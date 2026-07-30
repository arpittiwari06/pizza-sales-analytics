-- Query 1: Retrieve the total number of orders placed.

select count(*) as total_orders_placed from orders

-- Query 2: Calculate the total revenue generated from pizza sales.

select round(sum(order_details.quantity*pizzas.price),2) as total_revenue 
from order_details
join pizzas 
on order_details.pizza_id=pizzas.pizza_id

-- Query 3: dentify the highest-priced pizza.

select pt.name from pizza_types as pt
join pizzas as p s
on pt.pizza_type_id=p.pizza_type_id
where p.price=(select max(price) from pizzas)

-- Query 4: List the top 5 most ordered pizza types along with their quantities.

select pt.name,sum(o.quantity) as total from pizza_types as pt
join pizzas as p
on pt.pizza_type_id=p.pizza_type_id
join order_details as o
on o.pizza_id=p.pizza_id
group by pt.name order by total desc limit 5

-- Query 5: Determine the distribution of orders by hour of the day.
select hour(order_time) as hour_of_the_day,count(order_id)
from orders
group by hour_of_the_day

-- Query 6: Join relevant tables to find the category-wise distribution of pizzas.
select category,count(name) from pizza_types
group by category

-- Query 7: Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0)
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS quantity
    FROM
        orders AS o
    JOIN order_details AS od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS order_quantity
    
    -- Query 8: Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.category,round(sum(order_details.quantity*pizzas.price,0) as revenue from pizza_types
join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.category order by revenue desc limit 3

-- Query 9: Calculate the percentage contribution of each pizza type to total revenue.

SELECT name, rnk
FROM (
    SELECT
        name,
        RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rnk
    FROM (
        SELECT
            pizza_types.category,
            pizza_types.name,
            SUM(order_details.quantity * pizzas.price) AS revenue
        FROM pizza_types
        JOIN pizzas
            ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN order_details
            ON pizzas.pizza_id = order_details.pizza_id
        GROUP BY pizza_types.category, pizza_types.name
    ) AS a
) AS b
WHERE rnk <= 3;

-- Query 10: calculate the monthly revenue 

SELECT
    MONTHNAME(o.order_date) AS month,
    ROUND(SUM(od.quantity * p.price),2) AS revenue
FROM orders o
JOIN order_details od
ON o.order_id = od.order_id
JOIN pizzas p
ON od.pizza_id = p.pizza_id
GROUP BY MONTH(o.order_date), MONTHNAME(o.order_date)
ORDER BY MONTH(o.order_date);

-- Query 11: Calculate Monthly Growth Rate
WITH monthly_sales AS
(
SELECT
    MONTH(order_date) AS month,
    SUM(quantity*price) AS revenue
FROM orders o
JOIN order_details od
ON o.order_id=od.order_id
JOIN pizzas p
ON od.pizza_id=p.pizza_id
GROUP BY MONTH(order_date)
)

SELECT
    month,
    revenue,
    LAG(revenue) OVER(ORDER BY month) AS previous_month,
    ROUND(
    ((revenue-LAG(revenue) OVER(ORDER BY month))
    /
    LAG(revenue) OVER(ORDER BY month))*100,2)
    AS growth_percentage
FROM monthly_sales;

-- Query 12: calculate Revenue by Quarter
SELECT
    QUARTER(order_date) AS quarter,
    ROUND(SUM(quantity*price),2) AS revenue
FROM orders o
JOIN order_details od
ON o.order_id=od.order_id
JOIN pizzas p
ON od.pizza_id=p.pizza_id
GROUP BY quarter;


