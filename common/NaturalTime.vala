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
	
	private static TimeUnit[] units {get; private set;}
	
	public static void initialize () {
		NaturalTime.units = {
			TimeUnit(_("%d second"), _("%d seconds"), 1),
			TimeUnit(_("%d minute"), _("%d minutes"), 60),
			TimeUnit(_("%d hour"), _("%d hours"), 3600)
		};
	}
	
	public static string[] get_completions_for_input (string input) {
		int time = get_time_for_input(input);
		if (time < 1) time = 1;
		
		return get_completions_for_time(time);
	}
	
	public static string[] get_completions_for_time (int time) {
		string[] completions = new string[units.length];
		
		for (int i = 0; i < units.length; i++) {
			TimeUnit unit = units[i];
			completions[i] = ngettext(unit.label_single.printf(time),
					unit.label_plural.printf(time),
					time);
		}
		
		return completions;
	}
	
	public static string get_label_for_seconds (int seconds) {
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
	
	public static string get_countdown_for_seconds (int seconds) {
		int interval = 1;
		if (seconds <= 10) {
			interval = 1;
		} else if (seconds <= 60) {
			interval = 10;
		} else if (seconds <= 900) {
			interval = 60;
		} else {
			interval = 300;
		}
		
		int seconds_snapped_to_interval = (int)((seconds-1) / interval + 1) * interval;
		
		return get_label_for_seconds(seconds_snapped_to_interval);
	}
	
	private static bool get_unit_for_input (string input, out TimeUnit? out_unit, out int out_time) {
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
	
	public static int get_time_for_input (string input) {
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
	
	public static int get_seconds_for_input (string input) {
		TimeUnit? unit;
		int time;
		if (get_unit_for_input(input, out unit, out time)) {
			return time * unit.seconds;
		} else {
			return -1;
		}
	}
}

