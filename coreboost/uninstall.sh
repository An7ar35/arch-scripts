sudo systemctl stop coreboost.service
sudo systemctl disable coreboost.service
sudo rm /usr/local/bin/coreboost.sh
sudo rm /etc/systemd/system/coreboost.service
sudo systemctl daemon-reload
sudo systemctl reset-failed
