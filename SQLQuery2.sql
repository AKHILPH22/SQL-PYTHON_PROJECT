DROP TABLE df_orders

create table df_orders(
[order_id] int primary key, 
[order_date] date, 
[ship_mode] varchar(20),
[segment] varchar(20),
[country] varchar(20), 
[city] varchar(20),
[state] varchar(20), 
[postal_code] varchar(20), 
[region] varchar(20), 
[category] varchar(20),
[sub_category] varchar(20),
[product_id] varchar(50), 
[quantity] int, 
[discount] decimal(7,2), 
[sale_price] decimal(7,2), 
[profit] decimal(7,2)
)

SELECT * FROM DF_ORDERS

----top 10 highest revenue generating products

SELECT top 10 product_id, sum(sale_price)as sales from df_orders
group by product_id
order by sales desc


--top 5 highest selling products in each region


with cte as (
SELECT region, product_id, sum(sale_price)as sales from df_orders
group by region, product_id)

SELECT * FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY REGION ORDER BY SALES DESC) AS RN
FROM cte) A
WHERE RN <= 5


------MONTH OVER MONTH COMPARISON

SELECT DISTINCT YEAR(ORDER_DATE) FROM df_orders

WITH CTE AS(
SELECT YEAR(ORDER_DATE) AS ORDER_YEAR, MONTH(ORDER_DATE) AS ORDER_MONTH, SUM(SALE_PRICE) AS SALES FROM DF_ORDERS
GROUP BY YEAR(ORDER_DATE), MONTH(ORDER_DATE)
--ORDER BY YEAR(ORDER_DATE), MONTH(ORDER_DATE)
)
SELECT ORDER_MONTH,

SUM(
CASE 
WHEN ORDER_YEAR = 2022
THEN SALES ELSE 0
END) AS SALES_2022, 

SUM(
CASE 
WHEN ORDER_YEAR = 2023
THEN SALES ELSE 0
END) AS SALES_2023

FROM CTE
GROUP BY ORDER_MONTH
ORDER BY ORDER_MONTH


-----FOR EACH CATEGORY WHICH MONTH HAD HIGHEST SALES

SELECT TOP 10* FROM df_orders

WITH CTE AS (
SELECT CATEGORY, MONTH(order_date) AS ORDER_MONTH, SUM(sale_price) AS SALES FROM DF_ORDERS
GROUP BY CATEGORY, MONTH(ORDER_DATE)
--ORDER BY category, SALES DESC)
)
SELECT * FROM(
SELECT *, ROW_NUMBER() over (partition by category order by sales desc) as rn
from cte) A 
WHERE RN = 1


------ANOTHER WAY OF DOING THE SAME PROBLEM
WITH CTE AS (
SELECT CATEGORY, FORMAT(ORDER_DATE, 'yyyyMM') AS ORDER_YEAR_MONTH, sum(sale_price) as sales
FROM df_orders
GROUP BY CATEGORY, FORMAT(ORDER_DATE, 'yyyyMM')
)

SELECT * FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY CATEGORY ORDER BY SALES) AS RN
FROM CTE
) A 
WHERE RN = 1 


----------WHICH SUB CATEGORY HAD HIGHEST GROWTH BY PROFIT IN 2023 COMPARED TO 2022

SELECT TOP 10* FROM df_orders

WITH CTE AS(
SELECT SUB_CATEGORY,  YEAR(ORDER_DATE) AS ORDER_YEAR, SUM(SALE_PRICE) AS SALES FROM DF_ORDERS
GROUP BY SUB_CATEGORY, YEAR(ORDER_DATE)
--ORDER BY YEAR(ORDER_DATE), MONTH(ORDER_DATE)
)
, CTE2 AS (
SELECT SUB_CATEGORY,

SUM(
CASE 
WHEN ORDER_YEAR = 2022
THEN SALES ELSE 0
END) AS SALES_2022, 

SUM(
CASE 
WHEN ORDER_YEAR = 2023
THEN SALES ELSE 0
END) AS SALES_2023

FROM CTE
GROUP BY SUB_CATEGORY
)

SELECT TOP 1* , (SALES_2023 - SALES_2022)*100/SALES_2022 AS GROWTH_PERCENTAGE
FROM CTE2
ORDER BY (SALES_2023 - SALES_2022)*100/SALES_2022 DESC

