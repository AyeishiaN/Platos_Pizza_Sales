SELECT*
FROM pizza_sales;

-- create table to work with that is seperate from raw data
CREATE TABLE pizza_sales_stagging
SELECT *
FROM pizza_sales;

SELECT *
FROM pizza_sales_stagging;

-- Fix order_date and order_time data type. Also fixed order_details_id with removing unwanted characters in alter table window

ALTER TABLE pizza_sales_stagging
	-- ADD COLUMN new_order_date DATE
    -- AFTER order_date
    ADD COLUMN new_order_time TIME
    AFTER order_time;

UPDATE pizza_sales_stagging
SET new_order_date = STR_TO_DATE(order_date, "%m/%d/%Y");

UPDATE pizza_sales_stagging
SET new_order_time = STR_TO_DATE(order_time, "%H:%i:%s");

ALTER TABLE pizza_sales_stagging
DROP COLUMN order_date,
DROP COLUMN order_time;

SELECT *
FROM pizza_sales_stagging;

-- Most popular pizza, The Classic Deluxe Pizza
SELECT pizza_name, COUNT(quantity) AS total, ROUND(SUM(total_price),2) AS revenue
FROM pizza_sales_stagging
GROUP BY pizza_name
ORDER BY 2 DESC;

-- Top 5 pizzas
SELECT pizza_name, COUNT(quantity) AS total
FROM pizza_sales_stagging
GROUP BY pizza_name
ORDER BY 2 DESC
LIMIT 5;

-- Least selling pizza, The Brie Carre Pizza
SELECT pizza_name, COUNT(quantity) AS total
FROM pizza_sales_stagging
GROUP BY pizza_name
ORDER BY 2
LIMIT 5;

-- How many classic deluxe pizza is being sold weekly, monthly?
SELECT dayname(new_order_date) AS day_of_week, COUNT(quantity) AS orders, SUM(total_price) AS revenue
FROM pizza_sales_stagging
WHERE pizza_name = "The Classic Deluxe Pizza"
GROUP BY 1
ORDER BY 2 DESC;

SELECT monthname(new_order_date) AS month, COUNT(quantity) AS orders, SUM(total_price) AS revenue
FROM pizza_sales_stagging
WHERE pizza_name = "The Classic Deluxe Pizza"
GROUP BY 1
ORDER BY 2 DESC;

-- How many The Brie Carre Pizza is being sold weekly, monthly?
SELECT dayname(new_order_date) AS day_of_week, COUNT(quantity) AS orders, ROUND(SUM(total_price),2) AS revenue
FROM pizza_sales_stagging
WHERE pizza_name = "The Brie Carre Pizza"
GROUP BY 1
ORDER BY 2 DESC;

SELECT monthname(new_order_date) AS month, COUNT(quantity) AS orders, ROUND(SUM(total_price),2) AS revenue
FROM pizza_sales_stagging
WHERE pizza_name = "The Brie Carre Pizza"
GROUP BY 1
ORDER BY 2 DESC;

-- Days of the week, number of orders
SELECT dayname(new_order_date) AS day_of_week, COUNT(quantity) AS orders
FROM pizza_sales_stagging
GROUP BY day_of_week
ORDER BY 2 DESC;

-- Orders per time period
SELECT *
FROM pizza_sales_stagging;

SELECT MIN(new_order_time),MAX(new_order_time)  -- finding the range of time the restaurant is taking orders: 09:52 - 23:05
FROM pizza_sales_stagging;

SELECT pizza_name,
	CASE
		WHEN new_order_time BETWEEN "05:00:00" AND "11:59:59" THEN "Morning"
        WHEN new_order_time BETWEEN "12:00:00" AND "16:59:59" THEN "Afternoon"
        WHEN new_order_time BETWEEN "17:00:00" AND "20:59:59" THEN "Evening"
        WHEN new_order_time BETWEEN "21:00:00" AND "23:59:59" THEN "Night"
        ELSE "check time"
    END AS day_time,
    COUNT(quantity) AS orders
