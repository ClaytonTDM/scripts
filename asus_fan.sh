#!/bin/bash

cat > /usr/local/bin/asus_fan_notify.py << 'EOF'
#!/usr/bin/env python3
import gi
gi.require_version('Notify', '0.7')
from gi.repository import Notify, GLib
import sys
import os
import time

ID_FILE = "/tmp/asus_fan_notification_id"
Notify.init("ASUS Power Profile Monitor")

def send_notification(profile_name):
    """Sends a notification based on the provided power profile name."""

    if not profile_name or profile_name == "unknown":
        message = "Unknown/Learning..."
        icon = "dialog-question-symbolic"
    elif profile_name == "power-saver":
        message = "Power Saver"
        icon = "power-profile-power-saver-symbolic"
    elif profile_name == "balanced":
        message = "Balanced"
        icon = "power-profile-balanced-symbolic"
    elif profile_name == "performance":
        message = "Performance"
        icon = "power-profile-performance-symbolic"
    else:
        # Handle unexpected profile names just in case
        message = f"Profile: {profile_name.capitalize()}"
        icon = "dialog-question-symbolic" # Or a generic power icon

    notification = Notify.Notification.new("Power Profile", message, icon)

    try:
        if os.path.exists(ID_FILE):
            with open(ID_FILE, 'r') as f:
                old_id = f.read().strip()
                if old_id:
                    try:
                        temp_notification = Notify.Notification.new("", "", "")
                        temp_notification.set_property("id", int(old_id))
                        temp_notification.close()
                    except Exception:
                        pass # Ignore errors closing old notification
    except Exception:
        pass

    notification.show()

    try:
        GLib.timeout_add(100, lambda: save_notification_id(notification))
    except Exception:
        pass

def save_notification_id(notification):
    """Callback to save the notification ID after it's shown."""
    try:
        notification_id = notification.get_property("id")
        if notification_id > 0:
            with open(ID_FILE, 'w') as f:
                f.write(str(notification_id))
    except Exception:
        pass
    return False # Run only once

if len(sys.argv) > 1:
    profile_arg = sys.argv[1]
else:
    profile_arg = "unknown" # Default if no arg provided

loop = GLib.MainLoop()
send_notification(profile_arg)
# Quit the loop shortly after sending
GLib.timeout_add(500, loop.quit)

try:
    loop.run()
except KeyboardInterrupt:
    print("Script interrupted.")

EOF

chmod +x /usr/local/bin/asus_fan_notify.py
if [ "$(id -u)" = "0" ] && [ -n "$(logname)" ]; then
    chown $(logname):$(logname) /usr/local/bin/asus_fan_notify.py
fi


cat > /usr/local/bin/asus_fan_monitor.sh << 'EOF'
#!/bin/bash

MAP_FILE="/tmp/asus_fan_profile_map.txt"
# Touch the file initially if it doesn't exist
touch "$MAP_FILE"

get_mapped_profile() {
    local mode="$1"
    grep "^${mode}=" "$MAP_FILE" | cut -d'=' -f2
}

update_map() {
    local mode="$1"
    local profile="$2"
    # Create a temporary file
    local temp_map=$(mktemp)
    # Remove existing entry for this mode (if any)
    grep -v "^${mode}=" "$MAP_FILE" > "$temp_map"
    # Add the new mapping
    echo "${mode}=${profile}" >> "$temp_map"
    # Atomically replace the old map file
    mv "$temp_map" "$MAP_FILE"
}

