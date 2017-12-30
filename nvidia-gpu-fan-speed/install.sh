sudo cp gpu-fan-control.sh /usr/local/bin/
sudo cp gpu-fan-controller.service /etc/systemd/system/
sudo chmod 744 /usr/local/bin/gpu-fan-control.sh
sudo chmod 664 /etc/systemd/system/gpu-fan-controller.service
sudo systemctl daemon-reload
sudo systemctl enable gpu-fan-controller.service
