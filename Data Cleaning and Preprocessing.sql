-- Introduction of the dataset
/*
This dataset is from Kaggle, which records sales transactions from a cafe. 
It includes fields such as transcation ID, product name, quantity purchased, and so on.
These details provide valuable insights into sales performance from various perspectives.

Features:
Transaction ID: A unique identifier for each transaction.
Item: The name of the item purchased.
Quantity: The quantity of the item purchased.
Price Per Unit: The price of a single unit of the item.
Total Spent: The total amount spent on the transaction. Calculated as Quantity * Price Per Unit.
Payment Method: The method of payment used.
Location: The location where the transaction occurred.
Transaction Date: The date of the transaction.

Data Source: https://www.kaggle.com/datasets/ahmedmohamed2003/cafe-sales-dirty-data-for-cleaning-training/data
*/

-- Create a database
CREATE DATABASE project;
USE project;

SET SQL_SAFE_UPDATES = 0;

-- Import the dataset
-- I use the 'Table Data Import Wizard' to import the dataset.

-- To prevent any changes to the original data, I'll create a new table and work on a copy of the dataset.
CREATE TABLE cafe_sales_copy
LIKE cafe_sales;

INSERT cafe_sales_copy
SELECT * 
FROM cafe_sales;

SELECT * 
FROM cafe_sales_copy
LIMIT 5;

-- Data Cleaning and Preprocessing
-- Before diving into analysis, it is important to check the data for any inconsistencies such as missing or invalid values, 
-- and to perform necessary preprocessing to ensure data quality.

-- 1. Remove duplicates
-- Check for duplicates
WITH duplicate_cte AS (
	SELECT *, ROW_NUMBER() OVER (
    PARTITION BY `Transaction ID`, Item, Quantity, `Price Per Unit`, `Total Spent`, `Payment Method`, Location, `Transaction Date`
    ORDER BY `Transaction ID`) AS row_num
    FROM cafe_sales)
SELECT * FROM duplicate_cte
WHERE row_num > 1; -- There are no duplicates

-- 2. Standardize data
-- Checke if all unique IDs match in length
SELECT DISTINCT length(`Transaction ID`) as ID_length
FROM cafe_sales_copy; -- The length of all IDs is 11

 -- Standardize column 'Item'
 UPDATE cafe_sales_copy
 SET Item = NULL
 WHERE Item IN ('ERROR', 'UNKNOWN', '');
 
 -- Standardize column 'Quantity'
UPDATE cafe_sales_copy 
SET Quantity = NULL
WHERE Quantity IN ('ERROR', 'UNKNOWN', '');
 
 -- Correct datatype
ALTER TABLE cafe_sales_copy MODIFY Quantity INT;

-- Standardize column 'Price Per Unit'
-- Correct format
UPDATE cafe_sales_copy
SET `Price Per Unit` = 
			CASE
				WHEN `Price Per Unit` = '1.0' THEN '1.00'
                WHEN `Price Per Unit` = '1.5' THEN '1.50'
                WHEN `Price Per Unit` = '2.0' THEN '2.00'
                WHEN `Price Per Unit` = '3.0' THEN '3.00'
                WHEN `Price Per Unit` = '4.0' THEN '4.00'
                WHEN `Price Per Unit` = '5.0' THEN '5.00'
                ELSE NULL
			END;

-- Correct datatype
ALTER TABLE cafe_sales_copy MODIFY `Price Per Unit` DECIMAL(10,2);

