# SQL Reporting and Pivoting Cheatsheet

This cheatsheet provides a comprehensive reference for SQL reporting and pivoting techniques:
1. Pivoting Techniques
2. Aggregated String Concatenation
3. Advanced Reporting Techniques

## 1. Pivoting Techniques

### PIVOT Operator (Converting Rows to Columns)

#### SQL Server
```sql
-- Basic PIVOT syntax
SELECT *
FROM (
    SELECT category, sales_amount FROM sales_table
) src
PIVOT (
    SUM(sales_amount) FOR category IN ([Electronics], [Clothing], [Groceries])
) AS pivot_table;

-- PIVOT with multiple columns
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

-- PIVOT with date grouping
SELECT *
FROM (
    SELECT 
        DATEPART(QUARTER, sale_date) AS quarter,
        product_category,
        sales_amount
    FROM sales_data
    WHERE YEAR(sale_date) = 2023
) AS source_data
PIVOT (
    SUM(sales_amount)
    FOR quarter IN ([1], [2], [3], [4])
) AS quarterly_sales;
```

#### Oracle
```sql
-- Using PIVOT operator
SELECT *
FROM (
    SELECT category, sales_amount FROM sales_table
)
PIVOT (
    SUM(sales_amount) FOR category IN ('Electronics' AS electronics, 
                                      'Clothing' AS clothing, 
                                      'Groceries' AS groceries)
);

-- PIVOT with multiple aggregations
SELECT *
FROM (
    SELECT category, sales_amount, quantity FROM sales_table
)
PIVOT (
    SUM(sales_amount) AS sales, 
    AVG(quantity) AS avg_qty
    FOR category IN ('Electronics' AS electronics, 
                    'Clothing' AS clothing, 
                    'Groceries' AS groceries)
);
```

### UNPIVOT Operator (Converting Columns to Rows)

#### SQL Server
```sql
-- Basic UNPIVOT syntax
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

-- UNPIVOT with multiple measure columns
SELECT product_id, region, measure_type, measure_value
FROM (
    SELECT 
        product_id, 
        north_sales, north_quantity,
        south_sales, south_quantity,
        east_sales, east_quantity,
        west_sales, west_quantity
    FROM product_sales
) AS p
UNPIVOT (
    measure_value FOR measure_type IN (
        north_sales, north_quantity,
        south_sales, south_quantity,
        east_sales, east_quantity,
        west_sales, west_quantity
    )
) AS unpvt;
```

#### Oracle
```sql
-- Basic UNPIVOT syntax
SELECT product_id, region, sales_amount
FROM product_sales
UNPIVOT (
    sales_amount FOR region IN (
        north_sales AS 'North',
        south_sales AS 'South',
        east_sales AS 'East',
        west_sales AS 'West'
    )
);

-- UNPIVOT with INCLUDE NULLS option
SELECT product_id, region, sales_amount
FROM product_sales
UNPIVOT INCLUDE NULLS (
    sales_amount FOR region IN (
        north_sales AS 'North',
        south_sales AS 'South',
        east_sales AS 'East',
        west_sales AS 'West'
    )
);
```

### CASE-Based Pivoting (Cross-Database Compatible)

```sql
-- Simple CASE-based pivot
SELECT 
    product_line,
    SUM(CASE WHEN category = 'Electronics' THEN sales_amount ELSE 0 END) AS electronics_sales,
    SUM(CASE WHEN category = 'Clothing' THEN sales_amount ELSE 0 END) AS clothing_sales,
    SUM(CASE WHEN category = 'Groceries' THEN sales_amount ELSE 0 END) AS groceries_sales,
    SUM(sales_amount) AS total_sales
FROM sales_data
GROUP BY product_line
ORDER BY total_sales DESC;

-- CASE-based pivot with multiple aggregations
SELECT 
    product_line,
    SUM(CASE WHEN category = 'Electronics' THEN sales_amount ELSE 0 END) AS electronics_sales,
    AVG(CASE WHEN category = 'Electronics' THEN quantity ELSE NULL END) AS electronics_avg_qty,
    SUM(CASE WHEN category = 'Clothing' THEN sales_amount ELSE 0 END) AS clothing_sales,
    AVG(CASE WHEN category = 'Clothing' THEN quantity ELSE NULL END) AS clothing_avg_qty,
    SUM(sales_amount) AS total_sales
FROM sales_data
GROUP BY product_line;

-- Quarterly pivot report
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
```

