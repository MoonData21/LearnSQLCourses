-- Query evaluation order – problems with WHERE

-- Subqueries for problems with WHERE
-- Find the id, country and views for those auctions where the number of views was below the average.
SELECT
  id,
  country,
  views
FROM (
  SELECT
    id,
    country,
    views,
    AVG(views) OVER() AS avg_views
  FROM auction) c
WHERE views < avg_views;

-- Subqueries for problems with HAVING
-- Again, we would like to show those countries (country name and average final price) that have the average final price higher than the average price from all over the world. 
-- Correct the query by using a subquery.
SELECT
  country,
  AVG(final_price) 
FROM auction 
GROUP BY country 
HAVING AVG(final_price) > (SELECT AVG(final_price) FROM auction);

-- Subqueries for problems with GROUP BY
-- Now, divide all auctions into 6 equal groups based on the asking_price in ascending order. 
-- Show columns group_no, minimal, average and maximal value for that group. Sort by the group in ascending order.
SELECT
  group_no,
  MIN(asking_price),
  AVG(asking_price),
  MAX(asking_price)
FROM (
  SELECT
    asking_price,
    NTILE(6) OVER(ORDER BY asking_price) AS group_no
  FROM auction) c
GROUP BY group_no
ORDER BY group_no;

-- Window function in ORDER BY
-- For each auction, show the following columns: 
-- id, views and quartile based on the number of views in descending order. Order the rows by the quartile.
SELECT
  id,
  views,
  NTILE(4) OVER(ORDER BY views DESC) AS quartile
FROM auction
ORDER BY NTILE(4) OVER(ORDER BY views DESC);

-- What window functions see – continued
-- As you can see, the query now succeeded because we used an aggregate function (MAX(final_price)) that was indeed available after grouping the rows.
-- By the way, this is the only place where you can nest aggregate functions inside one another.
SELECT 
  category_id, 
  MAX(final_price) AS max_final, 
  AVG(MAX(final_price)) OVER() 
FROM auction 
GROUP BY category_id;

-- Group the auctions by the country. Show the country, 
-- the minimal number of participants in an auction and the average minimal number of participants across all countries.
SELECT 
  country, 
  MIN(participants), 
  AVG(MIN(participants)) OVER() 
FROM auction 
GROUP BY country;

-- Group the auctions by category_id and show the category_id 
-- and maximal asking price in that category alongside the average maximal price across all categories.
SELECT 
  category_id, 
  MAX(asking_price), 
  AVG(MAX(asking_price)) OVER() 
FROM auction 
GROUP BY category_id;

-- Ranking by an aggregate
-- Now, group the auctions based on the category. Show category_id, 
-- the sum of final prices for auctions from this category and a ranking based on that sum, with the highest sum coming first.
SELECT
  category_id,
  sum(final_price),
  RANK() OVER(ORDER BY sum(final_price) DESC)
FROM auction
GROUP BY category_id;

-- Ranking by an aggregate – practice
-- Group the auctions based on the day they ended and show the following columns: ended, 
-- the average number of views from auctions on that day and the ranking based on that average (the highest average should get the rank of 1).
SELECT
ended,
avg(views),
RANK() OVER(ORDER BY AVG(views) DESC)
from auction
group by ended;

-- Day-to-day deltas with GROUP BY
/*
For each end day, show the following columns:
ended,
the sum of views from auctions that ended on that day,
the sum of views from the previous day (name the column previous_day,
delta – the difference between the sum of views on that day and on the previous day (name the column delta).
*/
SELECT
  ended,
  SUM(views),
  LAG(SUM(views)) OVER(ORDER BY ended) as previous_day,
  SUM(views) - LAG(SUM(views)) OVER(ORDER BY ended) as delta
FROM auction
GROUP BY ended
ORDER BY ended;

-- Grouped rows, window functions and PARTITION BY
/*Group all auctions by the category and end date and show the following columns:
category_id,
ended,
the average daily final price as daily_avg_final_price in that category on that day,
the maximal daily average in that category from any day as daily_max_avg.
*/
SELECT
  category_id,
  ended,
  avg(final_price) AS daily_avg_final_price,
  max(avg(final_price)) OVER(PARTITION BY category_id)
    AS daily_max_avg
FROM auction
GROUP BY category_id, ended
ORDER BY category_id, ended;

