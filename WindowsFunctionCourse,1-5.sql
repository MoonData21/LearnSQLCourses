# WINDOW FUNCTIONS COURSE

# Quiz – Question 2
# Show the name of each dog along with the first and last name of its owner.
SELECT
  name,
  first_name,
  last_name
FROM dog
JOIN person
  ON person.id = dog.owner_id;
  
# Quiz – Question 3
# For each owner, show their id AS dog_owner_id and the number of dogs they have.
SELECT
  person.id AS dog_owner_id,
  COUNT(dog.id)
FROM person
JOIN dog
  ON person.id = dog.owner_id
GROUP BY person.id;

# Quiz – Question 4
# Show each breed with the average age of the dogs of that breed. 
# Do not show breeds where the average age is lower than 5.
select breed, avg(age) from dog
group by breed
having avg(age) >= 5;

# Window function - It is a function that performs calculations across a set of table rows. The rows are somehow related to the current row.
# For example, with window functions you can compute sum of values in the current row, one before and one after,
# OVER() – first example
# The most basic example is OVER() and means that the window consists of all rows in the query.
SELECT
  first_name,
  last_name,
  salary,  
  SUM(salary) OVER()
FROM employee;
# The average price of all items.
select 
	item, 
    price, 
    avg(price) Over() 
from purchase;

# Computations with OVER()
# Typically, OVER() is used to compare the current row with an aggregate.
# For each employee in table employee, select first and last name, years_worked, average of years spent in the company by all employees, and the difference between the years_worked and the average as difference.
SELECT
  first_name,
  last_name,
  years_worked,
  AVG(years_worked) OVER(),
  years_worked - AVG(years_worked) OVER() as difference
FROM employee;

/*For all employees from department with department_id = 3, show their:
first_name,
last_name,
salary,
the difference of their salary to the average of all salaries in that department as difference.
*/
SELECT
  first_name,
  last_name,
  salary,
  salary - AVG(salary) OVER() as difference
FROM employee
where department_id = 3;

# OVER() and COUNT()
# For each employee that earns more than 4000, show their first_name, last_name, salary and the number of all employees who earn more than 4000.
SELECT
  first_name,
  last_name,
  salary,
  Count(id) OVER()
FROM employee
where salary > 4000;

# Practice 1
SELECT
  id,
  department_id,
  item,
  price,
  MAX(price) OVER() AS max,
  MAX(price) OVER() - price AS difference
FROM purchase
WHERE department_id = 3;
# Practice 2
# For each purchase from any department, show its id, item, price, average price and the sum of all prices in that table.
select id, item, price, 
  avg(price) over(),
  sum(price) over()
from purchase;

# Range of OVER()
# Show the first_name, last_name and salary of every person who works in departments with id 1, 2 or 3, along with the average salary calculated in those three departments.
SELECT
  first_name,
  last_name,
  salary,
  AVG(salary) OVER()
FROM employee
WHERE department_id in (1,2,3);

# OVER and WHERE
# You cannot put window functions in WHERE
/*
Use <window_function> OVER() to compute an aggregate for all rows in the query result.
The window functions is applied after the rows are filtered by WHERE.
The window functions are used to compute aggregates but keep details of individual rows at the same time.
You can't use window functions in WHERE clauses.
*/
# Exercise 1
select 
first_name, last_name, years_worked,
avg(years_worked) over()
from employee
where department_id = 1 
OR department_id = 3
OR department_id = 5;

# Exercise 2
select purchase.id, name, item, price,
min(price) over (),
price - min(price) over ()
from purchase
join department 
on department.id = purchase.department_id;

# PARTITION BY
SELECT
  id,
  model,
  first_class_places,
  SUM(first_class_places) OVER (PARTITION BY model)
FROM train;

# Show the id of each journey, its date and the number of journeys that took place on that date.
select id, date,
count(id) over(partition by date)
from journey;

# Range of OVER(PARTITION BY)
# Show id, model,first_class_places, second_class_places, and the number of trains of each model with more than 30 first class places and more than 180 second class places.
SELECT
  id,
  model,
  first_class_places,
  second_class_places,
  COUNT(id) OVER (PARTITION BY model)
FROM train
WHERE first_class_places > 30
  AND second_class_places > 180;
  
# PARTITION BY MULTIPLE COLUMNS
# Show the id of each journey, the date on which it took place, the model of the train that was used, 
# the max_speed of that train and the highest max_speed from all the trains that ever went on the same route on the same day.
SELECT
  journey.id,
  date,
  model,
  max_speed,
  MAX(max_speed) OVER(PARTITION BY route_id, date)
FROM train
JOIN journey
ON train.id = journey.train_id;

