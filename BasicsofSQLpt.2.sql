#Sort the rows – ORDER BY

select * from employees
order by salary;

#ORDER BY with conditions
select * from employees 
where year = 2011
order by salary;

#Ascending and descending orders
select * from employees
order by last_name desc;

#Sort by a few columns
select * from employees
order by department asc, salary desc;

# Select distinctive values & distinctive values in certain columns
select distinct year from employees;

select distinct department, position from employees;

# Count the rows, we'll just get the number of all rows in the table orders – and not their content.
select count(*) from employees;

# Count the rows, ignore the NULLS
# Check how many non-NULL values in the column position there are in the table employees. Name the column non_null_no.
select count(position) as non_null_no from employees;

# Count distinctive values in a column
# Count how many different positions there are in the table employees. Name the column distinct_positions
select count(distinct (position)) as distinct_positions from employees;

# Find the minimum and maximum value
select max(salary) from employees;

# Find the average value
select avg(salary) from employees
where year = 2013;

# Find the sum
select sum(salary) from employees
where department = 'Marketing' and year = 2014;

# Group the rows and count them
select department, count(*) as employees_no from employees
where year = 2013
group by department;

# Find min and max values in groups
# Show all departments together with their lowest and highest salary in 2014.
select department, min(salary), max(salary) from employees
where year = 2014
group by department;

# Find the average value in groups
# For each department find the average salary in 2015
select department, AVG(salary) from employees
where year = 2015
group by department;

# Group by a few columns
# Find the average salary for each employee. Show the last name, the first name, and the average salary. Group the table by the last name and the first name.
select last_name, first_name, AVG(salary) from employees
group by last_name, first_name;

# Filter groups - having clause
# Find such employees who (have) spent more than 2 years in the company. Select their last name and first name together with the number of years worked (name this column years).
SELECT
  last_name,
  first_name,
  COUNT(DISTINCT year) as years
FROM employees
GROUP BY last_name, first_name
HAVING COUNT(DISTINCT year) > 2;

# Find such departments where the average salary in 2012 was higher than $3,000. Show the department name with the average salary.
select department, avg(salary) from employees
where year = 2012
group by department
having avg(salary) > 3000;

# Order groups
# Sort the employees according to their summary salaries. Highest values should appear first. Show the last name, the first name, and the sum.
select last_name, first_name, sum(salary) from employees
group by last_name, first_name
order by sum(salary) desc;

# Combined Exercise
select last_name, first_name, avg(salary) as average_salary, count(distinct year) as years_worked from employees
group by last_name, first_name
having count(distinct year) > 2
order by avg(salary) desc;

# JOIN revised
select * from student
join room
on room_id = room.id;

select name, room_number from student
join room
on room_id = room.id;

# INNER JOIN & JOIN are the same
select 
	room.id AS room_id,
    room_number,
    beds,
    floor,
    equipment.id as equipment_id,
    name
from room
inner join equipment
	on room.id = equipment.room_id;
# INNER JOIN (or JOIN, for short) only shows those rows from the two tables where there is a match between the columns.
SELECT *
FROM equipment
INNER JOIN room
  ON equipment.room_id = room.id;
  
# LEFT JOIN: it returns all rows from the left table (the first table in the query) plus all matching rows from the right table (the second table in the query).
select * from student
left join room
on student.room_id = room.id; 

select * from equipment
left join room
on equipment.room_id = room.id;

#RIGHT JOIN: it returns all rows from the right table (the second table in the query) plus all matching rows from the left table (the first table in the query).
SELECT *
FROM student
RIGHT JOIN room
  ON room.id = student.room_id;

SELECT *
FROM room
RIGHT JOIN student
  ON room.id = student.room_id;

# FULL JOIN returns all rows from both tables and combines the rows when there is a match.
SELECT *
FROM car
FULL JOIN person
  ON car.owner_id = person.id;
  
# LEFT JOIN, RIGHT JOIN, and FULL JOIN are also shortcuts. They are all actually OUTER JOINS: LEFT OUTER JOIN, RIGHT OUTER JOIN, and FULL OUTER JOIN. 
# You can add the keyword OUTER and the results of your queries will stay the same.
SELECT *
FROM room
RIGHT OUTER JOIN equipment
  ON room.id = equipment.room_id
WHERE equipment.name = 'kettle';

# NATURAL JOIN doesn't require column names because it always joins the two tables on the columns with the same name.
select * from student
natural join room;

