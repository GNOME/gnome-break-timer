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

/**
 * A collection of handy little functions of functionality that can't really
 * be categorized, but end up being used throughout this application.
 */
public class Util {
	private const int MICROSECONDS_IN_SECONDS = 1000 * 1000;

	public static int64 get_real_time_seconds() {
		return (GLib.get_real_time() / MICROSECONDS_IN_SECONDS);
	}

	public static int64 get_monotonic_time_seconds() {
		return (GLib.get_monotonic_time() / MICROSECONDS_IN_SECONDS);
	}
}