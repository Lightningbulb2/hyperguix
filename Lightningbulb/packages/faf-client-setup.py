#!/usr/bin/env python3
"""faf-client-setup — fully automatic, non-interactive setup of Supreme
Commander: Forged Alliance's launch command for the FAF client, on GNU
Guix with nonguix's Steam + this channel's fhs-run.

Steam + Proton only -- no Wine support. Detects your existing Steam
install of Supreme Commander: Forged Alliance (Steam App ID 9420,
normally already launched at least once so Steam has set up its own
Proton compatdata prefix for it) and writes ~/.faforever/client.prefs
(via a symlink -- see below) so the FAF client knows how to launch the
game inside this channel's `fhs-run` sandbox.

Runs once, top to bottom, with no prompts: either everything gets
auto-detected and it writes the config, or it fails loudly with an
explanation of what to check. Re-running is safe -- existing
client.prefs settings are preserved/merged (backed up to
client.prefs.bak first), and directories already redirected are left
alone.

Escape hatches, for when auto-detection can't find something (e.g. a
Proton build newer than the PROTONS list below knows about): set
FAF_GAME_PATH, FAF_PROTON_PATH, and/or FAF_RUNTIME_PATH in the
environment to override detection for that piece.

Directory layout this script sets up:
  ~/.config/faforever
    client.prefs itself. `~/.faforever` is symlinked here, since the
    FAF client hardcodes ~/.faforever/client.prefs and isn't XDG-aware
    (confirmed against FAForever/downlords-faf-client's own issue
    tracker -- this isn't overridable via an env var).
  ~/.local/share/faforever
    FAF's own managed copy of the game (binDirectory, the actual
    ForgedAlliance.exe the launch command runs, cache, replays, ...).
    Unchanged -- already XDG-correct.
  ~/.config/Gas-Powered-Games/Supreme-Commander-Forged-Alliance
    Game.prefs, symlinked in from the Proton prefix's
    `AppData/Local/Gas Powered Games/Supreme Commander Forged
    Alliance`, which is where the actual Windows game reads/writes it.
  ~/.local/share/Gas-Powered-Games/Supreme-Commander-Forged-Alliance
    mods/maps, symlinked in from the Proton prefix's `My Documents/My
    Games/Gas Powered Games/Supreme Commander Forged Alliance` --
    NOT the AppData/Local directory above. These are two different
    locations inside the prefix; confirmed against real user reports
    of mods/maps silently not showing up in-game when only the
    AppData/Local side gets redirected and this one is missed.

This is a Guix-friendly, Proton-only rewrite of nix-gaming's
faf-client-setup.py
(https://github.com/fufexan/nix-gaming/blob/master/pkgs/faf-client/faf-client-setup.py,
MIT, credit: chayleaf and contributors), whose Steam-library/Proton
detection logic (walking libraryfolders.vdf and each Proton prefix's
config_info) this still reuses.
"""

from os.path import expanduser, isfile, isdir, islink, join

import json
import os
import re
import shlex
import shutil
import sys


def die(msg):
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(1)


def note(msg):
    print(f"# {msg}")


# --- tiny stdlib-only replacements for what `vdf` and `pyxdg` provided ---

def xdg_data_home():
    return os.environ.get("XDG_DATA_HOME") or expanduser("~/.local/share")


def xdg_config_home():
    return os.environ.get("XDG_CONFIG_HOME") or expanduser("~/.config")