-- Standardize column 'Total Spent'
-- Correct format
UPDATE cafe_sales_copy
SET `Total Spent` = 
			CASE
				WHEN `Total Spent` = '1.0' Then '1.00'
                WHEN `Total Spent` = '1.5' Then '1.50'
                WHEN `Total Spent` = '2.0' Then '2.00'
                WHEN `Total Spent` = '3.0' Then '3.00'
                WHEN `Total Spent` = '4.0' Then '4.00'
                WHEN `Total Spent` = '4.5' Then '4.50'
                WHEN `Total Spent` = '5.0' Then '5.00'
                WHEN `Total Spent` = '6.0' Then '6.00'
                WHEN `Total Spent` = '7.5' Then '7.50'
                WHEN `Total Spent` = '8.0' Then '8.00'
                WHEN `Total Spent` = '9.0' Then '9.00'
                WHEN `Total Spent` = '10.0' Then '10.00'
                WHEN `Total Spent` = '12.0' Then '12.00'
                WHEN `Total Spent` = '15.0' Then '15.00'
                WHEN `Total Spent` = '16.0' Then '16.00'
                WHEN `Total Spent` = '20.0' Then '20.00'
                WHEN `Total Spent` = '25.0' Then '25.00'
                ELSE NULL
			END;

-- Correct datatype
ALTER TABLE cafe_sales_copy MODIFY `Total Spent` DECIMAL(10,2);

-- Standardize column 'Payment Method'
UPDATE cafe_sales_copy
SET `Payment Method` = NULL
WHERE `Payment Method` IN ('ERROR', 'UNKNOWN', '');

-- Standardize column 'Location'
UPDATE cafe_sales_copy
SET Location = NULL 
WHERE Location IN ('ERROR', 'UNKNOWN', '');

-- Standardize column 'Transaction Date'
UPDATE cafe_sales_copy 
SET `Transaction Date` = NULL
WHERE `Transaction Date` IN ('ERROR', 'UNKNOWN', '');

-- Correct format
UPDATE cafe_sales_copy 
SET `Transaction Date` = STR_TO_DATE(`Transaction Date`, '%Y-%m-%d');

-- Correct datatype
ALTER TABLE cafe_sales_copy MODIFY `Transaction Date` DATE;


-- 3. Handle Missing Values
-- Missing values overview
SELECT
SUM(Item IS NULL) AS item_null,
SUM(Quantity IS NULL) AS quantity_null,
SUM(`Price Per Unit` IS NULL) AS price_per_unit_null,
SUM(`Total Spent` IS NULL) AS total_spent_null,
SUM(`Payment Method` IS NULL) AS payment_method_null,
SUM(Location IS NULL) AS location_null,
SUM(`Transaction Date` IS NULL) AS date_null
FROM cafe_sales_copy;

-- Fill in missing valus for column 'Price Per Unit'
-- First, I find the price per unit for each unique item
SELECT DISTINCT Item, 
`Price Per Unit`
FROM cafe_sales_copy
WHERE Item IS NOT NULL AND `Price Per Unit` IS NOT NULL;

-- Fill in missing values
UPDATE cafe_sales_copy
SET `Price Per Unit` = 3.00
WHERE `Price Per Unit` IS NULL AND Item = 'Cake';

UPDATE cafe_sales_copy
SET `Price Per Unit` = 2.00
WHERE `Price Per Unit` IS NULL AND Item = 'Coffee';

UPDATE cafe_sales_copy
SET `Price Per Unit` = 1.00
WHERE `Price Per Unit` IS NULL AND Item = 'Cookie';

UPDATE cafe_sales_copy
SET `Price Per Unit` = 3.00
WHERE `Price Per Unit` IS NULL AND Item = 'Juice';

UPDATE cafe_sales_copy
SET `Price Per Unit` = 5.00
WHERE `Price Per Unit` IS NULL AND Item = 'Salad';

UPDATE cafe_sales_copy
SET `Price Per Unit` = 4.00
WHERE `Price Per Unit` IS NULL AND Item = 'Sandwich';

UPDATE cafe_sales_copy
SET `Price Per Unit` = 4.00
WHERE `Price Per Unit` IS NULL AND Item = 'Smoothie';

UPDATE cafe_sales_copy
SET `Price Per Unit` = 1.50
WHERE `Price Per Unit` IS NULL AND Item = 'Tea';

