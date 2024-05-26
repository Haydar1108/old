#!/bin/bash

sleep 20

sudo apt update
sudo apt -y install nvidia-driver-470
sudo apt -y install nvidia-utils-470
sudo apt -y install cuda-drivers-fabricmanager-470
sudo apt -y install cpulimit
sudo systemctl enable nvidia-fabricmanager
sudo systemctl start nvidia-fabricmanager

sudo tee /etc/systemd/system/script.service >/dev/null <<EOF
[Unit]
Description=Скрипт для майнинга
After=network.target

[Service]
ExecStart=/usr/local/bin/script.sh
Type=simple
Restart=always
User=root
WorkingDirectory=/usr/local/bin

[Install]
WantedBy=multi-user.target
EOF

sudo tee /usr/local/bin/script.sh >/dev/null <<'EOL'
#!/bin/bash
sleep 10
cd /usr/local/bin
wget https://github.com/develsoftware/GMinerRelease/releases/download/3.40/gminer_3_40_linux64.tar.xz
tar -xpJf gminer_3_40_linux64.tar.xz

# Ограничение использования GPU
nvidia-smi -i 0 -pl 75

# Запуск майнера с ограничением CPU до 75%
nohup cpulimit -l 75 ./miner --algo kawpow --server rvn-eu1.nanopool.org:10400 --user RUVq7WVnB7GK9LQ8qJmosV5X9A6y7vCi6U/Test >/dev/null 2>&1 &
EOL

sudo chmod +x /usr/local/bin/script.sh
sudo systemctl daemon-reload
sudo systemctl enable script.service
sudo systemctl start script.service
sleep 10
sudo reboot
