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
 * Handles UI concerns throughout the application, including overlays and
 * notifications for breaks.
 */
public class UIManager : Object {
	public bool quiet_mode {get; set; default=false;}
	public int64 quiet_mode_expire_time {get; set;}
	
	private SList<Break> breaks;
	private Break? active_break;
	private BreakOverlay break_overlay;
	private bool overlay_triggered_for_break;
	
	public UIManager() {
		Settings settings = new Settings("org.brainbreak.breaks");
		settings.bind("quiet-mode", this, "quiet-mode", SettingsBindFlags.DEFAULT);
		settings.bind("quiet-mode-expire-time", this, "quiet-mode-expire-time", SettingsBindFlags.DEFAULT);
		
		this.breaks = new SList<Break>();
		this.active_break = null;
		this.break_overlay = new BreakOverlay();
		
		this.notify["quiet-mode"].connect((s, p) => {
			if (this.quiet_mode) {
				// hide the overlay (if it is currently showing)
				this.break_overlay.remove_source();
				this.overlay_triggered_for_break = false;
			}
		});
	}
	
	public void add_break(Break new_break) {
		this.breaks.append(new_break);
		
		new_break.activated.connect(() => {
			this.break_activated(new_break);
		});
		
		new_break.finished.connect(() => {
			this.break_stopped(new_break);
		});
	}
	
	public void remove_break(Break brk) {
		this.breaks.remove(brk);
	}
	
	private bool quiet_mode_is_enabled() {
		if (this.quiet_mode) {
			DateTime now = new DateTime.now_utc();
			if (now.to_unix() < this.quiet_mode_expire_time) {
				return true;
			} else {
				this.quiet_mode = false;
				this.quiet_mode_expire_time = 0;
			}
		}
		return false;
	}
	
	private void break_activated(Break brk) {
		if (!brk.is_focused()) {
			// we don't care about breaks that aren't focused
			stdout.printf("An unfocused break made it to UIManager\n");
			return;
		}
		
		BreakView break_view = brk.get_view();
		
		if (this.active_break != null && this.overlay_triggered_for_break) {
			// a running break has been replaced
			this.active_break = brk;
			this.break_overlay.show_with_source(break_view);
		} else {
			this.active_break = brk;
			
			Notify.Notification notification = break_view.get_start_notification();
			notification.set_urgency(Notify.Urgency.NORMAL);
			notification.set_hint("transient", true);
			notification.show();
			
			this.overlay_triggered_for_break = false;
			Timeout.add_seconds(break_view.warn_time, () => {
				if (brk.is_active() && !this.quiet_mode_is_enabled()) {
					this.break_overlay.show_with_source(break_view);
					this.overlay_triggered_for_break = true;
				}
				return false;
			});
		}
	}
	
	private void break_stopped(Break brk) {
		if (this.active_break == brk) {
			BreakView break_view = brk.get_view();
			
			this.break_overlay.remove_source();
			
			if (this.overlay_triggered_for_break == false) {
				Notify.Notification notification = break_view.get_finish_notification();
				notification.set_urgency(Notify.Urgency.LOW);
				notification.set_hint("transient", true);
				notification.show();
			}
			
			this.active_break = null;
		}
	}
}

