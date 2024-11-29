-- Here are some questions related to case study of swiggy

-- 1. find users who never ordered
-- 2. Average Price /dish 
-- 3.  Find top restautants in terms of number of orders for a given month
-- 4. restaurants with monthly sales > x for
-- 5. Show all orders with order details for a particular customer in a particular date range
-- 6.  find restaurants with max repeated customers
-- 7.  Month over month revenue growth of swiggy
-- 8.  Customer -> Favorite Food
-- 9. find most loyal customers for all restaurants
-- 10. month over month revenue growth of a restaurants
-- 11. most paired Products 


CREATE DATABASE swiggy_case_study_my;


-- 1. find users who never ordered

SELECT * FROM
users 
WHERE user_id NOT IN (SELECT user_id FROM orders);

-- 2. Average Price /dish 

SELECT f_id ,AVG(price) 
FROM menu 
GROUP BY f_id;

--  or 
SELECT f.f_name ,AVG(price) AS 'AVG PRICE'
FROM menu m
JOIN food f
ON m.f_id = f.f_id
GROUP BY m.f_id;


-- 3.  Find top restautants in terms of number of orders for a given month

SELECT * FROM orders;
SELECT *, MONTHNAME(date) AS month_name FROM orders;

SELECT * , MONTHNAME(date) AS 'month' 
FROM orders WHERE MONTHNAME(date) LIKE 'december';
SELECT r.r_name, COUNT(*) AS 'month' 
FROM orders o JOIN restaurants r 
ON o.r_id = r.r_id 
WHERE MONTHNAME(date) LIKE 'july' 
GROUP BY o.r_id ORDER BY COUNT(*) DESC LIMIT 1; 



-- 4. restaurants with monthly sales > x for

SELECT * 
FROM orders 
WHERE MONTHNAME(date) LIKE 'june';

SELECT r_id, SUM(amount) AS 'PROFIT'
FROM orders 
GROUP BY r_id
HAVING PROFIT >3000; -- x= 3000

-- OR WITH RESTAURANTS NAMES

SELECT r.r_name ,SUM(amount) AS 'profit'
FROM orders o
JOIN restaurants r
ON o.r_id = r.r_id
GROUP BY o.r_id
HAVING profit>3000;

-- 5. Show all orders with order details for a particular customer in a particular date range
SELECT * FROM orders;
SELECT * FROM order_details;
SELECT * FROM users;


SELECT * FROM orders
WHERE user_id  = (SELECT user_id FROM users WHERE  name LIKE 'Ankit'); -- here name is unique

-- SELECT * FROM orders
-- WHERE user_id  = (SELECT user_id FROM users WHERE  name LIKE 'Ankit')
-- AND (date >'10-05-2022' AND date<'15-06-2022');

SELECT o.order_id ,r.r_name,f.f_name
FROM orders o

JOIN restaurants r
ON r.r_id = o.r_id

JOIN order_details od
ON o.order_id = od.order_id

JOIN food f
ON f.f_id = od.f_id

WHERE user_id  = (SELECT user_id FROM users WHERE  name LIKE 'Ankit')
AND (date >'10-05-2022' AND date<'15-06-2022');


SELECT o.order_id ,r.r_name,f.f_name
FROM orders o

JOIN restaurants r
ON r.r_id = o.r_id

JOIN order_details od
ON o.order_id = od.order_id

JOIN food f
ON f.f_id = od.f_id

WHERE user_id  = (SELECT user_id FROM users WHERE  name LIKE 'Neha')
AND (date >'10-05-2022' AND date<'15-06-2022');

-- 6.  find restaurants with max repeated customers ( loyal customors )


SELECT r_id, user_id, 
COUNT(*) AS 'visits'
 FROM orders 
 GROUP BY r_id , user_id
 HAVING visits>1;

--- OR ----

-- SELECT r_id, COUNT(*) AS 'Loyal_customers'
SELECT r.r_name, COUNT(*) AS 'Loyal_customers'

FROM (SELECT r_id, user_id, 
      COUNT(*) AS 'visits'
	  FROM orders 
      GROUP BY r_id , user_id
      HAVING visits>1
      )t
JOIN restaurants r
ON r.r_id = t.r_id

-- GROUP BY r_id
GROUP BY t.r_id


ORDER BY Loyal_cutomers DESC LIMIT 1; 

-- 7.  Month over month revenue growth of swiggy

SELECT * FROM orders;
SELECT * , MONTHNAME(date) AS 'MONTH_NAME' FROM orders;
-- step1 or
SELECT MONTHNAME(date) AS 'month' ,SUM(amount)
FROM orders 
GROUP BY month;

-- step 2
WITH sales AS (SELECT MONTHNAME(date) AS 'month' ,SUM(amount) AS 'revenue' 
FROM orders GROUP BY month ORDER BY MONTH(date))
SELECT month,  revenue,LAG(revenue ,1) 
OVER (ORDER BY revenue) FROM sales;    

-- step 3 final
SELECT month ,((revenue - prev)/prev)*100 FROM 
(
WITH sales AS (SELECT MONTHNAME(date) AS 'month' ,SUM(amount) AS 'revenue' FROM orders 
GROUP BY month 
ORDER BY MONTH(date)
)

SELECT month,  revenue,LAG(revenue ,1) 
OVER (ORDER BY revenue) AS prev 
FROM sales)t;


-- 8.  Customer -> Favorite Food
SELECT * FROM users;

-- step 1
SELECT * FROM orders o 
JOIN order_details od 
ON o.order_id = od.order_id;

-- step 2
SELECT o.user_id,od.f_id,COUNT(*) AS 'frequency'
FROM orders o 
JOIN order_details od 
ON o.order_id = od.order_id
GROUP BY o.user_id,od.f_id;


-- step 3
WITH temp AS(SELECT o.user_id,od.f_id,COUNT(*) AS 'frequency'
FROM orders o 
JOIN order_details od 
ON o.order_id = od.order_id
GROUP BY o.user_id,od.f_id)

SELECT * FROM temp t1 WHERE t1.frequency =(SELECT MAX(frequency) FROM temp t2 WHERE t2.user_id = t1.user_id);

-- step 4 final

WITH temp AS(SELECT o.user_id,od.f_id,COUNT(*) AS 'frequency'
FROM orders o 
JOIN order_details od 
ON o.order_id = od.order_id
GROUP BY o.user_id,od.f_id)

SELECT u.name,f.f_name,frequency FROM temp t1
JOIN users u
ON u.user_id = t1.user_id
JOIN food f
ON f.f_id= t1.f_id
WHERE t1.frequency =(SELECT MAX(frequency) FROM temp t2 WHERE t2.user_id = t1.user_id);





























 
 
