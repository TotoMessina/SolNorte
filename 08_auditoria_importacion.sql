-- ========================================================================================
-- TABLA DE LOG DE IMPORTACIÓN Y PROCEDIMIENTO PARA REGISTRAR ERRORES
-- ========================================================================================

CREATE SCHEMA Auditoria;
GO

-- Tabla de log general de importaciones
CREATE TABLE Auditoria.ImportacionLog (
    IdLog INT IDENTITY PRIMARY KEY,
    Maestro NVARCHAR(50),
    Archivo NVARCHAR(500),
    Fecha DATETIME DEFAULT GETDATE(),
    RegistrosExitosos INT,
    RegistrosFallidos INT,
    Mensaje NVARCHAR(1000)
);

-- Tabla de errores detallados
CREATE TABLE Auditoria.ImportacionErrores (
    IdError INT IDENTITY PRIMARY KEY,
    Maestro NVARCHAR(50),
    Campo NVARCHAR(100),
    Valor NVARCHAR(500),
    DescripcionError NVARCHAR(1000),
    Fecha DATETIME DEFAULT GETDATE()
);

-- Procedimiento para registrar errores (puede ser llamado desde otros SP)
CREATE PROCEDURE Auditoria.RegistrarErrorImportacion
    @Maestro NVARCHAR(50),
    @Campo NVARCHAR(100),
    @Valor NVARCHAR(500),
    @DescripcionError NVARCHAR(1000)
AS
BEGIN
    INSERT INTO Auditoria.ImportacionErrores (Maestro, Campo, Valor, DescripcionError)
    VALUES (@Maestro, @Campo, @Valor, @DescripcionError);
END;
GO
