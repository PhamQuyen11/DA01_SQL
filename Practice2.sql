--- ex1
select distinct city from STATION
where id % 2 = 0
group by city
---ex2
select count(CITY) - count(distinct CITY) from station
---ex4
SELECT
round(cast(sum(order_occurrences*item_count)/sum(order_occurrences) as decimal),1) as mean 
/*cast(... as decimal) - sau khi thực hiện phép chia, PostgreSQL tự nhận định đó là dạng số nguyên, 
để chuyển về dạng số thập phân phải dùng lệnh này */
FROM items_per_order 
---ex5
SELECT candidate_id FROM candidates
where skill in ('Python','Tableau','PostgreSQL') 
group by candidate_id	
having count(skill) = 3
---ex6
SELECT user_id,
date(max(post_date)) - date(min(post_date)) as days_between
FROM posts
where post_date between '01/01/2021' and '12/31/2021'
group by user_id
having count(post_id) > 1
---ex7
SELECT card_name,
max (issued_amount) - min(issued_amount) as difference
FROM monthly_cards_issued
group by card_name
order by max (issued_amount) - min(issued_amount) desc 
/* dùng order by difference desc cũng được */
---ex 8
SELECT manufacturer,
count (drug) as drug_count,
abs(sum(cogs)- sum(total_sales))  as total_loss
FROM pharmacy_sales
where total_sales-cogs <= 0 
group by manufacturer
order by total_loss desc
---ex9
select * from Cinema
where id%2 = 1 and description != 'boring'
order by rating desc
---ex10
select teacher_id,
count(distinct subject_id) as cnt
from Teacher 
group by teacher_id
---ex11
select user_id,
count (follower_id) as followers_count
from Followers 
group by user_id
order by user_id
---ex12
select class from Courses
group by class
having count(student) >= 5 

