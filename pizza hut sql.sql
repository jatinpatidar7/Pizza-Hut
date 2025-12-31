create database pizza_hub ;


-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;


-- Calculate the total revenue generated from pizza sales.
SELECT 
  ROUND(SUM(od.quantity * p.price), 2) AS total_sales
FROM 
  order_details AS od
JOIN 
  pizzas AS p 
ON 
  od.pizza_id = p.pizza_id;
  
-- Identify the highest-priced pizza.
SELECT 
    pt.name, p.price
FROM
    pizzas AS p
        JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(od.order_details_id) AS order_count
FROM
    pizzas AS p
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name, SUM(quantity) AS quantity
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY quantity DESC
limit 5;
**
-- Join the necessary tables to find the total quantity of each pizza category ordered.    
    
    SELECT 
    pt.category,
    SUM(od.quantity) AS quantity
FROM 
    pizza_types AS pt
JOIN 
    pizzas AS p 
    ON pt.pizza_type_id = p.pizza_type_id
JOIN 
    order_details AS od 
    ON od.pizza_id = p.pizza_id
GROUP BY 
    pt.category
ORDER BY 
    quantity DESC;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(time);

-- Join relevant tables to find the category-wise distribution of pizzas.
select category , count(name) from pizza_types
group by category ; 

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) as pizza_order_per_day
FROM
    (SELECT 
        o.date, SUM(od.quantity) AS quantity
    FROM
        orders AS o
    JOIN order_details AS od ON o.order_id = od.order_id
    GROUP BY o.date) AS order_quantity;
    
-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name, SUM(od.quantity * p.price) AS revenue
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

--
-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.category,
    ROUND(SUM(od.quantity * p.price) * 100.0 /
        (SELECT SUM(od.quantity * p.price)
         FROM order_details AS od
         JOIN pizzas AS p ON p.pizza_id = od.pizza_id), 2) AS revenue_share
FROM 
    pizza_types AS pt
JOIN 
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
JOIN 
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY 
    pt.category
ORDER BY 
    revenue_share DESC;
    
    
------------------- With cte


WITH total_sales AS (
    SELECT 
        SUM(od.quantity * p.price) AS total_revenue
    FROM 
        order_details AS od
    JOIN 
        pizzas AS p ON p.pizza_id = od.pizza_id
)
SELECT 
    pt.category,
    ROUND(SUM(od.quantity * p.price) * 100.0 / ts.total_revenue, 2) AS revenue
FROM 
    pizza_types AS pt
JOIN 
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
JOIN 
    order_details AS od ON p.pizza_id = od.pizza_id
CROSS JOIN 
    total_sales ts
GROUP BY 
    pt.category, ts.total_revenue
ORDER BY 
    revenue DESC;



-- Analyze the cumulative revenue generated over time.


WITH daily_sales AS (
    SELECT 
        o.date,
        SUM(od.quantity * p.price) AS revenue
    FROM orders AS o
    JOIN order_details AS od 
        ON o.order_id = od.order_id
    JOIN pizzas AS p 
        ON od.pizza_id = p.pizza_id
    GROUP BY o.date
)
SELECT 
    date,
    SUM(revenue) OVER (ORDER BY date) AS cum_revenue
FROM daily_sales
ORDER BY date;

------------------------

SELECT 
    o.date,
    SUM(SUM(od.quantity * p.price)) 
        OVER (ORDER BY o.date) AS cum_revenue
FROM orders AS o
JOIN order_details AS od 
    ON o.order_id = od.order_id
JOIN pizzas AS p 
    ON od.pizza_id = p.pizza_id
GROUP BY o.date
ORDER BY o.date;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.


WITH pizza_revenue AS (
    SELECT 
        pt.category,
        pt.name,
        SUM(od.quantity * p.price) AS revenue,
        RANK() OVER (
            PARTITION BY pt.category 
            ORDER BY SUM(od.quantity * p.price) DESC
        ) AS rn
    FROM 
        pizza_types AS pt
    JOIN 
        pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
    JOIN 
        order_details AS od ON od.pizza_id = p.pizza_id
    GROUP BY 
        pt.category, pt.name
)
SELECT 
    category,
    name,
    revenue
FROM 
    pizza_revenue
WHERE 
    rn <= 3
ORDER BY 
    category, revenue DESC;




