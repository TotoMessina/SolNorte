-- ========================================================================================
-- SCRIPT DE REPORTES AVANZADOS - SOL NORTE
-- ========================================================================================

-- Crear esquema si no existe
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Reportes')
    EXEC('CREATE SCHEMA Reportes');
GO

-- ========================================================================================
-- TABLA DE ASISTENCIAS (DATOS DE EJEMPLO PARA REPORTES 3 Y 4)
-- ========================================================================================
IF OBJECT_ID('Socios.Asistencias') IS NOT NULL DROP TABLE Socios.Asistencias;
GO
CREATE TABLE Socios.Asistencias (
    IdAsistencia INT IDENTITY PRIMARY KEY,
    IdSocio INT NOT NULL,
    IdActividad INT NOT NULL,
    Fecha DATE NOT NULL,
    Asistio BIT NOT NULL
);
GO

-- Cargar datos de ejemplo
INSERT INTO Socios.Asistencias (IdSocio, IdActividad, Fecha, Asistio)
VALUES
(1, 1, '2025-06-01', 1),
(1, 1, '2025-06-02', 0),
(2, 1, '2025-06-01', 0),
(2, 1, '2025-06-02', 0),
(3, 2, '2025-06-01', 1),
(3, 2, '2025-06-03', 0),
(3, 2, '2025-06-05', 0);
GO

-- ========================================================================================
-- REPORTE 1 - Morosos Recurrentes
-- ========================================================================================
CREATE OR ALTER VIEW Reportes.MorososRecurrentes AS
SELECT
    s.IdSocio AS NroSocio,
    s.Nombre,
    s.Apellido,
    FORMAT(f.FechaVencimiento, 'yyyy-MM') AS MesIncumplido,
    COUNT(*) OVER (PARTITION BY s.IdSocio) AS TotalMorosidades
FROM Socios.Socios s
JOIN Facturacion.Facturas f ON f.IdSocio = s.IdSocio
WHERE f.Estado IN ('Pendiente', 'Anulada')
  AND f.FechaVencimiento BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY s.IdSocio, s.Nombre, s.Apellido, FORMAT(f.FechaVencimiento, 'yyyy-MM')
HAVING COUNT(*) OVER (PARTITION BY s.IdSocio) > 2
ORDER BY TotalMorosidades DESC;
GO

-- ========================================================================================
-- REPORTE 2 - Ingresos mensuales por actividad deportiva
-- ========================================================================================
CREATE OR ALTER VIEW Reportes.IngresosMensualesPorActividad AS
SELECT
    FORMAT(f.FechaEmision, 'yyyy-MM') AS Mes,
    df.Descripcion,
    SUM(df.Importe) AS TotalIngresos
FROM Facturacion.Facturas f
JOIN Facturacion.DetalleFactura df ON f.IdFactura = df.IdFactura
WHERE f.Estado = 'Pagada'
  AND f.FechaEmision >= DATEFROMPARTS(YEAR(GETDATE()), 1, 1)
GROUP BY FORMAT(f.FechaEmision, 'yyyy-MM'), df.Descripcion
ORDER BY Mes;
GO

-- ========================================================================================
-- REPORTE 3 - Inasistencias por categoría y actividad
-- ========================================================================================
CREATE OR ALTER VIEW Reportes.InasistenciasPorCategoriaActividad AS
SELECT
    s.Categoria,
    a.Nombre AS Actividad,
    COUNT(*) AS CantInasistencias
FROM Socios.Asistencias sa
JOIN Socios.Socios s ON s.IdSocio = sa.IdSocio
JOIN Socios.Actividades a ON a.IdActividad = sa.IdActividad
WHERE sa.Asistio = 0
GROUP BY s.Categoria, a.Nombre
ORDER BY CantInasistencias DESC;
GO

-- ========================================================================================
-- REPORTE 4 - Socios con inasistencias a alguna clase
-- ========================================================================================
CREATE OR ALTER VIEW Reportes.SociosConInasistencias AS
SELECT
    s.Nombre,
    s.Apellido,
    DATEDIFF(YEAR, s.FechaNacimiento, GETDATE()) AS Edad,
    s.Categoria,
    a.Nombre AS Actividad
FROM Socios.Asistencias sa
JOIN Socios.Socios s ON s.IdSocio = sa.IdSocio
JOIN Socios.Actividades a ON a.IdActividad = sa.IdActividad
WHERE sa.Asistio = 0
GROUP BY s.Nombre, s.Apellido, s.FechaNacimiento, s.Categoria, a.Nombre;
GO
