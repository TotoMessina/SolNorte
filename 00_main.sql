/* ============================================================================
  Proyecto: Digitalización Administrativa - Institución Sol Norte
  Fecha de entrega: 20/06/2025
  Materia: Bases de Datos Aplicada
  Grupo: Grupo 7
  Integrantes:
    - Lucas Messina - DNI 44552900
============================================================================ */

-- =====================================================================
-- CREACIÓN DE LA BASE DE DATOS Y CONFIGURACIÓN INICIAL
-- =====================================================================
CREATE DATABASE SolNorteDB;
GO

-- Usamos la base de datos recién creada
USE SolNorteDB;
GO

-- =====================================================================
-- CREACIÓN DE ESQUEMAS PARA ORGANIZACIÓN LÓGICA
-- =====================================================================
CREATE SCHEMA Socios;
GO
CREATE SCHEMA Administracion;
GO
CREATE SCHEMA Pagos;
GO
CREATE SCHEMA Facturacion;
GO

-- =====================================================================
-- CREACIÓN DE TABLAS
-- =====================================================================

-- Tabla de Roles de Usuario
CREATE TABLE Administracion.Roles (
    IdRol INT IDENTITY PRIMARY KEY,
    NombreRol NVARCHAR(50) NOT NULL UNIQUE
);

-- Tabla de Usuarios del sistema
CREATE TABLE Administracion.Usuarios (
    IdUsuario INT IDENTITY PRIMARY KEY,
    Usuario NVARCHAR(50) NOT NULL UNIQUE,
    Contraseña NVARCHAR(100) NOT NULL,
    FechaVigencia DATE NOT NULL,
    IdRol INT NOT NULL,
    CONSTRAINT FK_Usuarios_Roles FOREIGN KEY (IdRol) REFERENCES Administracion.Roles(IdRol)
);

-- Tabla de Tutores (para menores)
CREATE TABLE Socios.Tutores (
    IdTutor INT IDENTITY PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL,
    Apellido NVARCHAR(100) NOT NULL,
    DNI CHAR(8) NOT NULL UNIQUE,
    Email NVARCHAR(100) NOT NULL,
    FechaNacimiento DATE NOT NULL,
    Telefono NVARCHAR(20),
    Parentesco NVARCHAR(50)
);

-- Tabla de Socios
CREATE TABLE Socios.Socios (
    IdSocio INT IDENTITY PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL,
    Apellido NVARCHAR(100) NOT NULL,
    DNI CHAR(8) NOT NULL UNIQUE,
    Email NVARCHAR(100) NOT NULL,
    FechaNacimiento DATE NOT NULL,
    Telefono NVARCHAR(20),
    TelefonoEmergencia NVARCHAR(20),
    ObraSocial NVARCHAR(100),
    NumeroSocioObraSocial NVARCHAR(50),
    IdTutor INT NULL,
    Categoria NVARCHAR(20) NOT NULL,
    Activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Socios_Tutor FOREIGN KEY (IdTutor) REFERENCES Socios.Tutores(IdTutor)
);

-- Tabla de Actividades
CREATE TABLE Socios.Actividades (
    IdActividad INT IDENTITY PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL,
    CostoMensual DECIMAL(10,2) NOT NULL CHECK (CostoMensual >= 0)
);

-- Tabla intermedia Socio-Actividad
CREATE TABLE Socios.SocioActividad (
    IdSocio INT NOT NULL,
    IdActividad INT NOT NULL,
    FechaInscripcion DATE NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (IdSocio, IdActividad),
    FOREIGN KEY (IdSocio) REFERENCES Socios.Socios(IdSocio),
    FOREIGN KEY (IdActividad) REFERENCES Socios.Actividades(IdActividad)
);

-- Tabla de Medios de Pago
CREATE TABLE Pagos.MediosPago (
    IdMedioPago INT IDENTITY PRIMARY KEY,
    Medio NVARCHAR(50) NOT NULL UNIQUE
);

-- Tabla de Pagos
CREATE TABLE Pagos.Pagos (
    IdPago INT IDENTITY PRIMARY KEY,
    IdSocio INT NOT NULL,
    FechaPago DATE NOT NULL DEFAULT GETDATE(),
    Monto DECIMAL(10,2) NOT NULL CHECK (Monto > 0),
    IdMedioPago INT NOT NULL,
    EsReembolso BIT DEFAULT 0,
    EsPagoCuenta BIT DEFAULT 0,
    FOREIGN KEY (IdSocio) REFERENCES Socios.Socios(IdSocio),
    FOREIGN KEY (IdMedioPago) REFERENCES Pagos.MediosPago(IdMedioPago)
);

-- Tabla de Facturas
CREATE TABLE Facturacion.Facturas (
    IdFactura INT IDENTITY PRIMARY KEY,
    IdSocio INT NOT NULL,
    FechaEmision DATE NOT NULL DEFAULT GETDATE(),
    FechaVencimiento DATE NOT NULL,
    Estado NVARCHAR(20) CHECK (Estado IN ('Pendiente', 'Pagada', 'Anulada')) NOT NULL,
    Total DECIMAL(10,2) NOT NULL CHECK (Total >= 0),
    FOREIGN KEY (IdSocio) REFERENCES Socios.Socios(IdSocio)
);

-- Tabla de Detalle Factura
CREATE TABLE Facturacion.DetalleFactura (
    IdDetalle INT IDENTITY PRIMARY KEY,
    IdFactura INT NOT NULL,
    Descripcion NVARCHAR(200) NOT NULL,
    Importe DECIMAL(10,2) NOT NULL CHECK (Importe >= 0),
    FOREIGN KEY (IdFactura) REFERENCES Facturacion.Facturas(IdFactura)
);

-- Relación entre Factura y Pago
CREATE TABLE Facturacion.PagoFactura (
    IdFactura INT NOT NULL,
    IdPago INT NOT NULL,
    PRIMARY KEY (IdFactura, IdPago),
    FOREIGN KEY (IdFactura) REFERENCES Facturacion.Facturas(IdFactura),
    FOREIGN KEY (IdPago) REFERENCES Pagos.Pagos(IdPago)
);