### Dynamic Pivot Queries

#### SQL Server (Using Dynamic SQL)
```sql
-- Dynamic pivot query
DECLARE @columns NVARCHAR(MAX) = '';
DECLARE @sql NVARCHAR(MAX) = '';

-- Get the column names dynamically
SELECT @columns = @columns + QUOTENAME(category) + ',' 
FROM (SELECT DISTINCT category FROM sales_table) AS categories
ORDER BY category;

-- Remove the trailing comma
SET @columns = LEFT(@columns, LEN(@columns) - 1);

-- Build the dynamic SQL
SET @sql = '
SELECT *
FROM (
    SELECT product, category, sales_amount FROM sales_table
) src
PIVOT (
    SUM(sales_amount) FOR category IN (' + @columns + ')
) AS pivot_table;';

-- Execute the dynamic SQL
EXEC sp_executesql @sql;
```

#### PostgreSQL (Using crosstab)
```sql
-- First, install the tablefunc extension
CREATE EXTENSION IF NOT EXISTS tablefunc;

-- Use crosstab function for pivoting
SELECT *
FROM crosstab(
    'SELECT 
        product, 
        category, 
        sales_amount 
     FROM sales_table 
     ORDER BY 1, 2',
    'SELECT DISTINCT category FROM sales_table ORDER BY 1'
) AS pivot_table (
    product TEXT,
    "Electronics" NUMERIC,
    "Clothing" NUMERIC,
    "Groceries" NUMERIC
);
```

## 2. Aggregated String Concatenation

### Oracle (LISTAGG)
```sql
-- Basic LISTAGG
SELECT 
    department_id,
    LISTAGG(employee_name, ', ') WITHIN GROUP (ORDER BY employee_name) AS employee_list
FROM employees
GROUP BY department_id;

-- LISTAGG with filtering
SELECT 
    department_id,
    LISTAGG(employee_name, ', ') WITHIN GROUP (ORDER BY salary DESC) AS top_employees
FROM employees
WHERE salary > 50000
GROUP BY department_id;

-- LISTAGG with ON OVERFLOW options (Oracle 12c+)
SELECT 
    department_id,
    LISTAGG(employee_name, ', ' ON OVERFLOW TRUNCATE '...') 
        WITHIN GROUP (ORDER BY employee_name) AS employee_list
FROM employees
GROUP BY department_id;
```

### PostgreSQL (STRING_AGG)
```sql
-- Basic STRING_AGG
SELECT 
    department_id,
    STRING_AGG(employee_name, ', ' ORDER BY employee_name) AS employee_list
FROM employees
GROUP BY department_id;

-- STRING_AGG with filtering
SELECT 
    department_id,
    STRING_AGG(employee_name, ', ' ORDER BY hire_date DESC) AS newest_employees
FROM employees
WHERE hire_date > '2020-01-01'
GROUP BY department_id;

-- STRING_AGG with DISTINCT
SELECT 
    department_id,
    STRING_AGG(DISTINCT city, ', ' ORDER BY city) AS employee_cities
FROM employees
GROUP BY department_id;
```

### SQL Server (STRING_AGG - SQL Server 2017+)
```sql
-- Basic STRING_AGG
SELECT 
    department_id,
    STRING_AGG(employee_name, ', ') WITHIN GROUP (ORDER BY employee_name) AS employee_list
FROM employees
GROUP BY department_id;

-- STRING_AGG with filtering
SELECT 
    department_id,
    STRING_AGG(employee_name, ', ') WITHIN GROUP (ORDER BY salary DESC) AS top_employees
FROM employees
WHERE salary > 50000
GROUP BY department_id;

-- For older SQL Server versions (using FOR XML PATH)
SELECT 
    department_id,
    STUFF((
        SELECT ', ' + employee_name
        FROM employees e2
        WHERE e2.department_id = e1.department_id
        ORDER BY employee_name
        FOR XML PATH('')
    ), 1, 2, '') AS employee_list
FROM employees e1
GROUP BY department_id;
```

