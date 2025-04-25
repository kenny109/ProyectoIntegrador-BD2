-- ========================================
-- PROCEDIMIENTO 1: Registrar una Transacción con Detalle
-- ========================================
CREATE PROCEDURE transacciones.RegistrarTransaccionConDetalle
    @numDocumento INT,
    @tipoDocumento NVARCHAR(50),
    @fechaTransaccion DATE,
    @idComprador INT,
    @Subtotal DECIMAL(5,2),
    @IGV DECIMAL(5,2),
    @Descuento DECIMAL(5,2),
    @Total DECIMAL(5,2),
    @idArticulo INT,
    @Cantidad INT
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Insertar en la tabla Transaccion
        INSERT INTO transacciones.Transaccion (numDocumento, tipoDocumento, fechaTransaccion, idComprador, Subtotal, IGV, Descuento, Total)
        VALUES (@numDocumento, @tipoDocumento, @fechaTransaccion, @idComprador, @Subtotal, @IGV, @Descuento, @Total);

        -- Obtener el ID recién generado
        DECLARE @idTransaccion INT = SCOPE_IDENTITY();

        -- Insertar en la tabla DetalleTransaccion
        INSERT INTO transacciones.DetalleTransaccion (idTransaccion, idArticulo, Cantidad)
        VALUES (@idTransaccion, @idArticulo, @Cantidad);

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;
GO

-- ========================================
-- EJECUCIÓN DE PRUEBA DEL PROCEDIMIENTO 1
-- ========================================
-- Asegúrate de tener un idComprador válido y un idArticulo existente
EXEC transacciones.RegistrarTransaccionConDetalle
    @numDocumento = 1001,
    @tipoDocumento = 'Factura',
    @fechaTransaccion = '2025-04-24',
    @idComprador = 1,
    @Subtotal = 100.00,
    @IGV = 18.00,
    @Descuento = 5.00,
    @Total = 113.00,
    @idArticulo = 1,
    @Cantidad = 3;
GO

-- ========================================
-- PROCEDIMIENTO 2: Consultar historial de transacciones de un comprador
-- ========================================
CREATE PROCEDURE transacciones.ConsultarHistorialComprador
    @idComprador INT
AS
BEGIN
    SELECT 
        t.idTransaccion,
        t.numDocumento,
        t.tipoDocumento,
        t.fechaTransaccion,
        t.Total,
        dt.idArticulo,
        a.nombreArticulo,
        dt.Cantidad
    FROM transacciones.Transaccion t
    INNER JOIN transacciones.DetalleTransaccion dt ON t.idTransaccion = dt.idTransaccion
    INNER JOIN articulos.Articulo a ON dt.idArticulo = a.idArticulo
    WHERE t.idComprador = @idComprador
    ORDER BY t.fechaTransaccion DESC;
END;
GO

-- ========================================
-- EJECUCIÓN DE PRUEBA DEL PROCEDIMIENTO 2
-- ========================================
EXEC transacciones.ConsultarHistorialComprador
    @idComprador = 1;
GO

-- ========================================
-- PROCEDIMIENTO 3: Registrar nuevo artículo y asignarlo al almacén
-- ========================================
CREATE PROCEDURE articulos.RegistrarArticuloConStock
    @codeArticulo NVARCHAR(10),
    @nombreArticulo NVARCHAR(100),
    @Tipo NVARCHAR(10),
    @Descripcion NVARCHAR(255),
    @idRama INT,
    @precioUnitario DECIMAL(10, 2),
    @idZonaAlmacen NVARCHAR(10),
    @Stock INT
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Insertar nuevo artículo
        INSERT INTO articulos.Articulo (codeArticulo, nombreArticulo, Tipo, Descripcion, idRama, precioUnitario)
        VALUES (@codeArticulo, @nombreArticulo, @Tipo, @Descripcion, @idRama, @precioUnitario);

        -- Obtener ID del artículo recién insertado
        DECLARE @idArticulo INT = SCOPE_IDENTITY();

        -- Insertar en la tabla Almacen con stock inicial
        INSERT INTO articulos.Almacen (idZonaAlmacen, idArticulo, Stock)
        VALUES (@idZonaAlmacen, @idArticulo, @Stock);

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

-- ========================================
-- EJECUCIÓN DE PRUEBA DEL PROCEDIMIENTO 3
-- ========================================
-- Asegúrate de que exista una rama con idRama = 1 y zona de almacén 'ZONA01'
EXEC articulos.RegistrarArticuloConStock
    @codeArticulo = 'A010',
    @nombreArticulo = 'Caja reciclada',
    @Tipo = 'Cartón',
    @Descripcion = 'Caja hecha de cartón reciclado',
    @idRama = 1,
    @precioUnitario = 4.50,
    @idZonaAlmacen = 'ZONA01',
    @Stock = 50;
GO
