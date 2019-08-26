# NVIDIA GPU Fan Speed `nvfan`

This is a script adapted from Artem S. Tashkinov's own and awesome adaptive fan speed management 
for NVIDIA GPUs on Linux script.

I've kept the update loop for the most part with a few tweak and added:
1) An aggressive default temperature/fan speed profile, 
2) External per-user configuration loading (.conf),
3) Background process handling (kill/reset),
4) Manual override of fan speed (be careful with that one),
5) Installer/Uninstaller and global symbolic link to the script.

This works well for keeping your GFX card cool when playing games or doing other GPU intensive 
tasks on Linux.

#### Installing

To install run the installer script, `sudo install.sh`, from the `nvfan/` repository directory.

The script will be installed in `/opt/nvfan/` and a symbolic link will be created in `usr/bin/` 
so that, assuming your system has `/usr/bin/` in its `$PATH` environment, `nvfan` can be run from
anywhere. 

If you wish to have it run at startup, add an auto-start entry to your desktop environment.

#### Uninstalling

Just run the uninstaller script, `sudo uninstall.sh`, from the `nvfan/` repository directory.

#### Usage

Run `nvfan` from the console.

    Options:
       -a  Start the automatic fan speed controller process based on the presets (will kill old 
           processes and reloads 'nvfan.conf' if it was running previously).
       -h  Usage help.
       -s  Manually set speed of fan <% fan speed>. Kills the auto fan speed process.
       -r  Kills the fan controller process and resets to NVIDIA's own fan management.

#### Settings

Settings can be configured in the `~/.config/nvfan/nvfan.conf` file.

Logging to `journalctl` can be switched on with:
> `Log=1`

Polling time can be changed with: `PollingTime=t` where `t` is the refresh rate in seconds. 
For example: 
> `Refresh=2`

Fan speeds on temperature ranges can be set as such: `Speed=s [f-c]` where `s` is the % speed of the 
fan at temperature range from `f` to `c`°C. For example:
> ```
> Speed=0 [0-29]  
> Speed=50 [30-40]  
> Speed=70 [41-50]  
> Speed=85 [51-58]  
> Speed=100 [59-200]
> ```

_With bad settings you can fry your card so be careful and always keep an eye
on your GPU temps (desktop monitor with warnings/critical temp. shutdown safety 
is a good idea)._

#### Dependencies

Currently only support the proprietary NVIDIA linux driver (with `nvidia-settings`).

If the script doesn't work you might need to enable fan speeds in the nvidia app by doing the following in the console and then restarting:
```
    sudo nvidia-xconfig
    sudo nvidia-xconfig --cool-bits=4
```
 
At some point when I get some time I might add the 'Nouveau' driver support with some auto-detection. 

#### Copyright

The original script to control the fans is from Artem S. Tashkinov and is 
[included](gpu-fan-control.sh) in the folder.