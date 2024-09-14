#!/bin/bash
if [ -e /var/www/artisan ]; then 
    echo "Laravel files found, starting configuration"

    # Change permissions of laravel files
    chown -R $USER:www-data /var/www/storage /var/www/bootstrap/cache
    chmod -R 775 /var/www/storage /var/www/bootstrap/cache

    # Check if we need to do composer install for first run
    if [ ! -d "/var/www/vendor" ] || [ ! -f "/var/www/composer.lock" ] || [ -z "$(ls -A /var/www/vendor)" ]; then
        echo "Vendor files missing, running composer install"
        cd /var/www && composer install
    fi

    # If the node_modules folder doesn't exist but we have packages to install
    if [ ! -d "/var/www/node_modules" ] && [ -f "/var/www/package.json" ]; then
        echo "Node modules missing, running npm install"
        cd /var/www && npm install
    fi

    # Check if the environment variable AppEnvironment is set to PROD
    if [ "$AppEnvironment" != "PROD" ]; then
        echo "Working in dev/test mode."
        if [ -d "/var/www/node_modules" ] && [ -f "/var/www/package.json" ] && { [ -f "/var/www/vite.config.js" ] || [ -f "/var/www/vite.config.ts" ] ; }; then
            echo "React - Starting watcher"
            npm run dev --watch
        fi
    else
        echo "Working in production"
        echo "Laravel - Clearing Optimizations"
        php artisan optimize:clear

        echo "Laravel - Optimizing & Caching"
        php artisan optimize

        #check if we are using vite
        if [ -f "/var/www/vite.config.js" ] || [ -f "/var/www/vite.config.ts" ]; then
            echo "Frontend - Compiling"
            npm run build
        fi
    fi

    #start cron
    echo "Starting Cron"
    crond &

    # Run the queue workers
    echo "Starting Laravel queue workers high and default"
    php artisan queue:work --queue=high,default --tries=3 &
    # Run the schedulers
    php artisan schedule:work &
else
    echo "Laravel files were not found, skipping setup."
fi
#finally start php
echo "Starting php in FPM mode"
php-fpm