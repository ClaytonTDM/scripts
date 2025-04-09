#!/bin/bash

clear
echo "This script will install some apps and tools that I use on my system."
echo ""
echo "Keep an eye on the terminal - you may need to enter your password or choose some options."
echo "If asked what shell to use, choose zsh."
echo "If asked to add a repository, choose yes."
echo ""
echo "Press any key to continue..."
read -n 1 -s key

# update system
sudo apt-get update
sudo apt-get upgrade -y

# cli stuff
sudo apt-get install git gh htop zsh -y

# oh my posh
curl -s https://ohmyposh.dev/install.sh | bash -s
# create zshrc
touch ~/.zshrc
# create omp.json file
touch ~/Documents/kali-modified.omp.json
# put some stuff in it
echo '{
  "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
  "blocks": [
    {
      "type": "prompt",
      "alignment": "left",
      "segments": [
        {
          "properties": {
            "display_host": true
          },
          "template": "<{{ if .Root }}lightBlue{{ else }}green{{ end }}>\u250c\u2500\u2500(</>{{ if .Root }}\uedcf{{ else }}\uf007{{ end }} {{ .UserName }}@{{ .HostName }}<{{ if .Root }}lightBlue{{ else }}green{{ end }}>)</>",
          "foreground": "lightBlue",
          "type": "session",
          "style": "plain",
          "foreground_templates": [
            "{{ if .Root }}lightRed{{ end }}"
          ]
        },
        {
          "properties": {
            "fetch_version": false,
            "fetch_virtual_env": true
          },
          "template": "<{{ if .Root }}lightBlue{{ else }}green{{ end }}>-[</>\ue235 {{ if .Error }}{{ .Error }}{{ else }}{{ if .Venv }}{{ .Venv }}{{ end }}{{ .Full }}{{ end }}<{{ if .Root }}lightBlue{{ else }}green{{ end }}>]</>",
          "foreground": "yellow",
          "type": "python",
          "style": "plain"
        },
        {
          "properties": {
            "folder_separator_icon": "<#c0c0c0>/</>",
            "style": "full"
          },
          "template": "<{{ if .Root }}lightBlue{{ else }}green{{ end }}>-[</>{{ .Path }}<{{ if .Root }}lightBlue{{ else }}green{{ end }}>]</>",
          "foreground": "lightWhite",
          "type": "path",
          "style": "plain"
        },
        {
          "template": "<{{ if .Root }}lightBlue{{ else }}green{{ end }}>-[</>{{ .HEAD }}<{{ if .Root }}lightBlue{{ else }}green{{ end }}>]</>",
          "foreground": "white",
          "type": "git",
          "style": "plain"
        }
      ]
    },
    {
      "type": "prompt",
      "alignment": "right",
      "segments": [
        {
          "properties": {
            "always_enabled": true,
            "style": "round"
          },
          "template": " {{ .FormattedMs }} ",
          "foreground": "white",
          "type": "executiontime",
          "style": "plain"
        },
        {
          "properties": {
            "always_enabled": true
          },
          "template": " {{ if gt .Code 0 }}\uea76{{else}}\uf42e{{ end }} ",
          "foreground": "green",
          "type": "status",
          "style": "plain",
          "foreground_templates": [
            "{{ if gt .Code 0 }}red{{ end }}"
          ]
        }
      ]
    },
    {
      "type": "prompt",
      "alignment": "left",
      "segments": [
        {
          "template": "<{{ if .Root }}lightBlue{{ else }}green{{ end }}>\u2514\u2500</>{{ if .Root }}<lightRed>#</>{{ else }}${{ end }} ",
          "foreground": "lightBlue",
          "type": "text",
          "style": "plain"
        }
      ],
      "newline": true
    }
  ],
  "version": 3
}' >~/Documents/kali-modified.omp.json

# install antidote
cd ~
git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote

# add to zshrc
echo 'export PATH=$PATH:/home/clay/.local/bin
eval "$(oh-my-posh init zsh --config ~/Documents/kali-modified.omp.json)"
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
source ~/.antidote/antidote.zsh
antidote load' >~/.zshrc
touch ~/.zsh_plugins.txt
echo 'zsh-users/zsh-syntax-highlighting
zsh-users/zsh-autosuggestions' >~/.zsh_plugins.txt
# use zsh by default
chsh -s $(which zsh)
# export bin just in case
export PATH=$PATH:/home/clay/.local/bin

# node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
nvm install 22
# pnpm
curl -fsSL https://get.pnpm.io/install.sh | env PNPM_VERSION=10.0.0 sh -
# deno
curl -fsSL https://deno.land/install.sh | sh
# bun
curl -fsSL https://bun.sh/install | bash

# now graphical stuff

