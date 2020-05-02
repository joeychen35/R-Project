USE db_customer_panel;
SELECT * FROM Trips;
###a. How many:
##Store shopping trips are recorded in your database?
#7596145
SELECT COUNT(DISTINCT TC_id) FROM Trips;

##Households appear in your database?
#39577
SELECT COUNT(hh_id) FROM Households;

##Stores of different retailers appear in our data base?
#863
SELECT COUNT(DISTINCT TC_retailer_code) FROM Trips;

##Different products are recorded?
#4231283
SELECT COUNT(prod_id) FROM products;

#i. Products per category and products per module
#Category 12 rows
#product 12 rows
SELECT department_at_prod_id AS department , COUNT(module_at_prod_id) AS module FROM products GROUP BY department_at_prod_id;
SELECT department_at_prod_id AS department , COUNT(prod_id) AS product FROM products GROUP BY department_at_prod_id;

#ii. Plot the distribution of products and modules per department
SELECT department_at_prod_id AS department , COUNT(module_at_prod_id) AS module FROM products GROUP BY department_at_prod_id;
SELECT department_at_prod_id AS department , COUNT(prod_id) AS product FROM products GROUP BY department_at_prod_id;
##Transactions?
#38587942
SELECT COUNT(TC_id) FROM purchases;

#i. Total transactions and transactions realized under some kind of promotion.
#2603946
SELECT COUNT(TC_id) FROM purchases WHERE coupon_value_at_TC_prod_id != '0';


 
###b. Aggregate the data at the household‐monthly level to answer the following questions:
##How many households do not shop at least once on a 3 month periods.
#32 households

SELECT DISTINCT datediff(D1,D2) AS date_diff,A.hh_id, A.D1, B.D2 FROM
(SELECT ROW_NUMBER() OVER (PARTITION BY hh_id ORDER BY hh_id, TC_date) AS RowNumber, hh_id,TC_date AS D1 FROM Trips
ORDER BY hh_id, TC_date) AS A
INNER JOIN
(SELECT ROW_NUMBER() OVER (PARTITION BY hh_id ORDER BY hh_id, TC_date)+ 1 AS rownumber2, hh_id,TC_date AS D2 FROM Trips
ORDER BY hh_id,TC_date) AS B
ON A.hh_id = B.hh_id AND A.RowNumber = B.rownumber2
WHERE datediff(D1,D2) > 90;




#i. Is it reasonable?
# Reasonable

#ii. Why do you think this is occurring?
#Under the assumption that household do not shop at least once on a 3 month periods is because of household being out 
#of country for more than 3 month, we believe only a small percentage of household will take a vacation more than 3 months.

## Loyalism: Among the households who shop at least once a month, which % of them concentrate at least 80% of 
##their grocery expenditure (on average) on single retailer? And among 2 retailers?
#1 retailers 2.45%
SELECT * FROM 
(SELECT DISTINCT A.hh_id FROM
(SELECT ROW_NUMBER() OVER (PARTITION BY hh_id ORDER BY hh_id, TC_date) AS RowNumber, hh_id,TC_date AS D1 FROM Trips
ORDER BY hh_id, TC_date) AS A
INNER JOIN
(SELECT ROW_NUMBER() OVER (PARTITION BY hh_id ORDER BY hh_id, TC_date)+ 1 AS rownumber2, hh_id,TC_date AS D2 FROM Trips
ORDER BY hh_id,TC_date) AS B
ON A.hh_id = B.hh_id AND A.RowNumber = B.rownumber2
WHERE datediff(D1,D2) < 30) AS E
NATURAL JOIN
(SELECT C.hh_id, round(total_per_retailer/total_spent, 3) AS pct_spent, D.TC_retailer_code FROM 
(SELECT hh_id, SUM(TC_total_spent) AS total_spent FROM Trips GROUP BY hh_id) AS C
INNER JOIN
(SELECT hh_id, TC_retailer_code, SUM(TC_total_spent) AS total_per_retailer FROM Trips GROUP BY hh_id, TC_retailer_code ORDER BY hh_id) AS D
ON C.hh_id = D.hh_id
WHERE (total_per_retailer/total_spent) > 0.8) AS F; 

