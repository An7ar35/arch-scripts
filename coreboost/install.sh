sudo cp coreboost.sh /usr/local/bin/
sudo cp coreboost.service /etc/systemd/system/
sudo chmod 744 /usr/local/bin/coreboost.sh
sudo chmod 664 /etc/systemd/system/coreboost.service
sudo systemctl daemon-reload
sudo systemctl enable coreboost.service
