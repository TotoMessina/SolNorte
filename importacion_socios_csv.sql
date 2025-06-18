-- ========================================================================================
-- PROCEDIMIENTO PARA IMPORTAR DATOS DE SOCIOS DESDE ARCHIVO CSV
-- ========================================================================================
-- Este procedimiento importa datos desde un archivo CSV (con encabezado), 
-- insertando en una tabla staging temporal, validando y luego actualizando la tabla final.

CREATE PROCEDURE Socios.ImportarSociosDesdeCSV
    @RutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    -- Crear tabla de staging temporal
    IF OBJECT_ID('tempdb..#StagingSocios') IS NOT NULL
        DROP TABLE #StagingSocios;

    CREATE TABLE #StagingSocios (
        DNI CHAR(8),
        Nombre NVARCHAR(100),
        Apellido NVARCHAR(100),
        Email NVARCHAR(100),
        FechaNacimiento DATE,
        Telefono NVARCHAR(20),
        TelefonoEmergencia NVARCHAR(20),
        ObraSocial NVARCHAR(100),
        NumeroSocioObraSocial NVARCHAR(50),
        Categoria NVARCHAR(20)
    );

    -- Importar desde el archivo usando BULK INSERT
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = '
    BULK INSERT #StagingSocios
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
        RAISERROR('Error al importar el archivo CSV. Verifique formato y accesibilidad.', 16, 1);
        RETURN;
    END CATCH

    -- Validar y filtrar datos correctos (no duplicados)
    INSERT INTO Socios.Socios (
        DNI, Nombre, Apellido, Email, FechaNacimiento,
        Telefono, TelefonoEmergencia, ObraSocial,
        NumeroSocioObraSocial, Categoria, Activo
    )
    SELECT
        s.DNI, s.Nombre, s.Apellido, s.Email, s.FechaNacimiento,
        s.Telefono, s.TelefonoEmergencia, s.ObraSocial,
        s.NumeroSocioObraSocial, s.Categoria, 1
    FROM #StagingSocios s
    WHERE NOT EXISTS (
        SELECT 1 FROM Socios.Socios so WHERE so.DNI = s.DNI
    )
    AND ISDATE(s.FechaNacimiento) = 1
    AND LEN(s.DNI) = 8
    AND s.Categoria IN ('Menor', 'Cadete', 'Mayor');

    -- Opcional: insertar en tabla de errores si hace falta (no requerido aún)
END;
GO

-- Comentario: El archivo CSV debe estar accesible desde el servidor de SQL Server.
-- Ejemplo de ruta: C:\DatosImportados\MaestroSocios.csv
