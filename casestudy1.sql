UPDATE Sales.SalesOrderHeader			
SET status = ABS(CHECKSUM(NEWID())) % 6 + 1;		

SELECT							
b.Name AS SalesTerritory,							
CASE status							
WHEN 1 THEN 'In process'							
WHEN 2 THEN 'Approved'							
WHEN 3 THEN 'Backordered'							
WHEN 4 THEN 'Rejected'							
WHEN 5 THEN 'Shipped'							
WHEN 6 THEN 'Cancelled'							
END AS Status,							
COUNT(SalesOrderID) AS Total_Order,							
FORMAT(SUM(CASE WHEN OnlineOrderFlag = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(SalesOrderID), 'P2') AS Ratio_On,							
FORMAT(SUM(CASE WHEN OnlineOrderFlag = 0 THEN 1 ELSE 0 END) * 1.0 / COUNT(SalesOrderID), 'P2') AS Ratio_Off							
FROM							
Sales.SalesOrderHeader a							
INNER JOIN Sales.SalesTerritory b ON a.TerritoryID = b.TerritoryID							
WHERE							
	YEAR(a.OrderDate) = 2013						
GROUP BY							
a.TerritoryID,							
Status,							
b.Name							
ORDER BY							
a.TerritoryID;							