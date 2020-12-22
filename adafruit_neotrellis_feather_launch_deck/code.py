# NeoTrellis Feather Launch Deck
# Adafruit 4x4 NeoTrellis Feather M4 Kit Pack: https://www.adafruit.com/product/4352
#
# USB HID button box for launching applications, media control, camera switching and more
# Use it with your favorite keyboard controlled launcher, such as Quicksilver and AutoHotkey
#
# Author: Nils Knieling  https://github.com/Cyclenerd
# Inspired by: https://learn.adafruit.com/launch-deck-trellis-m4

# Needed CircuitPython Libraries:
#  * adafruit_bus_device
#  * adafruit_hid
#  * adafruit_neotrellis
#  * adafruit_seesaw
# Download: https://circuitpython.org/libraries

import time
from adafruit_neotrellis.neotrellis import NeoTrellis
from board import SCL, SDA
import busio
import usb_hid
from adafruit_hid.keyboard import Keyboard
from adafruit_hid.keycode import Keycode
from adafruit_hid.consumer_control import ConsumerControl
from adafruit_hid.consumer_control_code import ConsumerControlCode

# some color definitions
OFF    = (0, 0, 0)
RED    = (255, 0, 0)
YELLOW = (255, 150, 0)
GREEN  = (0, 255, 0)
CYAN   = (0, 255, 255)
BLUE   = (0, 0, 255)
PURPLE = (255, 0, 255)

# the two command types -- MEDIA for ConsumerControlCodes, KEY for Keycodes
# this allows button press to send the correct HID command for the type specified
MEDIA = 1
KEY = 2

# Keymap (event.number):
# [ 0] [ 1] [ 2] [ 3]
# [ 4] [ 5] [ 6] [ 7]
# [ 8] [ 9] [10] [11]
# [12] [13] [14] [15]
#
# Keycodes:
# https://circuitpython.readthedocs.io/projects/hid/en/latest/_modules/adafruit_hid/keycode.html
#
# Button mapping:
# customize these for your desired postitions, colors, and keyboard combos
keymap = {
     0: (GREEN,  MEDIA, ConsumerControlCode.PLAY_PAUSE),
     1: (PURPLE, MEDIA, ConsumerControlCode.SCAN_PREVIOUS_TRACK),
     2: (PURPLE, MEDIA, ConsumerControlCode.SCAN_NEXT_TRACK),
     3: (BLUE,   MEDIA, ConsumerControlCode.MUTE),
     4: (CYAN,   KEY,   (Keycode.SHIFT, Keycode.F13)), # AutoHotKey +F13
     5: (CYAN,   KEY,   (Keycode.SHIFT, Keycode.F14)),
     6: (CYAN,   KEY,   (Keycode.SHIFT, Keycode.F15)),
     7: (CYAN,   KEY,   (Keycode.SHIFT, Keycode.F16)),
     8: (RED,    KEY,   (Keycode.GUI, Keycode.ONE)), # Win+1, Chrome
     9: (BLUE,   KEY,   (Keycode.GUI, Keycode.THREE)), # Win+3, KeePass
    10: (GREEN,  KEY,   (Keycode.GUI, Keycode.NINE)), # Win+9, Spotify
    11: (PURPLE, KEY,   (Keycode.GUI, Keycode.SEVEN)), # Win+7, Teams
    12: (GREEN,  KEY,   (Keycode.CONTROL, Keycode.R)), # reload
    13: (PURPLE, KEY,   (Keycode.CONTROL, Keycode.SHIFT, Keycode.TAB)), # cycle tabs backards
    14: (PURPLE, KEY,   (Keycode.CONTROL, Keycode.TAB)), # cycle tab forwards
    15: (RED,    KEY,   (Keycode.CONTROL, Keycode.F4)), # close tab
}

kbd = Keyboard(usb_hid.devices)
cc = ConsumerControl(usb_hid.devices)

# create the i2c object for the trellis
i2c_bus = busio.I2C(SCL, SDA)

# create the trellis
trellis = NeoTrellis(i2c_bus, False, addr=0x2E)

# this will be called when button events are received
def blink(event):
    button = event.number
    if event.edge == NeoTrellis.EDGE_RISING:
        print(button)
        if keymap[button][1] == KEY:
            kbd.press(*keymap[button][2])
            kbd.release(*keymap[button][2])
        else:
            cc.send(keymap[button][2])

for button in keymap:
    trellis.pixels.brightness = 0.01
    trellis.pixels[button] = keymap[button][0]
    # activate rising edge events on all keys
    trellis.activate_key(button, NeoTrellis.EDGE_RISING)
    # activate falling edge events on all keys
    trellis.activate_key(button, NeoTrellis.EDGE_FALLING)
    # set all keys to trigger the blink callback
    trellis.callbacks[button] = blink

while True:
    # call the sync function call any triggered callbacks
    trellis.sync()
    # the trellis can only be read every 17 millisecons or so
    time.sleep(0.02)