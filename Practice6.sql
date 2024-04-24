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
