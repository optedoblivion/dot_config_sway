#!/bin/bash
# TODO(optedoblivion): Check for available dependency programs.

# Cleanup
rm -f temp.mp4
rm -f vid.gif

# Use slurp to select a screen area and record to mp4
wf-recorder -g "$(slurp)" -f temp.mp4

# Convert mp4 into a gif
ffmpeg -i temp.mp4 vid.gif
