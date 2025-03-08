## install.sh

Installs the tools and customizations I use daily. Intended for a fresh Linux Mint install running Cinnamon.

```sh
curl https://raw.githubusercontent.com/ClaytonTDM/scripts/main/install.sh -o install.sh && sudo chmod +x ./install.sh && ./install.sh && sudo rm -rf ./install.sh
```

Last tested on Linux Mint 22.1 Cinnamon

## asus_fan.sh

**Only intended for ASUS laptops with `asus_wmi` firmware.** Installs a script to send a notification every time the fan boost mode is changed.

```sh
curl https://raw.githubusercontent.com/ClaytonTDM/scripts/main/asus_fan.sh -o asus_fan.sh && sudo bash ./asus_fan.sh && rm -rf ./asus_fan.sh
```

Last tested on Linux Mint 22.1 Cinnamon

## asus_fan_uninstall.sh

Uninstalls the above script.

```sh
curl https://raw.githubusercontent.com/ClaytonTDM/scripts/main/asus_fan_uninstall.sh -o asus_fan_uninstall.sh && sudo bash ./asus_fan_uninstall.sh && rm -rf ./asus_fan_uninstall.sh
```

Last tested on Linux Mint 22.1 Cinnamon

---

> [!WARNING]
> The below scripts have been unmaintained for years and are likely useless & broken. Proceed with caution

<details>
  <summary>Click me</summary>

  ## Kali Cinnamon

  Very simple script to install the Cinnamon desktop environment on Kali Linux, along with the default cursors, icons, & themes.
  
  ```sh
  curl https://raw.githubusercontent.com/ClaytonTDM/scripts/main/kali-cinnamon.sh | bash
  ```

  Last tested on Kali Linux 2023.4

  ## Ubuntu Essentials

  Most of the apps me and many others use daily, now in a convenient bash script.

  ```sh
  curl https://raw.githubusercontent.com/ClaytonTDM/scripts/main/ubuntu-essentials.sh | bash
  ```

  Last tested on Linux Mint 21.1 Cinnamon

  ## Windows Essentials

  Same as Ubuntu Essentials, but for Windows 10 (1809+) and Windows 11.

  To execute this, copy the command, then paste it in `cmd.exe`.

  ```cmd
  curl https://raw.githubusercontent.com/ClaytonTDM/scripts/main/windows-essentials.bat -o windows-essentials.bat
  windows-essentials.bat
  del windows-essentials.bat
  ```

  Last tested on Windows 11 22H2

</details>
