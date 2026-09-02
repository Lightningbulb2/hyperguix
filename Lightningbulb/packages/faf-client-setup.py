#!/usr/bin/env python3
"""faf-client-setup — configure Supreme Commander: Forged Alliance's launch
command for the FAF client.

This is a Guix-friendly port of nix-gaming's faf-client-setup.py
(https://github.com/fufexan/nix-gaming/blob/master/pkgs/faf-client/faf-client-setup.py,
MIT, credit: chayleaf and contributors). The logic — walking Steam's
libraryfolders.vdf and each Proton prefix's config_info to work out the
right launch command — is theirs; this port only removes the `vdf` and
`pyxdg` third-party dependencies (replaced with a tiny stdlib-only VDF
reader and manual XDG base-dir lookups) so the script has zero extra
runtime dependencies to package.

It does NOT install Wine, Proton, or DXVK, and does NOT download anything.
It only detects what you already have (a Steam install of Supreme
Commander: Forged Alliance, normally launched at least once so Steam has
already set up its own Proton prefix for it, or an existing Wine prefix
you point it at) and writes ~/.faforever/client.prefs so the FAF client
knows how to launch the game.
"""

from os.path import expanduser, isfile, isdir, islink, join
from typing import Optional

import json
import os
import re
import sys
import shlex
import shutil


# --- tiny stdlib-only replacements for what `vdf` and `pyxdg` provided ---

def xdg_data_home():
    return os.environ.get("XDG_DATA_HOME") or expanduser("~/.local/share")


def xdg_cache_home():
    return os.environ.get("XDG_CACHE_HOME") or expanduser("~/.cache")


def xdg_config_home():
    return os.environ.get("XDG_CONFIG_HOME") or expanduser("~/.config")


def vdf_load(path):
    """Minimal recursive-descent reader for Valve's KeyValues/VDF format --
    just enough to read libraryfolders.vdf and appmanifest_*.acf. Comments
    (//) and conditional blocks ([$WIN32] etc.) are not supported, but
    Steam doesn't use them in these particular files."""
    text = open(path, "rt", encoding="utf-8", errors="replace").read()
    tokens = re.findall(r'"((?:[^"\\]|\\.)*)"|[{}]', text)
    pos = 0

    def unescape(s):
        return s.replace('\\"', '"').replace("\\\\", "\\")

    def parse_obj():
        nonlocal pos
        obj = {}
        while pos < len(matches):
            tok, is_brace = matches[pos]
            if is_brace == "}":
                pos += 1
                return obj
            if is_brace == "{":
                pos += 1
                continue
            # tok is a key
            key = unescape(tok)
            pos += 1
            if pos >= len(matches):
                break
            nxt_tok, nxt_brace = matches[pos]
            if nxt_brace == "{":
                pos += 1
                obj[key] = parse_obj()
            else:
                obj[key] = unescape(nxt_tok)
                pos += 1
        return obj

    matches = []
    for m in re.finditer(r'"((?:[^"\\]|\\.)*)"|(\{)|(\})', text):
        if m.group(1) is not None:
            matches.append((m.group(1), None))
        elif m.group(2):
            matches.append((None, "{"))
        else:
            matches.append((None, "}"))
    pos = 0
    # top-level: single "root name" then an object
    if not matches:
        return {}
    root = {}
    if matches[0][1] is None:
        pos = 1
        if pos < len(matches) and matches[pos][1] == "{":
            pos += 1
            root[unescape(matches[0][0])] = parse_obj()
    return root


def exit_err(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)
    sys.exit(1)


def read_path(prompt):
    """input() but tolerant of what people actually paste: surrounding
    whitespace, and a single layer of matching quote marks (many file
    managers' "copy path" wraps the path in quotes for shell-pasting,
    which input() has no reason to strip on its own)."""
    s = input(prompt).strip()
    if len(s) >= 2 and s[0] == s[-1] and s[0] in ('"', "'"):
        s = s[1:-1]
    return s.strip()


