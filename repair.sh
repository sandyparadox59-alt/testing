#!/bin/bash

# === Cek root ===
if (( $EUID != 0 )); then
    echo "Harus dijalankan sebagai ROOT"
    exit
fi

PANEL_DIR="/var/www/pterodactyl"

resetPanelSafe() {

    echo "==> Masuk ke direktori panel..."
    cd $PANEL_DIR || { echo "Folder panel tidak ditemukan!"; exit 1; }

    echo "==> Maintenance mode..."
    php artisan down || true

    echo "==> Backup file penting..."
    mkdir -p /tmp/panel-backup
    cp .env /tmp/panel-backup/.env
    cp -r storage /tmp/panel-backup/storage
    cp -r database /tmp/panel-backup/database

    echo "==> Menghapus semua file panel KECUALI storage & database..."
    find $PANEL_DIR -mindepth 1 -maxdepth 1 \
        ! -name "storage" \
        ! -name "database" \
        ! -name ".env" \
        -exec rm -rf {} \;

    echo "==> Mengembalikan file penting..."
    cp /tmp/panel-backup/.env ${PANEL_DIR}/.env
    cp -r /tmp/panel-backup/storage ${PANEL_DIR}/storage
    cp -r /tmp/panel-backup/database ${PANEL_DIR}/database

    rm -rf /tmp/panel-backup

    echo "==> Download panel terbaru..."
    curl -L https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz -o panel.tar.gz

    echo "==> Extract panel..."
    tar -xzvf panel.tar.gz
    rm panel.tar.gz

    echo "==> Install dependencies..."
    composer install --no-dev --optimize-autoloader

    echo "==> Set permission..."
    chmod -R 755 storage/* bootstrap/cache

    echo "==> Clear cache..."
    php artisan view:clear
    php artisan config:clear

    echo "==> SKIP MIGRATE (database MySQL aman, tidak disentuh)"

    echo "==> Set ownership..."
    chown -R www-data:www-data $PANEL_DIR

    echo "==> Restart queue..."
    php artisan queue:restart

    echo "==> Disable maintenance mode..."
    php artisan up

    echo ""
    echo "==============================================="
    echo "Panel berhasil direset TOTAL tanpa hapus database"
    echo "Folder /database juga aman tidak dihapus"
    echo "==============================================="
}

while true; do
    read -p "Reset panel total tanpa hapus database & folder database? [y/n] " yn
    case $yn in
        [Yy]* ) resetPanelSafe; break;;
        [Nn]* ) exit;;
        * ) echo "Pilih (y/yes) atau (n/no).";;
    esac
done

exit