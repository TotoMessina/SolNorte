-- ========================================================================================
-- JUEGOS DE PRUEBA - PROYECTO SOL NORTE
-- Incluye pruebas básicas para validar el correcto funcionamiento de los procedimientos
-- ========================================================================================

USE SolNorteDB;
GO

-- ========================================================================================
-- CARGA INICIAL DE DATOS BÁSICOS
-- ========================================================================================

-- Insertar roles
INSERT INTO Administracion.Roles (NombreRol) VALUES ('Administrador'), ('Operador'), ('Consulta');

-- Insertar usuarios
INSERT INTO Administracion.Usuarios (Usuario, Contraseña, FechaVigencia, IdRol)
VALUES ('admin', 'Admin#2025', '2025-12-31', 1);

-- Insertar medios de pago
EXEC Pagos.InsertarMedioPago @Medio = 'Visa';
EXEC Pagos.InsertarMedioPago @Medio = 'MasterCard';
EXEC Pagos.InsertarMedioPago @Medio = 'Pago Fácil';

-- ========================================================================================
-- PRUEBAS DE SOCIOS
-- ========================================================================================

-- Insertar tutor
INSERT INTO Socios.Tutores (Nombre, Apellido, DNI, Email, FechaNacimiento, Telefono, Parentesco)
VALUES ('Carlos', 'Gómez', '30123456', 'carlos@example.com', '1980-05-10', '1133445566', 'Padre');

-- Insertar socio menor
EXEC Socios.InsertarSocio
    @Nombre = 'Lucía',
    @Apellido = 'Gómez',
    @DNI = '47223311',
    @Email = 'lucia@example.com',
    @FechaNacimiento = '2012-06-15',
    @Telefono = '1178990011',
    @TelefonoEmergencia = '1130004000',
    @ObraSocial = 'OSDE',
    @NumeroSocioObraSocial = 'OSD202212',
    @IdTutor = 1,
    @Categoria = 'Menor';

-- Insertar socio mayor
EXEC Socios.InsertarSocio
    @Nombre = 'Marcos',
    @Apellido = 'Fernández',
    @DNI = '39221133',
    @Email = 'marcos@example.com',
    @FechaNacimiento = '1990-08-22',
    @Telefono = '1166007788',
    @TelefonoEmergencia = '1155667788',
    @ObraSocial = 'SwissMedical',
    @NumeroSocioObraSocial = 'SWISSMED45',
    @IdTutor = NULL,
    @Categoria = 'Mayor';

-- Modificar socio
EXEC Socios.ModificarSocio
    @IdSocio = 2,
    @Nombre = 'Marcos A.',
    @Apellido = 'Fernández',
    @Email = 'marcosa@example.com',
    @Telefono = '1199001122',
    @TelefonoEmergencia = '1155667788',
    @ObraSocial = 'Medicus',
    @NumeroSocioObraSocial = 'MED999',
    @Categoria = 'Mayor';

-- Desactivar socio
EXEC Socios.DesactivarSocio @IdSocio = 2;

-- ========================================================================================
-- PRUEBAS DE ACTIVIDADES
-- ========================================================================================

-- Insertar actividades
EXEC Socios.InsertarActividad @Nombre = 'Natación', @CostoMensual = 4500;
EXEC Socios.InsertarActividad @Nombre = 'Taekwondo', @CostoMensual = 3000;

-- Modificar actividad
EXEC Socios.ModificarActividad @IdActividad = 2, @Nombre = 'Taekwondo Avanzado', @CostoMensual = 3500;

-- Eliminar actividad
EXEC Socios.EliminarActividad @IdActividad = 2;

-- ========================================================================================
-- PRUEBAS DE PAGOS
-- ========================================================================================

-- Insertar pago válido
EXEC Pagos.InsertarPago
    @IdSocio = 1,
    @Monto = 5000,
    @IdMedioPago = 1,
    @EsReembolso = 0,
    @EsPagoCuenta = 0;

-- ========================================================================================
-- PRUEBAS DE FACTURACIÓN
-- ========================================================================================

-- Crear factura con ítems en XML
DECLARE @Items XML = '
<Items>
    <Item>
        <Descripcion>Cuota mensual junio</Descripcion>
        <Importe>3500</Importe>
    </Item>
    <Item>
        <Descripcion>Natación junio</Descripcion>
        <Importe>4500</Importe>
    </Item>
</Items>';

EXEC Facturacion.GenerarFactura
    @IdSocio = 1,
    @FechaVencimiento = '2025-06-25',
    @Total = 8000,
    @Estado = 'Pendiente',
    @Items = @Items;

-- Asociar pago a factura
EXEC Facturacion.AsociarPagoAFactura @IdFactura = 1, @IdPago = 1;

-- Anular factura
EXEC Facturacion.AnularFactura @IdFactura = 1;


-- ========================================================================================
-- PRUEBAS DE IMPORTACIÓN DE ARCHIVOS CSV
-- ========================================================================================
-- Simula la ejecución de los procedimientos de importación con rutas de ejemplo.
-- Las rutas deben ser modificadas al entorno del servidor SQL real.

-- IMPORTANTE: Reemplazar las rutas con las correspondientes al entorno de ejecución
DECLARE @RutaSocios NVARCHAR(500) = 'C:\DatosImportados\MaestroSocios.csv';
DECLARE @RutaActividades NVARCHAR(500) = 'C:\DatosImportados\MaestroActividades.csv';
DECLARE @RutaPagos NVARCHAR(500) = 'C:\DatosImportados\MaestroPagos.csv';

-- Ejecutar importación de socios
EXEC Socios.ImportarSociosDesdeCSV @RutaArchivo = @RutaSocios;

-- Ejecutar importación de actividades
EXEC Socios.ImportarActividadesDesdeCSV @RutaArchivo = @RutaActividades;

-- Ejecutar importación de pagos
EXEC Pagos.ImportarPagosDesdeCSV @RutaArchivo = @RutaPagos;
