#Question 1--
	#Write a query to identify the number of duplicates in "sales_transaction" table. 
	#Also, create a separate table containing the unique values and remove the the original table from the databases 
	#Replace the name of the new table with the original name.

SELECT TransactionID, count(*)
FROM sales_transaction
GROUP BY TransactionID
HAVING count(*) > 1;

CREATE TABLE sales_transaction_nodupe AS
SELECT DISTINCT * FROM sales_transaction;

DROP TABLE sales_transaction;

ALTER TABLE sales_transaction_nodupe RENAME TO sales_transaction;

SELECT * FROM sales_transaction;


#Question 2--
	#Write a query to identify the discrepancies in the price of the same product in "sales_transaction" and "product_inventory" tables. 
    #Also, update those discrepancies to match the price in both the tables.

select s.TransactionID,
s.price as TransactionPrice,
p.price as InventoryPrice
from product_inventory as p
join sales_transaction as s
on p.productid = s.ProductID
where s.price<>p.price;

UPDATE `sales_transaction` AS s
JOIN `product_inventory` AS p
    ON s.ProductID = p.ProductID
SET s.Price = p.Price   
WHERE s.Price <> p.Price;

select * from sales_transaction;


#Question 3--
	#Write a SQL query to identify the null values in the dataset and replace those by “Unknown”.

SELECT COUNT(*) 
FROM customer_profiles
WHERE location is NULL;
set sql_safe_updates = 0;

UPDATE customer_profiles
SET Location = 'Unknown'
WHERE Location IS NULL;

select * from customer_profiles;


#Question 4--
	#Write a SQL query to clean the DATE column in the dataset.

create table sales_transaction_new as
select TransactionID,
		CustomerID,
        ProductID,
        QuantityPurchased,
        TransactionDate,
        Price,
        cast(TransactionDate as date) as TransactionDate_updated
from sales_transaction;

drop table sales_transaction;

rename table sales_transaction_new to sales_transaction;

select * from sales_transaction;


#Question 5--
	#Write a SQL query to summarize the total sales and quantities sold per product by the company.

select productid, 
	   sum(quantitypurchased) as TotalUnitsSold,
       sum(QuantityPurchased*Price) as TotalSales
from sales_transaction
group by ProductID
order by totalsales desc;


#Question 6--
	#Write a SQL query to count the number of transactions per customer to understand purchase frequency.

select customerid,
count(TransactionID) as NumberOfTransactions
from sales_transaction
group by customerid
order by NumberOfTransactions desc;

#Question 7--
	#Write a SQL query to evaluate the performance of the product categories based on the total sales which help us understand the product categories which needs to be promoted in the marketing campaigns.

    select p.category, 
	   sum(s.quantitypurchased) as TotalUnitsSold,
       sum(s.quantitypurchased*s.price) as TotalSales
from product_inventory as p
join sales_transaction as s
on s.ProductID = p.ProductID
group by p.category
order by totalsales desc;

#Question 8--
	#Write a SQL query to find the top 10 products with the highest total sales revenue from the sales transactions. This will help the company to identify the High sales products which needs to be focused to increase the revenue of the company.

select productid,
	   sum(quantitypurchased*price) as TotalRevenue
from sales_transaction
group by productid
order by totalrevenue desc
limit 10;

#Question 9--
	#Write a SQL query to find the ten products with the least amount of units sold from the sales transactions, provided that at least one unit was sold for those products.

select productid,
	   sum(quantitypurchased) as TotalUnitsSold
from sales_transaction
group by productid
HAVING SUM(QuantityPurchased) > 0
order by totalunitssold asc
limit 10;

#Question 10--
	#Write a SQL query to identify the sales trend to understand the revenue pattern of the company.

select transactiondate as DATETRANS,
	   count(transactionid) as Transaction_count,
       sum(quantitypurchased) as TotalUnitsSold,
       round(sum(quantitypurchased*price),2) as TotalSales
from sales_transaction
group by TransactionDate
order by datetrans desc;


#Question 11--
	#Write a SQL query to understand the month on month growth rate of sales of the company which will help understand the growth trend of the company.

SELECT
    month,
    total_sales,
    previous_month_sales,
    round(((total_sales - previous_month_sales) / previous_month_sales) * 100,2)
        AS mom_growth_percentage
from
	(select
        month(transactiondate) as "month",
	   round(sum(quantitypurchased*price),2) as total_sales,
       round(lag(sum(quantitypurchased*price)) over (order by month(transactiondate)),2) as previous_month_sales
from sales_transaction
group by month(transactiondate)) as Sales_data
order by month;


#Question 12--
	#Write a SQL query that describes the number of transaction along with the total amount spent by each customer which are on the higher side and will help us understand the customers who are the high frequency purchase customers in the company.

select customerid, count(transactionid) as NumberOfTransactions,
		sum(quantitypurchased*price) as TotalSpent
from sales_transaction
group by customerid
having NumberOfTransactions >10 and TotalSpent>1000
order by totalspent desc;


#Question 13--
	#Write a SQL query that describes the number of transaction along with the total amount spent by each customer, which will help us understand the customers who are occasional customers or have low purchase frequency in the company.

select customerid, count(transactionid) as NumberOfTransactions,
		sum(quantitypurchased*price) as TotalSpent
from sales_transaction
group by customerid
having NumberOfTransactions <=2
ORDER BY NumberOfTransactions ASC,
         TotalSpent DESC;
         

#Question 14--
	#Write a SQL query that describes the total number of purchases made by each customer against each productID to understand the repeat customers in the company.

select customerid, productid, count(transactionid) as TimesPurchased
from sales_transaction
group by customerid, productid
having TimesPurchased>1
order by TimesPurchased desc;

#Question 15--
	#Write a SQL query that describes the duration between the first and the last purchase of the customer in that particular company to understand the loyalty of the customer.

select Customerid, min(TransactionDate) as FirstPurchase, max(TransactionDate) as LastPurchase,
datediff(max(TransactionDate),min(TransactionDate)) as DaysBetweenPurchases
from sales_transaction
group by customerid
having DaysBetweenPurchases>0
order by DaysBetweenPurchases desc;	


#Question 16--
	#Write an SQL query that segments customers based on the total quantity of products they have purchased. Also, count the number of customers in each segment which will help us target a particular segment for marketing.

WITH customer_quantity AS (
    SELECT
        CustomerID,
        SUM(QuantityPurchased) AS total_quantity
    FROM sales_transaction
    GROUP BY CustomerID
)

SELECT
    CASE
        WHEN total_quantity BETWEEN 1 AND 10 THEN 'Low'
        WHEN total_quantity BETWEEN 11 AND 30 THEN 'Med'
        WHEN total_quantity > 30 THEN 'High'
    END AS CustomerSegment,
    COUNT(*) 
FROM customer_quantity
GROUP BY
    CASE
        WHEN total_quantity BETWEEN 1 AND 10 THEN 'Low'
        WHEN total_quantity BETWEEN 11 AND 30 THEN 'Med'
        WHEN total_quantity > 30 THEN 'High'
    END;