def candidate_home_roots():
    """Real HOME, plus any sandboxed home directories belonging to
    Guix's `nonguix' Steam package, which runs Steam inside an FHS
    container with its own isolated $HOME so it doesn't scatter dotfiles
    across your real one -- meaning Steam's actual library data can live
    somewhere this script's own (unsandboxed) view of $HOME never
    checks by default. `guix-sandbox-home` is the naming this was
    confirmed against directly (not verified against nonguix's source,
    which I couldn't get to from here) -- if yours differs, the game
    path prompt further down still accepts a manually typed path
    regardless."""
    roots = [expanduser("~")]
    sandbox = expanduser("~/.local/share/guix-sandbox-home")
    if isdir(sandbox):
        roots.append(sandbox)
    return roots


def steam_candidate_paths():
    paths = []
    for home in candidate_home_roots():
        paths.append(join(home, ".local/share/Steam"))
        paths.append(join(home, ".steam/steam"))
        paths.append(join(home, ".var/app/com.valvesoftware.Steam/.local/share/Steam"))
    return paths


steam_paths = steam_candidate_paths()

steam_path = None
for path in steam_paths:
    if isfile(join(path, "steamapps", "libraryfolders.vdf")):
        steam_path = path
        break

if steam_path is not None:
    root = vdf_load(join(steam_path, "steamapps", "libraryfolders.vdf"))
    LIBS = root.get("libraryfolders", {})
else:
    LIBS = {}
    print("Warning: Couldn't find Steam. You can still set things up for "
          "plain Wine below.")


def ensure(func, x):
    return x if func(x) else None


def compatdata(lib, id):
    return join(lib, "steamapps", "compatdata", id)


def find_path(id, name, default_path, multi=False):
    libs = []
    for folder in LIBS.values():
        if not isinstance(folder, dict):
            continue
        if id in folder.get("apps", {}):
            libs.append(folder["path"])

    if len(libs) == 0:
        return [] if multi else (None, None)

    if not multi:
        libs = [choose(libs, f"More than one Steam library contains "
                             f"{name}! Please choose the one you want to "
                             f"use.")]
    ret, low_prio = [], []
    for lib in libs:
        try:
            manifest = vdf_load(join(lib, "steamapps", f"appmanifest_{id}.acf"))
            state = manifest.get("AppState", {})
            if "installdir" not in state:
                raise FileNotFoundError()
            game_path = join(lib, "steamapps", "common", state["installdir"])
            append_to = ret
        except FileNotFoundError:
            game_path = join(lib, "steamapps", "common", default_path)
            append_to = low_prio
        if isdir(game_path) and len(os.listdir(game_path)):
            append_to.append((game_path, lib))
    if multi:
        return [x[0] for x in ret + low_prio]
    elif ret or low_prio:
        return (ret + low_prio)[0]
    return None, None


def choose(items, comment, default=0):
    if len(items) == 1:
        return items[0]
    print(comment)
    for i, lib in enumerate(items):
        print(f"[{i}] {lib}")
    while True:
        num = input(f"Enter the number (default: {default}): ")
        if not num:
            return items[default]
        try:
            n = int(num)
            if n < 0:
                raise ValueError()
            return items[n]
        except (ValueError, IndexError):
            print("Invalid number!")


def ask_yn(question, default):
    default_yn = "Y" if default else "N"
    while True:
        ans = input(f"{question} (Y/n, default: {default_yn}): ")
        if not ans:
            return default
        if ans.lower().startswith("y"):
            return True
        if ans.lower().startswith("n"):
            return False
        print("Invalid answer! Please write yes or no")


game_path, lib_path = find_path(
    "9420", "Supreme Commander: Forged Alliance",
    "Supreme Commander Forged Alliance")


