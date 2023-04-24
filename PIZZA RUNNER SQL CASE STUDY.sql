--INPUT DATA FROM THE INTERNET
DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

--CREATE TEMP TABLE TO CLEAN DATA
CREATE TABLE ##CUSTOMER_ORDERS (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" DATETIME
);

INSERT INTO ##CUSTOMER_ORDERS
SELECT ORDER_ID, customer_id, pizza_id, 
CASE  
 WHEN exclusions = 'null' or exclusions = ' ' THEN NULL
 ELSE exclusions
END AS exclusions,
CASE  
 WHEN extras = 'null' or extras = ' ' THEN NULL
 ELSE extras
END AS extras,
order_time
FROM customer_orders;

CREATE TABLE ##RUNNER_ORDERS (
 "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" DATETIME,
  "distance" DECIMAL(4,2),
  "duration" DECIMAL(4,2),
  "cancellation" VARCHAR(23)
);

INSERT INTO ##RUNNER_ORDERS
SELECT order_id, runner_id, CONVERT(DATETIME, 
CASE  
 WHEN pickup_time = 'null' then NULL
 ELSE pickup_time
END
) AS PICKUP_TIME,
CONVERT (DECIMAL(4,2), 
CASE 
 WHEN DISTANCE = 'null' then NULL
 WHEN DISTANCE LIKE '%km' THEN REPLACE(DISTANCE, 'km', '')
 else DISTANCE
END) AS DISTANCE,
CONVERT (INT, 
CASE 
 WHEN DURATION = 'null' then NULL
 WHEN DURATION LIKE '%min%' THEN  STUFF(DURATION, 3, 10, '')
 ELSE duration
END) AS DURATION,
CASE 
 WHEN cancellation = 'null' OR CANCELLATION = ' ' then NULL
 ELSE cancellation
END AS CANCELLATION
FROM runner_orders;

CREATE TABLE ##PIZZA_RECIPES (
  "pizza_id" INTEGER,
  "toppings" NVARCHAR(MAX)
);

INSERT INTO ##PIZZA_RECIPES
SELECT pizza_id, value AS toppings
FROM pizza_recipes
CROSS APPLY STRING_SPLIT(CAST(toppings AS NVARCHAR(MAX)), ',');

ALTER TABLE PIZZA_TOPPINGS
ALTER COLUMN TOPPING_NAME NVARCHAR(MAX);

SELECT * FROM ##CUSTOMER_ORDERS
SELECT * FROM ##RUNNER_ORDERS
SELECT * FROM runners
SELECT * FROM pizza_names
SELECT * FROM ##PIZZA_RECIPES
SELECT * FROM pizza_toppings

--A. Pizza Metrics
--1 How many pizzas were ordered?
--2 How many unique customer orders were made?
SELECT COUNT (*) AS NUMBER_OF_PIZZAS, COUNT(DISTINCT order_id) AS UNIQUE_ORD
FROM ##CUSTOMER_ORDERS;

--3 How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(ORDER_ID) AS SUC_ORD
FROM ##RUNNER_ORDERS
WHERE cancellation is NULL
GROUP BY RUNNER_ID;

--4 How many of each type of pizza was delivered?
SELECT CO.pizza_id, COUNT(CO.ORDER_ID) AS NUMBER
FROM ##CUSTOMER_ORDERS CO INNER JOIN ##RUNNER_ORDERS RO
ON CO.order_id = RO.order_id
WHERE RO.cancellation IS NULL
GROUP BY pizza_id;

--5 How many Vegetarian and Meatlovers were ordered by each customer?
SELECT customer_id, SUM(
CASE 
 WHEN PIZZA_ID = 1 THEN 1
 ELSE 0
END) AS MEATLOVERS,
SUM(
CASE 
 WHEN PIZZA_ID = 2 THEN 1
 ELSE 0
END) AS VEGETARIAN
FROM ##CUSTOMER_ORDERS
GROUP BY customer_id;

--6 What was the maximum number of pizzas delivered in a single order?
SELECT TOP 1 CO.order_id, COUNT(CO.order_id) AS NUMBER
FROM ##CUSTOMER_ORDERS CO INNER JOIN ##RUNNER_ORDERS RO
ON CO.order_id = RO.order_id
WHERE RO.cancellation IS NULL 
GROUP BY CO.order_id
ORDER BY COUNT(CO.ORDER_ID) DESC;

