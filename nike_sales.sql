-- Analyzing Nike sales for 2024
-- Skills used: CTE's, Aggregate Functions, String Functions

-- Select data we are starting with
SELECT Month,Region,
format(Units_Sold,0)as Units_Sold,
format(Revenue_USD,0)as Revenue_USD,
Retail_Price
FROM nike_sales_2024 order by Region;

-- Total Units Sold and Total Income for each Region
select Region,Month, FORMAT(sum(Units_Sold),0)as Total_Units_Sold,FORMAT(sum(Revenue_USD),0)as Total_Income 
from nike_sales_2024 group by Region,Month order by Region;

-- Highest Income
-- Shows in which month each region had the higgest income
WITH total_income AS (
    SELECT Region, Month, sum(Revenue_USD)as Total_Income
    FROM nike_sales_2024
    GROUP BY Region, Month
),
max_income AS (
    SELECT Region, MAX(Total_Income) AS Max_Income
    FROM total_income
    GROUP BY Region
)
SELECT ti.Region, ti.Month, format(ti.Total_Income,0) as MAX_Income
FROM total_income ti
JOIN max_income mi ON ti.Region = mi.Region AND ti.Total_Income = mi.Max_Income;

-- Lowest Income
-- Shows in which month each region had the lowest income
WITH total_income AS (
    SELECT Region, Month, sum(Revenue_USD)as Total_Income
    FROM nike_sales_2024
    GROUP BY Region, Month
),
min_income AS (
    SELECT Region, MIN(Total_Income) AS Min_Income
    FROM total_income
    GROUP BY Region
)
SELECT ti.Region, ti.Month, format(ti.Total_Income,0) as MIN_Income
FROM total_income ti
JOIN min_income mi ON ti.Region = mi.Region AND ti.Total_Income = mi.Min_Income;

-- Products and their Price per Region
select Region,Product_Line,round(AVG(Retail_Price),2)as Average_Price from nike_sales_2024
group by Product_Line,Region order by Region;

-- Income distribution by Price Tier(Budget, Mid-Range and Premium) and Region
select Region,Price_Tier,format(sum(Units_Sold*Retail_Price),0)as Total_Income from nike_sales_2024
group by Region, Price_Tier order by Region, Price_Tier;

-- Shows 5 best-selling products
select Product_Line as Products, sum(Units_Sold) as Units_Sold 
from nike_sales_2024 group by Product_Line order by Units_Sold desc Limit 5;

-- Shows the 5 worst-selling products
select Product_Line as Products, sum(Units_Sold) as Units_Sold 
from nike_sales_2024 group by Product_Line order by Units_Sold Limit 5;

-- Sales Performance by Sub-Category
select Sub_Category, 
round((SUM(Units_Sold) / (select SUM(Units_Sold) from nike_sales_2024)) * 100, 2) AS Percentage, 
sum(Units_Sold) as Units_Sold,
sum(Revenue_USD)as Total_Income
from nike_sales_2024 GROUP BY Sub_Category;

-- Online Income VS In-Store Income
select Month,Region, 
ROUND(sum(Revenue_Usd*(Online_Sales_Percentage/100)),0) as Online_Income,
ROUND(sum(Revenue_Usd-(Revenue_Usd*(Online_Sales_Percentage/100))),0) as InStore_Income 
from nike_sales_2024
group by Month, Region order by Region;


-- Top-Earning products
-- Shows which products generate the highest values
select Product_Line, sum(Revenue_USD)as Total_Income from nike_sales_2024
 group by Product_Line order by Total_Income desc limit 10;

-- Shows total income for sub-categories for each main category
select Main_Category, Sub_Category, sum(Revenue_USD)as Total_Income from nike_sales_2024 
group by Main_Category,Sub_Category order by Main_Category, Total_Income desc;

-- Price Impact on Online Sales per Region
select Region, Product_Line, 
ROUND(avg(Retail_Price),2)as AVG_Price, ROUND(sum(Revenue_Usd*(Online_Sales_Percentage/100)),0) as Online_Income
from nike_sales_2024 group by Region, Product_Line order by Region;

-- Data from: https://www.kaggle.com/datasets/ayushcx/nike-global-sales-data-2024?resource=download 
-- Tableau: https://public.tableau.com/app/profile/doroteja.djordjevic/vizzes
-- This analysis of Nike's 2024 sales data explores regional pricing strategies, income distribution, 
-- product performance, and the impact of retail prices on online and in-store sales.
