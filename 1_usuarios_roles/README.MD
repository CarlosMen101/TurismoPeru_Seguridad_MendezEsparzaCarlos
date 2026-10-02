## Actividad 4: Principio de Mínimo Privilegio

### Explicación
No es adecuado asignar el rol fijo de base de datos `db_owner` al **vendedor** o al **analista** por las siguientes razones de seguridad:

1. **Violación del Principio de Mínimo Privilegio:** Un usuario debe contar únicamente con las elevaciones indispensables para ejecutar sus tareas funcionales. `db_owner` confiere control total sobre la base de datos (lectura, modificación, eliminación de objetos, asignación de permisos y restauración).
2. **Riesgo de Pérdida o Alteración Indebida de Datos:** Si un vendedor o analista tuviese `db_owner`, podría eliminar accidental o maliciosamente tablas o bases de datos completas (`DROP TABLE`, `DELETE`), comprometiendo la integridad y disponibilidad del sistema.
3. **Escalación de Privilegios y Fuga de Seguridad:** Un analista con `db_owner` podría modificar permisos, crear otros usuarios administradores o alterar la configuración de auditoría y respaldo de la empresa.

---