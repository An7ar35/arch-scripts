# Apple MacBook Pro Brightness Patch

This is a script to streamline the creation and installation of the apple-gmux module out of a patched source file (included).

Currently (2017) the kernel's unpatched `apple-gmux` module does not work with brightness control on the MBP 2015.

Since on Arch Linux, the kernel is updated straight from upstream, updates are frequent.
In each new kernel release, if the brighness still doesn't work, just run the `install.sh` script.
It will compile and install the patched module.