def vdf_load(path):
    """Minimal recursive-descent reader for Valve's KeyValues/VDF format --
    just enough to read libraryfolders.vdf and appmanifest_*.acf. Comments
    (//) and conditional blocks ([$WIN32] etc.) are not supported, but
    Steam doesn't use them in these particular files."""
    text = open(path, "rt", encoding="utf-8", errors="replace").read()

    def unescape(s):
        return s.replace('\\"', '"').replace("\\\\", "\\")

    matches = []
    for m in re.finditer(r'"((?:[^"\\]|\\.)*)"|(\{)|(\})', text):
        if m.group(1) is not None:
            matches.append((m.group(1), None))
        elif m.group(2):
            matches.append((None, "{"))
        else:
            matches.append((None, "}"))

    pos = 0

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

    if not matches:
        return {}
    root = {}
    if matches[0][1] is None:
        pos = 1
        if pos < len(matches) and matches[pos][1] == "{":
            pos += 1
            root[unescape(matches[0][0])] = parse_obj()
    return root


def candidate_home_roots():
    """Real HOME, plus any sandboxed home directory belonging to Guix's
    `nonguix' Steam package, which runs Steam inside an FHS container
    with its own isolated $HOME so it doesn't scatter dotfiles across
    your real one -- meaning Steam's actual library data can live
    somewhere this script's own (unsandboxed) view of $HOME never
    checks by default. `guix-sandbox-home` is the naming this was
    confirmed against directly (not verified against nonguix's source,
    which I couldn't get to from here) -- if yours differs, set
    FAF_GAME_PATH to bypass detection entirely."""
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


def from_sandbox_path(path):
    """Inverse of to_sandbox_path(): Steam itself runs INSIDE the
    fhs-run sandbox, where $HOME shows guix-sandbox-home's content
    directly -- so any path VALUE Steam writes into its own config
    files (the "path" field of each library entry in
    libraryfolders.vdf) is recorded from that in-sandbox (short) point
    of view, not the real, full path this script (running unsandboxed)
    needs to actually read from disk. Confirmed in practice: a library
    whose "apps" map correctly listed App ID 9420 was still reported as
    "not found", because the recorded library path
    "$HOME/.local/share/Steam" doesn't exist at all outside the
    sandbox -- only
    "$HOME/.local/share/guix-sandbox-home/.local/share/Steam" does.
    Only rewrites when the rewritten path actually exists, so it's a
    no-op outside the sandboxed-Steam setup (or for libraries that
    live somewhere else entirely, e.g. a separate drive)."""
    if not path:
        return path
    real_home = expanduser("~")
    sandbox_home = expanduser("~/.local/share/guix-sandbox-home")
    if not isdir(sandbox_home):
        return path
    if path == real_home or path.startswith(real_home + "/"):
        if path.startswith(sandbox_home):
            return path  # already in full/outside form
        rewritten = sandbox_home + path[len(real_home):]
        if isdir(rewritten):
            return rewritten
    return path


