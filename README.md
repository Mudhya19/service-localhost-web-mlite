# Setting Up the mlite Web Server Using Ubuntu CLI

This documentation outlines the steps to configure and run the `mlite-RSDS` web server from the Ubuntu CLI environment, particularly under WSL with access to Windows directories.

---

## 1. System Update and Package Installation

Begin by updating the system and installing necessary packages:

```bash
# Update Ubuntu packages
sudo apt update && sudo apt upgrade -y

# Install required PHP extensions and Apache server
sudo apt install php-mysql
sudo apt install php-gd
sudo apt install php8.3-curl
sudo apt install apache2
sudo apt install php-mbstring  # or php8.3-mbstring depending on your PHP version
sudo apt php
sudo apt php-cli
sudo apt php-common
sudo apt php-curl
sudo apt php-xml
```

---

## 2. Verifying Installation

Start the Apache service and confirm required PHP modules are active:

```bash
# Start Apache web server
sudo systemctl start apache2

# Verify required PHP modules are loaded
php -m | grep curl
php -m | grep mbstring

# Check Apache service status
systemctl list-units --type=service | grep apache
which apache2
```

---

## 3. Accessing the Windows Folder and Running Web Server

Navigate to your project directory and launch a PHP development server:

```bash
# Navigate to the web project folder (inside Windows directory)
cd /mnt/c/laragon/www/mlite-RSDS

# Start PHP built-in server
php -S localhost:8000 -t /mnt/c/laragon/www/mlite-RSDS

# Copy project folder in system linux
cp -r /mnt/c/laragon/www/mlite-RSDS ~/mlite-RSDS
```

---

## 4. Creating a systemd Service for Persistent Hosting

To run the server as a background service on startup:

```bash
# Create a new service configuration file
sudo nano /etc/systemd/system/mlite-server.service
```

Paste the following content:

```ini
[Unit]
Description=mlite PHP Development Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/php -S 0.0.0.0:8010 -t /root/mlite-master
WorkingDirectory=/root/mlite-master
Restart=always
RestartSec=5
User=root
Environment=APP_ENV=production

StandardOutput=journal
StandardError=journal
SyslogIdentifier=mlite

[Install]
WantedBy=multi-user.target
```
Check Logs 
```
journalctl -u mlite.service -f
```
---

## 5. Enabling and Managing the Service

Enable and launch the service:

```bash
# Reload systemd to apply the new service
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

# Enable and start the service
sudo systemctl enable mlite
sudo systemctl start mlite
```

Check the network interface and access the server:

```bash
# Find your WSL IP address
hostname -I

# Access from browser:
# http://<IP_WSL>:8010 or http://localhost:8010
```

To check if the server is running and listening:

```bash
# Check for running services on port 8000
lsof -i :8010
```

---

You now have a working PHP web server running from your WSL Ubuntu terminal, accessible from your browser via `localhost:8000` or the assigned WSL IP address.

