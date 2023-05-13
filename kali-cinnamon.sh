#!/bin/bash
sudo rm -rf /etc/apt/sources.list.d/kalicinnamon.list
sudo bash -c "echo deb [trusted=yes] http://packages.linuxmint.com cindy main > /etc/apt/sources.list.d/kalicinnamon.list"
sudo apt update
sudo apt install kali-defaults kali-root-login desktop-base cinnamon mint-x-icons mint-y-icons mint-themes bibata-cursor-theme -y
zenity --info \
--text="To switch to Cinnamon, select \"/usr/bin/cinnamon-session\" (usually selection 1) in the next step."
clear
sudo update-alternatives --config x-session-manager