# deb packages
sudo apt-get install -y -m diodon audacity wine winetricks protontricks lutris steam retroarch flameshot gimp gnome-clocks dconf-editor ibus obs-studio vlc vlc-plugin-fluidsynth libonig5 libsass1 inkscape optipng fsearch zoxide power-profiles-daemon
# flatpaks
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install --user -y https://sober.vinegarhq.org/sober.flatpakref
flatpak install --user -y flathub com.usebottles.bottles com.github.tchx84.Flatseal org.prismlauncher.PrismLauncher com.vysp3r.ProtonPlus org.vinegarhq.Vinegar so.libdb.dissent com.github.neithern.g4music
# manual installs
# brave
curl -fsS https://dl.brave.com/install.sh | sh
# vscode
curl -L -o vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
sudo apt-get install ./vscode.deb -y
rm vscode.deb
# ghostty
mkdir ~/.config/ghostty
touch ~/.config/ghostty/config
echo 'theme = "Brogrammer"
font-family = "Cascadia Code NF"
background-opacity = 0.9
background-blur = true
background = "#0f0f0f"
window-width = 91
window-height = 31' >~/.config/ghostty/config
UBUNTU_VERSION=$(inxi -Sx | awk -F'Ubuntu ' '{print $2}' | awk '{print $1}' | tr -d '\n')
#source /etc/os-release
ARCH=$(dpkg --print-architecture)
GHOSTTY_DEB_URL=$(
	curl -s https://api.github.com/repos/mkasberg/ghostty-ubuntu/releases/latest |
		grep -oP "https://github.com/mkasberg/ghostty-ubuntu/releases/download/[^\s/]+/ghostty_[^\s/_]+_${ARCH}_${UBUNTU_VERSION}.deb"
)
GHOSTTY_DEB_FILE=$(basename "$GHOSTTY_DEB_URL")
curl -LO "$GHOSTTY_DEB_URL"
sudo dpkg -i "$GHOSTTY_DEB_FILE"
rm "$GHOSTTY_DEB_FILE"
# vesktop
curl -L -o vesktop.deb "https://github.com/Vencord/Vesktop/releases/download/v1.5.4/vesktop_1.5.4_amd64.deb"
sudo apt-get install ./vesktop.deb -y
rm vesktop.deb
# zen browser
bash <(curl -s https://updates.zen-browser.app/install.sh)

# install fonts
cd ~/
# inter
curl -L -o inter.zip "https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip"
unzip inter.zip -d inter
mkdir ~/.fonts
mv inter/Inter.ttc ~/.fonts
rm -rf inter inter.zip
# cascadia code
curl -L -o cascadia.zip "https://github.com/microsoft/cascadia-code/releases/download/v2407.24/CascadiaCode-2407.24.zip"
unzip cascadia.zip -d cascadia
mv cascadia/ttf/*.ttf ~/.fonts
rm -rf cascadia cascadia.zip
fc-cache -fv

# install colloid gtk theme
mkdir ~/Desktop/DEV # dont delete this folder
cd ~/Desktop/DEV
git clone https://github.com/vinceliuice/Colloid-gtk-theme.git
cd Colloid-gtk-theme
sudo chmod +x install.sh
./install.sh -t pink -c dark --tweaks black rimless -l

# generate icons
cd ~/Desktop/DEV
git clone https://github.com/linuxmint/mint-y-icons.git
cd mint-y-icons/usr/share/folder-color-switcher/colors.d
curl https://raw.githubusercontent.com/ClaytonTDM/scripts/refs/heads/main/assets/Mint-Y.json -o Mint-Y.json
cd ~/Desktop/DEV/mint-y-icons/src/places
curl https://raw.githubusercontent.com/ClaytonTDM/scripts/refs/heads/main/assets/generate-color-variations.py -o generate-color-variations.py
./generate-color-variations.py
./render_places.py Colloid-Pink
cd ~/Desktop/DEV/mint-y-icons/usr
sudo cp -rf ./share/* /usr/share/

# update system again
sudo apt-get update
sudo apt-get upgrade -y

# set default apps
xdg-settings set default-web-browser app.zen_browser.zen.desktop
gsettings set org.cinnamon.desktop.default-applications.terminal exec ghostty
sudo update-alternatives --set x-terminal-emulator /usr/bin/ghostty
# set default fonts
gsettings set org.cinnamon.desktop.interface font-name 'Inter 10'
gsettings set org.nemo.desktop font 'Inter 10'
gsettings set org.gnome.desktop.interface document-font-name 'Inter 10'
gsettings set org.gnome.desktop.interface monospace-font-name 'Cascadia Mono 10'
gsettings set org.cinnamon.desktop.wm.preferences titlebar-font 'Inter Medium 10'
# set gtk theme
gsettings set org.cinnamon.desktop.interface gtk-theme 'Colloid-Pink-Dark'
# set icon theme
gsettings set org.cinnamon.desktop.interface icon-theme 'Mint-Y-Colloid-Pink'
# set mouse pointer
gsettings set org.cinnamon.desktop.interface cursor-theme 'Bibata-Modern-Classic'
# set cinnamon theme
gsettings set org.cinnamon.theme name 'Colloid-Pink-Dark'

# restart cinnamon
cinnamon -r >/dev/null 2>&1 &

# show popup
zenity --list \
--title="Installation Complete" \
--width=400 \
--height=300 \
--text="You may notice some issues like the terminal font being\nwonky - these issues can be fixed by rebooting your system.\n\nThe following apps were installed:" \
--column="Installed Applications" \
--ok-label="Close" \
--hide-header \
"Git" \
"GitHub CLI" \
"HTOP" \
"Z Shell" \
"Oh My Posh" \
"Antidote" \
"Node Version Manager" \
"Node.js" \
"PNPM" \
"Deno" \
"Bun" \
"Diodon" \
"Audacity" \
"Wine" \
"Winetricks" \
"Protontricks" \
"Lutris" \
"Steam" \
"RetroArch" \
"Flameshot" \
"GNU Image Manipulation Program" \
"GNOME Camera" \
"GNOME Clocks" \
"DConf Editor" \
"Intelligent Input Bus" \
"Open Broadcaster Software Studio" \
"VideoLAN Client" \
"VideoLAN Client FluidSynth Plugin" \
"Sober" \
"Bottles" \
"Flatseal" \
"FSearch" \
"PrismLauncher" \
"ProtonPlus" \
"Vinegar" \
"Zen Browser" \
"Gapless" \
"Visual Studio Code" \
"Brave Browser" \
"Ghostty" \
"Vesktop" \
"Zoxide" \
"Inkscape" \
"Inter Font" \
"Cascadia Code Font" \
"Colloid Pink Dark GTK Theme" \
"Colloid Pink Dark Cinnamon Theme" \
"Colloid Pink Mint Y Icon Theme"
