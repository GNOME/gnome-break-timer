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

namespace BreakTimer.Helper {

static HelperApplication application;

public int main (string[] args) {
	application = new HelperApplication ();
	/*
	Posix.signal (Posix.SIGINT, sigint_cb);
	Posix.signal (Posix.SIGTERM, sigint_cb);
	Posix.signal (Posix.SIGHUP, sigint_cb);
	*/
	int status = application.run (args);
	return status;
}

void sigint_cb (int signal_number) {
	application.quit ();
}

}
