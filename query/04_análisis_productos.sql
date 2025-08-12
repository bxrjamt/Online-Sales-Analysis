--1. ¿Qué categoría genera más ingresos totales?
SELECT Product_Category, SUM(Total_Revenue) AS Total_Ingresos
FROM Online_Sales
GROUP BY Product_Category
ORDER BY Total_Ingresos DESC;

--2. ¿Qué categoría tiene el ticket promedio más alto?
SELECT product_category, ROUND(AVG(total_revenue),2) AS Ticket_Promedio
FROM Online_Sales
GROUP BY product_category
ORDER BY Ticket_Promedio DESC;

--3. ¿Qué categoría genera más ingresos a través de pagos con tarjeta de crédito?
SELECT product_category, SUM(total_revenue) AS Total_Ingresos, payment_method
FROM Online_Sales
WHERE payment_method == 'Credit Card'
GROUP BY product_category,payment_method
ORDER BY Total_Ingresos DESC;

--4. ¿Cuál es la categoría con mayor volumen de unidades vendidas los fines de semana?
SELECT product_category, SUM(units_sold) AS Unidades_Vendidas
FROM Online_Sales
WHERE day_of_week IN ('Saturday','Sunday')
GROUP BY product_category
ORDER BY Unidades_Vendidas DESC;

--5. ¿Qué categoría tiene mayores ingresos en los primeros 3 meses?
SELECT product_category, ROUND(SUM(Total_Ingresos),2) AS Ingresos_por_Categoría
FROM (
  SELECT product_category, SUM(total_revenue) AS Total_Ingresos, month
  FROM Online_Sales
  WHERE month IN ('January', 'February', 'March', 'April', 'May')
  GROUP BY product_category, month
  ORDER BY product_category ASC,Total_Ingresos DESC, month
  )
GROUP BY product_category
ORDER BY Total_Ingresos desc;

--6. ¿Cómo se distribuyen los ingresos por categoría según la región?
SELECT product_category, SUM(total_revenue) AS Total_Ingresos, region 
FROM Online_Sales
GROUP BY product_category,region
ORDER BY region DESC, Total_Ingresos DESC;

--7. ¿Hay alguna preferencia en las unidades vendidas por categoría según la región?
SELECT product_category, SUM(units_sold) AS Unidades_Vendidas, region 
FROM Online_Sales
GROUP BY product_category,region
ORDER BY region DESC, Unidades_Vendidas DESC;

--8. ¿Cuál es la categoría con mayor número de transacciones? 
SELECT product_category, COUNT(transaction_id) AS Total_Transacciones 
FROM Online_Sales
GROUP BY product_category
ORDER BY Total_Transacciones DESC;

--9. ¿Qué categorías tiene más transacciones pagadas con tarjeta de débito?
SELECT product_category, COUNT(transaction_id) AS Total_Transacciones 
FROM Online_Sales
WHERE payment_method == 'Debit Card'
GROUP BY product_category
ORDER BY Total_Transacciones DESC;

--10. ¿En qué categorías es más frecuente el pago con PayPal?
SELECT product_category, COUNT(transaction_id) AS Total_Transacciones 
FROM Online_Sales
WHERE payment_method == 'PayPal'
GROUP BY product_category
ORDER BY Total_Transacciones DESC;

--1. ¿Cuáles son los 10 productos más vendidos en unidades?
SELECT product_name, SUM(units_sold) AS Unidades_Vendidas
FROM Online_Sales
GROUP BY product_name
ORDER BY Unidades_Vendidas DESC
LIMIT 10;

--2. ¿Cuáles son los 10 productos con mayor facturación?
SELECT product_name, SUM(total_revenue) AS Total_Ingresos
FROM Online_Sales
GROUP BY product_name
ORDER BY Total_Ingresos DESC
LIMIT 10;

--3. ¿Hay productos con alta facturación pero pocas unidades vendidas?
SELECT product_name, SUM(total_revenue) AS Total_Ingresos, SUM(units_sold) as Unidades_Vendidas
FROM Online_Sales
GROUP BY product_name
ORDER BY Total_Ingresos DESC, Unidades_Vendidas ASC
LIMIT 10;

--4. ¿Cuál es el top 5 de productos con más ingresos en cada región?
SELECT product_name, Total_Ingresos, region
FROM (
    SELECT 
        product_name,
        SUM(total_revenue) AS Total_Ingresos,
        region,
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY SUM(total_revenue) DESC) AS orden
    FROM Online_Sales
    GROUP BY product_name, region
	) 
WHERE orden <= 5
ORDER BY region DESC, Total_Ingresos DESC;

--5. ¿Existen productos que solo se vendan en una región específica?

--6. ¿Qué producto generó más ingresos en el mes de enero?
SELECT product_name, SUM(total_revenue) AS Total_Ingresos, month
FROM Online_Sales
WHERE month == 'January'
GROUP BY product_name
ORDER BY Total_Ingresos DESC;

--7. ¿Cuáles son los 5 productos con más unidades vendidas en cada mes?
SELECT product_name, Unidades_Vendidas, month
FROM (
    SELECT 
        product_name,
        SUM(units_sold) AS Unidades_Vendidas,
        month,
        ROW_NUMBER() OVER (PARTITION BY month ORDER BY SUM(units_sold) DESC) AS orden
    FROM Online_Sales
    GROUP BY product_name, month
	) 
WHERE orden <= 5
ORDER BY month DESC, Unidades_Vendidas DESC;

--8. ¿Cuál es el producto con mayor ticket promedio dentro de su categoría?
SELECT product_name, product_category, ROUND(Ticket_Promedio, 2) AS Ticket_Promedio
FROM (
    SELECT 
        product_name,
        product_category,
        AVG(total_revenue) AS Ticket_Promedio,
        ROW_NUMBER() OVER (PARTITION BY product_category ORDER BY AVG(total_revenue) DESC) AS orden
    FROM Online_Sales
    GROUP BY product_name, product_category
    ) 
WHERE orden = 1
ORDER BY Ticket_Promedio DESC;

--9. ¿Qué 3 productos lideran los ingresos en cada categoría?
SELECT product_name, product_category, ROUND(Total_Ingresos, 2) AS Total_Ingresos
FROM (
    SELECT 
        product_name,
        product_category,
        SUM(total_revenue) AS Total_Ingresos,
        ROW_NUMBER() OVER (PARTITION BY product_category ORDER BY AVG(total_revenue) DESC) AS orden
    FROM Online_Sales
    GROUP BY product_name, product_category
    ) 
WHERE orden <= 3
ORDER BY  product_category ASC, Total_Ingresos DESC;

--10. ¿Cuál es el producto que aporta el mayor porcentaje de ingresos dentro de cada categoría?
SELECT product_name, product_category, Porcentaje_Ingresos
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

