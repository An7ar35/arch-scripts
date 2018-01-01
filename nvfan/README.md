# NVIDIA GPU Fan Speed `nvfan`

<span style="color:blue">__Only use this if you know what you are doing!__</span>

This is a script adapted from Artem S. Tashkinov's own and awesome adaptive fan speed management 
for NVIDIA GPUs on Linux script.

I've modified the temperature/fan speed values for a more aggressive profile.

This is perfect for keeping your GFX card cool when playing games or doing other GPU intensive 
tasks on Linux.

#### Installing

To install run the installer script, `sudo install.sh`, from the `nvfan/` directory.

#### Uninstalling

Just run the uninstaller script, `sudo uninstall.sh`, from the `nvfan/` directory.

#### Usage

    Options:
       -a  Start the automatic fan speed controller process based on the presets (will kill old 
           processes and reloads 'nvfan.conf' if it was running previously).
       -h  Usage help.
       -s  Manually set speed of fan <% fan speed>. Kills the auto fan speed process.
       -r  Kills the fan controller process and resets to NVIDIA's own fan management.

//TODO

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
on ou GPU temps (desktop monitor with warnings/critical temp. shutdown safety 
is a good idea)._

#### Dependencies

Requires nvidia-settings (part of the __proprietary NVIDIA package__).

#### Copyright

The original script to control the fans is from Artem S. Tashkinov and is 
[included](gpu-fan-control.sh) in the folder.