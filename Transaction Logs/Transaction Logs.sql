--    TRANSACTION LOGS

--    ////////////////////////////////////////////////////


--    Below, you see a transaction table where the logs of transactions between accounts are stored. 
--    Write a query to return the change in net worth for each user, ordered by decreasing net change.

--    Transactions:
--    Sender_ID	 Receiver_ID  Amount  Transaction_Date
--	    55	         22	       500	    18.05.2021
--		11	         33	       350	    19.05.2021
--		22	         11	       650	    19.05.2021
--		22	         33	       900	    20.05.2021
--		33	         11	       500	    21.05.2021
--		33	         22	       750	    21.05.2021
--		11	         44	       300	    22.05.2021

--    Desired Output:
--    Account_ID  Net_Change
--       11	        500
--       44	        300
--       33	        0
--       22	       -300
--       55	       -500

--    /////////////////////////////////////////////////


--    A. Create above table (transactions) and insert values,


CREATE TABLE Transactions
(
	Sender_ID INT NOT NULL,
	Receiver_ID INT NOT NULL,
	Amount INT NOT NULL,
	Transaction_Date DATE NOT NULL
)

INSERT INTO Transactions(Sender_ID,Receiver_ID,Amount,Transaction_Date)
VALUES 
(55, 22, 500, '2021-05-18'),
(11, 33, 350, '2021-05-19'),
(22, 11, 650, '2021-05-19'),
(22, 33, 900, '2021-05-20'),
(33, 11, 500, '2021-05-21'),
(33, 22, 750, '2021-05-21'),
(11, 44, 300, '2021-05-22')
;


--   Second Solution (with set dateformat)


SET DATEFORMAT dmy
INSERT INTO Transactions(Sender_ID,Receiver_ID,Amount,Transaction_Date)  
VALUES 
(55, 22, 500, '18.05.2021'),
(11, 33, 350, '19.05.2021'),
(22, 11, 650, '19.05.2021'),
(22, 33, 900, '20.05.2021'),
(33, 11, 500, '21.05.2021'),
(33, 22, 750, '21.05.2021'),
(11, 44, 300, '22.05.2021')
;

--   ///////////////////////////////////////////////////


--   B.	Sum amounts for each sender (debits) and receiver (credits),

SELECT Sender_ID, SUM(Amount) AS TotalSentAmount
FROM Transactions
GROUP BY Sender_ID

SELECT Receiver_ID, SUM(Amount) AS TotalReceivedAmount
FROM Transactions
GROUP BY Receiver_ID

--   ///////////////////////////////////////////////////


--   C.	Full (outer) join debits and credits tables on account id, taking net change as difference between credits and debits, 
--   coercing nulls to zeros with coalesce()


SELECT
	 COALESCE(s.Sender_ID, r.Receiver_ID) AS Account_ID,
	 COALESCE(r.TotalReceivedAmount, 0)-COALESCE(s.TotalSentAmount, 0) AS Net_Change
FROM 
	 (SELECT Sender_ID, SUM(Amount) AS TotalSentAmount
	  FROM Transactions
	  GROUP BY Sender_ID) AS s
	 FULL OUTER JOIN (SELECT Receiver_ID, SUM(Amount) AS TotalReceivedAmount
					  FROM Transactions
					  GROUP BY Receiver_ID) AS r
	 ON s.Sender_ID=r.Receiver_ID
ORDER BY
	 Net_Change DESC

