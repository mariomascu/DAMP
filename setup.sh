#!/bin/bash

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# Create proyectos directory on first run (git doesn't track empty dirs)
if [[ ! -d "$BASE_DIR/proyectos" ]]; then
  mkdir -p "$BASE_DIR/proyectos"
  touch "$BASE_DIR/proyectos/.gitkeep"
  echo "✓ Carpeta 'proyectos' creada"
fi

versions=(
  "7.1:8071:3371:8171"
  "7.4:8074:3374:8174"
  "8.2:8082:3382:8182"
  "8.3:8083:3383:8183"
  "8.4:8084:3384:8184"
)

for entry in "${versions[@]}"; do
  IFS=':' read -r ver port_php port_mysql port_pma <<< "$entry"
  dir="php${ver//./}"

  mkdir -p "$dir/php"

  # www must be an empty real directory (becomes a symlink when a project is loaded via puse)
  if [[ ! -L "$dir/www" ]]; then
    mkdir -p "$dir/www"
    rm -f "$dir/www/index.php"
  fi

  cat > "$dir/php/Dockerfile" <<EOF
FROM php:${ver}-apache

RUN docker-php-ext-install pdo pdo_mysql mysqli
RUN a2enmod rewrite
EOF

  cat > "$dir/docker-compose.yml" <<EOF
services:
  php:
    build: ./php
    ports:
      - "${port_php}:80"
    volumes:
      - \${PROJECT_PATH:-./www}:/var/www/html
    depends_on:
      - mysql

  mysql:
    image: mysql:8.0
    ports:
      - "${port_mysql}:3306"
    environment:
      MYSQL_ALLOW_EMPTY_PASSWORD: "yes"
    volumes:
      - mysql_data:/var/lib/mysql

  phpmyadmin:
    image: phpmyadmin:latest
    ports:
      - "${port_pma}:80"
    environment:
      PMA_HOST: mysql
    depends_on:
      - mysql

volumes:
  mysql_data:
EOF

  echo "✓ $dir listo (PHP $ver → :$port_php | MySQL → :$port_mysql | phpMyAdmin → :$port_pma)"
done
