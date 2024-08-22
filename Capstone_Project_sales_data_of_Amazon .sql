-- Database Created With the Name of amazon --

Use amazon;

-- 1. Data Wrangling: checking the presence of NULL values data replacement methods are used --

create table if not exists sales( 
   invoice_id varchar(30) not null primary key,
   branch varchar(5) not null, 
   city varchar(30) not null,
   customer_type varchar(30) not null,
   gender varchar(10) not null,
   product_line varchar(100) not null,
   unit_price decimal(10,2) not null,
   quantity int not null,
   vat float not null,
   total decimal(12,4) not null,
   date_ datetime not null,
   time_ time not null, 
   payment_method varchar(15) not null,
   cogs decimal(10,2) not null,
   gross_margin_pct float not null,
   gross_income decimal(12,4) not null,
   rating float
   ); 
   
select * from sales;   
SELECT * FROM sales
WHERE branch IS NULL; 

select isnull(total) from sales; 

select count(*) from sales; -- total 1000 rows are present in sales table --

SELECT count(*) as No_of_Column FROM information_schema.columns 
WHERE table_schema = 'amazon'and  table_name ='sales';  -- Total count of columns are present --

SELECT COUNT(*) AS Total_null FROM sales WHERE rating IS NULL; -- Checked if particular column contains null or not --

-- 2. Feature Engineering: This will help us generate some new columns from existing ones.--

-- time_of_day column created and added in the table.-- 

Select time_,
(case
   when time_ between '00:00:00' and '12:00:00' then 'Morning'
   when time_ between '12:01:00' and '16:00:00' then 'Afternoon'
  else 'Evening'
end) as time_of_day
from sales;  

Alter table sales add column time_of_day varchar(20);
SET SQL_SAFE_UPDATES = 0;
update sales 
set time_of_day = (case 
   when time_ between '00:00:00' and '12:00:00' then 'Morning'
   when time_ between '12:01:00' and '16:00:00' then 'Afternoon'
   else 'Evening'
 end);
 
SET SQL_SAFE_UPDATES = 1;
select * from sales; 

-- day_name column created from date column --

SET SQL_SAFE_UPDATES = 0;
UPDATE sales 
SET day_name = DAYNAME(date_);
SET SQL_SAFE_UPDATES = 1;

select date_, dayname(date_) 
from sales;

alter table sales add column day_name varchar(10);
select * from sales;
update sales 
set day_name = dayname(date_);

select * from sales; 

-- month_name column from date_ column

SET SQL_SAFE_UPDATES = 0;
UPDATE sales 
SET month_name = MONTHNAME(date_);
SET SQL_SAFE_UPDATES = 1;

select date_, monthname(date_) 
from sales;

alter table sales add column month_name varchar(10);
select * from sales;
update sales 
set month_name = monthname(date_); 
select * from sales;

-- ************************************************************************************************************************************* --

-- Business Questions To Answer:

-- 1. What is the count of distinct cities in the dataset?
select count(distinct city) as number_of_city from sales;
select distinct city from sales; -- Name of the distinct City 

-- 2. For each branch, what is the corresponding city?
select distinct branch,city from sales; 

-- 3. What is the count of distinct product lines in the dataset?
select count(distinct product_line) as count_of_product_line from sales;

-- 4. Which payment method occurs most frequently?
select payment_method, count(payment_method) as count_of_payment_method
from sales
group by payment_method
order by count_of_payment_method desc
limit 1;

-- 5. Which product line has the highest sales?
select product_line, count(product_line) as count_of_product_line
from sales
group by product_line
order by count_of_product_line DESC
limit 1;

-- 6. How much revenue is generated each month?
select month_name as month, 
sum(total) as revenue 
from sales 
group by month
order by revenue DESC;

-- 7. In which month did the cost of goods sold reach its peak?
select month_name as month, 	
sum(cogs) as total_cogs
from sales
group by month
order by total_cogs DESC
Limit 1;

-- 8. Which product line generated the highest revenue?
select product_line, sum(total) as revenue
from sales
group by product_line
order by revenue DESC
Limit 1;

-- 9. In which city was the highest revenue recorded?
select city, sum(total) as revenue
from sales
group by city
order by revenue DESC
LIMIT 1;

-- 10. Which product line incurred the highest Value Added Tax?
select product_line, sum(vat) as total_vat
from sales
group by product_line
order by total_vat DESC
LIMIT 1;