--7 For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT CO.customer_id, COUNT(CO.order_id) AS ORDER_NUM,
SUM(
CASE
 WHEN CO.EXCLUSIONS IS NOT NULL OR CO.EXTRAS IS NOT NULL THEN 1
 ELSE 0
END) AS CHANGE,
SUM(
CASE
 WHEN CO.EXCLUSIONS IS NOT NULL OR CO.EXTRAS IS NOT NULL THEN 0
 ELSE 1
END) AS NO_CHANGE
FROM ##CUSTOMER_ORDERS CO INNER JOIN ##RUNNER_ORDERS RO
ON CO.order_id = RO.order_id
WHERE RO.cancellation IS NULL 
GROUP BY CO.customer_id;

--8 How many pizzas were delivered that had both exclusions and extras?
SELECT CO.customer_id, COUNT(CO.order_id) AS ORDER_NUM,
SUM(
CASE
 WHEN CO.EXCLUSIONS IS NOT NULL AND CO.EXTRAS IS NOT NULL THEN 1
 ELSE 0
END) AS BOTH_CHANGE
FROM ##CUSTOMER_ORDERS CO INNER JOIN ##RUNNER_ORDERS RO
ON CO.order_id = RO.order_id
WHERE RO.cancellation IS NULL 
GROUP BY CO.customer_id
ORDER BY BOTH_CHANGE DESC;

