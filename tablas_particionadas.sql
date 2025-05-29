-- =====================================================
-- BASE DE DATOS HUELLASVERDES - PARTICIONAMIENTO SIMPLE
-- =====================================================

-- Crear base de datos y conectarse
-- CREATE DATABASE HuellasVerdes;
-- \c HuellasVerdes

-- Crear esquemas
CREATE SCHEMA compradores;
CREATE SCHEMA transacciones;
CREATE SCHEMA articulos;
CREATE SCHEMA administrador;

-- =====================================================
-- PARTICIONAMIENTO VERTICAL SIMPLE
-- =====================================================

-- 1. TABLA COMPRADOR - Separar por tipo (Natural vs Empresa)
-- Tabla principal con datos comunes
CREATE TABLE compradores.Comprador (
    idComprador SERIAL PRIMARY KEY,
    tipo_comprador CHAR(1) CHECK (tipo_comprador IN ('N', 'E')),
    Direccion1 VARCHAR(100),
    Direccion2 VARCHAR(100),
    Telefono VARCHAR(25)
);

-- Tabla solo para personas naturales
CREATE TABLE compradores.CompradorNatural (
    idComprador INT PRIMARY KEY,
    DNI VARCHAR(8) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    ApellidoP VARCHAR(100) NOT NULL,
    ApellidoM VARCHAR(100),
    FOREIGN KEY (idComprador) REFERENCES compradores.Comprador(idComprador)
);

-- Tabla solo para empresas
CREATE TABLE compradores.CompradorEmpresa (
    idComprador INT PRIMARY KEY,
    RUC VARCHAR(11) NOT NULL,
    RazonSocial VARCHAR(100) NOT NULL,
    FOREIGN KEY (idComprador) REFERENCES compradores.Comprador(idComprador)
);

-- 2. TABLA ARTICULO - Separar descripción grande del resto
-- Tabla principal con datos básicos (se consulta frecuentemente)
CREATE TABLE articulos.Articulo (
    idArticulo SERIAL PRIMARY KEY,
    codeArticulo VARCHAR(10) UNIQUE NOT NULL,
    nombreArticulo VARCHAR(100) NOT NULL,
    Tipo VARCHAR(10),
    idRama INT,
    precioUnitario NUMERIC(10, 2)
);

-- Tabla para descripciones largas (se consulta poco)
CREATE TABLE articulos.ArticuloDescripcion (
    idArticulo INT PRIMARY KEY,
    Descripcion TEXT,
    FOREIGN KEY (idArticulo) REFERENCES articulos.Articulo(idArticulo)
);

-- Tabla Rama (sin cambios)
CREATE TABLE articulos.Rama (
    idRama SERIAL PRIMARY KEY,
    Nombre VARCHAR(100),
    Descripcion VARCHAR(255),
    FOREIGN KEY (idRama) REFERENCES articulos.Rama(idRama)
);

-- =====================================================
-- PARTICIONAMIENTO HORIZONTAL SIMPLE
-- =====================================================

-- TRANSACCIONES particionadas por AÑO
-- Tabla principal particionada
CREATE TABLE transacciones.Transaccion (
    idTransaccion SERIAL,
    numDocumento INT,
    tipoDocumento VARCHAR(50),
    fechaTransaccion DATE NOT NULL,
    idComprador INT,
    Subtotal NUMERIC(10, 2),
    IGV NUMERIC(10, 2),
    Descuento NUMERIC(10, 2),
    Total NUMERIC(10, 2),
    PRIMARY KEY (idTransaccion, fechaTransaccion),
    FOREIGN KEY (idComprador) REFERENCES compradores.Comprador(idComprador)
) PARTITION BY RANGE (fechaTransaccion);

