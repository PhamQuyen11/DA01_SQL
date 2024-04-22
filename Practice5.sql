---ex1
select b.Continent, 
floor (avg (a.Population)) as avg_p
from CITY as a
join  COUNTRY as b
on a.Countrycode = b.Code
group by b.Continent
---ex2
SELECT ROUND(cast (SUM(CASE 
  WHEN b.signup_action='Confirmed' THEN 1 ELSE 0 END) as decimal) /COUNT(b.email_id),2) AS confirm_rate
FROM emails AS a
LEFT JOIN texts AS b
ON e.email_id=t.email_id;
---ex3
SELECT age_bucket,
round(sum(case when activity_type='send' then time_spent end)*100/(sum(case when activity_type='open' then time_spent end)+sum(case when activity_type='send' then time_spent end)),2) as send_prec,
round(sum(case when activity_type='open' then time_spent end)*100/(sum(case when activity_type='open' then time_spent end)+sum(case when activity_type='send' then time_spent end)),2) as open_prec
FROM activities as a
inner join age_breakdown as b
on a.user_id=b.user_id
group by age_bucket
---ex4
SELECT a.customer_id
FROM customer_contracts as a 
INNER JOIN products as b 
ON a.product_id = b.product_id
GROUP BY a.customer_id
HAVING COUNT(DISTINCT b.product_category) >= 3
---ex5
select rp.employee_id, rp.name as name, 
count (emp.reports_to) as reports_count,
round (avg (emp.age)) as average_age 
from employees as emp
join employees as rp
on emp.reports_to = rp.employee_id
group by rp.employee_id, rp.name
order by rp.employee_id 
---ex6
select distinct a.product_name,
sum (b.unit) as unit
from Products as a
join Orders as b
on a.product_id = b.product_id
WHERE b.order_date BETWEEN '2020-02-01' AND '2020-02-29'
GROUP BY b.product_id, a.product_name
HAVING SUM(b.unit) >= 100;
---ex7
select a.page_id
from pages as a 
full join page_likes as b
on a.page_id=b.page_id
where b.page_id is null
order by a.page_id
