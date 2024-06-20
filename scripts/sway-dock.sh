#!/bin/bash
set -e

LANDSCAPE_SERIAL="011NTWG4T545"
PORTRAIT_SERIAL="011NTEP4B380"

LANDSCAPE_OUTPUT="$(swaymsg -t get_outputs -p | grep ${LANDSCAPE_SERIAL} | awk '{ print $2 }')"
PORTRAIT_OUTPUT="$(swaymsg -t get_outputs -p | grep ${PORTRAIT_SERIAL} | awk '{ print $2 }')"

function disable_laptop_screen() {
	echo 1.5
	swaymsg -- output eDP-1 disable
}

function disable_landscape() {
	if [ "$LANDSCAPE_OUTPUT" != "" ]; then
		swaymsg -- output $LANDSCAPE_OUTPUT disable
	fi
}

function disable_portrait() {
	if [ "$PORTRAIT_OUTPUT" != "" ]; then
		swaymsg -- output $PORTRAIT_OUTPUT disable
	fi
}

function enable_laptop_screen() {
	swaymsg -- output eDP-1 enable
}

function enable_landscape() {
	if [ "$LANDSCAPE_OUTPUT" != "" ]; then
		swaymsg -- output $LANDSCAPE_OUTPUT enable
	fi
}

function transform_portrait() {
	if [ "$LANDSCAPE_OUTPUT" != "" ]; then
		swaymsg -- output $PORTRAIT_OUTPUT transform normal           # reset.
		swaymsg -- output $PORTRAIT_OUTPUT transform 90 anticlockwise # rotate.
	fi
}

function enable_portrait() {
	if [ "$PORTRAIT_OUTPUT" != "" ]; then
		swaymsg -- output $PORTRAIT_OUTPUT enable
	fi
}

function position_outputs() {
	# Position largest monitor as main screen.
	if [ "$LANDSCAPE_OUTPUT" != "" ]; then
		swaymsg -- output $LANDSCAPE_OUTPUT position 0 0 mode 3440 1440
	fi
	if [ "$PORTRAIT_OUTPUT" != "" ]; then
		swaymsg -- output $PORTRAIT_OUTPUT position -1080 0 mode 1920 1080
	fi
}

# Docks to the left side docking station.
function dock() {
	# Disable all monitors.
	echo 1
	disable_laptop_screen
	echo 2
	disable_landscape
	disable_portrait
	sleep 1

	# Enable only monitors, keep laptop screen off.
	enable_landscape
	enable_portrait
	sleep 1

	# Configure monitors.
	transform_portrait

	# Set the positions of the outputs.
	position_outputs
}

function undock() {
	# Disable all monitors.
	disable_laptop_screen
	disable_landscape
	disable_portrait
	sleep 1

	# Enable laptop monitor
	swaymsg -- output eDP-1 enable
}

# Check state
# Is the laptop monitor disabled or not?
IS_LAPTOP_MONITOR_DISABLED=$(swaymsg -t get_outputs -p | grep eDP-1 | grep disabled || echo disabled)

if [ "${IS_LAPTOP_MONITOR_DISABLED}" == "disabled" ]; then
	echo "Docking"
	dock
else
	echo "Undocking"
	undock
fi
