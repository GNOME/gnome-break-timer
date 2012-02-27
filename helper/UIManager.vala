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
	private BreakFocusManager focus_manager;
	
	public bool quiet_mode {get; set; default=false;}
	public int64 quiet_mode_expire_time {get; set;}
	
	private BreakOverlay break_overlay;
	private Notify.Notification? notification;
	
	public UIManager(Application application, BreakManager break_manager) {
		this.application = application;
		this.break_manager = break_manager;
		this.focus_manager = new BreakFocusManager();
		
		this.break_overlay = new BreakOverlay();
		
		this.break_manager.break_loaded.connect(this.break_loaded_cb);
		foreach (BreakType break_type in this.break_manager.all_breaks()) {
			this.break_loaded_cb(break_type);
		}
		
		this.focus_manager.focus_started.connect(this.break_focused_cb);
		this.focus_manager.focus_stopped.connect(this.break_unfocused_cb);
		
		Settings settings = new Settings("org.brainbreak.breaks");
		settings.bind("quiet-mode", this, "quiet-mode", SettingsBindFlags.DEFAULT);
		settings.bind("quiet-mode-expire-time", this, "quiet-mode-expire-time", SettingsBindFlags.DEFAULT);
		
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
	
	private void break_loaded_cb(BreakType break_type) {
		this.focus_manager.monitor_break_type(break_type);
		
		break_type.model.enabled.connect(() => {
			this.application.hold();
		});
		
		break_type.model.disabled.connect(() => {
			this.application.release();
		});
		
		break_type.model.activated.connect(() => {
			this.break_activated(break_type);
		});
		
		break_type.model.finished.connect(() => {
			this.break_finished(break_type);
		});
	}
	
	private void break_focused_cb(BreakType break_type) {
		stdout.printf("%s, break_focused_cb\n", break_type.id);
		this.show_break(break_type);
	}
	
	private void break_unfocused_cb(BreakType break_type) {
		stdout.printf("%s, break_unfocused_cb\n", break_type.id);
		this.hide_break(break_type);
	}
	
	private void break_activated(BreakType break_type) {
		stdout.printf("%s, break_activated_cb\n", break_type.id);
		this.show_break(break_type);
	}
	
	private void break_finished(BreakType break_type) {
		stdout.printf("%s, break_finished_cb\n", break_type.id);
		if (this.focus_manager.is_focusing(break_type) && ! this.break_overlay.is_showing()) {
			BreakView.NotificationContent notification_content = break_type.view.get_finish_notification();
			this.show_notification(notification_content, Notify.Urgency.LOW);
		}
		this.hide_break(break_type);
	}
	
	private bool break_is_showable(BreakType break_type) {
		bool focused = this.focus_manager.is_focusing(break_type);
		stdout.printf("focused: %s\n", focused.to_string());
		bool active = break_type.model.is_active();
		stdout.printf("active: %s\n", active.to_string());
		return focused && active;
	}
	
	private void show_break(BreakType break_type) {
		if (! this.break_is_showable(break_type)) return;
		
		if (this.break_overlay.is_showing()) {
			this.break_overlay.show_with_source(break_type.view);
			stdout.printf("show_break: replaced\n");
		} else {
			BreakView.NotificationContent notification_content = break_type.view.get_start_notification();
			this.show_notification(notification_content, Notify.Urgency.NORMAL);
			
			Timeout.add_seconds(break_type.view.get_lead_in_seconds(), () => {
				if (this.break_is_showable(break_type)) {
					this.break_overlay.show_with_source(break_type.view);
				}
				return false;
			});
			stdout.printf("show_break: notified\n");
		}
	}
	
	private void hide_break(BreakType break_type) {
		this.break_overlay.remove_source(break_type.view);
		stdout.printf("hide_break\n");
	}
}

