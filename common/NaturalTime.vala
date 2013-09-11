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

public class NaturalTime : Object {
	public delegate string FormatTimeCb (int seconds);

	private struct TimeUnit {
		public int seconds;
		public FormatTimeCb format_time;
		
		public TimeUnit (int seconds, FormatTimeCb format_time) {
			this.seconds = seconds;
			this.format_time = format_time;
		}
		
		public string format_seconds (int seconds) {
			int time = seconds / this.seconds;
			return this.format_time(time);
		}
	}
	
	private TimeUnit[] units { get; private set; }
	
	private NaturalTime () {
		this.units = {
			TimeUnit (1, (time) => {
				return ngettext ("%d second", "%d seconds", time).printf(time);
			}),
			TimeUnit (60, (time) => {
				return ngettext ("%d minute", "%d minutes", time).printf(time);
			}),
			TimeUnit (3600, (time) => {
				return ngettext ("%d hour", "%d hours", time).printf(time);
			})
		};
	}

	private static NaturalTime _instance;
	public static NaturalTime instance {
		get {
			if (_instance == null) {
				_instance = new NaturalTime ();
			}
			return _instance;
		}
	}
	
	/**
	 * Get a natural label for the given time in seconds. Converts seconds
	 * to a unit that will represent the time as accurately as possible,
	 * favouring precision over unit selection.
	 * So, an input of 60 will return "1 minute", but 61 will return
	 * "61 seconds".
	 * @param seconds time in seconds.
	 * @return a string with a natural and accurate representation of the time.
	 */
	public string get_label_for_seconds (int seconds) {
		TimeUnit label_unit = units[0];
		foreach (TimeUnit unit in units) {
			if (seconds % unit.seconds == 0) {
				label_unit = unit;
				// assumes smallest unit is first in the list
				if (seconds == 0) break;
			}
		}
		return label_unit.format_seconds (seconds);
	}
	
	/**
	 * Get a natural label for the given time in seconds. Converts seconds
	 * to a unit that will represent the time as cleanly as possible,
	 * favouring the simplest possible unit over precision.
	 * So, an input of 60 will return "1 minute", and 61 will return the
	 * same.
	 * @param seconds time in seconds.
	 * @return a string with a natural and accurate representation of the time.
	 */
	public string get_simplest_label_for_seconds (int seconds) {
		TimeUnit label_unit = units[0];
		foreach (TimeUnit unit in units) {
			if (seconds >= unit.seconds) {
				label_unit = unit;
			}
		}
		return label_unit.format_seconds (seconds);
	}
	
	private int soften_seconds_for_countdown (int seconds) {
		int interval = 1;
		if (seconds <= 10) {
			interval = 1;
		} else if (seconds <= 60) {
			interval = 10;
		} else {
			interval = 60;
		}
		int time_softened = ( (seconds-1) / interval) + 1;
		return time_softened * interval;
	}
	
	/**
	 * Get a natural label for the given time in seconds, in an imprecise
	 * format intented for a countdown. Precision is unimportant, so this
	 * function softens the time by a gradually smaller interval as seconds
	 * reaches 0.
	 * @param seconds number of seconds remaining in the countdown.
	 * @return a string representing the time remaining.
	 */
	public string get_countdown_for_seconds (int seconds) {
		int seconds_softened = soften_seconds_for_countdown (seconds);
		return get_simplest_label_for_seconds (seconds_softened);
	}
	
	/**
	 * Get a natural label for the given time in seconds, in an imprecise
	 * format intented for a countdown. Precision is unimportant, so this
	 * function softens the time by a gradually smaller interval as seconds
	 * reaches 0.
	 * When the remaining time is near the given start time, the start time
	 * is shown instead, without being softened.
	 * @param seconds number of seconds remaining in the countdown.
	 * @param start countdown start time, in seconds, which will be shown exactly.
	 * @return a string representing the time remaining.
	 */
	public string get_countdown_for_seconds_with_start (int seconds, int start) {
		int seconds_softened = soften_seconds_for_countdown (seconds);
		if (seconds_softened > start) seconds_softened = start;
		return get_simplest_label_for_seconds (seconds_softened);
	}
}