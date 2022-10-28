#!/bin/bash

# this script updates dunst's colors with the colors from xrdb, since dunst
# doesn't have a native way of using xrdb colors like i3 or polybar does
# this script gets executed after i make changes to my .Xresources
# you'll have to find a way to do this on your setup,
# i just use a bash alias (vim ~/.Xresources && xrdb ~/.Xresources && update_colors.sh)

# get the "background" color from xrdb
background=$(xrdb -query | grep "*.background" | cut -f2)
# print the "background" color
echo "Background: $background"
# get the foreground color from xrdb
foreground=$(xrdb -query | grep "*.foreground" | cut -f2)
# print the foreground color
echo "Foreground: $foreground"
# get the color0 color from xrdb
color0=$(xrdb -query | grep "*.color0" | cut -f2)
# print the color0 color
echo "Color0: $color0"

# replace the "background" color in $HOME/.config/dunst/dunstrc with the color from xrdb
# add double quotes around the color to make sure it's interpreted as a string

sed -i "s/background = .*/background = \"$background\"/" $HOME/.config/dunst/dunstrc
# do the same for the foreground color

sed -i "s/foreground = .*/foreground = \"$foreground\"/" $HOME/.config/dunst/dunstrc

# replace the "frame_color" color in $HOME/.config/dunst/dunstrc with color0 from xrdb
# add double quotes around the color to make sure it's interpreted as a string

sed -i "s/frame_color = .*/frame_color = \"$color0\"/" $HOME/.config/dunst/dunstrc

# get the urxvt.background color from Xresources via xrdb, then isolate the alpha value
# which is the only one we need

alpha=$(xrdb -query | grep urxvt.background | cut -f2 | cut -d/ -f4)
#echo $alpha

# now we convert background to rgba format, and add the alpha value to the end
# this is the format that urxvt.background needs to be in

# first, split the background color into its rgb values and add zeroes to the end
red=$(echo $background | cut -d# -f2 | cut -c1-2 | sed 's/$/00/')
green=$(echo $background | cut -d# -f2 | cut -c3-4 | sed 's/$/00/')
blue=$(echo $background | cut -d# -f2 | cut -c5-6 | sed 's/$/00/')

# now we can put the color back together in RGBA format

rgba="$red\/$green\/$blue\/$alpha"

# now replace the urxvt*background color in Xresources with the new rgba color
sed -i "s/urxvt*background: .*/urxvt*background: rgba:$rgba/" "$HOME/.Xresources"

# restart dunst using good ol' dbus, since dunst can't reload its config file on the fly
killall dunst
sleep 0.1
notify-send "update_colors.sh" "Dunst colors updated"
