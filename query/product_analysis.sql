-- ==================================================
-- SECCIÓN 1: Análisis por Categoría de Producto
-- ==================================================

--1. ¿Qué categoría genera más ingresos totales?
SELECT product_Category, SUM(total_revenue) AS total_ingresos
FROM Online_Sales
GROUP BY product_category
ORDER BY total_ingresos DESC;

--2. ¿Qué categoría tiene el ticket promedio más alto?
SELECT product_category, ROUND(AVG(total_revenue),2) AS ticket_promedio
FROM Online_Sales
GROUP BY product_category
ORDER BY ticket_promedio DESC;

--3. ¿Qué categoría genera más ingresos a través de pagos con tarjeta de crédito?
SELECT product_category, SUM(total_revenue) AS total_ingresos, payment_method
FROM Online_Sales
WHERE payment_method == 'Credit Card'
GROUP BY product_category,payment_method
ORDER BY total_ingresos DESC;

--4. ¿Cuál es la categoría con mayor volumen de unidades vendidas los fines de semana?
SELECT product_category, SUM(units_sold) AS unidades_vendidas
FROM Online_Sales
WHERE day_of_week IN ('Saturday','Sunday')
GROUP BY product_category
ORDER BY unidades_vendidas DESC;

--5. ¿Qué categoría tiene mayores ingresos en los primeros 3 meses?
SELECT product_category, ROUND(SUM(total_ingresos),2) AS ingresos_por_categoría
FROM (
  SELECT product_category, SUM(total_revenue) AS total_ingresos, month
  FROM Online_Sales
  WHERE month IN ('January', 'February', 'March', 'April', 'May')
  GROUP BY product_category, month
  ORDER BY product_category ASC, total_ingresos DESC, month
  )
GROUP BY product_category
ORDER BY total_ingresos desc;

--6. ¿Cómo se distribuyen los ingresos por categoría según la región?
SELECT product_category, SUM(total_revenue) AS total_ingresos, region 
FROM Online_Sales
GROUP BY product_category,region
ORDER BY region DESC, total_ingresos DESC;

--7. ¿Hay alguna preferencia en las unidades vendidas por categoría según la región?
SELECT product_category, SUM(units_sold) AS unidades_vendidas, region 
FROM Online_Sales
GROUP BY product_category,region
ORDER BY region DESC, unidades_vendidas DESC;

--8. ¿Cuál es la categoría con mayor número de transacciones? 
SELECT product_category, COUNT(transaction_id) AS total_transacciones 
FROM Online_Sales
GROUP BY product_category
ORDER BY total_transacciones DESC;

--9. ¿Qué categorías tiene más transacciones pagadas con tarjeta de débito?
SELECT product_category, COUNT(transaction_id) AS total_transacciones 
FROM Online_Sales
WHERE payment_method == 'Debit Card'
GROUP BY product_category
ORDER BY total_transacciones DESC;

--10. ¿En qué categorías es más frecuente el pago con PayPal?
SELECT product_category, COUNT(transaction_id) AS total_transacciones 
FROM Online_Sales
WHERE payment_method == 'PayPal'
GROUP BY product_category
ORDER BY total_transacciones DESC;

-- ==================================================
-- SECCIÓN 2: Análisis por Producto
-- =================================================

--1. ¿Cuáles son los 10 productos más vendidos en unidades?
SELECT product_name, SUM(units_sold) AS unidades_vendidas
FROM Online_Sales
GROUP BY product_name
ORDER BY unidades_vendidas DESC
LIMIT 10;

--2. ¿Cuáles son los 10 productos con mayor facturación?
SELECT product_name, SUM(total_revenue) AS total_ingresos
FROM Online_Sales
GROUP BY product_name
ORDER BY total_ingresos DESC
LIMIT 10;

--3. ¿Hay productos con alta facturación pero pocas unidades vendidas?
SELECT product_name, SUM(total_revenue) AS total_ingresos, SUM(units_sold) as unidades_vendidas
FROM Online_Sales
GROUP BY product_name
ORDER BY total_ingresos DESC, unidades_vendidas ASC
LIMIT 10;

--4. ¿Cuál es el top 5 de productos con más ingresos en cada región?
SELECT product_name, total_ingresos, region
FROM (
    SELECT 
        product_name,
        SUM(total_revenue) AS total_ingresos,
        region,
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY SUM(total_revenue) DESC) AS orden
    FROM Online_Sales
    GROUP BY product_name, region
	) 
WHERE orden <= 5
ORDER BY region DESC, total_ingresos DESC;

--5. ¿Existen productos que solo se vendan en una región específica?
SELECT product_name, region
FROM Online_Sales
GROUP BY product_name
HAVING COUNT(DISTINCT region) = 1;

--6. ¿Qué producto generó más ingresos en el mes de enero?
SELECT product_name, SUM(total_revenue) AS total_ingresos, month
FROM Online_Sales
WHERE month == 'January'
GROUP BY product_name
ORDER BY total_ingresos DESC;

--7. ¿Cuáles son los 5 productos con más unidades vendidas en cada mes?
SELECT product_name, unidades_vendidas, month
FROM (
    SELECT 
        product_name,
        SUM(units_sold) AS unidades_vendidas,
        month,
        ROW_NUMBER() OVER (PARTITION BY month ORDER BY SUM(units_sold) DESC) AS orden
    FROM Online_Sales
    GROUP BY product_name, month
	) 
WHERE orden <= 5
ORDER BY month DESC, unidades_vendidas DESC;

--8. ¿Cuál es el producto con mayor ticket promedio dentro de su categoría?
SELECT product_name, product_category, ROUND(ticket_promedio, 2) AS ticket_promedio
FROM (
    SELECT 
        product_name,
        product_category,
        AVG(total_revenue) AS ticket_promedio,
        ROW_NUMBER() OVER (PARTITION BY product_category ORDER BY AVG(total_revenue) DESC) AS orden
    FROM Online_Sales
    GROUP BY product_name, product_category
    ) 
WHERE orden = 1
ORDER BY ticket_promedio DESC;

--9. ¿Qué 3 productos lideran los ingresos en cada categoría?
SELECT product_name, product_category, ROUND(total_ingresos, 2) AS total_ingresos
FROM (
    SELECT 
        product_name,
        product_category,
        SUM(total_revenue) AS total_ingresos,
        ROW_NUMBER() OVER (PARTITION BY product_category ORDER BY AVG(total_revenue) DESC) AS orden
    FROM Online_Sales
    GROUP BY product_name, product_category
    ) 
WHERE orden <= 3
ORDER BY  product_category ASC, total_ingresos DESC;

--10. ¿Cuál es el producto que aporta el mayor porcentaje de ingresos dentro de cada categoría?
SELECT product_name, product_category, porcentaje_ingresos
FROM (
    SELECT product_category,
           product_name,
           ROUND((SUM(total_revenue) * 100.0) / SUM(SUM(total_revenue)) OVER (PARTITION BY product_category), 2) AS Porcentaje_Ingresos,
           ROW_NUMBER() OVER (PARTITION BY product_category ORDER BY SUM(total_revenue) DESC) AS orden
    FROM Online_Sales
    GROUP BY product_name, product_category
	)
WHERE orden = 1
ORDER BY product_category;

