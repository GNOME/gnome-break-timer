#!/bin/bash

# It would be better to do this in our build process, but appstreamcli is not
# available in the GNOME flatpak Sdk, and I don't understand the equivalent
# command in appstream-util.

appstreamcli news-to-metainfo NEWS --format=yaml --limit=6 data/metainfo/org.gnome.BreakTimer.metainfo.xml.in.in
