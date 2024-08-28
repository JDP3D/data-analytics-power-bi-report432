-- 2.Print a list of the columns in the orders table and save the result to a csv file called orders_columns.csv

-- 3.Repeat the same process for each other table in the database, saving the results to a csv file with the same name as the table

SELECT COLUMN_NAME FROM information_schema.columns 
WHERE table_name = 'orders_powerbi' 

SELECT COLUMN_NAME FROM information_schema.columns 
WHERE table_name = 'dim_products'

SELECT COLUMN_NAME FROM information_schema.columns 
WHERE table_name = 'dim_stores'

SELECT COLUMN_NAME FROM information_schema.columns 
WHERE table_name = 'dim_users'
-- Could not retrieve the column names as this table doesn't have the correct headers