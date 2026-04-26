# Plantilla wp-config.php para DAMP

Copia este contenido como `wp-config.php` en la raíz de cada proyecto WordPress dentro de `proyectos/`.

Ajusta únicamente:
- `DB_NAME` → nombre de tu base de datos
- `$table_prefix` → prefijo de tablas (si lo cambiaste al instalar WordPress)
- Las claves secretas → genera las tuyas en https://api.wordpress.org/secret-key/1.1/salt/
---

```php
<?php
// ** URL dinámica — funciona con cualquier versión/puerto de DAMP ** //
define( 'WP_SITEURL', 'http://' . $_SERVER['HTTP_HOST'] );
define( 'WP_HOME',    'http://' . $_SERVER['HTTP_HOST'] );

// ** Configuración de base de datos ** //
define( 'DB_NAME',     'nombre_base_de_datos' );
define( 'DB_USER',     'root' );
define( 'DB_PASSWORD', '' );
define( 'DB_HOST',     'mysql' );  // nombre del servicio Docker, no 'localhost'
define( 'DB_CHARSET',  'utf8' );
define( 'DB_COLLATE',  '' );


// ** Claves secretas — genera las tuyas en: https://api.wordpress.org/secret-key/1.1/salt/ ** //
define( 'AUTH_KEY',         'reemplaza-esto' );
define( 'SECURE_AUTH_KEY',  'reemplaza-esto' );
define( 'LOGGED_IN_KEY',    'reemplaza-esto' );
define( 'NONCE_KEY',        'reemplaza-esto' );
define( 'AUTH_SALT',        'reemplaza-esto' );
define( 'SECURE_AUTH_SALT', 'reemplaza-esto' );
define( 'LOGGED_IN_SALT',   'reemplaza-esto' );
define( 'NONCE_SALT',       'reemplaza-esto' );

// ** Prefijo de tablas ** //
$table_prefix = 'wp_';

// ** Depuración (desactívalo en producción) ** //
define( 'WP_DEBUG',    true );
define( 'WP_DEBUG_LOG', true );   // guarda errores en wp-content/debug.log
define( 'WP_DEBUG_DISPLAY', false );  // no muestra errores en pantalla

/* ¡No edites más allá de esta línea! */

if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php';
```

---

## Por qué `WP_SITEURL` y `WP_HOME` son dinámicos

WordPress guarda la URL del sitio en la base de datos. Al importar una copia de producción, esa URL apunta al dominio original y el panel de administración redirige allí.

Con `$_SERVER['HTTP_HOST']` WordPress usa siempre el host y puerto reales de la petición (`localhost:8082`, `localhost:8084`, etc.), lo que permite cambiar de versión de PHP sin tocar el fichero.
