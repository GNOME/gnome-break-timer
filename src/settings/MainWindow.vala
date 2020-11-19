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

using BreakTimer.Settings.Break;
using BreakTimer.Settings.Panels;

namespace BreakTimer.Settings {

public class MainWindow : Gtk.ApplicationWindow, GLib.Initable {
    private BreakManager break_manager;

    private GLib.DBusConnection dbus_connection;

    private GLib.Menu app_menu;

    private Gtk.HeaderBar header;
    private Gtk.Stack main_stack;

    private Gtk.Button settings_button;
    private Gtk.Switch master_switch;
    private Gtk.MenuButton menu_button;

    private BreakSettingsDialog break_settings_dialog;

    private WelcomePanel welcome_panel;
    private StatusPanel status_panel;

    public MainWindow (Application application, BreakManager break_manager) {
        GLib.Object (application: application);

        this.break_manager = break_manager;

        this.set_title ( _("Break Timer"));
        this.set_default_size (850, 400);

        Gtk.Builder builder = new Gtk.Builder ();
        try {
            builder.add_from_resource ("/org/gnome/BreakTimer/settings/settings-panels.ui");
        } catch (Error e) {
            GLib.error ("Error loading UI: %s", e.message);
        }

        this.app_menu = new GLib.Menu ();
        this.app_menu.append ( _("About"), "app.about");
        this.app_menu.append ( _("Quit"), "app.quit");

        this.break_settings_dialog = new BreakSettingsDialog (break_manager);
        this.break_settings_dialog.set_modal (true);
        this.break_settings_dialog.set_transient_for (this);

        Gtk.Grid content = new Gtk.Grid ();
        this.add (content);
        content.set_orientation (Gtk.Orientation.VERTICAL);
        content.set_vexpand (true);

        this.header = new Gtk.HeaderBar ();
        this.set_titlebar (this.header);
        this.header.set_show_close_button (true);
        this.header.set_hexpand (true);

        this.master_switch = new Gtk.Switch ();
        master_switch.set_valign (Gtk.Align.CENTER);
        break_manager.bind_property ("master-enabled", this.master_switch, "active", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
        header.pack_start (this.master_switch);

        this.menu_button = new Gtk.MenuButton ();
        this.menu_button.set_direction (Gtk.ArrowType.NONE);
        this.menu_button.set_menu_model (this.app_menu);
        header.pack_end (this.menu_button);

        this.settings_button = new Gtk.Button ();
        settings_button.clicked.connect (this.settings_clicked_cb);
        // FIXME: This icon is not semantically correct. (Wrong category, especially).
        settings_button.set_image (new Gtk.Image.from_icon_name (
            "preferences-system-symbolic",
            Gtk.IconSize.MENU)
        );
        settings_button.valign = Gtk.Align.CENTER;
        settings_button.set_always_show_image (true);
        header.pack_end (this.settings_button);

        this.main_stack = new Gtk.Stack ();
        content.add (this.main_stack);
        main_stack.set_margin_top (6);
        main_stack.set_margin_bottom (6);
        main_stack.set_transition_duration (250);

        this.status_panel = new StatusPanel (break_manager, builder);
        this.main_stack.add_named (this.status_panel, "status_panel");

        this.welcome_panel = new WelcomePanel (break_manager, builder, this);
        this.main_stack.add_named (this.welcome_panel, "welcome_panel");
        this.welcome_panel.tour_finished.connect (this.on_tour_finished);

        this.header.show_all ();
        content.show_all ();

        break_manager.notify["foreground-break"].connect (this.update_visible_panel);
        this.update_visible_panel ();
    }

    public bool init (GLib.Cancellable? cancellable) throws GLib.Error {
        this.dbus_connection = GLib.Bus.get_sync (GLib.BusType.SESSION, cancellable);

        foreach (BreakType break_type in this.break_manager.all_breaks ()) {
            var info_widget = break_type.info_widget;
            this.main_stack.add_named (info_widget, break_type.id);
            info_widget.set_margin_start (20);
            info_widget.set_margin_end (20);
            info_widget.set_halign (Gtk.Align.CENTER);
            info_widget.set_valign (Gtk.Align.CENTER);
        }

        this.break_settings_dialog.init (cancellable);
        this.status_panel.init (cancellable);

        return true;
    }

    public Gtk.Widget get_master_switch () {
        return this.master_switch;
    }

    public Gtk.Widget get_settings_button () {
        return this.settings_button;
    }

    public Gtk.Widget? get_close_button () {
        // TODO: We need some way to get the close button position from this.header
        return null;
    }

    private void update_visible_panel () {
        // Use a transition when switching from the welcome panel
        Gtk.StackTransitionType transition;
        if (this.main_stack.get_visible_child () == this.welcome_panel) {
            transition = Gtk.StackTransitionType.SLIDE_LEFT;
        } else {
            transition = Gtk.StackTransitionType.NONE;
        }

        BreakType? foreground_break = this.break_manager.foreground_break;
        if (this.welcome_panel.is_active ()) {
            this.main_stack.set_visible_child_full ("welcome_panel", transition);
            this.header.set_title ( _("Welcome Tour"));
        } else if (foreground_break != null) {
            this.main_stack.set_visible_child_full (foreground_break.id, transition);
            this.header.set_title (foreground_break.info_widget.title);
        } else {
            this.main_stack.set_visible_child_full ("status_panel", transition);
            this.header.set_title ( _("Break Timer"));
        }
    }

    private void on_tour_finished () {
        this.update_visible_panel ();
    }

    public void show_about_dialog () {
        const string copyright = "Copyright © 2011-2013 Dylan McCall";

        Gtk.show_about_dialog (this,
            "program-name", _("GNOME Break Timer"),
            "logo-icon-name", Config.APPLICATION_ICON,
            "version", Config.PROJECT_VERSION,
            "comments", _("Computer break reminders for active minds"),
            "website", Config.APPLICATION_URL,
            "website-label", _("GNOME Break Timer Website"),
            "copyright", copyright,
            "license-type", Gtk.License.GPL_3_0,
            "wrap-license", false,
            "translator-credits", _("translator-credits")
        );
    }

    private void settings_clicked_cb () {
        this.break_settings_dialog.show ();
        this.welcome_panel.settings_button_clicked ();
    }
}

}
