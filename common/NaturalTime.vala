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

class NaturalTime : Object {
	private struct TimeUnit {
		public string label_single;
		public string label_plural;
		public int seconds;
		
		public Regex re_single;
		public Regex re_plural;
		
		public TimeUnit(string label_single, string label_plural, int seconds) {
			this.label_single = label_single;
			this.label_plural = label_plural;
			this.seconds = seconds;
			
			this.re_single = new Regex(label_single.replace("%d", "(\\d+)"));
			this.re_plural = new Regex(label_plural.replace("%d", "(\\d+)"));
		}
		
		public string format_seconds(int seconds) {
			int time = seconds / this.seconds;
			
			return ngettext(this.label_single.printf(time),
					this.label_plural.printf(time),
					time);
		}
	}
	
	private TimeUnit[] units {get; private set;}
	
	private NaturalTime () {
		this.units = {
			TimeUnit(_("%d second"), _("%d seconds"), 1),
			TimeUnit(_("%d minute"), _("%d minutes"), 60),
			TimeUnit(_("%d hour"), _("%d hours"), 3600)
		};
	}
	
	private static NaturalTime? instance;
	public static NaturalTime get_instance() {
		if (instance == null) {
			instance = new NaturalTime();
		}
		return instance;
	}
	
	/**
	 * Get a list of possible matches for a natural time input such as
	 * "5 seconds." An input of "50" will return an array with 50 of every
	 * known time interval: "50 seconds", "50 minutes" and "50 hours."
	 * @param input a string representing an amount of time.
	 * @return a list of strings representing the same time in different units.
	 */
	public string[] get_completions_for_input (string input) {
		int time = get_time_for_input(input);
		if (time < 1) time = 1;
		
		return get_completions_for_time(time);
	}
	
	/**
	 * Get a list of natural representations of the given amount of time,
	 * one for each known unit. Note that this does not do unit conversion
	 * for time, so that number is treated exactly as given. For example,
	 * an input of 50 will return a string representation of 50 seconds, 50
	 * hours and 50 minutes
	 * @param input an amount of time.
	 * @return a list of strings representing the same time in different units.
	 */
	public string[] get_completions_for_time (int time) {
		string[] completions = new string[units.length];
		
		for (int i = 0; i < units.length; i++) {
			TimeUnit unit = units[i];
			completions[i] = ngettext(unit.label_single.printf(time),
					unit.label_plural.printf(time),
					time);
		}
		
		return completions;
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
		return label_unit.format_seconds(seconds);
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
		return label_unit.format_seconds(seconds);
	}
	
	private int soften_seconds_for_countdown(int seconds) {
		int interval = 1;
		if (seconds <= 10) {
			interval = 1;
		} else if (seconds <= 60) {
			interval = 10;
		} else {
			interval = 60;
		}
		int time_softened = ((seconds-1) / interval) + 1;
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
		int seconds_softened = soften_seconds_for_countdown(seconds);
		return get_simplest_label_for_seconds(seconds_softened);
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
		int seconds_softened = soften_seconds_for_countdown(seconds);
		if (seconds_softened > start) seconds_softened = start;
		return get_simplest_label_for_seconds(seconds_softened);
	}
	
	private bool get_unit_for_input (string input, out TimeUnit? out_unit, out int out_time) {
		out_unit = null;
		out_time = -1;
		
		foreach (TimeUnit unit in units) {
			MatchInfo match_info;
			if (unit.re_single.match(input, RegexMatchFlags.ANCHORED, out match_info) ||
					unit.re_plural.match(input, RegexMatchFlags.ANCHORED, out match_info)) {
				string time_str = match_info.fetch(1);
				out_time = int.parse(time_str);
				out_unit = unit;
				return true;
			}
		}
		
		return false;
	}
	
	private int get_time_for_input (string input) {
		// this assumes \\d+ will _only_ match the time
		Regex re = new Regex("(\\d+)");
		
		MatchInfo match_info;
		if (re.match(input, 0, out match_info)) {
			string time_str = match_info.fetch(1);
			int time = int.parse(time_str);
			return time;
		} else {
			return -1;
		}
	}
	
	/**
	 * Convert an input string representing a time to its corresponding
	 * number of seconds. The input should be in a format understood by
	 * NaturalTime, such as a string provided by get_completions_for_time.
	 * @param input a string representing some amount of time.
	 * @return int the time, in seconds, corresponding to the input.
	 */
	public int get_seconds_for_input (string input) {
		TimeUnit? unit;
		int time;
		if (get_unit_for_input(input, out unit, out time)) {
			return time * unit.seconds;
		} else {
			return -1;
		}
	}
}

