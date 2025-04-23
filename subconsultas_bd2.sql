-- 1. Clientes con m�s de una transacci�n
SELECT idComprador
FROM transacciones.Transaccion
GROUP BY idComprador
HAVING COUNT(*) = 1;

-- 2. Art�culos con stock menor al promedio
SELECT * FROM articulos.Almacen
WHERE Stock < (SELECT AVG(Stock) FROM articulos.Almacen);

-- 3. Transacciones con total mayor al promedio
SELECT * FROM transacciones.Transaccion
WHERE Total > (SELECT AVG(Total) FROM transacciones.Transaccion);

-- 4. Compradores que nunca han comprado
SELECT * FROM compradores.Comprador
WHERE idComprador NOT IN (
    SELECT idComprador FROM transacciones.Transaccion
);

-- 5. Art�culos m�s vendidos (top 3)
SELECT TOP 3 idArticulo
FROM transacciones.DetalleTransaccion
GROUP BY idArticulo
ORDER BY SUM(Cantidad) DESC;

-- 6. Compradores naturales que hicieron compras en abril 2024
SELECT n.Nombre, n.ApellidoP
FROM compradores.Natural n
WHERE n.idComprador IN (
    SELECT t.idComprador
    FROM transacciones.Transaccion t
    WHERE MONTH(t.fechaTransaccion) = 4 AND YEAR(t.fechaTransaccion) = 2024
);

-- 7. Stock de art�culos cuyo precio unitario es mayor al promedio
SELECT a.nombreArticulo, al.Stock
FROM articulos.Articulo a
JOIN articulos.Almacen al ON a.idArticulo = al.idArticulo
WHERE a.precioUnitario > (SELECT AVG(precioUnitario) FROM articulos.Articulo);

-- 8. Transacciones donde el descuento es mayor al IGV
SELECT * FROM transacciones.Transaccion
WHERE Descuento > IGV;

-- 9. Empresas que han realizado transacciones por m�s de 500 soles
SELECT e.RazonSocial
FROM compradores.Empresa e
WHERE e.idComprador IN (
    SELECT idComprador FROM transacciones.Transaccion
    WHERE Total > 500
);

-- 10. Art�culos sin movimientos (sin egresos ni ingresos)
SELECT * FROM articulos.Articulo
WHERE idArticulo NOT IN (
    SELECT idArticulo FROM articulos.Ingreso
    UNION
    SELECT idArticulo FROM articulos.Egreso
);

-- 11. Art�culos con m�s ingresos que egresos
SELECT a.idArticulo, a.nombreArticulo
FROM articulos.Articulo a
WHERE (
    SELECT ISNULL(SUM(cantidadIngreso), 0)
    FROM articulos.Ingreso
    WHERE idArticulo = a.idArticulo
) > (
    SELECT ISNULL(SUM(cantidadEgreso), 0)
    FROM articulos.Egreso
    WHERE idArticulo = a.idArticulo
);

-- 12. Total vendido por cada comprador
SELECT c.idComprador, 
       (SELECT SUM(t.Total) FROM transacciones.Transaccion t WHERE t.idComprador = c.idComprador) AS TotalComprado
FROM compradores.Comprador c;

-- 13. Transacciones con m�s de 3 art�culos distintos
SELECT idTransaccion
FROM transacciones.DetalleTransaccion
GROUP BY idTransaccion
HAVING COUNT(DISTINCT idArticulo) > 3;

-- 14. Clientes con art�culos en stock < 10
SELECT DISTINCT c.idComprador
FROM compradores.Comprador c
JOIN transacciones.Transaccion t ON t.idComprador = c.idComprador
JOIN transacciones.DetalleTransaccion d ON d.idTransaccion = t.idTransaccion
JOIN articulos.Almacen al ON d.idArticulo = al.idArticulo
WHERE al.Stock < 10;

-- 15. Precio unitario promedio por rama
SELECT r.Nombre, 
       (SELECT AVG(a.precioUnitario) FROM articulos.Articulo a WHERE a.idRama = r.idRama) AS PromedioPrecio
FROM articulos.Rama r;