-- Summary
-- Window functions can only appear in the SELECT and ORDER BY clauses.
-- If you need window functions in other parts of the query, use a subquery.
-- If the query uses aggregates or GROUP BY, remember that the window function can only see the grouped rows instead of the original table rows.

-- Excercise 1
-- Divide the books into 4 groups based on their rating. For each group (bucket),
-- show its number (column bucket), the minimal and maximal rating in that bucket.
SELECT
  bucket,
  MIN(rating),
  MAX(rating)
FROM (
  SELECT
    rating,
    NTILE(4) OVER(ORDER BY rating) AS bucket
  FROM book) c
GROUP BY bucket;

-- Exercise 2
/* For each author show:
author_id,
the number of books published by this author (name the column number_of_books),
the rank of the author based on the number of published books in descending order.
*/
SELECT 
  author_id, 
  COUNT(id) AS number_of_books, 
  RANK() OVER (ORDER BY COUNT(id) DESC) AS ranking
FROM book
GROUP BY author_id
ORDER BY ranking;

-- Exercise 3
/*For each year in which books were published, show the following columns:
publish_year,
the number of books published that year,
the number of books published in the previous year.
*/
SELECT
  publish_year,
  COUNT(id),
  LAG(COUNT(id)) OVER(ORDER BY publish_year)
FROM book
GROUP BY publish_year
ORDER BY publish_year;

-- SECTION 9
-- Practice
-- OVER() Summary
-- Show each gift card purchased: id, amount_worth and the total number of all gift cards purchased.
SELECT
  id,
  amount_worth,
  count(id) OVER()
FROM giftcard;

-- Show each subscription: id, length, start_date, payment_amount and the total amount paid for all subscriptions ever.
SELECT
  id,
  length,
  start_date,
  payment_amount,
  sum(payment_amount) OVER()
FROM subscription;

-- Show each single rental: id, rental_period, payment_amount,
-- the average amount paid from all the single rentals ever and the ratio of the two last columns.
SELECT
  id,
  rental_period,
  payment_amount,
  AVG(payment_amount) OVER(),
  ROUND((payment_amount / AVG(payment_amount) OVER()) * 100, 2)
FROM single_rental;
-- OR
SELECT
  id,
  rental_period,
  payment_amount,
  AVG(payment_amount) OVER(),
  payment_amount / AVG(payment_amount) OVER()
FROM single_rental;

-- PARTITION BY – Summary
-- For each movie, show its title, editor_rating, genre and the average editor_rating of all movies of the same genre.
SELECT
  title,
  editor_rating,
  genre,
  avg(editor_rating) OVER(PARTITION BY genre)
FROM movie;

-- For each distinctive movie, show the title, the average customer rating for that movie (as the avg_movie_rating column), the average customer rating for the entire genre (as the avg_genre_rating column), 
-- and the average customer rating for all movies (as the avg_rating column).
SELECT DISTINCT
  title,
  AVG(rating) OVER(PARTITION BY movie_id) AS avg_movie_rating,
  AVG(rating) OVER(PARTITION BY genre) AS avg_genre_rating,
  AVG(rating) OVER() AS avg_rating
FROM movie
JOIN review
  ON movie.id = review.movie_id;
  
  /*
  distinctive amount_worth values of giftcards,
count of the number of giftcards with this value that were ever purchased (shown as count_1),
count of all giftcards ever purchased (shown as count_2),
show the percentage that the respective giftcard type constitutes in relation to all gift cards. Show the last column rounded to integer values and name it percentage.
*/
SELECT 
  amount_worth,
  COUNT(*) AS count_1,
  (SELECT COUNT(*) FROM giftcard) AS count_2,
  ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM giftcard)) AS percentage
FROM giftcard
GROUP BY amount_worth
ORDER BY amount_worth;

-- PARTITION BY – Exercise 4
-- For each customer, show the following information: first_name, last_name, 
-- the average payment_amount from single rentals by that customer and the average payment_amount from single rentals by any customer from the same country.
SELECT DISTINCT
  first_name,
  last_name,
  AVG(payment_amount) OVER(PARTITION BY customer.id),
  AVG(payment_amount) OVER(PARTITION BY country)
FROM customer
JOIN single_rental
  ON customer.id = single_rental.customer_id;
  -- Anytime it says For Each (Customer, etc) use a DISTINCT
  
  -- Ranking functions – Summary
  /*
  For each movie, show the following information: title, release_year, editor_rating and the rank based on editor_rating. 
  The movie with the highest editor_rating should have rank = 1. The same rank values are possible for multiple rows, but don't leave gaps in numbering.
  */
  SELECT
  title,
  release_year,
  editor_rating,
  DENSE_RANK() OVER (ORDER BY editor_rating DESC)
