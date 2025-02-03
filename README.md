## install.sh

Installs the tools and customizations I use daily. Intended for a fresh Linux Mint install running Cinnamon, last tested on Mint 22.1 Xia

```sh
curl https://raw.githubusercontent.com/ClaytonTDM/scripts/main/install.sh | bash
```

---

> [!WARNING]
> I no longer use the below scripts, and they might be broken - proceed with caution

## Kali Cinnamon

Very simple script to install the Cinnamon desktop environment on Kali Linux, along with the default cursors, icons, & themes.
```sh
curl https://raw.githubusercontent.com/ClaytonTDM/scripts/main/kali-cinnamon.sh | bash
```
## Ubuntu Essentials
Most of the apps me and many others use daily, now in a convenient bash script.
```sh
curl https://raw.githubusercontent.com/ClaytonTDM/scripts/main/ubuntu-essentials.sh | bash
```

## Windows Essentials
Same as Ubuntu Essentials, but for Windows 10 (1809+) and Windows 11.
To execute this, copy the command, then paste it in `cmd.exe`.
```cmd
curl https://raw.githubusercontent.com/ClaytonTDM/scripts/main/windows-essentials.bat -o windows-essentials.bat
windows-essentials.bat
del windows-essentials.bat
```
