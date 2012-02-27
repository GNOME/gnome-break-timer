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

#include <stdlib.h>
#include <xcb/xcb.h>
#include <xcb/screensaver.h>

static xcb_connection_t * connection;
static xcb_screen_t * screen;

/**
 * Connects to the X server (via xcb) and gets the screen
 */
void magic_begin () {
	connection = xcb_connect (NULL, NULL);
	screen = xcb_setup_roots_iterator (xcb_get_setup (connection)).data;
}

/**
 * Asks X for the time the user has been idle
 * @returns idle time in milliseconds
 */
unsigned long magic_get_idle_time () {
	xcb_screensaver_query_info_cookie_t cookie;
	xcb_screensaver_query_info_reply_t *info;
	
	cookie = xcb_screensaver_query_info (connection, screen->root);
	info = xcb_screensaver_query_info_reply (connection, cookie, NULL);
	
	uint32_t idle = info->ms_since_user_input;
	free (info);
	
	return idle;
}