def faf_quote(s):
    """Quote S the way the FAF client's OWN executableDecorator parser
    expects -- NOT a POSIX shell. There is no shell involved at all:
    the client tokenizes this string itself and execs argv directly
    (its own logs show a literal ["env", "PROTON_NO_ESYNC=1", ...]
    array). Confirmed in practice: wrapping a path in single quotes
    (shlex.quote()'s style) does NOT protect embedded spaces -- a
    Proton path like ".../Proton - Experimental" got torn into three
    separate broken arguments, with the single-quote characters left
    behind as literal text. The client's own convention for the "%s"
    placeholder is always double-quoted, which its parser evidently
    DOES respect for grouping -- so that's what's used here too."""
    if s and re.search(r'[\s"]', s):
        return '"' + s.replace('"', '\\"') + '"'
    return s


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
            libs.append(from_sandbox_path(folder["path"]))

    if len(libs) == 0:
        return [] if multi else (None, None)

    if not multi:
        if len(libs) > 1:
            note(f"{name} found in {len(libs)} Steam libraries -- using "
                 f"{libs[0]}")
        libs = [libs[0]]
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
    Proton chain all run *inside* the sandbox and need the short form.
    Only apply this to those; NOT to paths the FAF client itself (a
    normal, unsandboxed process) reads directly -- preferencesFile, the
    vault/mods/maps directories, and installationPath (the client reads
    the original Steam install directly to seed its own managed copy;
    it's never passed into command() at all) -- which should keep their
    real, full paths. Idempotent -- safe to call more than once on the
    same value."""
    if not path:
        return path
    real_home = expanduser("~")
    sandbox_home = expanduser("~/.local/share/guix-sandbox-home")
    if path.startswith(sandbox_home + "/"):
        return real_home + path[len(sandbox_home):]
    return path


def write_launch_script(reaper, wrapper, runtime, proton):
    """Write the reaper -> steam-launch-wrapper -> Steam Linux Runtime ->
    Proton launch chain out as a REAL, on-disk POSIX shell script (quoted
    with shlex.quote(), ordinary shell quoting) instead of folding the
    whole thing into one string for the FAF client's own
    executableDecorator tokenizer to parse. Returns the SHORT (in-sandbox)
    path to the script, ready to drop straight into the command string.

    This works around a real bug in nonguix's `fhs-internal` -- shared by
    *every* nonguix-container, not just this channel's fhs-run, not
    something fixable from this side by reshuffling "--"s. Confirmed
    against nonguix's own nonguix/multiarch-container.scm
    (`make-internal-script`):

        (fhs-args (member "--" all-args))
        (package-args (if fhs-args
                          (reverse (cdr (member "--" (reverse all-args))))
                          all-args))

    `all-args` there is fhs-run's own full argv. This looks for the LAST
    "--" in it and treats everything after that point as fhs-run's own
    options (e.g. "-- --asound32" for 32-bit audio) -- `package-args`
    (what actually gets exec'd) is unconditionally truncated right
    before that final "--", full stop, regardless of what's there.

    The Steam Linux Runtime launch chain legitimately needs three "--"
    separators of its own (reaper's, steam-launch-wrapper's, and
    _v2-entry-point's -- the last one right before the actual `proton
    ... game.exe` command), so fhs-internal's "last --" is always one
    of *ours*, never its own, and it was silently discarding "proton
    waitforexitandrun ForgedAlliance.exe ..." -- and every game
    argument after it (/init, /gpgnet, /savereplay, ...) -- leaving
    _v2-entry-point with nothing to run at all. Confirmed in practice:
    the FAF client's own log shows "Launching coreutils in sandbox"
    (fhs-run starting up fine) immediately followed by
    "_v2-entry-point[N]: Error: A command to run is required" (its
    COMMAND having been silently dropped).

    The only real fix is making sure fhs-run's own argv never contains
    a bare "--" token at all. Writing this whole chain out as a real
    script file and invoking *that* with the actual game executable
    (substituted in for "%s") as its one plain argument keeps fhs-run's
    own command line down to two clean tokens -- the script's path and
    "%s" -- with no "--" anywhere for fhs-internal to trip over. "$@"
    inside the script forwards the substituted executable *and* every
    game argument FAF appends after it (all of /init, /log, /gpgnet,
    /savereplay, /numgames, etc. -- confirmed from the client's own log
    to be separate, space-preserved argv elements following "%s", not
    bundled into it), each with its spaces intact via ordinary shell
    quoting -- so nothing downstream of "%s" gets lost either.

    The script must live *inside* the sandboxed home
    (~/.local/share/guix-sandbox-home), not the real one: nonguix's
    container bind-mounts that directory AT $HOME itself inside the
    sandbox, entirely replacing the view of $HOME rather than layering
    on top of it, so anything written under the *real*, unsandboxed
    $HOME (e.g. ~/.config/faforever) would simply not exist as far as
    the sandboxed process launching it is concerned."""
    sandbox_home = expanduser("~/.local/share/guix-sandbox-home")
    if not isdir(sandbox_home):
        die("~/.local/share/guix-sandbox-home not found -- expected "
            "since Steam and the game were already detected as running "
            "through it. Can't safely place the generated launch script "
            "where the sandbox will actually see it.")
    script_path = join(sandbox_home, "faf-launch.sh")
    script = (
        "#!/bin/sh\n"
        "exec {reaper} SteamLaunch AppId=9420 -- {wrapper} -- {entry} "
        "--verb=waitforexitandrun -- {proton} waitforexitandrun \"$@\"\n"
    ).format(
        reaper=shlex.quote(to_sandbox_path(reaper)),
        wrapper=shlex.quote(to_sandbox_path(wrapper)),
        entry=shlex.quote(to_sandbox_path(join(runtime, "_v2-entry-point"))),
        proton=shlex.quote(to_sandbox_path(proton)),
    )
    with open(script_path, "wt", encoding="utf-8") as f:
        f.write(script)
    os.chmod(script_path, 0o755)
    note(f"wrote {script_path} (visible inside the sandbox as "
         f"{to_sandbox_path(script_path)})")
    return to_sandbox_path(script_path)


def command(proton, runtime, wrapper, reaper, launcher, prepend):
    script_path = write_launch_script(reaper, wrapper, runtime, proton)
    # launcher is fhs-run's own store path, not something living inside
    # the sandbox -- deliberately not passed through to_sandbox_path.
    # Invoked explicitly via /bin/sh (also just a plain token, adding no
    # "--" for fhs-internal to trip over) rather than relying on the
    # kernel resolving the script's own "#!/bin/sh" shebang against
    # whatever "/bin/sh" happens to mean inside the sandbox's mount
    # namespace at that point.
    return (prepend + faf_quote(launcher) + " /bin/sh " +
            faf_quote(script_path) + ' "%s"')


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


def redirect_to(link_path, real_dir):
    """Make LINK_PATH a symlink pointing at REAL_DIR, merging in
    anything already at LINK_PATH first (existing files in REAL_DIR win
    on name clashes). Idempotent -- safe to re-run."""
    os.makedirs(real_dir, exist_ok=True)
    if islink(link_path):
        if os.path.realpath(link_path) == os.path.realpath(real_dir):
            return
        note(f"{link_path} is already a symlink to "
             f"{os.readlink(link_path)} -- leaving it alone")
        return
    if isdir(link_path):
        for entry in os.listdir(link_path):
            src, dst = join(link_path, entry), join(real_dir, entry)
            if os.path.exists(dst):
                note(f"{dst} already exists -- keeping it, not overwriting "
                     f"with {src}")
                continue
            shutil.move(src, dst)
        try:
            os.rmdir(link_path)
        except OSError:
            note(f"{link_path} still has files in it after merging into "
                 f"{real_dir} -- leaving it as a real directory rather "
                 f"than symlinking over it. Resolve the leftover files by "
                 f"hand and re-run to finish the redirect.")
            return
    elif isfile(link_path):
        os.remove(link_path)
    os.makedirs(os.path.dirname(link_path), exist_ok=True)
    os.symlink(real_dir, link_path)
    note(f"{link_path} -> {real_dir}")


def deep_update(x, update):
    for k, v in update.items():
        if k not in x or not isinstance(v, dict):
            x[k] = v
        else:
            deep_update(x[k], v)


# --- Steam ---

steam_path = None
for path in steam_candidate_paths():
    if isfile(join(path, "steamapps", "libraryfolders.vdf")):
        steam_path = path
        break

if steam_path is None:
    die("Steam not found (checked ~/.local/share/Steam, ~/.steam/steam, "
        "and the Flatpak path, under both your real home and "
        "~/.local/share/guix-sandbox-home). Install and run nonguix's "
        "`steam` package at least once, then re-run this script.")

root = vdf_load(join(steam_path, "steamapps", "libraryfolders.vdf"))
LIBS = root.get("libraryfolders", {})
note(f"steam: {steam_path}")

# --- game ---

game_path = os.environ.get("FAF_GAME_PATH")
lib_path = None
if game_path:
    note(f"game (FAF_GAME_PATH override): {game_path}")
else:
    game_path, lib_path = find_path(
        "9420", "Supreme Commander: Forged Alliance",
        "Supreme Commander Forged Alliance")
    if game_path is None:
        die("Supreme Commander: Forged Alliance (Steam App ID 9420) not "
            "found installed in any Steam library. Install it via Steam "
            "first, or set FAF_GAME_PATH to override detection.")
    note(f"game: {game_path}")

if lib_path is None:
    # FAF_GAME_PATH override -- compatdata lookups below still need
    # some library to search under.
    lib_path = steam_path

# --- Proton ---

proton_path = os.environ.get("FAF_PROTON_PATH")
prefix_path = None
if proton_path:
    note(f"proton (FAF_PROTON_PATH override): {proton_path}")
    prefix_path = join(compatdata(lib_path, "9420"), "pfx")
else:
    proton_path, prefix_path = find_proton(lib_path, "9420")
    if proton_path is None:
        protons = []
        for name, id in PROTONS:
            protons.extend(find_proton2(name, id))
        if protons:
            proton_path = protons[0]
            prefix_path = join(compatdata(lib_path, "9420"), "pfx")
    if proton_path is not None:
        note(f"proton: {proton_path}")

if proton_path is None or prefix_path is None or not isdir(prefix_path):
    die("No Proton install/prefix detected for App ID 9420. In Steam: "
        "right-click Supreme Commander: Forged Alliance -> Properties -> "
        "Compatibility -> force a specific Proton version, then run the "
        "game at least once via Steam so it creates its compatdata "
        "prefix, then re-run this script. If detection keeps failing "
        "(e.g. you're on a Proton version newer than this script's "
        "PROTONS list knows about), set FAF_PROTON_PATH=/path/to/proton "
        "and re-run.")

# --- Steam Linux Runtime ---

runtime_path = os.environ.get("FAF_RUNTIME_PATH")
if not runtime_path:
    runtimes = []
    for name, id in RUNTIMES:
        runtimes.extend(find_runtime(name, id))
    runtime_path = runtimes[0] if runtimes else None

if runtime_path is None:
    die("No Steam Linux Runtime detected (checked scout/soldier/sniper/"
        "medic/heavy in your Steam libraries). Steam normally installs "
        "one automatically the first time you run a Proton game -- try "
        "running Supreme Commander via Steam once more, or set "
        "FAF_RUNTIME_PATH=/path/to/runtime to override.")
note(f"runtime: {runtime_path}")

# --- reaper / steam-launch-wrapper ---

reaper_path = launch_wrapper_path = None
for arch in ("ubuntu12_32", "ubuntu12_64"):
    if reaper_path is None:
        reaper_path = ensure(isfile, join(steam_path, arch, "reaper"))
    if launch_wrapper_path is None:
        launch_wrapper_path = ensure(
            isfile, join(steam_path, arch, "steam-launch-wrapper"))

if reaper_path is None or launch_wrapper_path is None:
    die(f"Couldn't find `reaper`/`steam-launch-wrapper` under "
        f"{steam_path}/ubuntu12_{{32,64}}. Your Steam install may be "
        f"incomplete -- try running Steam once more.")

# --- fhs-run ---

launcher = resolve_steam_run_equivalent()
if launcher is None:
    die("Neither `fhs-run` nor `steam-run` is on PATH. Install this "
        "channel's `fhs-run` package (`guix install fhs-run`, or just "
        "`guix install faf-client`, which pulls it in automatically), "
        "then re-run this script.")

env = {
    "PROTON_NO_ESYNC": "1",
    # Required -- Proton's own `proton` script does a hard `sys.exit(1)`
    # ("No compat data path?") at startup if STEAM_COMPAT_DATA_PATH isn't
    # set, and reads STEAM_COMPAT_CLIENT_INSTALL_PATH unconditionally a
    # few lines into setup_prefix() right after (KeyError otherwise --
    # confirmed against ValveSoftware/Proton's own `proton` source).
    # Normally Steam itself sets both before ever invoking Proton; since
    # this whole reaper/wrapper/runtime/proton chain bypasses Steam's
    # own launcher entirely, nothing else will set them for us.
    "STEAM_COMPAT_DATA_PATH": to_sandbox_path(os.path.dirname(prefix_path)),
    "STEAM_COMPAT_CLIENT_INSTALL_PATH": to_sandbox_path(steam_path),
    # Not required to get past the crash above, but genuinely read by
    # Proton (STEAM_COMPAT_APP_ID gates a handful of per-game Proton bug
    # workarounds; STEAM_COMPAT_INSTALL_PATH/LIBRARY_PATHS enable its
    # "gamedrive" feature for games that reference sibling files in the
    # same Steam library by relative path) -- included for parity with
    # what real Steam would set, at negligible cost.
    "STEAM_COMPAT_APP_ID": "9420",
    "STEAM_COMPAT_INSTALL_PATH": to_sandbox_path(game_path),
    # Must be the *steamapps* subdirectory of each library, not the bare
    # library root -- confirmed against Proton's own source
    # (get_validated_steamapps_parent() specifically checks
    # `os.path.basename(path) == "steamapps"` before using its parent as
    # the game-drive root; passing the library root itself just makes
    # that check silently fail and log `Error: unable to use parent for
    # game drive, path ...`, disabling the gamedrive feature rather than
    # crashing outright -- but there's no reason to leave it broken).
    "STEAM_COMPAT_LIBRARY_PATHS": to_sandbox_path(join(steam_path, "steamapps")),
}
env_s = "env " + "".join(f"{faf_quote(f'{k}={v}')} " for k, v in env.items())
cmd = command(proton_path, runtime_path, launch_wrapper_path, reaper_path,
              launcher, env_s)
note("launch command:")
note(cmd)

# --- consolidated config/data directories ---

faf_config = join(xdg_config_home(), "faforever")
redirect_to(expanduser("~/.faforever"), faf_config)

game_config = join(xdg_config_home(), "Gas-Powered-Games",
                    "Supreme-Commander-Forged-Alliance")
game_data = join(xdg_data_home(), "Gas-Powered-Games",
                  "Supreme-Commander-Forged-Alliance")
os.makedirs(join(game_data, "mods"), exist_ok=True)
os.makedirs(join(game_data, "maps"), exist_ok=True)

users = join(prefix_path, "drive_c", "users", "steamuser")
redirect_to(join(users, "AppData", "Local", "Gas Powered Games",
                  "Supreme Commander Forged Alliance"), game_config)
redirect_to(join(users, "My Documents", "My Games", "Gas Powered Games",
                  "Supreme Commander Forged Alliance"), game_data)

save_path = join(game_config, "Game.prefs")
faf_home = join(xdg_data_home(), "faforever")

config = {
    "forgedAlliance": {
        "installationPath": game_path,
        "preferencesFile": save_path,
        "executableDecorator": cmd,
        "allowIpv6": True,
        "vaultBaseDirectory": game_data,
        "modsDirectory": join(game_data, "mods"),
        "mapsDirectory": join(game_data, "maps"),
    },
    "data": {
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
    },
}

config_path = join(faf_config, "client.prefs")
os.makedirs(faf_config, exist_ok=True)
if isfile(config_path):
    shutil.copy2(config_path, config_path + ".bak")
    note(f"backed up existing client.prefs to {config_path}.bak")
    existing = json.loads(open(config_path, "rt", encoding="utf-8").read())
    deep_update(existing, config)
    config = existing
open(config_path, "wt", encoding="utf-8").write(json.dumps(config, indent=2))
note(f"wrote {config_path}")
print("\nDone. Run `faf-client` to log in and play.")
