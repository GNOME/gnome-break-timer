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
 * Smooths interaction between multiple breaks by managing focus, where only a
 * single break can ask for focus at a single time; all others continue in idle
 * mode. The break manager can postpone breaks or cancel breaks as appropriate,
 * depending on others waiting in line.
 */
public interface FocusManager<T> : Object {
	public signal void focus_started(T focusable);
	public signal void focus_stopped(T focusable);
	
	public abstract void request_focus(T owner, FocusPriority priority);
	
	public abstract void release_focus(T owner);
	
	public abstract T get_focus();
	
	public bool is_focusing(T focusable) {
		return this.get_focus() == focusable;
	}
}

