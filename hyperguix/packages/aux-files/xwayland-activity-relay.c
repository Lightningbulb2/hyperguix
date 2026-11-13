/* xwayland-activity-relay -- tell X11 programs under Xwayland that the user
   is active while they work in Wayland windows.

   Xwayland only gets input aimed at X11 windows, so X11 programs that read
   the X11 idle time (MIT-SCREEN-SAVER) consider you idle while you use
   Wayland programs.  Twice a second this asks the session's idle time
   (cosmic-idle answers org.freedesktop.ScreenSaver.GetSessionIdleTime), and
   when there was input, resets the X11 screen saver, which
   xwayland-with-idle-time counts as activity.  It doesn't touch the pointer:
   warping it over a game that hides the cursor makes Xwayland lock the
   pointer to the game, and clicks stopped reaching Wine programs (BFME).
   Steam's Away status doesn't read the idle time: it polls QueryPointer every
   second and waits for the pointer to move more than 5 pixels.  xwayland-with-idle-time
   therefore also shifts the position it reports to such polls by 8 pixels on each
   reset, which is what keeps Steam Online.

   While the pointer is over an X11 window, X11 programs see that input
   themselves, so no reset is made: each one counts as input in Xwayland
   and flips that shift, and games (Wine) that had the cursor locked lost
   their mouse look and the keyboard focus.

   Usage: xwayland-activity-relay  */

#include <dbus/dbus.h>
#include <X11/Xlib.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

/* Milliseconds since the last input, or -1 when nobody answers.  */
static long
session_idle_time (DBusConnection *bus)
{
  DBusMessage *call, *reply;
  dbus_uint32_t idle;
  long result = -1;

  call = dbus_message_new_method_call ("org.freedesktop.ScreenSaver",
                                       "/org/freedesktop/ScreenSaver",
                                       "org.freedesktop.ScreenSaver",
                                       "GetSessionIdleTime");
  if (!call)
    return -1;
  reply = dbus_connection_send_with_reply_and_block (bus, call, 2000, NULL);
  dbus_message_unref (call);
  if (!reply)
    return -1;
  if (dbus_message_get_args (reply, NULL, DBUS_TYPE_UINT32, &idle,
                             DBUS_TYPE_INVALID))
    result = idle;
  dbus_message_unref (reply);
  return result;
}

/* Whether the X11 pointer is over an X11 window.  Over Wayland windows
   Xwayland keeps it on the root window, with no child under it.  */
static int
pointer_over_x11_window (Display *display)
{
  Window root, child = None;
  int root_x, root_y, win_x, win_y;
  unsigned int mask;

  if (!XQueryPointer (display, DefaultRootWindow (display), &root, &child,
                      &root_x, &root_y, &win_x, &win_y, &mask))
    return 0;
  return child != None;
}

/* Reset the X11 screen saver unless the pointer is over an X11 window.
   Return whether it was reset.  */
static int
relay_activity (Display *display)
{
  if (pointer_over_x11_window (display))
    return 0;
  XResetScreenSaver (display);
  XSync (display, False);
  return 1;
}

/* Milliseconds on a monotonic clock.  */
static long long
now_ms (void)
{
  struct timespec ts;
  clock_gettime (CLOCK_MONOTONIC, &ts);
  return ts.tv_sec * 1000LL + ts.tv_nsec / 1000000;
}

/* Steam checks the pointer about once a second and needs it to have moved
   since its previous check, so each reset (which shifts the position it is
   shown) must last longer than that or two could cancel out unseen.  */
#define MIN_GAP_MS 2500

int
main (int argc, char *argv[])
{
  DBusConnection *bus = NULL;
  /* When the screen saver was last reset; long ago at startup.  */
  long long last_reset = now_ms () - 3600 * 1000LL;

  (void) argc;
  (void) argv;

  for (;; usleep (500 * 1000))
    {
      long idle;
      long long now;

      if (!bus && !(bus = dbus_bus_get (DBUS_BUS_SESSION, NULL)))
        continue;
      dbus_connection_set_exit_on_disconnect (bus, FALSE);
      if (!dbus_connection_get_is_connected (bus))
        {
          dbus_connection_unref (bus);
          bus = NULL;
          continue;
        }

      idle = session_idle_time (bus);
      now = now_ms ();
      /* Relay activity when there was input since the last reset (cosmic-idle
         reports 0 while input is ongoing), at most once per MIN_GAP_MS.  On
         return from being away the last reset is long past, so this reacts
         within half a second.  */
      if (idle < 0 || now - last_reset < MIN_GAP_MS || idle >= now - last_reset)
        continue;

      /* Connect each time: Xwayland may have restarted meanwhile, and a
         lasting connection would keep it from exiting when idle.  */
      Display *display = XOpenDisplay (NULL);
      if (display)
        {
          if (relay_activity (display))
            last_reset = now;
          XCloseDisplay (display);
        }
    }
}
