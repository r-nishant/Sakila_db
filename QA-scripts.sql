use sakila;

-- 1. Write a query to find the full name of the actor who has acted in the maximum number of movies.'

-- Sample Output:-
-- Full_name
-- PENELOPE GUINESS

SELECT distinct(concat(first_name, ' ', last_name)) Full_name
FROM actor INNER JOIN film_actor USING (actor_id)
WHERE actor_id = (SELECT actor_id FROM film_actor
				GROUP BY actor_id
                ORDER BY count(film_id) DESC
				LIMIT 1);

---------------------------------------------------------------------------------------------------------------------------
-- 2. Write a query to find the full name of the actor who has acted in the third most number of movies.

-- Sample Output:-
-- Actor_name
-- PENELOPE GUINESS

SELECT distinct(concat(first_name, ' ', last_name)) Actor_name
FROM actor INNER JOIN film_actor USING (actor_id)
WHERE actor_id = (SELECT actor_id FROM film_actor
				GROUP BY actor_id
                ORDER BY count(film_id) DESC
				LIMIT 2,1);
                
----------------------------------------------------------------------------------------------------------------------------
-- 3. Write a query to find the film which grossed the highest revenue for the video renting organisation.

-- Sample Output:-
-- title
-- ACADEMY DINOSAUR

'''SELECT * FROM sales_by_film_category;

SELECT inventory_id, rental_id, amount
FROM rental INNER JOIN payment
USING(rental_id);
'''
WITH inventory_rental AS (
SELECT inventory_id, rental_id, amount
FROM rental INNER JOIN payment
USING(rental_id)
)
SELECT title FROM film_text
WHERE film_id = (SELECT film_id FROM inventory 
				WHERE inventory_id = (SELECT DISTINCT(inventory_id) FROM inventory_rental
									GROUP BY inventory_id
                                    ORDER BY sum(amount) DESC
                                    LIMIT 1));
                                    
-------------------------------------------------------------------------------------------------------------------------------
-- 4. Write a query to find the city which generated the maximum revenue for the organisation.

-- Sample Output:-
-- city
-- Abu Dhabi
'''
-- This one below gives the city of the customer who generated the highest revenue for the organisation.
SELECT city FROM city
WHERE city_id = (SELECT city_id FROM address
				WHERE address_id = (SELECT address_id FROM customer
									WHERE customer_id = (SELECT distinct(customer_id) FROM payment
														GROUP BY customer_id
                                                        ORDER BY sum(amount) DESC
                                                        LIMIT 1
                                                        )
									)
				);
'''

WITH citywise_revenue AS (
SELECT city, city_id, address_id, customer_id, amount
FROM city INNER JOIN address USING (city_id)
INNER JOIN customer USING (address_id)
INNER JOIN payment USING (customer_id)
)
SELECT city FROM citywise_revenue
GROUP BY city
ORDER BY sum(amount) DESC
LIMIT 1;

-------------------------------------------------------------------------------------------------------------------------
-- 5. Write a query to find out how many times a particular movie category is rented. 
-- Arrange these categories in the decreasing order of the number of times they are rented.

-- Sample Output:-
-- Name			| Rental_count
-- Comedy		| 15

SELECT name Name, count(rental_id) Rental_count
FROM category INNER JOIN film_category USING (category_id)
INNER JOIN inventory USING (film_id)
INNER JOIN rental USING (inventory_id)
GROUP BY Name
ORDER BY Rental_count DESC;

----------------------------------------------------------------------------------------------------------------------------
-- 6. Write a query to find the full names of customer who have rented sc-fi movies more than 2 times.
-- Arrange these names in the alphabetical order

-- Sample Output:-
-- Customer_name
-- MARY SMITH

SELECT concat(first_name, ' ', last_name) Customer_name
FROM customer INNER JOIN rental USING (customer_id)
INNER JOIN inventory USING (inventory_id)
INNER JOIN film_category USING (film_id)
INNER JOIN category c USING (category_id)
WHERE c.name = 'sci-fi'
GROUP BY Customer_name
HAVING count(rental_id) > 2
ORDER BY Customer_name;

-----------------------------------------------------------------------------------------------------------------------------
-- 7. Write a query to find the full names of those customers who have rented 
-- at least one movie and belong to the city Arlington.

-- Sample Output:-
-- Customer_name
-- MARY SMITH

WITH customer_rental AS(
SELECT first_name, last_name, address_id
FROM customer RIGHT JOIN rental USING (customer_id)
)
SELECT distinct(concat(first_name, ' ', last_name)) Customer_name
FROM customer_rental INNER JOIN address USING (address_id)
INNER JOIN city USING (city_id)
WHERE city = 'Arlington';

----------------------------------------------------------------------------------------------------------------------------
-- 8. Write a query to find the number of movies rentend across each country. 
-- Display only those countries where at least one movie was rented.
-- Arrange these countries in the alphabetical order.

-- Sample Output:-
-- Country			| Rental_count
-- Afghanistan		| 15

WITH countrywise_rental AS(
SELECT country Country, count(rental_id) Rental_count
FROM country LEFT JOIN city USING (country_id)
LEFT JOIN address USING (city_id)
LEFT JOIN customer USING (address_id)
LEFT JOIN rental USING (customer_id)
GROUP BY country
)
SELECT * FROM countrywise_rental
WHERE Rental_count > 0
ORDER BY Country;
