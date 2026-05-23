#!/bin/bash

function print_color(){
  NC='\033[0m'
  case $1 in
    "green") COLOR='\033[0;32m' ;;
    "red") COLOR='\033[0;31m' ;;
    "yellow") COLOR='\033[1;33m' ;;
    *) COLOR='\033[0m' ;;
  esac
  echo -e "${COLOR}$2${NC}"
}

command -v docker >/dev/null 2>&1 || { print_color "red" "Docker not installed"; exit 1; }

docker compose version >/dev/null 2>&1 || { print_color "red" "Docker Compose missing"; exit 1; }

# Setup docker-compose.yml
if [ ! -f docker-compose.yml ]; then
  if [ -f docker-compose.yml.example ]; then
    print_color "green" "Creating docker-compose.yml from example..."
    cp docker-compose.yml.example docker-compose.yml || exit 1
  else
    print_color "red" "docker-compose.yml.example not found"
    exit 1
  fi
else
  print_color "yellow" "docker-compose.yml already exists"
fi

# Clone Laravel app
if [ ! -d app ]; then
  print_color "green" "Cloning project..."
  git clone git@github.com:taraqr9/admin-panel-skote.git app || exit 1
else
  print_color "yellow" "App already exists"
fi

cd app || exit 1

# Setup .env
if [ ! -f .env ]; then
  cp .env.example .env || { print_color "red" ".env.example missing"; exit 1; }

  sed -i.bak 's/DB_HOST=.*/DB_HOST=mysql/' .env
  sed -i.bak 's/DB_PORT=.*/DB_PORT=3306/' .env
  sed -i.bak 's/DB_DATABASE=.*/DB_DATABASE=laravel/' .env
  sed -i.bak 's/DB_USERNAME=.*/DB_USERNAME=laravel/' .env
  sed -i.bak 's/DB_PASSWORD=.*/DB_PASSWORD=root/' .env
fi

cd ..

print_color "green" "Starting containers..."
docker compose up -d --build

print_color "green" "Installing dependencies..."
docker compose exec app composer install

print_color "green" "Generating key..."
docker compose exec app php artisan key:generate

print_color "green" "Migrating database..."
docker compose exec app php artisan migrate
docker compose exec app php artisan db:seed

print_color "green" "Fixing permissions..."
docker compose exec app chmod -R 777 storage bootstrap/cache

print_color "green" "Done!"

echo ""
print_color "yellow" "App: http://localhost:9080"
print_color "yellow" "phpMyAdmin: http://localhost:9090"