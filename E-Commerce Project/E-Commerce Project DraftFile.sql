


--E-COMMERCE PROJECT


--////////////////////////////////////////////////


--1. Join all the tables and create a new table called combined_table. (market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)


SELECT 
	M.Sales, M.Discount, M.Order_Quantity, M.Product_Base_Margin, C.*, O.*, P.*, S.*
INTO 
	combined_table 
FROM
	market_fact AS M
	FULL OUTER JOIN cust_dimen AS C ON C.Cust_id=M.Cust_id
	FULL OUTER JOIN orders_dimen AS O ON O.Ord_id=M.Ord_id
	FULL OUTER JOIN prod_dimen AS P ON P.Prod_id=M.Prod_id
	FULL OUTER JOIN shipping_dimen AS S ON S.Ship_id=M.Ship_id


--/////////////////////////////////////////////////


--2. Find the top 3 customers who have the maximum count of orders.


SELECT TOP 3 Cust_id, COUNT(Ord_id) AS CountOfOrders
FROM combined_table
GROUP BY Cust_id
ORDER BY CountOfOrders DESC;


--//////////////////////////////////////////////////


--3.Create a new column at combined_table as DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.
--Use "ALTER TABLE", "UPDATE" etc.


ALTER TABLE combined_table
ADD DaysTakenForDelivery INT;

UPDATE combined_table
SET DaysTakenForDelivery=DATEDIFF(DAY, Order_Date, Ship_Date)

SELECT TOP 100 *
FROM combined_table;


--//////////////////////////////////////////////////


--4. Find the customer whose order took the maximum time to get delivered.
--Use "MAX" or "TOP"


SELECT Cust_id, Customer_Name, Order_Date, Ship_Date, DaysTakenForDelivery
FROM combined_table
WHERE DaysTakenForDelivery=(SELECT MAX(DaysTakenForDelivery)
						    FROM combined_table)


--//////////////////////////////////////////////////


--5. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011
--You can use such date functions and subqueries


SELECT COUNT(DISTINCT Cust_id) AS TotalNumOfUniqueCust
FROM combined_table
WHERE MONTH(Order_Date)=01 AND YEAR(Order_Date)=2011;


SELECT MONTH(Order_Date) AS [MONTH], COUNT(DISTINCT Cust_id) AS MonthlyNumOfCust
FROM combined_table
WHERE Cust_id IN
	 (SELECT DISTINCT Cust_id
	  FROM combined_table
	  WHERE MONTH(Order_Date)=01 AND YEAR(Order_Date)=2011
	  GROUP BY Cust_id)
	  AND YEAR(Order_Date)=2011
GROUP BY MONTH(Order_Date);


--///////////////////////////////////////////////////


--6. write a query to return for each user the time elapsed between the first purchasing and the third purchasing, 
--in ascending order by Customer ID
--Use "MIN" with Window Functions


SELECT 
	DISTINCT Cust_id, Order_Date, DenseNumber, FirstOrderDate,
	DATEDIFF(DD, FirstOrderDate, Order_Date) AS DaysElapsed
FROM
	(SELECT Cust_id, Order_Date,
	        MIN(Order_Date) OVER(PARTITION BY Cust_id ORDER BY Order_Date) AS FirstOrderDate,
	        DENSE_RANK() OVER(PARTITION BY Cust_id ORDER BY Order_Date) AS DenseNumber  
	 FROM combined_table) AS [DATES]
WHERE 
	DenseNumber = 3;


--////////////////////////////////////////////////////


--7. Write a query that returns customers who purchased both product 11 and product 14, 
--as well as the ratio of these products to the total number of products purchased by the customer.
--Use CASE Expression, CTE, CAST AND such Aggregate Functions


SELECT Cust_id,
		SUM(CASE WHEN Prod_id = 'Prod_11' THEN Order_Quantity ELSE 0 END) AS P11,
		SUM(CASE WHEN Prod_id = 'Prod_14' THEN Order_Quantity ELSE 0 END) AS P14,
		SUM(Order_Quantity) AS TotalProd,
		ROUND(CAST(SUM(CASE WHEN Prod_id = 'Prod_11' THEN Order_Quantity ELSE 0 END) AS FLOAT) / SUM(Order_Quantity),2) AS RATIO_P11,
		ROUND(CAST(SUM(CASE WHEN Prod_id = 'Prod_14' THEN Order_Quantity ELSE 0 END) AS FLOAT) / SUM(Order_Quantity),2) AS RATIO_P14
FROM combined_table
WHERE Cust_id IN(SELECT Cust_id
				 FROM combined_table
				 WHERE Prod_id IN ('Prod_11', 'Prod_14')
				 GROUP BY Cust_id
				 HAVING COUNT(DISTINCT Prod_id)=2)
