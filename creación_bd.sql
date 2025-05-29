-- Crear base de datos y conectarse
--CREATE DATABASE HuellasVerdes;
--\c HuellasVerdes

-- Crear esquemas
CREATE SCHEMA compradores;
CREATE SCHEMA transacciones;
CREATE SCHEMA articulos;
CREATE SCHEMA administrador;

-- Tabla unificada Comprador
CREATE TABLE compradores.Comprador (
    idComprador SERIAL PRIMARY KEY,
    tipo_comprador CHAR(1) CHECK (tipo_comprador IN ('N', 'E')),
    Direccion1 VARCHAR(100),
    Direccion2 VARCHAR(100),
    Telefono VARCHAR(25),
    -- Para naturales
    DNI VARCHAR(8),
    Nombre VARCHAR(100),
    ApellidoP VARCHAR(100),
    ApellidoM VARCHAR(100),
    -- Para empresas
    RUC VARCHAR(11),
    RazonSocial VARCHAR(100)
);

-- Tabla Rama
CREATE TABLE articulos.Rama (
    idRama SERIAL PRIMARY KEY,
    Nombre VARCHAR(100),
    Descripcion VARCHAR(255)
);

-- Tabla Articulo
CREATE TABLE articulos.Articulo (
    idArticulo SERIAL PRIMARY KEY,
    codeArticulo VARCHAR(10),
    nombreArticulo VARCHAR(100),
    Tipo VARCHAR(10),
    Descripcion VARCHAR(255),
    idRama INT,
    precioUnitario NUMERIC(10, 2),
    CONSTRAINT FK_Articulo_Rama FOREIGN KEY (idRama)
        REFERENCES articulos.Rama(idRama)
);

-- Tabla unificada MovimientoStock (reemplaza Ingreso y Egreso)
CREATE TABLE articulos.MovimientoStock (
    idMovimiento SERIAL PRIMARY KEY,
    idArticulo INT NOT NULL,
    fechaMovimiento DATE NOT NULL,
    tipo_movimiento CHAR(1) CHECK (tipo_movimiento IN ('I', 'E')), -- 'I' para ingreso, 'E' para egreso
    cantidad INT NOT NULL,
    CONSTRAINT FK_Movimiento_Articulo FOREIGN KEY (idArticulo)
        REFERENCES articulos.Articulo(idArticulo)
);

-- Tabla Almacen
CREATE TABLE articulos.Almacen (
    idZonaAlmacen VARCHAR(10) PRIMARY KEY,
    idArticulo INT,
    Stock INT,
    CONSTRAINT FK_Almacen_Articulo FOREIGN KEY (idArticulo)
        REFERENCES articulos.Articulo(idArticulo)
);

-- Tabla Transaccion
CREATE TABLE transacciones.Transaccion (
    idTransaccion SERIAL PRIMARY KEY,
    numDocumento INT,
    tipoDocumento VARCHAR(50),
    fechaTransaccion DATE,
    idComprador INT,
    Subtotal NUMERIC(5, 2),
    IGV NUMERIC(5, 2),
    Descuento NUMERIC(5, 2),
    Total NUMERIC(5, 2),
    CONSTRAINT FK_Documento_Comprador FOREIGN KEY (idComprador)
        REFERENCES compradores.Comprador(idComprador)
);

-- Tabla DetalleTransaccion
CREATE TABLE transacciones.DetalleTransaccion (
    idTransaccion INT,
    idArticulo INT,
    Cantidad INT,
    PRIMARY KEY (idTransaccion, idArticulo),
    CONSTRAINT FK_DetalleTransaccion_Transaccion FOREIGN KEY (idTransaccion)
        REFERENCES transacciones.Transaccion(idTransaccion),
    CONSTRAINT FK_DetalleTransaccion_Articulo FOREIGN KEY (idArticulo)
        REFERENCES articulos.Articulo(idArticulo)
);