# Table aliases
SELECT
  e.id,
  e.name,
  r.room_number,
  r.beds
FROM equipment AS e
INNER JOIN room AS r
  ON e.room_id = r.id;
  
# Aliases in self-joins
# We want to know who lives with the student Jack Pearson in the same room. 
# Use self-joining to show all the columns for the student Jack Pearson together with all the columns for each student living with him in the same room.
select * from student as s1
join student as s2
on s1.room_id = s2.room_id
where s1.name = 'Jack Pearson'
and s1.id <> s2.id;

# Joining more tables
/* The challenge is as follows: for each room with 2 beds where there actually are 2 students, 
we want to show one row which contains the following columns:

the name of the first student.
the name of the second student.
the room number.
*/
# A small hint: in terms of SQL, "first in the alphabet" means "smaller than" for text values.
SELECT
  st1.name,
  st2.name,
  room_number
FROM student st1
JOIN student st2
  ON st1.room_id = st2.room_id
JOIN room
  ON st1.room_id = room.id
WHERE st1.name < st2.name AND beds = 2;

# Subqueries:
# Show all information about all cities which have the same area as Paris.
SELECT *
FROM city
WHERE area = (
  SELECT
    area
  FROM city
  WHERE name = 'Paris'
);
# Subqueries with various logical operators
# Find the names of all cities which have a population lower than Madrid.
SELECT name
FROM city
WHERE population < (
  SELECT population
  FROM city
  WHERE name = 'Madrid'
);
# Subqueries with functions
# Find all information about trips whose price is higher than the average.
SELECT *
FROM trip
WHERE price > (
  SELECT AVG(price)
  FROM trip
);
# The operator IN
# Find all information about hiking trips with difficulty 1, 2, or 3.
SELECT *
FROM hiking_trip
WHERE difficulty IN (1, 2, 3);

# The operator IN with subqueries
# Find all information about all trips in cities whose area is greater than 100.
SELECT *
FROM trip
WHERE city_id IN (
  SELECT id
  FROM city
  WHERE area > 100
);
# The operator ALL- You can also use ALL with other logical operators: = ALL, != ALL, < ALL, <= ALL, >= ALL
# Find all information about the cities which are less populated than all countries in the database.
SELECT *
FROM city
WHERE population < ALL (
  SELECT population
  FROM country
);
# The operator ANY
# Find all information about all the city trips which have the same price as any hiking trip.
SELECT *
FROM trip
WHERE price = ANY (
  SELECT price
  FROM hiking_trip
);
# Learn subqueries which are dependent on the main query. They are called correlated subqueries.
# Just remember the golden rule: subqueries can use tables from the main query, but the main query can't use tables from the subquery!
# Let's check if the database contains any errors in a sample exercise. 
# Find all information about each country whose population is equal to or smaller than the population of the least populated city in that specific country.
 
SELECT *
FROM country
WHERE population <= (
  SELECT MAX(population)
  FROM city
  WHERE city.country_id = country.id
);

# Aliases for tables
# Find all information about cities with a rating higher than the average rating for all cities in that specific country.
SELECT *
FROM city main_city
WHERE rating > (
  SELECT AVG(rating)
  FROM city average_city
  WHERE average_city.country_id = main_city.country_id
);

# The operator IN with correlated subqueries
# Show all information about all trips to cities where the ratio of city area to trip duration (in days) is greater than 700.
SELECT *
FROM trip
WHERE city_id IN (
  SELECT id
  FROM city
  WHERE area/days > 700
);

# The operator EXISTS
# Select all countries where there is at least one mountain.
select * from country
where exists (
  select * 
  from mountain
  where country_id = country.id);

# The operator EXISTS with NOT
# Select all mountains with no hiking trips to them.
select * from mountain
where not exists (
  select * from hiking_trip
  where mountain_id = mountain.id);
  
#The operator ALL in correlated subqueries
#Select the hiking trip with the longest distance (column length) for every mountain.
select * from hiking_trip longest_trip
where length >= all (
  select length 
  from hiking_trip sub_trip
  where longest_trip.mountain_id = sub_trip.mountain_id);
  
# The operator ANY in correlated subqueries
# Select those trips which last shorter than any hiking_trip with the same price.
select * from trip
where days < Any (
  select days from hiking_trip
  where hiking_trip.price = trip.price);