### MySQL (GROUP_CONCAT)
```sql
-- Basic GROUP_CONCAT
SELECT 
    department_id,
    GROUP_CONCAT(employee_name ORDER BY employee_name SEPARATOR ', ') AS employee_list
FROM employees
GROUP BY department_id;

-- GROUP_CONCAT with DISTINCT
SELECT 
    department_id,
    GROUP_CONCAT(DISTINCT job_title ORDER BY job_title SEPARATOR ', ') AS department_roles
FROM employees
GROUP BY department_id;

-- GROUP_CONCAT with custom separator and limit
SELECT 
    department_id,
    GROUP_CONCAT(
        employee_name 
        ORDER BY salary DESC 
        SEPARATOR ' | '
    ) AS top_employees
FROM employees
GROUP BY department_id;
```

## 3. Advanced Reporting Techniques

### Cross-Tabulation Reports

```sql
-- Cross-tabulation with row and column totals
SELECT 
    COALESCE(product_category, 'Total') AS product_category,
    SUM(CASE WHEN region = 'North' THEN sales_amount ELSE 0 END) AS north_sales,
    SUM(CASE WHEN region = 'South' THEN sales_amount ELSE 0 END) AS south_sales,
    SUM(CASE WHEN region = 'East' THEN sales_amount ELSE 0 END) AS east_sales,
    SUM(CASE WHEN region = 'West' THEN sales_amount ELSE 0 END) AS west_sales,
    SUM(sales_amount) AS total_sales
FROM sales_data
GROUP BY ROLLUP(product_category)
ORDER BY 
    CASE WHEN product_category = 'Total' THEN 1 ELSE 0 END, 
    product_category;

-- Cross-tabulation with multiple dimensions
SELECT 
    COALESCE(product_category, 'Total') AS product_category,
    COALESCE(sales_channel, 'Total') AS sales_channel,
    SUM(CASE WHEN quarter = 'Q1' THEN sales_amount ELSE 0 END) AS Q1_sales,
    SUM(CASE WHEN quarter = 'Q2' THEN sales_amount ELSE 0 END) AS Q2_sales,
    SUM(CASE WHEN quarter = 'Q3' THEN sales_amount ELSE 0 END) AS Q3_sales,
    SUM(CASE WHEN quarter = 'Q4' THEN sales_amount ELSE 0 END) AS Q4_sales,
    SUM(sales_amount) AS total_sales
FROM sales_data
GROUP BY GROUPING SETS (
    (product_category, sales_channel),
    (product_category),
    ()
)
ORDER BY 
    CASE WHEN product_category IS NULL THEN 1 ELSE 0 END,
    product_category,
    CASE WHEN sales_channel IS NULL THEN 1 ELSE 0 END,
    sales_channel;
```

### Percentage Calculations

```sql
-- Percentage of total
SELECT 
    product_category,
    SUM(sales_amount) AS category_sales,
    SUM(SUM(sales_amount)) OVER () AS total_sales,
    ROUND(100.0 * SUM(sales_amount) / SUM(SUM(sales_amount)) OVER (), 2) AS percentage
FROM sales_data
GROUP BY product_category
ORDER BY category_sales DESC;

-- Percentage of group total
SELECT 
    region,
    product_category,
    SUM(sales_amount) AS category_sales,
    SUM(SUM(sales_amount)) OVER (PARTITION BY region) AS region_total,
    ROUND(100.0 * SUM(sales_amount) / SUM(SUM(sales_amount)) OVER (PARTITION BY region), 2) AS percentage
FROM sales_data
GROUP BY region, product_category
ORDER BY region, percentage DESC;

-- Running percentage
SELECT 
    product_category,
    SUM(sales_amount) AS category_sales,
    SUM(SUM(sales_amount)) OVER () AS total_sales,
    ROUND(100.0 * SUM(sales_amount) / SUM(SUM(sales_amount)) OVER (), 2) AS percentage,
    ROUND(100.0 * SUM(SUM(sales_amount)) OVER (ORDER BY SUM(sales_amount) DESC) / 
          SUM(SUM(sales_amount)) OVER (), 2) AS running_percentage
FROM sales_data
GROUP BY product_category
ORDER BY category_sales DESC;
```

### Time-Based Reporting