SELECT DISTINCT A.hh_id FROM
(SELECT ROW_NUMBER() OVER (PARTITION BY hh_id ORDER BY hh_id, TC_date) AS RowNumber, hh_id,TC_date AS D1 FROM Trips
ORDER BY hh_id, TC_date) AS A
INNER JOIN
(SELECT ROW_NUMBER() OVER (PARTITION BY hh_id ORDER BY hh_id, TC_date)+ 1 AS rownumber2, hh_id,TC_date AS D2 FROM Trips
ORDER BY hh_id,TC_date) AS B
ON A.hh_id = B.hh_id AND A.RowNumber = B.rownumber2
WHERE datediff(D1,D2) < 30;

#2 retailer
#3733/39577= 9.43%
SELECT * FROM
(SELECT (H.top_2_retail_spent/I.total_spent) AS pct_spent_top2, H.hh_id FROM 
(SELECT G.hh_id, SUM(G.total_per_retailer) AS top_2_retail_spent FROM 
(SELECT RANK () OVER (PARTITION BY hh_id ORDER BY SUM(TC_total_spent)DESC) AS rank1, hh_id, TC_retailer_code, 
SUM(TC_total_spent) AS total_per_retailer 
FROM Trips GROUP BY hh_id, TC_retailer_code 
ORDER BY hh_id, total_per_retailer DESC) AS G WHERE G.rank1 = 1 OR G.rank1 = 2 GROUP BY G.hh_id) AS H
NATURAL JOIN 
(SELECT hh_id, SUM(TC_total_spent) AS total_spent FROM Trips GROUP BY hh_id) AS I
) AS J
NATURAL JOIN
(SELECT DISTINCT A.hh_id FROM
(SELECT ROW_NUMBER() OVER (PARTITION BY hh_id ORDER BY hh_id, TC_date) AS RowNumber, hh_id,TC_date AS D1 FROM Trips
ORDER BY hh_id, TC_date) AS A
INNER JOIN
(SELECT ROW_NUMBER() OVER (PARTITION BY hh_id ORDER BY hh_id, TC_date)+ 1 AS rownumber2, hh_id,TC_date AS D2 FROM Trips
ORDER BY hh_id,TC_date) AS B
ON A.hh_id = B.hh_id AND A.RowNumber = B.rownumber2
WHERE datediff(D1,D2) < 30) AS K
WHERE pct_spent_top2 > 0.8;




#i. Are their demographics remarkably different? Are these people richer? Poorer?
# 1 retailer 
#NO Remarkably different, both rich and poor household who shop at least once a month will spend 80% of their grocery 
#expenditure in 1 retail store 

SELECT * FROM
(SELECT E.hh_id FROM 
(SELECT DISTINCT A.hh_id FROM
(SELECT ROW_NUMBER() OVER (PARTITION BY hh_id ORDER BY hh_id, TC_date) AS RowNumber, hh_id,TC_date AS D1 FROM Trips
ORDER BY hh_id, TC_date) AS A
INNER JOIN
(SELECT ROW_NUMBER() OVER (PARTITION BY hh_id ORDER BY hh_id, TC_date)+ 1 AS rownumber2, hh_id,TC_date AS D2 FROM Trips
ORDER BY hh_id,TC_date) AS B
ON A.hh_id = B.hh_id AND A.RowNumber = B.rownumber2
WHERE datediff(D1,D2) < 30) AS E
NATURAL JOIN
(SELECT C.hh_id, round(total_per_retailer/total_spent, 3) AS pct_spent, D.TC_retailer_code FROM 
(SELECT hh_id, SUM(TC_total_spent) AS total_spent FROM Trips GROUP BY hh_id) AS C
INNER JOIN
(SELECT hh_id, TC_retailer_code, SUM(TC_total_spent) AS total_per_retailer FROM Trips GROUP BY hh_id, TC_retailer_code ORDER BY hh_id) AS D
ON C.hh_id = D.hh_id
WHERE (total_per_retailer/total_spent) > 0.8) AS F) AS L
NATURAL JOIN 
(SELECT * FROM Households) AS M;
#2 retailers
#NO Remarkably different, both rich and poor household who shop at least once a month will spend 80% of their grocery 
#expenditure in 2 retail store 

