create database e_commerce;

use e_commerce;

-- You can analyze all the tables by describing their contents.

desc Customers;
desc Products;
desc Orders;
desc OrderDetails;

-- Identify the top 3 cities with the highest number of customers to determine key markets for
--  targeted marketing and logistic optimization.

select location, count(*) as number_of_customers
from Customers
group by location
order by number_of_customers desc
limit 3;

-- Determine the distribution of customers by the number of orders placed. This insight will help in segmenting customers 
-- into one-time buyers, occasional shoppers, and regular customers for tailored marketing strategies.

with order_per_customer as (
    select customer_id,
    count(*) as NumberOfOrders
    from Orders 
    group by customer_id
)
select NumberOfOrders,
  count(*) as CustomerCount
from order_per_customer
group by NumberOfOrders
order by NumberOfOrders ;

-- Identify products where the average purchase quantity per order is 2 but with a high total revenue, 
-- suggesting premium product trends.

select Product_id,
          avg(quantity) as AvgQuantity,
          sum(quantity * price_per_unit) as TotalRevenue
 from orderDetails
 group by Product_id
 having AvgQuantity = 2
 order by TotalRevenue desc;
 
--  For each product category, calculate the unique number of customers purchasing from it. This will help 
--  understand which categories have wider appeal across the customer base.

select p.category, count(distinct o.customer_id) as unique_customers
from Products p 
join OrderDetails od on p.product_id = od.product_id
join Orders o on o.order_id = od.order_id
group by p.category
order by unique_customers desc;

-- Analyze the month-on-month percentage change in total sales to identify growth trends.

with sales_cte as (
    select date_format(order_date, '%Y-%m') as Month,
    round(sum(total_amount),2) as TotalSales
    from orders
    group by Month
)
select Month, TotalSales,
                   round(
                        ((TotalSales - lag(TotalSales) over (order by Month)) /
                         lag(TotalSales) over (order by Month)) * 100
                       ,2) as PercentChange
from sales_cte;

-- Examine how the average order value changes month-on-month. Insights can guide pricing and promotional strategies
--  to enhance order value

with sales_cte as (
    select date_format(order_date, '%Y-%m') as Month,
    round(avg(total_amount),2) as AvgOrderValue
    from orders
    group by Month
)
select Month, AvgOrderValue,
                    round(
                        (AvgOrderValue - lag(AvgOrderValue) over (order by Month))                       
                       ,2) as ChangeInValue
from sales_cte
order by ChangeInValue desc;


-- Based on sales data, identify products with the fastest turnover rates, suggesting high demand and the need
--  for frequent restocking.

select product_id,
          count(*) as SalesFrequency
 from OrderDetails
 group by product_id
 order by SalesFrequency desc
 limit 5;
 
 
--  List products purchased by less than 40% of the customer base, indicating potential mismatches 
--  between inventory and customer interest.

select 
   p.Product_id, p.Name, count(distinct o.customer_id) as UniqueCustomerCount
from products p 
join orderDetails od on od.Product_id = p.Product_id
join orders o on o.order_id = od.order_id
group by p.Product_id , p.Name
having UniqueCustomerCount < 0.4 * (select count(distinct customer_id) from customers);

-- Evaluate the month-on-month growth rate in the customer base to understand the effectiveness of marketing campaigns and 
-- market expansion efforts.

WITH FirstPurchase AS (
    SELECT 
        Customer_ID,
        MIN(Order_Date) AS Month
    FROM 
        Orders
    GROUP BY 
        Customer_ID
)
SELECT 
    DATE_FORMAT(Month, '%Y-%m') AS FirstPurchaseMonth,
    COUNT(Customer_ID) AS TotalNewCustomers
FROM 
    FirstPurchase
GROUP BY 
    FirstPurchaseMonth
ORDER BY 
    FirstPurchaseMonth ASC;
    
-- Identify the months with the highest sales volume, aiding in planning for stock levels, 
-- marketing efforts, and staffing in anticipation of peak demand periods.

select date_format(order_date,'%Y-%m') as Month,
          sum(total_amount) as TotalSales
from orders 
group by Month
order by TotalSales desc
limit 3;