def find_proton(lib_path, id):
    prefix = compatdata(lib_path, id)
    if not isfile(join(prefix, "config_info")):
        return None, None
    proton_path = None
    try:
        protons = set()
        dirs = ["/files/" + x for x in
                ("share/fonts", "lib", "lib64", "share/default_pfx")]
        dirs = dirs + [d + "/" for d in dirs]
        for line in open(join(prefix, "config_info")):
            line = line.strip()
            for d in dirs:
                if line.endswith(d):
                    protons.add(line[: -len(d)])
                    break
        protons = list(protons)
        if len(protons) != 1:
            raise ValueError()
        proton_path = protons[0]
    except (FileNotFoundError, ValueError):
        return None, None
    return ensure(isfile, join(proton_path, "proton")), join(prefix, "pfx")


proton_path = prefix_path = None
if lib_path is not None:
    proton_path, prefix_path = find_proton(lib_path, "9420")

if steam_path is not None:
    reaper_path = ensure(isfile, join(steam_path, "ubuntu12_32", "reaper"))
    launch_wrapper_path = ensure(
        isfile, join(steam_path, "ubuntu12_32", "steam-launch-wrapper"))
else:
    reaper_path = launch_wrapper_path = None

RUNTIMES = [("medic", None), ("sniper", "16283507"), ("soldier", "1391110"),
            ("heavy", None), ("scout", "1070560")]
PROTONS = [("experimental", "1493710"), ("next", "2230260"),
           ("hotfix", "2180100"), ("7.0", "1887720"), ("6.3", "1580130"),
           ("5.13", "1420170"), ("5.0", "1245040"), ("4.11", "1113280"),
           ("4.2", "1054830"), ("3.16 beta", "996510"), ("3.16", "961940"),
           ("3.7 beta", "930400"), ("3.7", "858280")]


def find_base(id, path):
    ret = []
    if id is not None:
        ret.extend(find_path(id, path, path, True))
    return ret


def find_proton2(name, id):
    rt_path = "Proton - Experimental" if name == "experimental" \
        else "Proton " + name.capitalize()
    ret = find_base(id, rt_path)
    return [ensure(isfile, join(x, "proton")) for x in ret]


def find_runtime(name, id):
    rt_path = "SteamLinuxRuntime" if name == "scout" \
        else "SteamLinuxRuntime_" + name
    ret = find_base(id, rt_path)
    return [x for x in ret if isfile(join(x, "_v2-entry-point"))]


if game_path is not None:
    if not ask_yn(f"Detected game path:\n{game_path}.\n\nCorrect?", True):
        game_path = None
while game_path is None:
    p = ensure(isdir, read_path("Please enter game path: "))
    if p is None:
        print("Invalid game path!")
    else:
        game_path = p

runtimes = []
for name, id in RUNTIMES:
    runtimes.extend(find_runtime(name, id))
protons = []
for name, id in PROTONS:
    protons.extend(find_proton2(name, id))

runtime_path = runtimes[0] if runtimes else None
needs_setup = proton_path is None
if proton_path is None and protons:
    proton_path = protons[0]
if runtime_path is None:
    proton_path = None


def to_sandbox_path(path):
    """Paths that will be used as arguments to programs running INSIDE
    the fhs-run/nonguix Steam sandbox need rewriting: nonguix's
    container bind-mounts $HOME/.local/share/guix-sandbox-home AT $HOME
    itself, inside the container -- so a path that's
    "$HOME/.local/share/guix-sandbox-home/foo" from outside the sandbox
    is just "$HOME/foo" from inside it. Passing the outside-form path to
    something that runs inside the sandbox resolves to a nonexistent,
    doubly-nested location. Confirmed in practice:
    `env: '.../guix-sandbox-home/.local/share/Steam/ubuntu12_32/reaper':
    No such file or directory`, even though that exact path is real and
    correct from outside the sandbox -- the reaper/wrapper/runtime/
    Proton chain, and the game's own install path, all run *inside* the
    sandbox and need the short form. Only apply this to those; NOT to
    paths the FAF client itself (a normal, unsandboxed process) reads
    directly, like preferencesFile or the vault/mods/maps directories,
    which should keep their real, full paths. Idempotent -- safe to
    call more than once on the same value."""
    if not path:
        return path
    real_home = expanduser("~")
    sandbox_home = expanduser("~/.local/share/guix-sandbox-home")
    if path.startswith(sandbox_home + "/"):
        return real_home + path[len(sandbox_home):]
    return path


