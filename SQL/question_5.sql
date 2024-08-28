-- 5.Which product category generated the most profit for the "Wiltshire, UK" region in 2021?

SELECT
    category AS most_profitable_product_category_wiltshire_uk_2021,
    ROUND(SUM((sale_price - cost_price) * "Product Quantity")::numeric, 2) as Profit
FROM
    dim_products
JOIN
    orders_powerbi ON orders_powerbi.product_code = dim_products.product_code
JOIN
    dim_stores ON dim_stores."store code" = orders_powerbi."Store Code"
WHERE
    date_part('year', TO_Date("Order Date", 'YYYY-MM-DD')) = 2021 AND
    country_region = 'Wiltshire' AND country_code = 'GB'
GROUP BY
    category
ORDER BY
    profit DESC
LIMIT
    1

