USE TURISMOPERU_came;
GO

-- ============================================================================
-- PROCESO ETL Y MIGRACIÓN MASIVA DE DATOS (ACTIVIDAD 5)
-- Base de datos: TURISMOPERU_came
-- ============================================================================

/*
==============================================================================
 COMANDOS BCP (Ejecutar desde el Símbolo del Sistema / CMD)
==============================================================================

--- EXPORTACIÓN (queryout) ---
bcp "SELECT p.numero_documento, p.nombres, p.apaterno, p.amaterno FROM TURISMOPERU_came.came.persona p INNER JOIN TURISMOPERU_came.came.cliente c ON p.id_persona = c.id_persona" queryout "D:\Migration\clientes.csv" -c -t "," -r \n -S 161.132.54.162 -U estudiante -P Unc.2026 -C RAW -u
bcp "SELECT codigo_reserva, id_cliente, id_paquete, id_empleado, id_alojamiento, id_habitacion, fecha_reserva, fecha_inicio, fecha_fin, numero_personas, precio_total, adelanto, saldo_pendiente, id_estado_reserva, observaciones FROM TURISMOPERU_came.came.reserva" queryout "D:\Migration\reservas.csv" -c -t "," -r \n -S 161.132.54.162 -U estudiante -P Unc.2026 -C RAW -u
bcp "SELECT id_reserva, id_medio_pago, monto, fecha_pago, numero_operacion, comprobante, estado FROM TURISMOPERU_came.came.pago" queryout "D:\Migration\pago.csv" -c -t "," -r \n -S 161.132.54.162 -U estudiante -P Unc.2026 -C RAW -u
bcp "SELECT nombre, descripcion, precio_entrada, horario_apertura, horario_cierre, calificacion, estado FROM TURISMOPERU_came.came.lugar_turistico" queryout "D:\Migration\lugaresturtisticos.csv" -c -t "," -r \n -S 161.132.54.162 -U estudiante -P Unc.2026 -C RAW -u

--- IMPORTACIÓN (in) ---
bcp TURISMOPERU_came.came.cliente_importacion in "D:\Migration\clientes.csv" -c -t "," -r \n -S 161.132.54.162 -U estudiante -P Unc.2026 -C RAW -u
bcp TURISMOPERU_came.came.lugar_turistico_importacion in "D:\Migration\lugaresturtisticos.csv" -c -t "," -r \n -S 161.132.54.162 -U estudiante -P Unc.2026 -C RAW -u
bcp TURISMOPERU_came.came.reserva_importacion in "D:\Migration\reservas.csv" -c -t "," -r \n -S 161.132.54.162 -U estudiante -P Unc.2026 -C RAW -u
==============================================================================
*/

-- ============================================================================
-- SECCIÓN 1: IMPORTACIÓN Y MIGRACIÓN DE CLIENTES
-- ============================================================================

-- 1.1 Crear tabla staging para clientes
IF OBJECT_ID('came.cliente_importacion', 'U') IS NOT NULL
BEGIN
    DROP TABLE came.cliente_importacion;
    PRINT 'Tabla previa came.cliente_importacion eliminada.';
END
GO

CREATE TABLE came.cliente_importacion (
    Documento NVARCHAR(MAX),
    Nombres NVARCHAR(MAX),
    ApellidoPaterno NVARCHAR(MAX),
    ApellidoMaterno NVARCHAR(MAX)
);
PRINT 'Tabla staging came.cliente_importacion creada correctamente.';
GO

-- 1.2 Consultas de Validación e Identificación de Duplicados (Ejecutar tras BCP)
-- Ver contenido staging
SELECT * FROM came.cliente_importacion;

-- Validar registros nulos o inválidos
SELECT * 
FROM came.cliente_importacion
WHERE Documento IS NULL OR LTRIM(RTRIM(Documento)) = '';

-- Identificar duplicados dentro del staging
SELECT Documento, COUNT(*) AS repeticiones
FROM came.cliente_importacion
GROUP BY Documento
HAVING COUNT(*) > 1;

-- Identificar registros que ya existen en la base de datos (tabla persona)
SELECT ci.*
FROM came.cliente_importacion ci
INNER JOIN came.persona p ON LTRIM(RTRIM(ci.Documento)) = p.numero_documento;
GO

-- 1.3 Inserción transaccional de registros válidos en persona y cliente
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @NuevasPersonas TABLE (id_persona INT);

    INSERT INTO came.persona (
        tipo_persona, 
        nombres, 
        apaterno, 
        amaterno, 
        razon_social, 
        id_tipo_documento, 
        numero_documento, 
        id_nacionalidad, 
        estado, 
        fecha_registro
    )
    OUTPUT INSERTED.id_persona INTO @NuevasPersonas(id_persona)
    SELECT DISTINCT
        'N' AS tipo_persona,
        LTRIM(RTRIM(ci.Nombres)),
        LTRIM(RTRIM(ci.ApellidoPaterno)),
        LTRIM(RTRIM(ci.ApellidoMaterno)),
        LTRIM(RTRIM(ci.Nombres + ' ' + ci.ApellidoPaterno)),
        1 AS id_tipo_documento,                              -- 1 = DNI
        LTRIM(RTRIM(ci.Documento)),
        1 AS id_nacionalidad,                                -- 1 = Peruana
        'Activo' AS estado,
        GETDATE() AS fecha_registro
    FROM came.cliente_importacion ci
    WHERE ci.Documento IS NOT NULL 
      AND LTRIM(RTRIM(ci.Documento)) <> ''
      AND NOT EXISTS (
          SELECT 1 
          FROM came.persona p 
          WHERE p.numero_documento = LTRIM(RTRIM(ci.Documento))
      );

    INSERT INTO came.cliente (id_persona, fecha_nacimiento)
    SELECT 
        np.id_persona, 
        NULL AS fecha_nacimiento
    FROM @NuevasPersonas np;

    COMMIT TRANSACTION;
    PRINT 'Clientes importados e insertados exitosamente.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error durante la inserción de clientes: ' + ERROR_MESSAGE();
