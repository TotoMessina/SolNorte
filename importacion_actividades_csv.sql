-- ========================================================================================
-- PROCEDIMIENTO PARA IMPORTAR DATOS DE ACTIVIDADES DESDE ARCHIVO CSV
-- ========================================================================================
-- Este procedimiento importa actividades desde un archivo CSV (con encabezado),
-- insertando en una tabla staging temporal, validando y luego actualizando la tabla final.

CREATE PROCEDURE Socios.ImportarActividadesDesdeCSV
    @RutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    -- Crear tabla de staging temporal
    IF OBJECT_ID('tempdb..#StagingActividades') IS NOT NULL
        DROP TABLE #StagingActividades;

    CREATE TABLE #StagingActividades (
        Nombre NVARCHAR(100),
        CostoMensual DECIMAL(10,2)
    );

    -- Importar desde archivo CSV
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = '
    BULK INSERT #StagingActividades
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
        RAISERROR('Error al importar el archivo CSV de actividades.', 16, 1);
        RETURN;
    END CATCH

    -- Validar e insertar actividades nuevas
    INSERT INTO Socios.Actividades (Nombre, CostoMensual)
    SELECT s.Nombre, s.CostoMensual
    FROM #StagingActividades s
    WHERE NOT EXISTS (
        SELECT 1 FROM Socios.Actividades a WHERE a.Nombre = s.Nombre
    )
    AND s.CostoMensual >= 0;
END;
GO

-- Comentario: El archivo CSV debe estar accesible desde el servidor SQL.
-- Ejemplo: C:\DatosImportados\MaestroActividades.csv
