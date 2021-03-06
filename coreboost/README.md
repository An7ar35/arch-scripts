# Coreboost

Coreboost consists of:
1. A shell script file that enables/disables the CPU's turbo boost functionality,
2. A `systemd` service file that runs the script on startup and suspend resume,
3. Installer and uninstaller scripts.

#### Installing

To install run the installer script, `sudo install.sh`, from the `coreboost/` directory.

On install Turbo Boost will be disabled.

#### Usage

Run `coreboost` from the console.

    Options:
      -e  Enable Turbo Boost
      -d  Disable Turbo Boost
      -h  Usage help.
      -s  Prints the TurboBoost status of all the cores.

#### Uninstalling

Just run the uninstaller script, `sudo uninstall.sh`, from the `coreboost/` directory.

Turbo Boost will be re-enabled again.

#### Dependencies

Requires [MSR tools](https://01.org/msr-tools). In Arch it can be installed with
`yaourt -S msr-tools` from the AUR repositories 
(if you have [Yaourt](https://github.com/archlinuxfr/yaourt)).

On other distros you'll have to look for it.