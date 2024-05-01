select * from public.sales_dataset_rfm_prj
1) 
ALTER TABLE sales_dataset_rfm_prj 
ALTER COLUMN ordernumber 
TYPE numeric USING (trim(ordernumber)::numeric),
ALTER COLUMN quantityordered 
TYPE int USING (trim(quantityordered)::int),
ALTER COLUMN msrp
TYPE int USING (trim(msrp)::int),
ALTER COLUMN orderlinenumber 
TYPE smallint USING (trim(orderlinenumber)::smallint),
ALTER COLUMN priceeach 
TYPE numeric USING (trim(priceeach)::numeric),
ALTER COLUMN sales 
TYPE numeric USING (trim(sales)::numeric),
ALTER orderdate TYPE timestamp using to_TIMESTAMP(orderdate, 'mm/dd/yyyy hh24:mi')
2)
ALTER TABLE public.sales_dataset_rfm_prj
ADD CONSTRAINT check_ordernumber 
CHECK (ordernumber IS NOT NULL),
ADD CONSTRAINT check_quantityordered
CHECK (quantityordered IS NOT NULL),
ADD CONSTRAINT check_priceeach
CHECK (priceeach IS NOT NULL),
ADD CONSTRAINT check_orderlinenumber
CHECK (orderlinenumber IS NOT NULL),
ADD CONSTRAINT check_sales
CHECK (sales IS NOT NULL),
ADD CONSTRAINT check_orderdate
CHECK (orderdate IS NOT NULL)

ALTER TABLE public.sales_dataset_rfm_prj
ADD COLUMN contactlastname VARCHAR,
ADD COLUMN contactfirstname VARCHAR
3) 
UPDATE public.sales_dataset_rfm_prj
SET contactlastname = UPPER(SUBSTRING(contactfullname, POSITION('-' IN contactfullname) + 1,1)) || LOWER(RIGHT(contactfullname, LENGTH(contactfullname) - POSITION('-' IN contactfullname)-1)),
contactfirstname = UPPER(LEFT(contactfullname, 1)) || SUBSTRING(contactfullname, 2, POSITION('-' IN contactfullname) - 2)
4)
ALTER TABLE public.sales_dataset_rfm_prj
ADD COLUMN QTR_ID INTEGER,
ADD COLUMN MONTH_ID INTEGER,
ADD COLUMN YEAR_ID INTEGER;
UPDATE public.sales_dataset_rfm_prj
SET QTR_ID = EXTRACT('quarter' FROM orderdate),
MONTH_ID = EXTRACT('month' FROM orderdate),
YEAR_ID = EXTRACT('year' FROM orderdate)
5)
---Boxplot 
With cte_b as (
SELECT q1 - 1.5*(q3-q1) as min_value, q3 + 1.5*(q3-q1) as max_value from (
Select 
percentile_cont(0.25) within group (order by quantityordered) as q1,
percentile_cont(0.75) within group (order by quantityordered) as q3,
percentile_cont(0.75) within group (order by quantityordered) - percentile_cont(0.25) within group (order by quantityordered) as IQR from public.sales_dataset_rfm_prj) as a)
select quantityordered from public.sales_dataset_rfm_prj 
where quantityordered < (select min_value from cte_b) or quantityordered > (select max_value from cte_b)
---Z-score 
With cte as (
Select quantityordered, (Select avg (quantityordered) as avg From public.sales_dataset_rfm_prj) ,
(Select stddev (quantityordered) From public.sales_dataset_rfm_prj) as stddev 
From public.sales_dataset_rfm_prj),
twt_outlier as (
Select quantityordered, (quantityordered - avg)/stddev as z_score
From cte where abs ((quantityordered - avg)/stddev) > 2)

Delete from public.sales_dataset_rfm_prj
Where quantityordered in (select quantityordered from twt_outlier)
6)
CREATE TABLE SALES_DATASET_RFM_PRJ_CLEAN AS
(SELECT * FROM SALES_DATASET_RFM_PRJ)