# Subqueries in the FROM clause
# Show mountains together with their countries. The countries must have at least 50,000 residents.
SELECT *
FROM mountain, (
    SELECT
      *
    FROM country
    WHERE population >= 50000) AS crowdy_country
WHERE crowdy_country.id = mountain.country_id;

# Subqueries in the FROM clause
# Show hiking trips together with their mountains. 
# (The mountains must be at least 3,000ft high. Select only the columns length and height)
SELECT
  length,
  height
FROM hiking_trip h, (
    SELECT
      *
    FROM mountain
    WHERE height >= 3000) AS high_mountain
WHERE high_mountain.id = h.mountain_id;

# Subqueries in the SELECT clause
# Show each mountain name together with the number of hiking trips to that mountain (name the column count).
select name,
(select count(*)
 from hiking_trip
 where mountain_id = mountain.id) AS count
 from mountain;
 
 # How UNION works
 # It combines results of two or more queries.
SELECT *
FROM cycling
WHERE year between 2010 and 2014
UNION
SELECT *
FROM skating
WHERE year between 2010 and 2014;

# Both tables must have the same number of columns so that the results can be merged into one table.
# The respective columns must have the same kind of information: number or text.

# By default, UNION removes duplicate rows. Luckily, we can change this. Just put UNION ALL instead of UNION
SELECT country
FROM cycling
UNION ALL
SELECT country
FROM skating;

# How INTERSECT works
# Well, UNION gave you all the results from the first query PLUS the results from the second query. 
# INTERSECT, on the other hand, only shows the rows which belong to BOTH tables.
# Find names of each person who has medals both in cycling and in skating.
/*
SELECT person
FROM cycling
INTERSECT
SELECT person
FROM skating;
*/
# How EXCEPT works
# It shows all the results from the first (left) table with the exception of those that also appeared in the second (right) table.
# Find all the countries which have a medal in cycling but not in skating.
/*
select country from cycling
except
select country from skating;
*/
# MINUS instead of EXCEPT
# Find all the years when there was at least one medal in skating but no medals in cycling. Use the keyword MINUS.
/*
select year from skating
minus
select year from cycling;
*/

# Main excercises
# Task 1 – Selecting rows from one table
# Select all columns from horoscopes for Pisces and Aquarius from the years 2010 to 2014.
SELECT *
FROM horoscope
WHERE sign in ('Pisces', 'Aquarius') 
AND year BETWEEN 2010 and 2014;

# Task 2 – Selecting rows from multiple tables
# Show all pets (show the columns name, type, year_born) whose name begins with an 'M' together with their owners (the columns name, year_born).
SELECT
p.name,
p.type,
p.year_born AS pet_year_born,
o.name,
o.year_born AS owner_year_born
FROM pet p
JOIN owner o
ON p.owner_id = o.id
WHERE p.name LIKE 'M%';

# Task 3 – Aggregation and grouping
# Show students' names (column person) together with
# The number of essays they handed in (name the column number_of_essays).
# their average number of points (name the column avg_points).
# Show only those students whose average number of points is more than 80.

select person, count(*) as number_of_essays, avg(points) as avg_points from essay
group by person
having avg_points > 80;

# Task 4 – Sophisticated JOINs
# Show all coaches together with the players they train, show all columns for coaches and players. Show unemployed coaches with NULLs instead of player data.
select * from coach
left join player 
on player.id = coach.player_id;

# Task 5 – Subqueries
# Show all columns for the prisons where there is at least one prisoner above 50 years of age.
SELECT *
FROM prison
WHERE EXISTS (
  SELECT
    *
  FROM prisoner
  WHERE prison.id = prisoner.prison_id
    AND age > 50
);
# Task 6 – Set operations
# Show all columns for the products which are gluten free and vegetarian at the same time.
/*
SELECT *
FROM vegetarian_product
INTERSECT
SELECT *
FROM gluten_free_product;
*/

# Task 7 – Challenge
/*
The owner of the shop would like to see each customer's
id (name the column cus_id).
name (name the column cus_name).
id of their latest purchase (name the column latest_purchase_id).
the total quantity of all flowers purchased by the customer, in all purchases, not just the last purchase (name the column all_items_purchased).
*/
SELECT C.id AS cus_id, C.name AS cus_name, MAX(P.id) AS latest_purchase_id, SUM(I.quantity) AS all_items_purchased
FROM customer C
INNER JOIN purchase P
ON P.customer_id = C.id
INNER JOIN purchase_item I
ON I.purchase_id = P.id
GROUP BY cus_id
