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
 * maintain a simple, modal structure. This uses SimpleFocusManager to make
 * sure only one break is affecting the UI at a time. This class also tries
 * to keep UI events nicely spaced so they don't turn into noise. Any object
 * which needs to provide a GUI implements UIFragment, which provides a simple
 * interface to create notifications and overlays.
 */
public class UIManager : SimpleFocusManager {
	public abstract class UIFragment : Object, IFocusable {
		protected UIManager ui_manager;

		protected IScreenOverlayContent? overlay_content;
		protected Notify.Notification? notification;

		protected FocusPriority focus_priority = FocusPriority.LOW;

		public abstract string get_id();

		protected void request_ui_focus() {
			if (this.has_ui_focus()) {
				// If we already have focus, UIManager will not call
				// focus_started again. We need to call it ourselves.
				this.focus_started();
			} else {
				this.ui_manager.request_focus(this, this.focus_priority);
			}
		}
		
		protected void release_ui_focus() {
			this.ui_manager.release_focus(this);
		}

		protected bool has_ui_focus() {
			return this.ui_manager.is_focusing(this);
		}

		protected void show_notification(Notify.Notification notification) {
			if (this.has_ui_focus()) {
				this.ui_manager.show_notification(notification);
				this.notification = notification;
			}
		}

		protected void show_lock_notification(Notify.Notification notification) {
			if (this.has_ui_focus()) {
				this.ui_manager.show_lock_notification(notification);
				this.notification = notification;
			}
		}

		protected void hide_notification() {
			this.ui_manager.hide_notification(this.notification);
		}

		protected void set_overlay(IScreenOverlayContent overlay_content) {
			this.overlay_content = overlay_content;

			if (this.has_ui_focus()) {
				this.ui_manager.screen_overlay.set_content(this.overlay_content);
			}
		}

		protected void reveal_overlay() {
			if (this.has_ui_focus()) {
				this.ui_manager.screen_overlay.reveal_content(this.overlay_content);
			}
		}

		protected void shake_overlay() {
			if (this.overlay_is_visible()) {
				this.ui_manager.screen_overlay.request_attention();
			}
		}

		protected bool overlay_is_visible() {
			return this.ui_manager.screen_overlay.is_showing_content(this.overlay_content);
		}

		protected void hide_overlay() {
			this.ui_manager.screen_overlay.disappear_content(this.overlay_content);
		}

		/* IFocusable interface */

		public abstract void focus_started();
		public abstract void focus_stopped();
	}

	private Application application;
	
	public bool quiet_mode {get; set; default=false;}
	public int64 quiet_mode_expire_time {get; set;}

	private PausableTimeout quiet_mode_timeout;

	protected ScreenOverlay screen_overlay;
	protected Notify.Notification? notification;
	
	public UIManager(Application application) {
		this.application = application;
		this.screen_overlay = new ScreenOverlay();
		
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

	/**
	 * Show a notification, ensuring that the application is only showing one
	 * notification at any time.
	 */
	protected void show_notification(Notify.Notification notification) {
		if (notification != this.notification) {
			this.hide_notification(this.notification);
		}
		try {
			notification.show();
		} catch (Error error) {
			GLib.warning("Error showing notification: %s", error.message);
		}
		this.notification = notification;
	}

	private Notify.Notification? lock_notification;
	/**
	 * Show a notification that will only appear in the lock screen. The
	 * notification automatically hides when the screen is unlocked.
	 */
	protected void show_lock_notification(Notify.Notification notification) {
		if (SessionStatus.instance.is_locked()) {
			this.show_notification(notification);
			this.lock_notification = notification;
			SessionStatus.instance.unlocked.connect(this.hide_lock_notification_cb);
		}
	}

	private void hide_lock_notification_cb() {
		this.hide_notification(this.lock_notification);
		SessionStatus.instance.unlocked.disconnect(this.hide_lock_notification_cb);
	}

	/**
	 * Close a notification proactively, if it is still open.
	 */
	protected void hide_notification(Notify.Notification? notification) {
		if (notification != null && notification == this.notification) {
			try {
				this.notification.close();
			} catch (Error error) {
				GLib.warning("Error closing notification: %s", error.message);
			}
		}
		this.notification = null;
	}

	public void add_break(BreakView break_view) {
		this.application.hold();
	}

	public void remove_break(BreakView break_view) {
		this.release_focus(break_view);
		this.application.release();
	}
}

