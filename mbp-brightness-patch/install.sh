#!/usr/bin/env bash
echo -e '
obj-m += apple-gmux.o

all:
\t make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
\t make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean
' > Makefile
make

linux_version=$(uname -r)

mod=$(ls /lib/modules/$linux_version/kernel/drivers/platform/x86/apple-gmux.ko*)
sudo mv -v $mod{,.orig}
sudo cp apple-gmux.ko /lib/modules/$linux_version/kernel/drivers/platform/x86/
sudo depmod

rm -r .tmp_versions
rm .[!.]*.cmd
rm apple-gmux.ko
rm apple-gmux.mod.c
rm apple-gmux.mod.o
rm apple-gmux.o
rm Makefile
rm Module.symvers
rm modules.order
