## Docker Setup
Docker has been setup with the following "servers"

 1. Php - setup as php-fpm, artisan commands can be ran here.
 2. Nginx - Serves the site/app on port 8080.
 3. MySQL - The database system for the app.

### PHP Setup
Php has been setup with the `php.ini` file that resides in the folder
`./Docker/php/local.ini` with the main Docker build configuration residing in the file `./App.dockerfile`

### Nginx
Nginx has been setup with the `app.conf` file that resides in the folder
`./Docker/app.conf`

## App Setup
The php server has an entrypoint file `./Docker/AppDockerFiles/Entrypoint.sh` that does a number of things.

* If laravel is found in the `/var/www` folder then: 
    * and the `vendor` folder is missing then:
        * Set laravel folder permissions
        * `composer install` command will be ran
    * If the `node_modules` folder is missing then:
        * `npm install` command will be ran
    * If the environment variable `AppEnvironment` != "PROD" then:
        * If we are using Vite then run `npm run dev --watch`
    * If the environment is "PROD" then:
        * Clear any laravel optimisations
        * Perform laravel optimisations 
        * If using vite then build the components
    * Start the scheduled tasks / cron server
    * Start the laravel queue worker for high and default with a rety count of 3
    * Start the laravel schedule
*  Start php in FPM mode

## Full Command List

Start by running `docker compose up -d --build` to build the app and start it.  Once built connect to the `laravelapp-php` service and do the following:
```
cd /var/www
composer create-project laravel/laravel ./
```
Now perform installs.
```
composer install
npm install
```
Change the configuration to use MySQL/MariahDB by changing the .env file
```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=root
DB_PASSWORD=root
```
Now we need to setup the cache system and start migration with seeding.
```
php artisan make:cache-table
php artisan migrate --seed
```