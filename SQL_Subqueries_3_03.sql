-- Lab | SQL Subqueries 3.02/3.03

-- 1. How many copies of the film Hunchback Impossible exist in the inventory system?
-- tables needed: film to return film_id, table inventory to retrieve the copies

SELECT count(*)
FROM sakila.inventory
WHERE film_id = (SELECT film_id FROM sakila.film WHERE title = 'Hunchback Impossible')
;

-- 2. List all films whose length is longer than the average of all the films.
-- tables needed: film
-- variable needed: avg(length)
SELECT film_id, title, length
FROM sakila.film
WHERE length > (SELECT avg(length) as avg_length FROM sakila.film)
ORDER BY length ASC;

-- 3. Use subqueries to display all actors who appear in the film Alone Trip.
-- query needed: actor_id from 
SELECT first_name, last_name
FROM sakila.actor
WHERE actor_id IN (
SELECT fa.actor_id
FROM sakila.film_actor AS fa
JOIN sakila.film f ON fa.film_id = f.film_id
WHERE f.title = 'Alone Trip')
;

-- 4. Sales have been lagging among young families, and you wish to target all family 
-- movies for a promotion. Identify all movies categorized as family films.
-- Interprestation of this question: listing of all the family films
-- and the higher the rental rate, the higher the discount: 4.99 -> 2.99 and 2.99 -> 1.99
-- tables needed: category / film_category / film
SELECT f.title, rental_rate AS normal_price, IF(rental_rate = 4.99, 2.99, IF(rental_rate = 2.99, 1.99, rental_rate)) AS action_price
FROM sakila.film_category AS fc
JOIN sakila.film f ON fc.film_id = f.film_id
JOIN sakila.category c ON fc.category_id = c.category_id
WHERE c.name = 'Family';

-- 5. Get name and email from customers from Canada using subqueries. Do the same with joins. 
-- Note that to create a join, you will have to identify the correct tables with their primary 
-- keys and foreign keys, that will help you get the relevant information.
-- Join solution, tables required: country, city, adress, customer
SELECT cu.first_name, cu.last_name, cu.email  
FROM sakila.customer AS cu
JOIN sakila.address a ON cu.address_id = a.address_id 
JOIN sakila.city ci ON a.city_id = ci.city_id
JOIN sakila.country co ON ci.country_id = co.country_id
WHERE country = 'Canada';
-- now with subqueries
SELECT first_name, last_name, email  
FROM sakila.customer
WHERE address_id IN (SELECT address_id FROM sakila.address
WHERE city_id IN (SELECT city_id FROM sakila.city
WHERE country_id = (SELECT country_id FROM sakila.country WHERE country = 'Canada')));

-- 6. Which are films starred by the most prolific actor? Most prolific actor is defined as 
-- the actor that has acted in the most number of films. First you will have to find the most 
-- prolific actor and then use that actor_id to find the different films that he/she starred.
SELECT first_name, last_name, title 
FROM sakila.actor
JOIN sakila.film_actor
USING(actor_id)
JOIN sakila.film
USING(film_id)
WHERE actor_id = (
SELECT sub1.actor_id as prol_id FROM (
SELECT MAX(actor_id) as actor_id, count(*) AS count FROM sakila.film_actor AS fa
GROUP BY fa.film_id
ORDER BY count DESC
LIMIT 1) sub1)
;

-- 7. Films rented by most profitable customer. You can use the customer table and payment 
-- table to find the most profitable customer ie the customer that has made the largest sum of payments
SELECT f.title, r.customer_id 
FROM sakila.rental AS r
JOIN sakila.inventory AS i
USING(inventory_id)
JOIN sakila.film AS f
USING(film_id)
WHERE r.customer_id = (
SELECT sub1.customer_id FROM (
SELECT p.customer_id, SUM(p.amount)
FROM sakila.payment AS p
GROUP BY p.customer_id 
ORDER BY SUM(p.amount) DESC
LIMIT 1) sub1)
;

-- 8. Customers who spent more than the average payments.
SELECT customer_id, first_name, last_name, spend FROM (
SELECT customer_id, AVG(amount) as spend
FROM sakila.payment
GROUP BY customer_id) sub1
JOIN sakila.customer
USING(customer_id)
WHERE spend > (SELECT AVG(amount) FROM sakila.payment)
;
