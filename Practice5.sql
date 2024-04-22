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

