# SQL Basics Course SQL File
# A semicolon is like a period at the end of the sentence. It tells the database that you're done with your command.

SELECT *
FROM car;

# Select one column
select brand from car;

# Select many columns
select model, price from car;

#We've added WHERE and a condition.
select * from car where production_year = 1999;

/*
Conditional operators are:
< (less than),
> (greater than),
<= (less than or equal),
>= (greater than or equal).
*/
select * from car where price > 10000;

#The not equal sign (!=)
select * from car where production_year != 1999;

#Conditional operators and selecting columns
select brand, model, production_year from car where price <= 11300; 

#Logical operators – OR, using conditional operators: =, !=, <, >, <=, >=
select vin from car 
where production_year<2005 
OR price<10000;

#Logical operators – AND
select vin from car 
where production_year > 1999 
and price < 7000;

#The BETWEEN operator
#Instead of:
SELECT id, name
FROM user
WHERE age <= 70
  AND age >= 13;
# Use this:
select vin, brand, model from car 
where production_year between 1995 AND 2005;

#Logical operators – NOT
select vin, brand, model from car 
where production_year NOT BETWEEN 1995 AND 2005;

#Join multiple conditions like this:
select vin from car 
where (production_year < 1999 or production_year > 2005) 
and (price < 4000 or price > 10000);

#Use text in where clauses:
select * from car where brand = 'Ford';

#Like operator, using the percentage sign %
select vin, brand, model from car 
where brand LIKE 'F%';  #Any starting with F will be populated

SELECT *
FROM user
WHERE name LIKE '%A%'; # The example above will select any user whose name contains at least one 'A'

select vin from car where model LIKE '%s'; # Select vin of all cars whose model ends with an s.

# The underscore sign _
SELECT *
FROM user
WHERE name LIKE '_atherine'; # The underscore sign (_) matches exactly one character. Whether it's Catherine or Katherine – the expression will return a row.

# Looking for NOT NULL values, we don't want NULL values in this query.
select * from car 
where price is not null;

# Looking for NULL values
select * from car 
where price is null;

# Comparisons with NULL- In no way does NULL equal zero. What's more, the expression NULL = NULL is never true in SQL!
select * from car where price >= 0;

# Basic mathematical operators- In this way, you can add (+), subtract (-), multiply (*) and divide (/) numbers.
select * from car 
where (price * 0.2) > 2000;
# Select all columns for cars with a tax amount over $2000. The tax amount for all cars is 20% of their price.
# Multiply the price by 0.2 to get the tax amount.

/*Select all columns of those cars that:
were produced between 1999 and 2005,
are not Volkswagens,
have a model that begins with either 'P' or 'F',
have their price set.
*/
SELECT *
FROM car
WHERE production_year BETWEEN 1999 AND 2005
  AND brand != 'Volkswagen'
  AND (model LIKE 'P%' OR model LIKE 'F%')
  AND price IS NOT NULL;
  
# The keyword JOIN, joining tables together
select * from movie 
JOIN director
ON movie.director_id = director.id;
# an inner join can either say INNER JOIN or just JOIN

#Displaying specific columns
select movie.title, director.name from movie 
join director 
on movie.director_id = director.id;  

# Refer to columns without table names
# Select director name and movie title from the movie and director tables in such a way that a movie is shown together with its director. 
# Don't write table names in the SELECT clause.
select title, name from movie 
join director 
on movie.director_id = director.id;
# Though if there are matching column names in the tables, movie.id & directior.id must be used instead

#Rename columns with AS
SELECT
  title as movie_title,
  name
FROM movie
JOIN director
  ON movie.director_id = director.id;
  
# Filter the joined tables
select * from movie
join director
on movie.director_id = director.id
where movie.production_year > 2000;

select * from movie
join director 
on movie.director_id = director.id
where director.name = 'Steven Spielberg';

# Excercise Code
select title, production_year, name, birth_year as born_in 
from movie 
join director on director_id = director.id
where (production_year - birth_year) < 40;

select movie.id, title, production_year as produced_in, name, birth_year as born_in 
from movie
join director 
on movie.director_id = director.id
where (title LIKE '%a%' and production_year > 2000)
OR (birth_year between 1945 and 1995);