SELECT * FROM 
(SELECT J.hh_id FROM
(SELECT (H.top_2_retail_spent/I.total_spent) AS pct_spent_top2, H.hh_id FROM 
(SELECT G.hh_id, SUM(G.total_per_retailer) AS top_2_retail_spent FROM 
(SELECT RANK () OVER (PARTITION BY hh_id ORDER BY SUM(TC_total_spent)DESC) AS rank1, hh_id, TC_retailer_code, 
SUM(TC_total_spent) AS total_per_retailer 
FROM Trips GROUP BY hh_id, TC_retailer_code 
ORDER BY hh_id, total_per_retailer DESC) AS G WHERE G.rank1 = 1 OR G.rank1 = 2 GROUP BY G.hh_id) AS H
NATURAL JOIN 
(SELECT hh_id, SUM(TC_total_spent) AS total_spent FROM Trips GROUP BY hh_id) AS I
) AS J
NATURAL JOIN
(SELECT DISTINCT A.hh_id FROM
(SELECT ROW_NUMBER() OVER (PARTITION BY hh_id ORDER BY hh_id, TC_date) AS RowNumber, hh_id,TC_date AS D1 FROM Trips
ORDER BY hh_id, TC_date) AS A
INNER JOIN
(SELECT ROW_NUMBER() OVER (PARTITION BY hh_id ORDER BY hh_id, TC_date)+ 1 AS rownumber2, hh_id,TC_date AS D2 FROM Trips
ORDER BY hh_id,TC_date) AS B
ON A.hh_id = B.hh_id AND A.RowNumber = B.rownumber2
WHERE datediff(D1,D2) < 30) AS K
WHERE pct_spent_top2 > 0.8) AS N
NATURAL JOIN 
(SELECT * FROM Households) AS O;
#ii. What is the retailer that has more loyalists?
#1 retailer
#TC_retailer_code = 6920 has more loyalists (418 household)
SELECT COUNT(E.hh_id) AS household_shop_at_retailer, F.TC_retailer_code FROM 
(SELECT DISTINCT A.hh_id FROM
(SELECT ROW_NUMBER() OVER (PARTITION BY hh_id ORDER BY hh_id, TC_date) AS RowNumber, hh_id,TC_date AS D1 FROM Trips
ORDER BY hh_id, TC_date) AS A
INNER JOIN
(SELECT ROW_NUMBER() OVER (PARTITION BY hh_id ORDER BY hh_id, TC_date)+ 1 AS rownumber2, hh_id,TC_date AS D2 FROM Trips
ORDER BY hh_id,TC_date) AS B
ON A.hh_id = B.hh_id AND A.RowNumber = B.rownumber2
WHERE datediff(D1,D2) < 30) AS E
NATURAL JOIN
(SELECT C.hh_id, round(total_per_retailer/total_spent, 3) AS pct_spent, D.TC_retailer_code FROM 
(SELECT hh_id, SUM(TC_total_spent) AS total_spent FROM Trips GROUP BY hh_id) AS C
INNER JOIN
(SELECT hh_id, TC_retailer_code, SUM(TC_total_spent) AS total_per_retailer FROM Trips GROUP BY hh_id, TC_retailer_code ORDER BY hh_id) AS D
ON C.hh_id = D.hh_id
WHERE (total_per_retailer/total_spent) > 0.8) AS F
GROUP BY F.TC_retailer_code ORDER BY F.TC_retailer_code;


#iii. Where do they live? Plot the distribution by state.
#1 retailer
SELECT COUNT(M.hh_id),M.hh_state FROM
(SELECT E.hh_id FROM 
(SELECT DISTINCT A.hh_id FROM
(SELECT ROW_NUMBER() OVER (PARTITION BY hh_id ORDER BY hh_id, TC_date) AS RowNumber, hh_id,TC_date AS D1 FROM Trips
ORDER BY hh_id, TC_date) AS A
INNER JOIN
(SELECT ROW_NUMBER() OVER (PARTITION BY hh_id ORDER BY hh_id, TC_date)+ 1 AS rownumber2, hh_id,TC_date AS D2 FROM Trips
ORDER BY hh_id,TC_date) AS B
ON A.hh_id = B.hh_id AND A.RowNumber = B.rownumber2
WHERE datediff(D1,D2) < 30) AS E
NATURAL JOIN
(SELECT C.hh_id, round(total_per_retailer/total_spent, 3) AS pct_spent, D.TC_retailer_code FROM 
(SELECT hh_id, SUM(TC_total_spent) AS total_spent FROM Trips GROUP BY hh_id) AS C
INNER JOIN
(SELECT hh_id, TC_retailer_code, SUM(TC_total_spent) AS total_per_retailer FROM Trips GROUP BY hh_id, TC_retailer_code ORDER BY hh_id) AS D
ON C.hh_id = D.hh_id
WHERE (total_per_retailer/total_spent) > 0.8) AS F) AS L
NATURAL JOIN 
(SELECT * FROM Households) AS M
GROUP BY M.hh_state;

