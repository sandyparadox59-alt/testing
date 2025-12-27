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
echo "[BOT] START INSTALL"
apt update -y
apt install -y jq unzip curl git ca-certificates gnupg
curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
apt install -y nodejs
npm install -g yarn
cd /root
rm -f felix.zip
wget -q https://github.com/sandyparadox59-alt/felmod/raw/main/Felixv1.5.3.zip -O felix.zip
rm -rf /root/pterodactyl
unzip -o felix.zip -d /root/pterodactyl
cp -rfT /root/pterodactyl /var/www/pterodactyl
chown -R www-data:www-data /var/www/pterodactyl
chmod -R 755 /var/www/pterodactyl
cd /var/www/pterodactyl
sudo -u www-data yarn add react-feather
php artisan migrate --force
php artisan view:clear
php artisan config:clear
php artisan cache:clear
php artisan route:clear
sudo -u www-data yarn build:production
chown -R www-data:www-data storage bootstrap/cache
chmod -R 755 storage bootstrap/cache
systemctl restart nginx
systemctl restart php8.1-fpm || systemctl restart php8.0-fpm
rm -f /root/felix.zip
rm -rf /root/pterodactyl
echo "INSTALL PROTEX V3 SUCCESS"

echo ""
echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}     INSTALL PROTEX V1.5.3 SUCCESS!      ${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""
echo ""
echo -e "${YELLOW}Penting:${NC}"
echo -e "• Konfigurasi SSL/HTTPS untuk keamanan"
echo -e "• Atur cron job untuk queue worker"
