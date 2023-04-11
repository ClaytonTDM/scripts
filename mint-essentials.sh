#!/bin/bash

notify-send "Mint Essentials" "Thank you for choosing Mint Essentials. Preparing for installation..."
sudo apt-get update;
sudo apt-get upgrade -y;
sudo dpkg --add-architecture i386;
sudo apt-get install curl;

# --- Brave Browser --- #
notify-send "Mint Essentials" "Installing Brave Browser..."
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg;
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list;
sudo apt-get update;
sudo apt-get install brave-browser -y;

# --- GrapeJuice --- #
notify-send "Mint Essentials" "Brave Browser has finished installing. Installing GrapeJuice..."
curl https://gitlab.com/brinkervii/grapejuice/-/raw/master/ci_scripts/signing_keys/public_key.gpg | sudo tee /usr/share/keyrings/grapejuice-archive-keyring.gpg;
sudo tee /etc/apt/sources.list.d/grapejuice.list <<< 'deb [signed-by=/usr/share/keyrings/grapejuice-archive-keyring.gpg] https://brinkervii.gitlab.io/grapejuice/repositories/debian/ universal main';
sudo apt-get update;
sudo apt-get install grapejuice -y;

# --- Wine --- #
notify-send "Mint Essentials" "GrapeJuice has finished installing. Installing Wine..."
sudo mkdir -pm755 /etc/apt/keyrings;
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key;
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bullseye/winehq-bullseye.sources;
sudo apt-get update;
sudo apt-get install --install-recommends winehq-stable -y;

# --- QEMU --- #
notify-send "Mint Essentials" "Wine has finished installing. Installing QEMU..."
sudo apt install qemu-kvm virt-manager virtinst libvirt-clients bridge-utils libvirt-daemon-system -y;
sudo systemctl enable --now libvirtd;
sudo systemctl start libvirtd;
sudo usermod -aG kvm $USER;
sudo usermod -aG libvirt $USER;

# --- Speedtest --- #
notify-send "Mint Essentials" "QEMU has finished installing. Installing Speedtest..."
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash;
sudo apt-get install speedtest -y;

# --- Git --- #
notify-send "Mint Essentials" "Speedtest has finished installing. Installing Git..."
sudo apt-get install git -y;

# --- Spotify --- #
notify-send "Mint Essentials" "Git has finished installing. Installing Spotify..."
sudo apt-get install spotify-client -y

if [ -e /dev/.cros_milestone ]; then
  echo Chrome OS detected
  notify-send "Mint Essentials" "Spotify has finished installing. Starting cleanup..."
else
  # --- OBS Studio --- #
  notify-send "Mint Essentials" "Spotify has finished installing. Installing OBS Studio..."
  sudo add-apt-repository ppa:obsproject/obs-studio -y;
  sudo apt update;
  sudo apt install ffmpeg obs-studio -y;

  # --- VSCodium --- #
  notify-send "Mint Essentials" "OBS Studio has finished installing. Installing VSCodium..."
  sudo apt-get install codium -y;

  # --- Discord --- #
  notify-send "Mint Essentials" "VSCodium has finished installing. Installing Discord..."
  wget https://dl.discordapp.net/apps/linux/0.0.17/discord-0.0.17.deb
  sudo apt-get install ./discord-0.0.17.deb -y

  # --- Steam --- #
  notify-send "Mint Essentials" "Discord has finished installing. Installing Steam..."
  sudo apt-get install steam -y;
  
  notify-send "Mint Essentials" "Steam has finished installing. Starting cleanup..."
fi

# --- Cleanup --- #
sudo apt-get install -f;
sudo apt-get autoremove -y;
sudo rm -rf ./discord-0.0.17.deb

zenity --info --text="All programs supported on your system have been installed. Thank you for using Mint Essentials." --title="Mint Essentials"
