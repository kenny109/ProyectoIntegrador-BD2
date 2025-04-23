-- ========================================
-- SCRIPT: Transacciones para la BD HuellasVerdes
-- ========================================

-- 1. Transacción: Registrar ingreso y actualizar stock
BEGIN TRAN;

BEGIN TRY
    INSERT INTO articulos.Ingreso (idArticulo, fechaIngreso, cantidadIngreso)
    VALUES (1, GETDATE(), 50);

    UPDATE articulos.Almacen
    SET Stock = Stock + 50
    WHERE idArticulo = 1;

    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT 'Error: ' + ERROR_MESSAGE();
END CATCH;


-- 2. Transacción: Registrar egreso y reducir stock
BEGIN TRAN;

BEGIN TRY
    INSERT INTO articulos.Egreso (idArticulo, fechaEgreso, cantidadEgreso)
    VALUES (1, GETDATE(), 20);

    UPDATE articulos.Almacen
    SET Stock = Stock - 20
    WHERE idArticulo = 1;

    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT 'Error: ' + ERROR_MESSAGE();
END CATCH;


-- 3. Transacción adicional: Ingreso + Transacción de compra
BEGIN TRAN;

BEGIN TRY
    INSERT INTO articulos.Ingreso (idArticulo, fechaIngreso, cantidadIngreso)
    VALUES (1, GETDATE(), 100);

    INSERT INTO transacciones.Transaccion (numDocumento, tipoDocumento, fechaTransaccion, idComprador, Subtotal, IGV, Descuento, Total)
    VALUES (1002, 'Factura', GETDATE(), 2, 500, 90, 10, 580);

    UPDATE articulos.Almacen
    SET Stock = Stock + 100
    WHERE idArticulo = 1;

    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT 'Error en la transacción: ' + ERROR_MESSAGE();
END CATCH;


-- 4. Transacción adicional: Egreso + Venta
BEGIN TRAN;

BEGIN TRY
    INSERT INTO articulos.Egreso (idArticulo, fechaEgreso, cantidadEgreso)
    VALUES (2, GETDATE(), 5);

    INSERT INTO transacciones.Transaccion (numDocumento, tipoDocumento, fechaTransaccion, idComprador, Subtotal, IGV, Descuento, Total)
    VALUES (1003, 'Factura', GETDATE(), 3, 300, 54, 5, 349);

    UPDATE articulos.Almacen
    SET Stock = Stock - 5
    WHERE idArticulo = 2;

    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT 'Error en la transacción: ' + ERROR_MESSAGE();
END CATCH;
