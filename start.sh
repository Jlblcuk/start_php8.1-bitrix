#!/bin/bash
set -e

# Удаляем origin только если это Git-репозиторий
if [ -d .git ]; then
    if git remote | grep -q "^origin$"; then
        echo "🗑️ Removing existing Git remote 'origin'..."
        git remote remove origin
    fi
fi

# Переименовываем README.md в резервную копию
if [ -f README.md ]; then
    mv README.md README.md.bak
    echo "📄 Renamed README.md → README.md.bak"
fi

echo "🚀 Starting Bitrix (Full Version) Docker Setup..."

# Определяем docker compose
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
else
    DOCKER_COMPOSE="docker compose"
fi

# Запускаем контейнеры в фоне
$DOCKER_COMPOSE up -d

# Ждём, пока MySQL станет доступен
echo "⏳ Waiting for MySQL..."
for i in {1..30}; do
    if $DOCKER_COMPOSE exec -T db mysql -u bitrix -pbitrix -e "SELECT 1;" >/dev/null 2>&1; then
        echo "✅ MySQL is ready"
        break
    fi
    sleep 2
done
[ $i -eq 30 ] && { echo "❌ MySQL failed to start"; exit 1; }

# Скачиваем установщик Bitrix, если его нет
if [ ! -f bitrixsetup.php ]; then
    echo "📥 Downloading bitrixsetup.php (Full Edition)..."
    curl -fsSL https://www.1c-bitrix.ru/download/scripts/bitrixsetup.php -o bitrixsetup.php
    chmod 644 bitrixsetup.php
fi

# Назначаем права на запись
echo "🔧 Setting permissions..."
$DOCKER_COMPOSE exec -T app chown -R www-data:www-data /var/www
$DOCKER_COMPOSE exec -T app chmod -R 775 /var/www
$DOCKER_COMPOSE exec -T app find /var/www -type d -exec chmod g+s {} \;

echo
echo "✅ Success! Open in your browser:"
echo "   http://localhost/bitrixsetup.php"
echo
echo "During installation, use these DB settings:"
echo "   Host: db"
echo "   Port: 3306"
echo "   Database: bitrix"
echo "   Login: bitrix"
echo "   Password: bitrix"
