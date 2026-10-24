/* xwayland-activity-relay -- tell X11 programs under Xwayland that the user
   is active while they work in Wayland windows.

   Xwayland only gets input aimed at X11 windows, so X11 programs that judge
   activity by input -- Steam watches XInput 2 raw events -- consider you away
   while you use Wayland programs.  Every few seconds this asks the session's
   idle time (cosmic-idle answers org.freedesktop.ScreenSaver.GetSessionIdleTime),
   and when there was input, resets the X11 screen saver, which
   xwayland-with-idle-time counts as activity and answers with a raw motion
   event of zero; and while no X11 window has the focus -- the real pointer is
   elsewhere then, so nothing visible moves -- it also moves the X pointer by
   one pixel, for programs that poll it.

   Usage: xwayland-activity-relay [SECONDS]   (default 20)  */

#include <dbus/dbus.h>
#include <X11/Xlib.h>
#include <X11/Xatom.h>
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

/* Whether an X11 window has the keyboard focus (the window manager --
   smithay, for cosmic-comp -- keeps _NET_ACTIVE_WINDOW at None while a
   Wayland window has it).  */
static int
x11_window_focused (Display *display, Window root)
{
  Atom type;
  int format;
  unsigned long count, after;
  unsigned char *data = NULL;
  int focused = 0;

  if (XGetWindowProperty (display, root,
                          XInternAtom (display, "_NET_ACTIVE_WINDOW", False),
                          0, 1, False, XA_WINDOW, &type, &format, &count,
                          &after, &data) == Success
      && data)
    {
      focused = type == XA_WINDOW && format == 32 && count == 1
                && *(unsigned long *) data != None;
      XFree (data);
    }
  return focused;
}

static void
relay_activity (Display *display)
{
  Window root = DefaultRootWindow (display), root_return, child;
  int x, y, win_x, win_y;
  unsigned int mask;

  XResetScreenSaver (display);
  /* With an X11 window focused, Xwayland gets the input itself; don't
     disturb a game that may have hidden and locked the pointer.  Otherwise
     the X pointer is left where it last was over an X11 window: move it.
     Xwayland handles that warp on the X side only, since the real pointer
     is over a Wayland window.  */
  if (!x11_window_focused (display, root)
      && XQueryPointer (display, root, &root_return, &child, &x, &y,
                        &win_x, &win_y, &mask))
    /* Between two neighbouring pixels, so it never drifts.  */
    XWarpPointer (display, None, root, 0, 0, 0, 0, x ^ 1, y);
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
