-- ===========================
-- CARGA MASIVA DE DATOS
-- ===========================

-- 1. Insertar 10 Ramas
DO $$
DECLARE
    i INT := 1;
BEGIN
    RAISE NOTICE 'Insertando ramas...';
    WHILE i <= 10 LOOP
        INSERT INTO articulos.Rama (Nombre, Descripcion)
        VALUES (
            CONCAT('Rama ', i),
            CONCAT('Descripción de la rama ', i)
        );
        i := i + 1;
    END LOOP;
END $$;
select * from  articulos.Rama
-- Vacía la tabla rama
TRUNCATE TABLE articulos.rama RESTART IDENTITY CASCADE;

-- 2. Insertar 1000 Artículos
DO $$
DECLARE
    i INT := 1;
BEGIN
    RAISE NOTICE 'Insertando artículos...';
    WHILE i <= 1000 LOOP
        INSERT INTO articulos.Articulo (codeArticulo, nombreArticulo, Tipo, Descripcion, idRama, precioUnitario)
        VALUES (
            CONCAT('A', LPAD(i::TEXT, 4, '0')),
            CONCAT('Artículo ', i),
            CASE WHEN i % 2 = 0 THEN 'Eco' ELSE 'Bio' END,
            CONCAT('Este es el artículo número ', i),
            ((i - 1) % 10 + 1),
            ROUND((RANDOM() * 100 + 1) * 100) / 100.0
        );
        i := i + 1;
    END LOOP;
END $$;

-- 3. Insertar 1000 Movimientos de Stock
DO $$
DECLARE
    i INT := 1;
BEGIN
    RAISE NOTICE 'Insertando movimientos de stock...';
    WHILE i <= 1000 LOOP
        INSERT INTO articulos.MovimientoStock (idArticulo, fechaMovimiento, tipo_movimiento, cantidad)
        VALUES (
            ((i - 1) % 1000 + 1),
            CURRENT_DATE - ((i - 1) % 30),
            CASE WHEN i % 2 = 0 THEN 'I' ELSE 'E' END,
            (RANDOM() * 100 + 1)::INT
        );
        i := i + 1;
    END LOOP;
END $$;

-- 4. Insertar 500 zonas de Almacén
DO $$
DECLARE
    i INT := 1;
BEGIN
    RAISE NOTICE 'Insertando zonas de almacén...';
    WHILE i <= 500 LOOP
        INSERT INTO articulos.Almacen (idZonaAlmacen, idArticulo, Stock)
        VALUES (
            CONCAT('ZONA', LPAD(i::TEXT, 4, '0')),
            ((i - 1) % 1000 + 1),
            (RANDOM() * 100)::INT
        );
        i := i + 1;
    END LOOP;
END $$;

-- 5. Insertar 500 Compradores (naturales y empresas)
DO $$
DECLARE
    i INT := 1;
BEGIN
    RAISE NOTICE 'Insertando compradores...';
    WHILE i <= 500 LOOP
        INSERT INTO compradores.Comprador (
            tipo_comprador, Direccion1, Direccion2, Telefono,
            DNI, Nombre, ApellidoP, ApellidoM,
            RUC, RazonSocial
        )
        VALUES (
            CASE WHEN i <= 250 THEN 'N' ELSE 'E' END,
            CONCAT('Calle Falsa ', i),
            CONCAT('Interior ', i),
            CONCAT('+51 9', LPAD((RANDOM() * 99999999)::INT::TEXT, 8, '0')),
            CASE WHEN i <= 250 THEN LPAD(i::TEXT, 8, '0') ELSE NULL END,
            CASE WHEN i <= 250 THEN CONCAT('Nombre', i) ELSE NULL END,
            CASE WHEN i <= 250 THEN 'Pérez' ELSE NULL END,
            CASE WHEN i <= 250 THEN 'Gómez' ELSE NULL END,
            CASE WHEN i > 250 THEN LPAD(i::TEXT, 11, '1') ELSE NULL END,
            CASE WHEN i > 250 THEN CONCAT('Empresa ', i) ELSE NULL END
        );
        i := i + 1;
    END LOOP;
END $$;
select * from compradores.Comprador
TRUNCATE TABLE compradores.Comprador RESTART IDENTITY CASCADE;

-- 6. Insertar 300 Transacciones
DO $$
DECLARE
    i INT := 1;
BEGIN
    RAISE NOTICE 'Insertando transacciones...';
    WHILE i <= 300 LOOP
        INSERT INTO transacciones.Transaccion (
            numDocumento, tipoDocumento, fechaTransaccion,
            idComprador, Subtotal, IGV, Descuento, Total
        )
        VALUES (
            1000 + i,
            CASE WHEN i % 2 = 0 THEN 'Boleta' ELSE 'Factura' END,
            CURRENT_DATE - ((i - 1) % 30),
            ((i - 1) % 500 + 1),
            ROUND((RANDOM() * 200 + 50)::NUMERIC, 2),
            ROUND((RANDOM() * 20)::NUMERIC, 2),
            ROUND((RANDOM() * 10)::NUMERIC, 2),
            ROUND((RANDOM() * 200 + 50)::NUMERIC, 2)
        );
        i := i + 1;
    END LOOP;
END $$;

-- 7. Insertar DetalleTransaccion (2 por transacción)
DO $$
DECLARE
    i INT := 1;
BEGIN
    RAISE NOTICE 'Insertando detalles de transacciones...';
    WHILE i <= 300 LOOP
        INSERT INTO transacciones.DetalleTransaccion (idTransaccion, idArticulo, Cantidad)
        VALUES (i, ((i - 1) % 1000 + 1), (RANDOM() * 10 + 1)::INT);

        INSERT INTO transacciones.DetalleTransaccion (idTransaccion, idArticulo, Cantidad)
        VALUES (i, ((i * 2) % 1000 + 1), (RANDOM() * 10 + 1)::INT);

        i := i + 1;
    END LOOP;
END $$;
