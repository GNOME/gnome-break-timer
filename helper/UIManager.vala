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
 * Central place to manage UI throughout the application. We need this to
 * maintain a simple, modal structure. This uses a simple focus tracking
 * mechanism to make sure only one break is affecting the UI at a time. This
 * class also helps to keep UI events nicely spaced so they don't turn into
 * noise. Each BreakView implementation talks to a common instance of
 * UIManager.
 */
public class UIManager : BreakFocusManager {
	private Application application;
	
	public bool quiet_mode {get; set; default=false;}
	public int64 quiet_mode_expire_time {get; set;}

	private PausableTimeout quiet_mode_timeout;

	public ScreenOverlay screen_overlay;
	public Notify.Notification? notification;
	
	public UIManager(Application application) {
		base();
		this.application = application;
		this.screen_overlay = new ScreenOverlay();
		
		this.focus_started.connect(this.break_focused_cb);
		this.focus_stopped.connect(this.break_unfocused_cb);
		
		Settings settings = new Settings("org.brainbreak.breaks");
		settings.bind("quiet-mode", this, "quiet-mode", SettingsBindFlags.DEFAULT);
		settings.bind("quiet-mode-expire-time", this, "quiet-mode-expire-time", SettingsBindFlags.DEFAULT);

		this.quiet_mode_timeout = new PausableTimeout(this.quiet_mode_timeout_cb, 30);
		this.notify["quiet-mode"].connect((s, p) => {
			this.update_overlay_format();
		});
		this.update_overlay_format();
	}

	private void quiet_mode_timeout_cb(PausableTimeout timeout, int delta_millisecs) {
		DateTime now = new DateTime.now_utc();
		if (this.quiet_mode && now.to_unix() > this.quiet_mode_expire_time) {
			this.quiet_mode = false;
			this.quiet_mode_expire_time = 0;
			GLib.debug("Automatically expiring quiet mode");
		}
	}

	private void update_overlay_format() {
		if (this.quiet_mode) {
			this.screen_overlay.set_format(ScreenOverlay.Format.SILENT);
			this.quiet_mode_timeout.start();
			this.quiet_mode_timeout.run_once();
			GLib.debug("Quiet mode enabled");
		} else {
			this.screen_overlay.set_format(ScreenOverlay.Format.FULL);
			this.quiet_mode_timeout.stop();
			GLib.debug("Quiet mode disabled");
		}
	}
	
	public void show_notification(BreakView.NotificationContent content, Notify.Urgency urgency) {
		if (this.notification == null) {
			this.notification = new Notify.Notification("", null, null);
			this.notification.set_hint("transient", true);
		}
		this.notification.set_urgency(urgency);
		this.notification.update(content.summary, content.body, content.icon);
		
		try {
			this.notification.show();
		} catch (Error error) {
			GLib.warning("Error showing notification: %s", error.message);
		}
	}

	public void add_break(BreakView break_view) {
		this.application.hold();
	}

	public void remove_break(BreakView break_view) {
		this.release_focus(break_view);
		this.application.release();
	}

	private void break_focused_cb(BreakView break_view) {
		break_view.begin_ui_focus();
	}
	
	private void break_unfocused_cb(BreakView break_view) {
		break_view.end_ui_focus();
	}
}

