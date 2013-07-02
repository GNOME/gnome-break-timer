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
 * A simple GTimer lookalike that keeps track of its own state.
 * This is implemented using the GTimer API, internally, so it behaves
 * exactly as described in the GTimer documentation - just with an extra
 * "state" field for convenience.
 */
public class StatefulTimer : Object {
	public enum State {
		STOPPED,
		COUNTING
	}
	public State state {public get; private set;}

	private Timer timer;

	public StatefulTimer() {
		this.timer = new Timer();
		this.state = State.COUNTING;
	}

	public inline bool is_stopped() {
		return ! this.is_counting();
	}

	public bool is_counting() {
		return this.state == State.COUNTING;
	}

	public void start() {
		this.timer.start();
		this.state = State.COUNTING;
	}

	public void stop() {
		this.timer.stop();
		this.state = State.STOPPED;
	}

	public void continue() {
		this.timer.continue();
		this.state = State.COUNTING;
	}

	public double elapsed() {
		return this.timer.elapsed();
	}

	public void reset() {
		this.start();
	}
}