run_notify() {
    local profile_name="$1"
    local current_user=$(logname)
    if [ -n "$current_user" ]; then
        local user_id=$(id -u $current_user)
        # Attempt to find the DBUS session address for common desktop environments
        local dbus_address=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u $user_id -n gnome-session || pgrep -u $user_id -n plasma_session || pgrep -u $user_id -n xfce4-session || pgrep -u $user_id -n cinnamon-session || echo 0)/environ | cut -d= -f2-)

        if [ -n "$dbus_address" ]; then
             sudo -u $current_user DBUS_SESSION_BUS_ADDRESS=$dbus_address /usr/local/bin/asus_fan_notify.py "$profile_name"
        else
             # Fallback if DBUS address not found
             sudo -u $current_user /usr/local/bin/asus_fan_notify.py "$profile_name"
        fi
    fi
}


sudo dmesg -c > /dev/null

echo "Monitoring dmesg for fan mode changes. Learning mapping..."

stdbuf -oL sudo dmesg -w | grep --line-buffered -E 'asus_wmi: Set fan boost mode:' | while read -r line; do
    dmesg_mode=$(echo "$line" | grep -o "Set fan boost mode: [0-2]" | awk '{print $5}')

    if [[ "$dmesg_mode" =~ ^[0-2]$ ]]; then
        mapped_profile=$(get_mapped_profile "$dmesg_mode")

        if [ -n "$mapped_profile" ]; then
            # echo "Mapping known: $dmesg_mode -> $mapped_profile. Notifying..." # Debug
            run_notify "$mapped_profile"
        else
            echo "Learning mapping for dmesg mode: $dmesg_mode..." # Info
            # Wait for the power profile change to likely complete
            sleep 3
            actual_profile=$(powerprofilesctl get)

            if [ -n "$actual_profile" ] && [ "$actual_profile" != "unknown" ]; then
                echo "Learned: dmesg mode $dmesg_mode corresponds to profile '$actual_profile'. Storing." # Info
                update_map "$dmesg_mode" "$actual_profile"
                run_notify "$actual_profile"
            else
                echo "Warning: Could not determine actual power profile after delay. Cannot update map for mode $dmesg_mode." # Warn
                # run_notify "unknown"
            fi
        fi
    else
         echo "Warning: Could not extract valid mode number from dmesg line: $line" # Warn
    fi
done
EOF

chmod +x /usr/local/bin/asus_fan_monitor.sh


CURRENT_USER=$(logname)
if [ -n "$CURRENT_USER" ]; then
    AUTODIR="/home/$CURRENT_USER/.config/autostart/"
    mkdir -p "$AUTODIR"
    cat > "$AUTODIR/asus-fan-monitor.desktop" << EOF
[Desktop Entry]
Type=Application
Name=ASUS Power Profile Monitor
Comment=Monitor ASUS power profile changes via dmesg trigger (with learning)
Exec=/usr/local/bin/asus_fan_monitor.sh
Terminal=false
Hidden=false
X-GNOME-Autostart-enabled=true
EOF
    if [ "$(id -u)" = "0" ]; then
        chown -R $CURRENT_USER:$CURRENT_USER "$AUTODIR"
    fi
else
    echo "Warning: Could not determine logged in user ('logname'). Autostart entry not created/updated."
fi


if [ -n "$CURRENT_USER" ]; then
    SUDOERS_FILE="/etc/sudoers.d/asus-fan-monitor"
    echo "# Allow running dmesg without password for ASUS power profile monitoring" > "$SUDOERS_FILE"
    echo "$CURRENT_USER ALL=(ALL) NOPASSWD: /bin/dmesg" >> "$SUDOERS_FILE"
    chmod 440 "$SUDOERS_FILE"
else
     echo "Warning: Could not determine logged in user ('logname'). Sudoers entry not created/updated."
fi

echo "ASUS Power Profile Monitor (with learning) installed/updated."
echo "Mapping file stored at /tmp/asus_fan_profile_map.txt"
echo "It relies on dmesg for triggering and learns the mapping using powerprofilesctl."
echo "It should start automatically on next login."
echo "To start it now (if not already running), run: /usr/local/bin/asus_fan_monitor.sh"
echo "(You might need to kill any existing instance first: pkill -f asus_fan_monitor.sh)"
