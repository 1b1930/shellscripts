#!/bin/bash

# TODO: replace ifs with case, maybe? haven't learned that yet though

# supress all error messages, remember to disable this in case something funky happens
exec 2>/dev/null

# check if /sys/class/backlight/intel_backlight exists
if [ -d /sys/class/backlight/intel_backlight ]; then
    # if it exists, get the current brightness value
    brightness=$(cat /sys/class/backlight/intel_backlight/brightness)
    # get the maximum brightness value
    max_brightness=$(cat /sys/class/backlight/intel_backlight/max_brightness)
    # calculate the percentage of the current brightness value
    percentage=$(echo "scale=2; $brightness / $max_brightness * 100" | bc)
    # print the percentage
    echo "Brightness: $percentage %"
else
    # if /sys/class/backlight/intel_backlight does not exist, print an error message
    echo "Error: /sys/class/backlight/intel_backlight does not exist"
fi

# if the user passed no argument or more than one argument, print help message and exit
if [ $# -eq 0 ] || [ $# -gt 1 ]; then
    echo "Usage: $0 [half|min|max|0-100]"
    exit 1
fi

# if the user passed an argument that isn't "half", "min", "max" or a number ranging from 0 to 100, print help message and exit
if [ "$1" != "half" ] && [ "$1" != "min" ] && [ "$1" != "max" ] && ! [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -lt 0 ] && [ "$1" -gt 100 ]; then
    echo "Usage: $0 [half|min|max|0-100]"
    exit 1
fi



# if the user passed the argument "half", set the brightness to half of the maximum value
if [ "$1" = "half" ]; then
    echo "Setting brightness to half of the maximum value"
    echo $((max_brightness / 2)) > /sys/class/backlight/intel_backlight/brightness
fi

# if user passed the argument "min", set the brightness to the minimum value
if [ "$1" = "min" ]; then
    echo "Setting brightness to the minimum value"
    echo 0 > /sys/class/backlight/intel_backlight/brightness
fi

# if user passed the argument "max", set the brightness to the maximum value
if [ "$1" = "max" ]; then
    echo "Setting brightness to the maximum value"
    echo $max_brightness > /sys/class/backlight/intel_backlight/brightness
fi

# if the user passed a number ranging from 0 to 100 as an argument, set the brightness to that percentage of the maximum value
# if the number is above 100, just print a warning message
if [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -ge 0 ] && [ "$1" -le 100 ]; then
    if [ "$1" -gt 100 ]; then
        echo "Warning: $1 is above 100, setting brightness to 100%"
    fi
    echo "Setting brightness to $1 %"
    echo $((max_brightness * $1 / 100)) > /sys/class/backlight/intel_backlight/brightness
fi
