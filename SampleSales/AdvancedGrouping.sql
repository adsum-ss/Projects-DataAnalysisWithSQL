
-- ADVANCED GROUPING OPERATIONS

-- GROUPING SETS


-- Write a query that returns the sales amount grouped by brand and category.

SELECT brand_name, category_name, SUM(list_price) AS [Sales]
FROM product.product p
     INNER JOIN product.brand b ON p.brand_id=b.brand_id
     INNER JOIN product.category c ON p.category_id=c.category_id
GROUP BY 
     GROUPING SETS(
	(brand_name, category_name),
	(brand_name),
	(category_name),
	()
)
ORDER BY brand_name, category_name;

---------------

SELECT GROUPING(brand_name) GroupingBrand, GROUPING(category_name) GroupingCategory, 
       brand_name, category_name, SUM(list_price) AS [Sales]
FROM product.product p
     INNER JOIN product.brand b ON p.brand_id=b.brand_id
     INNER JOIN product.category c ON p.category_id=c.category_id
GROUP BY 
     GROUPING SETS(
	(brand_name, category_name),
	(brand_name),
	(category_name),
	()
)
ORDER BY brand_name, category_name;


-- ///////////////////////////////////////////////////// --

-- ROLLUP


-- Write a query that uses the ROLLUP to calculate the sales amount by brand (subtotal) and both brand and category (total).

SELECT brand_name, category_name, SUM(list_price) AS [Sales]
FROM product.product p
     INNER JOIN product.brand b ON p.brand_id=b.brand_id
     INNER JOIN product.category c ON p.category_id=c.category_id
GROUP BY 
     ROLLUP(brand_name, category_name);

--------------

SELECT brand_name, category_name, SUM(list_price) AS [Sales]
FROM product.product p
     INNER JOIN product.brand b ON p.brand_id=b.brand_id
     INNER JOIN product.category c ON p.category_id=c.category_id
GROUP BY 
     brand_name, ROLLUP(category_name)
ORDER BY brand_name, category_name;


-- Write a query that uses the ROLLUP to calculate the average, total, max and min list prices by category (subtotal) and total.

SELECT 
    ISNULL(category_name,'TOTAL') AS [Category],
    AVG(list_price) AS [AverageListPrice],
    SUM(list_price) AS [TotalListPrice],
    MAX(list_price) AS [HighestListPrice],
    MIN(list_price) AS [LeastListPrice]
FROM 
    product.product AS p
    INNER JOIN product.category AS c ON p.category_id=c.category_id
GROUP BY 
    category_name WITH ROLLUP;


-- Write a query that uses the ROLLUP to calculate the average list price by category (subtotal) and brand (total) 
-- with the number of products belonging to it.

SELECT 
    ISNULL(category_name, 'GRAND') AS [Category],
    ISNULL(brand_name, 'TOTAL') AS [Brand],
    AVG(list_price) AS [AverageListPrice],
    COUNT(*) AS [NumofProducts]	
FROM 
    product.product AS p
    INNER JOIN product.category AS c ON p.category_id=c.category_id
    INNER JOIN product.brand AS b ON p.brand_id=b.brand_id
GROUP BY 
    category_name, brand_name WITH ROLLUP;


-- ///////////////////////////////////////////////////// --

-- CUBE


-- Write a query that uses the CUBE to calculate the sales amount by brand (subtotal) and both brand and category (total).

SELECT brand_name, category_name, SUM(list_price) AS [Sales]
FROM product.product p
     INNER JOIN product.brand b ON p.brand_id=b.brand_id
     INNER JOIN product.category c ON p.category_id=c.category_id
GROUP BY 
     CUBE(brand_name, category_name);

--------------

SELECT brand_name, category_name, SUM(list_price) AS [Sales]
FROM product.product p
     INNER JOIN product.brand b ON p.brand_id=b.brand_id
     INNER JOIN product.category c ON p.category_id=c.category_id
GROUP BY
     brand_name,
     CUBE(category_name);
     
