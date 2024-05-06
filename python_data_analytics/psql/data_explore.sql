-- Show table schema 
\d+ retail;

-- Q1: Show first 10 rows
SELECT * FROM retail limit 10;

-- Q2: Check # of records
select count(*) from retail;

-- Q3: number of clients (e.g. unique client ID)
select count(distinct customer_id) from retail;

-- Q4: invoice date range (e.g. max/min dates)
select max(invoice_date), min(invoice_date) from retail;

-- Q5: number of SKU/merchants (e.g. unique stock code)
select count(distinct stock_code) from retail;


-- - Q6: Calculate average invoice amount excluding invoices with a negative amount (e.g. canceled orders have negative amount)
-- - an invoice consists of one or more items where each item is a row in the df
--  - hint: you need to use GROUP BY and HAVING

select AVG(total_amount) as avg_invoice_amount
from (
    select invoice_no, SUM(quantity * unit_price) as total_amount
    from retail
    group by invoice_no
    having SUM(quantity * unit_price) > 0
) as positive_invoices;

    
-- Q7: Calculate total revenue (e.g. sum of unit_price * quantity)
select sum(quantity * unit_price) as revenue from retail;

    
-- Q8: Calculate total revenue by YYYYMM
-- - hints
--    - Create a new YYYMM column
--    e.g. you want convert 2010-10-28 (datetime) to 201010 (integer). 201010 = 2010 *100 + 10.
--    - The following functions might be useful: [extract](https://www.postgresqltutorial.com/postgresql-extract/), [cast](https://www.postgresqltutorial.com/postgresql-cast/)
  
select cast(extract(year from invoice_date) as integer) * 100 + cast(extract(month from invoice_date) as integer) as yyyymm,
sum(quantity * unit_price) as total_revenue from retail group by yyyymm order by yyyymm;
