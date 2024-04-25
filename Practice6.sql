---ex1
with cte as (
select 
company_id, 
title, 
description, 
count (job_id) as job_count
from job_listings
group by company_id, title, description
)
select count(cte.company_id) as duplicate_companies
from cte
where job_count = 2 
---ex2
with cte as
(SELECT category,product,sum(spend) as total_spend,
rank() over(partition by category order by sum(spend) desc) as no 
---RANK() OVER (PARTITION BY _______ ORDER BY _____ DESC) PARTITION BY chia các hàng của các phân vùng tập kết quả mà hàm được áp dụng. ORDER BY chỉ định thứ tự sắp xếp logic của các hàng
FROM product_spend
where EXTRACT(year from transaction_date)=2022
group by category,product
order by category,total_spend desc
)
select category,product,total_spend
from cte
where no < 3
--- ex3
with cte as (
select count(case_id) as policy_holder from callers
group by policy_holder_id	
having count(case_id) >=3
)
select count (policy_holder) as policy_holder_count from cte 
---ex4
select 
page_id from pages
where page_id not in (
select page_id from page_likes
)
order by page_id
---ex5
select extract (month from event_date),
count(distinct user_id) as monthly_active_users
FROM  user_actions
where user_id in (
select user_id from user_actions
where extract (month from event_date) = 6)
and 
extract (month from event_date) = 7
group by extract (month from event_date)
---ex6
select
left (cast (trans_date as  varchar), 7) as month,
country,
count(*) AS trans_count,
sum(case when state = 'approved' then 1 else 0 end) AS approved_count,
sum(amount) AS trans_total_amount,
sum(case when state = 'approved' then amount else 0 end) AS approved_total_amount
from Transactions
group by left (cast (trans_date as  varchar), 7), country
---ex7
select product_id, year as first_year, quantity, price
from Sales
WHERE (product_id, year) in (
select product_id, min(year) 
from Sales
group by product_id
)
---ex8
select customer_id from customer 
group by customer_id 
having count(distinct product_key) = (
select count (product_key)
from product
) 
---ex9
select employee_id  from Employees
where salary < 30000 and manager_id not in  (
select employee_id from Employees
)
---ex10: trùng vời ex1
---ex11
(select name as results
from MovieRating join Users on MovieRating.user_id = Users.user_id
group by name
ORDER BY COUNT(*) DESC, name
limit 1)
union all 
(SELECT title as results
FROM MovieRating JOIN Movies on MovieRating.movie_id = Movies.movie_id
where left (cast (created_at as varchar),7) = '2020-02'
group by title
ORDER BY AVG(rating) DESC, title
limit 1)
---ex12
with cte as(
select requester_id as id from RequestAccepted
union all
select accepter_id as id from RequestAccepted
)
select id, count(*) as num  
from cte 
group by id 
order by count(*) desc 
limit 1 
