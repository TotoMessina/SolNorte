-- ========================================================================================
-- PROCEDIMIENTO PARA IMPORTAR DATOS DE PAGOS DESDE ARCHIVO CSV
-- ========================================================================================
-- Este procedimiento importa pagos desde un archivo CSV (con encabezado),
-- insertando en una tabla staging temporal, validando y luego actualizando la tabla final.

CREATE PROCEDURE Pagos.ImportarPagosDesdeCSV
    @RutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    -- Crear tabla staging temporal
    IF OBJECT_ID('tempdb..#StagingPagos') IS NOT NULL
        DROP TABLE #StagingPagos;

    CREATE TABLE #StagingPagos (
        IdSocio INT,
        Monto DECIMAL(10,2),
        IdMedioPago INT,
        EsReembolso BIT,
        EsPagoCuenta BIT
    );

    -- Importar desde archivo
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = '
    BULK INSERT #StagingPagos
    FROM ''' + @RutaArchivo + '''
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = '','',
        ROWTERMINATOR = ''\n'',
        CODEPAGE = ''65001'',
        TABLOCK
    );';

    BEGIN TRY
        EXEC sp_executesql @SQL;
    END TRY
    BEGIN CATCH
        RAISERROR('Error al importar archivo CSV de pagos.', 16, 1);
        RETURN;
    END CATCH

    -- Validar e insertar pagos válidos
    INSERT INTO Pagos.Pagos (IdSocio, Monto, IdMedioPago, EsReembolso, EsPagoCuenta)
    SELECT s.IdSocio, s.Monto, s.IdMedioPago, s.EsReembolso, s.EsPagoCuenta
    FROM #StagingPagos s
    WHERE s.Monto > 0
      AND EXISTS (SELECT 1 FROM Socios.Socios so WHERE so.IdSocio = s.IdSocio)
      AND EXISTS (SELECT 1 FROM Pagos.MediosPago mp WHERE mp.IdMedioPago = s.IdMedioPago);
END;
GO

-- Comentario: El archivo debe estar accesible desde el motor de SQL Server.
-- Ejemplo de ruta: C:\DatosImportados\MaestroPagos.csv
