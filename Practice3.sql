--- ex1
select Name from STUDENTS
where Marks > 75 
order by right (name, 3) asc, id
--- ex2
select user_id, 
concat(upper(left(name,1)), lower(right(name,length(name)-1))) as name --- concat(upper(left(name,1)), lower(substring (name,2))) as name 
from Users
order by user_id 
--- ex 3
SELECT manufacturer,
'$' || round (sum (total_sales)/1000000) ||' million' as sale 
FROM pharmacy_sales
group by manufacturer 
order by sum (total_sales) desc, manufacturer
--- ex4
SELECT 
extract (month from submit_date), 
product_id as product,
round (avg (stars),2) as avg_star 
FROM reviews
group by extract (month from submit_date), product 
order by  extract (month from submit_date), product_id
--- ex 5
SELECT 
sender_id,
count(content) as message_count
FROM messages
where extract (month from sent_date) = '8' and extract (year from sent_date) = '2022'
group by sender_id
order by count(content) desc
limit 2 
--- ex6
select 
tweet_id from Tweets
where length (content) > 15 
--- ex7
activity_date as day,
count (distinct user_id) as active_users from Activity 
WHERE activity_date BETWEEN '2019-06-28' AND '2019-07-27'
group by activity_date
order by activity_date 
--- ex8
select 
count (employee_id) as number_employee
from employees
where extract (month from joining_date ) in ('1','2','3','4','5','6','7') 
and extract (year from joining_date ) = '2022'
--- ex9
select 
position ('a' in first_name) as pst
from worker
where first_name = 'Amitah'
--- ex10
select 
cast (substring (title, position ('2' in title), 4) as int )
from winemag_p2
where country = 'Macedonia'
