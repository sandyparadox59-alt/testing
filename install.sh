#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

clear
echo -e "${YELLOW}==========================================${NC}"
echo -e "${GREEN}       Felix Panel Installer PROTEX v1.5.3       ${NC}"
echo -e "${YELLOW}==========================================${NC}"
echo ""
echo "Script ini akan menginstall Protex Panel Anda."
echo "JANGAN DI BAGIKAN GRATIS KODE INI.."
echo ""
echo -e "${YELLOW}Persiapan yang akan dilakukan:${NC}"
echo "1. Update system packages"
echo "2. Install dependencies (Node.js 16, Yarn, dll)"
echo "3. Download PROTEX V1.5.3"
echo "4. Extract dan setup panel"
echo "5. Build assets dengan Yarn"
echo "6. Restart services (nginx, php-fpm)"
echo ""

# Ask for confirmation
read -p "Apakah Anda ingin melanjutkan instalasi? (Y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Instalasi dibatalkan.${NC}"
    exit 1
fi

echo ""
echo "[BOT] START INSTALL"

# Update system
echo -e "${YELLOW}[1/6] Memperbarui paket sistem...${NC}"
apt update -y

# Install dependencies
echo -e "${YELLOW}[2/6] Menginstal dependensi...${NC}"
apt install -y jq unzip curl git ca-certificates gnupg

# Install Node.js 16
echo -e "${YELLOW}   -> Menginstal Node.js 16...${NC}"
curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
apt install -y nodejs

# Install Yarn
echo -e "${YELLOW}   -> Menginstal Yarn...${NC}"
npm install -g yarn

# Download Felix Panel
echo -e "${YELLOW}[3/6] Mengunduh PROTEX V1.5.3...${NC}"
cd /root
rm -f felix.zip
wget -q https://github.com/sandyparadox59-alt/felmod/raw/main/Felixv1.5.3.zip -O felix.zip

# Extract files
echo -e "${YELLOW}[4/6] Mengekstrak dan menyiapkan panel...${NC}"
rm -rf /root/pterodactyl
unzip -o felix.zip -d /root/pterodactyl

# Copy to web directory
cp -rfT /root/pterodactyl /var/www/pterodactyl

# Set permissions
chown -R www-data:www-data /var/www/pterodactyl
chmod -R 755 /var/www/pterodactyl

# Build assets
echo -e "${YELLOW}[5/6] Membangun assets...${NC}"
cd /var/www/pterodactyl
sudo -u www-data yarn add react-feather

# Run artisan commands
php artisan migrate --force
php artisan view:clear
php artisan config:clear
php artisan cache:clear
php artisan route:clear

# Build production assets
echo -e "${YELLOW}   -> Membangun production assets...${NC}"
sudo -u www-data yarn build:production

# Set final permissions
chown -R www-data:www-data storage bootstrap/cache
chmod -R 755 storage bootstrap/cache

# Restart services
echo -e "${YELLOW}[6/6] Merestart services...${NC}"
systemctl restart nginx
systemctl restart php8.1-fpm || systemctl restart php8.0-fpm

# Cleanup
rm -f /root/felix.zip
rm -rf /root/pterodactyl

echo ""
echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}     INSTALL PROTEX V1.5.3 SUCCESS!      ${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""
echo -e "${YELLOW}Informasi Panel:${NC}"
echo -e "• Panel diinstall di: /var/www/pterodactyl"
echo -e "• URL panel: http://$(curl -s ifconfig.me)"
echo ""
echo -e "${YELLOW}Penting:${NC}"
echo -e "• Konfigurasi SSL/HTTPS untuk keamanan"
echo -e "• Atur cron job untuk queue worker"