FROM movie;
-- The top rated movie is first.

-- Ranking functions – Exercise 2
/*
Rank single_rental in accordance with the price paid for them. For each single_rental, show the movie title, rental_period, payment_amount and the rank. 
Multiple single_rentals can share the same rank, the highest amount should have rank = 1 and gaps in numbering are allowed, too.
*/
SELECT 
  m.title,
  s.rental_period,
  s.payment_amount,
  RANK() OVER (ORDER BY s.payment_amount DESC) AS ranking
FROM single_rental s
JOIN movie m ON s.movie_id = m.id;

-- Ranking functions – Exercise 3
/* Show the first and last name of the customer who bought the second most recent giftcard along with the date when the payment took place. 
Assume that an individual rank is assigned for each giftcard purchase.
*/
WITH ranked_giftcards AS (
  SELECT 
    g.customer_id,
    g.payment_date,
    RANK() OVER (ORDER BY g.payment_date DESC) AS ranking
  FROM giftcard g
)
SELECT 
  c.first_name, 
  c.last_name, 
  r.payment_date
FROM ranked_giftcards r
JOIN customer c ON r.customer_id = c.id
WHERE r.ranking = 2;
-- Use a CTE: WITH ranking AS (...) SELECT ... And pick the row with rank = 2;

-- Ranking functions – Exercise 4
/* For each single rental, show the rental_date, the title of the movie rented, its genre, the payment_amount and the rank of the rental in terms of the price paid (the most expensive rental should have rank = 1). 
The ranking should be created separately for each movie genre. Allow the same rank for multiple rows and allow gaps in numbering too.
*/
SELECT
  rental_date,
  title,
  genre,
  payment_amount,
  RANK() OVER(PARTITION BY genre ORDER BY payment_amount DESC)
