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

public class MicroBreakPanel : TimerBreakPanel {
	public MicroBreakPanel(Settings breaks_settings) {
		Settings settings = breaks_settings.get_child("microbreak");
		
		base(settings, "microbreak", _("Micro break"),
			{480, 600, 720, 900},
			{15, 20, 30, 45, 60});
	}
}