# OVER(PARTITION BY) – practice 1
# For each journey, show its id, the production_year of the train on that journey, the number of journeys the train took and the number of journeys on the same route.
SELECT
  journey.id,
  train.production_year,
  COUNT(journey.id) OVER(PARTITION BY train_id),
  COUNT(journey.id) OVER(PARTITION BY route_id)
FROM train
JOIN journey
ON train.id = journey.train_id;

# OVER(PARTITION BY) – practice 2
SELECT
  t.id,
  t.price,
  j.date,
  AVG(t.price) OVER(PARTITION BY j.date),
  COUNT(t.id) OVER(PARTITION BY j.date)
FROM ticket t
JOIN journey j
ON j.id = t.journey_id
WHERE j.train_id != 5;

# practice 3
# For each ticket, show its id, price and, the column named ratio. 
# The ratio is the ticket price to the sum of all ticket prices purchased on the same journey.
SELECT
  id,
  price,
  price / SUM(price) OVER (PARTITION BY journey_id) AS ratio
FROM ticket;

/* Postgres answer
SELECT
  id,
  price,
  price::numeric / SUM(price) OVER(PARTITION BY journey_id) as ratio
FROM ticket; 
*/ 
/* OR THIS WAY WILL WORK AS WELL
SELECT
  id,
  price,
  CAST(price AS numeric) / SUM(price) OVER(PARTITION BY journey_id) as ratio
FROM ticket; 
*/

# Summary - OVER(PARTITION BY x) works in a similar way to GROUP BY, defining the window as all the rows in the query result that have the same value in x.
# x can be a single column or multiple columns separated by commas.

# Quiz
select first_name, last_name, department, salary,
Min(salary) OVER(PARTITION BY department),
MAX(salary) OVER(PARTITION BY department)
from employee;
/*
select first_name, last_name, department, salary,
CAST(salary AS numeric) / SUM(salary) OVER (PARTITION BY department)
from employee;
*/
# Ranking functions 
# [ranking function] OVER (ORDER BY [order by columns])

SELECT
  name,
  platform,
  editor_rating,
  RANK() OVER(ORDER BY editor_rating)
FROM game;

# RANK() will always leave gaps in numbering when more than 1 row share the same value.

# For each game, show name, genre, date of update and its rank. The rank should be created with RANK() and take into account the date of update.
SELECT
  name,
  genre,
  updated,
  RANK() OVER(ORDER BY updated)
FROM game;

# DENSE_RANK()
SELECT
  name,
  platform,
  editor_rating,
  DENSE_RANK() OVER(ORDER BY editor_rating)
FROM game;
# DENSE_RANK gives a 'dense' rank indeed, i.e. there are no gaps in numbering.
# Use DENSE_RANK() and for each game, show name, size and the rank in terms of its size.
SELECT
  name,
  size,
  DENSE_RANK() OVER(ORDER BY size)
FROM game;

# ROW_NUMBER()
# Now, each row gets its own, unique rank number, so even rows with the same value get consecutive numbers.
# When you execute ROW_NUMBER(), you never really know what the output will be.
# The order is nondeterministic
SELECT
  name,
  platform,
  editor_rating,
  ROW_NUMBER() OVER(ORDER BY editor_rating)
FROM game;
# Use ROW_NUMBER() and for each game, show their name, date of release and the rank based on the date of release.
SELECT
  name,
  released,
  ROW_NUMBER() OVER(ORDER BY released)
FROM game;
# RANK(), DENSE_RANK(), ROW_NUMBER()
SELECT
  name,
  genre,
  released,
  RANK() OVER(ORDER BY released),
  DENSE_RANK() OVER(ORDER BY released),
  ROW_NUMBER() OVER(ORDER BY released)
FROM game;

# RANK() OVER(ORDER BY ... DESC)
# Show the latest games from the studio
SELECT
  name,
  genre,
  released,
  DENSE_RANK() OVER(ORDER BY released DESC)
FROM game;

# RANK() / ROW_NUMBER with ORDER BY many columns
# We want to find games which were both recently released and recently updated with ROW_NUMBER
SELECT
  name,
  released,
  updated,
  ROW_NUMBER() OVER(ORDER BY released DESC, updated DESC)
FROM game;

# Ranking and ORDER BY
# For each game find its name, genre, its rank by size. 
# Order the games by date of release with newest games coming first.
SELECT
  name,
  genre,
  RANK() OVER (ORDER BY size)
FROM game
ORDER BY released DESC;

# For each purchase, find the name of the game, the price, and the date of the purchase. 
# Give purchases consecutive numbers by date when the purchase happened, so that the latest purchase gets number 1. 
# Order the result by editor's rating of the game.
SELECT
  name,
  price,
  date,
  ROW_NUMBER() OVER(ORDER BY date DESC)
