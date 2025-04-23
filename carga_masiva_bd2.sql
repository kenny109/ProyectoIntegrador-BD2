
-- ============================
-- 1. COMPRADORES: Insertar en tabla base
-- ============================
PRINT 'Insertando compradores...'
DECLARE @i INT = 1;
WHILE @i <= 1000
BEGIN
    INSERT INTO compradores.Comprador (Direccion1, Direccion2, Telefono)
    VALUES (
        CONCAT('Calle ', @i, ' #', (1000 + @i)),
        CONCAT('Urbanización ', CHAR(65 + (@i % 26))),
        CONCAT('9', FORMAT(@i, '0000000'))
    );
    SET @i += 1;
END

-- ============================
-- 2. NATURAL: 60% de los compradores
-- ============================
PRINT 'Insertando personas naturales...'
SET @i = 1;
WHILE @i <= 600
BEGIN
    INSERT INTO compradores.Natural (idComprador, DNI, Nombre, ApellidoP, ApellidoM)
    VALUES (
        @i,
        RIGHT('00000000' + CAST(@i AS NVARCHAR), 8),
        CONCAT('Nombre', @i),
        CONCAT('ApellidoP', @i),
        CONCAT('ApellidoM', @i)
    );
    SET @i += 1;
END

-- ============================
-- 3. EMPRESA: 40% de los compradores
-- ============================
PRINT 'Insertando empresas...'
SET @i = 601;
WHILE @i <= 1000
BEGIN
    INSERT INTO compradores.Empresa (idComprador, RUC, RazonSocial)
    VALUES (
        @i,
        RIGHT('00000000000' + CAST(@i AS NVARCHAR), 11),
        CONCAT('Empresa S.A.C ', @i)
    );
    SET @i += 1;
END

-- ============================
-- 4. RAMAS: 10 categorías
-- ============================
PRINT 'Insertando ramas de artículos...'
SET @i = 1;
WHILE @i <= 10
BEGIN
    INSERT INTO articulos.Rama (Nombre, Descripcion)
    VALUES (
        CONCAT('Rama ', @i),
        CONCAT('Descripción de la rama ', @i)
    );
    SET @i += 1;
END

-- ============================
-- 5. ARTÍCULOS: 1000 artículos distribuidos en ramas
-- ============================
PRINT 'Insertando artículos...'
SET @i = 1;
WHILE @i <= 1000
BEGIN
    INSERT INTO articulos.Articulo (codeArticulo, nombreArticulo, Tipo, Descripcion, idRama, precioUnitario)
    VALUES (
        CONCAT('A', FORMAT(@i, '0000')),
        CONCAT('Artículo ', @i),
        CASE WHEN @i % 2 = 0 THEN 'Eco' ELSE 'Bio' END,
        CONCAT('Este es el artículo número ', @i),
        ((@i - 1) % 10 + 1),
        CAST(RAND() * 100 + 1 AS DECIMAL(10,2))
    );
    SET @i += 1;
END

-- ============================
-- 6. INGRESO, EGRESO y ALMACÉN por artículo
-- ============================
PRINT 'Insertando ingresos, egresos y almacenes...'
SET @i = 1;
WHILE @i <= 1000
BEGIN
    INSERT INTO articulos.Ingreso (idArticulo, fechaIngreso, cantidadIngreso)
    VALUES (
        @i,
        DATEADD(DAY, -@i % 365, GETDATE()),
        (@i % 50 + 1)
    );

    INSERT INTO articulos.Egreso (idArticulo, fechaEgreso, cantidadEgreso)
    VALUES (
        @i,
        DATEADD(DAY, -@i % 180, GETDATE()),
        (@i % 30 + 1)
    );

    INSERT INTO articulos.Almacen (idZonaAlmacen, idArticulo, Stock)
    VALUES (
        CONCAT('Z', FORMAT(@i, '000')),
        @i,
        (100 - @i % 40)
    );
    SET @i += 1;
END

-- ============================
-- 7. TRANSACCIONES y DETALLE TRANSACCIÓN
-- ============================
PRINT 'Insertando transacciones y detalles...'
SET @i = 1;
WHILE @i <= 1000
BEGIN
    DECLARE @idComprador INT = ((@i - 1) % 1000) + 1;
    DECLARE @sub DECIMAL(5,2) = CAST(RAND() * 500 + 50 AS DECIMAL(5,2));
    DECLARE @igv DECIMAL(5,2) = CAST(@sub * 0.18 AS DECIMAL(5,2));
    DECLARE @desc DECIMAL(5,2) = CAST((@sub + @igv) * 0.05 AS DECIMAL(5,2));
    DECLARE @total DECIMAL(5,2) = @sub + @igv - @desc;

    INSERT INTO transacciones.Transaccion (numDocumento, tipoDocumento, fechaTransaccion, idComprador, Subtotal, IGV, Descuento, Total)
    VALUES (
        10000 + @i,
        CASE WHEN @i % 2 = 0 THEN 'Boleta' ELSE 'Factura' END,
        DATEADD(DAY, -@i % 90, GETDATE()),
        @idComprador,
        @sub,
        @igv,
        @desc,
        @total
    );

    DECLARE @j INT = 1;
    WHILE @j <= 3
    BEGIN
        INSERT INTO transacciones.DetalleTransaccion (idTransaccion, idArticulo, Cantidad)
        VALUES (
            @i,
            ((@i + @j) % 1000 + 1),
            (@j * 2)
        );
        SET @j += 1;
    END
    SET @i += 1;
END

PRINT 'Carga de datos de prueba completada exitosamente.'
