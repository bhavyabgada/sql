BEGIN TRANSACTION;

-- Recursive CTE for hierarchical queries
WITH RECURSIVE recursive_cte AS (
    SELECT id, parent_id, name, 1 AS level
    FROM hierarchy_table
    WHERE parent_id IS NULL
    UNION ALL
    SELECT h.id, h.parent_id, h.name, r.level + 1
    FROM hierarchy_table h
    JOIN recursive_cte r ON h.parent_id = r.id
),
cte_name AS (
    SELECT column1, column2, 
           aggregate_function(column3) OVER (PARTITION BY column1 ORDER BY column2) AS window_func_result
    FROM table_name
    WHERE condition
    GROUP BY column1, column2
    HAVING aggregate_condition
    ORDER BY column1 DESC
    LIMIT 100
)
SELECT 
    main_table.column1, 
    main_table.column2, 
    subquery_table.derived_column, 
    JSON_EXTRACT(main_table.json_column, '$.key') AS extracted_value,
    CASE 
        WHEN main_table.condition_column = 'value' THEN 'result_1'
        ELSE 'result_2'
    END AS case_result,
    (SELECT COUNT(*) FROM another_table WHERE another_table.foreign_key = main_table.id) AS subquery_result,
    ROW_NUMBER() OVER (PARTITION BY main_table.column1 ORDER BY main_table.column2) AS row_number_rank,
    LISTAGG(main_table.category, ', ') WITHIN GROUP (ORDER BY main_table.category) AS aggregated_list
FROM main_table
FULL OUTER JOIN another_table ON main_table.id = another_table.foreign_key
LEFT JOIN (
    SELECT foreign_key, COUNT(*) AS derived_column
    FROM yet_another_table
    GROUP BY foreign_key
) AS subquery_table ON main_table.id = subquery_table.foreign_key
WHERE main_table.filter_column IN (SELECT DISTINCT column_name FROM referenced_table)
AND EXISTS (
    SELECT 1 FROM some_table WHERE some_table.ref_id = main_table.id
)
AND main_table.boolean_column = TRUE
GROUP BY main_table.column1, main_table.column2, subquery_table.derived_column
HAVING COUNT(main_table.column3) > 10
ORDER BY main_table.column1 ASC, subquery_result DESC
LIMIT 50
FOR UPDATE;

-- Modification Queries
INSERT INTO log_table (query_executed, timestamp)
VALUES ('SELECT query executed', CURRENT_TIMESTAMP);

UPDATE some_table
SET column_name = 'new_value'
WHERE id IN (SELECT id FROM main_table WHERE column_name = 'something');

DELETE FROM another_table
WHERE NOT EXISTS (SELECT 1 FROM main_table WHERE main_table.id = another_table.foreign_key);

MERGE INTO main_table AS target
USING (SELECT * FROM source_table) AS source
ON target.id = source.id
WHEN MATCHED THEN 
    UPDATE SET target.value = source.value
WHEN NOT MATCHED THEN
    INSERT (id, value) VALUES (source.id, source.value);

-- Creating a trigger for automatic update logging
CREATE TRIGGER after_update_trigger
AFTER UPDATE ON some_table
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, operation, timestamp)
    VALUES ('some_table', 'UPDATE', CURRENT_TIMESTAMP);
END;

-- Creating a stored procedure for dynamic query execution
CREATE PROCEDURE DynamicQueryExecution(IN sql_query TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
    EXECUTE sql_query;
END;
$$;

-- PIVOT query (SQL Server, Oracle-style)
SELECT *
FROM (
    SELECT category, sales_amount FROM sales_table
) src
PIVOT (
    SUM(sales_amount) FOR category IN ('Electronics', 'Clothing', 'Groceries')
) AS pivot_table;

COMMIT; 