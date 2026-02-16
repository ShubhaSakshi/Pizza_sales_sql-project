Basic:
Retrieve the total number of orders placed.
Calculate the total revenue generated from pizza sales.
Identify the highest-priced pizza.
Identify the most common pizza size ordered.
List the top 5 most ordered pizza types along with their quantities.


Intermediate:
Join the necessary tables to find the total quantity of each pizza category ordered.
Determine the distribution of orders by hour of the day.
Join relevant tables to find the category-wise distribution of pizzas.
Group the orders by date and calculate the average number of pizzas ordered per day.
Determine the top 3 most ordered pizza types based on revenue.

Advanced:
Calculate the percentage contribution of each pizza type to total revenue.
Analyze the cumulative revenue generated over time.
Determine the top 3 most ordered pizza types based on revenue for each pizza category.






-- Pizaa Sales SQL Project
-- Database: Pizza_hut
CREATE DATABASE pizza_hut;	
USE pizza_hut;
SELECT 
    *
FROM
    pizzas;
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL
);
SELECT 
    *
FROM
    pizza_hut;	
CREATE TABLE order_details (
    order_details_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL
);
SELECT 
    *
FROM
    order_details; 
SHOW DATABASES; 
SHOW TABLES;

-- Q1 Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS 'total orders'
FROM
    orders;

-- Q2Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS 'total revenue'
FROM
    pizzas AS p
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id;


-- Q3 Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizzas
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


-- Q4 Identify the most common pizza size ordered.

SELECT 
    pizzas.size, SUM(order_details.quantity) AS total_order
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY total_order DESC
LIMIT 1;


-- Q5 List the top 5 most ordered pizza types along with their quantities

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;


-- Q6 Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    SUM(order_details.quantity) AS quantity,
    pizza_types.category
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- Q7 Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS per_hour, COUNT(order_id) AS order_
FROM
    orders
GROUP BY HOUR(order_time);

-- Q8 Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    COUNT(name), category
FROM
    pizza_types
GROUP BY category;


-- Q9 Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0)
FROM
    (SELECT 
        (SUM(order_details.quantity)) AS quantity,
            orders.order_date AS per_day
    FROM
        order_details
    JOIN orders ON order_details.order_id = orders.order_id
    GROUP BY per_day) AS perDay;


-- Q10 Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;


-- Q11 Calculate the percentage contribution of each pizza type to total revenue.

SELECT pizza_types.category,
ROUND(SUM(order_details.quantity * pizzas.price) /(SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS 'total revenue'
FROM
    pizzas AS p
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id )*100,2)AS revenue
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;


-- Q12 Analyze the cumulative revenue generated over time.

SELECT order_date,
SUM(revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM
(SELECT orders.order_date,
ROUND(SUM(order_details.quantity * pizzas.price),2) AS revenue
FROM order_details JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id 
JOIN orders
ON orders.order_id = order_details.order_id
GROUP BY orders.order_date )AS sales;


-- Q13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT name,revenue
FROM
(SELECT category,name,revenue,
RANK()OVER(PARTITION BY category ORDER BY revenue DESC) AS rn
FROM
(SELECT pizza_types.category,pizza_types.name,
SUM(order_details.quantity * pizzas.price) AS revenue
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category,pizza_types.name) AS a) AS b

WHERE rn <= 3;
