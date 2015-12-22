#!/bin/sh

bl_device=/sys/class/backlight/intel_backlight/brightness
bl_max=$(cat /sys/class/backlight/intel_backlight/max_brightness)
new=$(($(cat $bl_device)+50))

if [[ "$new" -le 0 ]]
    then
        new=0
fi

if [[ "$new" -le $bl_max ]]
    then
        echo $new | sudo tee $bl_device
fi

if [[ "$new" -ge $bl_max ]]
    then
        echo $bl_max | sudo tee $bl_device
fi


