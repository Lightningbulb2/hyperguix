/* xwayland-activity-relay -- tell X11 programs under Xwayland that the user
   is active while they work in Wayland windows.

   Xwayland only gets input aimed at X11 windows, so X11 programs that read
   the X11 idle time (MIT-SCREEN-SAVER) consider you idle while you use
   Wayland programs.  Every few seconds this asks the session's idle time
   (cosmic-idle answers org.freedesktop.ScreenSaver.GetSessionIdleTime), and
   when there was input, resets the X11 screen saver, which
   xwayland-with-idle-time counts as activity.  It doesn't touch the pointer:
   warping it over a game that hides the cursor makes Xwayland lock the
   pointer to the game, and clicks stopped reaching Wine programs (BFME).
   Steam's Away status doesn't read the idle time: it polls QueryPointer every
   second and waits for the pointer to move more than 5 pixels.  xwayland-with-idle-time
   therefore also shifts the position it reports to such polls by 8 pixels on each
   reset, which is what keeps Steam Online.

   Usage: xwayland-activity-relay [SECONDS]   (default 20)  */

#include <dbus/dbus.h>
#include <X11/Xlib.h>
#include <stdio.h>
#include <stdlib.h>
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

static void
relay_activity (Display *display)
{
  XResetScreenSaver (display);
  XSync (display, False);
}

int
main (int argc, char *argv[])
{
  unsigned int interval = argc > 1 ? (unsigned int) atoi (argv[1]) : 20;
  DBusConnection *bus = NULL;

  if (interval == 0)
    interval = 20;

  for (;; sleep (interval))
    {
      long idle;

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
      if (idle < 0 || idle >= interval * 1000L)
        continue;

      /* Connect each time: Xwayland may have restarted meanwhile, and a
         lasting connection would keep it from exiting when idle.  */
      Display *display = XOpenDisplay (NULL);
      if (display)
        {
          relay_activity (display);
          XCloseDisplay (display);
        }
    }
}
