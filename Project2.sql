---II - Ad-hoc tasks 
--- Bài 1 
WITH cte AS(
SELECT FORMAT_DATE('%Y-%m',created_at) as year_month,
user_id,order_id, status 
from bigquery-public-data.thelook_ecommerce.orders
order by year_month
)
SELECT year_month, count(user_id) as total_user, 
SUM(CASE WHEN status='Complete' THEN 1 else 0 END) as total_order
FROM cte 
GROUP BY year_month
ORDER BY year_month
-- => lượng người mua và lượng đơn hàng nhìn chung tăng dần theo thời gian

--- Bài 2
WITH cte AS (
SELECT FORMAT_DATE('%Y-%m',created_at) as year_month,
user_id,order_id, sale_price
FROM bigquery-public-data.thelook_ecommerce.order_items
WHERE created_at between '2019-01-01' and '2022-04-30' 
)
SELECT year_month, count(DISTINCT user_id) as distinct_users,
round (sum(sale_price)/count(order_id),2) AS average_order_value
FROM cte
GROUP BY year_month
ORDER BY year_month
--=> Tổng số người dùng khác nhau mỗi tháng nhìn chung tăng, giá trị 1 đơn hàng trung bình không cố đinh, có xu hướng giảm

--- Bài 3
WITH cte1 AS(select distinct first_name, last_name, gender, age,
RANK() OVER(PARTITION BY gender ORDER BY age) AS rank,
FROM bigquery-public-data.thelook_ecommerce.order_items as a
JOIN bigquery-public-data.thelook_ecommerce.users as b
ON a.user_id = b.id
WHERE a.created_at between '2019-01-01' and '2022-04-30'),

cte2 AS(select distinct first_name, last_name, gender, age,
RANK() OVER(PARTITION BY gender ORDER BY age DESC) AS rank,
FROM bigquery-public-data.thelook_ecommerce.order_items as a
JOIN bigquery-public-data.thelook_ecommerce.users as b
ON a.user_id = b.id
WHERE a.created_at between '2019-01-01' and '2022-04-30'),
youngest AS(
SELECT distinct first_name, last_name, gender, age,
CASE WHEN rank = 1 Then 'youngest' END tag
FROM cte1),
oldest AS(
SELECT distinct first_name, last_name, gender, age,
CASE WHEN rank = 1 Then 'oldest' END tag
FROM cte2),
t_table as (
SELECT first_name, last_name, gender, age,tag FROM youngest WHERE tag ='youngest'
UNION ALL 
SELECT first_name, last_name, gender, age,tag FROM oldest WHERE tag ='oldest'
ORDER BY tag)

SELECT age, 
COUNT (tag) as amount 
FROM t_table 
GROUP BY age 
--=> lớn tuổi nhất: 70, số lượng 426
--=> nhỏ tuổi nhất: 12, số lượng 415 

---Bài 4
with cte1 as (
SELECT FORMAT_DATE('%Y-%m',created_at) as month_year,
product_id, a.name as product_name, round (sale_price, 2) as sales, round (cost,2) as cost, round (sale_price - cost, 2) as profit 
from bigquery-public-data.thelook_ecommerce.products a
join bigquery-public-data.thelook_ecommerce.order_items b
on a.id = b.product_id
order by month_year),
cte2 as (
select month_year, product_id,
sum (profit) as total_profit 
from cte1 
group by 1, 2),
cte3 as (
SELECT cte1.month_year, cte1.product_id, product_name, sales, total_profit,
DENSE_RANK() OVER(PARTITION BY cte1.month_year ORDER BY total_profit DESC) as rank_per_month 
FROM cte1 
JOIN cte2
ON cte1.month_year = cte2.month_year and cte1.product_id = cte2.product_id)
SELECT * FROM cte3
WHERE rank_per_month <=5
order by month_year

---Bài 5
WITH cte1 AS(SELECT FORMAT_DATE('%Y-%m-%d',created_at) as  dates,
a.category as product_categories, ROUND(b.sale_price,2) as sale
FROM bigquery-public-data.thelook_ecommerce.products a
JOIN bigquery-public-data.thelook_ecommerce.order_items b
ON a.id = b.product_id
WHERE b.status = 'Complete'
AND b.created_at between '2022-01-15' and '2022-04-15'),
cte2 AS(
SELECT dates, product_categories, ROUND(sum(sale),2) as revenue
FROM cte1 
GROUP BY dates, product_categories)
SELECT * FROM cte2 
ORDER BY dates 

---III
---Bài 1
create view bigquery-public-data.thelook_ecommerce.vw_ecommerce_analyst as (
with cte1 as 
(SELECT FORMAT_DATE('%Y-%m',a.created_at) as Month,
FORMAT_DATE('%Y',a.created_at) as Year,
category as Product_category,
round(sum(sale_price),2) as TPV,
count(c.order_id) as TPO,
round(sum(b.cost),2) as Total_cost
from bigquery-public-data.thelook_ecommerce.orders as a 
Join bigquery-public-data.thelook_ecommerce.products as b on a.order_id=b.id 
Join bigquery-public-data.thelook_ecommerce.order_items as c on b.id=c.id
Group by Month, Year, Product_category
)
Select Month, Year, Product_category, TPV, TPO,
round(cast((TPV - lag(TPV) OVER(PARTITION BY Product_category ORDER BY Year, Month))
/lag(TPV) OVER(PARTITION BY Product_category ORDER BY Year, Month) as Decimal)*100.00,2) || '%'
as Revenue_growth,
round(cast((TPO - lag(TPO) OVER(PARTITION BY Product_category ORDER BY Year, Month))
/lag(TPO) OVER(PARTITION BY Product_category ORDER BY Year, Month) as Decimal)*100.00,2) || '%'
as Order_growth,
Total_cost,
round(TPV - Total_cost,2) as Total_profit,
round((TPV - Total_cost)/Total_cost,2) as Profit_to_cost_ratio
from cte1 
Order by Product_category, Year, Month)

---Bài 2
With cte1 as
(Select user_id, 
Min(created_at) OVER (PARTITION BY user_id) as first_purchase_date,
created_at
from bigquery-public-data.thelook_ecommerce.order_items),
cte2 as
(Select user_id, FORMAT_DATE('%Y-%m', first_purchase_date) as cohort_month,
created_at,
(Extract(year from created_at) - extract(year from first_purchase_date))*12 + Extract(MONTH from created_at) - extract(MONTH from first_purchase_date) +1
as index
from cte1), 
xxx as (
Select cohort_month, 
index,
COUNT(DISTINCT cte1.user_id) as cnt
from cte1 
join cte2 on cte1.created_at=cte2.created_at
Group by cohort_month, index
ORDER BY INDEX)
,customer_cohort as (
select cohort_month, 
sum (case when index=1 then cnt else 0 end) as m1,
sum(case when index=2 then cnt else 0 end ) as m2,
sum(case when index=3 then cnt else 0 end ) as m3,
sum(case when index=4 then cnt else 0 end ) as m4
from xxx
group by cohort_month
order by cohort_month)

select
cohort_month,
round(100.00* m1/m1,2)||'%' as m1,
round(100.00* m2/m1,2)|| '%' as m2,
round(100.00* m3/m1,2) || '%' as m3,
round(100.00* m4/m1,2) || '%' as m4
from customer_cohort

