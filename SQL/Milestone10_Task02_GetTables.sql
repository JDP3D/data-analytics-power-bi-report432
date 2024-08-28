-- 1.Print a list of the tables in the database and save the result to a csv file for your reference.
SELECT table_name
FROM INFORMATION_SCHEMA.TABLES
WHERE table_type = 'BASE TABLE' 
AND table_schema = 'public'