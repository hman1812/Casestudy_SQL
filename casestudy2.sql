--List employees who generated a total revenue greater than 500 USD in Q4 of 2013.
SELECT TOP (3)
	SalesPersonID as Ma_Nhan_Vien, 
	sum(SubTotal) as Tong_Doanh_Thu
FROM sales.SalesOrderHeader
WHERE datepart(quarter,OrderDate)=4 and YEAR(OrderDate)=2013 and SalesPersonID is not null 
GROUP BY SalesPersonID
HAVING sum(SubTotal) > 700
ORDER BY sum(SubTotal) DESC

SELECT 
	SalesPersonID as Ma_Nhan_Vien, 
	sum(SubTotal) as Tong_Doanh_Thu
FROM sales.SalesOrderHeader
WHERE datepart(quarter,OrderDate)=4 and YEAR(OrderDate)=2013 and SalesPersonID is not null 
GROUP BY SalesPersonID
HAVING sum(SubTotal) > 700
ORDER BY sum(SubTotal) DESC


--List the top 5 subcategories with the highest total revenue in Q3 of 2013.
SELECT top (5)
	d.Name as Ten_Danh_Muc,
	sum(b.LineTotal) as Tong_Doanh_Thu
FROM 
	sales.SalesOrderHeader as a inner join Sales.SalesOrderDetail as b ON a.SalesOrderID = b.SalesOrderID
	inner join Production.Product as c ON b.ProductID = c.ProductID 
	inner join Production.ProductSubcategory as d ON c.ProductSubcategoryID = d.ProductSubcategoryID
WHERE datepart(quarter,OrderDate)=3 and YEAR(OrderDate)=2013
GROUP BY d.Name
ORDER BY sum(b.LineTotal) DESC


--Customer segmentation is based on the average basket value per transaction.
WITH CTE as
(
	SELECT 
		a.CustomerID as Ma_khach_hang,
		b.Name as [Khu Vuc], 
		sum(a.Subtotal) as Tong_Doanh_thu,
		count(a.salesorderid) as so_hoa_don,
		cast(sum(a.subtotal)*1.0/Count(a.salesorderid) as decimal (10,2)) as avg_basket_value
	FROM Sales.SalesOrderHeader as a inner join Sales.SalesTerritory as b on a.TerritoryID = b.TerritoryID
	GROUP BY a.CustomerID, b.Name 
)
SELECT *,
	CASE 
	WHEN avg_basket_value >2000 THEN  'HIGH'
	WHEN avg_basket_value <1000 THEN 'LOW'
	ELSE 'MEDIUM'
	END AS [Phan khuc]
FROM CTE

 

--Provide additional details on the average basket size
WITH CTE2 AS (		
	SELECT 
			a.CustomerID as Ma_khach_hang,
			b.Name as [Khu Vuc], 
			sum(a.Subtotal) as Tong_Doanh_thu,
			count(a.salesorderid) as so_hoa_don,
			cast(sum(Subtotal)*1.0/Count(a.salesorderid) as decimal (10,2)) as avg_basket_value
		FROM Sales.SalesOrderHeader as a inner join Sales.SalesTerritory as b on a.TerritoryID = b.TerritoryID
		GROUP BY a.CustomerID, b.Name 
),		
CTE1 AS (		
	SELECT *,
		CASE 
		WHEN avg_basket_value >2000 THEN  'HIGH'
		WHEN avg_basket_value < 1000 THEN 'LOW'
		ELSE 'MEDIUM'
		END AS [Phan khuc]
	FROM CTE2
)			
SELECT 
	[Khu Vuc],
	[Phan khuc],
	count (Ma_khach_hang) as unique_customers,
	sum(so_hoa_don) as Tong_giao_dich,
	sum(Tong_Doanh_thu)_Tong_doanh_thu,
	cast(sum(Tong_Doanh_thu)*1.0/Count(so_hoa_don) as decimal (10,2)) as avg_basket_size
FROM CTE1	
GROUP BY
	[Khu Vuc],
	[Phan khuc]