--9 What was the total volume of pizzas ordered for each hour of the day?
WITH T1 AS (SELECT *, DATEPART(HOUR, order_time) AS HR
FROM ##CUSTOMER_ORDERS)
SELECT HR, COUNT(ORDER_ID) AS VOLUME
FROM T1
GROUP BY HR
ORDER BY HR;

--10 What was the volume of orders for each day of the week?
WITH T1 AS (SELECT *, DATENAME(WEEKDAY, order_time) AS WKD
FROM ##CUSTOMER_ORDERS)
SELECT WKD, COUNT(ORDER_ID) AS VOLUME
FROM T1
GROUP BY WKD;

--B. Runner and Customer Experience
--1 How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
WITH T1 AS (SELECT *, CONVERT(DATE,DATEADD(WEEK, DATEDIFF(WEEK, '2021-01-01', REGISTRATION_DATE), '2021-01-01')) AS WK_Start, DATEPART(WEEK, registration_date) AS WK
FROM Runners),
T2 AS (SELECT runner_id,
CASE 
 WHEN registration_date < WK_Start THEN WK-1
 ELSE WK
END AS WK_NUM
FROM T1)
SELECT WK_NUM, COUNT(RUNNER_ID) AS RUNNERS
FROM T2
GROUP BY WK_NUM;

--2 What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT RO.runner_id, AVG(DATEDIFF(MINUTE, CO.ORDER_TIME, RO.PICKUP_TIME)) AS AVG_MIN
FROM ##CUSTOMER_ORDERS CO INNER JOIN ##RUNNER_ORDERS RO
ON CO.order_id = RO.order_id
WHERE RO.cancellation IS NULL
GROUP BY RO.RUNNER_ID;

--3 Is there any relationship between the number of pizzas and how long the order takes to prepare?=>DEFINITELY, YES
--THE MORE NUMBER OF PIZZAS WERE ORDERED, THE MORE TIME NEEDED FOR PREPARATION
WITH T1 AS (SELECT CO.ORDER_ID, COUNT(CO.PIZZA_ID) AS PIZZA_NUM, AVG(DATEDIFF(MINUTE, CO.ORDER_TIME, RO.PICKUP_TIME)) AS MINUTES
FROM ##CUSTOMER_ORDERS CO INNER JOIN ##RUNNER_ORDERS RO
ON CO.order_id = RO.order_id
WHERE RO.cancellation IS NULL
GROUP BY CO.order_id)
SELECT PIZZA_NUM, AVG(MINUTES) AS MINUTES
FROM T1
GROUP BY PIZZA_NUM;

--4 What was the average distance travelled for each customer?
SELECT CO.customer_id, AVG(RO.DISTANCE) AS AVG_DIS
FROM ##CUSTOMER_ORDERS CO INNER JOIN ##RUNNER_ORDERS RO
ON CO.order_id = RO.order_id
WHERE RO.cancellation IS NULL
GROUP BY CO.customer_id;

--5 What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(DURATION) - MIN (DURATION) AS DIF_TIMES
FROM ##RUNNER_ORDERS
WHERE CANCELLATION IS NULL;

--6 What was the average speed for each runner for each delivery and do you notice any trend for these values?
--THE HIGHER DISTANCE, THE MORE MINUTES
SELECT runner_id, AVG(DISTANCE) AS DISTANCE_KM, AVG(DURATION) AS MINUTES, AVG(DISTANCE*60/DURATION) AS SPEED_KM_H
FROM ##RUNNER_ORDERS
WHERE CANCELLATION IS NULL
GROUP BY runner_id;

--7 What is the successful delivery percentage for each runner?
SELECT runner_id, FORMAT(100.0*SUM(
CASE 
 WHEN cancellation IS NULL 
 THEN 1 
 ELSE 0 
END) / COUNT(ORDER_ID), '0.00') + '%' AS SUC_PERCENT
FROM ##RUNNER_ORDERS
GROUP BY runner_id;

--C. Ingredient Optimisation
--1 What are the standard ingredients for each pizza?
SELECT PC.pizza_id, PT.topping_name
FROM ##PIZZA_RECIPES PC INNER JOIN pizza_toppings PT
ON PC.toppings = PT.topping_id;

--2 What was the most commonly added extra?
WITH T1 AS (SELECT ORDER_ID, VALUE AS EXTRAS
FROM ##CUSTOMER_ORDERS
CROSS APPLY STRING_SPLIT(CAST(EXTRAS AS NVARCHAR(MAX)), ','))
SELECT PT.topping_name, COUNT(T1.EXTRAS) AS EXTRA_NUM
FROM T1 INNER JOIN pizza_toppings PT
ON T1.EXTRAS = PT.topping_id
GROUP BY PT.topping_name
ORDER BY COUNT(T1.EXTRAS) DESC;

--3 What was the most common exclusion?
WITH T1 AS (SELECT ORDER_ID, VALUE AS EXCLUSIONS
FROM ##CUSTOMER_ORDERS
CROSS APPLY STRING_SPLIT(CAST(EXCLUSIONS AS NVARCHAR(MAX)), ','))
SELECT PT.topping_name, COUNT(T1.EXCLUSIONS) AS EXCLUSION_NUM
FROM T1 INNER JOIN pizza_toppings PT
ON T1.EXCLUSIONS = PT.topping_id
GROUP BY PT.topping_name
ORDER BY COUNT(T1.EXCLUSIONS) DESC;

--4 Generate an order item for each record in the customers_orders table in the format of one of the following:
--Meat Lovers
SELECT DISTINCT ORDER_ID
FROM ##CUSTOMER_ORDERS CO INNER JOIN pizza_names PN
ON CO.pizza_id = PN.pizza_id
WHERE PN.pizza_name = 'Meatlovers';

--Meat Lovers - Exclude Beef
SELECT DISTINCT ORDER_ID
FROM ##CUSTOMER_ORDERS CO INNER JOIN pizza_names PN
ON CO.pizza_id = PN.pizza_id
WHERE PN.pizza_name = 'Meatlovers' AND CO.exclusions LIKE '%3%';

--Meat Lovers - Extra Bacon
SELECT DISTINCT ORDER_ID
FROM ##CUSTOMER_ORDERS CO INNER JOIN pizza_names PN
ON CO.pizza_id = PN.pizza_id
WHERE PN.pizza_name = 'Meatlovers' AND CO.extras LIKE '%1%';

--5 Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table 
WITH C1 AS (SELECT ORDER_ID, CUSTOMER_ID, PIZZA_ID, EXCLUSIONS,EXTRAS, 
COUNT(*) OVER (PARTITION BY ORDER_ID, CUSTOMER_ID, PIZZA_ID, EXCLUSIONS,EXTRAS 
               ORDER BY ORDER_ID, CUSTOMER_ID, PIZZA_ID, EXCLUSIONS,EXTRAS) AS QTY
FROM ##CUSTOMER_ORDERS),
C2 AS (SELECT DISTINCT *
FROM C1),
C3 AS (SELECT ROW_NUMBER() OVER (ORDER BY ORDER_ID, CUSTOMER_ID, PIZZA_ID, EXCLUSIONS,EXTRAS) AS ID, *
FROM C2), 
C4 AS (SELECT PIZZA_ID, TRIM(TOPPINGS) AS TOPPINGS
FROM ##PIZZA_RECIPES),
T1 AS (SELECT ID, ORDER_ID, pizza_id, QTY,value AS EXCLUSIONS, EXTRAS
FROM C3
CROSS APPLY STRING_SPLIT(CAST(EXCLUSIONS AS NVARCHAR(MAX)),',')),
T2 AS (SELECT ID, ORDER_ID, pizza_id, QTY, TRIM(EXCLUSIONS) AS EXCLUSIONS, EXTRAS
FROM T1),
T4 AS (SELECT T2.ID, T2.QTY, T2.EXCLUSIONS, T2.extras, PT.TOPPING_NAME
FROM T2 INNER JOIN C4
ON T2.pizza_id = C4.pizza_id
INNER JOIN pizza_toppings PT
ON PT.topping_id = C4.toppings
WHERE C4.toppings <> T2.EXCLUSIONS),
T5 AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY ID, TOPPING_NAME ORDER BY ID, TOPPING_NAME) AS RN
FROM T4),
T6 AS (SELECT A.ID, A.QTY, A.EXCLUSIONS, A.extras, A.topping_name
FROM T5 A
WHERE A.RN = 2
OR (A.RN = 1 AND NOT EXISTS(SELECT 1 FROM T5 B WHERE B.ID = A.ID AND B.RN = 2))),
K1 AS (SELECT ID, ORDER_ID, pizza_id, QTY, EXCLUSIONS, value AS EXTRAS
FROM C3
CROSS APPLY STRING_SPLIT(CAST(EXTRAS AS NVARCHAR(MAX)),',')),
K2 AS (SELECT ID, ORDER_ID, pizza_id, QTY, EXCLUSIONS, TRIM(EXTRAS) AS EXTRAS
FROM K1),
K4 AS (SELECT K2.ID, K2.order_id, K2.pizza_id, K2.EXCLUSIONS, K2.EXTRAS, K2.QTY, PT.TOPPING_NAME,
CASE 
  WHEN C4.toppings = K2.EXTRAS THEN '2X' + ' ' + PT.TOPPING_NAME
  ELSE PT.TOPPING_NAME
END AS TOPPING_NAME_1
FROM K2 INNER JOIN C4
ON K2.pizza_id = C4.pizza_id
INNER JOIN pizza_toppings PT
ON PT.topping_id = C4.toppings),
K5 AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY ID, TOPPING_NAME ORDER BY ID, TOPPING_NAME, TOPPING_NAME_1) AS RN
FROM K4),
K6 AS (SELECT ID, QTY, EXCLUSIONS, EXTRAS, TOPPING_NAME_1, topping_name
FROM K5 
WHERE RN = 1)
SELECT C3.ID, C3.QTY, STRING_AGG(PT.TOPPING_NAME, ', ') AS INGRE_LIST
FROM C3 INNER JOIN C4
ON C4.pizza_id = C3.pizza_id
INNER JOIN pizza_toppings PT
ON PT.topping_id = C4.TOPPINGS
WHERE C3.exclusions IS NULL AND C3.extras IS NULL
GROUP BY C3.ID, C3.QTY
UNION
SELECT ID, QTY, STRING_AGG(TOPPING_NAME_1, ', ') AS INGRE_LIST
FROM K6
WHERE exclusions IS NULL
GROUP BY ID, QTY
UNION
SELECT ID, QTY, STRING_AGG(TOPPING_NAME, ', ') AS INGRE_LIST
FROM T6 
WHERE EXTRAS IS NULL
GROUP BY ID, QTY
UNION
SELECT K6.ID, K6.QTY, STRING_AGG(K6.TOPPING_NAME_1, ', ') AS INGRE_LIST
FROM K6 INNER JOIN T6 
ON K6.ID = T6.ID AND K6.QTY = T6.QTY AND K6.topping_name = T6.topping_name
WHERE K6.exclusions IS NOT NULL AND T6.EXTRAS IS NOT NULL
GROUP BY K6.ID, K6.QTY;

