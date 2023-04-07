                                                  SNOWFLAKE LIVE ASSIGNMENT OF DATA LOAD
                                                  --------------------------------------
                                                  
-- 1. Load the given dataset into snowflake with a primary key to Order Date column.

USE WAREHOUSE demo_warehouse;
USE DATABASE demo_database;

CREATE SCHEMA snowflake_assignment;
USE SCHEMA snowflake_assignment;

CREATE OR REPLACE TABLE assignment_sales_data
(
    order_id VARCHAR(25),
    order_date DATE NOT NULL PRIMARY KEY,    
    ship_date date,
    ship_mode VARCHAR(25),
    customer_name varchar(50),
    segment VARCHAR(15),
    state VARCHAR(50),
    country	VARCHAR(50),
    market	VARCHAR(30),
    region	VARCHAR(30),
    product_id VARCHAR(40),
    category VARCHAR(40),
    sub_category VARCHAR(20),
    product_name VARCHAR(200),
    -- sales VARCHAR(10),       
    sales NUMBER(10,3),   -- changed the data type from General to Numeric in the csv file only to remove comma from (1,648)
    quantity smallint,
    discount NUMBER(8,4),
    profit NUMBER(9,5),
    shipping_cost NUMBER(6,3),
    order_priority VARCHAR(20),
    year char(4)
);

DESC TABLE assignment_sales_data;
SELECT * FROM assignment_sales_data limit 100;
SELECT COUNT(*) FROM assignment_sales_data; -- 51290

-- Let's make a copy of the original table along with data (remember it won't copy the constraints)

CREATE OR REPLACE TABLE sales_with_data AS SELECT * FROM assignment_sales_data;

DESC TABLE sales_with_data; -- not null and primary key constraint was not copied

-- adding primary key
ALTER TABLE sales_with_data
ADD PRIMARY KEY (order_date); -- run successfully

-- adding not null constraints
ALTER TABLE sales_with_data
MODIFY COLUMN order_date NOT NULL;

-- 2. Change the Primary key to Order Id Column.

-- first drop the current primary key, otherwise it will give error like below
ALTER TABLE sales_with_data
ADD PRIMARY KEY (order_id); -- error: primary key already exists for table 'SALES_WITH_DATA'

ALTER TABLE sales_with_data
DROP PRIMARY KEY;

DESC TABLE sales_with_data; -- primary key is dropped

ALTER TABLE sales_with_data
ADD PRIMARY KEY (order_id);

-- 3. Check the data type for Order_date and Ship_date and mention in what data type it should be?
Ans: Valid date format for DATE data type in Snowflake is 'YYYY-MM-DD' and valid date format for DATE in excel is 'DD-MM-YYYY'.
     So, change the format of Order_date and Ship_date in the csv file itself before loading the data into the tabel. I have use
     text-to-column functionality of the excel to change the DATE format.

-- 4. Create a new column called order_extract and extract the number after the last ‘–‘from Order_ID column.

-- Use SUBSTRING(<base_expr>, <start_expr> [,<length_expr>])

ALTER TABLE sales_with_data
ADD COLUMN order_extract varchar(10);

UPDATE sales_with_data
SET order_extract = SUBSTRING(order_id,9,LENGTH(order_id));

SELECT * FROM sales_with_data LIMIT 10;

-- 5. Create a new column called Discount Flag and categorize it based on discount. Use ‘Yes’ if the discount is greater than zero else ‘No’
SELECT * , CASE
               WHEN discount > 0 then 'Yes'
               ELSE 'No' 
           END AS Discount_Flag
from sales_with_data
limit 100;

-- But, how to put this result into a new column
ALTER TABLE sales_with_data
ADD COLUMN discount_flag CHAR(3);

UPDATE sales_with_data
SET discount_flag = CASE
                      WHEN discount > 0 then 'Yes'
                      ELSE 'No' 
                    END;
                    
SELECT * FROM sales_with_data LIMIT 100;                    

-- 6. Create a new column called process days and calculate how many days it takes for each order id to process from the order to its shipment.

SELECT DATEDIFF('day',order_date,ship_date) PROCESS_DAYS
FROM sales_with_data;

ALTER TABLE sales_with_data
ADD COLUMN process_days INT;

UPDATE sales_with_data
SET process_days = DATEDIFF('day',order_date,ship_date);

SELECT * FROM sales_with_data LIMIT 100; 

-- 7. Create a new column called Rating and then based on the Process dates give rating like given below.
     /* a. If process days less than or equal to 3days then rating should be 5
        b. If process days are greater than 3 and less than or equal to 6 then rating should be 4
        c. If process days are greater than 6 and less than or equal to 10 then rating should be 3
        d. If process days are greater than 10 then the rating should be 2. */

ALTER TABLE sales_with_data
ADD COLUMN rating INT;

UPDATE sales_with_data
SET rating = CASE 
                WHEN process_days <= 3 then 5
                WHEN process_days > 3 and process_days <= 6 then 4
                WHEN process_days > 6 and process_days <= 10 then 3
                WHEN process_days > 10 then 2
             END;  

SELECT * FROM sales_with_data limit 100; 
