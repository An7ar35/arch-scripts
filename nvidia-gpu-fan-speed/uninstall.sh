sudo systemctl stop gpu-fan-controller.service
sudo systemctl disable gpu-fan-controller.service
sudo rm /usr/local/bin/gpu-fan-control.sh
sudo rm /etc/systemd/system/gpu-fan-controller.service
sudo systemctl daemon-reload
sudo systemctl reset-failed
