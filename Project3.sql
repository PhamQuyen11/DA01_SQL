---1)
select productline, year_id, dealsize, 
sum (sales) as revenue 
from public.sales_dataset_rfm_prj_clean
group by productline, year_id, dealsize 
order by productline,  dealsize ,year_id
---2)
select month_id, ordernumber,
sum (sales) OVER(PARTITION BY month_id)  AS revenue 
from public.sales_dataset_rfm_prj_clean
order by sum (sales) OVER(PARTITION BY month_id ) desc
---3)
SELECT month_id, productline, ordernumber,
sum (sales) OVER(PARTITION BY productline) AS revenue_in_nov
FROM public.sales_dataset_rfm_prj_clean
where month_id = 11
order by sum (sales) OVER(PARTITION BY productline) desc 
---4)
with cte1 as (
select year_id, productline, sum(sales) as revenue 
from public.sales_dataset_rfm_prj_clean
where country = 'UK'
group by year_id, productline, country
)
, cte2 as (
select *,
rank () over (partition by year_id order by revenue) as rank
from cte1)

select * from cte2
WHERE RANK = 1
---5)
With customer_rfm as (
Select customername, current_date - max(orderdate) as R,
Count (distinct ordernumber) as F,
Sum (sales) as M
From public.sales_dataset_rfm_prj_clean
Group by customername),

rfm_score as (
Select customername,
Ntile (5) over (order by R desc) as R_score,
Ntile (5) over (order by F) as F_score,
Ntile (5) over (order by M) as M_score
From customer_rfm),

rfm_final as (
Select customername,
cast (R_score as varchar) || cast (F_score as varchar) || cast (M_score as varchar) as rfm_score
From rfm_score)

Select customername, segment
from (
Select a.customername, b.segment from rfm_final a
Join segment_score b on a.rfm_score = b.scores) as a
