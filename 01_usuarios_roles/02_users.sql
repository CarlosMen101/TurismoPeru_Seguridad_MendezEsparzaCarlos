USE TURISMOPERU_came;
GO

-- 1. Usuario para turismo_admin
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'turismo_admin')
BEGIN
    CREATE USER turismo_admin FOR LOGIN turismo_admin;
    -- Se le asigna db_owner al administrador del sistema
    ALTER ROLE db_owner ADD MEMBER turismo_admin;
    PRINT 'Usuario turismo_admin creado y asignado a db_owner.';
END
GO

-- 2. Usuario para turismo_vendedor
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'turismo_vendedor')
BEGIN
    CREATE USER turismo_vendedor FOR LOGIN turismo_vendedor;
    PRINT 'Usuario turismo_vendedor creado correctamente.';
END
GO

-- 3. Usuario para turismo_analista
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'turismo_analista')
BEGIN
    CREATE USER turismo_analista FOR LOGIN turismo_analista;
    PRINT 'Usuario turismo_analista creado correctamente.';
END
GO