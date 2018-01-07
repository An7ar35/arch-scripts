#!/bin/bash
if [ ! -d '/opt/coreboost/' ]; then
    sudo mkdir -p '/opt/coreboost/'
fi
sudo cp coreboost.sh /opt/coreboost/
sudo chmod 775 /opt/coreboost/coreboost.sh
sudo ln -s /opt/coreboost/coreboost.sh /usr/bin/coreboost

sudo cp coreboost.service /etc/systemd/system/
sudo chmod 664 /etc/systemd/system/coreboost.service

sudo systemctl daemon-reload
sudo systemctl enable coreboost.service
sudo systemctl start coreboost.service