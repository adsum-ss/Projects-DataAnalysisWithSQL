

-- GROUPING OPERATIONS BY GROUP BY


-- Bring category_ids with a maximum list price above 3000 or a minimum list price below 300
-- (for each brand)

SELECT brand_id, category_id, 
       MAX(list_price) AS MaxListPrice, 
       MIN(list_price) AS MinListPrice 
FROM product.product
GROUP BY brand_id, category_id
HAVING MAX(list_price) > 3000 OR MIN(list_price) < 300
ORDER BY brand_id;


-- Write a query that returns the average list price for each brand

SELECT P.brand_id, brand_name, CONVERT(DECIMAL(18,2), AVG(list_price)) AS AvgPrice
FROM product.product P, product.brand B
WHERE P.brand_id=B.brand_id
GROUP BY P.brand_id, brand_name

----------

SELECT P.brand_id, brand_name, ROUND(AVG(CAST(list_price AS FLOAT)), 2) AS AvgPrice
FROM product.product P, product.brand B
WHERE P.brand_id=B.brand_id
GROUP BY P.brand_id, brand_name
ORDER BY AvgPrice DESC;


-- Write a query that returns the average list price by brand for all products with the model year 2019

SELECT
    brand_name,
    AVG(list_price) AvgPrice
FROM
    product.product p
    INNER JOIN product.brand b ON p.brand_id = b.brand_id
WHERE
    model_year=2019
GROUP BY
    brand_name
ORDER BY
    brand_name;


-- Write a query that returns the domain types and quantities in the customer table

SELECT  
        RIGHT(email, LEN(email)-CHARINDEX('@', email)) AS DomainType,
	COUNT(RIGHT(email, LEN(email)-CHARINDEX('@', email))) AS NumofDomains
FROM 
	sale.customer
GROUP BY
	RIGHT(email, LEN(email)-CHARINDEX('@', email))
ORDER BY
	NumofDomains DESC;

