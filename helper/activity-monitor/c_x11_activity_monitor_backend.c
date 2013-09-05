/*
 * This file is part of GNOME Break Timer.
 * 
 * GNOME Break Timer is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * GNOME Break Timer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with GNOME Break Timer.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * Much of the code in this file is adapted from Workrave's X11InputMonitor.
 * 
 * The original code is
 * Copyright (C) 2001 - 2010 Rob Caelers <robc@krandor.nl>, and
 * Copyright (C) 2007 Ray Satiro <raysatiro@yahoo.com>.
 * 
 * Provided under the terms of the GNU General Public License, version 3 or
 * later.
 * 
 * Please see <http://www.workrave.org/> for details.
 * 
 * We love you, Workrave!
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <X11/X.h>
#include <X11/Xlib.h>
#include <X11/extensions/record.h>
#include <X11/extensions/XInput.h>
#include <X11/extensions/XIproto.h>

#define bool int
#define true 1
#define false 0

typedef struct {
	Display * x11_display;
	Display * xrecord_datalink;
	XRecordContext xrecord_context;
	unsigned long last_event_time;
} XRecordMonitor_priv;

void error_handler (Display * display, XErrorEvent * event);
bool init_xrecord (XRecordMonitor_priv * priv);
void run_xrecord (XRecordMonitor_priv * priv);
void stop_xrecord (XRecordMonitor_priv * priv);
void handle_xrecord_callback (XPointer closure, XRecordInterceptData * data);

void * c_x11_activity_monitor_backend_create_context () {
	XRecordMonitor_priv * priv = malloc (sizeof (XRecordMonitor_priv));
	priv->x11_display = NULL;
	priv->xrecord_datalink = NULL;
	priv->xrecord_context = 0;
	priv->last_event_time = 0;
	
	return priv;
}

void c_x11_activity_monitor_backend_start (XRecordMonitor_priv * priv) {
	//XSetErrorHandler (&error_handler);
	
	//XRecordMonitor_priv * priv = malloc (sizeof (XRecordMonitor_priv));
	
	if (priv->x11_display == NULL) {
		priv->x11_display = XOpenDisplay (NULL);
		run_xrecord (priv);
	}
}

void c_x11_activity_monitor_backend_stop (XRecordMonitor_priv * priv) {
	stop_xrecord (priv);
	
	if (priv->x11_display != NULL) {
		XCloseDisplay (priv->x11_display);
		priv->x11_display = NULL;
	}
}

unsigned long c_x11_activity_monitor_backend_get_last_event_time (XRecordMonitor_priv * priv) {
	return priv->last_event_time;
}


void error_handler (Display * display, XErrorEvent * event) {
	char text[128];
	XGetErrorText (display, event->error_code, text, 127);
	fprintf (stderr, "X11 activity monitor backend: X Error %d, %s\n", event->error_code, text);
}

static int xi_event_base = 0;
bool init_xrecord (XRecordMonitor_priv * priv) {
	int success = true;
	
	priv->xrecord_context = 0;
	priv->xrecord_datalink = NULL;
	
	int major, minor;
	if (XRecordQueryVersion (priv->x11_display, &major, &minor)) {
		// Receive from ALL clients, including future clients.
		XRecordClientSpec client = XRecordAllClients;
		
		// Receive KeyPress, KeyRelease, ButtonPress, ButtonRelease and
		// MotionNotify events.
		XRecordRange * record_range = XRecordAllocRange ();
		if (record_range != NULL) {
			memset (record_range, 0, sizeof (XRecordRange));
			
			int dummy = 0;
			bool have_xi = XQueryExtension (priv->x11_display, "XInputExtension", &dummy, &xi_event_base, &dummy);
			
			if (have_xi && xi_event_base != 0) {
				record_range->device_events.first = xi_event_base + XI_DeviceKeyPress;
				record_range->device_events.last = xi_event_base + XI_DeviceMotionNotify;
			} else {
				record_range->device_events.first = KeyPress;
				record_range->device_events.last = MotionNotify;
			}
		}
		
		// And create the XRECORD context.
		priv->xrecord_context = XRecordCreateContext (priv->x11_display, false, &client,  1, &record_range, 1);
		
		XFree (record_range);
	}
	
	if (priv->xrecord_context != 0) {
		XSync (priv->x11_display, true);
		priv->xrecord_datalink = XOpenDisplay (NULL);
	}
	
	if (priv->xrecord_datalink == NULL) {
		XRecordFreeContext (priv->x11_display, priv->xrecord_context);
		priv->xrecord_context = 0;
		success = false;
	}
	
	return success;
}

void run_xrecord (XRecordMonitor_priv * priv) {
	bool xrecord_alive = init_xrecord (priv);
	
	if (xrecord_alive) {
		XRecordState * state = malloc (sizeof (XRecordState));
		XRecordGetContext (priv->xrecord_datalink, priv->xrecord_context, &state);
		
		int enabled = XRecordEnableContext (priv->xrecord_datalink, priv->xrecord_context, &handle_xrecord_callback, (XPointer)priv);
	}
}

void stop_xrecord (XRecordMonitor_priv * priv) {
	if (priv->xrecord_context != 0) {
		XRecordDisableContext (priv->xrecord_datalink, priv->xrecord_context);
		XRecordFreeContext (priv->x11_display, priv->xrecord_context);
		XFlush (priv->xrecord_datalink);
		
		priv->xrecord_context = 0;
		priv->xrecord_datalink = NULL;
	}
}



void handle_xrecord_core_event (XRecordInterceptData * data, XRecordMonitor_priv * priv) {
	/*XEvent *event = (XEvent *)data->data;*/
	if (data->server_time > priv->last_event_time) {
		priv->last_event_time = data->server_time;
	}
}

void handle_xrecord_xi_event (XRecordInterceptData * data, XRecordMonitor_priv * priv) {
	/*deviceKeyButtonPointer *event = (deviceKeyButtonPointer *)data->data;*/
	if (data->server_time > priv->last_event_time) {
		priv->last_event_time = data->server_time;
	}
}

void handle_xrecord_callback (XPointer closure, XRecordInterceptData * data) {
	xEvent *  event;
	XRecordMonitor_priv * priv = (XRecordMonitor_priv *)closure;
	
	switch (data->category) {
		case XRecordStartOfData:
		case XRecordFromClient:
		case XRecordClientStarted:
		case XRecordClientDied:
		case XRecordEndOfData:
			break;
		
		case XRecordFromServer:
			event = (xEvent *)data->data;
			
			if (KeyPress <= event->u.u.type && event->u.u.type <= MotionNotify) {
				handle_xrecord_core_event (data, priv);
			} else if (xi_event_base != 0) {
				handle_xrecord_xi_event (data, priv);
			}
			
			break;
	}
	
	if (data != NULL) {
		XRecordFreeData (data);
	}
}

