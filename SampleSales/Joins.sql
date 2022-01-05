use SampleSales

------------------- JOINS --------------------

-- //////////////////////////////////////// --

-- INNER JOIN


-- List employees of stores with their store information (store_name, state)

SELECT staff_id, first_name, last_name, store_name, [state]
FROM sale.staff AS staff
     INNER JOIN sale.store AS store ON staff.store_id=store.store_id

----------

SELECT staff_id, first_name, last_name, store_name, [state]
FROM sale.staff AS staff, sale.store AS store
WHERE staff.store_id=store.store_id;


-- List products with product ID greater than 200 by brand and category names

SELECT	product_id, product_name, brand_name, category_name
FROM	product.product AS P 
	INNER JOIN product.brand AS B ON P.brand_id = B.brand_id
	INNER JOIN product.category AS C ON P.category_id = C.category_id
	AND product_id > 200


-- //////////////////////////////////////// --

-- LEFT JOIN


-- Write a query that returns products that have never been ordered (with brand and category names)
-- (USE LEFT JOIN)

SELECT P.product_id, product_name, brand_name, category_name
FROM product.product AS P
     LEFT JOIN sale.order_item AS O ON P.product_id=O.product_id
     LEFT JOIN product.brand AS B ON P.brand_id = B.brand_id
     LEFT JOIN product.category AS C ON P.category_id = C.category_id
WHERE order_id IS NULL
ORDER BY 1;


-- Report the stock status of the products whose quantity is greater than 20 in the stores.
-- Expected columns: Product_id, Product_name, Store_name, quantity

SELECT S.product_id, product_name, quantity, store_name
FROM product.stock AS S
     LEFT JOIN product.product AS P ON S.product_id=P.product_id
     LEFT JOIN sale.store ON S.store_id=sale.store.store_id
WHERE quantity > 20;


-- Find the products that belong to the order id 100. (return all products)

SELECT p.product_id, product_name, order_id
FROM product.product p
     LEFT JOIN sale.order_item o ON o.product_id = p.product_id AND o.order_id = 100
ORDER BY order_id DESC;


-- Find the products that belong to the order id 100. 

SELECT p.product_id, product_name, order_id
FROM product.product p
     LEFT JOIN sale.order_item o ON o.product_id = p.product_id
WHERE order_id = 100
ORDER BY product_id;


-- Report the orders information made by all staffs.
-- Expected columns: Staff_id, first_name, last_name, store_name, total orders

WITH OrdersInfo AS
(
	SELECT 
		staff_id, store_id, COUNT(staff_id) AS TotalOrders
	FROM 
		sale.orders
	GROUP BY 
		staff_id, store_id
)
SELECT O.staff_id, first_name, last_name, TotalOrders, store_name
FROM OrdersInfo AS O
     LEFT JOIN sale.staff AS staff ON O.staff_id=staff.staff_id
     LEFT JOIN sale.store AS store ON O.store_id=store.store_id
ORDER BY 1;


-- //////////////////////////////////////// --

-- RIGHT JOIN


-- Report the stock status of the products that product id greater than 310 in the stores.
-- Expected columns: Product_id, Product_name, Store_id, quantity (USE RIGHT JOIN)

SELECT A.product_id, product_name, store_id, quantity
FROM product.stock A RIGHT JOIN product.product B ON A.product_id=B.product_id
WHERE B.product_id > 310
ORDER BY store_id;


-- Find the products that do not have any sales.

SELECT product_name, order_id
FROM sale.order_item o
     RIGHT JOIN product.product p ON o.product_id=p.product_id
WHERE order_id IS NULL
ORDER BY product_name;


-- //////////////////////////////////////// --

-- FULL OUTER JOIN


--Write a query that returns products with their list price that don't exist in the stock

SELECT P.product_id, product_name, list_price
FROM product.stock S
     FULL OUTER JOIN product.product P ON S.product_id=P.product_id
WHERE S.product_id IS NULL;


-- Write a query that returns stock and order information together for all products . (TOP 20)
-- Expected columns: Product_id, store_id, quantity, order_id, list_price (USE FULL OUTER JOIN)

SELECT TOP 20*
FROM sale.order_item A 
     FULL OUTER JOIN product.stock B ON A.product_id=B.product_id
ORDER BY B.product_id, A.order_id;


-- find the products that have never been ordered and orders which do not exist in the stock.

SELECT *
FROM sale.order_item A 
     FULL OUTER JOIN product.stock B ON A.product_id=B.product_id
WHERE A.product_id IS NULL OR B.product_id IS NULL;


-- //////////////////////////////////////// --

-- SELF JOIN


-- Write a query that returns staff information with their manager names

SELECT s1.staff_id, s1.first_name, s1.last_name, s2.first_name + ' ' + s2.last_name AS ManagerName
FROM sale.staff AS s1 INNER JOIN sale.staff AS s2 ON s1.manager_id=s2.staff_id;

SELECT s1.staff_id, s1.first_name, s1.last_name, s2.first_name + ' ' + s2.last_name AS ManagerName
FROM sale.staff AS s1 LEFT JOIN sale.staff AS s2 ON s1.manager_id=s2.staff_id;


-- Write a query that returns the customers located in the same city.

SELECT
    c1.city,
    c1.first_name + ' ' + c1.last_name customer_1,
    c2.first_name + ' ' + c2.last_name customer_2	
FROM
    sale.customer c1
	INNER JOIN sale.customer c2 ON c1.customer_id > c2.customer_id
	AND c1.city = c2.city
ORDER BY
    city,
    customer_1,
    customer_2;


-- //////////////////////////////////////// --

-- CROSS JOIN


-- Write a query that returns the products that have no sales across the stores.

SELECT s.store_id, s.store_name, p.product_id, ISNULL(sales, 0) sales
FROM sale.store s
     CROSS JOIN product.product p
     LEFT JOIN (SELECT s.store_id, p.product_id, SUM (quantity * i.list_price) sales
		FROM sale.orders o
		     INNER JOIN sale.order_item i ON i.order_id = o.order_id
		     INNER JOIN sale.store s ON s.store_id = o.store_id
		     INNER JOIN product.product p ON p.product_id = i.product_id
		GROUP BY s.store_id, p.product_id
		) c ON c.store_id = s.store_id
		    AND c.product_id = p.product_id
WHERE sales IS NULL
ORDER BY product_id, store_id;

