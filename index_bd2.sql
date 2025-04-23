-- Índices en columnas de búsqueda frecuente
CREATE NONCLUSTERED INDEX IX_Articulo_Precio ON articulos.Articulo(precioUnitario) ON FG_Articulos;

CREATE NONCLUSTERED INDEX IX_Transaccion_Fecha ON transacciones.Transaccion(fechaTransaccion) ON FG_Transacciones;

CREATE NONCLUSTERED INDEX IX_Almacen_Stock ON articulos.Almacen(Stock) ON FG_Articulos;

CREATE NONCLUSTERED INDEX IX_Comprador_Telefono ON compradores.Comprador(Telefono) ON FG_Compradores;
