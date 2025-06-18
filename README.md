# Proyecto Base de Datos - Sol Norte

Este repositorio contiene la implementación de una base de datos relacional en SQL Server para la institución deportiva **Sol Norte**, cuyo objetivo es digitalizar los procesos de inscripción, facturación, morosidad y cobranza.

---

## 📂 Contenido

- `main.sql`  
  Script completo de creación de base de datos, esquemas, tablas, claves y restricciones.

- `sociossp.sql`  
  Procedimientos para gestionar Socios (altas, modificaciones, bajas lógicas).

- `actividadessp.sql`  
  Procedimientos para gestionar Actividades.

- `pagossp.sql`  
  Procedimientos para registrar pagos y medios de pago.

- `facturacionsp.sql`  
  Procedimientos para facturación: generar facturas, asociar pagos y anularlas.

- `pruebas.sql`  
  Script de pruebas con ejemplos funcionales y casos de validación.

- `DER.png`  
  Diagrama entidad-relación (DER) del modelo lógico diseñado.


---

## 📥 Importación de archivos CSV

El sistema permite importar datos periódicos desde archivos `.csv` mediante procedimientos almacenados que aseguran:

- Validación de campos (formatos, duplicados, valores obligatorios)
- Carga incremental sin duplicar datos existentes
- Transformaciones internas en SQL Server

### Procedimientos disponibles

- `Socios.ImportarSociosDesdeCSV(@RutaArchivo NVARCHAR)`  
- `Socios.ImportarActividadesDesdeCSV(@RutaArchivo NVARCHAR)`  
- `Pagos.ImportarPagosDesdeCSV(@RutaArchivo NVARCHAR)`

### Formato esperado

- Archivos `.csv` codificados en UTF-8
- Encabezado en la primera fila
- Separador: coma (`,`)

### Rutas de ejemplo

> Las rutas deben apuntar a carpetas accesibles por el servidor SQL Server.  
> Ejemplo: `C:\DatosImportados\MaestroSocios.csv`

### Archivos de ejemplo incluidos

- `MaestroSocios.csv`
- `MaestroActividades.csv`
- `MaestroPagos.csv`

Estas pruebas pueden ejecutarse con el script `pruebas.sql` que ya incluye llamadas de ejemplo.


---

## 🛠️ Requisitos

- SQL Server 2022 o superior
- SQL Server Management Studio (SSMS)
- Habilitar autenticación mixta y TCP/IP

---

## 👨‍💻 Autor

- Lucas Messina – DNI 44552900  
Grupo 7 – Materia: Bases de Datos Aplicada

---

## 📝 Notas

- Se respetaron buenas prácticas de modelado, normalización y seguridad.
- Todos los procedimientos usan validaciones básicas para datos críticos.