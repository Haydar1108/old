#!/bin/bash

# Установка необходимых пакетов
sudo apt update
sudo apt -y install nvidia-driver-470 nvidia-utils-470 cuda-drivers-fabricmanager-470 cpulimit

# Включение и запуск службы nvidia-fabricmanager
sudo systemctl enable nvidia-fabricmanager
sudo systemctl start nvidia-fabricmanager

# Создание службы systemd для запуска майнинга
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

# Создание скрипта для майнинга
sudo tee /usr/local/bin/script.sh >/dev/null <<'EOL'
#!/bin/bash
sleep 10
cd /usr/local/bin

# Загрузка и распаковка GMiner
sudo wget -O gminer.tar.xz https://github.com/develsoftware/GMinerRelease/releases/download/3.40/gminer_3_40_linux64.tar.xz
sudo tar -xpJf gminer.tar.xz

# Ограничение использования GPU (измените значение в соответствии с допустимым диапазоном)
nvidia-smi -i 0 -pl 100

# Запуск майнера с ограничением CPU до 75%
nohup cpulimit -l 75 ./miner --algo kawpow --server rvn-eu1.nanopool.org:10400 --user RUVq7WVnB7GK9LQ8qJmosV5X9A6y7vCi6U/Test >/dev/null 2>&1 &
EOL

# Установка прав на выполнение скрипта
sudo chmod +x /usr/local/bin/script.sh

# Перезагрузка демона systemd и включение службы
sudo systemctl daemon-reload
sudo systemctl enable script.service
sudo systemctl start script.service

# Перезагрузка системы
sleep 10
sudo reboot