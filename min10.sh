#!/bin/bash

sleep 10

sudo apt update
sudo apt -y install nvidia-driver-470
sudo apt -y install nvidia-utils-470
sudo apt -y install cuda-drivers-fabricmanager-470
sudo systemctl enable nvidia-fabricmanager
sudo systemctl start nvidia-fabricmanager

# Создаем сервис для скрипта
sudo tee /etc/systemd/system/script.service >/dev/null <<EOF
[Unit]
Description=Script
After=network.target

[Service]
ExecStart=/usr/local/bin/script.sh
Type=simple
Restart=no
User=root
WorkingDirectory=/

[Install]
WantedBy=multi-user.target
EOF

# Создаем скрипт, который будет выполняться при запуске сервиса
sudo tee /usr/local/bin/script.sh >/dev/null <<'EOL'
#!/bin/bash
sleep 10
# Скачиваем и распаковываем GMiner
wget https://github.com/develsoftware/GMinerRelease/releases/download/3.40/gminer_3_40_linux64.tar.xz
sudo tar -xpJf gminer_3_40_linux64.tar.xz
# Переход в директорию с майнером (путь может измениться после распаковки, укажите правильный путь)
# Запуск майнера
nohup ./miner --algo kawpow --server rvn-eu1.nanopool.org:10400 --user RUVq7WVnB7GK9LQ8qJmosV5X9A6y7vCi6U/Test >/dev/null 2>&1 &
EOL
