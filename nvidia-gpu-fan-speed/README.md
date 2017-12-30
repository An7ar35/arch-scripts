# NVIDIA GPU Fan Speed

This is a systemd service wrapper for Artem S. Tashkinov's awesome adaptive fan speed management 
for NVIDIA GPUs on Linux script.

I've modified the temperature/fan speed values for a more aggressive profile.

This is perfect for keeping your GFX card cool when playing games or doing other GPU intensive taks on Linux.

__Only use this if you know what you are doing!__

#### Modiying fan speed steps and polling time

Edit the [gpu-fan-control.sh](gpu-fan-control.sh) script and look for the
`polltime` and `range`/`dtemp` sections.

With bad settings you can fry your card so be carefull and always keep an eye
on ou GPU temps (desktop monitor with warnings/critical temp. shutdown safety 
is a good idea).

#### Installing

To install run the installer script, `sudo install.sh`, from the `nvidia-gpu-fan-speed/` directory.

#### Uninstalling

Just run the uninstaller script, `sudo uninstall.sh`, from the `nvidia-gpu-fan-speed/` directory.

#### Dependencies

Requires nvidia-settings (part of the __proprietary NVIDIA package__).

#### Copyright

The original script to control the fans is from Artem S. Tashkinov.

Installer/Uninstaller and systemd service are made by me (An7ar35).
