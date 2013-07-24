@INTLTOOL_XML_NOMERGE_RULE@

@GSETTINGS_RULES@
gsettingsschema_in_files = org.gnome.break-timer.gschema.xml.in
gsettings_SCHEMAS = $(gsettingsschema_in_files:.xml.in=.xml)

@INTLTOOL_DESKTOP_RULE@
desktopdir = $(datadir)/applications
desktop_DATA = gnome-break-timer.desktop gnome-break-timer-service.desktop

autostartdir = $(sysconfdir)/xdg/autostart
autostart_DATA = gnome-break-timer-autostart.desktop

check: $(desktop_DATA) $(autostart_DATA)
	@for desktop in $(desktop_DATA); do \
		desktop-file-validate $${desktop} || exit 1; \
	done

EXTRA_DIST= \
    settings-panels.ui \
    gnome-break-timer.gresource.xml \
    $(desktop_DATA) \
    $(autostart_DATA) \
    $(service_in_files) \
    $(desktop_in_files) \
    $(gsettingsschema_in_files)

CLEANFILES = \
    $(desktop_DATA) \
    $(autostart_DATA) \
    $(gsettings_SCHEMAS)
