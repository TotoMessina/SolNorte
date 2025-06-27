-- ========================================================================================
-- PROCEDIMIENTOS ALMACENADOS PARA FACTURACIÓN
-- ========================================================================================

-- Inserta una nueva factura con sus detalles
CREATE PROCEDURE Facturacion.GenerarFactura
    @IdSocio INT,
    @FechaVencimiento DATE,
    @Total DECIMAL(10,2),
    @Estado NVARCHAR(20),
    @Items XML -- Ej: <Items><Item><Descripcion>Cuota mensual</Descripcion><Importe>2500</Importe></Item></Items>
AS
BEGIN
    SET NOCOUNT ON;

    IF @Total < 0
    BEGIN
        RAISERROR('El total no puede ser negativo.', 16, 1);
        RETURN;
    END

    IF @Estado NOT IN ('Pendiente', 'Pagada', 'Anulada')
    BEGIN
        RAISERROR('Estado no válido.', 16, 1);
        RETURN;
    END

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Insertar la factura
        INSERT INTO Facturacion.Facturas (IdSocio, FechaVencimiento, Total, Estado)
        VALUES (@IdSocio, @FechaVencimiento, @Total, @Estado);

        DECLARE @IdFactura INT = SCOPE_IDENTITY();

        -- Insertar los ítems
        INSERT INTO Facturacion.DetalleFactura (IdFactura, Descripcion, Importe)
        SELECT @IdFactura,
               Item.value('(Descripcion)[1]', 'NVARCHAR(200)'),
               Item.value('(Importe)[1]', 'DECIMAL(10,2)')
        FROM @Items.nodes('/Items/Item') AS X(Item);

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        RAISERROR('Error al generar factura.', 16, 1);
    END CATCH
END;
GO

-- Anula una factura
CREATE PROCEDURE Facturacion.AnularFactura
    @IdFactura INT
AS
BEGIN
    UPDATE Facturacion.Facturas
    SET Estado = 'Anulada'
    WHERE IdFactura = @IdFactura;
END;
GO

-- Asocia un pago a una factura
CREATE PROCEDURE Facturacion.AsociarPagoAFactura
    @IdFactura INT,
    @IdPago INT
AS
BEGIN
    INSERT INTO Facturacion.PagoFactura (IdFactura, IdPago)
    VALUES (@IdFactura, @IdPago);

    -- Si ya tiene todos los pagos cubiertos, marcar como Pagada
    DECLARE @TotalFactura DECIMAL(10,2) = (SELECT Total FROM Facturacion.Facturas WHERE IdFactura = @IdFactura);
    DECLARE @TotalPagado DECIMAL(10,2) = (
        SELECT SUM(P.Monto)
        FROM Facturacion.PagoFactura PF
        JOIN Pagos.Pagos P ON PF.IdPago = P.IdPago
        WHERE PF.IdFactura = @IdFactura
    );

    IF @TotalPagado >= @TotalFactura
    BEGIN
        UPDATE Facturacion.Facturas
        SET Estado = 'Pagada'
        WHERE IdFactura = @IdFactura;
    END
END;
GO
