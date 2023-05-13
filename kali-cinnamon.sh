#!/bin/bash
clear
ans=$(zenity --list --text="This tool is licensed under the Eclipse Public License 2.0.\n\nThis tool is provided as-is without any warranty\nor guarantee of any kind, whether express or implied.\nThe user assumes all risks associated with the use of this tool.\n\nThe developer of this tool shall not be liable for any damages\nor losses of any kind arising from the use or inability to use this\ntool, including but not limited to direct, indirect, incidental,\npunitive, and consequential damages." --radiolist --column="" --column="" --title="Kali Cinnamon - Agreement" TRUE Agree FALSE Disagree);
if [ "$ans" == "Agree" ]; then
function askPassword {
  if [ $(sudo -n uptime 2>&1 | grep "load" | wc -l) != "1" ]; then
    echo $(zenity --password --title="Enter superuser password") | sudo -S echo
  fi
  if [ $(sudo -n uptime 2>&1 | grep "load" | wc -l) != "1" ]; then
    zenity --error --text="Incorrect or no password provided"
    askPassword
  fi
}
askPassword
(
echo "# Adding repositories..."
sudo rm -rf /etc/apt/sources.list.d/kalicinnamon.list
sudo bash -c "echo deb [trusted=yes] http://packages.linuxmint.com cindy main > /etc/apt/sources.list.d/kalicinnamon.list"
echo "# Updating package lists..."
sudo apt-get update
echo "# Installing Cinnamon..."
sudo apt-get install kali-defaults kali-root-login desktop-base cinnamon mint-x-icons mint-y-icons mint-themes bibata-cursor-theme -y
clear
echo "# Exiting..."
) |
zenity --progress --title="Kali Cinnamon" --text="Preparing..." --pulsate --auto-close --auto-kill
clear
zenity --info --text="To switch to Cinnamon, select \"/usr/bin/cinnamon-session\" (usually selection 1) in the terminal after pressing OK." --title="Kali Cinnamon"
sudo update-alternatives --config x-session-manager
clear
zenity --info --text="Thank you for using Kali Cinnamon. To finish installation, Kali Cinnamon will now reboot your computer." --title="Kali Cinnamon"
sudo reboot
fi
