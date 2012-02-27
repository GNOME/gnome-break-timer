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

public enum FocusPriority {
	NONE,
	LOW,
	HIGH
}

/**
 * Keeps track of focus between any type of object (T), ensuring that one will
 * always have focus. Objects must request focus, and the most recent request
 * with the highest priority at any time will be given focus. Focus can change
 * at any time as other objects request or release focus.
 * Focus is not communicated directly to focusable objects, but through the
 * focus_started and focus_stopped signals.
 */
public interface FocusManager<T> : Object {
	public signal void focus_started(T focusable);
	public signal void focus_stopped(T focusable);
	
	/**
	 * Creates a focus request with the given priority. The focusable will
	 * be focused as soon as it has the highest priority of existing
	 * requests.
	 * @param focusable the object that needs focus
	 * @param priority the priority of the request
	 */
	public abstract void request_focus(T focusable, FocusPriority priority);
	
	/**
	 * Releases an exisisting focus request. The focusable will be
	 * unfocused if it is already focused.
	 * @param focusable the object that has focus
	 */
	public abstract void release_focus(T focusable);
	
	/**
	 * @return true if the given focusable is in focus
	 */
	public abstract bool is_focusing(T focusable);
}

