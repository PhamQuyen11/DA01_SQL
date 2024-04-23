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
-------------Mid-course Test 
---QS1
select distinct replacement_cost from film
order by replacement_cost 
---QS2
select  
case when replacement_cost between 9.99 and 19.99 then 'low'
when replacement_cost between 20.00 and 24.99 then 'medium'
else 'high'
end as RP_C,
count (*) as so_luong 
from film
group by RP_C  
---QS3
select a.title, a.length, c.name from film as a
join film_category as b
on a.film_id=b.film_id
full join category as c
on b.category_id = c.category_id 
where c.name in ('Drama','Sports')
order by a.length desc 
---QS4
select c.name, 
count (a.title) as so_luong
from film as a
join film_category as b
on a.film_id=b.film_id
full join category as c
on b.category_id = c.category_id 
group by c.name
order by so_luong desc
---QS5
select a.first_name, a.last_name,
count (c.title) as so_luong
from actor as a
full join film_actor as b
on a.actor_id=b.actor_id
full join film as c
on b.film_id = c.film_id 
group by a.first_name, a.last_name 
order by so_luong desc
---QS6
select b.customer_id, a.address
from address as a
left join customer as b
on a.address_id=b.address_id
where b.address_id is null
---QS7
select c.city, 
sum (p.amount) as doanh_thu
FROM city as c
full join address as a
on a.city_id = c.city_id
full join customer as ctm
on ctm.address_id = a.address_id
full join payment as p
on p.customer_id = ctm.customer_id
group by c.city
order by sum (p.amount) desc
---QS8
select  ctr.country || ', ' || c.city,
sum (p.amount) as doanh_thu
FROM city as c
full join address as a
on a.city_id = c.city_id
full join customer as ctm
on ctm.address_id = a.address_id
full join payment as p
on p.customer_id = ctm.customer_id
full join country as ctr
on ctr.country_id = c.country_id
group by c.city, ctr.country
order by sum (p.amount) desc