def command(proton, runtime, wrapper, reaper, launcher, prepend):
    if launcher:
        # launcher is fhs-run's own store path, not something living
        # inside the sandbox -- deliberately not passed through
        # to_sandbox_path.
        return command(proton, runtime, wrapper, reaper, None,
                        prepend + shlex.quote(launcher) + " ")
    if reaper is not None:
        return command(proton, runtime, wrapper, None, None,
                        prepend + f"{shlex.quote(to_sandbox_path(reaper))} SteamLaunch AppId=9420 -- ")
    if wrapper is not None:
        return command(proton, runtime, None, None, None,
                        prepend + f"{shlex.quote(to_sandbox_path(wrapper))} -- ")
    if runtime is not None:
        return command(proton, None, None, None, None,
                        prepend + f"{shlex.quote(to_sandbox_path(join(runtime, '_v2-entry-point')))} --verb=waitforexitandrun -- ")
    if proton is not None:
        return command(None, None, None, None, None,
                        prepend + f"{shlex.quote(to_sandbox_path(proton))} waitforexitandrun ")
    return prepend + '"%s"'


def resolve_command(name):
    """Resolve NAME to an absolute path via *this script's* PATH,
    rather than leaving the bare command name in client.prefs for a
    completely different process (the FAF client itself, launched
    separately -- via a desktop menu entry, a different shell, or a
    different Guix profile's PATH -- with no guarantee it shares this
    script's environment) to look up on its own PATH later. Returns
    None if not found even here (callers decide how to handle that)."""
    return shutil.which(name)


def resolve_steam_run_equivalent():
    """`fhs-run' (this channel's own package, faforever/fhs-run.scm) is
    tried first: it's a genuine general-purpose "run this exact command
    inside Steam's FHS sandbox" tool, built from nonguix's own
    nonguix-container machinery, needed because nonguix's `steam'
    package itself doesn't expose one (confirmed from its actual
    source: `fhs-internal' always execs one hardcoded target, Steam
    itself). Falls back to a literal `steam-run' if that happens to
    exist (e.g. a differently-set-up system), then to None."""
    return resolve_command("fhs-run") or resolve_command("steam-run")


steam_run_equiv = resolve_steam_run_equivalent()
steam_binary_path = resolve_command("steam")

via_steam_applaunch = False
if steam_run_equiv is None:
    print("Neither `fhs-run' nor `steam-run' is available. Without one of "
          "these, there's no way to run FAF's own precisely-constructed "
          "launch command (pointing at FAF's own patched game files, not "
          "just the vanilla Steam install) inside a working FHS/Proton "
          "environment.")
    print("Strongly recommended: build and install `fhs-run' from this "
          "channel (faforever/fhs-run.scm), then re-run this script.")
    if steam_binary_path is not None:
        via_steam_applaunch = ask_yn(
            "As a fallback ONLY (not recommended -- see below), set the "
            "launch command to `steam -applaunch 9420 \"%s\"' anyway?",
            False)
        if via_steam_applaunch:
            print("Warning: `-applaunch' launches Steam's OWN configured "
                  "executable for this App ID, appending arguments to it -- "
                  "it can NOT substitute FAF's own patched executable the "
                  "way `%s' is meant to. This will very likely not actually "
                  "work for playing FAF games; it's here only so you have "
                  "*something* written to client.prefs rather than nothing.")

