CREATE DATABASE HuellasVerdes
GO
-- Usando la base de datos creada
USE HuellasVerdes
GO
-- Agregar filegroup para las ventas
ALTER DATABASE HuellasVerdes
ADD FILEGROUP FG_Transacciones;
-- Agregar filegroup para los productos (inventario)
ALTER DATABASE HuellasVerdes 
ADD FILEGROUP FG_Articulos;
-- Agregar filegroup para los clientes
ALTER DATABASE HuellasVerdes
ADD FILEGROUP FG_Compradores;
GO
-- Agregar archivo físico para las ventas
ALTER DATABASE HuellasVerdes
ADD FILE (
    NAME = 'TransaccionesFile', 
    FILENAME = 'C:\Proyecto integrador\SQLDATA\TransaccionesFile.ndf', 
    SIZE = 5MB, 
    MAXSIZE = 100MB, 
    FILEGROWTH = 5MB) 
TO FILEGROUP FG_Transacciones;
GO
-- Agregar archivo físico para los productos (inventario)
ALTER DATABASE HuellasVerdes
ADD FILE (
    NAME = 'ArticulosFile', 
    FILENAME = 'C:\Proyecto integrador\SQLDATA\ArticulosFile.ndf', 
    SIZE = 5MB, 
    MAXSIZE = 100MB, 
    FILEGROWTH = 5MB) 
TO FILEGROUP FG_Articulos;
GO
-- Agregar archivo físico para los clientes
ALTER DATABASE HuellasVerdes
ADD FILE (
    NAME = 'CompradoresFile', 
    FILENAME = 'C:\Proyecto integrador\SQLDATA\CompradoresFile.ndf', 
    SIZE = 5MB, 
    MAXSIZE = 100MB, 
    FILEGROWTH = 5MB) 
TO FILEGROUP FG_Compradores;
GO
-- Creando esquemas
CREATE SCHEMA compradores
GO
CREATE SCHEMA transacciones
GO
CREATE SCHEMA articulos
GO
CREATE SCHEMA administrador
GO
-- Tabla Comprador
CREATE TABLE compradores.Comprador (
    idComprador INT IDENTITY(1,1) PRIMARY KEY,
    Direccion1 NVARCHAR(100),
    Direccion2 NVARCHAR(100),
    Telefono NVARCHAR(25) -- CAMBIO: de INT a NVARCHAR(15)
) ON FG_Compradores;
-- Tabla Natural
CREATE TABLE compradores.Natural (
    idComprador INT PRIMARY KEY,
    DNI NVARCHAR(8) NOT NULL,
    Nombre NVARCHAR(100),
    ApellidoP NVARCHAR(100),
    ApellidoM NVARCHAR(100),
    CONSTRAINT FK_Natural_Comprador FOREIGN KEY (idComprador) REFERENCES compradores.Comprador(idComprador)
)ON FG_Compradores;
-- Tabla Empresa
CREATE TABLE compradores.Empresa (
    idComprador INT PRIMARY KEY,
    RUC NVARCHAR(11) NOT NULL,
    RazonSocial NVARCHAR(100),
    CONSTRAINT FK_Empresa_Comprador FOREIGN KEY (idComprador) REFERENCES compradores.Comprador(idComprador)
)ON FG_Compradores;
GO
-- Tabla Rama
CREATE TABLE articulos.Rama (
    idRama INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(100),
    Descripcion NVARCHAR(255)
)ON FG_Articulos;
-- Tabla Articulo
CREATE TABLE articulos.Articulo (
    idArticulo INT IDENTITY(1,1) PRIMARY KEY,
    codeArticulo NVARCHAR(10),
    nombreArticulo NVARCHAR(100),
    Tipo NVARCHAR(10),
    Descripcion NVARCHAR(255),
    idRama INT,
    precioUnitario DECIMAL(10, 2),
    CONSTRAINT FK_Articulo_Rama FOREIGN KEY (idRama) REFERENCES articulos.Rama(idRama)
)ON FG_Articulos;
-- Tabla Ingreso
CREATE TABLE articulos.Ingreso (
    idIngreso INT IDENTITY(1,1) PRIMARY KEY,
    idArticulo INT,
    fechaIngreso DATE,
    cantidadIngreso INT,
    CONSTRAINT FK_Articulo_Ingreso FOREIGN KEY (idArticulo) REFERENCES articulos.Articulo(idArticulo)
)ON FG_Articulos;
-- Tabla Egreso
CREATE TABLE articulos.Egreso (
    idEgreso INT IDENTITY(1,1) PRIMARY KEY,
    idArticulo INT,
    fechaEgreso DATE,
    cantidadEgreso INT,
    CONSTRAINT FK_Articulo_Egreso FOREIGN KEY (idArticulo) REFERENCES articulos.Articulo(idArticulo)
)ON FG_Articulos;
-- Tabla Almacen
CREATE TABLE articulos.Almacen (
    idZonaAlmacen NVARCHAR(10) PRIMARY KEY,
    idArticulo INT,
    Stock INT,
    CONSTRAINT FK_Almacen_Articulo FOREIGN KEY (idArticulo) REFERENCES articulos.Articulo(idArticulo)
)ON FG_Articulos;
GO
-- Tabla Transaccion
CREATE TABLE transacciones.Transaccion (
    idTransaccion INT IDENTITY(1,1) PRIMARY KEY,
    numDocumento INT,
    tipoDocumento NVARCHAR(50),
    fechaTransaccion DATE,
    idComprador INT,
    Subtotal DECIMAL (5, 2),
    IGV DECIMAL(5, 2),
    Descuento DECIMAL(5, 2),
    Total DECIMAL (5, 2),
    CONSTRAINT FK_Documento_Comprador FOREIGN KEY (idComprador) REFERENCES compradores.Comprador(idComprador)
)ON FG_Transacciones;
-- Tabla DetalleTransaccion
CREATE TABLE transacciones.DetalleTransaccion (
    idTransaccion INT,
    idArticulo INT,
    Cantidad INT,
    PRIMARY KEY (idTransaccion, idArticulo),
    CONSTRAINT FK_DetalleTransaccion_Transaccion FOREIGN KEY (idTransaccion) REFERENCES transacciones.Transaccion(idTransaccion),
    CONSTRAINT FK_DetalleTransaccion_Articulo FOREIGN KEY (idArticulo) REFERENCES articulos.Articulo(idArticulo)
)ON FG_Transacciones;