-- Particiones por año (una por año)
CREATE TABLE transacciones.Transaccion_2023 
    PARTITION OF transacciones.Transaccion
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE transacciones.Transaccion_2024 
    PARTITION OF transacciones.Transaccion
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE transacciones.Transaccion_2025 
    PARTITION OF transacciones.Transaccion
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- MOVIMIENTO STOCK particionado por AÑO (más simple que por mes)
CREATE TABLE articulos.MovimientoStock (
    idMovimiento SERIAL,
    idArticulo INT NOT NULL,
    fechaMovimiento DATE NOT NULL,
    tipo_movimiento CHAR(1) CHECK (tipo_movimiento IN ('I', 'E')),
    cantidad INT NOT NULL,
    PRIMARY KEY (idMovimiento, fechaMovimiento),
    FOREIGN KEY (idArticulo) REFERENCES articulos.Articulo(idArticulo)
) PARTITION BY RANGE (fechaMovimiento);

-- Particiones por año
CREATE TABLE articulos.MovimientoStock_2023 
    PARTITION OF articulos.MovimientoStock
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE articulos.MovimientoStock_2024 
    PARTITION OF articulos.MovimientoStock
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE articulos.MovimientoStock_2025 
    PARTITION OF articulos.MovimientoStock
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- =====================================================
-- TABLAS RESTANTES (SIN PARTICIONAMIENTO)
-- =====================================================

-- DetalleTransaccion también particionado (para que coincida con Transaccion)
CREATE TABLE transacciones.DetalleTransaccion (
    idTransaccion INT,
    fechaTransaccion DATE,
    idArticulo INT,
    Cantidad INT,
    PRIMARY KEY (idTransaccion, fechaTransaccion, idArticulo),
    FOREIGN KEY (idTransaccion, fechaTransaccion) 
        REFERENCES transacciones.Transaccion(idTransaccion, fechaTransaccion),
    FOREIGN KEY (idArticulo) REFERENCES articulos.Articulo(idArticulo)
) PARTITION BY RANGE (fechaTransaccion);

-- Particiones de detalle (coinciden con las de transacción)
CREATE TABLE transacciones.DetalleTransaccion_2023 
    PARTITION OF transacciones.DetalleTransaccion
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE transacciones.DetalleTransaccion_2024 
    PARTITION OF transacciones.DetalleTransaccion
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE transacciones.DetalleTransaccion_2025 
    PARTITION OF transacciones.DetalleTransaccion
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- Tabla Almacen (normal, sin particionamiento)
CREATE TABLE articulos.Almacen (
    idZonaAlmacen VARCHAR(10) PRIMARY KEY,
    idArticulo INT,
    Stock INT,
    FOREIGN KEY (idArticulo) REFERENCES articulos.Articulo(idArticulo)
);

-- =====================================================
-- ÍNDICES BÁSICOS
-- =====================================================

-- Índices para mejorar consultas frecuentes
CREATE INDEX idx_comprador_tipo ON compradores.Comprador(tipo_comprador);
CREATE INDEX idx_articulo_codigo ON articulos.Articulo(codeArticulo);
CREATE INDEX idx_transaccion_comprador ON transacciones.Transaccion(idComprador);
CREATE INDEX idx_movimiento_articulo ON articulos.MovimientoStock(idArticulo);

-- =====================================================
-- VISTAS SIMPLES PARA CONSULTAS
-- =====================================================

-- Vista para ver comprador completo (natural o empresa)
CREATE VIEW compradores.VW_CompradorCompleto AS
SELECT 
    c.idComprador,
    c.tipo_comprador,
    c.Direccion1,
    c.Telefono,
    CASE 
        WHEN c.tipo_comprador = 'N' THEN cn.DNI
        WHEN c.tipo_comprador = 'E' THEN ce.RUC
    END as documento,
    CASE 
        WHEN c.tipo_comprador = 'N' THEN cn.Nombre || ' ' || cn.ApellidoP
        WHEN c.tipo_comprador = 'E' THEN ce.RazonSocial
    END as nombre_completo
