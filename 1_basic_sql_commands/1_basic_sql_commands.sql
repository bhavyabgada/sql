-- 1. BASIC SQL COMMANDS
-- This file covers the fundamental SQL commands: SELECT, INSERT, UPDATE, DELETE, and basic clauses

-- 1.1 SELECT, FROM, WHERE
-- Basic query structure with selection criteria
SELECT 
    main_table.column1, 
    main_table.column2
FROM main_table
WHERE main_table.boolean_column = TRUE;

-- 1.2 INSERT, UPDATE, DELETE, MERGE (Upsert)
-- Adding new data
INSERT INTO log_table (query_executed, timestamp)
VALUES ('SELECT query executed', CURRENT_TIMESTAMP);

-- Modifying existing data
UPDATE some_table
SET column_name = 'new_value'
WHERE id IN (SELECT id FROM main_table WHERE column_name = 'something');

-- Removing data
DELETE FROM another_table
WHERE NOT EXISTS (SELECT 1 FROM main_table WHERE main_table.id = another_table.foreign_key);

-- MERGE (Upsert) - Insert or update based on condition
MERGE INTO main_table AS target
USING (SELECT * FROM source_table) AS source
ON target.id = source.id
WHEN MATCHED THEN 
    UPDATE SET target.value = source.value
WHEN NOT MATCHED THEN
    INSERT (id, value) VALUES (source.id, source.value);

-- 1.3 GROUP BY, HAVING, ORDER BY, LIMIT
-- Grouping and filtering aggregated data
SELECT column1, column2, COUNT(*) as count
FROM table_name
GROUP BY column1, column2
HAVING COUNT(*) > 10
ORDER BY column1 ASC
LIMIT 50;

-- Note: The above examples demonstrate the basic structure of SQL commands.
-- In real applications, these would be used with actual table and column names. 