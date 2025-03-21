# SECTION - 6
# Function LEAD(x)
# The analytic function here is LEAD(name).
# LEAD with a single argument in the parentheses looks at the next row in the given order and shows the value in the column specified as the argument.

SELECT
  name,
  opened,
  LEAD(name) OVER(ORDER BY opened)
FROM website;

# For all the statistics of the website with id = 1, show the day, the number of users and the number of users on the next day.
SELECT
  day,
  users,
  LEAD(users) OVER(ORDER BY day)
FROM statistics
where website_id = 1;

# Deltas
# LEAD() can be extremely useful when we want to calculate Deltas, 
# i.e. differences between two values.
# For website_id = 1, show each statistics row: day, 
# revenue, revenue on the next day and the difference between these two values (as next day's minus that day's revenue).

SELECT
  day,
  revenue,
  LEAD(revenue) OVER(ORDER BY day),
  LEAD(revenue) OVER(ORDER BY day) - revenue AS difference
FROM statistics
WHERE website_id = 1;

# Function LEAD(x, y)
# LEAD(x,y). x remains the same – it specifies the column to return. 
# y, in turn, is a number which defines the number of rows forward from the current value.
# Take the statistics for the website with id = 2 between 1 and 14 May 2016 and show the day, the number of users and the number of users 7 days later.
# Note that the last 7 rows in the results don't have a value in the last column, because no rows '7 days from now' can be found for them.
SELECT
  day,
  users,
  LEAD(users, 7) OVER(ORDER BY day)
FROM statistics
WHERE website_id = 2
  AND day BETWEEN '2016-05-01' AND '2016-05-14';
  
-- Modify the template based on the previous exercise so that it shows -1 instead of NULL if no LEAD value is found.
SELECT
  day,
  users,
  LEAD(users,7, -1) OVER(ORDER BY day)
FROM statistics
WHERE website_id = 2
  AND day BETWEEN '2016-05-01' AND '2016-05-14';
  
-- Function LAG(x)
-- There's also a function that shows a previous value, and its name is LAG(x):
/*
Note that you can always sort the rows in the reverse order with DESC and use LEAD(...) instead of LAG(...), or the other way around. In other words:
LEAD (...) OVER(ORDER BY ...)
is the same as
LAG (...) OVER (ORDER BY ... DESC)
and
LEAD (...) OVER(ORDER BY ... DESC)
is the same as
LAG (...) OVER (ORDER BY ...)
*/
-- Show the statistics for the website with id = 3: day, number of clicks that day and the number of clicks on the previous day.
-- Note that there won't be any previous value for the first row.
SELECT
  day,
  clicks,
  LAG(clicks) OVER(ORDER BY day)
FROM statistics
WHERE website_id = 3;

-- Function LAG(x, y)
-- Show the statistics for the website with id = 3: day, revenue and the revenue 3 days before.
SELECT
  day,
  revenue,
  LAG(revenue,3) OVER(ORDER BY day)
FROM statistics
WHERE website_id = 3;

-- Function LAG(x, y, z)
-- Modify the template from the previous exercise so that it shows -1.00 for rows with no revenue value 3 days before.
SELECT
  day,
  revenue,
  LAG(revenue,3,-1.00) OVER(ORDER BY day)
FROM statistics
WHERE website_id=3;

-- Excercise
-- For each statistics row with website_id = 2, show the day, the RPM and the RPM 7 days later. Rename the columns to RPM and RPM_7.

SELECT
  day,
  revenue / impressions * 1000 AS RPM,
  LEAD(revenue / impressions, 7) OVER(ORDER BY day) * 1000 AS RPM_7
FROM statistics
WHERE website_id = 2;

-- For website_id = 1 and dates between May 15 and May 31, 2016, show each statistics row: day, clicks, impressions, conversion rate (as the conversion column) 
-- and the conversion rate on the previous day (as the previous_conversion column).
/*
SELECT
  day,
  clicks,
  impressions,
  CAST(clicks AS numeric) / impressions * 100 AS conversion,
  CAST(LAG(clicks) OVER(ORDER BY day) AS numeric) / LAG(impressions) OVER(ORDER BY day) * 100 AS previous_conversion
FROM statistics
WHERE website_id = 1
  AND day BETWEEN '2016-05-15' AND '2016-05-31';
*/
-- FIRST_VALUE(x)
-- Show the statistics for website_id = 2. For each row, show the day, the number of users and the smallest number of users ever.
SELECT
  day,
  users,
  FIRST_VALUE(users) OVER(ORDER BY users)
