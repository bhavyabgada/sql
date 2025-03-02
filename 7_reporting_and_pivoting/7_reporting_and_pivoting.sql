-- 7. REPORTING & PIVOTING
-- This file covers SQL techniques for reporting and data transformation

-- 7.1 Pivoting (PIVOT, UNPIVOT)
-- Example of PIVOT from the master query
SELECT *
FROM (
    SELECT category, sales_amount FROM sales_table
) src
PIVOT (
    SUM(sales_amount) FOR category IN ('Electronics', 'Clothing', 'Groceries')
) AS pivot_table;

-- SQL Server style PIVOT with more details
SELECT *
FROM (
    SELECT 
        product_category,
        sales_region,
        sales_amount
    FROM sales_data
) AS source_data
PIVOT (
    SUM(sales_amount)
    FOR sales_region IN ([North], [South], [East], [West])
) AS pivot_result;

-- UNPIVOT example (SQL Server style)
SELECT product_id, region, sales_amount
FROM (
    SELECT 
        product_id, 
        north_sales, 
        south_sales, 
        east_sales, 
        west_sales
    FROM product_sales
) AS p
UNPIVOT (
    sales_amount FOR region IN (north_sales, south_sales, east_sales, west_sales)
) AS unpvt;

-- 7.2 Aggregated String Concatenation (LISTAGG(), STRING_AGG())
-- Example of LISTAGG from the master query
SELECT 
    main_table.column1,
    LISTAGG(main_table.category, ', ') WITHIN GROUP (ORDER BY main_table.category) AS aggregated_list
FROM main_table
GROUP BY main_table.column1;

-- PostgreSQL string aggregation
SELECT 
    department_id,
    STRING_AGG(employee_name, ', ' ORDER BY employee_name) AS employee_list
FROM employees
GROUP BY department_id;

-- MySQL string aggregation
SELECT 
    department_id,
    GROUP_CONCAT(employee_name ORDER BY employee_name SEPARATOR ', ') AS employee_list
FROM employees
GROUP BY department_id;

-- Combining pivoting with aggregation for complex reports
SELECT 
    product_line,
    SUM(CASE WHEN quarter = 'Q1' THEN sales_amount ELSE 0 END) AS Q1_sales,
    SUM(CASE WHEN quarter = 'Q2' THEN sales_amount ELSE 0 END) AS Q2_sales,
    SUM(CASE WHEN quarter = 'Q3' THEN sales_amount ELSE 0 END) AS Q3_sales,
    SUM(CASE WHEN quarter = 'Q4' THEN sales_amount ELSE 0 END) AS Q4_sales,
    SUM(sales_amount) AS total_sales
FROM sales_data
GROUP BY product_line
ORDER BY total_sales DESC;

-- Note: These techniques transform row-based data into more report-friendly formats.
-- They are essential for business intelligence and reporting applications. 