if via_steam_applaunch:
    old_setup = False  # unused in this branch, but keeps later code simple
    cmd = f'{steam_binary_path} -applaunch 9420 "%s"'
    print(f"\nLaunch command set to `{cmd}'.")
    needs_setup = True
else:
    old_setup = not ask_yn(
        "Use the new setup wizard for Steam+Proton? Answer no if you plan to "
        "use plain Wine.", True)

    if not old_setup:
        input("1. Set Supreme Commander: Forged Alliance's launch options in "
              "Steam to `PROTON_NO_ESYNC=1 PROTON_DUMP_DEBUG_COMMANDS=1 "
              "%command%` and press enter. ")
        input("2. Run Supreme Commander: Forged Alliance at least once and "
              "press enter. ")
        source_path = f"/tmp/proton_{os.environ.get('USER', '')}/run"
        while not os.path.exists(source_path):
            if ask_yn(f"Failed to locate {source_path}. Switch to legacy "
                      f"wizard instead? If not, run Supreme Commander again "
                      f"and answer no to try again.", True):
                old_setup = True
                break


def _resolve_or_bare(name):
    """Like resolve_command, but falls back to the bare name (with a
    warning) -- used for the legacy reconstruction path below, where
    giving up isn't an option since we're already committed to it."""
    resolved = resolve_command(name)
    if resolved is None:
        print(f"Warning: couldn't find `{name}' on PATH even here -- "
              f"writing the bare command name, but the FAF client will "
              f"likely fail to launch the game with a \"No such file or "
              f"directory\" error until `{name}' is actually installed "
              f"and on PATH.")
        return name
    return resolved


if via_steam_applaunch:
    pass  # cmd already set above
elif not old_setup:
    os.makedirs(expanduser("~/.local/share/faforever"), exist_ok=True)
    target_path = expanduser("~/.local/share/faforever/run.sh")
    shutil.copy2(source_path, target_path)
    steam_run = steam_run_equiv or _resolve_or_bare("fhs-run")
    print(f"Launch command will be set to `{steam_run} {target_path} \"%s\"`. "
          f"You may modify the `run.sh` script as necessary.")
    cmd: Optional[str] = f'{steam_run} {target_path} "%s"'
