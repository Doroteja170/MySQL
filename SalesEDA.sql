-- Product Report:
-- 1) Extract essential product data like product name, category, price, and classification.
-- 2) Aggregate product-level metrics:
-- 		Total number of sales transactions.
-- 		Total quantity of units sold.
-- 		Total revenue (accounting for discounts).
-- 3) Segment products based on revenue performane:
-- 		Categorize products as High-Performer, Mid-Range, or Low-Performer based on total revenue.
-- 4) Calculate key performance indicators (KPIs):
-- 		Average revenue per sale to assess product profitability.
-- 5) Identify product lifecycle insights:
-- 		Track the last sale date of each product.
-- 		Calculate the expiration date based on modification date and vitality period.	
with base as(
select s.SalesID, s.SalesDate,  s.Quantity, s.Discount,
p.ProductName as Product, c.CategoryName as Category, p.class, p.Price, p.ModifyDate, p.VitalityDays
from sales s
join products p on s.ProductID=p.ProductID
join categories c on p.CategoryID=c.CategoryID
where s.SalesDate is not null
),
sales_data as (
select Product,Category,Class,Price,
max(SalesDate) as LastSale,
date_add(ModifyDate, interval VitalityDays day) as ExpirationDate,
count(SalesID) as TotalSales,
round(sum((price*quantity) - (price * (1-discount)) / 100)) AS TotalRevenue,
sum(quantity) as TotalQuantity
from base
group by Product,Category,Class,Price,ExpirationDate
)
select Product,
Category,
Class,
ExpirationDate,
Price,
LastSale,
TotalSales,
TotalRevenue,
TotalQuantity,
CASE 
        WHEN TotalRevenue >= 500000 THEN 'High-Performer'
        WHEN TotalRevenue BETWEEN 50000 AND 499999 THEN 'Mid-Performer'
        WHEN TotalRevenue < 50000 THEN 'Low-Performer'
        ELSE 'Uncategorized'
    END AS SalesCategory,
    round(TotalRevenue/TotalSales,2) as AvgRevenue
from sales_data
order by TotalRevenue desc;

-- Analyzing the average price of products based on whether they contain common allergens.
select 
IsAllergic as Allergens,
round(AVG(price),2) AvgPrice from products
group by IsAllergic;



-- Customer Report
-- Highlights:
-- 1) Extract key customer details like full name, city, and country.
-- 2) Analyze customer purchase behavior:
-- 		Last purchase date to track recent activity.
--  	Customer lifespan (time between first and last purchase).
-- 		Recency (days since last purchase).
-- 3)Aggregate customer-level metrics:
-- 		Total number of purchases.
-- 		Total quantity of products bought.
-- 		Total revenue (with discounts applied).
-- 4) Segment customers based on engagement & spending: VIP, Regular and New
-- 5) Calculate key performance indicators (KPIs):
-- 		Average revenue per purchase.
with customer_cte as (
select
        c.CustomerID,
        CONCAT(c.FirstName, ' ', c.LastName) FullName,
        ci.CityName City, 
        co.CountryName Country,
        MAX(s.SalesDate) LastPurchase, 
        datediff(MAX(s.SalesDate), MIN(s.SalesDate)) Lifespan,
        datediff(curdate(),max(s.SalesDate)) Recency,
        count(s.SalesID) TotalPurchase,
        round(sum((p.price*s.quantity) - (p.price * (1-s.discount)) / 100)) TotalRevenue,
        sum(s.Quantity) TotalQuantity
    from sales s
    join customers c on s.CustomerID = c.CustomerID
    join products p on s.ProductID = p.ProductID
    join cities ci on c.CityID = ci.CityID
    join countries co on ci.CountryID = co.CountryID
    where s.SalesDate IS NOT NULL
    group by c.CustomerID, FullName, City, Country
)
select 
    FullName, 
    City, 
    Country,
    LastPurchase,
    Recency,
    CASE 
        WHEN Lifespan > 70 AND TotalRevenue > 10000 THEN 'VIP'
        WHEN Lifespan BETWEEN 20 AND 70 AND TotalRevenue BETWEEN 5000 AND 10000 THEN 'Regular'
        else 'New'
    END AS CustomerSegment,
    TotalPurchase,
    TotalRevenue,
    TotalQuantity,
    Lifespan,
    round(TotalRevenue/TotalPurchase,2) as AverageRevenuePerPurchase