FROM statistics
WHERE website_id = 2;
-- Show the statistics for website_id = 3. For each row, show the day, the revenue and the revenue on the first day.
SELECT
  day,
  revenue,
  FIRST_VALUE(revenue) OVER(ORDER BY day)
FROM statistics
WHERE website_id = 3;

-- LAST_VALUE(x) with window frame
SELECT
  name,
  opened,
  LAST_VALUE(opened) OVER(
    ORDER BY opened
    ROWS BETWEEN UNBOUNDED PRECEDING
      AND UNBOUNDED FOLLOWING)
FROM website;

-- Show the statistics for website_id = 1. For each row, show the day, 
-- the number of impressions and the number of impressions on the day with the most users.
SELECT
  day,
  impressions,
  LAST_VALUE(impressions) OVER(
    ORDER BY users
    ROWS BETWEEN UNBOUNDED PRECEDING
      AND UNBOUNDED FOLLOWING)
FROM statistics
WHERE website_id = 1;

-- For each statistics rows with website_id = 1, show the day, the number of users, the number of users on the last day and the difference between these two values.
SELECT
  day,
  users,
  LAST_VALUE(users) OVER(
    ORDER BY day
    ROWS BETWEEN UNBOUNDED PRECEDING
      AND UNBOUNDED FOLLOWING),
  users - LAST_VALUE(users) OVER(
    ORDER BY day
    ROWS BETWEEN UNBOUNDED PRECEDING
      AND UNBOUNDED FOLLOWING)
FROM statistics
WHERE website_id = 1;

-- NTH_VALUE(x, n)
-- The last function we'll learn in this part is: NTH_VALUE(x,n). 
-- This function returns the value in the column x of the nth row in the given order.
-- Take the statistics for the website with id = 2 between May 15 and May 31, 2016. Show the day, the revenue on that day and the third highest revenue in that period.
SELECT 
  day, 
  revenue, 
  NTH_VALUE(revenue, 3) OVER (
    ORDER BY revenue DESC 
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  )
FROM statistics
WHERE website_id = 2 
AND day BETWEEN '2016-05-15' AND '2016-05-31';

