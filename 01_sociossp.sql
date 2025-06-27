-- ========================================================================================
-- PROCEDIMIENTOS ALMACENADOS PARA SOCIOS
-- ========================================================================================

-- Inserta un nuevo socio
CREATE PROCEDURE Socios.InsertarSocio
    @Nombre NVARCHAR(100),
    @Apellido NVARCHAR(100),
    @DNI CHAR(8),
    @Email NVARCHAR(100),
    @FechaNacimiento DATE,
    @Telefono NVARCHAR(20),
    @TelefonoEmergencia NVARCHAR(20),
    @ObraSocial NVARCHAR(100),
    @NumeroSocioObraSocial NVARCHAR(50),
    @IdTutor INT = NULL,
    @Categoria NVARCHAR(20)
AS
BEGIN
    -- Validaciones básicas
    IF LEN(@DNI) != 8 OR @DNI NOT LIKE '%[0-9]%'
    BEGIN
        RAISERROR('DNI inválido.', 16, 1);
        RETURN;
    END

    IF @Categoria NOT IN ('Menor', 'Cadete', 'Mayor')
    BEGIN
        RAISERROR('Categoría no válida.', 16, 1);
        RETURN;
    END

    INSERT INTO Socios.Socios (
        Nombre, Apellido, DNI, Email, FechaNacimiento,
        Telefono, TelefonoEmergencia, ObraSocial,
        NumeroSocioObraSocial, IdTutor, Categoria, Activo
    )
    VALUES (
        @Nombre, @Apellido, @DNI, @Email, @FechaNacimiento,
        @Telefono, @TelefonoEmergencia, @ObraSocial,
        @NumeroSocioObraSocial, @IdTutor, @Categoria, 1
    );
END;
GO

-- Modifica un socio existente
CREATE PROCEDURE Socios.ModificarSocio
    @IdSocio INT,
    @Nombre NVARCHAR(100),
    @Apellido NVARCHAR(100),
    @Email NVARCHAR(100),
    @Telefono NVARCHAR(20),
    @TelefonoEmergencia NVARCHAR(20),
    @ObraSocial NVARCHAR(100),
    @NumeroSocioObraSocial NVARCHAR(50),
    @Categoria NVARCHAR(20)
AS
BEGIN
    UPDATE Socios.Socios
    SET Nombre = @Nombre,
        Apellido = @Apellido,
        Email = @Email,
        Telefono = @Telefono,
        TelefonoEmergencia = @TelefonoEmergencia,
        ObraSocial = @ObraSocial,
        NumeroSocioObraSocial = @NumeroSocioObraSocial,
        Categoria = @Categoria
    WHERE IdSocio = @IdSocio;
END;
GO

-- Borrado lógico de un socio
CREATE PROCEDURE Socios.DesactivarSocio
    @IdSocio INT
AS
BEGIN
    UPDATE Socios.Socios
    SET Activo = 0
    WHERE IdSocio = @IdSocio;
END;
GO