else:
    launcher: Optional[str] = steam_run_equiv or _resolve_or_bare("fhs-run")
    env = {"PROTON_NO_ESYNC": "1"} if proton_path else {}

    def cur_cmd():
        env_s = "".join(f"{shlex.quote(k)}={shlex.quote(v)} "
                         for k, v in env.items())
        if env_s:
            env_s = "env " + env_s
        return command(proton_path, runtime_path, launch_wrapper_path,
                        reaper_path, launcher, env_s)

    cmd = cur_cmd()
    print("\nAutodetected launch command:")
    print(cmd)
    if not ask_yn("\nCorrect?", True):
        cmd = None

    def ask_cmd():
        val = cur_cmd()
        print("Launch command:", val)
        if ask_yn("\nCorrect?", True):
            return val

    if cmd is None:
        env_s = "".join(f"{shlex.quote(k)}={shlex.quote(v)} "
                         for k, v in env.items())
        print("Env vars:", env_s if env_s else "none")
        if not ask_yn("\nCorrect?", True):
            while True:
                parts = shlex.split(input("Enter your own env vars: "))
                env = {}
                try:
                    for part in parts:
                        k, v = part.split("=")
                        env[k] = v
                    break
                except ValueError:
                    print("Invalid environment variable list!")
            cmd = ask_cmd()

    if cmd is None and (runtime_path is None or
                        not ask_yn("Use Steam runtime?", True)):
        runtime_path = None
        launch_wrapper_path = None
        reaper_path = None
        if steam_path and ask_yn("Use Proton?", True):
            env["STEAM_COMPAT_CLIENT_INSTALL_PATH"] = steam_path
            if prefix_path is not None and os.path.split(prefix_path)[-1] == "pfx":
                pfx = os.path.split(prefix_path)[0]
                pfx1 = expanduser(read_path(f"Enter prefix path (Default: {prefix_path}): "))
                pfx = pfx1 or pfx
            else:
                pfx = expanduser(read_path("Enter prefix path: "))
            needs_setup = True
            env["STEAM_COMPAT_DATA_PATH"] = pfx
            prefix_path = join(pfx, "pfx")
            if proton_path is not None:
                cmd = ask_cmd()
            if cmd is None:
                proton_path = expanduser(read_path("Enter path to proton binary: "))
        elif ask_yn("Use Wine?", True):
            env.pop("PROTON_NO_ESYNC", None)
            env.pop("PROTON_NO_FSYNC", None)
            proton_path = None
            if ask_yn("Use 32-bit WINEARCH?", True):
                env["WINEARCH"] = "win32"
            prefix_path = expanduser(read_path("Enter prefix path (default: ~/.wine): "))
            if prefix_path:
                env["WINEPREFIX"] = prefix_path
            else:
                prefix_path = expanduser("~/.wine")
            needs_setup = True
            launcher = resolve_command("wine")
            cmd = ask_cmd()
            if cmd is None:
                launcher = expanduser(read_path("Enter custom path to wine binary: "))
                cmd = ask_cmd()
        else:
            launcher = None
            prefix_path = None
            env.pop("PROTON_NO_ESYNC", None)
            env.pop("PROTON_NO_FSYNC", None)
            proton_path = None
    elif cmd is None:
        if not ask_yn("Is the correct Proton version being used?", True):
            opts = ["Custom"] + protons
            proton_path = choose(opts, "Choose the Proton version.", 1)
            if proton_path == "Custom":
                proton_path = expanduser(read_path("Enter custom path to proton binary: "))
            cmd = ask_cmd()
        if cmd is None and not ask_yn("Is the correct Steam Runtime being used?", True):
            opts = ["Custom"] + runtimes
            runtime_path = choose(opts, "Choose the Steam Runtime", 1)
            if runtime_path == "Custom":
                runtime_path = expanduser(read_path(
                    "Enter custom Steam runtime path (must have a "
                    "_v2-entry-point binary inside): "))
            cmd = ask_cmd()
        if cmd is None and not ask_yn("Use steam-launch-wrapper?", True):
            launch_wrapper_path = None
            cmd = ask_cmd()
        if cmd is None and not ask_yn("Use reaper?", True):
            reaper_path = None
            cmd = ask_cmd()
        if (cmd is None and (launch_wrapper_path is not None or reaper_path is not None)
                and not ask_yn("Use 32-bit steam-launch-wrapper/reaper?", True)):
            if reaper_path is not None and steam_path is not None:
                reaper_path = ensure(isfile, join(steam_path, "ubuntu12_64", "reaper"))
            if launch_wrapper_path is not None and steam_path is not None:
                launch_wrapper_path = ensure(
                    isfile, join(steam_path, "ubuntu12_64", "steam-launch-wrapper"))
            cmd = ask_cmd()

    if cmd is None:
        needs_setup = True
        print("Couldn't automatically guess the launch command.")
        cmd = input('Enter custom launch command (use "%s" instead of the exe path): ')

if needs_setup:
    print("Don't forget to set the Wine/Proton prefix up for SupCom "
          "(DXVK etc.) if you haven't already!")

save_path = save_base = ""
if prefix_path:
    users = join(prefix_path, "drive_c", "users")
    user = join(users, "steamuser" if proton_path else os.getlogin())
    save_base = join(user, "AppData", "Local", "Gas Powered Games",
                      "Supreme Commander Forged Alliance")
    save_path = join(save_base, "Game.prefs")

if save_path:
    print("\nAutomatically inferred Game.prefs save path:")
    print(save_path)
    if not isfile(save_path):
        print("\n!!! Warning: file does not exist!", end="")

