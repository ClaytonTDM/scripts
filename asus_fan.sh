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
        message = f"Profile: {profile_name.capitalize()}"
        icon = "dialog-question-symbolic"

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
                        pass
    except Exception:
        pass

    notification.show()

    try:
        GLib.timeout_add(100, lambda: save_notification_id(notification))
    except Exception:
        pass

def save_notification_id(notification):
    try:
        notification_id = notification.get_property("id")
        if notification_id > 0:
            with open(ID_FILE, 'w') as f:
                f.write(str(notification_id))
    except Exception:
        pass
    return False

if len(sys.argv) > 1:
    profile_arg = sys.argv[1]
else:
    profile_arg = "unknown"

loop = GLib.MainLoop()
send_notification(profile_arg)
GLib.timeout_add(500, loop.quit)

try:
    loop.run()
except KeyboardInterrupt:
    pass

EOF

chmod +x /usr/local/bin/asus_fan_notify.py
if [ "$(id -u)" = "0" ] && [ -n "$(logname 2>/dev/null)" ]; then
    chown $(logname):$(logname) /usr/local/bin/asus_fan_notify.py
fi


cat > /usr/local/bin/asus_fan_monitor.sh << 'EOF'
#!/bin/bash

MAP_FILE="/tmp/asus_fan_profile_map.txt"
touch "$MAP_FILE"

