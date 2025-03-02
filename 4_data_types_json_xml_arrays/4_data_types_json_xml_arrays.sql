-- 4. DATA TYPES, JSON, XML, AND ARRAYS
-- This file covers handling special data types in SQL including JSON, XML, and arrays

-- 4.1 JSON Functions (JSON_EXTRACT(), JSON_TABLE(), JSONB)
-- Example of JSON extraction from the master query
SELECT 
    main_table.column1,
    JSON_EXTRACT(main_table.json_column, '$.key') AS extracted_value
FROM main_table;

-- Additional JSON function examples
-- MySQL/MariaDB style
SELECT 
    id,
    JSON_EXTRACT(json_data, '$.name') AS name,
    JSON_EXTRACT(json_data, '$.address.city') AS city,
    JSON_EXTRACT(json_data, '$.phones[0]') AS primary_phone
FROM customer_data;

-- PostgreSQL style (JSONB)
SELECT 
    id,
    json_data->'name' AS name,
    json_data->'address'->>'city' AS city,
    json_data->'phones'->0 AS primary_phone
FROM customer_data;

-- 4.2 XML Handling (XMLTable(), XMLQUERY())
-- Oracle/SQL Server style XML query
SELECT 
    id,
    XMLQUERY('/customer/name/text()' PASSING customer_xml) AS customer_name,
    XMLQUERY('/customer/address/city/text()' PASSING customer_xml) AS city
FROM customer_xml_data;

-- Using XMLTable (Oracle style)
SELECT x.id, x.name, x.city
FROM customer_xml_data,
XMLTABLE('/customer' PASSING customer_xml
    COLUMNS
        id NUMBER PATH '@id',
        name VARCHAR2(100) PATH 'name',
        city VARCHAR2(100) PATH 'address/city'
) x;

-- 4.3 ARRAY Handling (ARRAY_AGG(), STRING_AGG(), LISTAGG())
-- Example of LISTAGG from the master query
SELECT 
    main_table.column1,
    LISTAGG(main_table.category, ', ') WITHIN GROUP (ORDER BY main_table.category) AS aggregated_list
FROM main_table
GROUP BY main_table.column1;

-- PostgreSQL array aggregation
SELECT 
    department_id,
    ARRAY_AGG(employee_name ORDER BY employee_name) AS employees
FROM employees
GROUP BY department_id;

-- SQL Server string aggregation
SELECT 
    department_id,
    STRING_AGG(employee_name, ', ') WITHIN GROUP (ORDER BY employee_name) AS employees
FROM employees
GROUP BY department_id;

-- Note: These functions allow SQL to work with complex data structures beyond simple scalar values.
-- Different database systems may have different syntax for these operations. 