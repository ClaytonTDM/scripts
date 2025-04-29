#!/bin/bash

if [ -f /usr/local/bin/asus_fan_notify.py ]; then
    rm -f /usr/local/bin/asus_fan_notify.py
    echo "Removed /usr/local/bin/asus_fan_notify.py"
fi

if [ -f /usr/local/bin/asus_fan_monitor.sh ]; then
    rm -f /usr/local/bin/asus_fan_monitor.sh
    echo "Removed /usr/local/bin/asus_fan_monitor.sh"
fi

if [ -f /tmp/asus_fan_profile_map.txt ]; then
    rm -f /tmp/asus_fan_profile_map.txt
    echo "Removed /tmp/asus_fan_profile_map.txt"
fi

if [ -f /home/$(logname)/.config/autostart/asus-fan-monitor.desktop ]; then
    rm -f /home/$(logname)/.config/autostart/asus-fan-monitor.desktop
    echo "Removed autostart entry"
fi

if [ -f /etc/sudoers.d/asus-fan-monitor ]; then
    rm -f /etc/sudoers.d/asus-fan-monitor
    echo "Removed sudoers entry"
fi

if [ -f /tmp/asus_fan_notification_id ]; then
    rm -f /tmp/asus_fan_notification_id
    echo "Removed temporary files"
fi

pkill -f "asus_fan_monitor.sh" 2>/dev/null
echo "Stopped any running instances"

echo "ASUS Fan Monitor has been completely uninstalled."
