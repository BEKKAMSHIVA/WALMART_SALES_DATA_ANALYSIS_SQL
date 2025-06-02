CREATE DATABASE IF NOT EXISTS walmart;
---creating the data base.

USE walmart;


CREATE TABLE dbo.Walmart(
invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
branch VARCHAR(5) NOT NULL,
city VARCHAR(30) NOT NULL,
customer_type VARCHAR(30) NOT NULL,
gender VARCHAR(10) NOT NULL,
product_line VARCHAR(100) NOT NULL,
unit_price DECIMAL(10,2) NOT NULL,
quantity INT(20) NOT NULL,
vat FLOAT(6,4) NOT NULL,
total DECIMAL(12, 4) NOT NULL,
date DATETIME NOT NULL,
time TIME NOT NULL,
payment VARCHAR(15) NOT NULL,
cogs DECIMAL(10,2) NOT NULL,
gross_margin_pct FLOAT(11,9),
gross_income DECIMAL(12, 4),
rating FLOAT(2, 1)
);
---creating the table

select * from Walmart;


select top(10) * from Walmart;
---checking the top 10 rows of the dataset..

-----FEATURE ENGINEERING TECHNICES------


---finding the starting and ending time of the sales .
SELECT 
    CONVERT(TIME, MIN(time)) AS earliest_time_only,
    CONVERT(TIME, MAX(time)) AS latest_time_only
FROM dbo.Walmart;

-- 1.create a new coloumn for the time of the day.

ALTER TABLE dbo.Walmart
ADD time_of_day VARCHAR(20);


UPDATE dbo.Walmart
SET time_of_day = (
    CASE 
        WHEN CAST(time AS TIME) BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN CAST(time AS TIME) BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening' 
    END
);
----2. create a new column on the day of the salesa
SELECT DISTINCT 
  FORMAT(date, 'yyyy-MM') AS year_month
FROM Walmart;

ALTER TABLE Walmart
ADD day_of_week VARCHAR(10);

UPDATE Walmart
SET day_of_week = DATENAME(WEEKDAY, date);

---3.Adding the month of the sales.
ALTER TABLE Walmart
ADD month_name varchar(10);


UPDATE Walmart
SET month_name = DATENAME(MONTH, date);


---- **** GENERAL_QUESTION ***** -------
--1. How many distinct cities are present in the dataset?
select count(distinct city)as unique_citys from Walmart;
----Total Three unique citys are their.

--2.In which city is each branch situated?
select distinct Branch, City from Walmart;
-----In Yangon,Mandalay, Naypyitaw citys A,B,C branches are their.



--- ***** Product Analysis **** -----

---1. How many distinct product lines are there in the dataset?
select count(distinct Product_line) as countofproductline from Walmart;
----Total 6 product lines are present.

---2.What is the most common payment method?
SELECT TOP 1 payment, COUNT(payment) AS common_payment_method 
FROM Walmart 
GROUP BY payment 
ORDER BY common_payment_method DESC;
---- MOST COMMON PAYMENT IS EWALLET WITH 345 TIMES.


--3.What is the most selling product line?
Select Top 1 product_line, count(product_line) as common_product_line
from Walmart
group by product_line
order by common_product_line DESC ;
-- The most selling product line is 'Fashion accessories with 178.

-- 4.What is the total revenue by month?
SELECT 
    FORMAT(date, 'yyyy-MM') AS revenue_month,
    SUM(gross_income) AS total_revenue
FROM Walmart
GROUP BY FORMAT(date, 'yyyy-MM')
ORDER BY revenue_month;
----[JAN, 5537.708],[FEB,4629.494],[MARCH,5212.167]------


----5.Which month recorded the highest Cost of Goods Sold (COGS)?

SELECT  top 1 month_name, SUM(cogs) AS total_revenue
FROM Walmart GROUP BY month_name ORDER BY total_revenue DESC;
----[JAN, 110754.16]-----

-- 6.Which product line generated the highest revenue?
select top 1 product_line, sum(total) as highest_revenue_product_line from Walmart
group by product_line order by highest_revenue_product_line DESC;
---[Food and beverages produce the highest revenue with '56144.844']

--7.Which city has the highest revenue?
select top 1 city, sum(total) as highest_revenue_city from Walmart
group by city 
order by highest_revenue_city DESC;
---[Naypyitaw has the highest revenue with 110568.7065].