FROM movie
JOIN single_rental
  ON single_rental.movie_id = movie.id;
  -- You'll need to join two tables: movie and single_rental. 
  -- Partition the rows by the genre, but sort them by payment_amount in the descending order.
  
  -- Window frame – Summary
  -- For each single rental, show the id, 
  -- rental_date, payment_amount and the running total of payment_amounts of all rentals from the oldest one (in terms of rental_date) until the current row.
  SELECT
  id,
  rental_date,
  payment_amount,
  SUM(payment_amount) OVER(
    ORDER BY rental_date
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
FROM single_rental;
-- ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW.

-- Window frame – Exercise 2
-- For each single rental, show its id, rental_date, platform, payment_date, payment_amount and the average payment amount calculated by taking into account the previous two rows, 
-- the current row and the next two rows when sorted by the payment_date.
SELECT
  id,
  rental_date,
  platform,
  payment_date,
  payment_amount,
  AVG(payment_amount) OVER(
    ORDER BY payment_date
    ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING)
FROM single_rental;

-- Window frame – Exercise 3
-- For each subscription, show the following columns: id, length, platform, payment_date, payment_amount and the future cashflows calculated as the total money from all subscriptions starting from the beginning of the payment_date of the current row 
-- (i.e. include any other payments on the very same date) until the very end.
SELECT
  id,
  length,
  platform,
  payment_date,
  payment_amount,
  SUM(payment_amount) OVER(
    ORDER BY payment_date
    RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)
FROM subscription;
-- This time, instead of ROWS, we need RANGE: RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING

-- Window frame – Exercise 4
-- For each single rental, show the following information: rental_date, title of the movie rented, genre of the movie, payment_amount and the highest payment_amount for any movie in the same genre rented from the first day up to the current rental_date. 
-- Show the last column as highest_amount.
SELECT
  rental_date,
  title,
  genre,
  payment_amount,
  MAX(payment_amount) OVER(
    PARTITION BY genre
    ORDER BY rental_date
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS highest_amount
FROM movie
JOIN single_rental
  ON single_rental.movie_id = movie.id;
  
  -- Analytic functions – Summary
  SELECT
  amount_worth,
  payment_amount,
  FIRST_VALUE(payment_amount) OVER(ORDER BY payment_date),
  LAST_VALUE(payment_amount) OVER(
    ORDER BY payment_date
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM giftcard;
-- Use both FIRST_VALUE and LAST_VALUE. Remember that LAST_VALUE requires redefining the window frame:
-- ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING

-- Analytic functions – Exercise 2
-- For each single rental, show the following columns: id, payment_date, payment_amount, 
-- the payment_amount of the previous single_rental in terms of the payment_date and the difference between the last two values.
-- Use LAG(payment_amount) and order by the payment_date.
SELECT
  id,
  payment_date,
  payment_amount,
  LAG(payment_amount) OVER(ORDER BY payment_date),
  payment_amount - LAG(payment_amount) OVER(ORDER BY payment_date)
FROM single_rental;

-- Analytic functions – Exercise 3
/*
In this exercise, it is best to create a temporary table using WITH table_name AS (...). In the temporary table, group payment_amounts by dates. 
Once this table is ready, you can easily select the daily sum from that temporary table and the use the lag function to retrieve the value on the previous day.
*/
WITH temporary AS (
  SELECT
    rental_date,
    SUM(payment_amount) AS payment_amounts
  FROM single_rental
  GROUP BY rental_date
)

SELECT
  rental_date,
  payment_amounts,
  LAG(payment_amounts) OVER(ORDER BY rental_date),
  payment_amounts - LAG(payment_amounts) OVER(ORDER BY rental_date) AS difference
FROM temporary;

-- Analytic functions – Exercise 4
-- For each customer, show the following information: first_name, last_name, 
-- the sum of payments (AS sum_of_payments) for all single rentals and the sum of payments of the median customer in terms of the sum of payments (since there are 7 customers, pick the 4th customer as the median).
-- That's a difficult one! You will need to use GROUP BY with first_name and last_name and ORDER BY SUM(payment_amount). Remember that NTH_VALUE requires two arguments and redefine the window frame:
-- ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
SELECT
  first_name,
  last_name,
  SUM(payment_amount) AS sum_of_payments,
  NTH_VALUE(SUM(payment_amount), 4) OVER(
    ORDER BY SUM(payment_amount)
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM single_rental
JOIN customer
  ON customer.id = single_rental.customer_id
GROUP BY first_name, last_name;

-- PARTITION BY ORDER BY – Summary
-- For each movie, show its title, genre, editor_rating and its rank based on editor_rating for all the movies in the same genre.
SELECT
  title,
  genre,
  editor_rating,
  RANK() OVER(PARTITION BY genre ORDER BY editor_rating DESC)
FROM movie;
-- PARTITION BY ORDER BY – Exercise 1
SELECT
  review.id,
  title,
  rating,
  LAG(rating) OVER(PARTITION BY movie_id ORDER BY review.id)
FROM review
JOIN movie
  ON review.movie_id = movie.id;
  
  -- PARTITION BY ORDER BY – Exercise 2
  /*
  For each movie, show the following information: title, genre, average user rating for that movie and its rank in the respective genre based on that average rating in descending order 
  (so that the best movies will be shown first).
  */
  
  SELECT
  title,
  genre,
  AVG(rating),
  RANK() OVER(
    PARTITION BY genre
    ORDER BY AVG(rating) DESC)
FROM movie m
JOIN review r
  ON m.id = r.movie_id
GROUP BY title, genre;

-- Ranking of platforms
-- For each platform, show the following columns: 
-- platform, sum of subscription payments for that platform and its rank based on that sum (the platform with the highest sum should get the rank of 1)
SELECT
  platform,
  SUM(payment_amount),
  RANK() OVER(ORDER BY SUM(payment_amount) DESC)
FROM subscription
GROUP BY platform;

-- Grouping by ntiles
-- Divide subscriptions into three groups (buckets) based on the payment_amount. Group the rows based on those buckets. Show the following columns: 
-- bucket, minimal payment_amount in that bucket and maximal payment_amount in that bucket.

-- SECTION 9
-- 1. For each doctor, show first_name, last_name, age and the average age of all doctors.
SELECT DISTINCT
  first_name,
  last_name,
  age,
  avg(age) OVER()
FROM doctor;

-- 2. For each procedure, show its id, category, price and the total sum of prices from all procedures in the same category.
SELECT
  id,
  category,
  price,
  sum(price) OVER(PARTITION BY category)
FROM procedure1;

-- Question 3
-- For each procedure, show its name, the first and last name of the doctor, 
-- the score and the rank of the procedure in its category based on its score. The best procedure should get rank = 1. Allow multiple procedures with the same rank and gaps in numbering.
SELECT
  name,
  first_name,
  last_name,
  score,
  RANK() OVER(PARTITION BY category ORDER BY score DESC)
FROM doctor
JOIN procedure1
  ON doctor.id = procedure1.doctor_id;
  
  -- Question 4
  -- For the third most expensive procedure ever, show the following information: doctor_id, name, procedure_date and price.
WITH ranked_procedures AS (
  SELECT 
    doctor_id, 
    name, 
    procedure_date, 
    price, 
    RANK() OVER (ORDER BY price DESC) AS price_rank
  FROM procedure1
)
SELECT doctor_id, name, procedure_date, price
FROM ranked_procedures
WHERE price_rank = 3;

-- Question 5
/*
For each procedure, show the following information: procedure_date, doctor_id, category, name, score and the average score from the procedures in the same category which are included in the following window frame: 
two previous rows, current row, three following rows in terms of the procedure date.
*/
SELECT
  procedure_date,
  doctor_id,
  category,
  name,
  score,
  AVG(score) OVER(
    PARTITION BY category
    ORDER BY procedure_date
    ROWS BETWEEN 2 PRECEDING AND 3 FOLLOWING)
FROM procedure1;

-- Question 6
-- For each procedure, show the following information: procedure_date, category, doctor_id, patient_id, name, price and the total sum of prices from all procedures from the first day until the end of the current day.
SELECT
  procedure_date,
  category,
  doctor_id,
  patient_id,
  name,
  price,
  SUM(price) OVER(
    ORDER BY procedure_date
    RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
FROM procedure1;

-- Question 7
-- For each procedure, show the following information: id, procedure_date, name, price, price of the previous procedure (in terms of the id) and the difference between these two values. Name the last two columns previous_price and difference
SELECT
  id,
  procedure_date,
  name,
  price,
  LAG(price) OVER(ORDER BY id) AS previous_price,
  price - LAG(price) OVER(ORDER BY id) AS difference
FROM procedure1;

-- Question 8
/*
For each procedure, show the following information: procedure_date, name, price, the procedure_date of the newest procedure in the same category together with its price. The newest procedure is the procedure with the greatest ID. 
Show the last two colums as most_recent_date and most_recent_price.
*/
SELECT
  procedure_date,
  name,
  price,
  LAST_VALUE(procedure_date) OVER(
    PARTITION BY category
    ORDER BY id
    ROWS BETWEEN UNBOUNDED PRECEDING
      AND UNBOUNDED FOLLOWING) AS most_recent_date,
  LAST_VALUE(price) OVER(
    PARTITION BY category
    ORDER BY id
    ROWS BETWEEN UNBOUNDED PRECEDING
      AND UNBOUNDED FOLLOWING) AS most_recent_price
FROM procedure1;

-- Question 9
-- For each procedure, show the name, score, price, category, the average price in its category (as avg_price), the average score in its category (as avg_score) and its rank in the category based on its score (procedure with the highest score should get rank 1). 
-- Multiple procedures may share the same rank, but don't allow gaps in numbering.
SELECT
  name,
  score,
  price,
  category,
  AVG(price) OVER(PARTITION BY category) AS avg_price,
  AVG(score) OVER(PARTITION BY category) AS avg_score,
  DENSE_RANK() OVER(PARTITION BY category ORDER BY score DESC)
FROM procedure1;

-- Question 10
-- For each procedure, show the following information: procedure_date, name, price, category, score, the price of the best procedure (in terms of the score) from the same category (column best_procedure) 
-- and the difference between price and best_procedure (column difference).

-- Question 11
/*Find out which doctor is the best for each procedure.
For each procedure select procedure name and the first and last name of all doctors who got high scores 
(higher than or equal to average score for this procedure) the most often (rank = 1).
*/
WITH cte AS (
  SELECT
    name,
    first_name,
    last_name,
    COUNT(*) c,
    RANK() OVER(PARTITION BY name ORDER BY COUNT(*) DESC) AS ranking
  FROM procedure1 p 
  JOIN doctor d
    ON p.doctor_id = d.id
  WHERE score >= (SELECT avg(score) FROM procedure1 pl WHERE pl.name = p.name)
  GROUP BY name, first_name, last_name
)

SELECT 
  name,
  first_name,
  last_name
FROM cte
WHERE ranking = 1
