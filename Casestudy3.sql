--Analyze customers who made purchases in all four quarters of 2013 and whose spending increased quarter by quarter.
WITH CTE as 
(
	SELECT
		CustomerID as Ma_khach_hang,
		DATEPART(QUARTER, OrderDate) AS quy,
		SUM(Subtotal) as Tong_Doanh_thu
	FROM sales.SalesOrderHeader
	WHERE YEAR(OrderDate)=2013
	GROUP BY
		CustomerID,
		DATEPART(QUARTER, OrderDate)
)
SELECT 
	Ma_khach_hang,
	COUNT(quy)as so_quy
FROM CTE
GROUP BY 
	Ma_khach_hang
HAVING COUNT(quy) = 4


--Calculate the sales growth between two quarters (Q4-2013 compared to Q3-2013) for each territory.
WITH CTE AS
(
	SELECT
		DATEPART(QUARTER,a.OrderDate) as quy,
		YEAR (a.OrderDate) as nam,
		b.name,
		SUM(a.subtotal) as doanh_thu,
		LAG (SUM(a.subtotal)) OVER (PARTITION by b.name ORDER BY DATEPART(QUARTER,a.OrderDate), YEAR (a.OrderDate)) AS quy_truoc
	FROM 
	[Sales].[SalesTerritory] AS b INNER JOIN sales.SalesOrderHeader AS a ON b.TerritoryID = a.TerritoryID
	WHERE (DATEPART(QUARTER,a.OrderDate)=3 OR DATEPART(QUARTER,a.OrderDate)=4) AND YEAR (a.OrderDate)=2013
	GROUP BY DATEPART(QUARTER,a.OrderDate),
		YEAR (a.OrderDate),
		b.name
)
SELECT 
	*,
	ISNULL(FORMAT((doanh_thu - quy_truoc)*1.0/quy_truoc, 'P2') ,0) AS GROWTH_RATE
FROM CTE

select * from  [Sales].[SalesTerritory]


-- Calculate the monthly sales growth in 2013 compared to the previous month.
WITH CTE AS (
SELECT
	YEAR(OrderDate) as year,
	MONTH(OrderDate) as month,
	SUM (SubTotal) AS sales
FROM sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2013 OR  YEAR(OrderDate) = 2012
GROUP BY
	YEAR(OrderDate),
	MONTH(OrderDate) 
),
CTE2 AS
(
	SELECT
		*,
		LAG (sales,12) OVER (ORDER BY YEAR, MONTH) AS thang_truoc
	FROM CTE
)
SELECT 
	*,
	FORMAT((sales - thang_truoc)*1.0/thang_truoc, 'P2') GROWTH_RATE
FROM CTE2
WHERE year = 2013

			
					