UPDATE cafe_sales_copy
SET `Price Per Unit` = round(`Total Spent` / Quantity, 2)
WHERE `Price Per Unit` IS NULL AND (Quantity IS NOT NULL AND `Total Spent` IS NOT NULL);

-- Fill in missing values for column 'Total Spent'
UPDATE cafe_sales_copy 
SET `Total Spent` = Quantity * `Price Per Unit`
WHERE `Total Spent` IS NULL AND Quantity IS NOT NULL;

-- Fill in missing values for column 'Quantity'
UPDATE cafe_sales_copy 
SET Quantity = ROUND(`Total Spent` / `Price Per Unit`)
WHERE Quantity IS NULL AND `Total Spent` IS NOT NULL;

-- Fill in missing values for column 'Item'
UPDATE cafe_sales_copy 
SET Item = 'Cake/Juice'
WHERE Item IS NULL AND `Price Per Unit` = 3.00;

UPDATE cafe_sales_copy 
SET Item = 'Coffee'
WHERE Item IS NULL AND `Price Per Unit` = 2.00;

UPDATE cafe_sales_copy 
SET Item = 'Cookie'
WHERE Item IS NULL AND `Price Per Unit` = 1.00;

UPDATE cafe_sales_copy 
SET Item = 'Salad'
WHERE Item IS NULL AND `Price Per Unit` = 5.00;

UPDATE cafe_sales_copy 
SET Item = 'Sandwich/Smoothie'
WHERE Item IS NULL AND `Price Per Unit` = 4.00;

UPDATE cafe_sales_copy 
SET Item = 'Tea'
WHERE Item IS NULL AND `Price Per Unit` = 1.50;

-- Fill in missing values for column 'Payment Method'
UPDATE cafe_sales_copy 
SET `Payment Method` = 'Unknown'
WHERE `Payment Method` IS NULL;

-- Fill in missing values for column 'Location'
UPDATE cafe_sales_copy 
SET Location = 'Unknown'
WHERE Location IS NULL;

-- Fill in missing values for column 'Transaction Date'
WITH date_fix AS (
	SELECT 
	`Transaction ID`,
	COALESCE(`Transaction Date`, LAG(`Transaction Date`) OVER (ORDER BY `Transaction ID`)) AS filled_date
	FROM cafe_sales_copy
)
UPDATE cafe_sales_copy c1
JOIN date_fix c2
ON c1.`Transaction ID` = c2.`Transaction ID`
SET c1.`Transaction Date` = c2.filled_date;

-- Number of missing value at this point
SELECT
SUM(Item IS NULL) AS item_null,
SUM(Quantity IS NULL) AS quantity_null,
SUM(`Price Per Unit` IS NULL) AS price_per_unit_null,
SUM(`Total Spent` IS NULL) AS total_spent_null,
SUM(`Payment Method` IS NULL) AS payment_method_null,
SUM(Location IS NULL) AS location_null,
SUM(`Transaction Date` IS NULL) AS date_null
FROM cafe_sales_copy;

SELECT * FROM cafe_sales_copy
WHERE Item IS NULL OR
Quantity IS NULL OR
`Price Per Unit` IS NULL OR
`Total Spent` IS NULL; -- 26 rows containing the 52 NULL values

-- Find the mode values to fill the nulls where 'Price Per Unit' is known 
-- Find the most 'Total Spent' value when price per unit is 5.00
SELECT DISTINCT 
`Total Spent`, 
COUNT(`Total Spent`) AS frequency 
FROM cafe_sales_copy
WHERE `Price Per Unit` = 5.00
GROUP BY `Total Spent`
ORDER BY 1 DESC
lIMIT 1; -- 25.00 is the most frequency total when unit price is 5.00

-- Find the most 'Total Spent' value when price per unit is 4.00
SELECT DISTINCT 
`Total Spent`, 
COUNT(`Total Spent`) AS frequency 
FROM cafe_sales_copy
WHERE `Price Per Unit` = 4.00
GROUP BY `Total Spent`
ORDER BY 1 DESC
LIMIT 1; -- 20.00 is the most frequency total when unit price is 4.00