GROUP BY Cust_id;


--/////////////////////////////////////////////////////


--CUSTOMER RETENTION ANALYSIS


--1. Create a view that keeps visit logs of customers on a monthly basis. (For each log, three field is kept: Cust_id, Year, Month)
--Use such date functions. Don't forget to call up columns you might need later.


CREATE VIEW visit_logs AS
	SELECT Cust_id, 
		   YEAR(Order_Date) AS [YEAR], 
		   MONTH(Order_Date) AS [MONTH]
	FROM combined_table;


SELECT *
FROM visit_logs
ORDER BY Cust_id, [YEAR], [MONTH];


--//////////////////////////////////////////////////////


--2. Create a view that keeps the number of monthly visits by users. (Separately for all months from the business beginning)
--Don't forget to call up columns you might need later.


CREATE VIEW monthly_visits AS
	SELECT Cust_id, 
		   YEAR(Order_Date) AS [YEAR], 
		   MONTH(Order_Date) AS [MONTH],
		   COUNT(Order_Date) AS NUM_OF_LOG
	FROM combined_table
	GROUP BY Cust_id, YEAR(Order_Date), MONTH(Order_Date);


SELECT * FROM monthly_visits


--//////////////////////////////////////////////////////


--3. For each visit of customers, create the next month of the visit as a separate column.
--You can number the months with "DENSE_RANK" function.
--then create a new column for each month showing the next month using the numbering you have made. (use "LEAD" function.)
--Don't forget to call up columns you might need later.


CREATE VIEW next_month_visits AS
	SELECT *, LEAD(current_month) OVER(PARTITION BY Cust_id ORDER BY [YEAR], [MONTH]) AS next_visit_month
	FROM (SELECT *, DENSE_RANK() OVER(ORDER BY [YEAR], [MONTH]) AS current_month 
		  FROM monthly_visits) AS M

SELECT * FROM next_month_visits


--/////////////////////////////////////////////////////


--4. Calculate the monthly time gap between two consecutive visits by each customer.
--Don't forget to call up columns you might need later.


CREATE VIEW monthly_time_gap AS
	SELECT *, next_visit_month-current_month AS TimeGaps
	FROM next_month_visits


SELECT * From monthly_time_gap


--/////////////////////////////////////////////////////


--5.Categorise customers using time gaps. Choose the most fitted labeling model for you.
--  For example: 
--	Labeled as churn if the customer hasn't made another purchase in the months since they made their first purchase.
--	Labeled as regular if the customer has made a purchase every month.
--  Etc.


SELECT Cust_id, AVG(TimeGaps) AS AvgTimeGap,
	   CASE WHEN AVG(TimeGaps) IS NULL THEN 'Churn'
		    WHEN MAX(TimeGaps) = 1 THEN 'regular'
		    ELSE 'irregular'	
	   END CustLabels
FROM monthly_time_gap
GROUP BY Cust_id;


--/////////////////////////////////////////////////////


--MONTH-WÝSE RETENTÝON RATE


--Find month-by-month customer retention rate  since the start of the business.


--1. Find the number of customers retained month-wise. (You can use time gaps)
--Use Time Gaps


SELECT *, COUNT(Cust_id) OVER(PARTITION BY [YEAR], [MONTH]) AS RetentionMonthWise
FROM monthly_time_gap
WHERE TimeGaps=1
ORDER BY Cust_id;


--//////////////////////////////////////////////////////


--2. Calculate the month-wise retention rate.

--Basic formula: o	Month-Wise Retention Rate = 1.0 * Total Number of Customers in The Previous Month / Number of Customers Retained in The Next Nonth

--It is easier to divide the operations into parts rather than in a single ad-hoc query. It is recommended to use View. 
--You can also use CTE or Subquery if you want.

--You should pay attention to the join type and join columns between your views or tables.


WITH CTE1 AS
	 (SELECT [YEAR], [MONTH], COUNT(Cust_id) AS TotalCustomerPerMonth,
	  SUM(CASE WHEN TimeGaps=1 THEN 1 END) AS RetentionMonthWise
	  FROM monthly_time_gap
	  GROUP BY [YEAR], [MONTH])
SELECT *
FROM(SELECT [YEAR], [MONTH], LAG(RetentionRate) OVER(ORDER BY [YEAR], [MONTH]) AS RetentionRate
	 FROM(SELECT CTE1.[YEAR], CTE1.[MONTH],
				 ROUND(CAST(CTE1.RetentionMonthWise AS FLOAT) / CTE1.TotalCustomerPerMonth,2) AS RetentionRate
          FROM CTE1) AS SUBQ1) AS SUBQ2
WHERE RetentionRate IS NOT NULL


---///////////////////////////////////