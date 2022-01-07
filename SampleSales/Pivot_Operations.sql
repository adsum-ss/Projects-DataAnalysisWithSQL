
-- PIVOT OPERATIONS
-- (WITH DYNAMIC PIVOT OPERATIONS)


-- Write a query that returns the number of products for each category name by model year.


-- to get category names
SELECT ',' + QUOTENAME(category_name) 
FROM product.category


SELECT * FROM   
(
    SELECT category_name, product_id, model_year
    FROM product.product p INNER JOIN product.category c ON c.category_id = p.category_id
) BaseData 
PIVOT(
    COUNT(product_id) 
    FOR category_name IN(
        [Children Bicycles], 
        [Comfort Bicycles], 
        [Cruisers Bicycles], 
        [Cyclocross Bicycles], 
        [Electric Bikes], 
        [Mountain Bikes], 
        [Road Bikes])
) AS PivotTable;


-- Write a query that returns the amount of total orders for each brand by years and months.


-- to get brand names
SELECT ',' + QUOTENAME(brand_name) 
FROM product.brand


SELECT * FROM
	(SELECT 
		brand_name,
		YEAR(order_date) AS [OrderYear],
		DATENAME(MM, order_date) AS [OrderMonth],
		quantity
	 FROM sale.order_item oi 
		LEFT JOIN sale.orders o ON oi.order_id=o.order_id
		LEFT JOIN product.product p ON oi.product_id=p.product_id 
		LEFT JOIN product.brand b ON p.brand_id=b.brand_id) AS BaseData
PIVOT (
	SUM(quantity)
	FOR brand_name
	IN ([Electra]
		,[Haro]
		,[Redline]
		,[Cannondale]
		,[Schwinn]
		,[Giant]
		,[Sun Bicycles]
		,[Surly]
		,[Trek])
) AS PivotTable
ORDER BY OrderYear DESC;


-- Write a query that returns the average list prices according to brands and categories.
 
 
SELECT * FROM
(
	SELECT brand_name, category_name, CAST(list_price AS INT) AS ListPrice 
	FROM product.product AS P, product.brand AS B, product.category AS C
	WHERE P.brand_id=B.brand_id AND P.category_id=C.category_id
) AS SubQ1
PIVOT
(
	AVG(ListPrice)
	FOR brand_name
	IN([Trek],[Schwinn],[Surly],[Redline],[Electra],[Cannondale],[Haro],[Sun Bicycles],[Giant])
) AS CategoryBrandPrices
 
 
-- (replace null values with '0')
 
 
SELECT category_name,
	CONVERT(DECIMAL, ISNULL([Trek], 0)) AS [Trek],
	CONVERT(DECIMAL, ISNULL([Schwinn], 0)) AS [Schwinn],
	CONVERT(DECIMAL, ISNULL([Surly], 0)) AS [Surly],
	CONVERT(DECIMAL, ISNULL([Redline], 0)) AS [Redline],
	CONVERT(DECIMAL, ISNULL([Electra], 0)) AS [Electra],
	CONVERT(DECIMAL, ISNULL([Cannondale], 0)) AS [Cannondale],
	CONVERT(DECIMAL, ISNULL([Haro], 0)) AS [Haro],
	CONVERT(DECIMAL, ISNULL([Sun Bicycles], 0)) AS [Sun Bicycles],
	CONVERT(DECIMAL, ISNULL([Giant], 0)) AS [Giant]
FROM
(
	SELECT brand_name, category_name, list_price
	FROM product.product AS P, product.brand AS B, product.category AS C
	WHERE P.brand_id=B.brand_id AND P.category_id=C.category_id
) AS SubQ1
PIVOT
(
	AVG(list_price)
	FOR brand_name
	IN([Trek],[Schwinn],[Surly],[Redline],[Electra],[Cannondale],[Haro],[Sun Bicycles],[Giant])
) AS CategoryBrandPrices


-- ///////////////////////////////////////////////////////////// --

-- DYNAMIC PIVOT OPERATIONS


-- Write a query that returns the number of products for each category name by model year.
-- (USE DYNAMIC PIVOT)

DECLARE 
    @ColumnName NVARCHAR(MAX) = '', 
    @DynamicPivotQuery NVARCHAR(MAX) = '';

SELECT 
    @ColumnName += QUOTENAME(category_name) + ','
FROM 
    product.category
ORDER BY 
    category_name;

SET @ColumnName = LEFT(@ColumnName, LEN(@ColumnName) - 1);

SET @DynamicPivotQuery =
'SELECT * FROM   
(
    SELECT 
        category_name, 
        model_year,
        product_id 
    FROM 
        product.product p
        INNER JOIN product.category c 
            ON c.category_id = p.category_id
) BaseData 
PIVOT(
    COUNT(product_id) 
    FOR category_name IN ('+ @ColumnName +')
) AS PivotTable;';

EXECUTE sp_executesql @DynamicPivotQuery;