from customer_cte
order by TotalRevenue DESC;



-- Employee Report
-- Highlights:
-- 1) Extract key employee details like full name, age, gender, city, and country, hire date and tenure
-- 2) Analyze employee sales performance:
-- 		Total sales transactions handled.
-- 		Total revenue (with discounts applied).
-- 		Total quantity of products sold.
-- 		Last sale date to track recent activity.
-- 4) Segment employees based on performance: ,Top Performer, Experienced and New
with employee_cte as (
select
        e.EmployeeID,
        e.HireDate,
        CONCAT(e.FirstName, ' ', e.LastName) AS FullName,
        timestampdiff(year,e.BirthDate,curdate())as Age,
        timestampdiff(year,e.HireDate,curdate())as Tenure,
        case when e.Gender='M' then 'Male'
        else 'Female' end as Gender,
        ci.CityName AS City, 
        co.CountryName AS Country,
        MAX(s.SalesDate) AS LastSale, 
        count(s.SalesID) AS TotalSales,
        round(sum((p.price*s.quantity) - (p.price * (1-s.discount)) / 100)) AS TotalRevenue,
        sum(s.Quantity) AS TotalQuantity
    from sales s
    join employees e on s.SalesPersonID = e.EmployeeID
    join products p on s.ProductID = p.ProductID
    join cities ci on e.CityID = ci.CityID
    join countries co on ci.CountryID = co.CountryID
    where s.SalesDate IS NOT NULL
    group by e.EmployeeID, FullName, City, Country
)
select
    FullName, 
    Age,
    HireDate,
    Tenure,
    Gender,
    City, 
    Country,
    TotalSales,
    TotalRevenue,
    TotalQuantity,
    CASE WHEN TotalSales>10000 and TotalRevenue>700000 then 'Top Performer'
		WHEN TotalSales between 5000 and 10000 and TotalRevenue between 200000 and 500000 then 'Experienced'
        ELSE 'New Employee' END AS EmployeeSegment
from employee_cte
order by TotalRevenue DESC;



-- Current Month vs Previous Month Revenue Difference
with cte as (
    select
		Month(s.SalesDate) as MonthNum,
        monthname(s.SalesDate) as Month,
        round(sum((p.price*s.quantity) - (p.price * (1-s.discount)) / 100)) AS TotalRevenue
    from sales s
    join products p on s.ProductID = p.ProductID
    where s.SalesDate is not null
    group by Month(s.SalesDate),monthname(s.SalesDate)
)
select Month, TotalRevenue,
    LAG(TotalRevenue) over (order by MonthNum) as PreviousMonthRevenue,
    round(TotalRevenue - LAG(TotalRevenue) OVER (order by MonthNum), 2) as RevenueDiff
from cte;


-- Cuurent Weekday vs Previous Weekday by Month Revenue Difference
with cte as (
    select
		Month(s.SalesDate) as MonthNum,
        monthname(s.SalesDate) as Month,
        DAYNAME(s.SalesDate) as WeekDay,
        WEEKDAY(s.SalesDate) as WeekDayNum,
        round(sum((p.price*s.quantity) - (p.price * (1-s.discount)) / 100)) AS TotalRevenue
    from sales s
    join products p on s.ProductID = p.ProductID
    where s.SalesDate is not null
    group by DAYNAME(s.SalesDate),WEEKDAY(s.SalesDate),Month(s.SalesDate),
        monthname(s.SalesDate)
)
select Month,WeekDay, TotalRevenue,
    LAG(TotalRevenue) over (PARTITION BY MonthNum order by WeekDayNum) as PreviousDayRevenue,
    round(TotalRevenue - LAG(TotalRevenue) OVER (PARTITION BY MonthNum order by WeekDayNum), 2) as RevenueDiff
from cte;


