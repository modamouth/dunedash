#!/bin/bash
set -e

# Railway/Docker: no .env file exists — create one from example so artisan can boot
if [ ! -f .env ]; then
    cp .env.example .env
fi

# Only generate key if APP_KEY isn't already injected as an env var
if [ -z "$APP_KEY" ]; then
    php artisan key:generate --force
fi

# Run migrations
php artisan migrate --force

# Seed only if database is empty
php artisan db:seed --force 2>/dev/null || true

# Storage symlink
php artisan storage:link 2>/dev/null || true

# Cache config, routes, views for performance
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Start Apache
exec apache2-foreground