PROFILES=("power-saver" "balanced" "performance")
NUM_PROFILES=${#PROFILES[@]}

get_mapped_profile() {
    local mode="$1"
    grep "^${mode}=" "$MAP_FILE" | cut -d'=' -f2
}

get_user_session() {
    local display_user=$(who | grep -E '\(:[0-9.]+\)' | head -n 1 | awk '{print $1}')
    local session_pid=""
    local dbus_address=""

    if [ -z "$display_user" ]; then
        local session_info=$(loginctl list-sessions --no-legend | grep ' active=yes.* type=\(x11\|wayland\)' | head -n 1)
        if [ -n "$session_info" ]; then
            local session_id=$(echo "$session_info" | awk '{print $1}')
            display_user=$(echo "$session_info" | awk '{print $3}')
            session_pid=$(loginctl show-session "$session_id" -p Leader | cut -d= -f2)
        fi
    fi

    if [ -n "$display_user" ]; then
        local user_id=$(id -u "$display_user")
        if [ -z "$session_pid" ]; then
             session_pid=$(pgrep -u "$user_id" -n "(gnome-session|plasma_session|xfce4-session|cinnamon-session|startlxqt|mate-session)")
        fi

        if [ -n "$session_pid" ]; then
             dbus_address=$(grep -z DBUS_SESSION_BUS_ADDRESS "/proc/$session_pid/environ" 2>/dev/null | cut -d= -f2-)
        fi

        if [ -n "$dbus_address" ]; then
             echo "$display_user $dbus_address"
             return 0
        fi
    fi
    echo ""
    return 1
}

run_notify() {
    local profile_name="$1"
    local user_session_info=$(get_user_session)

    if [ -n "$user_session_info" ]; then
        read -r current_user dbus_address <<< "$user_session_info"
        sudo -u "$current_user" DBUS_SESSION_BUS_ADDRESS="$dbus_address" /usr/local/bin/asus_fan_notify.py "$profile_name" &>/dev/null &
    else
        echo "Warning: Could not determine active user session for notifications."
    fi
}

sudo dmesg -c > /dev/null
echo "Monitoring dmesg for fan mode changes. Will learn mapping once."

stdbuf -oL sudo dmesg -w | grep --line-buffered -E 'asus_wmi: Set fan boost mode:' | while read -r line; do
    dmesg_mode=$(echo "$line" | grep -o "Set fan boost mode: [0-2]" | awk '{print $5}')

    if [[ "$dmesg_mode" =~ ^[0-2]$ ]]; then
        map_count=$(grep -c '=' "$MAP_FILE")

        if [ "$map_count" -eq ${NUM_PROFILES} ]; then
            mapped_profile=$(get_mapped_profile "$dmesg_mode")
            if [ -n "$mapped_profile" ]; then
                run_notify "$mapped_profile"
            fi
        else
            mapped_profile=$(get_mapped_profile "$dmesg_mode")
            if [ -n "$mapped_profile" ]; then
                 run_notify "$mapped_profile"
            else
                 echo "Learning profile mappings from dmesg mode: $dmesg_mode..."
                 sleep 3
                 actual_profile=$(powerprofilesctl get)

                 if [ -n "$actual_profile" ] && [[ " ${PROFILES[@]} " =~ " ${actual_profile} " ]]; then
                     echo "Learned: dmesg mode $dmesg_mode corresponds to profile '$actual_profile'."

                     learned_profile_index=-1
                     for i in "${!PROFILES[@]}"; do
                        if [[ "${PROFILES[$i]}" = "$actual_profile" ]]; then
                            learned_profile_index=$i
                            break
                        fi
                     done

                     if [ "$learned_profile_index" -ne -1 ]; then
                         > "$MAP_FILE"
                         for i in 0 1 2; do
                             offset=$(( (i - dmesg_mode + NUM_PROFILES) % NUM_PROFILES ))
                             profile_index=$(( (learned_profile_index + offset) % NUM_PROFILES ))
                             profile_name=${PROFILES[$profile_index]}
                             echo "${i}=${profile_name}" >> "$MAP_FILE"
                         done
                         echo "All mappings learned and stored in $MAP_FILE."
                         run_notify "$actual_profile"
                     else
                          echo "Error: Could not find index for learned profile '$actual_profile'."
                     fi
                 else
                     echo "Warning: Could not determine actual power profile after delay. Cannot learn mappings."
                 fi
            fi
        fi
    else
         echo "Warning: Could not extract valid mode number from dmesg line: $line"
    fi
done
EOF

chmod +x /usr/local/bin/asus_fan_monitor.sh

ACTIVE_USER=""
if [ -n "$(logname 2>/dev/null)" ]; then
    ACTIVE_USER=$(logname)
elif [ -n "$SUDO_USER" ]; then
    ACTIVE_USER="$SUDO_USER"
else
    # Attempt to find user from 'who' as a last resort for sudoers file
    ACTIVE_USER=$(who | grep -E '\(:[0-9.]+\)' | head -n 1 | awk '{print $1}')
fi


if [ -n "$ACTIVE_USER" ]; then
    AUTODIR="/home/$ACTIVE_USER/.config/autostart/"
    mkdir -p "$AUTODIR"
    cat > "$AUTODIR/asus-fan-monitor.desktop" << EOF
[Desktop Entry]
Type=Application
Name=ASUS Power Profile Monitor
Comment=Monitor ASUS power profile changes via dmesg trigger (smart learning)
Exec=/usr/local/bin/asus_fan_monitor.sh
Terminal=false
Hidden=false
X-GNOME-Autostart-enabled=true
EOF
    if [ "$(id -u)" = "0" ]; then
        chown -R $ACTIVE_USER:$ACTIVE_USER "$AUTODIR"
    fi

    SUDOERS_FILE="/etc/sudoers.d/asus-fan-monitor"
    echo "# Allow running dmesg without password for ASUS power profile monitoring" > "$SUDOERS_FILE"
    echo "$ACTIVE_USER ALL=(ALL) NOPASSWD: /bin/dmesg" >> "$SUDOERS_FILE"
    chmod 440 "$SUDOERS_FILE"
    echo "ASUS Power Profile Monitor (smart learning) installed/updated for user $ACTIVE_USER."
    echo "Mapping file stored at /tmp/asus_fan_profile_map.txt"
    echo "It relies on dmesg for triggering and learns the mapping once using powerprofilesctl."
    echo "It should start automatically on next login."
    echo "To start it now (if not already running), run: /usr/local/bin/asus_fan_monitor.sh"
    echo "(You might need to kill any existing instance first: pkill -f asus_fan_monitor.sh)"
else
    echo "Error: Could not determine user for Autostart and Sudoers configuration. Please configure manually."
fi

