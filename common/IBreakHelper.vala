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

public const string HELPER_BUS_NAME = "org.brainbreak.Helper";
public const string HELPER_OBJECT_PATH = "/org/brainbreak/Helper";
public const string HELPER_BREAK_OBJECT_BASE_PATH = "/org/brainbreak/Breaks/";

[DBus (name = "org.brainbreak.Helper")]
public interface IBreakHelper : Object {
	public abstract string[] get_break_ids() throws IOError;
	public abstract string[] get_status_messages() throws IOError;
	public abstract void trigger_break(string break_name) throws IOError;
}

[DBus (name = "org.brainbreak.Breaks.TimerBreak")]
public interface IBreakHelper_TimerBreak : Object {
	public abstract TimerBreakStatus get_status() throws IOError;
	public abstract void activate() throws IOError;
}

public struct TimerBreakStatus {
	bool is_enabled;
	bool is_active;
	int starts_in;
	int time_remaining;
	int current_duration;
}
