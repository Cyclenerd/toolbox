#!/bin/sh

#
# Remove SRM Device Agent from Autostart
#

sudo sed -i -e 's/true/false/g' ~/Library/LaunchAgents/de.srm.pc8deviceagent.launcher.plist && echo 'Done'