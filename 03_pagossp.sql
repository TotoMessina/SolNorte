-- ========================================================================================
-- PROCEDIMIENTOS ALMACENADOS PARA PAGOS
-- ========================================================================================

-- Inserta un nuevo medio de pago
CREATE PROCEDURE Pagos.InsertarMedioPago
    @Medio NVARCHAR(50)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Pagos.MediosPago WHERE Medio = @Medio)
    BEGIN
        RAISERROR('El medio de pago ya existe.', 16, 1);
        RETURN;
    END

    INSERT INTO Pagos.MediosPago (Medio)
    VALUES (@Medio);
END;
GO

-- Inserta un nuevo pago
CREATE PROCEDURE Pagos.InsertarPago
    @IdSocio INT,
    @Monto DECIMAL(10,2),
    @IdMedioPago INT,
    @EsReembolso BIT = 0,
    @EsPagoCuenta BIT = 0
AS
BEGIN
    IF @Monto <= 0
    BEGIN
        RAISERROR('El monto debe ser mayor a cero.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Socios.Socios WHERE IdSocio = @IdSocio)
    BEGIN
        RAISERROR('Socio no válido.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Pagos.MediosPago WHERE IdMedioPago = @IdMedioPago)
    BEGIN
        RAISERROR('Medio de pago no válido.', 16, 1);
        RETURN;
    END

    INSERT INTO Pagos.Pagos (IdSocio, Monto, IdMedioPago, EsReembolso, EsPagoCuenta)
    VALUES (@IdSocio, @Monto, @IdMedioPago, @EsReembolso, @EsPagoCuenta);
END;
GO