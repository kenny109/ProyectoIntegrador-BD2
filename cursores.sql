-- ========================================
-- CURSOR 1: Listar todos los artículos y su stock actual
-- ========================================
DECLARE @ArticuloStock TABLE (
    idArticulo INT,
    nombreArticulo NVARCHAR(100),
    Stock INT
);

INSERT INTO @ArticuloStock
SELECT A.idArticulo, A.nombreArticulo, AL.Stock
FROM articulos.Articulo A
JOIN articulos.Almacen AL ON A.idArticulo = AL.idArticulo;

DECLARE @idArticulo INT, @nombreArticulo NVARCHAR(100), @Stock INT;
DECLARE articulo_cursor CURSOR FOR
SELECT idArticulo, nombreArticulo, Stock FROM @ArticuloStock;

OPEN articulo_cursor;
FETCH NEXT FROM articulo_cursor INTO @idArticulo, @nombreArticulo, @Stock;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Artículo: ' + @nombreArticulo + ', Stock: ' + CAST(@Stock AS NVARCHAR);
    FETCH NEXT FROM articulo_cursor INTO @idArticulo, @nombreArticulo, @Stock;
END

CLOSE articulo_cursor;
DEALLOCATE articulo_cursor;


-- ========================================
-- CURSOR 2: Revisar transacciones de hoy
-- ========================================
DECLARE @idTransaccion INT, @fecha DATE, @total DECIMAL(5,2);

DECLARE transaccion_cursor CURSOR FOR
SELECT idTransaccion, fechaTransaccion, Total
FROM transacciones.Transaccion
WHERE fechaTransaccion = CAST(GETDATE() AS DATE);

OPEN transaccion_cursor;
FETCH NEXT FROM transaccion_cursor INTO @idTransaccion, @fecha, @total;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Transacción ID: ' + CAST(@idTransaccion AS NVARCHAR) +
          ' | Fecha: ' + CAST(@fecha AS NVARCHAR) +
          ' | Total: S/. ' + CAST(@total AS NVARCHAR);
    FETCH NEXT FROM transaccion_cursor INTO @idTransaccion, @fecha, @total;
END

CLOSE transaccion_cursor;
DEALLOCATE transaccion_cursor;

-- ========================================
-- CURSOR 3: Listar empresas registradas con su RUC
-- ========================================
DECLARE @idComprador_E INT, @RUC NVARCHAR(11), @razonSocial NVARCHAR(100);

DECLARE empresa_cursor CURSOR FOR
SELECT idComprador, RUC, RazonSocial
FROM compradores.Empresa;

OPEN empresa_cursor;
FETCH NEXT FROM empresa_cursor INTO @idComprador_E, @RUC, @razonSocial;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Empresa: ' + @razonSocial + ' | RUC: ' + @RUC;
    FETCH NEXT FROM empresa_cursor INTO @idComprador_E, @RUC, @razonSocial;
END

CLOSE empresa_cursor;
DEALLOCATE empresa_cursor;

-- ========================================
-- CURSOR 4: Total de ingresos por artículo
-- ========================================
DECLARE @idArticulo_I INT, @nombreArticulo_I NVARCHAR(100), @cantidadTotal INT;

DECLARE ingreso_cursor CURSOR FOR
SELECT A.idArticulo, A.nombreArticulo, ISNULL(SUM(I.cantidadIngreso), 0) AS cantidadTotal
FROM articulos.Articulo A
LEFT JOIN articulos.Ingreso I ON A.idArticulo = I.idArticulo
GROUP BY A.idArticulo, A.nombreArticulo;

OPEN ingreso_cursor;
FETCH NEXT FROM ingreso_cursor INTO @idArticulo_I, @nombreArticulo_I, @cantidadTotal;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Artículo: ' + @nombreArticulo_I + ' | Total Ingresado: ' + CAST(@cantidadTotal AS NVARCHAR);
    FETCH NEXT FROM ingreso_cursor INTO @idArticulo_I, @nombreArticulo_I, @cantidadTotal;
