-- Exploratory Data Analysis
USE project;

-- 1. What is the most sold item?
SELECT DISTINCT
Item,
sum(Quantity) AS Total_Quantity
FROM cafe_sales_copy
GROUP BY 1
ORDER BY 2 DESC; -- Coffee is the most sold item with 3929

-- 2. Average sales
SELECT
min(`Total Spent`) AS Min_Spent,
max(`Total Spent`) AS Max_Spent,
round(avg(`Total Spent`), 2) AS Average_sales
FROM cafe_sales_copy; -- Average sales is 8.94

-- 3. What are customers' spending habits?
WITH distribution_table AS (
SELECT
	CASE
		WHEN `Total Spent` BETWEEN 1.00 AND 5.00 THEN '1.00 - 5.00'
        WHEN `Total Spent` BETWEEN 5.00 AND 10.00 THEN '5.00 - 10.00'
        WHEN `Total Spent` BETWEEN 10.00 AND 15.00 THEN '10.00 - 15.00'
        WHEN `Total Spent` BETWEEN 15.00 AND 20.00 THEN '15.00 - 20.00'
        ELSE 'Over 20'
        END AS total_spent_range,
        count(*) AS Frequency
FROM cafe_sales_copy
GROUP BY 1
)
SELECT
total_spent_range,
Frequency,
concat(round(Frequency * 100 / (SELECT sum(Frequency) FROM distribution_table) , 2), '%') AS percentage
FROM distribution_table
GROUP BY 1
ORDER BY 2 DESC; -- Almost 70% of the total spent in a single transaction ranges between $1.00 and $10.00

-- 4. Which item has the highest sales?
SELECT
Item,
sum(`Total Spent`) AS Total_sales,
concat(round((sum(`Total Spent`) * 100 / (SELECT sum(`Total Spent`) FROM cafe_sales_copy)), 2), '%') AS percentage
FROM cafe_sales_copy
GROUP BY 1
ORDER BY 2 DESC; -- Salad has the highest sales with 19240

-- 5. Sales by payment method
SELECT
`Payment Method`,
sum(`Total Spent`) AS Total_sales,
concat(round((sum(`Total Spent`) * 100 / (SELECT sum(`Total Spent`) FROM cafe_sales_copy)), 2), '%') AS percentage
FROM cafe_sales_copy
GROUP BY 1
ORDER BY 2 DESC; -- Credit Card is the known payment method that has the highest sales

-- 6. Sales by location
SELECT
Location,
sum(`Total Spent`) AS Total_sales,
concat(round((sum(`Total Spent`) * 100 / (SELECT sum(`Total Spent`) FROM cafe_sales_copy)), 2), '%') AS percentage
FROM cafe_sales_copy
GROUP BY 1
ORDER BY 2 DESC; -- In-store is the known location that has the highest sales

-- 7. Sales by month
SELECT
monthname(`Transaction Date`) AS `month`,
sum(`Total Spent`) AS Total_sales,
concat(round((sum(`Total Spent`) * 100 / (SELECT sum(`Total Spent`) FROM cafe_sales_copy)), 2), '%') AS percentage
FROM cafe_sales_copy
GROUP BY 1
ORDER BY 2 DESC; -- January has the hightest sales with 7808.50 but pretty even across the board

-- 8. Which item is the best-seller each month?
WITH best_seller_by_month AS (
SELECT
Item,
monthname(`Transaction Date`) AS `month`,
sum(Quantity) AS Total_Sold,
ROW_NUMBER() OVER (PARTITION BY monthname(`Transaction Date`) ORDER BY sum(Quantity) DESC) AS `rank`
FROM cafe_sales_copy
GROUP BY 1, 2
)
SELECT
`month`,
Item,
Total_Sold
FROM best_seller_by_month
WHERE `rank` = 1
ORDER BY FIELD(`month`,
  'January','February','March','April','May','June',
  'July','August','September','October','November','December');

/*
January: Sandwich was the best-seller with 361 sold.
February: Coffee topped the list with 310 sold.
March: Coffee again led with 368 sold.
April: Salad was the most popular, with 346 sold.
May: Sandwich returned to the top with 314 sold.
June: Coffee remained strong with 349 sold.
July: Salad led the month with 348 sold.
August: Tea was the top-seller, with 331 sold.
September: Cookie took the lead with 334 sold.
October: Coffee dominated again with 390 sold.
November: Salad was the best-seller with 332 sold.
December: Coffee finished the year strong with 345 sold.
*/


-- 9. Sales by season
SELECT
	CASE
		WHEN month(`Transaction Date`) = 1 THEN 'Winter'
        WHEN month(`Transaction Date`) = 2 THEN 'Winter'
        WHEN month(`Transaction Date`) = 3 THEN 'Spring'
        WHEN month(`Transaction Date`) = 4 THEN 'Spring'
        WHEN month(`Transaction Date`) = 5 THEN 'Spring'
        WHEN month(`Transaction Date`) = 6 THEN 'Summer'
        WHEN month(`Transaction Date`) = 7 THEN 'Summer'
        WHEN month(`Transaction Date`) = 8 THEN 'Summer'
        WHEN month(`Transaction Date`) = 9 THEN 'Fall'
        WHEN month(`Transaction Date`) = 10 THEN 'Fall'
        WHEN month(`Transaction Date`) = 11 THEN 'Fall'
        WHEN month(`Transaction Date`) = 12 THEN 'Winter'
	END AS season,
sum(`Total Spent`) AS Total_sales,
concat(round((sum(`Total Spent`) * 100 / (SELECT sum(`Total Spent`) FROM cafe_sales_copy)), 2), '%') AS percentage
FROM cafe_sales_copy
GROUP BY 1
ORDER BY 2 DESC; -- Spring has the hightest sales with 22687.50 but pretty even across the board

-- 10. Sales by day
SELECT
dayname(`Transaction Date`) AS `Day of Week`,
sum(`Total Spent`) AS Total_sales,
concat(round((sum(`Total Spent`) * 100 / (SELECT sum(`Total Spent`) FROM cafe_sales_copy)), 2), '%') AS percentage
FROM cafe_sales_copy
GROUP BY 1
ORDER BY 2 DESC; -- Thursday has the highest sale with 13062.50