FROM purchase, game
WHERE game.id = game_id
ORDER BY editor_rating;
# OR
SELECT
  g.name,
  p.price,
  p.date,
  ROW_NUMBER() OVER (ORDER BY p.date DESC)
FROM game g
  JOIN purchase p
  ON p.game_id = g.id
ORDER BY g.editor_rating;

# NTILE(X) It distributes the rows into a specific number of groups, provided as X.
# We want to divide games into 4 groups with regard to their size, with biggest games coming first. For each game, show its name, genre, size and the group it belongs to.
SELECT
  name,
  genre,
  size,
  NTILE(4) OVER (ORDER BY size DESC)
FROM game;

# Split the games into 5 groups based on their date of last update. 
SELECT
  name,
  genre,
  updated,
  NTILE(5) OVER (ORDER BY updated DESC)
FROM game;

# Create the ranking
SELECT
  name,
  RANK() OVER(ORDER BY editor_rating DESC)
FROM game;

# What is the name of the game with rank 2 in terms of best editor_rating
# CTE
WITH ranking AS (
  SELECT 
    name, 
    RANK() OVER (ORDER BY editor_rating DESC) AS editor_ranking
  FROM game
) 
SELECT name 
FROM ranking 
WHERE editor_ranking = 2;

# Sub-query
SELECT name
FROM (
  SELECT 
    name, 
    RANK() OVER (ORDER BY editor_rating DESC) AS ranking
  FROM game
) AS ranked_games
WHERE ranking = 2;

# Practice 1: Find the name, genre and size of the smallest game in our studio.
WITH ranking AS (
  SELECT
    name,
    genre,
    size,
    RANK() OVER(ORDER BY size) AS siz_ranking
  FROM game
)

SELECT
  name,
  genre,
  size
FROM ranking
WHERE size_ranking = 1;

# Practice 2: Show the name, platform and update date of the second most recently updated game.
WITH ranking AS (
  SELECT
    name,
    platform,
    updated,
    RANK() OVER(ORDER BY updated DESC) AS updated_rank
  FROM game
)

SELECT
  name,
  platform,
  updated
FROM ranking
WHERE updated_rank = 2;

# Summary
WITH ranking AS
  (SELECT
    RANK() OVER (ORDER BY col2) AS RANK2,
    col1
  FROM table_name)

SELECT col1
FROM ranking
WHERE RANK2 = place1;

# Exercise 1
# For each application, show its name, average_rating and its rank, with best rated apps coming first.
SELECT
  name,
  average_rating,
  RANK() OVER(ORDER BY average_rating Desc)
FROM application;

# Exercise 2
# Find the application that ranked 3rd in terms of the greatest number of downloads. 
# Show its name and the number of downloads.
WITH ranking AS
  (SELECT
  	name,
  	downloads,
    RANK() OVER (ORDER BY downloads DESC) AS DOWNLOAD_RANK
  FROM application)

SELECT name, downloads
FROM ranking
WHERE DOWNLOAD_RANK = 3;

# Window Frames
SELECT
  id,
  total_price,
  SUM(total_price) OVER(ORDER BY placed ROWS UNBOUNDED PRECEDING)
FROM single_order;

# In the above query, we sum the column total_price. For each row, we add the current row AND all the previously introduced rows (UNBOUNDED PRECEDING) to the sum. 
# As a result, the sum will increase with each new order.

# Window frame definition
SELECT
  id,
  total_price,
  SUM(total_price) OVER(ORDER BY placed ROWS UNBOUNDED PRECEDING) AS running_total,
  SUM(total_price) OVER(ORDER BY placed ROWS BETWEEN 3 PRECEDING and 3 FOLLOWING) AS sum_3_before_after
FROM single_order
ORDER BY placed;

# Take a look at the example on the right. The query computes:
# The total price of all orders placed so far (this kind of sum is called a running total),
# The total price of the current order, 3 preceding orders and 3 following orders.

