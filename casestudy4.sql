--1. Total revenue by quarters for each year
SELECT 
	YEAR,ISNULL([1],0) AS QUY_1,
	ISNULL([2],0) AS QUY_2,
	ISNULL([3],0) AS QUY_3,
	ISNULL([4],0) AS QUY_4
FROM						
(						
SELECT 
	DATEPART(YEAR, OrderDate) AS year,
	DATEPART(QUARTER, OrderDate) AS quarter,
	SUM(SUBTOTAL) as Tong_Doanh_thu
FROM sales.SalesOrderHeader
GROUP BY
	DATEPART(YEAR, OrderDate),
	DATEPART(QUARTER, OrderDate)					
) AS SourceTable						
PIVOT						
(						
SUM(Tong_Doanh_thu) 				
FOR quarter IN ([1], [2],[3], [4])						
) AS PivotTable;
	

--2. Total revenue by months for each year
SELECT 
	YEAR,ISNULL([1],0) AS MONTH_1,
	ISNULL([2],0) AS MONTH_2,
	ISNULL([3],0) AS MONTH_3,
	ISNULL([4],0) AS MONTH_4,
	ISNULL([5],0) AS MONTH_5,
	ISNULL([6],0) AS MONTH_6,
	ISNULL([7],0) AS MONTH_7,
	ISNULL([8],0) AS MONTH_8,
	ISNULL([9],0) AS MONTH_9,
	ISNULL([10],0) AS MONTH_10,
	ISNULL([11],0) AS MONTH_11,
	ISNULL([12],0) AS MONTH_12
FROM						
(						
SELECT 
	DATEPART(YEAR, OrderDate) AS YEAR,
	DATEPART(MONTH, OrderDate) AS MONTH,
	SUM(SUBTOTAL) as Tong_Doanh_thu
FROM sales.SalesOrderHeader
GROUP BY
	DATEPART(YEAR, OrderDate),
	DATEPART(MONTH, OrderDate)					
) AS SourceTable						
PIVOT						
(						
SUM(Tong_Doanh_thu) 				
FOR MONTH IN ([1], [2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])					
) AS PivotTable;


--3. In 2013, the total spending of customers
-- Requirement: customers who made purchases in both Q3 & Q4, and spending in Q4 > Q3
WITH CTE AS
(
	SELECT 
	CustomerID,
	YEAR,
	ISNULL([3],0) AS quy_3, 
	ISNULL([4],0) as quy_4
	FROM				
	(				
	SELECT 
		CustomerID,
		DATEPART(YEAR, OrderDate) AS YEAR,
		DATEPART(QUARTER, OrderDate) AS QUARTER,
		SUM(SubTotal) AS chi_tieu
	FROM [Sales].[SalesOrderHeader]	
	WHERE DATEPART(YEAR, OrderDate) = 2013 and (DATEPART(QUARTER, OrderDate)=3 or DATEPART(QUARTER, OrderDate)= 4)
	GROUP BY 
		DATEPART(YEAR, OrderDate),
		DATEPART(QUARTER, OrderDate),
		CustomerID
	) AS SourceTable
	PIVOT				
	(				
	SUM(chi_tieu)				
	FOR QUARTER IN ([3], [4])				
	) AS PivotTable				
)		
SELECT * 
FROM CTE
WHERE [quy_3]>0 AND (quy_4-quy_3)>0


--4. Calculate total revenue and total number of customers for the following regions:
-- Australia, Central, Canada, France, Northwest, [United Kingdom], Southwest, Southeast, Northeast, Germany
SELECT *
FROM				
(				
SELECT 
	'tong_doanh_thu' AS metric, 
	b.Name ten_kv, SUM(a.SubTotal) tong_tien							
FROM Sales.SalesOrderHeader a INNER JOIN Sales.SalesTerritory b ON a.TerritoryID = b.TerritoryID							
GROUP BY b.Name							
UNION ALL							
SELECT 'tong_khach_hang' AS metric, b.Name ten_kv, COUNT(*) tong_kh							
FROM Sales.SalesOrderHeader a INNER JOIN Sales.SalesTerritory b ON a.TerritoryID = b.TerritoryID							
GROUP BY b.Name					
) AS SourceTable				
PIVOT				
(				
SUM(tong_tien)				
FOR ten_kv IN (Australia,
Central,
Canada,
France,
Northwest,
[United Kingdom],
Southwest,
Southeast,
Northeast,
Germany)			
) AS PivotTable;				


--Total order value for each year
DECLARE @cols AS NVARCHAR(MAX),						
@query AS NVARCHAR(MAX);						
						
-- Combine data for all years in ascending order						
SELECT @cols = STRING_AGG(QUOTENAME(Year), ', ')						
WITHIN GROUP (ORDER BY Year)						
FROM (SELECT DISTINCT YEAR(orderdate) AS Year FROM sales.salesorderheader) AS Years;						
						
-- Create dynamic query						
SET @query = 'SELECT *						
FROM						
(						
SELECT YEAR(orderdate) AS year, SUM(subtotal) AS total_amt						
FROM sales.salesorderheader						
GROUP BY YEAR(orderdate)						
) AS SourceTable						
PIVOT						
(						
SUM(total_amt)						
FOR year IN (' + @cols + ')						
) AS PivotTable;';						

-- Execute dynamic query	
EXEC sp_executesql @query;	

		