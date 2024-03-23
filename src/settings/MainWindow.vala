/* MainWindow.vala
 *
 * Copyright 2020-2021 Dylan McCall <dylan@dylanmccall.ca>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using BreakTimer.Common;
using BreakTimer.Settings.Break;
using BreakTimer.Settings.Panels;

namespace BreakTimer.Settings {

public class MainWindow : Adw.ApplicationWindow, GLib.Initable {
    private BreakManager break_manager;

    private GLib.DBusConnection dbus_connection;

    private GLib.Menu app_menu;

    private Adw.HeaderBar header;
    private Gtk.Stack main_stack;
    private Adw.Banner permission_error_banner;

    private Gtk.Button settings_button;
    private Gtk.Switch master_switch;
    private Gtk.MenuButton menu_button;

    private BreakSettingsDialog break_settings_dialog;

    private WelcomePanel welcome_panel;
    private StatusPanel status_panel;

    private bool skip_tour;

    public MainWindow (Application application, BreakManager break_manager) {
        GLib.Object (application: application);

        this.break_manager = break_manager;
        this.skip_tour = break_manager.master_enabled;

        this.set_title (_("Break Timer"));
        this.set_default_size (850, 400);

        Gtk.Builder builder = new Gtk.Builder ();
        try {
            builder.add_from_resource ("/org/gnome/BreakTimer/settings/ui/settings-panels.ui");
        } catch (GLib.Error e) {
            GLib.error ("Error loading UI: %s", e.message);
        }

        this.app_menu = new GLib.Menu ();
        this.app_menu.append (_("About"), "app.about");
        this.app_menu.append (_("Quit"), "app.quit");

        this.break_settings_dialog = new BreakSettingsDialog (break_manager);
        this.break_settings_dialog.set_modal (true);
        this.break_settings_dialog.set_transient_for (this);
        this.break_settings_dialog.set_hide_on_close (true);

        Gtk.Box content = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        this.set_content (content);
        content.set_orientation (Gtk.Orientation.VERTICAL);
        content.set_vexpand (true);

        this.header = new Adw.HeaderBar ();
        content.append (this.header);

        this.master_switch = new Gtk.Switch ();
        master_switch.set_valign (Gtk.Align.CENTER);
        break_manager.bind_property ("master-enabled", this.master_switch, "active", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
        header.pack_start (this.master_switch);

        this.menu_button = new Gtk.MenuButton ();
        this.menu_button.set_direction (Gtk.ArrowType.NONE);
        this.menu_button.set_menu_model (this.app_menu);
        header.pack_end (this.menu_button);

        this.settings_button = new Gtk.Button ();
        settings_button.clicked.connect (this.on_settings_clicked);
        // FIXME: Verify, especially IconSize
        settings_button.set_child (
            new Gtk.Image.from_icon_name ("alarm-symbolic")
        );
        settings_button.valign = Gtk.Align.CENTER;
        // FIXME: Verify
        // settings_button.set_always_show_image (true);
        header.pack_end (this.settings_button);

        this.main_stack = new Gtk.Stack ();
        content.append (this.main_stack);
        main_stack.set_margin_top (6);
        main_stack.set_margin_bottom (6);
        main_stack.set_transition_duration (250);

        this.permission_error_banner = new Adw.Banner (
            _("Break Timer needs permission to start automatically and run in the background")
        );
        /* Label for a button that opens GNOME Settings to change permissions */
        this.permission_error_banner.button_label = _("Open Settings");
        this.permission_error_banner.button_clicked.connect (this.on_permission_error_banner_button_clicked);
        content.append (this.permission_error_banner);

        this.status_panel = new StatusPanel (break_manager, builder);
        this.main_stack.add_named (this.status_panel, "status_panel");

        this.welcome_panel = new WelcomePanel (break_manager, builder, this);
        this.main_stack.add_named (this.welcome_panel, "welcome_panel");
        this.welcome_panel.tour_finished.connect (this.on_tour_finished);

        this.header.show ();
        content.show ();

        break_manager.notify["permissions-error"].connect (this.on_break_manager_permissions_error_change);
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
            info_widget.set_halign (Gtk.Align.FILL);
            info_widget.set_valign (Gtk.Align.FILL);
        }

        this.break_settings_dialog.init (cancellable);
        this.status_panel.init (cancellable);

        return true;
    }

    private void on_break_manager_permissions_error_change () {
        if (this.break_manager.permissions_error != NONE) {
            this.permission_error_banner.set_revealed(true);
        } else {
            this.permission_error_banner.set_revealed(false);
        }
    }

    public Gtk.Widget get_master_switch () {
        return this.master_switch;
    }

    public Gtk.Widget get_settings_button () {
        return this.settings_button;
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
        if (!skip_tour && this.welcome_panel.is_active ()) {
            this.main_stack.set_visible_child_full ("welcome_panel", transition);
            this.set_title (_("Welcome Tour"));
        } else if (foreground_break != null) {
            this.main_stack.set_visible_child_full (foreground_break.id, transition);
            this.set_title (foreground_break.info_widget.title);
        } else {
            this.main_stack.set_visible_child_full ("status_panel", transition);
            this.set_title (_("Break Timer"));
        }
    }

    private void on_tour_finished () {
        this.update_visible_panel ();
    }

    private void on_settings_clicked () {
        this.break_settings_dialog.show ();
        this.welcome_panel.settings_button_clicked ();
    }

    private void on_permission_error_banner_button_clicked (Adw.Banner banner) {
        GLib.Idle.add_full (
            GLib.Priority.HIGH_IDLE,
            () => {
                this.launch_application_settings ();
                return GLib.Source.REMOVE;
            }
        );
    }

    private bool launch_application_settings () {
        // Try to launch GNOME Settings pointing at the Applications panel.
        // This feels kind of dirty and it would be nice if there was a better
        // way.
        // TODO: Can we pre-select org.gnome.BreakTimer?
        // TODO: Vala doesn't provide an easy way to do async dbus method calls,
        //       so we'll spawn a simple thread for this.

        new GLib.Thread<bool> (null, () => {
            GLib.Variant[] parameters = {
                new GLib.Variant ("(sav)", "applications")
            };
            GLib.HashTable<string, Variant> platform_data = new GLib.HashTable<string, Variant> (str_hash, str_equal);

            try {
                IFreedesktopApplication gnome_settings_application = this.dbus_connection.get_proxy_sync (
                    "org.gnome.Settings",
                    "/org/gnome/Settings",
                    GLib.DBusProxyFlags.DO_NOT_AUTO_START,
                    null
                );
                gnome_settings_application.activate_action ("launch-panel", parameters, platform_data);
            } catch (GLib.IOError error) {
                GLib.warning ("Error connecting to org.gnome.Settings: %s", error.message);
                return false;
            } catch (GLib.DBusError error) {
                GLib.warning ("Error launching org.gnome.Settings: %s", error.message);
                return false;
            }
            return true;
        });

        return true;
    }
}

}
