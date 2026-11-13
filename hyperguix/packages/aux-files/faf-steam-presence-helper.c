/* faf-steam-presence-helper -- Steam's "playing Supreme Commander: Forged
   Alliance" while a FAF game runs, from inside nonguix's Steam container.

   The FAF client's own helper (`faforever-client --steam-presence') calls
   SteamAPI_Init on the host, where Steam can't be found: nonguix runs Steam in
   a container with its own home, process and IPC namespaces.  faf-steam-presence
   starts this program in those namespaces instead.  It is built against the
   container's FHS glibc (/lib64), signs in as app $SteamAppId through the given
   libsteam_api.so, and keeps the status until its standard input closes, which
   faf-steam-presence does when the game exits.

   Usage: faf-steam-presence-helper LIBSTEAM_API.SO
   Exit codes are those of the client's helper: 0 the game ended, 2 usage,
   4 no library, 5 no entry point, 6 Steam refused.  */

#include <dlfcn.h>
#include <poll.h>
#include <stdio.h>
#include <unistd.h>

typedef int (*init_flat_fn) (char *message);
typedef int (*init_fn) (void);
typedef void (*void_fn) (void);

int
main (int argc, char *argv[])
{
  void *library;
  init_flat_fn init_flat;
  init_fn init;
  void_fn run_callbacks, shutdown;
  char message[1024] = "";
  struct pollfd input = { .fd = 0, .events = POLLIN };

  if (argc != 2)
    {
      fprintf (stderr, "usage: %s LIBSTEAM_API.SO\n", argv[0]);
      return 2;
    }
  if (!(library = dlopen (argv[1], RTLD_NOW)))
    {
      fprintf (stderr, "%s\n", dlerror ());
      return 4;
    }
  init_flat = (init_flat_fn) dlsym (library, "SteamAPI_InitFlat");
  init = (init_fn) dlsym (library, "SteamAPI_Init");
  run_callbacks = (void_fn) dlsym (library, "SteamAPI_RunCallbacks");
  shutdown = (void_fn) dlsym (library, "SteamAPI_Shutdown");
  if (!run_callbacks || !shutdown || (!init_flat && !init))
    {
      fprintf (stderr, "no Steamworks entry points in %s\n", argv[1]);
      return 5;
    }
  if (init_flat)
    {
      int result = init_flat (message);
      if (result != 0)
        {
          fprintf (stderr, "Steam refused (result %d): %s\n", result, message);
          return 6;
        }
    }
  else if (!init ())
    {
      fprintf (stderr, "Steam refused\n");
      return 6;
    }

  /* Valve asks every process that initialises the API to pump callbacks;
     once a second, until the other end lets go of standard input.  */
  for (;;)
    {
      char buffer[64];

      run_callbacks ();
      if (poll (&input, 1, 1000) > 0
          && (input.revents & (POLLHUP | POLLERR)
              || read (0, buffer, sizeof buffer) <= 0))
        break;
    }
  shutdown ();
  return 0;
}
