-- 2. ADVANCED QUERY TECHNIQUES
-- This file covers advanced SQL query techniques including joins, subqueries, CTEs, and window functions

-- 2.1 Joins (INNER, LEFT, RIGHT, FULL OUTER, CROSS)
-- Example of FULL OUTER JOIN and LEFT JOIN from master query
SELECT 
    main_table.column1, 
    main_table.column2, 
    subquery_table.derived_column
FROM main_table
FULL OUTER JOIN another_table ON main_table.id = another_table.foreign_key
LEFT JOIN (
    SELECT foreign_key, COUNT(*) AS derived_column
    FROM yet_another_table
    GROUP BY foreign_key
) AS subquery_table ON main_table.id = subquery_table.foreign_key;

-- 2.2 Subqueries (EXISTS, IN, NOT IN, SCALAR SUBQUERY)
-- Example of EXISTS, IN, and scalar subquery
SELECT 
    main_table.column1,
    (SELECT COUNT(*) FROM another_table WHERE another_table.foreign_key = main_table.id) AS subquery_result
FROM main_table
WHERE main_table.filter_column IN (SELECT DISTINCT column_name FROM referenced_table)
AND EXISTS (
    SELECT 1 FROM some_table WHERE some_table.ref_id = main_table.id
);

-- Example of NOT EXISTS in DELETE statement (from basic commands)
DELETE FROM another_table
WHERE NOT EXISTS (SELECT 1 FROM main_table WHERE main_table.id = another_table.foreign_key);

-- 2.3 Common Table Expressions (CTE) (WITH, WITH RECURSIVE)
-- Basic CTE example
WITH cte_name AS (
    SELECT column1, column2, 
           aggregate_function(column3) OVER (PARTITION BY column1 ORDER BY column2) AS window_func_result
    FROM table_name
    WHERE condition
    GROUP BY column1, column2
    HAVING aggregate_condition
    ORDER BY column1 DESC
    LIMIT 100
)
SELECT * FROM cte_name;

-- 2.4 Window Functions (ROW_NUMBER(), RANK(), DENSE_RANK(), LAG(), LEAD(), NTILE())
-- Example of ROW_NUMBER() window function
SELECT 
    main_table.column1,
    main_table.column2,
    ROW_NUMBER() OVER (PARTITION BY main_table.column1 ORDER BY main_table.column2) AS row_number_rank
FROM main_table;

-- 2.5 Hierarchical Queries (CONNECT BY, WITH RECURSIVE)
-- Recursive CTE for hierarchical data
WITH RECURSIVE recursive_cte AS (
    SELECT id, parent_id, name, 1 AS level
    FROM hierarchy_table
    WHERE parent_id IS NULL
    UNION ALL
    SELECT h.id, h.parent_id, h.name, r.level + 1
    FROM hierarchy_table h
    JOIN recursive_cte r ON h.parent_id = r.id
)
SELECT * FROM recursive_cte;

-- Note: These advanced techniques allow for complex data manipulation and analysis.
-- They build upon the basic commands from the previous file. 