-- 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
select product_line,
(case
 when sum(total) > (select avg(total) from sales) then 'Good'
 else 'Bad'
 end) as sales_status
 from sales
 group by product_line;
 
 -- 12. Identify the branch that exceeded the average number of products sold.
select branch,
sum(quantity) as qty
from sales
group by branch
having sum(quantity) > (select avg(quantity) from sales)
order by qty DESC
LIMIT 1;

-- 13. Which product line is most frequently associated with each gender?
Select product_line, gender, cnt_product_line
from
(select product_line, gender, cnt_product_line,
dense_rank() over (partition by gender order by cnt_product_line DESC) as dr_rank
from
(select gender,product_line, count(product_line) as cnt_product_line 
from sales 
group by gender, product_line
order by cnt_product_line DESC) as t1) as t2 where dr_rank = 1;

-- 14. Calculate the average rating for each product line.
Select * from sales;
Select product_line,
round(Avg(rating),2) as avrage_rating
from sales
group by product_line
order by avrage_rating DESC;

-- 15. Count the sales occurrences for each time of day on every weekday.
select time_of_day,
count(total) as total_sales
from sales
where day_name NOT IN ('saturday','Sunday')
group by time_of_day; 

-- 16. Identify the customer type contributing the highest revenue.
select customer_type,
sum(total) as revenue
from sales
group by customer_type
order by revenue DESC
LIMIT 1;

-- 17. Determine the city with the highest VAT percentage.
Select city,round(((sum(vat)/sum(total))*100),2) as vat_percentage
from sales
group by city
order by vat_percentage DESC
LIMIT 1;

-- 18. Identify the customer type with the highest VAT payments.
Select customer_type,sum(vat) as total_vat_pay
from sales
group by customer_type
order by total_vat_pay DESC 
LIMIT 1;

-- 19. What is the count of distinct customer types in the dataset?
Select count(distinct_customer_type) as Cnt_customer_type
from sales;
Select distinct customer_type from sales;

-- 20. What is the count of distinct payment methods in the dataset?
Select count(distinct_payment_method) as Cnt_payement_method
from sales;
select distinct payment_method from sales;

-- 21. Which customer type occurs most frequently?
Select customer_type, Count(customer_type) as Cnt_customer_type
from sales
group by customer_type
order by Cnt_customer_type DESC
Limit 1; 

-- 22. Identify the customer type with the highest purchase frequency.
Select * from sales;
Select customer_type, count(*) as Cnt_of_purchase
from sales
group by customer_type
order by Cnt_of_purchase DESC
Limit 1;

-- 23. Determine the predominant gender among customers.
Select gender, count(*) as Cnt_of_gender
from sales
group by gender
order by Cnt_of_gender DESC
LIMIT 1;

-- 24. Examine the distribution of genders within each branch.
select branch, gender, count(gender) as cnt_of_gen 
from sales 
group by branch, gender
order by branch;

-- 25. Identify the time of day when customers provide the most ratings.
Select time_of_day, cnt_of_rating from 
(select time_of_day, cnt_of_rating, dense_rank() over(order by cnt_of_rating desc) as dr_rank 
from (select time_of_day, count(rating) as cnt_of_rating  
from sales 
group by time_of_day) as t1) as t2 where dr_rank= 1;

-- 26. Determine the time of day with the highest customer ratings for each branch.
Select time_of_day, branch, high_rating from 
(Select time_of_day, branch, high_rating, dense_rank()
over (partition by branch order by high_rating DESC) as dr_rank
from(select branch, time_of_day, max(rating) as high_rating
from sales
Group by time_of_day, branch
Order by high_rating DESC) as new_table) as new2 where dr_rank=1;

-- 27. Identify the day of the week with the highest average ratings.
Select day_name, avg_rating from
(select day_name, avg_rating, dense_rank() over(order by avg_rating desc) as dr_rank
from (select day_name, round(avg(rating),2) as avg_rating
from sales
group by day_name
order by avg_rating desc) as t1)as t2  where dr_rank= 1;

-- 28. Determine the day of the week with the highest average ratings for each branch.
Select day_name, branch, avg_rating from 
(select branch, day_name, avg_rating, dense_rank() 
over(partition by branch order by avg_rating desc) as dr_rank 
from (select  branch,day_name, round(avg(rating),2)as avg_rating
from sales 
group by branch, day_name 
order by avg_rating desc) as new_table) as new2 where dr_rank = 1;

SELECT * FROM SALES;



 



