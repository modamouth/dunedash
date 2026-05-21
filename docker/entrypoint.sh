#!/bin/bash
set -e

# Run migrations with error handling
php artisan migrate --force 2>&1 || {
    echo "Migrations failed - database may not be ready yet"
}

# Seed only if database is empty
php artisan db:seed --force 2>/dev/null || true

# Storage symlink
php artisan storage:link 2>/dev/null || true

# Cache config, routes, views for performance
php artisan config:cache 2>/dev/null || true
php artisan route:cache 2>/dev/null || true
php artisan view:cache 2>/dev/null || true

# Start Apache
exec apache2-foreground
