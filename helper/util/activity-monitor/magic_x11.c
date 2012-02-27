/*
 * This file is part of Brain Break.
 * 
 * Brain Break is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Brain Break is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with Brain Break.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <stdio.h>
#include <X11/Xlib.h>
 
#include <X11/Xutil.h>
#include <X11/extensions/scrnsaver.h>

#include <gtk-3.0/gdk/gdk.h>
#include <gtk-3.0/gdk/gdkx.h>

void magic_begin () {
}

unsigned long magic_get_idle_time () {
	Display * display = gdk_x11_get_default_xdisplay();
	Window rootwin = gdk_x11_get_default_root_xwindow();
	
	
	static XScreenSaverInfo *mit_info = NULL;
	int event_base, error_base;
	if (XScreenSaverQueryExtension(display, &event_base, &error_base)) {
		mit_info = XScreenSaverAllocInfo();
		XScreenSaverQueryInfo(display, rootwin, mit_info);
		return (long)mit_info->idle;
	} else {
		return 0;
	}
}

