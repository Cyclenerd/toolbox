#!/bin/bash

# Flip Monitor of my Yoga 11e Chromebook with Ubuntu

# Set keyboard shortcut:
# Settings -> Devices -> Keyboard
#     Shift + Ctrl + F3 = /home/nils/Scripts/flip-monitor.sh

# nils@11e:~$ monitor-left
# nils@11e:~$ xrandr --current
# Screen 0: minimum 320 x 200, current 768 x 1366, maximum 8192 x 8192
# eDP-1 connected primary 768x1366+0+0 left (normal left inverted right x axis y axis) 256mm x 144mm

# nils@11e:~$ monitor-flip
# nils@11e:~$ xrandr --current
# Screen 0: minimum 320 x 200, current 1366 x 768, maximum 8192 x 8192
# eDP-1 connected primary 1366x768+0+0 inverted (normal left inverted right x axis y axis) 256mm x 144mm


if xrandr --current | head -n 2 | grep 'inverted (normal'; then
	xrandr --output eDP-1 --rotate normal
else
	xrandr --output eDP-1 --rotate inverted
fi
