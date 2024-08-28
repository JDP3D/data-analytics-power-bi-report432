-- Which month in 2022 has had the highest revenue?
-- There is no date table, not sure if this is meant to be. I used the dates orders_powerbi table

SELECT
    TO_CHAR(TO_Date("Order Date", 'YYYY-MM-DD'), 'Month') as top_month_by_revenue_2022,
    ROUND((SUM(sale_price * "Product Quantity"))::numeric, 2) AS total_revenue
FROM
    dim_products
JOIN
    orders_powerbi ON dim_products.product_code = orders_powerbi.product_code
WHERE
    date_part('year', TO_Date("Order Date", 'YYYY-MM-DD')) = 2022
GROUP BY
    top_month_by_revenue_2022
ORDER BY
    total_revenue Desc
LIMIT
    1