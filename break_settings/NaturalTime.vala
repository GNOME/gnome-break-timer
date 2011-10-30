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
	private struct TimeInterval {
		public string label_single;
		public string label_plural;
		public int seconds;
		
		public TimeInterval(string label_single, string label_plural, int seconds) {
			this.label_single = label_single;
			this.label_plural = label_plural;
			this.seconds = seconds;
		}
	}
	
	//private static TimeInterval[] intervals;
	
	public static string get_label_for_seconds (int seconds) {
		TimeInterval[] intervals = {
		TimeInterval(_("%d second"), _("%d seconds"), 1),
		TimeInterval(_("%d minute"), _("%d minutes"), 60),
		TimeInterval(_("%d hour"), _("%d hours"), 3600)
	};
		
		TimeInterval label_interval = intervals[0];
		
		foreach (TimeInterval interval in intervals) {
			if (seconds % interval.seconds == 0) {
				label_interval = interval;
			}
		}
		
		int time = seconds / label_interval.seconds;
		
		return ngettext(label_interval.label_single.printf(time),
				label_interval.label_plural.printf(time),
				time);
	}
}

