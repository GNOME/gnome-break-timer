icon16dir = $(datadir)/icons/hicolor/16x16/apps
icon16_DATA = hicolor/16x16/apps/gnome-break-timer.png
icon22dir = $(datadir)/icons/hicolor/22x22/apps
icon22_DATA = hicolor/22x22/apps/gnome-break-timer.png
icon32dir = $(datadir)/icons/hicolor/32x32/apps
icon32_DATA = hicolor/32x32/apps/gnome-break-timer.png
icon48dir = $(datadir)/icons/hicolor/48x48/apps
icon48_DATA = hicolor/48x48/apps/gnome-break-timer.png
icon256dir = $(datadir)/icons/hicolor/256x256/apps
icon256_DATA = hicolor/256x256/apps/gnome-break-timer.png
icon_files = \
	$(icon16_DATA) \
	$(icon22_DATA) \
	$(icon32_DATA) \
	$(icon48_DATA) \
	$(icon256_DATA) \
	hicolor/gnome-break-timer.svg

gtk_update_icon_cache = gtk-update-icon-cache -f -t $(datadir)/icons/hicolor

install-data-hook: update-icon-cache
uninstall-hook: update-icon-cache
update-icon-cache:
	@-if test -z "$(DESTDIR)"; then \
		echo "Updating Gtk icon cache."; \
		$(gtk_update_icon_cache); \
	else \
		echo "*** Icon cache not updated.  After (un)install, run this:"; \
		echo "***   $(gtk_update_icon_cache)"; \
	fi

EXTRA_DIST = \
	$(icon_files)