--6 What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
WITH C1 AS (SELECT ORDER_ID, CUSTOMER_ID, PIZZA_ID, EXCLUSIONS,EXTRAS, 
COUNT(*) OVER (PARTITION BY ORDER_ID, CUSTOMER_ID, PIZZA_ID, EXCLUSIONS,EXTRAS 
               ORDER BY ORDER_ID, CUSTOMER_ID, PIZZA_ID, EXCLUSIONS,EXTRAS) AS QTY
FROM ##CUSTOMER_ORDERS),
C2 AS (SELECT DISTINCT *
FROM C1),
C3 AS (SELECT ROW_NUMBER() OVER (ORDER BY ORDER_ID, CUSTOMER_ID, PIZZA_ID, EXCLUSIONS,EXTRAS) AS ID, *
FROM C2), 
C4 AS (SELECT PIZZA_ID, TRIM(TOPPINGS) AS TOPPINGS
FROM ##PIZZA_RECIPES),
T1 AS (SELECT ID, ORDER_ID, pizza_id, QTY,value AS EXCLUSIONS, EXTRAS
FROM C3
CROSS APPLY STRING_SPLIT(CAST(EXCLUSIONS AS NVARCHAR(MAX)),',')),
T2 AS (SELECT ID, ORDER_ID, pizza_id, QTY, TRIM(EXCLUSIONS) AS EXCLUSIONS, EXTRAS
FROM T1),
T4 AS (SELECT T2.ID, T2.QTY, T2.order_id, T2.EXCLUSIONS, T2.extras, PT.TOPPING_NAME
FROM T2 INNER JOIN C4
ON T2.pizza_id = C4.pizza_id
INNER JOIN pizza_toppings PT
ON PT.topping_id = C4.toppings
WHERE C4.toppings <> T2.EXCLUSIONS),
T5 AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY ID, TOPPING_NAME ORDER BY ID, TOPPING_NAME) AS RN
FROM T4),
T6 AS (SELECT A.ID, A.QTY, A.order_id, A.EXCLUSIONS, A.extras, A.topping_name
FROM T5 A
WHERE A.RN = 2
OR (A.RN = 1 AND NOT EXISTS(SELECT 1 FROM T5 B WHERE B.ID = A.ID AND B.RN = 2))),
K1 AS (SELECT ID, ORDER_ID, pizza_id, QTY, EXCLUSIONS, value AS EXTRAS
FROM C3
CROSS APPLY STRING_SPLIT(CAST(EXTRAS AS NVARCHAR(MAX)),',')),
K2 AS (SELECT ID, ORDER_ID, pizza_id, QTY, EXCLUSIONS, TRIM(EXTRAS) AS EXTRAS
FROM K1),
K4 AS (SELECT K2.ID, K2.order_id, K2.pizza_id, K2.EXCLUSIONS, K2.EXTRAS, K2.QTY, PT.TOPPING_NAME,
CASE 
  WHEN C4.toppings = K2.EXTRAS THEN '2X' + ' ' + PT.TOPPING_NAME
  ELSE PT.TOPPING_NAME
END AS TOPPING_NAME_1
FROM K2 INNER JOIN C4
ON K2.pizza_id = C4.pizza_id
INNER JOIN pizza_toppings PT
ON PT.topping_id = C4.toppings),
K5 AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY ID, TOPPING_NAME ORDER BY ID, TOPPING_NAME, TOPPING_NAME_1) AS RN
FROM K4),
K6 AS (SELECT ID, QTY, ORDER_ID, EXCLUSIONS, EXTRAS, TOPPING_NAME_1, topping_name
FROM K5 
WHERE RN = 1),
C5 AS (SELECT C3.ID, C3.QTY, C3.order_id, STRING_AGG(PT.TOPPING_NAME, ', ') AS INGRE_LIST
FROM C3 INNER JOIN C4
ON C4.pizza_id = C3.pizza_id
INNER JOIN pizza_toppings PT
ON PT.topping_id = C4.TOPPINGS
WHERE C3.exclusions IS NULL AND C3.extras IS NULL
GROUP BY C3.ID, C3.QTY, C3.order_id
UNION
SELECT ID, QTY, order_id,STRING_AGG(TOPPING_NAME_1, ', ') AS INGRE_LIST
FROM K6
WHERE exclusions IS NULL
GROUP BY ID, QTY, order_id
UNION
SELECT ID, QTY, order_id,STRING_AGG(TOPPING_NAME, ', ') AS INGRE_LIST
FROM T6 
WHERE EXTRAS IS NULL
GROUP BY ID, QTY, order_id
UNION
SELECT K6.ID, K6.QTY, K6.order_id,STRING_AGG(K6.TOPPING_NAME_1, ', ') AS INGRE_LIST
FROM K6 INNER JOIN T6 
ON K6.ID = T6.ID AND K6.QTY = T6.QTY AND K6.topping_name = T6.topping_name
WHERE K6.exclusions IS NOT NULL AND T6.EXTRAS IS NOT NULL
GROUP BY K6.ID, K6.QTY, K6.order_id),
C6 AS (SELECT ID, QTY, order_id,VALUE AS INGRE_LIST
FROM C5
CROSS APPLY STRING_SPLIT(CAST(INGRE_LIST AS NVARCHAR(MAX)),',')),
C7 AS (SELECT ID, QTY, order_id,TRIM(INGRE_LIST) AS TOPPINGS
FROM C6),
C8 AS (SELECT ID, QTY, order_id,TOPPINGS,
CASE
 WHEN TOPPINGS LIKE '2X%' THEN SUBSTRING(TOPPINGS, 4, LEN(TOPPINGS) - 3)
 ELSE TOPPINGS
END AS INGRE,
CASE
 WHEN TOPPINGS LIKE '2X%' THEN 2*QTY
 ELSE QTY
END AS T_COUNT
FROM C7),
C9 AS (SELECT INGRE, order_id,SUM(T_COUNT) AS QTY
FROM C8
GROUP BY INGRE, order_id)
SELECT C9.INGRE, SUM(C9.QTY) AS TOTAL_QTY
FROM C9 INNER JOIN ##RUNNER_ORDERS RO
ON RO.order_id = C9.order_id
WHERE RO.cancellation IS NULL
GROUP BY C9.INGRE
ORDER BY SUM(C9.QTY) DESC;