END CATCH;
GO


-- ============================================================================
-- SECCIÓN 2: IMPORTACIÓN Y MIGRACIÓN DE LUGARES TURÍSTICOS
-- ============================================================================

-- 2.1 Crear tabla staging para lugares turísticos
IF OBJECT_ID('came.lugar_turistico_importacion', 'U') IS NOT NULL
BEGIN
    DROP TABLE came.lugar_turistico_importacion;
    PRINT 'Tabla previa came.lugar_turistico_importacion eliminada.';
END
GO

CREATE TABLE came.lugar_turistico_importacion (
    nombre NVARCHAR(MAX),
    descripcion NVARCHAR(MAX),
    precio_entrada NVARCHAR(MAX),
    horario_apertura NVARCHAR(MAX),
    horario_cierre NVARCHAR(MAX),
    calificacion NVARCHAR(MAX),
    estado NVARCHAR(MAX)
);
PRINT 'Tabla staging came.lugar_turistico_importacion creada correctamente.';
GO

-- 2.2 Migración segura a la tabla principal came.lugar_turistico (Ejecutar tras BCP)
INSERT INTO came.lugar_turistico (
    nombre, 
    descripcion, 
    precio_entrada, 
    horario_apertura, 
    horario_cierre, 
    calificacion, 
    estado
)
SELECT 
    LTRIM(RTRIM(nombre)), 
    LTRIM(RTRIM(descripcion)), 
    ISNULL(TRY_CAST(REPLACE(precio_entrada, ',', '.') AS DECIMAL(10,2)), 0.00), 
    TRY_CAST(horario_apertura AS TIME), 
    TRY_CAST(horario_cierre AS TIME), 
    ISNULL(TRY_CAST(REPLACE(calificacion, ',', '.') AS DECIMAL(3,2)), 0.00), 
    ISNULL(LTRIM(RTRIM(estado)), 'Activo')
FROM came.lugar_turistico_importacion
WHERE nombre IS NOT NULL AND LTRIM(RTRIM(nombre)) <> '';

PRINT 'Lugares turísticos migrados correctamente.';
GO


-- ============================================================================
-- SECCIÓN 3: IMPORTACIÓN Y MIGRACIÓN DE RESERVAS
-- ============================================================================

-- 3.1 Crear tabla staging para reservas
IF OBJECT_ID('came.reserva_importacion', 'U') IS NOT NULL
BEGIN
    DROP TABLE came.reserva_importacion;
    PRINT 'Tabla previa came.reserva_importacion eliminada.';
END
GO

CREATE TABLE came.reserva_importacion (
    codigo_reserva NVARCHAR(MAX),
    id_cliente NVARCHAR(MAX),
    id_paquete NVARCHAR(MAX),
    id_empleado NVARCHAR(MAX),
    id_alojamiento NVARCHAR(MAX),
    id_habitacion NVARCHAR(MAX),
    fecha_reserva NVARCHAR(MAX),
    fecha_inicio NVARCHAR(MAX),
    fecha_fin NVARCHAR(MAX),
    numero_personas NVARCHAR(MAX),
    precio_total NVARCHAR(MAX),
    adelanto NVARCHAR(MAX),
    saldo_pendiente NVARCHAR(MAX),
    id_estado_reserva NVARCHAR(MAX),
    observaciones NVARCHAR(MAX)
);
PRINT 'Tabla staging came.reserva_importacion creada correctamente.';
GO

-- 3.2 Migración segura a la tabla principal came.reserva (Ejecutar tras BCP)
INSERT INTO came.reserva (
    codigo_reserva,
    id_cliente,
    id_paquete,
    id_empleado,
    id_alojamiento,
    id_habitacion,
    fecha_reserva,
    fecha_inicio,
    fecha_fin,
    numero_personas,
    precio_total,
    adelanto,
    saldo_pendiente,
    id_estado_reserva,
    observaciones
)
SELECT 
    LTRIM(RTRIM(codigo_reserva)),
    TRY_CAST(id_cliente AS INT),
    TRY_CAST(id_paquete AS INT),
    TRY_CAST(id_empleado AS INT),
    TRY_CAST(id_alojamiento AS INT),
    TRY_CAST(id_habitacion AS INT),
    TRY_CAST(fecha_reserva AS DATETIME),
    TRY_CAST(fecha_inicio AS DATE),
    TRY_CAST(fecha_fin AS DATE),
    TRY_CAST(numero_personas AS INT),
    ISNULL(TRY_CAST(REPLACE(precio_total, ',', '.') AS DECIMAL(10,2)), 0.00),
    ISNULL(TRY_CAST(REPLACE(adelanto, ',', '.') AS DECIMAL(10,2)), 0.00),
    ISNULL(TRY_CAST(REPLACE(saldo_pendiente, ',', '.') AS DECIMAL(10,2)), 0.00),
    TRY_CAST(id_estado_reserva AS INT),
    LTRIM(RTRIM(observaciones))
FROM came.reserva_importacion
WHERE codigo_reserva IS NOT NULL AND LTRIM(RTRIM(codigo_reserva)) <> '';

PRINT 'Reservas migradas correctamente.';
GO