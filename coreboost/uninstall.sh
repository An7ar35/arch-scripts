#!/bin/bash
sudo systemctl stop coreboost.service
sudo systemctl disable coreboost.service

sudo rm /usr/bin/coreboost
sudo rm /opt/coreboost/coreboost.sh
sudo rmdir /opt/coreboost

sudo rm /etc/systemd/system/coreboost.service
sudo systemctl daemon-reload
sudo systemctl reset-failed