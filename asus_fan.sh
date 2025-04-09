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
Notify.init("ASUS Fan Monitor")

def send_notification(mode):
    mode = int(mode)

    if mode == 1:
        message = "Power Saver"
        icon = "power-profile-power-saver-symbolic"
    elif mode == 2:
        message = "Balanced"
        icon = "power-profile-balanced-symbolic"
    elif mode == 0:
        message = "Performance"
        icon = "power-profile-performance-symbolic"
    else:
        message = f"Unknown Mode: {mode}"
        icon = "dialog-question-symbolic"

    notification = Notify.Notification.new("Fan Boost", message, icon)

    try:
        os.system("killall -SIGUSR1 notification-daemon 2>/dev/null")
        os.system("killall -SIGUSR1 notify-osd 2>/dev/null")

        if os.path.exists(ID_FILE):
            with open(ID_FILE, 'r') as f:
                old_id = f.read().strip()
                if old_id:
                    try:
                        old_notification = Notify.Notification.new("", "", "")
                        old_notification.set_property("id", int(old_id))
                        old_notification.close()
                    except:
                        pass
    except:
        pass

    notification.show()

    try:
        notification_id = notification.get_property("id")
        with open(ID_FILE, 'w') as f:
            f.write(str(notification_id))
    except:
        pass

if len(sys.argv) > 1:
    send_notification(sys.argv[1])
    time.sleep(0.5)
EOF

chmod +x /usr/local/bin/asus_fan_notify.py

cat > /usr/local/bin/asus_fan_monitor.sh << EOF
#!/bin/bash
sudo dmesg -c > /dev/null
sudo dmesg -w | grep -E 'asus_wmi: Set fan boost mode:' --line-buffered | while read -r line; do
    mode=\$(echo "\$line" | grep -o "Set fan boost mode: [0-2]" | awk '{print \$5}')
    /usr/local/bin/asus_fan_notify.py "\$mode"
done
EOF

chmod +x /usr/local/bin/asus_fan_monitor.sh

mkdir -p /home/$(logname)/.config/autostart/

cat > /home/$(logname)/.config/autostart/asus-fan-monitor.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=ASUS Fan Monitor
Comment=Monitor ASUS fan boost mode changes
Exec=/usr/local/bin/asus_fan_monitor.sh
Terminal=false
Hidden=false
X-GNOME-Autostart-enabled=true
EOF

chown -R $(logname):$(logname) /home/$(logname)/.config/autostart/
chown $(logname):$(logname) /usr/local/bin/asus_fan_notify.py

cat > /etc/sudoers.d/asus-fan-monitor << EOF
# Allow running dmesg without password for ASUS fan monitoring
$(logname) ALL=(ALL) NOPASSWD: /bin/dmesg
EOF

chmod 440 /etc/sudoers.d/asus-fan-monitor

echo "ASUS Fan Monitor installed. It will start automatically on next login."
echo "To start it now, run: /usr/local/bin/asus_fan_monitor.sh"
