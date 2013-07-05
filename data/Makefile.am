@INTLTOOL_XML_NOMERGE_RULE@

@GSETTINGS_RULES@
gsettings_SCHEMAS = org.brainbreak.gschema.xml

@INTLTOOL_DESKTOP_RULE@
desktopdir = $(datadir)/applications
desktop_DATA = brainbreak.desktop brainbreak-settings.desktop

autostartdir = $(sysconfdir)/xdg/autostart
autostart_DATA = brainbreak-autostart.desktop

check: $(desktop_DATA) $(autostart_DATA)
	@for desktop in $(desktop_DATA); do \
		desktop-file-validate $${desktop} || exit 1; \
	done

EXTRA_DIST= \
    brainbreak.desktop \
    brainbreak-autostart.desktop \
    brainbreak-settings.desktop \
    $(service_in_files) \
    $(desktop_in_files) \
    $(gsettingsschema_in_files)

CLEANFILES = \
    $(desktop_DATA) \
    $(autostart_DATA) \
    $(gsettings_SCHEMAS)
