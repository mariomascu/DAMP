# Entornos PHP locales con Docker

Sistema de entornos de desarrollo local similares a XAMPP, con múltiples versiones de PHP corriendo simultáneamente via Docker.

---

## Estructura de carpetas

```
Dev/
├── setup.sh          → genera/regenera los entornos PHP
├── damp              → comando para cargar proyectos
├── proyectos/        → aquí van todos los proyectos
│   ├── miproyecto/
│   └── otroproject/
├── php71/            → entorno PHP 7.1
├── php74/            → entorno PHP 7.4
├── php82/            → entorno PHP 8.2
├── php83/            → entorno PHP 8.3
└── php84/            → entorno PHP 8.4
```

Cada carpeta `phpXX/` contiene:
- `docker-compose.yml` — servicios PHP, MySQL y phpMyAdmin
- `php/Dockerfile` — imagen PHP+Apache
- `www` — symlink al proyecto activo (vacío si no hay proyecto cargado)
- `.env` — ruta del proyecto activo (generado automáticamente por `damp`)

---

## Puertos por versión

| PHP  | App                        | phpMyAdmin                 | MySQL  |
|------|----------------------------|----------------------------|--------|
| 7.1  | http://localhost:8071      | http://localhost:8171      | 3371   |
| 7.4  | http://localhost:8074      | http://localhost:8174      | 3374   |
| 8.2  | http://localhost:8082      | http://localhost:8182      | 3382   |
| 8.3  | http://localhost:8083      | http://localhost:8183      | 3383   |
| 8.4  | http://localhost:8084      | http://localhost:8184      | 3384   |

---

## Comandos

### Levantar un proyecto

```bash
damp <version-php> <nombre-proyecto>
```

Ejemplo:
```bash
damp 8.4 mi-proyecto
```

Esto:
1. Crea el symlink `php84/www → proyectos/mi-proyecto`
2. Escribe `php84/.env` con la ruta del proyecto
3. Lanza `docker compose up -d --build`

El proyecto queda disponible en http://localhost:8084

### Ver qué proyecto tiene cargado cada versión

```bash
damp --list
```

### Detener una versión

```bash
damp <version-php> --stop
```

### Reiniciar una versión

```bash
damp <version-php> --restart
```

---

## Acceso a phpMyAdmin

- **Usuario:** `root`
- **Contraseña:** *(vacía)*

---

## Configuración WordPress (wp-config.php)

```php
define( 'DB_NAME',     'nombre_base_de_datos' );
define( 'DB_USER',     'root' );
define( 'DB_PASSWORD', '' );
define( 'DB_HOST',     'mysql' );
```

> `DB_HOST` debe ser `mysql`, no `localhost`. Dentro de Docker los servicios se comunican por nombre de servicio.

---

## Añadir una nueva versión de PHP

1. Añadir una línea en el array `versions` de `setup.sh`:
   ```bash
   "8.1:8081:3381:8181"  # formato → version:puerto_php:puerto_mysql:puerto_pma
   ```
2. Añadir la versión al mapa de puertos en `damp`:
   ```bash
   declare -A PHP_PORTS=( ... [8.1]="8081:8181" )
   ```
3. Ejecutar `setup.sh` para generar el nuevo entorno:
   ```bash
   ./setup.sh
   ```

---

## Regenerar entornos existentes

```bash
./setup.sh
```

Si un contenedor MySQL ya estaba levantado con configuración anterior, borrar su volumen para que aplique los cambios:

```bash
cd php84
docker compose down -v
docker compose up -d --build
```