# First exercise
SELECT
  id,
  placed,
  COUNT(id) OVER(
    ORDER BY placed
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
FROM single_order;
# For each order, show its id, the placed date, 
# and the third column which will count the number of orders up to the current order when sorted by the placed date.

# Rows – exercise 1
SELECT
  id,
  product_id,
  quantity,
  SUM(quantity) OVER(
    ORDER BY id
    ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)
FROM order_position
WHERE order_id = 5;

# Rows – exercise 2
# For each product, show its id, name, introduced date and the count of products introduced up to that point.
SELECT
  id,
  name,
  introduced,
  COUNT(name) OVER (
    ORDER BY introduced
    RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  )
FROM product;

# Rows – exercise 3
# Now, for each single_order, show its placed date, total_price, the average price calculated by taking 2 previous orders, 
# The current order and 2 following orders (in terms of the placed date) and the ratio of the total_price to the average price calculated as before.
SELECT
  placed,
  total_price,
  AVG(total_price) OVER(ORDER BY placed ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING),
  total_price / AVG(total_price) OVER(ORDER BY placed ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) as Ratio
FROM single_order;

# Abbreviations
# ROWS UNBOUNDED PRECEDING means BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
# ROWS n PRECEDING means BETWEEN n PRECEDING AND CURRENT ROW
# ROWS CURRENT ROW means BETWEEN CURRENT ROW AND CURRENT ROW

# You will now have a chance to practice abbreviations. Pick those stock changes which refer to product_id = 3. 
# For each of them, show the id, changed date, quantity, and the running total, indicating the current stock status. 
# Sort the rows by the changed date in the ascending order.
SELECT
  id,
  changed,
  quantity,
  SUM(quantity) OVER(ORDER BY changed ROWS UNBOUNDED PRECEDING)
FROM stock_change
where product_id = 3;

# For each single_order, show its placed date, total_price and the average price from the current single_order and three previous orders (in terms of the placed date).
SELECT
  placed,
  total_price,
  avg(total_price) OVER(ORDER BY placed ROWS BETWEEN 3 PRECEDING AND CURRENT ROW)
FROM single_order;

# RANGE explained
# Modify the example so that it shows the average total_price for single days for each row.
SELECT
  id,
  placed,
  total_price,
  AVG(total_price) OVER(ORDER BY placed RANGE CURRENT ROW)
FROM single_order;
# id	placed	total_price	avg
# 5	2016-06-13	602.03	2287.1633333333333333
# 6	2016-06-13	3599.83	2287.1633333333333333

/* ROWS and RANGE – explanation
The difference between ROWS and RANGE is similar to the difference between the ranking functions ROW_NUMBER and RANK()
The query with ROWS sums the total_price for all rows which have their ROW_NUMBER less than or equal to the row number of the current row.
The query with RANGE sums the total_price for all rows which have their RANK() less than or equal to the rank of the current row.
*/
# Boundaries with RANGE
# For each stock_change with product_id = 7, show its id, quantity, 
# changed date and another column which will count the number of stock changes with product_id = 7 on that particular date.
SELECT
  id,
  quantity,
  changed,
  count(id) OVER(ORDER BY changed RANGE CURRENT ROW)
FROM stock_change
where product_id = 7;
# Ex.1
# For each stock_change, show id, product_id, quantity, changed date, and the total quantity change from all stock_change for that product.
SELECT
  id,
  product_id,
  quantity,
  changed,
  sum(quantity) OVER(ORDER BY product_id RANGE CURRENT ROW)
FROM stock_change;
# Ex. 2
# For each stock_change, show its id, changed date, and the number of any stock changes that took place on the same day or any time earlier.
SELECT
  id,
  changed,
  count(id) OVER(ORDER BY changed RANGE UNBOUNDED PRECEDING)
FROM stock_change;
# Ex. 3
# Our finance department needs to calculate future cashflows for each date. 
# Let's help them. In order to do that, we need to show each order: its id, placed date, total_price and the total sum of all prices of orders from the very same day or any later date.
SELECT
  id,
  placed,
  total_price,
  sum(total_price) OVER(ORDER BY placed RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)
FROM single_order;

# Default window frame – without ORDER BY
/*SELECT
id,
placed,
total_price,
sum (total_price) OVER()
from single_order;
*/
# Default window frame – with ORDER BY
/*SELECT
id,
placed,
total_price,
sum (total_price) OVER(order by placed)
from single_order;
*/
# Exercise 1
# For each row from department with id = 2, show its department_id, year, 
# amount and the total amount from the current year + two previous years.
SELECT
  department_id,
  year,
  amount,
  SUM(amount) OVER(ORDER BY year ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
FROM revenue
where department_id=2;

# Exercise 2
# For each row from department with id = 1, show its department_id, year, 
# amount and the running average amount from all rows up to the current rows, sorted by the year.
SELECT
  department_id,
  year,
  amount,
  avg(amount) OVER(ORDER BY year RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
FROM revenue
where department_id=1;

# Exercise 3
# For each row sorted by the year, show its department_id, year, amount,
# the average amount from all departments in the given year and the difference between the amount and the average amount.
SELECT
  department_id,
  year,
  amount,
  AVG(amount) OVER (PARTITION BY year),
  amount - AVG(amount) OVER (PARTITION BY year)
FROM revenue
ORDER BY year;