FROM compradores.Comprador c
LEFT JOIN compradores.CompradorNatural cn ON c.idComprador = cn.idComprador
LEFT JOIN compradores.CompradorEmpresa ce ON c.idComprador = ce.idComprador;

-- Vista para ver artículo con descripción
CREATE VIEW articulos.VW_ArticuloCompleto AS
SELECT 
    a.idArticulo,
    a.codeArticulo,
    a.nombreArticulo,
    a.precioUnitario,
    ad.Descripcion
FROM articulos.Articulo a
LEFT JOIN articulos.ArticuloDescripcion ad ON a.idArticulo = ad.idArticulo;

-- =====================================================
-- FUNCIONES SIMPLES PARA AGREGAR PARTICIONES
-- =====================================================

-- Función para agregar partición de un nuevo año
CREATE OR REPLACE FUNCTION agregar_particion_anio(nuevo_anio INT)
RETURNS TEXT AS $$
BEGIN
    -- Crear partición de transacciones
    EXECUTE format('CREATE TABLE transacciones.Transaccion_%s 
                    PARTITION OF transacciones.Transaccion
                    FOR VALUES FROM (%L) TO (%L)',
                   nuevo_anio, nuevo_anio || '-01-01', (nuevo_anio + 1) || '-01-01');
    
    -- Crear partición de detalles
    EXECUTE format('CREATE TABLE transacciones.DetalleTransaccion_%s 
                    PARTITION OF transacciones.DetalleTransaccion
                    FOR VALUES FROM (%L) TO (%L)',
                   nuevo_anio, nuevo_anio || '-01-01', (nuevo_anio + 1) || '-01-01');
    
    -- Crear partición de movimientos
    EXECUTE format('CREATE TABLE articulos.MovimientoStock_%s 
                    PARTITION OF articulos.MovimientoStock
                    FOR VALUES FROM (%L) TO (%L)',
                   nuevo_anio, nuevo_anio || '-01-01', (nuevo_anio + 1) || '-01-01');
    
    RETURN 'Particiones creadas para el año ' || nuevo_anio;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- CONSULTAS PARA VER LAS PARTICIONES
-- =====================================================

-- Ver todas las particiones y cuántas filas tienen
SELECT 
    schemaname as esquema,
    tablename as tabla,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as tamaño
FROM pg_tables 
WHERE tablename LIKE '%_2023' OR tablename LIKE '%_2024' OR tablename LIKE '%_2025'
ORDER BY schemaname, tablename;

-- =====================================================
-- EJEMPLOS DE USO
-- =====================================================

-- Insertar datos de ejemplo
INSERT INTO articulos.Rama (Nombre, Descripcion) VALUES 
('Productos Verdes', 'Artículos ecológicos');

INSERT INTO articulos.Articulo (codeArticulo, nombreArticulo, Tipo, idRama, precioUnitario) VALUES 
('ECO001', 'Bolsa Reciclable', 'BOLSA', 1, 5.50);

INSERT INTO articulos.ArticuloDescripcion (idArticulo, Descripcion) VALUES 
(1, 'Bolsa fabricada con materiales 100% reciclados, resistente y reutilizable...');

-- Ejemplo de comprador natural
INSERT INTO compradores.Comprador (tipo_comprador, Direccion1, Telefono) VALUES 
('N', 'Av. Principal 123', '987654321');

INSERT INTO compradores.CompradorNatural (idComprador, DNI, Nombre, ApellidoP, ApellidoM) VALUES 
(1, '12345678', 'Juan', 'Pérez', 'García');

-- Ejemplo de transacción (se guarda automáticamente en la partición correcta)
INSERT INTO transacciones.Transaccion (numDocumento, tipoDocumento, fechaTransaccion, idComprador, Total) VALUES 
(1001, 'BOLETA', '2024-06-15', 1, 55.00);

-- Para agregar un nuevo año:
-- SELECT agregar_particion_anio(2026);
