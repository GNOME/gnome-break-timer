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
	
	cookie = xcb_screensaver_query_info (connection,screen->root);
	info = xcb_screensaver_query_info_reply (connection, cookie, NULL);
	
	uint32_t idle = info->ms_since_user_input; // get idle time
	free (info);
	
	return idle;
}

