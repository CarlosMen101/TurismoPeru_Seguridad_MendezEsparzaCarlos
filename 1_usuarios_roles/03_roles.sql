USE TURISMOPERU_came;
GO

-- 1. Crear rol_vendedor
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'rol_vendedor' AND type = 'R')
BEGIN
    CREATE ROLE rol_vendedor;
    PRINT 'Rol rol_vendedor creado.';
END
GO

-- 2. Crear rol_analista
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'rol_analista' AND type = 'R')
BEGIN
    CREATE ROLE rol_analista;
    PRINT 'Rol rol_analista creado.';
END
GO

-- 3. Asignar los usuarios a sus respectivos roles
ALTER ROLE rol_vendedor ADD MEMBER turismo_vendedor;
ALTER ROLE rol_analista ADD MEMBER turismo_analista;
GO
PRINT 'Usuarios agregados a sus respectivos roles.';