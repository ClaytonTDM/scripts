#!/bin/bash
clear
ans=$(zenity --list --text="This tool is licensed under the MIT License.\n\nThis tool is provided as-is without any warranty\nor guarantee of any kind, whether express or implied.\nThe user assumes all risks associated with the use of this tool.\n\nThe developer of this tool shall not be liable for any damages\nor losses of any kind arising from the use or inability to use this\ntool, including but not limited to direct, indirect, incidental,\npunitive, and consequential damages." --radiolist --column="" --column="" --title="Ubuntu Essentials - Agreement" TRUE Agree FALSE Disagree);
if [ "$ans" == "Agree" ]; then
function askPassword {
  if [ $(sudo -n uptime 2>&1 | grep "load" | wc -l) != "1" ]; then
    echo $(zenity --password --title="Enter superuser password") | sudo -S echo authenticated > /dev/null && echo
  fi
  if [ $(sudo -n uptime 2>&1 | grep "load" | wc -l) != "1" ]; then
    zenity --error --text="Incorrect or no password provided"
    askPassword
  fi
}
askPassword
sudo apt-get install xdotool -y > /dev/null
xdotool windowminimize $(xdotool getactivewindow)
(
cd ~/
rm -rf ~/*.deb.* && rm -rf ~/*.deb
# =================================================================

echo "# Installing Brave...\n1/10"
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg;
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list;
sudo apt-get update > /dev/null;
sudo apt-get install brave-browser -y > /dev/null;

# =================================================================

echo "# Installing GrapeJuice...\n2/10"
curl -s https://gitlab.com/brinkervii/grapejuice/-/raw/master/ci_scripts/signing_keys/public_key.gpg | sudo tee /usr/share/keyrings/grapejuice-archive-keyring.gpg  > /dev/null;
sudo tee /etc/apt/sources.list.d/grapejuice.list <<< 'deb [signed-by=/usr/share/keyrings/grapejuice-archive-keyring.gpg] https://brinkervii.gitlab.io/grapejuice/repositories/debian/ universal main';
sudo apt-get update > /dev/null;
sudo apt-get install grapejuice -y > /dev/null;

# =================================================================

echo "# Installing Wine...\n3/10"
sudo mkdir -pm755 /etc/apt/keyrings > /dev/null;
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key > /dev/null;
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bullseye/winehq-bullseye.sources > /dev/null;
sudo apt-get autoremove > /dev/null;
sudo apt-get install -f;
sudo apt-get update > /dev/null;
sudo apt-get install --install-recommends winehq-stable -y > /dev/null;

# =================================================================

echo "# Installing QEMU...\n4/10"
sudo apt-get update > /dev/null;
sudo apt install qemu-kvm virt-manager virtinst libvirt-clients bridge-utils libvirt-daemon-system -y > /dev/null;
sudo systemctl enable --now libvirtd > /dev/null;
sudo systemctl start libvirtd > /dev/null;
sudo usermod -aG kvm $USER > /dev/null;
sudo usermod -aG libvirt $USER > /dev/null;

# =================================================================

echo "# Installing Git...\n5/10"
sudo apt-get update > /dev/null;
sudo apt-get install git -y > /dev/null;

# =================================================================

echo "# Installing Spotify...\n6/10"
curl -sS https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt-get update > /dev/null;
sudo apt-get install spotify-client -y > /dev/null;

# =================================================================

echo "# Installing OBS Studio...\n7/10"
sudo add-apt-repository ppa:obsproject/obs-studio -y > /dev/null;
sudo apt update > /dev/null;
sudo apt install ffmpeg obs-studio -y > /dev/null;

# =================================================================

echo "# Installing Discord...\n8/10"
wget https://dl.discordapp.net/apps/linux/0.0.26/discord-0.0.26.deb > /dev/null;
sudo apt-get update > /dev/null;
sudo apt-get install ./discord-0.0.26.deb -y > /dev/null;

# =================================================================

echo "# Installing Steam...\n9/10"
wget https://cdn.akamai.steamstatic.com/client/installer/steam.deb > /dev/null;
sudo apt-get update > /dev/null;
sudo apt-get install libc6-i386;
sudo apt-get install ./steam.deb -y > /dev/null;

# =================================================================

# echo "# Installing VSCodium...\n10/10"
# curl -s https://api.github.com/repos/VSCodium/vscodium/releases/latest -o codium.deb | jq '.assets[] | select(.name|match("amd64.deb$")) | .browser_download_url'
# sudo apt-get update > /dev/null;
# sudo apt-get install ./codium.deb -y > /dev/null;

# =================================================================

echo "# Cleaning Up..."
sudo rm -rf ./discord-*.deb;
sudo rm -rf ./codium.deb;
sudo rm -rf ./steam.deb;
sudo rm -rf ./discord-*.deb.*;
# sudo rm -rf ./codium.deb.*;
sudo rm -rf ./steam.deb.*;
sudo apt-get install -f > /dev/null;
sudo apt-get autoremove -y > /dev/null;

# =================================================================


) |
zenity --progress --title="Ubuntu Essentials" --text="Preparing..." --pulsate --auto-close --auto-kill

(( $? != 0 )) && zenity --error --text="An error has occurred."
notify-send "Ubuntu Essentials" "All applications supported by your system have been installed."
zenity --info --text="All applications supported by your system have been installed. This tool will now exit." --title="Ubuntu Essentials"
exit
else
exit
fi