--D. Pricing and Ratings
--1 If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
SELECT RO.runner_id, SUM(
CASE 
 WHEN PN.pizza_name = 'Meatlovers' THEN 12
 WHEN PN.pizza_name = 'Vegetarian' THEN 10
END) AS TOTAL_MONEY  
FROM ##CUSTOMER_ORDERS CO INNER JOIN ##RUNNER_ORDERS RO
ON CO.order_id = RO.order_id
INNER JOIN pizza_names PN
ON PN.pizza_id = CO.pizza_id
WHERE RO.cancellation IS NULL
GROUP BY RO.runner_id;

--2 What if there was an additional $1 charge for any pizza extras?
--Add cheese is $1 extra
WITH C1 AS (SELECT ORDER_ID, CUSTOMER_ID, PIZZA_ID, EXCLUSIONS,EXTRAS, 
COUNT(*) OVER (PARTITION BY ORDER_ID, CUSTOMER_ID, PIZZA_ID, EXCLUSIONS,EXTRAS 
               ORDER BY ORDER_ID, CUSTOMER_ID, PIZZA_ID, EXCLUSIONS,EXTRAS) AS QTY
FROM ##CUSTOMER_ORDERS),
C2 AS (SELECT DISTINCT *
FROM C1),
C3 AS (SELECT ROW_NUMBER() OVER (ORDER BY ORDER_ID, CUSTOMER_ID, PIZZA_ID, EXCLUSIONS,EXTRAS) AS ID, *
FROM C2),
C4 AS (SELECT ID, ORDER_ID, PIZZA_ID, QTY, VALUE AS EXTRAS
FROM C3 
CROSS APPLY STRING_SPLIT(CAST(C3.EXTRAS AS NVARCHAR(MAX)),',')),
C5 AS (SELECT C3.ID, C3.ORDER_ID, C3.PIZZA_ID, C3.QTY, TRIM(C4.EXTRAS) AS EXTRAS
FROM C4 RIGHT JOIN C3
ON C3.ID = C4.ID),
C6 AS (SELECT C5.ID, RO.runner_id, C5.QTY,
CASE 
 WHEN PN.pizza_name = 'Meatlovers' THEN (CASE WHEN C5.EXTRAS = 4 THEN 13 ELSE 12 END)
 WHEN PN.pizza_name = 'Vegetarian' THEN (CASE WHEN C5.EXTRAS= 4 THEN 11 ELSE 10 END)
END AS REVENUE
FROM C5 INNER JOIN ##RUNNER_ORDERS RO
ON C5.order_id = RO.order_id
INNER JOIN pizza_names PN
ON PN.pizza_id = C5.pizza_id
WHERE RO.cancellation IS NULL),
C7 AS (SELECT *, RANK() OVER (PARTITION BY ID ORDER BY REVENUE DESC) AS RN 
FROM C6)
SELECT runner_id, SUM(QTY*REVENUE) AS TOTAL_REVENUE
FROM C7
WHERE RN=1
GROUP BY runner_id
ORDER BY runner_id;

--3 The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
DROP TABLE IF EXISTS  RATINGS;
CREATE TABLE RATINGS (
"ORDER_ID" INTEGER,
"RATING" TINYINT CHECK (Rating BETWEEN 1 AND 5));

INSERT INTO RATINGS (ORDER_ID, RATING)
VALUES 
('1', '4'),
('2', '3'),
('3', '5'),
('4', '4'),
('5', '3'),
('5', '3'),
('6', '4'),
('7', '5'),
('8', '4'),
('9', '5'),
('10', '3');

--4 Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
--customer_id
--order_id
--runner_id
--rating
--order_time
--pickup_time
--Time between order and pickup
--Delivery duration
--Average speed
--Total number of pizzas
SELECT CO.customer_id, CO.order_id, RO.runner_id, R.RATING, CO.order_time, RO.pickup_time, 
       DATEDIFF(MINUTE, CO.order_time, RO.pickup_time) AS PREPARATION_TIME, RO.duration, AVG(RO.DISTANCE*60/RO.DURATION) AS SPEED_KM_H,
	   COUNT(CO.PIZZA_ID) NUMBER_OF_PIZZA
FROM ##CUSTOMER_ORDERS CO INNER JOIN ##RUNNER_ORDERS RO
ON CO.order_id = RO.order_id
INNER JOIN RATINGS R
ON R.ORDER_ID = CO.order_id
WHERE RO.CANCELLATION IS NULL
GROUP BY CO.customer_id, CO.order_id, RO.runner_id, R.RATING, CO.order_time, RO.pickup_time, 
       DATEDIFF(MINUTE, CO.order_time, RO.pickup_time), RO.duration

--5 If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
SELECT SUM(
CASE 
 WHEN PN.pizza_name = 'Meatlovers' THEN 12
 WHEN PN.pizza_name = 'Vegetarian' THEN 10
END) -
SUM(CASE 
 WHEN RO.distance IS NULL THEN 0 ELSE 0.3*RO.distance END)
 AS EARNINGS
FROM ##CUSTOMER_ORDERS CO INNER JOIN ##RUNNER_ORDERS RO
ON CO.order_id = RO.order_id
INNER JOIN pizza_names PN
ON PN.pizza_id = CO.pizza_id
WHERE RO.cancellation IS NULL

--E. Bonus Questions
--If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?
INSERT INTO pizza_names 
("pizza_id", "pizza_name")
VALUES
  (3, 'SUPREME');

INSERT INTO ##PIZZA_RECIPES
("pizza_id", "toppings")
VALUES
(10,1),
(10,2),
(10,3),
(10,4),
(10,5),
(10,6),
(10,7),
(10,8),
(10,9),
(10,10);