END

CLOSE ingreso_cursor;
DEALLOCATE ingreso_cursor;

-- ========================================
-- CURSOR 5: Total de compras realizadas por cada comprador
-- ========================================
DECLARE @idComprador_C INT, @totalGastado DECIMAL(10,2);

DECLARE comprador_cursor CURSOR FOR
SELECT idComprador, SUM(Total) AS totalGastado
FROM transacciones.Transaccion
GROUP BY idComprador;

OPEN comprador_cursor;
FETCH NEXT FROM comprador_cursor INTO @idComprador_C, @totalGastado;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Comprador ID: ' + CAST(@idComprador_C AS NVARCHAR) +
          ' | Total Gastado: S/. ' + CAST(@totalGastado AS NVARCHAR);
    FETCH NEXT FROM comprador_cursor INTO @idComprador_C, @totalGastado;
END

CLOSE comprador_cursor;
DEALLOCATE comprador_cursor;


-- ========================================
-- CURSOR 6: Listar todos los compradores naturales con nombre completo y DNI
-- ========================================
DECLARE @idComprador_N INT, @DNI NVARCHAR(8), @nombre NVARCHAR(100), @apP NVARCHAR(100), @apM NVARCHAR(100);

DECLARE natural_cursor CURSOR FOR
SELECT idComprador, DNI, Nombre, ApellidoP, ApellidoM
FROM compradores.Natural;

OPEN natural_cursor;
FETCH NEXT FROM natural_cursor INTO @idComprador_N, @DNI, @nombre, @apP, @apM;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Comprador Natural: ' + @nombre + ' ' + @apP + ' ' + @apM + ' | DNI: ' + @DNI;
    FETCH NEXT FROM natural_cursor INTO @idComprador_N, @DNI, @nombre, @apP, @apM;
END

CLOSE natural_cursor;
DEALLOCATE natural_cursor;

-- ========================================
-- CURSOR 7: Verificar si hay artículos sin stock en almacén
-- ========================================
DECLARE @idArticulo_S INT, @nombreArticulo_S NVARCHAR(100), @stockActual INT;

DECLARE stock_cursor CURSOR FOR
SELECT A.idArticulo, A.nombreArticulo, ISNULL(AL.Stock, 0)
FROM articulos.Articulo A
LEFT JOIN articulos.Almacen AL ON A.idArticulo = AL.idArticulo;

OPEN stock_cursor;
FETCH NEXT FROM stock_cursor INTO @idArticulo_S, @nombreArticulo_S, @stockActual;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @stockActual = 0
        PRINT 'Artículo SIN STOCK: ' + @nombreArticulo_S;
    FETCH NEXT FROM stock_cursor INTO @idArticulo_S, @nombreArticulo_S, @stockActual;
END

CLOSE stock_cursor;
DEALLOCATE stock_cursor;

-- ========================================
-- CURSOR 8: Listar todos los egresos por artículo y fecha
-- ========================================
DECLARE @idEgreso INT, @idArticulo_E INT, @fechaEgreso DATE, @cantidadEgreso INT;

DECLARE egreso_cursor CURSOR FOR
SELECT idEgreso, idArticulo, fechaEgreso, cantidadEgreso
FROM articulos.Egreso;

OPEN egreso_cursor;
FETCH NEXT FROM egreso_cursor INTO @idEgreso, @idArticulo_E, @fechaEgreso, @cantidadEgreso;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Egreso ID: ' + CAST(@idEgreso AS NVARCHAR) +
          ' | Artículo ID: ' + CAST(@idArticulo_E AS NVARCHAR) +
          ' | Fecha: ' + CAST(@fechaEgreso AS NVARCHAR) +
          ' | Cantidad: ' + CAST(@cantidadEgreso AS NVARCHAR);
    FETCH NEXT FROM egreso_cursor INTO @idEgreso, @idArticulo_E, @fechaEgreso, @cantidadEgreso;
END

CLOSE egreso_cursor;
DEALLOCATE egreso_cursor;