-- Find the most 'Total Spent' value when price per unit is 3.00
SELECT DISTINCT 
`Total Spent`, 
COUNT(`Total Spent`) AS frequency 
FROM cafe_sales_copy
WHERE `Price Per Unit` = 3.00
GROUP BY `Total Spent`
ORDER BY 1 DESC
LIMIT 1; -- 15.00 is the most frequency total when unit price is 3.00

-- Find the most 'Total Spent' value when price per unit is 2.00
SELECT DISTINCT 
`Total Spent`, 
COUNT(`Total Spent`) AS frequency 
FROM cafe_sales_copy
WHERE `Price Per Unit` = 2.00
GROUP BY `Total Spent`
ORDER BY 1 DESC
LIMIT 1; -- 10.00 is the most frequency total when unit price is 2.00

-- Find the most 'Total Spent' value when price per unit is 1.50
SELECT DISTINCT 
`Total Spent`, 
COUNT(`Total Spent`) AS frequency 
FROM cafe_sales_copy
WHERE `Price Per Unit` = 1.50
GROUP BY `Total Spent`
ORDER BY 1 DESC
LIMIT 1; -- 7.50 is the most frequency total when unit price is 1.50

-- Find the most 'Total Spent' value when price per unit is 1.00
SELECT DISTINCT 
`Total Spent`, 
COUNT(`Total Spent`) AS frequency 
FROM cafe_sales_copy
WHERE `Price Per Unit` = 1.00
GROUP BY `Total Spent`
ORDER BY 1 DESC
LIMIT 1; -- 5.00 is the most frequency total when unit price is 1.00

-- Fill in the null values with the mode
-- Fill in where price per unit is 5.00 and other columns are null
UPDATE cafe_sales_copy
SET `Total Spent` = 25.00,
    Quantity = 5
WHERE `Price Per Unit` = 5.00 AND (Quantity IS NULL AND `Total Spent` IS NULL);

-- Fill in where price per unit is 4.00 and other columns are null
UPDATE cafe_sales_copy
SET `Total Spent` = 20.00,
    Quantity = 5
WHERE `Price Per Unit` = 4.00 AND (Quantity IS NULL AND `Total Spent` IS NULL);

-- Fill in where price per unit is 3.00 and other columns are null
UPDATE cafe_sales_copy
SET `Total Spent` = 15.00,
    Quantity = 5
WHERE `Price Per Unit` = 3.00 AND (Quantity IS NULL AND `Total Spent` IS NULL);

-- Fill in where price per unit is 2.00 and other columns are null
UPDATE cafe_sales_copy
SET `Total Spent` = 10.00,
    Quantity = 5
WHERE `Price Per Unit` = 2.00 AND (Quantity IS NULL AND `Total Spent` IS NULL);

-- Fill in where price per unit is 1.50 and other columns are null
UPDATE cafe_sales_copy
SET `Total Spent` = 7.50,
    Quantity = 5
WHERE `Price Per Unit` = 1.50 AND (Quantity IS NULL AND `Total Spent` IS NULL);

-- Fill in where price per unit is 1.00 and other columns are null
UPDATE cafe_sales_copy
SET `Total Spent` = 5.00,
    Quantity = 5
WHERE `Price Per Unit` = 1.00 AND (Quantity IS NULL AND `Total Spent` IS NULL);

-- Find the mode values to fill the nulls where 'Total Spent' is known
-- Find the most 'Price Per Unit' value when total spent is 25.00
SELECT DISTINCT 
`Price Per Unit`, 
COUNT(`Price Per Unit`)
FROM cafe_sales_copy
WHERE `Total Spent` = 25.00
GROUP BY `Price Per Unit`
ORDER BY 1 DESC
LIMIT 1; -- 5.00 is the most frequent 'Price Per Unit' when 'Total Spent' is 25.00

