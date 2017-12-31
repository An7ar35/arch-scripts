# NVIDIA GPU Fan Speed `nvfan`

This is a script adapted from Artem S. Tashkinov's own and awesome adaptive fan speed management 
for NVIDIA GPUs on Linux script.

I've modified the temperature/fan speed values for a more aggressive profile.

This is perfect for keeping your GFX card cool when playing games or doing other GPU intensive 
tasks on Linux.

__Only use this if you know what you are doing!__

#### Usage

//TODO

#### Modiying fan speed steps and polling time

Edit the [`nvfan.sh`](nvfan.sh) script prior to installing 
and look for the `polltime` and `range`/`speed` sections.

For example the following settings would set the fan speed to 0% between 0-29°C, 50% between 
30-79°C and 100% between 80-200°C.
> range[0]="0 29"  
> speed[0]=0  
> range[0]="30 79"  
> speed[0]=50  
> range[0]="80 200"  
> speed[0]=100

With bad settings you can fry your card so be careful and always keep an eye
on ou GPU temps (desktop monitor with warnings/critical temp. shutdown safety 
is a good idea).

#### Installing

To install run the installer script, `sudo install.sh`, from the `nvfan/` directory.

#### Uninstalling

Just run the uninstaller script, `sudo uninstall.sh`, from the `nvfan/` directory.

#### Dependencies

Requires nvidia-settings (part of the __proprietary NVIDIA package__).

#### Copyright

The original script to control the fans is from Artem S. Tashkinov and is 
[included](gpu-fan-control.sh) in the folder.