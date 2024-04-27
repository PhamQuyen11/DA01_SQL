---ex1
with cte as 
(select 
EXTRACT(year from transaction_date) as year , 
product_id,
sum(spend) as curr_year_spend 
from user_transactions
group by EXTRACT('year' from transaction_date) , product_id) ,

cte1 as 
(SELECT * , 
lag(curr_year_spend) over(partition by product_id order by year) as prev_year_spend 
from cte)

SELECT *, 
round((curr_year_spend - prev_year_spend ) * 100/ prev_year_spend , 2 ) as yoy_rate
from cte1 

---ex2
 SELECT distinct card_name, 
first_value (issued_amount) over (partition by card_name order by issue_year, issue_month)
FROM monthly_cards_issued
order by first_value (issued_amount) over (partition by card_name order by issue_year, issue_month) DESC

---ex3
with cte as (
SELECT user_id, spend, transaction_date,
RANK() OVER(PARTITION BY user_id ORDER BY transaction_date) as STT
FROM transactions
) 
select user_id, spend, transaction_date from cte 
where STT = 3 

---ex4
with cte as (
SELECT transaction_date, user_id,
COUNT(product_id) OVER(PARTITION BY transaction_date, user_id) as purchase_count,
ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY transaction_date desc) as stt 
 FROM user_transactions
 )
select transaction_date, user_id,purchase_count from cte 
where stt = 1 

---ex5
WITH cte AS (
SELECT user_id,tweet_date,tweet_count,
LAG(tweet_count, 2) OVER (PARTITION BY user_id ORDER BY tweet_date) AS lag2,
LAG(tweet_count, 1) OVER (PARTITION BY user_id ORDER BY tweet_date) AS lag1
  FROM tweets
)
SELECT user_id,tweet_date,
  CASE 
    WHEN lag1 IS NULL AND lag2 IS NULL THEN ROUND(tweet_count, 2)
    WHEN lag1 IS NULL THEN ROUND((lag2 + tweet_count) / 2.0, 2)
    WHEN lag2 IS NULL THEN ROUND((lag1 + tweet_count) / 2.0, 2)
    ELSE ROUND((lag1 + lag2 + tweet_count) / 3.0, 2)
  END AS rolling_avg_3d
FROM cte

---ex6
with cte as (
SELECT *,transaction_timestamp-lag(transaction_timestamp,1) 
OVER(PARTITION BY merchant_id,credit_card_id) as ss
FROM transactions
)
select count( DISTINCT merchant_id)
from cte 
where ss is not NULL and ss <= '00:10:00'

---ex7
with cte as
(SELECT category,product,sum(spend) as total_spend,
rank() over(partition by category order by sum(spend) desc) as no
FROM product_spend
where EXTRACT(year from transaction_date)=2022
group by category,product
order by category,total_spend desc
)
select category,product,total_spend
from cte
where no<3

---ex8
with cte as (
SELECT a.artist_name,g.rank
FROM artists a  
join songs s 
on a.artist_id=s.artist_id
join global_song_rank g  
on s.song_id=g.song_id
where g.rank<=10
),
cte2 as (
select artist_name,COUNT(*) as cnt
from cte 
GROUP BY artist_name
),
cte3 as (
select artist_name,dense_rank() over (order by cnt desc) as artist_rank
from cte2
)
select * from cte3 
where artist_rank<=5
