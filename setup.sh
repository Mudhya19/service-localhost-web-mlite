#!/bin/bash
# setup.sh - Automated setup for mlite web server on Ubuntu/WSL

set -e  # stop kalau ada error

echo "=== [1/5] Updating system packages ==="
sudo apt update && sudo apt upgrade -y

echo "=== [2/5] Installing required packages ==="
sudo apt install -y composer apache2 php php-cli php-common php-mysql \
    php-gd php-curl php-mbstring php-xml

# Check PHP version for curl & mbstring compatibility
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
echo "Detected PHP version: $PHP_VERSION"

# Install curl module sesuai versi
sudo apt install -y php${PHP_VERSION}-curl php${PHP_VERSION}-mbstring || true

echo "=== [3/5] Starting Apache service ==="
sudo systemctl enable apache2
sudo systemctl start apache2
sudo systemctl status apache2 --no-pager

echo "=== [4/5] Copying mlite project from Windows to Linux ==="
if [ -d "/mnt/c/laragon/www/mlite" ]; then
    cp -r /mnt/c/laragon/www/mlite ~/mlite
    echo "Project copied to ~/mlite"
else
    echo "⚠️  Windows project folder not found at /mnt/c/laragon/www/mlite"
fi

# Clean old folder if exists
# rm -rf ~/mlite || true
# mv ~/mlite ~/mlite

echo "=== [5/5] Creating systemd service for mlite-server ==="
SERVICE_FILE="/etc/systemd/system/mlite-server.service"

sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=mlite PHP Development Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/php -S 0.0.0.0:8010 -t /root/mlite
WorkingDirectory=/root/mlite
Restart=always
RestartSec=5
User=root
Environment=APP_ENV=production

StandardOutput=journal
StandardError=journal
SyslogIdentifier=mlite

[Install]
WantedBy=multi-user.target
EOL

echo "=== Reloading systemd and enabling mlite-server ==="
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable mlite-server
sudo systemctl start mlite-server

echo "=== Setup Completed! ==="
echo "Check service status with: sudo systemctl status mlite-server"
echo "Check logs with: journalctl -u mlite-server -f"
echo "Access from browser: http://localhost:8010 or http://\$(hostname -I | awk '{print \$1}'):8010"
