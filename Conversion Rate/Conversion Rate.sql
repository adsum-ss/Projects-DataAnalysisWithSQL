-- CONVERSION RATE

-- ////////////////////////////////////////////////

-- Below you see a table of the actions of customers visiting the website by clicking on two different types of advertisements 
-- given by an E-Commerce company. Write a query to return the conversion rate for each Advertisement type.


-- Actions:

-- Visitor_ID      Adv_Type      Action

--     1              A			  Left
--     2			  A			  Order
--     3			  B			  Left
--     4			  A			  Order
--     5			  A			  Review
--     6			  A			  Left
--     7			  B			  Left
--     8			  B			  Order
--     9			  B			  Review
--     10			  A			  Review


-- Desired Output:

-- Adv_Type		Conversion_Rate

--    A				 0.33
--    B				 0.25

-- ///////////////////////////////////////////////////


-- a. Create above table (Actions) and insert values,


CREATE TABLE Actions
(
	Visitor_ID INT NOT NULL,
	Adv_Type VARCHAR(MAX) NOT NULL,
	[Action] VARCHAR(MAX) NOT NULL,
)

INSERT INTO Actions(Visitor_ID,Adv_Type,[Action])  
VALUES 
(1, 'A', 'Left'),
(2, 'A', 'Order'),
(3, 'B', 'Left'),
(4, 'A', 'Order'),
(5, 'A', 'Review'),
(6, 'A', 'Left'),
(7, 'B', 'Left'),
(8, 'B', 'Order'),
(9, 'B', 'Review'),
(10, 'A', 'Review')


-- b. Retrieve count of total Actions and Orders for each Advertisement Type,


SELECT Adv_Type, COUNT([Action]) AS TotalActions
FROM Actions
GROUP BY Adv_Type

SELECT Adv_Type, COUNT([Action]) AS TotalOrders
FROM Actions
WHERE [Action]='Order'
GROUP BY Adv_Type, [Action]


-- c. Calculate Orders (Conversion) rates for each Advertisement Type by dividing by total count of actions 
--    casting as float by multiplying by 1.0.


SELECT
	T.Adv_Type, CAST(CAST(TotalOrders AS FLOAT)/TotalActions AS DECIMAL(18,2)) AS Conversion_Rate
FROM
	(SELECT Adv_Type, COUNT(Action) AS TotalActions
	 FROM Actions
	 GROUP BY Adv_Type) AS T
	FULL OUTER JOIN (SELECT Adv_Type, COUNT([Action]) AS TotalOrders
					 FROM Actions
					 WHERE [Action]='Order'
					 GROUP BY Adv_Type, [Action]) AS O
	ON T.Adv_Type=O.Adv_Type


-- SECOND SOLUTION

WITH T1 AS
(
	SELECT Adv_Type, COUNT([Action]) AS TotalActions
	FROM Actions
	GROUP BY Adv_Type
),
	T2 AS
(
	SELECT Adv_Type, COUNT([Action]) AS TotalOrders
	FROM Actions
	WHERE [Action]='Order'
	GROUP BY Adv_Type, [Action]
)
SELECT 
	T1.Adv_Type, CAST(CAST(TotalOrders AS float)/TotalActions AS DECIMAL(18,2)) AS Conversion_Rate
FROM 
	T1,T2
WHERE 
	T1.Adv_Type = T2.Adv_Type;


-- ////////////////////////////////////////////////////////

WITH T1 AS
(
SELECT *
FROM  (VALUES
		(1,'A', 'Left'),
		(2,'A', 'Order'),
		(3,'B', 'Left'),
		(4,'A', 'Order'),
		(5,'A', 'Review'),
		(6,'A', 'Left'),
		(7,'B', 'Left'),
		(8,'B', 'Order'),
		(9,'B', 'Review'),
		(10,'A', 'Review')
		) A (visitor_id, adv_type, [Action])
), T2 AS
(
SELECT	adv_type, 
		COUNT (*) total_count,
		SUM (CASE WHEN [Action] = 'Order' THEN 1 ELSE 0 END) AS cnt_order
FROM T1
GROUP BY adv_type
)
SELECT	adv_type, CONVERT(NUMERIC(3,2)  , 1.0 * cnt_order / total_count) conversion_rate
FROM	T2
