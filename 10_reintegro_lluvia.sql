-- Crear esquema Clima
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Clima')
    EXEC('CREATE SCHEMA Clima');
GO

-- Crear tabla de clima
CREATE TABLE Clima.RegistroMeteorologico (
    Fecha DATE PRIMARY KEY,
    Precipitacion DECIMAL(5,2),
    TemperaturaMin DECIMAL(5,2),
    TemperaturaMax DECIMAL(5,2)
);
GO

-- SP: Importar datos climáticos
CREATE OR ALTER PROCEDURE Clima.ImportarDatosClimaticosDesdeCSV
    @RutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    IF OBJECT_ID('tempdb..#StagingClima') IS NOT NULL
        DROP TABLE #StagingClima;

    CREATE TABLE #StagingClima (
        Fecha DATE,
        Precipitacion DECIMAL(5,2),
        TemperaturaMin DECIMAL(5,2),
        TemperaturaMax DECIMAL(5,2)
    );

    DECLARE @SQL NVARCHAR(MAX) = '
    BULK INSERT #StagingClima
    FROM ''' + @RutaArchivo + '''
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = '','',
        ROWTERMINATOR = ''\n'',
        CODEPAGE = ''65001'',
        TABLOCK
    );';

    EXEC sp_executesql @SQL;

    INSERT INTO Clima.RegistroMeteorologico
    SELECT * FROM #StagingClima s
    WHERE NOT EXISTS (
        SELECT 1 FROM Clima.RegistroMeteorologico c WHERE c.Fecha = s.Fecha
    );
END;
GO

-- Crear tabla si no existe
IF OBJECT_ID('Socios.PiletaEntradas') IS NULL
CREATE TABLE Socios.PiletaEntradas (
    IdEntrada INT IDENTITY PRIMARY KEY,
    IdSocio INT NOT NULL,
    Fecha DATE NOT NULL,
    EsInvitado BIT DEFAULT 0,
    Monto DECIMAL(10,2) NOT NULL
);
GO

-- SP: Generar reintegros por lluvia
CREATE OR ALTER PROCEDURE Pileta.GenerarReintegrosPorLluvia
    @Desde DATE,
    @Hasta DATE
AS
BEGIN
    INSERT INTO Pagos.Pagos (IdSocio, FechaPago, Monto, IdMedioPago, EsReembolso, EsPagoCuenta)
    SELECT pe.IdSocio, GETDATE(), ROUND(pe.Monto * 0.6, 2), 1, 1, 1
    FROM Socios.PiletaEntradas pe
    JOIN Clima.RegistroMeteorologico c ON pe.Fecha = c.Fecha
    WHERE c.Precipitacion > 0
      AND pe.Fecha BETWEEN @Desde AND @Hasta
      AND NOT EXISTS (
          SELECT 1 FROM Pagos.Pagos p
          WHERE p.IdSocio = pe.IdSocio
          AND p.Monto = ROUND(pe.Monto * 0.6, 2)
          AND p.FechaPago = GETDATE()
          AND p.EsPagoCuenta = 1
      );
END;
GO
