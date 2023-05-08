#!/bin/bash
clear
ans=$(zenity --list --text="This script is licensed under the Eclipse Public License 2.0.\n\nThis script is provided as-is without any warranty\nor guarantee of any kind, whether express or implied.\nThe user assumes all risks associated with the use of this script.\n\nThe developer of this script shall not be liable for any damages\nor losses of any kind arising from the use or inability to use this\nscript, including but not limited to direct, indirect, incidental,\npunitive, and consequential damages." --radiolist --column="" --column="" --title="Ubuntu Essentials - Agreement" TRUE Agree FALSE Disagree);
if [ "$ans" == "Agree" ]; then
(
function askPassword {
  if [ $(sudo -n uptime 2>&1 | grep "load" | wc -l) == "1" ]; then
    echo has sudo
    else
    echo $(zenity --password --title="Enter sudo password") | sudo -S echo sudo authenticated
  fi

  if [ $(sudo -n uptime 2>&1 | grep "load" | wc -l) != "1" ]; then
    zenity --error --text="Incorrect or no password provided"
    askPassword
  fi
}
askPassword
clear
cd ~/
# =================================================================
echo "# Installing Brave Browser..."
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg;
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list;
sudo apt-get update > /dev/null;
sudo apt-get install brave-browser -y > /dev/null;

# =================================================================
echo "8.33"
echo "# Installing GrapeJuice..."
curl -s https://gitlab.com/brinkervii/grapejuice/-/raw/master/ci_scripts/signing_keys/public_key.gpg | sudo tee /usr/share/keyrings/grapejuice-archive-keyring.gpg  > /dev/null;
sudo tee /etc/apt/sources.list.d/grapejuice.list <<< 'deb [signed-by=/usr/share/keyrings/grapejuice-archive-keyring.gpg] https://brinkervii.gitlab.io/grapejuice/repositories/debian/ universal main';
sudo apt-get update > /dev/null;
sudo apt-get install grapejuice -y > /dev/null;

# =================================================================
echo "16.67"
echo "# Installing Wine..."
sudo mkdir -pm755 /etc/apt/keyrings > /dev/null;
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key > /dev/null;
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bullseye/winehq-bullseye.sources > /dev/null;
sudo apt-get autoremove > /dev/null;
sudo apt-get install -f;
sudo apt-get update > /dev/null;
sudo apt-get install --install-recommends winehq-stable -y > /dev/null;

# =================================================================
echo "25"
echo "# Installing QEMU..."
sudo apt-get update > /dev/null;
sudo apt install qemu-kvm virt-manager virtinst libvirt-clients bridge-utils libvirt-daemon-system -y > /dev/null;
sudo systemctl enable --now libvirtd > /dev/null;
sudo systemctl start libvirtd > /dev/null;
sudo usermod -aG kvm $USER > /dev/null;
sudo usermod -aG libvirt $USER > /dev/null;

# =================================================================
echo "33.33"
echo "# Installing Git..."
sudo apt-get update > /dev/null;
sudo apt-get install git -y > /dev/null;

# =================================================================
echo "50"
echo "# Installing Spotify..."
curl -sS https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt-get update > /dev/null;
sudo apt-get install spotify-client -y > /dev/null;

# =================================================================
echo "58.33"
echo "# Installing OBS Studio..."
sudo add-apt-repository ppa:obsproject/obs-studio -y > /dev/null;
sudo apt update > /dev/null;
sudo apt install ffmpeg obs-studio -y > /dev/null;

# =================================================================
echo "66.7"
echo "# Installing Discord..."
wget https://dl.discordapp.net/apps/linux/0.0.26/discord-0.0.26.deb > /dev/null;
sudo apt-get update > /dev/null;
sudo apt-get install ./discord-0.0.26.deb -y > /dev/null;

# =================================================================
echo "75"
echo "# Installing Steam..."
wget https://cdn.akamai.steamstatic.com/client/installer/steam.deb > /dev/null;
sudo apt-get update > /dev/null;
sudo apt-get install libc6-i386;
sudo apt-get install ./steam.deb -y > /dev/null;

# =================================================================
echo "83.33"
echo "# Installing VSCodium..."
curl -s https://api.github.com/repos/VSCodium/vscodium/releases/latest -o codium.deb | jq '.assets[] | select(.name|match("amd64.deb$")) | .browser_download_url'
sudo apt-get update > /dev/null;
sudo apt-get install ./codium.deb -y > /dev/null;

# =================================================================
echo "91.67"
echo "# Cleaning Up..."
sudo rm -rf ./discord-0.0.26.deb;
sudo rm -rf ./codium.deb;
sudo rm -rf ./steam.deb;
echo "93.67"
echo "# Almost Done..."
sudo apt-get install -f > /dev/null;
sudo apt-get autoremove -y > /dev/null;

# =================================================================

echo "100"
) |
zenity --progress --title="Ubuntu Essentials" --text="Preparing..." --percentage=0 --auto-close --auto-kill --no-cancel

(( $? != 0 )) && zenity --error --text="An error has occurred."
zenity --info --text="All programs supported by your system have been installed. Thank you for using Ubuntu Essentials." --title="Ubuntu Essentials"
fi
