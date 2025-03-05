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
