-- ========================================================================================
-- PROCEDIMIENTOS ALMACENADOS PARA ACTIVIDADES
-- ========================================================================================

-- Inserta una nueva actividad
CREATE PROCEDURE Socios.InsertarActividad
    @Nombre NVARCHAR(100),
    @CostoMensual DECIMAL(10,2)
AS
BEGIN
    IF @CostoMensual < 0
    BEGIN
        RAISERROR('El costo mensual no puede ser negativo.', 16, 1);
        RETURN;
    END

    INSERT INTO Socios.Actividades (Nombre, CostoMensual)
    VALUES (@Nombre, @CostoMensual);
END;
GO

-- Modifica una actividad existente
CREATE PROCEDURE Socios.ModificarActividad
    @IdActividad INT,
    @Nombre NVARCHAR(100),
    @CostoMensual DECIMAL(10,2)
AS
BEGIN
    UPDATE Socios.Actividades
    SET Nombre = @Nombre,
        CostoMensual = @CostoMensual
    WHERE IdActividad = @IdActividad;
END;
GO

-- Elimina una actividad (borrado físico)
CREATE PROCEDURE Socios.EliminarActividad
    @IdActividad INT
AS
BEGIN
    DELETE FROM Socios.Actividades
    WHERE IdActividad = @IdActividad;
END;
GO