```sql
-- Month-over-month comparison
SELECT 
    FORMAT(sale_date, 'yyyy-MM') AS month,
    SUM(sales_amount) AS monthly_sales,
    LAG(SUM(sales_amount)) OVER (ORDER BY MIN(sale_date)) AS previous_month_sales,
    ROUND(100.0 * (SUM(sales_amount) - LAG(SUM(sales_amount)) OVER (ORDER BY MIN(sale_date))) / 
          LAG(SUM(sales_amount)) OVER (ORDER BY MIN(sale_date)), 2) AS percentage_change
FROM sales_data
GROUP BY FORMAT(sale_date, 'yyyy-MM')
ORDER BY month;

-- Year-to-date totals
SELECT 
    FORMAT(sale_date, 'yyyy-MM') AS month,
    SUM(sales_amount) AS monthly_sales,
    SUM(SUM(sales_amount)) OVER (
        PARTITION BY YEAR(sale_date) 
        ORDER BY MIN(sale_date)
        ROWS UNBOUNDED PRECEDING
    ) AS ytd_sales
FROM sales_data
GROUP BY FORMAT(sale_date, 'yyyy-MM'), YEAR(sale_date)
ORDER BY month;

-- Rolling averages
SELECT 
    sale_date,
    SUM(sales_amount) AS daily_sales,
    AVG(SUM(sales_amount)) OVER (
        ORDER BY sale_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS seven_day_moving_avg
FROM sales_data
GROUP BY sale_date
ORDER BY sale_date;
```

### Hierarchical Reporting

```sql
-- Hierarchical sales report (SQL Server)
WITH sales_hierarchy AS (
    SELECT 
        region,
        country,
        city,
        SUM(sales_amount) AS sales_amount
    FROM sales_data
    GROUP BY region, country, city
)
SELECT 
    CASE 
        WHEN city IS NULL AND country IS NULL THEN 'Total'
        WHEN city IS NULL THEN region
        WHEN country IS NOT NULL AND city IS NULL THEN region + ' - ' + country
        ELSE region + ' - ' + country + ' - ' + city
    END AS location,
    sales_amount,
    CASE 
        WHEN city IS NULL AND country IS NULL THEN 0  -- Total level
        WHEN country IS NULL THEN 1  -- Region level
        WHEN city IS NULL THEN 2  -- Country level
        ELSE 3  -- City level
    END AS level
FROM sales_hierarchy
GROUP BY ROLLUP(region, country, city)
ORDER BY 
    COALESCE(region, 'ZZZ'),
    COALESCE(country, 'ZZZ'),
    COALESCE(city, 'ZZZ');

-- Hierarchical sales report (Oracle)
SELECT 
    LPAD(' ', 2 * (LEVEL - 1)) || 
    CASE 
        WHEN LEVEL = 1 THEN 'Total'
        WHEN LEVEL = 2 THEN region
        WHEN LEVEL = 3 THEN country
        WHEN LEVEL = 4 THEN city
    END AS location,
    SUM(sales_amount) AS sales_amount
FROM sales_data
START WITH region IS NULL
CONNECT BY PRIOR region = region AND PRIOR country IS NULL
       OR PRIOR country = country AND PRIOR city IS NULL
GROUP BY LEVEL, region, country, city
ORDER BY LEVEL, region, country, city;
```

### Conditional Aggregation

```sql
-- Conditional counts
SELECT 
    department_id,
    COUNT(*) AS total_employees,
    COUNT(CASE WHEN salary > 50000 THEN 1 END) AS high_salary_count,
    COUNT(CASE WHEN YEAR(hire_date) = 2023 THEN 1 END) AS new_hires,
    COUNT(CASE WHEN performance_rating >= 4 THEN 1 END) AS top_performers
FROM employees
GROUP BY department_id;

-- Conditional averages
SELECT 
    department_id,
    AVG(salary) AS avg_salary,
    AVG(CASE WHEN gender = 'M' THEN salary END) AS avg_male_salary,
    AVG(CASE WHEN gender = 'F' THEN salary END) AS avg_female_salary,
    AVG(CASE WHEN years_of_service > 5 THEN salary END) AS avg_experienced_salary
FROM employees
GROUP BY department_id;

-- Conditional sums
SELECT 
    product_category,
    SUM(sales_amount) AS total_sales,
    SUM(CASE WHEN discount_applied = 1 THEN sales_amount END) AS discounted_sales,
    SUM(CASE WHEN discount_applied = 0 THEN sales_amount END) AS regular_sales,
    ROUND(100.0 * SUM(CASE WHEN discount_applied = 1 THEN sales_amount END) / 
          SUM(sales_amount), 2) AS discount_percentage
FROM sales_data
GROUP BY product_category;
``` 