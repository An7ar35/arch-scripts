#!/bin/bash

nvfan -r
sudo rm /usr/bin/nvfan
sudo rm /opt/nvfan/nvfan.sh
sudo rmdir /opt/nvfan
echo "nvfan removed."