/* Practice 1
Let's run some cross-website statistics now. Take the day May 14, 2016 and for each row, show: website_id, revenue on that day, the highest revenue from any website on that day 
(AS highest_revenue and the lowest revenue from any website on that day (as lowest_revenue).
*/
SELECT 
  website_id, 
  revenue, 
  FIRST_VALUE(revenue) OVER (ORDER BY website_id) AS highest_revenue,
  LAST_VALUE(revenue) OVER (
    ORDER BY website_id 
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS lowest_revenue
FROM statistics
WHERE day = '2016-05-14';

/* Practice 2
Take the statistics for website_id = 1. For each row, show the day, 
the number of clicks on that day and the median of clicks in May 2016 (calculated as the 16th value of all 31 values in the column clicks when sorted by the number of clicks).
*/
SELECT
  day,
  clicks,
  NTH_VALUE(clicks, 16) OVER(
    ORDER BY clicks DESC
    ROWS BETWEEN UNBOUNDED PRECEDING
      AND UNBOUNDED FOLLOWING)
FROM statistics
WHERE website_id = 1;

-- Practice 3
-- For each statistics row of website_id = 3, show the day, the number of clicks on that day and a ratio expressed as percentage: the number of clicks on that day to the greatest number of clicks on any day. 
-- Round the percentage to integer values.
/*
SELECT 
  day, 
  clicks, 
  ROUND(
    (CAST(clicks AS numeric) / MAX(clicks) OVER ()) * 100
  )
FROM statistics
WHERE website_id = 3;
*/
/*Summary:
LEAD(x) and LAG(x) give you the next/previous value in the column x, respectively.
LEAD(x,y) and LAG(x,y) give you the value in the column x of the row which is y rows after/before the current row, respectively.
FIRST_VALUE(x) and LAST_VALUE(x) give you the first and last value in the column x, respectively.
NTH_VALUE(x,n) gives you the value in the column x of the n-th row.
LAST_VALUE and NTH_VALUE usually require the window frame to be set to
- ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
*/
-- Exercise 1
SELECT
  day,
  price,
  LEAD(price) OVER(ORDER BY day)
FROM advertisement;

-- Exercise 2
SELECT
  day,
  price,
  LAG(price, 7) OVER(ORDER BY day),
  price - LAG(price, 7) OVER(ORDER BY day)
FROM advertisement;

-- Exercise 3
SELECT 
  day, 
  price,
  FIRST_VALUE(price) OVER (ORDER BY price) AS lowest_price,
  LAST_VALUE(price) OVER (
    ORDER BY price 
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS highest_price
FROM advertisement;

# SECTION - 7
-- PARTITION BY – refresher 1
-- For each sales row, show the store_id, day, revenue on that day and the average revenue in that store.
SELECT
  store_id,
  day,
  revenue,
  AVG(revenue) OVER(PARTITION BY store_id)
FROM sales;

-- PARTITION BY – refresher 2
-- For each sales row between August 1 and August 7, 2016, show the store_id, day, number of transactions, 
-- the total number of transactions on that day in any store and the ratio of the two last columns shown as percentage rounded to integer values.
/* POSTGRESS
SELECT
  store_id,
  day,
  transactions,
  SUM(transactions) OVER(PARTITION BY day),
  ROUND(CAST(transactions AS numeric) / SUM(transactions) OVER(PARTITION BY day)*100)
FROM sales
WHERE day BETWEEN '2016-08-01' AND '2016-08-07';
*/
# MYSQL
SELECT 
  store_id,
  day,
  transactions,
  SUM(transactions) OVER (PARTITION BY day) AS total_transactions,
  ROUND((transactions / SUM(transactions) OVER (PARTITION BY day)) * 100) AS transaction_ratio_percentage
FROM sales
WHERE day BETWEEN '2016-08-01' AND '2016-08-07';

-- PARTITION BY ORDER BY with ranking
-- RANK() with PARTITION BY ORDER BY
-- Take into account the period between August 10 and August 14, 2016. For each row of sales, show the following information: store_id, day, number of customers 
-- and the rank based on the number of customers in the particular store (in descending order).
SELECT
  store_id,
  day,
  customers,
  RANK() OVER(PARTITION BY store_id ORDER BY customers DESC)
FROM sales
Where day between '2016-08-10' and '2016-08-14';

-- NTILE(x) with PARTITION BY ORDER BY
-- Take the sales between August 1 and August 10, 2016. For each row, show the store_id, the day, 
-- the revenue on that day and quartile number (quartile means we divide the rows into four groups) based on the revenue of the given store in the descending order.
SELECT
  store_id,
  day,
  revenue,
  NTILE(4) OVER(PARTITION BY store_id ORDER BY revenue DESC)
FROM sales
Where day between '2016-08-01' and '2016-08-10';

# PARTITION BY ORDER BY in CTE
# For each store, show a row with three columns: store_id, 
# the revenue on the best day in that store in terms of the revenue and the day when that best revenue was achieved.
WITH ranking AS (
  SELECT
    store_id,
    revenue,
    day,
    RANK() OVER(PARTITION BY store_id ORDER BY revenue DESC) AS rev_rank
  FROM sales
)

SELECT
  store_id,
  revenue,
  day
FROM ranking
WHERE rev_rank = 1;

# Practice 1
# Let's analyze sales data between August 1 and August 3, 2016. 
# For each row, show store_id, day, transactions and the ranking of the store on that day in terms of the number of transactions as compared to other stores. 
# The store with the greatest number should get 1 from a window function. Use individual row ranks even when two rows share the same value. Name the column place_no.
SELECT
  store_id,
  day,
  transactions,
  ROW_NUMBER() OVER (PARTITION BY day ORDER BY transactions DESC) AS place_no
FROM sales
WHERE day
BETWEEN '2016-08-01' AND '2016-08-03';

# For each day of the sales statistics, show the day, the store_id of the best store in terms of the revenue on that day, and that revenue.
WITH ranking AS (
  SELECT
    store_id,
    revenue,
    day,
    RANK() OVER(PARTITION BY day ORDER BY revenue DESC) AS rev_rank
  FROM sales
)

SELECT
  store_id,
  revenue,
  day
FROM ranking
WHERE rev_rank = 1;

-- Practice 3
-- Divide the sales results for each store into four groups based on the number of transactions and for each store, 
-- show the rows in the group with the lowest numbers of transactions: store_id, day, transactions.
WITH ranking AS (
  SELECT
    store_id,
    day,
    transactions,
    NTILE(4) OVER(PARTITION BY store_id ORDER BY transactions) AS quartile
  FROM sales
)

SELECT
  store_id,
  day,
  transactions
FROM ranking
WHERE quartile = 1;

# PARTITION BY ORDER BY with window frames
# Show sales statistics between August 1 and August 7, 2016.
# For each row, show store_id, day, revenue and the best revenue in the respective store up to that date.
# In part 5, you got to know window frames. Can we use them together with PARTITION BY to create even more sophisticated windows? Yes
SELECT
  store_id,
  day,
  revenue,
  MAX(revenue) OVER(
    PARTITION BY store_id
    ORDER BY day
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
FROM sales
WHERE day BETWEEN '2016-08-01' AND '2016-08-07';

# Practice 1
# Take sales from the period between August 1 and August 10, 2016. For each row, show the following information: 
# store_id, day, number of transactions and the average number of transactions in the respective store in the window frame starting 2 days before and ending 2 days later with respect to the current row.
SELECT
  store_id,
  day,
  transactions,
  AVG(transactions) OVER(
    PARTITION BY store_id
    ORDER BY day
    ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING)
FROM sales
WHERE day BETWEEN '2016-08-01' AND '2016-08-10';

# For each sales row, show the following information: store_id, day, revenue and the future cash flow receivable by the headquarters 
# (i.e. the total revenue in that store, counted from the current day until the last day in our table).
SELECT
  store_id,
  day,
  revenue,
  SUM(revenue) OVER(
    PARTITION BY store_id
    ORDER BY day
    ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)
FROM sales;


-- LEAD() with PARTITION BY ORDER BY
/*
For each store, show the sales in the period between August 5, 2016 and August 10, 2016: store_id, day, number of transactions,
number of transactions on the previous day and the difference between these two values.
*/
SELECT
  store_id,
  day,
  transactions,
  LAG(transactions) OVER(PARTITION BY store_id ORDER BY day),
  transactions - LAG(transactions) OVER(PARTITION BY store_id ORDER BY day)
FROM sales
WHERE day BETWEEN '2016-08-05' AND '2016-08-10';

-- FIRST_VALUE() with PARTITION BY ORDER BY
# Show sales figures in the period between August 1 and August 3: for each store, show the store_id, the day, 
# the revenue and the date with the best revenue in that period (for this store) as best_revenue_day.
SELECT
  store_id,
  day,
  revenue,
  FIRST_VALUE(day) OVER(PARTITION BY store_id ORDER BY revenue DESC) as best_revenue_day
FROM sales
where day between '2016-08-01' and '2016-08-03';

-- Practice 1
-- For each row of the sales figures, show the following information: store_id, day, revenue, revenue for this store a week before and the ratio of revenue today to the revenue for this store a week before, 
-- expressed in percentage with 2 decimal places.
SELECT
  store_id,
  day,
  revenue,
  LAG(revenue,7) OVER(PARTITION BY store_id ORDER BY day),
  ROUND(revenue / LAG(revenue, 7) OVER(PARTITION BY store_id ORDER BY day) * 100, 2)
FROM sales;
/*
For each row, show the following columns: store_id, day, 
customers and the number of clients in the 5th greatest store in terms of the number of customers on that day.
*/
SELECT 
  store_id,
  day,
  customers,
  NTH_VALUE(customers, 5) OVER (
    PARTITION BY day 
    ORDER BY customers DESC
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  )
FROM sales;

-- Exercise 1
-- For each day, show the following two columns: day and the name of the second most frequently repaired phone on that day. Only take into account free_repairs.
-- In case of a tie for the second most frequently repaired phone, display all phones that share this position.
WITH ranking AS (
  SELECT
    day,
    phone,
    RANK() OVER(PARTITION BY day ORDER BY free_repairs DESC) AS rank2
  FROM repairs
)

SELECT
  day,
  phone
FROM ranking
WHERE rank2 = 2;

-- Exercise 2
-- For each phone, show the following information: phone, day, revenue and the revenue for the first repair for each phone (column name first_revenue)
SELECT 
  phone, 
  day, 
  revenue, 
  FIRST_VALUE(revenue) OVER (
    PARTITION BY phone 
    ORDER BY day
  ) AS first_revenue
FROM repairs;

-- Exercise 3
/*
For each phone, show the following information: phone, day, the number of paid repairs, 
the number of paid repairs on the previous day and the difference between these two values.
*/
SELECT
  phone,
  day,
  paid_repairs,
  LAG(paid_repairs) OVER(PARTITION BY phone ORDER BY day),
  paid_repairs - LAG(paid_repairs) OVER(PARTITION BY phone ORDER BY day)
FROM repairs;
