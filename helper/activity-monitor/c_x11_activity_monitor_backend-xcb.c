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

#include <stdlib.h>
#include <xcb/xcb.h>
#include <xcb/record.h>

static xcb_record_context_t record_context;

void start_xrecord () {
	static xcb_connection_t * connection = xcb_connect (NULL, NULL);
	
	xcb_record_element_header_t record_element_header;
	
	xcb_record_client_spec_t * client_specs = XCB_RECORD_CS_ALL_CLIENTS;
	
	xcb_record_range_t * record_range = 
	
	xcb_void_cookie_t cookie = xcb_record_create_context (
		connection,
		&record_context,
		&record_element_header,
		1,
		1,
		&client_specs,
		
		
}

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