#2 retailer 
SELECT COUNT(O.hh_id),O.hh_state FROM 
(SELECT J.hh_id FROM
(SELECT (H.top_2_retail_spent/I.total_spent) AS pct_spent_top2, H.hh_id FROM 
(SELECT G.hh_id, SUM(G.total_per_retailer) AS top_2_retail_spent FROM 
(SELECT RANK () OVER (PARTITION BY hh_id ORDER BY SUM(TC_total_spent)DESC) AS rank1, hh_id, TC_retailer_code, 
SUM(TC_total_spent) AS total_per_retailer 
FROM Trips GROUP BY hh_id, TC_retailer_code 
ORDER BY hh_id, total_per_retailer DESC) AS G WHERE G.rank1 = 1 OR G.rank1 = 2 GROUP BY G.hh_id) AS H
NATURAL JOIN 
(SELECT hh_id, SUM(TC_total_spent) AS total_spent FROM Trips GROUP BY hh_id) AS I
) AS J
NATURAL JOIN
(SELECT DISTINCT A.hh_id FROM
(SELECT ROW_NUMBER() OVER (PARTITION BY hh_id ORDER BY hh_id, TC_date) AS RowNumber, hh_id,TC_date AS D1 FROM Trips
ORDER BY hh_id, TC_date) AS A
INNER JOIN
(SELECT ROW_NUMBER() OVER (PARTITION BY hh_id ORDER BY hh_id, TC_date)+ 1 AS rownumber2, hh_id,TC_date AS D2 FROM Trips
ORDER BY hh_id,TC_date) AS B
ON A.hh_id = B.hh_id AND A.RowNumber = B.rownumber2
WHERE datediff(D1,D2) < 30) AS K
WHERE pct_spent_top2 > 0.8) AS N
NATURAL JOIN 
(SELECT * FROM Households) AS O
GROUP BY O.hh_state;

## Plot with the distribution:
#i. Average number of items purchased on a given month.
#Assume all household cumulative average number of items purchased on a given month.

SELECT AVG(A.quantity_at_TC_prod_id), month(B.TC_date) AS month1 FROM 
purchases AS A
NATURAL JOIN
Trips AS B 
GROUP BY month(B.TC_date) ORDER BY month(B.TC_date);

#ii. Average number of shopping trips per month.
#Assume all household cumulative Average number of shopping trips per month.

SELECT ROUND(AVG(TC_id),3) AS avg_trips, MONTH(TC_date) AS month1 FROM Trips GROUP BY month1 ORDER BY month1;

#iii. Average number of days between 2 consecutive shopping trips.
SELECT DISTINCT A.hh_id, AVG(datediff(D1,D2)) AS avg_date_diff FROM
(SELECT ROW_NUMBER() OVER (PARTITION BY hh_id ORDER BY hh_id, TC_date) AS RowNumber, hh_id,TC_date AS D1 FROM Trips
ORDER BY hh_id, TC_date) AS A
INNER JOIN
(SELECT ROW_NUMBER() OVER (PARTITION BY hh_id ORDER BY hh_id, TC_date)+ 1 AS rownumber2, hh_id,TC_date AS D2 FROM Trips
ORDER BY hh_id,TC_date) AS B
ON A.hh_id = B.hh_id AND A.RowNumber = B.rownumber2 
GROUP BY A.hh_id;

###c. Answer
## Is the number of shopping trips per month correlated with the average number of items and reason the following questions: (Make informative visualizations) purchased?
## Is the average price paid per item correlated with the number of items purchased?
## Private Labeled products are the products with the same brand as the supermarket. In the data set they appear labeled as ‘CTL BR’
#i. What are the product categories that have proven to be more “Private labelled”
#ii. Is the expenditure share in Private Labeled products constant across months?
#iii. Cluster households in three income groups, Low, Medium and High. Report the average monthly expenditure on grocery. Study the % of private label share in their monthly expenditures. Use visuals to represent the intuition you are suggesting.