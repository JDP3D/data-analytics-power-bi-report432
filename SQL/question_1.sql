-- 1.How many staff are there in all of the UK stores?

Select 
    SUM("staff numbers") AS "number of UK staff"
FROM 
    dim_stores
WHERE
    country_code = 'GB'