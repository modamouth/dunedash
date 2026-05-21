#!/bin/bash
set -e

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
