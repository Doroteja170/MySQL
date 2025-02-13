select * from sales;
select * from employees;
select * from customers;
select * from products;
select * from categories;
select * from cities;
select * from countries;

-- Data Cleaning and Formating
SELECT STR_TO_DATE(BirthDate, '%m/%d/%Y') AS converted_date
FROM employees;

update employees
set BirthDate=STR_TO_DATE(BirthDate, '%m/%d/%Y');

alter table employees
modify column BirthDate DATE;

update employees
set HireDate=STR_TO_DATE(HireDate, '%m/%d/%Y');

alter table employees
modify column HireDate DATE;

alter table sales drop column TotalPrice;

select * from products;

update products
set ModifyDate=STR_TO_DATE(ModifyDate, '%m/%d/%Y');

alter table products
modify column ModifyDate DATE;

select * from sales;

update sales
set SalesDate=NULL where SalesDate='';

update sales
set SalesDate=STR_TO_DATE(SalesDate, '%m/%d/%Y');

alter table sales
modify column SalesDate DATE;

select * from customers;
select * from employees;

select FirstName, LastName, concat(FirstName,' ',LastName) as Name
from employees;

update customers
set FirstName=concat(FirstName,' ',LastName);
alter table customers drop column LastName;
alter table customers rename column FirstName to FullName;

update employees
set FirstName=concat(FirstName,' ',LastName);
alter table employees drop column LastName;
alter table employees rename column FirstName to FullName;


select * from employees;
select * from sales;

select * from sales s
join employees e on s.SalesPersonID=e.EmployeeID;

select s.SalesPersonID, e.FullName from sales s
left join employees e on s.SalesPersonID=e.EmployeeID;

-- Employees and their Total Sales
select e.FullName, count(s.SalesPersonID) as Total_Sales from sales s
left join employees e on s.SalesPersonID=e.EmployeeID
group by e.FullName
order by count(s.SalesPersonID) DESC;

-- Total Employees Hired per Year
select YEAR(HireDate), count(EmployeeID) as Total_Employees from employees
group by year(HireDate)
order by year(HireDate);

-- Total Sales per Year and Month
select YEAR(SalesDate) as `Year`,MONTH(SalesDate) as `Month`,count(SalesID) as Total_Sales
from sales
where YEAR(SalesDate) is not null and MONTH(SalesDate) is not null
group by YEAR(SalesDate),MONTH(SalesDate)
order by YEAR(SalesDate),MONTH(SalesDate);

select * from categories;
select * from products;
select * from sales;

-- Total Income, Total Sales and Total Quantity by Products
with cte1 as
(select count(s.CustomerID) as Sales, sum(s.Quantity)as Quantity,p.ProductName as ProductName,round(sum(p.Price*s.Quantity),2) as Income
,c.CategoryName as CategoryName
from sales s
join products p on s.ProductID=p.ProductID
join categories c on p.CategoryID=c.CategoryID
where s.Discount=0
group by p.ProductName,c.CategoryName
),
cte2 as
(select count(s.CustomerID) as Sales,sum(s.Quantity)as Quantity,p.ProductName as ProductName,
round(sum(p.Price*s.Quantity*(1-s.Discount)),2) as Income
,c.CategoryName
from sales s
join products p on s.ProductID=p.ProductID
join categories c on p.CategoryID=c.CategoryID
where s.Discount>0
group by p.ProductName,c.CategoryName
)
select cte1.ProductName,cte1.CategoryName,sum(cte1.Sales+cte2.Sales)as Total_Sales,sum(cte1.Quantity+cte2.Quantity) as Total_Quantity,
round(sum(cte1.Income+cte2.Income),2)as Total_Income from cte1
join cte2 on cte1.ProductName=cte2.ProductName
group by cte1.ProductName,cte1.CategoryName
order by cte1.CategoryName,round(sum(cte1.Income+cte2.Income),2) DESC;


-- Total Income, Total Sales and Total Quantity by Product Category
with cte1 as
(select count(s.SalesID) as Sales ,sum(s.Quantity)as Quantity,p.ProductName as ProductName,round(sum(p.Price*s.Quantity),2) as Income
,c.CategoryName as CategoryName
from sales s
join products p on s.ProductID=p.ProductID
join categories c on p.CategoryID=c.CategoryID
where s.Discount=0
group by p.ProductName,c.CategoryName
),
cte2 as
(select count(s.SalesID) as Sales,sum(s.Quantity)as Quantity,p.ProductName as ProductName,
round(sum(p.Price*s.Quantity*(1-s.Discount)),2) as Income
,c.CategoryName
from sales s
join products p on s.ProductID=p.ProductID
join categories c on p.CategoryID=c.CategoryID
where s.Discount>0
group by p.ProductName,c.CategoryName
)
select cte1.CategoryName,sum(cte1.Sales+cte2.Sales)as Total_Sales,sum(cte1.Quantity+cte2.Quantity) as Total_Quantity,
round(sum(cte1.Income+cte2.Income),2)as Total_Income from cte1
join cte2 on cte1.ProductName=cte2.ProductName
group by cte1.CategoryName
order by round(sum(cte1.Income+cte2.Income),2) DESC;