-- Find the most 'Price Per Unit' value when total spent is 20.00
SELECT DISTINCT 
`Price Per Unit`, 
COUNT(`Price Per Unit`)
FROM cafe_sales_copy
WHERE `Total Spent` = 20.00
GROUP BY `Price Per Unit`
ORDER BY 1 DESC
LIMIT 1; -- 5.00 is the most frequent 'Price Per Unit' when 'Total Spent' is 20.00

-- Find the most 'Price Per Unit' value when total spent is 9.00
SELECT DISTINCT 
`Price Per Unit`, 
COUNT(`Price Per Unit`)
FROM cafe_sales_copy
WHERE `Total Spent` = 9.00
GROUP BY `Price Per Unit`
ORDER BY 1 DESC
LIMIT 1; -- 3.00 is the most frequent 'Price Per Unit' when 'Total Spent' is 9.00

-- Fill in the null values with the mode
-- Fill in where total spent is 25.00 and other columns are null
UPDATE cafe_sales_copy
SET Item = 'Salad',
	Quantity = 5,
    `Price Per Unit` = 5.00
WHERE `Total Spent` = 25.00 AND (Item IS NULL AND Quantity IS NULL AND `Price Per Unit` IS NULL);

-- Fill in where total spent is 20.00 and other columns are null
UPDATE cafe_sales_copy
SET Item = 'Salad',
	Quantity = 4,
    `Price Per Unit` = 5.00
WHERE `Total Spent` = 20.00 AND (Item IS NULL AND Quantity IS NULL AND `Price Per Unit` IS NULL);

-- Fill in where total spent is 9.00 and other columns are null
UPDATE cafe_sales_copy
SET Item = 'Cake/Juice',
	Quantity = 3,
    `Price Per Unit` = 3.00
WHERE `Total Spent` = 9.00 AND (Item IS NULL AND Quantity IS NULL AND `Price Per Unit` IS NULL);

-- Find the mode values to fill the nulls where 'Quantity' is known
-- Find the most 'Total Spent' Value when quantity is 4
SELECT DISTINCT 
`Total Spent`, 
COUNT(`Total Spent`)
FROM cafe_sales_copy
WHERE Quantity = 4
GROUP BY `Total Spent`
ORDER BY 1 DESC 
LIMIT 1; -- 20.00 is the most frequency Total Spent when quantity is 4

-- Find the most 'Total Spent' Value when quantity is 2
SELECT DISTINCT 
`Total Spent`, 
COUNT(`Total Spent`)
FROM cafe_sales_copy
WHERE Quantity = 2
GROUP BY `Total Spent`
ORDER BY 1 DESC 
LIMIT 1; -- 10.00 is the most frequency Total Spent When quantity is 2

-- Fill in the null values with the mode
-- Fill in where quantity is 4 and other columns are null
UPDATE cafe_sales_copy
SET Item = 'Salad',
    `Price Per Unit` = 5.00,
	`Total Spent` = 20.00
WHERE Quantity = 4 AND (Item IS NULL AND `Price Per Unit` IS NULL AND `Total Spent` IS NULL);

-- Fill in where quantity is 2 and other columns are null
UPDATE cafe_sales_copy
SET Item = 'Salad',
    `Price Per Unit` = 5.00,
	`Total Spent` = 10.00
WHERE Quantity = 2 AND (Item IS NULL AND `Price Per Unit` IS NULL AND `Total Spent` IS NULL);

-- Number of missing value at this point
SELECT
SUM(Item IS NULL) AS item_null,
SUM(Quantity IS NULL) AS quantity_null,
SUM(`Price Per Unit` IS NULL) AS price_per_unit_null,
SUM(`Total Spent` IS NULL) AS total_spent_null,
SUM(`Payment Method` IS NULL) AS payment_method_null,
SUM(Location IS NULL) AS location_null,
SUM(`Transaction Date` IS NULL) AS date_null
FROM cafe_sales_copy; -- All columns have no missing values

