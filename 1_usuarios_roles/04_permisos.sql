USE TURISMOPERU_came;
GO

----------------------------------------------------
-- PERMISOS PARA ROL: rol_vendedor
----------------------------------------------------
-- Permisos de lectura e inserción requeridos
GRANT SELECT, INSERT ON came.cliente TO rol_vendedor;
GRANT SELECT, INSERT ON came.reserva TO rol_vendedor;
GRANT SELECT ON came.alojamiento TO rol_vendedor;
GRANT SELECT ON came.habitacion TO rol_vendedor;

-- Restricción explícita de eliminación
DENY DELETE ON came.cliente TO rol_vendedor;
DENY DELETE ON came.reserva TO rol_vendedor;
GO

----------------------------------------------------
-- PERMISOS PARA ROL: rol_analista
----------------------------------------------------
-- Permisos de lectura únicamente sobre las tablas especificadas
GRANT SELECT ON came.cliente TO rol_analista;
GRANT SELECT ON came.reserva TO rol_analista;
GRANT SELECT ON came.pago TO rol_analista;
GRANT SELECT ON came.alojamiento TO rol_analista;
GRANT SELECT ON came.habitacion TO rol_analista;
GRANT SELECT ON came.paquete TO rol_analista;
GRANT SELECT ON came.lugar_turistico TO rol_analista;

-- Denegación explícita de modificación (INSERT, UPDATE, DELETE) en el esquema came
DENY INSERT, UPDATE, DELETE ON SCHEMA::came TO rol_analista;
GO