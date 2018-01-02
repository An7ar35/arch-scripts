#!/bin/bash

if [ ! -d '/opt/nvfan/' ]; then
    sudo mkdir -p '/opt/nvfan/'
fi
sudo cp nvfan.sh /opt/nvfan/
sudo chmod 775 /opt/nvfan/nvfan.sh
sudo ln -s /opt/nvfan/nvfan.sh /usr/bin/nvfan