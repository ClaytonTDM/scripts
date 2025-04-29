#!/bin/bash

if [ -f /usr/local/bin/asus_fan_notify.py ]; then
    rm -f /usr/local/bin/asus_fan_notify.py
    echo "Removed /usr/local/bin/asus_fan_notify.py"
fi

if [ -f /usr/local/bin/asus_fan_monitor.sh ]; then
    rm -f /usr/local/bin/asus_fan_monitor.sh
    echo "Removed /usr/local/bin/asus_fan_monitor.sh"
fi

TARGET_USER=""
if [ -n "$SUDO_USER" ]; then
    TARGET_USER="$SUDO_USER"
elif [ -n "$(logname 2>/dev/null)" ]; then
    TARGET_USER=$(logname)
else
    TARGET_USER=$(who | grep -E '\(:[0-9.]+\)' | head -n 1 | awk '{print $1}')
fi

if [ -n "$TARGET_USER" ] && [ -d "/home/$TARGET_USER/.config/asus-fan-monitor" ]; then
    rm -rf "/home/$TARGET_USER/.config/asus-fan-monitor"
    echo "Removed persistent configuration directory"
fi

if [ -f /tmp/asus_fan_profile_map.txt ]; then
    rm -f /tmp/asus_fan_profile_map.txt
    echo "Removed /tmp/asus_fan_profile_map.txt"
fi

if [ -f /tmp/asus_fan_notification_id ]; then
    rm -f /tmp/asus_fan_notification_id
    echo "Removed /tmp/asus_fan_notification_id"
fi

if [ -n "$TARGET_USER" ] && [ -f "/home/$TARGET_USER/.config/autostart/asus-fan-monitor.desktop" ]; then
    rm -f "/home/$TARGET_USER/.config/autostart/asus-fan-monitor.desktop"
    echo "Removed autostart entry"
fi

if [ -f /etc/sudoers.d/asus-fan-monitor ]; then
    rm -f /etc/sudoers.d/asus-fan-monitor
    echo "Removed sudoers entry"
fi

pkill -f "asus_fan_monitor.sh" 2>/dev/null
echo "Stopped any running instances"

echo "ASUS Fan Monitor has been completely uninstalled."
