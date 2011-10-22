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

class TimerString : Object {
	private const string second_remaining_template = "%d second";
	private const string seconds_remaining_template = "%d seconds";
	private const string minute_remaining_template = "%d minute";
	private const string minutes_remaining_template = "%d minutes";
	
	public static string get_countdown_for_seconds (int seconds) {
		/* FIXME: handle plurals, nicely */
		int remaining;
		int interval;
		
		if (seconds <= 10) {
			interval = 1;
		} else if (seconds <= 30) {
			interval = 5;
		} else if (seconds <= 60) {
			interval = 10;
		} else {
			interval = 60;
		}
		
		remaining = (int)((seconds + interval - 1) / interval);
		
		if (interval == 60) {
			return minutes_remaining_template.printf(remaining);
		} else {
			return seconds_remaining_template.printf(remaining * interval);
		}
	}
}