FROM pizza_sales_stagging
GROUP BY day_time, pizza_name
ORDER BY 3 DESC;

SELECT 
	CASE
		WHEN new_order_time BETWEEN "05:00:00" AND "11:59:59" THEN "Morning"
        WHEN new_order_time BETWEEN "12:00:00" AND "16:59:59" THEN "Afternoon"
        WHEN new_order_time BETWEEN "17:00:00" AND "20:59:59" THEN "Evening"
        WHEN new_order_time BETWEEN "21:00:00" AND "23:59:59" THEN "Night"
        ELSE "check time"
    END AS day_time,
    COUNT(quantity) AS orders
FROM pizza_sales_stagging
GROUP BY day_time
ORDER BY 2 DESC;

-- Average order revenue

SELECT order_id ,ROUND(AVG(total_price),2) AS avg_total_revenue -- finds the average order revenue per order
FROM pizza_sales_stagging
GROUP BY order_id;

SELECT ROUND(AVG(avg_total_revenue),2) AS avg_order_revenue -- finds the overall average order revenue
FROM(
	SELECT order_id ,ROUND(AVG(total_price),2) AS avg_total_revenue
FROM pizza_sales_stagging
GROUP BY order_id
) AS avg_order;

-- Popular pizza type, Classic

SELECT pizza_category,  COUNT(pizza_category) AS pizzas
FROM pizza_sales_stagging
GROUP BY pizza_category
ORDER BY 2 DESC;

-- Popular Pizza size, Large

SELECT pizza_size, COUNT(pizza_size) AS pizzas
FROM pizza_sales_stagging
GROUP BY pizza_size
ORDER BY 2 DESC;

-- Popular size for The Classic Deluxe Pizza, M

SELECT pizza_size, COUNT(pizza_size) AS pizzas
FROM pizza_sales_stagging
WHERE pizza_name = "The Classic Deluxe Pizza"
GROUP BY pizza_size
ORDER BY 2 DESC;

-- Revenue per pizza type
SELECT pizza_name, ROUND(SUM(total_price),2) AS revenue
FROM pizza_sales_stagging
GROUP BY pizza_name
ORDER BY 2 DESC;

-- Number of orders per hour in the weeks of each month

SELECT monthname(new_order_date) AS month,dayname(new_order_date) AS day ,Hour(new_order_time) AS hour, COUNT(order_id) AS orders, COUNT(order_id) / 60 AS remaining_seats
FROM pizza_sales_stagging
GROUP BY month,day, hour;


SELECT month, COUNT(*) AS num_hours -- how many hours where there a lack of seats, 279
FROM (
	SELECT monthname(new_order_date) AS month,dayname(new_order_date) AS day ,Hour(new_order_time) AS hour, COUNT(order_id) AS orders, COUNT(order_id) / 60 AS remaining_seats
FROM pizza_sales_stagging
GROUP BY month,day, hour
) AS seats
WHERE remaining_seats > 1
GROUP BY month;

SELECT month, COUNT(*) AS num_hours -- how many hours where there a lack of seats if we assume the average customer spends 30 minutes seated, 11
FROM (
	SELECT monthname(new_order_date) AS month,dayname(new_order_date) AS day ,Hour(new_order_time) AS hour, COUNT(order_id) AS orders, COUNT(order_id) / 120 AS remaining_seats
FROM pizza_sales_stagging
GROUP BY month,day, hour
) AS seats
WHERE remaining_seats > 1
GROUP BY month;

SELECT COUNT(*) -- total hours orders were made through the year, 1024
FROM (
	SELECT monthname(new_order_date) AS month,dayname(new_order_date) AS day ,Hour(new_order_time) AS hour, COUNT(order_id) AS orders, COUNT(order_id) / 60 AS remaining_seats
FROM pizza_sales_stagging
GROUP BY month,day, hour
) AS seats
;

SELECT (279/1024)*100;


































