save_is_default = True
if not save_path or not ask_yn("\nCorrect?", True):
    save_is_default = False
    save_path = expanduser(read_path("Enter Game.prefs save path (inside the Wine prefix): "))
    save_base = os.path.split(save_path)[0]

config = {"forgedAlliance": {"installationPath": to_sandbox_path(game_path),
                              "preferencesFile": save_path,
                              "executableDecorator": cmd}}

if ask_yn("Enable IPv6 support?", True):
    config["forgedAlliance"]["allowIpv6"] = True

changed_dirs = False
if ask_yn("Change FAF config to use XDG_DATA_HOME (~/.local/share)?", True):
    changed_dirs = True
    data, cache = xdg_data_home(), xdg_cache_home()
    faf_home = join(data, "faforever")
    sup_home = join(data, "Gas Powered Games", "Supreme Commander Forged Alliance")
    sup_config = join(xdg_config_home(), "Gas Powered Games",
                       "Supreme Commander Forged Alliance")
    sup_cache = join(cache, "Gas Powered Games", "Supreme Commander Forged Alliance")

    if save_is_default and not islink(save_path):
        os.makedirs(sup_config, exist_ok=True)
        old_save_path = save_path
        save_path = join(sup_config, "Game.prefs")
        config["forgedAlliance"]["preferencesFile"] = save_path
        if isfile(old_save_path):
            if isfile(save_path):
                os.remove(old_save_path)
            else:
                shutil.move(old_save_path, save_path)
        os.symlink(save_path, old_save_path)

    old_sup_cache = join(save_base, "cache") if save_is_default else None
    if save_is_default and old_sup_cache and not islink(old_sup_cache):
        os.makedirs(join(cache, "Gas Powered Games"), exist_ok=True)
        if isdir(old_sup_cache):
            shutil.move(old_sup_cache, sup_cache)
        os.symlink(sup_cache, old_sup_cache)

    config["forgedAlliance"]["vaultBaseDirectory"] = sup_home
    config["forgedAlliance"]["modsDirectory"] = join(sup_home, "mods")
    config["forgedAlliance"]["mapsDirectory"] = join(sup_home, "maps")
    config["data"] = {
        "baseDataDirectory": faf_home,
        "binDirectory": join(faf_home, "bin"),
        "mapGeneratorDirectory": join(faf_home, "map_generator"),
        "cacheDirectory": faf_home,
        "cacheStylesheetsDirectory": join(faf_home, "stylesheets"),
        "featuredModCacheDirectory": join(faf_home, "featured_mod"),
        "languagesDirectory": join(faf_home, "languages"),
        "themesDirectory": join(faf_home, "themes"),
        "replaysDirectory": join(faf_home, "replays"),
        "corruptedReplaysDirectory": join(faf_home, "corrupt"),
    }


def deep_update(x, update):
    for k, v in update.items():
        if k not in x or not isinstance(v, dict):
            x[k] = v
        else:
            deep_update(x[k], v)


print("Final config:")
print(json.dumps(config, indent=2))
if changed_dirs:
    print("# FAF data will be in `~/.local/share/faforever`.")
    print("# Supreme Commander config: `~/.config/Gas Powered Games/Supreme "
          "Commander Forged Alliance`")
    print("# Supreme Commander maps/mods: `~/.local/share/Gas Powered Games/"
          "Supreme Commander Forged Alliance`")

if ask_yn("Commit (other settings will be preserved if already set)?", True):
    os.makedirs(expanduser("~/.faforever"), exist_ok=True)
    config_path = expanduser("~/.faforever/client.prefs")
    if isfile(config_path):
        shutil.copy2(config_path, expanduser("~/.faforever/client.prefs.bak"))
        print("Wrote a backup of the old client.prefs to client.prefs.bak")
        new_config = config
        config = json.loads(open(config_path, "rt", encoding="utf-8").read())
        deep_update(config, new_config)
    open(config_path, "wt", encoding="utf-8").write(json.dumps(config, indent=2))
