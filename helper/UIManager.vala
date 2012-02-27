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
	private Application application;
	private BreakManager break_manager;
	private FocusManager<BreakType> focus_manager;
	
	public bool quiet_mode {get; set; default=false;}
	public int64 quiet_mode_expire_time {get; set;}
	
	private BreakOverlay break_overlay;
	private Break active_break;
	
	private Notify.Notification? notification;
	
	public UIManager(Application application, BreakManager break_manager) {
		this.application = application;
		this.break_manager = break_manager;
		this.focus_manager = break_manager.get_focus_manager();
		
		this.break_overlay = new BreakOverlay();
		
		Settings settings = new Settings("org.brainbreak.breaks");
		settings.bind("quiet-mode", this, "quiet-mode", SettingsBindFlags.DEFAULT);
		settings.bind("quiet-mode-expire-time", this, "quiet-mode-expire-time", SettingsBindFlags.DEFAULT);
		
		foreach (BreakType break_type in this.break_manager.get_all_breaks()) {
			stdout.printf("%s\n", break_type.id);
			/* TODO: Connect signal to show / hide break UI */
		}
		
		/* TODO: Connect signal to attach / detach break from UI */
		this.focus_manager.focus_started.connect(this.focus_started_cb);
		this.focus_manager.focus_stopped.connect(this.focus_stopped_cb);
		
		this.notify["quiet-mode"].connect((s, p) => {
			if (this.quiet_mode) {
				// hide the overlay (if it is currently showing)
				//this.break_overlay.remove_source();
				this.break_overlay.set_format(ScreenOverlay.Format.MINI);
				//this.overlay_triggered_for_break = false;
			} else {
				this.break_overlay.set_format(ScreenOverlay.Format.FULL);
			}
		});
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
	
	private void show_notification(BreakView.NotificationContent content, Notify.Urgency urgency) {
		if (this.notification == null) {
			this.notification = new Notify.Notification("", null, null);
			this.notification.set_hint("transient", true);
		}
		this.notification.set_urgency(urgency);
		this.notification.update(content.summary, content.body, content.icon);
		this.notification.show();
	}
	
	private void focus_started_cb(BreakType break_type) {
		this.show_break(break_type);
	}
	
	private void focus_stopped_cb(BreakType break_type) {
		this.hide_break(break_type);
	}
	
	/*
	private void watch_break(BreakType break_type) {
		break_type.brk.enabled.connect(() => {
			this.application.hold();
		});
		break_type.brk.disabled.connect(() => {
			this.application.release();
		});
		
		break_type.brk.activated.connect(() => {
			this.show_break(break_type);
		});
		break_type.brk.finished.connect(() => {
			this.hide_break(break_type);
		});
		
		break_type.view.focus_started.connect(() => {
			this.show_break(break_type);
		});
		break_type.view.focus_ended.connect(() => {
			this.hide_break(break_type);
		});
	}
	*/
	
	private void show_break(BreakType break_type) {
		BreakView break_view = break_type.view;
		
		if (this.break_overlay.is_showing_source()) {
			// a running break has been replaced
			this.break_overlay.show_with_source(break_view);
		} else {
			BreakView.NotificationContent notification_content = break_view.get_start_notification();
			this.show_notification(notification_content, Notify.Urgency.NORMAL);
			
			Timeout.add_seconds(break_view.get_lead_in_seconds(), () => {
				if (this.focus_manager.is_focused(break_type)) {
					this.break_overlay.show_with_source(break_view);
				}
				return false;
			});
		}
	}
	
	/*private void break_finished(Break brk) {
		if (this.active_break == brk && this.overlay_triggered_for_break == false) {
			BreakView break_view = brk.get_view();
			
			BreakView.NotificationContent notification_content = break_view.get_finish_notification();
			this.show_notification(notification_content, Notify.Urgency.LOW);
		}
	}*/
	
	private void hide_break(BreakType break_type) {
		this.break_overlay.remove_source(break_type.view);
	}
}

