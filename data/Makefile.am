SUBDIRS = icons

@INTLTOOL_XML_NOMERGE_RULE@
@GSETTINGS_RULES@
@INTLTOOL_DESKTOP_RULE@


# settings schemas

gsettingsschema_in_files = org.gnome.break-timer.gschema.xml.in
gsettings_SCHEMAS = $(gsettingsschema_in_files:.xml.in=.xml)


# launchers

desktopdir = $(datadir)/applications
desktop_DATA = gnome-break-timer.desktop gnome-break-timer-service.desktop

autostartdir = $(sysconfdir)/xdg/autostart
autostart_DATA = gnome-break-timer-autostart.desktop

check: $(desktop_DATA) $(autostart_DATA)
	@for desktop in $(desktop_DATA); do \
		desktop-file-validate $${desktop} || exit 1; \
	done


# appdata

appdatadir = $(datadir)/appdata
appdata_in_files = gnome-break-timer.appdata.xml.in
appdata_DATA = $(appdata_in_files:.appdata.xml.in=.appdata.xml)


EXTRA_DIST= \
	settings-panels.ui \
	gnome-break-timer.gresource.xml \
	$(desktop_DATA) \
	$(appdata_in_files) \
	$(autostart_DATA) \
	$(service_in_files) \
	$(desktop_in_files) \
	$(gsettingsschema_in_files)

CLEANFILES = \
	$(desktop_DATA) \
	$(appdata_DATA) \
	$(autostart_DATA) \
	$(gsettings_SCHEMAS)
