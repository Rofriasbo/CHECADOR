CHECADOR
---

# Proyecto de Gestión de Asistencia Escolar

Esta es una aplicación móvil desarrollada en Flutter para la gestión y control de la asistencia de profesores, materias y horarios en una institución.

---

## Dependencias Clave del Proyecto

Este proyecto utiliza varios paquetes de Dart/Flutter para funcionar. A continuación se describe para qué se utiliza cada uno:

### `sqflite: ^2.4.2`

* **¿Para qué se usa?** Es la **Base de Datos** principal de la aplicación.
* **Explicación:** `sqflite` es el paquete que permite a Flutter utilizar **SQLite**, una base de datos SQL local que se guarda directamente en el teléfono (Android o iOS). En este proyecto, se usa para almacenar de forma persistente toda la información:
    * La tabla `PROFESOR`
    * La tabla `MATERIA`
    * La tabla `HORARIO`
    * La tabla `ASISTENCIA`

### `path: ^1.9.0`

* **¿Para qué se usa?** Para **encontrar la ubicación** de la base de datos.
* **Explicación:** `sqflite` necesita saber *dónde* guardar el archivo de la base de datos (ej. `asistencia_escolar.db`) en el sistema de archivos del teléfono. El paquete `path` (específicamente su función `join`) nos ayuda a construir una ruta de archivo válida (ej. `/data/user/0/.../databases/asistencia_escolar.db`) que funciona correctamente tanto en Android como en iOS.

### `uuid: ^4.4.0`

* **¿Para qué se usa?** Para generar **IDs únicos** (Claves Primarias).
* **Explicación:** Cuando creamos un nuevo Profesor o una nueva Materia, necesitamos asignarles un `NPROFESOR` y un `NMAT` que sean únicos y nunca se repitan. En lugar de usar un timestamp (que podría fallar), `uuid` genera un "Identificador Único Universal" (ej. `123e4567-e89b-12d3-a456-426614174000`). Esto garantiza que cada profesor y materia tengan una clave primaria (PK) única y robusta.

### `intl: ^0.19.0`

* **¿Para qué se usa?** Para **formatear fechas y horas**.
* **Explicación:** El paquete `intl` (Internacionalización) es la herramienta estándar en Dart para manejar formatos de fechas, horas, monedas y números de manera correcta. En este proyecto, lo usamos para:
    * Formatear la fecha y hora de la firma de asistencia al formato exacto que pediste (`YYYY-MM-DD HH:MM:SS.SSS`).
    * Mostrar las horas en los `TimePicker` (relojes) en formato AM/PM (ej. `7:00 AM a 9:00 AM`).

---

## Explicación de Archivos

### `base.dart` (Clase `DBAsistencia`)

* **¿Para qué se usa?** Es el **controlador de la base de datos**.
* **Explicación:** Piensa en este archivo como el único **"traductor" o "intermediario"** que sabe cómo hablar con la base de datos (SQLite). Ninguna otra parte de la aplicación (como la interfaz de usuario en `pagina.dart`) habla directamente con SQLite.

Sus responsabilidades principales son:

1.  **Conexión y Creación (`_conectarDB`, `onCreate`):** Se encarga de crear el archivo `asistencia_escolar.db` y definir la estructura de todas las tablas (`PROFESOR`, `MATERIA`, `HORARIO`, `ASISTENCIA`) la primera vez que se instala la app.
2.  **Operaciones CRUD (Create, Read, Update, Delete):** Proporciona métodos fáciles de usar para el resto de la app, como `insertarProfesor(...)` o `mostrarHorarios()`. La interfaz de usuario no sabe SQL; simplemente llama a estos métodos.
3.  **Manejo de Datos:** Convierte los objetos de Dart (ej. un objeto `Profesor`) en un mapa que SQLite puede entender (usando `.toMap()`) y hace lo contrario al leer datos (usando `.fromMap()`).
4.  **Consultas Avanzadas:** Contiene las consultas SQL complejas (con `JOIN` y `rawQuery`) necesarias para la pestaña "Consultas", permitiendo cruzar datos de profesores, materias y horarios en un solo reporte.
