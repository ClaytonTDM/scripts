@echo off

cls
rem # --- Discord --- #
winget install discord.discord --accept-package-agreements --accept-source-agreements

cls
rem # --- Git For Windows --- #
winget install git.git --accept-package-agreements --accept-source-agreements

cls
rem # --- VSCodium --- #
winget install vscodium.vscodium --accept-package-agreements --accept-source-agreements

cls
rem # --- Brave --- #
winget install brave.brave --accept-package-agreements --accept-source-agreements

cls
rem # --- OBS Studio --- #
winget install obsproject.obsstudio --accept-package-agreements --accept-source-agreements

cls
rem # --- Steam --- #
winget install valve.steam --accept-package-agreements --accept-source-agreements

cls
rem # --- Prism Launcher [Minecraft] --- #
winget install prismlauncher.prismlauncher --accept-package-agreements --accept-source-agreements

cls
echo Finished.
