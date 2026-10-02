# Sistema de Gestión Turística - TURISMOPERU_came

## 1. Nombre del proyecto
**TURISMOPERU_came - Proceso de Migración, Importación/Exportación de Datos y Backups**

## 2. Descripción
Proyecto enfocado en la implementación, migración y mantenimiento de la base de datos `TURISMOPERU_came`. Incluye la automatización de procesos ETL (Exportación, Transformación y Carga) de clientes, reservas y lugares turísticos mediante la herramienta BCP de SQL Server, la validación y limpieza de datos en tablas staging, así como la generación de copias de seguridad en formato BACPAC.

## 3. Tecnologías utilizadas
* **Motor de Base de Datos:** Microsoft SQL Server (ODBC Driver 18)
* **Gestor GUI:** SQL Server Management Studio (SSMS) / Azure Data Studio
* **Herramientas CLI:** BCP (Bulk Copy Program), SQLCmd, SqlPackage
* **Control de Versiones:** Git & GitHub

## 4. Requisitos
* Microsoft SQL Server 2019 o superior.
* SQL Server Management Studio (SSMS) versión 18 o superior.
* Drivers ODBC 18 for SQL Server instalados.
* Carpeta local `D:\Migration\` creada para la recepción/lectura de archivos CSV y BACPAC.

## 5. Configuración
1. Clonar este repositorio en tu equipo local:
   ```cmd
   git clone <URL_DE_TU_REPOSITORIO>