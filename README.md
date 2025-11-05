
---

# Proyecto de Gestión de Asistencia Escolar

Esta es una aplicación móvil desarrollada en Flutter para la gestión y control de la asistencia de profesores, materias y horarios en una institución.

---

## Dependencias Clave del Proyecto

Este proyecto utiliza varios paquetes de Dart/Flutter para funcionar. A continuación se describe para qué se utiliza cada uno:

### `sqflite: ^2.4.2` (o similar)

* **¿Para qué se usa?** Es la **Base de Datos** principal de la aplicación.
* **Explicación:** `sqflite` es el paquete que permite a Flutter utilizar **SQLite**, una base de datos SQL local que se guarda directamente en el teléfono (Android o iOS). En este proyecto, se usa para almacenar de forma persistente toda la información:
    * La tabla `PROFESOR`
    * La tabla `MATERIA`
    * La tabla `HORARIO`
    * La tabla `ASISTENCIA`

### `path: ^1.9.0` (o similar)

* **¿Para qué se usa?** Para **encontrar la ubicación** de la base de datos.
* **Explicación:** `sqflite` necesita saber *dónde* guardar el archivo de la base de datos (ej. `asistencia_escolar.db`) en el sistema de archivos del teléfono. El paquete `path` (específicamente su función `join`) nos ayuda a construir una ruta de archivo válida (ej. `/data/user/0/.../databases/asistencia_escolar.db`) que funciona correctamente tanto en Android como en iOS.

---

## Explicación de Archivos

### `base.dart` (Clase `DBAsistencia`)

* **¿Para qué se usa?** Es el **controlador de la base de datos**.
* **Explicación:** Piensa en este archivo como el único **"traductor" o "intermediario"** que sabe cómo hablar con la base de datos (SQLite). Ninguna otra parte de la aplicación (como la interfaz de usuario en `APP03.dart`) habla directamente con SQLite.

Sus responsabilidades principales son:

1.  **Conexión y Creación (`_conectarDB`, `onCreate`):** Se encarga de crear el archivo `asistencia_escolar.db` y definir la estructura de todas las tablas (`PROFESOR`, `MATERIA`, `HORARIO`, `ASISTENCIA`) la primera vez que se instala la app.
2.  **Operaciones CRUD (Create, Read, Update, Delete):** Proporciona métodos fáciles de usar para el resto de la app, como `insertarProfesor(...)` o `mostrarHorarios()`. La interfaz de usuario no sabe SQL; simplemente llama a estos métodos.
3.  **Consultas Avanzadas:** Contiene las consultas SQL complejas (con `JOIN` y `rawQuery`) necesarias para la pestaña "Consultas", permitiendo cruzar datos de profesores, materias y horarios en un solo reporte.

### `modelos/` (`profesor.dart`, `materia.dart`, `horario.dart`, `asistencia.dart`)

* **¿Para qué se usan?** Son los **"moldes" de los datos** de la aplicación.
* **Explicación:** Cada archivo define una clase de Dart (ej. `Profesor`) que representa una fila de la base de datos. Su trabajo es estructurar la información y contener las funciones clave `toMap()` (para convertir el objeto de Dart en un mapa para la DB) y `fromMap()` (para convertir el mapa de la DB en un objeto de Dart).

### `APP03.dart` (La Interfaz de Usuario Principal)

* **¿Para qué se usa?** Es la **pantalla principal** y el "cerebro" de la aplicación.
* **Explicación:** Este archivo `StatefulWidget` controla todo lo que el usuario ve y hace. Sus responsabilidades incluyen:
    * **Dibujar la UI:** Contiene el `Scaffold`, `AppBar`, y el `Drawer` (menú lateral).
    * **Navegación:** Maneja la lógica para cambiar entre las diferentes secciones (Profesores, Materias, Horarios, Asistencias, Consultas).
    * **Gestión de Estado:** Almacena en listas (`_profesores`, `_horarios`, etc.) la información actual que se muestra en pantalla.
    * **Formularios y Alertas:** Muestra los formularios para capturar nuevos datos y los diálogos de alerta.
    * **Lógica de Botones:** Cuando el usuario presiona "Guardar" o "Eliminar", este archivo llama al método correspondiente en `base.dart` y luego actualiza la pantalla (`setState`).
    * **Modo Oscuro:** Contiene la lógica del `colorsw` para alternar los temas.

### `main.dart` (Punto de Entrada de la App)

* **¿Para qué se usa?** Es el **arranque** de la aplicación.
* **Explición:** Este es el primer archivo que se ejecuta. Su única tarea es iniciar la aplicación. Contiene:
    * La función `main()`.
    * El widget `MaterialApp`, que es el "abuelo" de toda la aplicación.
    * La configuración del tema de color principal (como el `Colors.deepOrange`).
    * *(Opcional)* La configuración de localización (si se usaran widgets como calendarios).
    * Define `APP03()` como la página `home` (principal).

---