-- Total Income, Total Sales and Total Quantity by Month
with cte1 as
(select count(s.SalesID) as Sales ,sum(s.Quantity)as Quantity,MONTH(s.SalesDate) as `Month`,round(sum(p.Price*s.Quantity)) as Income
from sales s
join products p on s.ProductID=p.ProductID
where s.Discount=0 and MONTH(s.SalesDate) is not null
group by MONTH(s.SalesDate)
),
cte2 as
(select count(s.SalesID) as Sales,sum(s.Quantity)as Quantity,MONTH(s.SalesDate) as `Month`,round(sum(p.Price*s.Quantity*(1-s.Discount))) as Income
from sales s
join products p on s.ProductID=p.ProductID
where s.Discount>0 and MONTH(s.SalesDate) is not null
group by MONTH(s.SalesDate)
)
select cte1.`Month`,sum(cte1.Sales+cte2.Sales)as Total_Sales,sum(cte1.Quantity+cte2.Quantity) as Total_Quantity,
round(sum(cte1.Income+cte2.Income))as Total_Income from cte1
join cte2 on cte1.`Month`=cte2.`Month`
group by cte1.`Month`
order by cte1.`Month`;


-- Total Income, Total Sales and Total Quantity
with cte1 as
(select count(s.SalesID) as Sales ,sum(s.Quantity)as Quantity,round(sum(p.Price*s.Quantity),2) as Income, p.ProductID as ID
from sales s
join products p on s.ProductID=p.ProductID
where s.Discount=0
group by p.productID
),
cte2 as
(select count(s.SalesID) as Sales,sum(s.Quantity)as Quantity,round(sum(p.Price*s.Quantity*(1-s.Discount)),2) as Income, 
p.ProductID as ID
from sales s
join products p on s.ProductID=p.ProductID
where s.Discount>0
group by p.ProductID
)
select sum(cte1.Sales+cte2.Sales)as Total_Sales,sum(cte1.Quantity+cte2.Quantity) as Total_Quantity,
round(sum(cte1.Income+cte2.Income),2)as Total_Income from cte1
join cte2 on cte1.ID=cte2.ID;


-- Products Expiration Dates
select ProductName,ModifyDate,DATE_ADD(ModifyDate, INTERVAL VitalityDays DAY) AS ExpirationDate
from products
where VitalityDays>0
order by DATE_ADD(ModifyDate, INTERVAL VitalityDays DAY);

-- Average Price for Categories by Product Class
select c.CategoryName,p.Class, round(avg(p.Price),2) as Average_Price from products p
join categories c on p.CategoryID=c.CategoryID
group by c.CategoryName,p.Class
order by c.CategoryName,field(p.Class,'Low','Medium','High');

-- Total Sales, Income, Quantity and Average Price by Product Resistant Type
select p.Resistant, round(avg(p.Price),2) as Average_Price,count(s.SalesID) as Total_Sales,
SUM(s.Quantity) AS Total_Quantity, ROUND(SUM(s.Quantity * p.Price), 2) AS Total_Income from sales s
join products p on s.ProductID=p.ProductID
where p.Resistant != 'Unknown'
group by p.Resistant;

select ProductName, IsAllergic from products
where IsAllergic != 'Unknown'
order by IsAllergic;

-- Total Income, Total Sales and Total Quantity based on if Products are Allergy-friendly or not
select p.IsAllergic, round(avg(p.Price),2) as Average_Price,count(s.SalesID) as Total_Sales,SUM(s.Quantity) AS Total_Quantity,
ROUND(SUM(s.Quantity * p.Price)) AS Total_Income from sales s
join products p on s.ProductID=p.ProductID
where p.IsAllergic != 'Unknown'
group by p.IsAllergic;

select * from products;

-- Customers Demographics
select ct.CityName, co.CountryName ,count(c.CustomerID) as Total_Customers from customers c
join cities ct on c.CityID=ct.CityID
join countries co on ct.CountryID=co.CountryID
group by ct.CityName,co.CountryName
order by count(c.CustomerID) DESC;

-- Employee Demographics
select Gender, count(EmployeeID) as Total_Employees from employees
group by Gender;

select FullName, TIMESTAMPDIFF(YEAR, BirthDate, CURDATE()) AS age
from employees
order by TIMESTAMPDIFF(YEAR, BirthDate, CURDATE());

select e.FullName,c.CityName,cu.CountryName from employees e
join cities c on e.CityID=c.CityID
join countries cu on c.CountryID=cu.CountryID;
