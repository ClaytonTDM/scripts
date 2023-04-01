#!/bin/bash
sudo apt-get update;
sudo apt-get upgrade -y;
sudo dpkg --add-architecture i386;
sudo apt-get install curl;

# --- Brave Browser --- #
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg;
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list;
sudo apt-get update;
sudo apt-get install brave-browser -y;

# --- Steam --- #
sudo apt-get install steam -y;

# --- GrapeJuice --- #
curl https://gitlab.com/brinkervii/grapejuice/-/raw/master/ci_scripts/signing_keys/public_key.gpg | sudo tee /usr/share/keyrings/grapejuice-archive-keyring.gpg;
sudo tee /etc/apt/sources.list.d/grapejuice.list <<< 'deb [signed-by=/usr/share/keyrings/grapejuice-archive-keyring.gpg] https://brinkervii.gitlab.io/grapejuice/repositories/debian/ universal main';
sudo apt-get update;
sudo apt-get install grapejuice -y;

# --- VSCodium --- #
sudo apt-get install codium -y;

# --- Wine --- #
sudo mkdir -pm755 /etc/apt/keyrings;
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key;
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bullseye/winehq-bullseye.sources;
sudo apt-get update;
sudo apt-get install --install-recommends winehq-stable -y;

# --- Discord --- #
sudo apt-get install discord -y;

# --- OBS Studio --- #
sudo add-apt-repository ppa:obsproject/obs-studio -y;
sudo apt update;
sudo apt install ffmpeg obs-studio -y;

# --- QEMU --- #
sudo apt install qemu-kvm virt-manager virtinst libvirt-clients bridge-utils libvirt-daemon-system -y;
sudo systemctl enable --now libvirtd;
sudo systemctl start libvirtd;
sudo usermod -aG kvm $USER;
sudo usermod -aG libvirt $USER;

# --- Speedtest --- 
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash;
sudo apt-get install speedtest -y;

# --- Cleanup --- #
sudo apt-get install -f;
sudo apt-get autoremove -y;
