# DAMP - Docker Apache MySQL PHP
<em>by Mario Mascuñano</em>
version 1.2

> Entorno de desarrollo local multi-versión de PHP con Docker, similar a XAMPP pero más ligero y flexible.

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker)](https://www.docker.com/)
[![Bash](https://img.shields.io/badge/Bash-4EAA25?style=flat&logo=gnu-bash)](https://www.gnu.org/software/bash/)
[![Licencia](https://img.shields.io/badge/Licencia-MIT-green.svg)](LICENSE)

---

## 📋 Requisitos

- **Docker** + Docker Compose
- **Bash 3.2+** — compatible con macOS (bash 3.2 nativo) y Linux (bash 4+)
- **Git**

---

## 🚀 Instalación

```bash
# 1. Clonar el repositorio
git clone https://github.com/TU_USUARIO/damp.git
cd damp

# 2. Dar permisos y ejecutar el instalador
chmod +x setup.sh damp
./setup.sh

# 3. (Opcional) Hacer disponible el comando 'damp' globalmente
sudo cp damp /usr/local/bin/
```

`setup.sh` genera las carpetas `phpXX/` con sus `Dockerfile` y `docker-compose.yml`, y crea la carpeta `proyectos/` si no existe.

---

## 🏗️ Estructura

```
damp/
├── setup.sh              # Instalador — genera los entornos PHP
├── damp                  # Comando principal para gestionar proyectos
├── proyectos/            # Aquí van todos los proyectos (ignorada por git)
│   ├── miproyecto/
│   └── otroproyecto/
├── php74/                # Entorno PHP 7.4 (generado por setup.sh)
├── php82/                # Entorno PHP 8.2
├── php83/                # Entorno PHP 8.3
└── php84/                # Entorno PHP 8.4
```

Cada carpeta `phpXX/` contiene:
- `docker-compose.yml` — servicios PHP/Apache, MySQL y phpMyAdmin
- `php/Dockerfile` — imagen PHP+Apache con extensiones `pdo`, `pdo_mysql`, `mysqli`
- `www` — symlink al proyecto activo (gestionado automáticamente por `damp`)
- `.env` — ruta absoluta del proyecto activo (generado automáticamente)

> Las carpetas `phpXX/` y `proyectos/` están en `.gitignore`. Solo se versiona el instalador.

---

## 📦 Puertos por versión

| PHP  | App (Apache)            | phpMyAdmin              | MySQL |
|------|-------------------------|-------------------------|-------|
| 7.4  | http://localhost:8074   | http://localhost:8174   | 3374  |
| 8.2  | http://localhost:8082   | http://localhost:8182   | 3382  |
| 8.3  | http://localhost:8083   | http://localhost:8183   | 3383  |
| 8.4  | http://localhost:8084   | http://localhost:8184   | 3384  |

---

## 💻 Comandos

### Levantar un proyecto

```bash
damp <version-php> <nombre-proyecto>
```

El proyecto debe existir como carpeta dentro de `proyectos/`. El comando:
1. Crea el symlink `phpXX/www → proyectos/<nombre-proyecto>`
2. Escribe `phpXX/.env` con la ruta absoluta del proyecto
3. Lanza `docker compose up -d --build`

```bash
damp 8.4 miproyecto
# → http://localhost:8084  |  phpMyAdmin: http://localhost:8184
```

### Cambiar de proyecto en la misma versión de PHP

Ejecuta el mismo comando apuntando al nuevo proyecto:

```bash
damp 8.4 otroproyecto
```

Solo se recrea el contenedor PHP/Apache (que sirve los ficheros). MySQL y phpMyAdmin siguen corriendo sin interrupción y las bases de datos se conservan.

### Ver qué proyecto está activo en cada versión

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

## 🗄️ Base de datos

### Credenciales MySQL

| Campo      | Valor   |
|------------|---------|
| Host       | `mysql` (dentro de Docker) / `localhost` (desde el host) |
| Usuario    | `root`  |
| Contraseña | *(vacía)* |

> Cada versión de PHP tiene su propio MySQL aislado con su propio volumen de datos.

### Importar una base de datos

```bash
# Crear la base de datos
docker exec phpXX-mysql-1 mysql -u root -e "CREATE DATABASE nombre_db;"

# Importar el fichero SQL
docker exec -i phpXX-mysql-1 mysql -u root nombre_db < /ruta/al/fichero.sql
```

Ejemplo real con PHP 8.4:
```bash
docker exec php84-mysql-1 mysql -u root -e "CREATE DATABASE mi_proyecto;"
docker exec -i php84-mysql-1 mysql -u root mi_proyecto < ~/Downloads/mi_proyecto.sql
```

### Configuración WordPress (`wp-config.php`)

```php
define( 'DB_NAME',     'nombre_base_de_datos' );
define( 'DB_USER',     'root' );
define( 'DB_PASSWORD', '' );
define( 'DB_HOST',     'mysql' );  // nombre del servicio Docker, no 'localhost'
```

---

## 📁 Gestión de proyectos

```bash
# Crear un nuevo proyecto
mkdir proyectos/miproyecto

# Copiar un proyecto existente
cp -r proyectos/otroproyecto proyectos/nuevoproyecto
```

Estructura recomendada:

```
proyectos/
└── miproyecto/
    ├── index.php
    ├── src/
    └── public/
```

---

## 🔧 Añadir una nueva versión de PHP

1. Añadir la entrada en el array `versions` de `setup.sh`:
   ```bash
   "8.1:8081:3381:8181"  # formato → version:puerto_php:puerto_mysql:puerto_pma
   ```

2. Añadir la versión en la función `get_ports` del comando `damp`:
   ```bash
   get_ports() {
     case "$1" in
       8.1) echo "8081:8181" ;;
       # ...resto de versiones
     esac
   }
   ```
   Y añadirla también a la variable `VERSIONS` al principio del fichero.

3. Ejecutar `setup.sh` para generar el nuevo entorno:
   ```bash
   ./setup.sh
   ```

---

## 🐛 Solución de problemas

### Los contenedores no inician

```bash
# Ver logs
docker compose -f phpXX/docker-compose.yml logs -f

# Reiniciar
damp <version> --restart
```

### Puerto ya en uso

Edita `phpXX/docker-compose.yml` y cambia el puerto externo:

```yaml
ports:
  - "9090:80"  # cambia el puerto de la izquierda
```

### Resetear MySQL de una versión (borra todas las BBDDs de esa versión)

```bash
cd phpXX
docker compose down -v   # elimina contenedores y volumen de datos
docker compose up -d
```

### Permisos denegados (Linux)

```bash
sudo chown -R $USER:$USER damp/
```

---

## 📄 Licencia

MIT License — libre para usar y modificar.

---

## 🤝 Contribuir

1. Fork del repositorio
2. Crea una rama (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -m 'Añadir nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request