-- 8.Which product line incurred the highest VAT?
EXEC sp_rename 'dbo.Walmart.tax_5', 'vat', 'COLUMN';

select top 1  product_line ,sum(vat) as highest_vat from Walmart
group by product_line 
order by highest_vat DESC;
---[Food and beverages has the highest vat with 2673.564].

-- 9.Retrieve each product line and add a column product_category, indicating 'Good' or 'Bad,'based on whether its sales are above the average.
Alter table Walmart
ADD product_category varchar(10);

UPDATE Walmart
SET product_category= 
(CASE 
	WHEN total >= (SELECT AVG(total) FROM dbo.Walmart) THEN 'Good'
    ELSE 'Bad'
END)FROM Walmart;

---[Added the column product_category with 'good' and 'bad' ]

-- 10.What is the most common product line by gender?
WITH RankedProducts AS (
    SELECT 
        gender,
        product_line,
        COUNT(*) AS total_count,
        ROW_NUMBER() OVER (PARTITION BY gender ORDER BY COUNT(*) DESC) AS rn
    FROM dbo.Walmart
    GROUP BY gender, product_line
)
SELECT gender, product_line, total_count
FROM RankedProducts
WHERE rn = 1;
----[Male is 'Health and beauty' and Female is 'Fashion accessories']---


-- 11.What is the average rating of each product line?

select product_line , avg(Rating) as Average_rating from Walmart
group by product_line;
----[Fashion accessories : 7.02921348314607][Health and beauty : 7.00328947368421][Electronic accessories : 6.92470588235294]
----[Food and beverages : 7.1132183908046] [sports and travel : 6.91626506024096]

---- @@@@@ Sales Analysis @@@@@ -----

-- 1.Number of sales made in each time of the day per weekday?

SELECT day_of_week, time_of_day, COUNT(*) AS total_sales FROM Walmart
WHERE day_of_week NOT IN ('Saturday','Sunday') 
GROUP BY day_of_week, time_of_day;

-- 2.Identify the customer type that generates the highest revenue.
SELECT TOP 1 customer_type, SUM(total) AS highest_revenue
FROM Walmart
GROUP BY customer_type
ORDER BY highest_revenue ;
---Normal---

-- 3.Which city has the largest tax percent/ VAT (Value Added Tax)?

select   top 1 city ,sum(vat) as largest_tax from Walmart
group by city
order by largest_tax desc;
---Naypyitwa---

-- 4.Which customer type pays the most in VAT?
select top 1 customer_type , sum(vat) as most_vat from Walmart
group by customer_type
order by most_vat desc;
---Member---

----  ##### Customer Analysis  ###### -------

-- 1.How many unique customer types does the data have?
select distinct(customer_type) from Walmart;
---Normal,Member


---2.How many unique payment methods does the data have?
select distinct(payment) from Walmart;
---EWallet,Cash,Credit card---


-- 3.Which is the most common customer type?
SELECT top 1 customer_type, COUNT(customer_type) AS common_customer FROM Walmart
GROUP BY customer_type 
ORDER BY common_customer DESC ;
---Member---

-- 4.Which customer type buys the most?
SELECT top 1  customer_type, SUM(total) as total_sales from Walmart
GROUP BY customer_type ORDER BY total_sales;
--Normal---

--5 What is the gender of most of the customers?
SELECT top 1 gender, COUNT(*) AS all_genders
FROM Walmart
GROUP BY gender
ORDER BY all_genders DESC;
---Female---


-- 6.What is the gender distribution per branch?
SELECT branch, gender, COUNT(gender) AS gender_distribution FROM Walmart
GROUP BY branch, gender ORDER BY branch;


--7. Which time of the day do customers give most ratings?

SELECT  top 1 time_of_day, SUM(rating) AS most_rating from Walmart
GROUP BY time_of_day
ORDER BY most_rating DESC;
---Evening---

---8.Which time of the day do customers give most ratings per branch?
select  time_of_day,branch, sum(rating) as most_rating_per_branch from Walmart
group by time_of_day,branch
order by most_rating_per_branch DESC;

-- 9.Which day of the week has the best avg ratings?
select top 1 day_of_week,avg(rating) as best_avg_rating from Walmart
group by day_of_week
order by best_avg_rating desc;
---Monday----

--10.Which day of the week has the best average ratings per branch?
select top 1 day_of_week,branch,avg(rating) as best_avg_rating from Walmart
group by day_of_week,branch
order by best_avg_rating desc;
---Monday B branch