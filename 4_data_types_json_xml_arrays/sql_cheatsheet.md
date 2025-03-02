# SQL Data Types, JSON, XML, and Arrays Cheatsheet

This cheatsheet provides an exhaustive reference for working with special data types in SQL covered in the lesson:
1. JSON Functions
2. XML Handling
3. ARRAY Handling
4. String Functions and Regular Expressions

## 1. JSON Functions

### JSON Data Types

#### Database-Specific JSON Types
```sql
-- PostgreSQL
CREATE TABLE json_example (
    id SERIAL PRIMARY KEY,
    data JSON,                -- Standard JSON type
    data_b JSONB              -- Binary JSON type (more efficient)
);

-- MySQL
CREATE TABLE json_example (
    id INT AUTO_INCREMENT PRIMARY KEY,
    data JSON
);

-- SQL Server
CREATE TABLE json_example (
    id INT IDENTITY PRIMARY KEY,
    data NVARCHAR(MAX)        -- Stored as text, validated with functions
);

-- Oracle
CREATE TABLE json_example (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    data CLOB                 -- Stored as text, validated with IS JSON constraint
    CONSTRAINT ensure_json CHECK (data IS JSON)
);
```

### JSON Creation and Validation

#### Creating JSON Values
```sql
-- PostgreSQL
SELECT '{"name": "John", "age": 30}'::json;
SELECT jsonb_build_object('name', 'John', 'age', 30);

-- MySQL
SELECT JSON_OBJECT('name', 'John', 'age', 30);

-- SQL Server
SELECT '{"name": "John", "age": 30}';

-- Oracle
SELECT JSON_OBJECT('name' VALUE 'John', 'age' VALUE 30) FROM DUAL;
```

#### Validating JSON
```sql
-- PostgreSQL
SELECT jsonb_typeof('{"name": "John"}'::jsonb);  -- Returns 'object'

-- MySQL
SELECT JSON_VALID('{"name": "John"}');  -- Returns 1 if valid

-- SQL Server
SELECT ISJSON('{"name": "John"}');  -- Returns 1 if valid

-- Oracle
SELECT JSON_VALID('{"name": "John"}') FROM DUAL;  -- Returns 'true' if valid
```

### JSON Extraction and Querying

#### Extracting Values (Path-based)
```sql
-- PostgreSQL
SELECT data->'name' FROM json_example;                  -- Returns JSON
SELECT data->>'name' FROM json_example;                 -- Returns text
SELECT jsonb_extract_path(data, 'address', 'city') FROM json_example;

-- MySQL
SELECT JSON_EXTRACT(data, '$.name') FROM json_example;  -- Returns JSON
SELECT JSON_UNQUOTE(JSON_EXTRACT(data, '$.name')) FROM json_example;  -- Returns string
SELECT data->'$.name' FROM json_example;                -- Shorthand operator

-- SQL Server
SELECT JSON_VALUE(data, '$.name') FROM json_example;    -- Returns scalar value
SELECT JSON_QUERY(data, '$.address') FROM json_example; -- Returns JSON object/array

-- Oracle
SELECT JSON_VALUE(data, '$.name') FROM json_example;    -- Returns scalar value
SELECT JSON_QUERY(data, '$.address') FROM json_example; -- Returns JSON object/array
```

#### Querying JSON Arrays
```sql
-- PostgreSQL
SELECT data->'tags'->0 FROM json_example;               -- First array element
SELECT jsonb_array_elements(data->'tags') FROM json_example;  -- Unnest array

-- MySQL
SELECT JSON_EXTRACT(data, '$.tags[0]') FROM json_example;  -- First array element
SELECT JSON_EXTRACT(data, '$.tags[*]') FROM json_example;  -- All array elements

-- SQL Server
SELECT JSON_VALUE(data, '$.tags[0]') FROM json_example;    -- First array element
SELECT j.value FROM json_example CROSS APPLY OPENJSON(data, '$.tags') j;  -- Unnest array

-- Oracle
SELECT JSON_VALUE(data, '$.tags[0]') FROM json_example;    -- First array element
SELECT j.* FROM json_example, JSON_TABLE(data, '$.tags[*]' COLUMNS (value VARCHAR2(100) PATH '$')) j;  -- Unnest array
```

#### Filtering with JSON Conditions
```sql
-- PostgreSQL
SELECT * FROM json_example WHERE data->>'age' = '30';
SELECT * FROM json_example WHERE (data->'address'->>'city') = 'New York';
SELECT * FROM json_example WHERE data @> '{"tags": ["sql"]}'::jsonb;  -- Contains

-- MySQL
SELECT * FROM json_example WHERE JSON_EXTRACT(data, '$.age') = 30;
SELECT * FROM json_example WHERE JSON_EXTRACT(data, '$.address.city') = 'New York';
SELECT * FROM json_example WHERE JSON_CONTAINS(data, '"sql"', '$.tags');

-- SQL Server
SELECT * FROM json_example WHERE JSON_VALUE(data, '$.age') = 30;
SELECT * FROM json_example WHERE JSON_VALUE(data, '$.address.city') = 'New York';
SELECT * FROM json_example WHERE EXISTS (
    SELECT * FROM OPENJSON(data, '$.tags') WHERE value = 'sql'
);

-- Oracle
SELECT * FROM json_example WHERE JSON_VALUE(data, '$.age' RETURNING NUMBER) = 30;
SELECT * FROM json_example WHERE JSON_VALUE(data, '$.address.city') = 'New York';
SELECT * FROM json_example WHERE JSON_EXISTS(data, '$.tags[*]?(@ == "sql")');
```

### JSON Modification

#### Modifying JSON Values
```sql
-- PostgreSQL
UPDATE json_example 
SET data = jsonb_set(data::jsonb, '{name}', '"Jane"'::jsonb)
WHERE id = 1;

-- MySQL
UPDATE json_example 
SET data = JSON_SET(data, '$.name', 'Jane')
WHERE id = 1;

-- SQL Server
UPDATE json_example 
SET data = JSON_MODIFY(data, '$.name', 'Jane')
WHERE id = 1;

-- Oracle
UPDATE json_example 
SET data = JSON_TRANSFORM(data, SET '$.name' = 'Jane')
WHERE id = 1;
```

#### Adding Elements
```sql
-- PostgreSQL
UPDATE json_example 
SET data = jsonb_set(data::jsonb, '{contact}', '{"email": "jane@example.com"}'::jsonb)
WHERE id = 1;

-- MySQL
UPDATE json_example 
SET data = JSON_INSERT(data, '$.contact', JSON_OBJECT('email', 'jane@example.com'))
WHERE id = 1;

-- SQL Server
UPDATE json_example 
SET data = JSON_MODIFY(data, '$.contact', JSON_QUERY('{"email": "jane@example.com"}'))
WHERE id = 1;

-- Oracle
UPDATE json_example 
SET data = JSON_TRANSFORM(data, SET '$.contact' = JSON_OBJECT('email' VALUE 'jane@example.com'))
WHERE id = 1;
```

#### Removing Elements
```sql
-- PostgreSQL
UPDATE json_example 
SET data = data::jsonb - 'age'
WHERE id = 1;

-- MySQL
UPDATE json_example 
SET data = JSON_REMOVE(data, '$.age')
WHERE id = 1;

-- SQL Server
UPDATE json_example 
SET data = JSON_MODIFY(data, '$.age', NULL)
WHERE id = 1;

-- Oracle
UPDATE json_example 
SET data = JSON_TRANSFORM(data, REMOVE '$.age')
WHERE id = 1;
```

### JSON to Relational Conversion

#### JSON to Rows (Table)
```sql
-- PostgreSQL
SELECT id, 
       jsonb_array_elements(data->'items')
FROM json_example;

-- MySQL
SELECT id, 
       items.*
FROM json_example,
     JSON_TABLE(data, '$.items[*]' COLUMNS (
         item_name VARCHAR(100) PATH '$.name',
         price DECIMAL(10,2) PATH '$.price'
     )) AS items;

-- SQL Server
SELECT id, 
       j.item_name,
       j.price
FROM json_example
CROSS APPLY OPENJSON(data, '$.items')
WITH (
    item_name VARCHAR(100) '$.name',
    price DECIMAL(10,2) '$.price'
) AS j;

-- Oracle
SELECT id, 
       j.item_name,
       j.price
FROM json_example,
     JSON_TABLE(data, '$.items[*]' COLUMNS (
         item_name VARCHAR2(100) PATH '$.name',
         price NUMBER PATH '$.price'
     )) j;
```

#### Aggregating to JSON
```sql
-- PostgreSQL
SELECT 
    customer_id,
    jsonb_agg(jsonb_build_object('product', product_name, 'quantity', quantity)) AS orders
FROM orders
GROUP BY customer_id;

-- MySQL
SELECT 
    customer_id,
    JSON_ARRAYAGG(JSON_OBJECT('product', product_name, 'quantity', quantity)) AS orders
FROM orders
GROUP BY customer_id;

-- SQL Server
SELECT 
    customer_id,
    (SELECT product_name, quantity
     FROM orders o2
     WHERE o2.customer_id = o1.customer_id
     FOR JSON PATH) AS orders
FROM orders o1
GROUP BY customer_id;

-- Oracle
SELECT 
    customer_id,
    JSON_ARRAYAGG(JSON_OBJECT('product' VALUE product_name, 'quantity' VALUE quantity)) AS orders
FROM orders
GROUP BY customer_id;
```

## 2. XML Handling

### XML Data Types and Creation

#### Database-Specific XML Types
```sql
-- SQL Server
CREATE TABLE xml_example (
    id INT IDENTITY PRIMARY KEY,
    data XML
);

-- PostgreSQL
CREATE TABLE xml_example (
    id SERIAL PRIMARY KEY,
    data XML
);

-- Oracle
CREATE TABLE xml_example (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    data XMLTYPE
);
```

#### Creating XML Values
```sql
-- SQL Server
SELECT '<person><name>John</name><age>30</age></person>' AS xml_data;

-- PostgreSQL
SELECT XMLPARSE(CONTENT '<person><name>John</name><age>30</age></person>');
SELECT '<person><name>John</name><age>30</age></person>'::xml;

-- Oracle
SELECT XMLTYPE('<person><name>John</name><age>30</age></person>') FROM DUAL;
```

### XML Querying with XPath

#### Extracting Values
```sql
-- SQL Server
SELECT 
    data.value('(/person/name)[1]', 'VARCHAR(100)') AS name,
    data.value('(/person/age)[1]', 'INT') AS age
FROM xml_example;

-- PostgreSQL
SELECT 
    XMLCAST(XMLQUERY('/person/name/text()' PASSING BY REF data) AS VARCHAR) AS name,
    XMLCAST(XMLQUERY('/person/age/text()' PASSING BY REF data) AS INTEGER) AS age
FROM xml_example;

-- Oracle
SELECT 
    EXTRACTVALUE(data, '/person/name') AS name,
    EXTRACTVALUE(data, '/person/age') AS age
FROM xml_example;
```

#### Filtering with XML Conditions
```sql
-- SQL Server
SELECT * FROM xml_example 
WHERE data.exist('/person/age[. > 25]') = 1;

-- PostgreSQL
SELECT * FROM xml_example 
WHERE XMLEXISTS('/person/age[. > 25]' PASSING BY REF data);

-- Oracle
SELECT * FROM xml_example 
WHERE EXISTSNODE(data, '/person/age[. > 25]') = 1;
```

### XML to Relational Conversion

#### XML to Rows (Table)
```sql
-- SQL Server
SELECT 
    t.c.value('@id', 'INT') AS item_id,
    t.c.value('name[1]', 'VARCHAR(100)') AS item_name,
    t.c.value('price[1]', 'DECIMAL(10,2)') AS price
FROM xml_example
CROSS APPLY data.nodes('/items/item') AS t(c);

-- PostgreSQL
SELECT 
    XMLTABLE.* 
FROM xml_example,
     XMLTABLE('/items/item' PASSING data
              COLUMNS 
                  item_id INT PATH '@id',
                  item_name VARCHAR(100) PATH 'name',
                  price DECIMAL(10,2) PATH 'price');

-- Oracle
SELECT 
    xt.* 
FROM xml_example,
     XMLTABLE('/items/item' PASSING data
              COLUMNS 
                  item_id NUMBER PATH '@id',
                  item_name VARCHAR2(100) PATH 'name',
                  price NUMBER PATH 'price') xt;
```

### XML Modification

#### Modifying XML Values
```sql
-- SQL Server
UPDATE xml_example
SET data.modify('replace value of (/person/name/text())[1] with "Jane"')
WHERE id = 1;

-- PostgreSQL (requires rebuilding the XML)
UPDATE xml_example
SET data = XMLPARSE(CONTENT REPLACE(XMLSERIALIZE(CONTENT data AS VARCHAR), 
                                   '<name>John</name>', 
                                   '<name>Jane</name>'))
WHERE id = 1;

-- Oracle
UPDATE xml_example
SET data = UPDATEXML(data, '/person/name/text()', 'Jane')
WHERE id = 1;
```

#### Adding Elements
```sql
-- SQL Server
UPDATE xml_example
SET data.modify('insert <email>john@example.com</email> as last into (/person)[1]')
WHERE id = 1;

-- Oracle
UPDATE xml_example
SET data = APPENDCHILDXML(data, '/person', XMLType('<email>john@example.com</email>'))
WHERE id = 1;
```

#### Removing Elements
```sql
-- SQL Server
UPDATE xml_example
SET data.modify('delete /person/age')
WHERE id = 1;

-- Oracle
UPDATE xml_example
SET data = DELETEXML(data, '/person/age')
WHERE id = 1;
```

## 3. ARRAY Handling

### Array Data Types

#### Database-Specific Array Types
```sql
-- PostgreSQL
CREATE TABLE array_example (
    id SERIAL PRIMARY KEY,
    tags TEXT[],
    scores INTEGER[]
);

-- MySQL (simulated with JSON)
CREATE TABLE array_example (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tags JSON,
    scores JSON
);

-- Oracle (using nested tables)
CREATE TYPE string_array AS TABLE OF VARCHAR2(100);
CREATE TYPE number_array AS TABLE OF NUMBER;

CREATE TABLE array_example (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tags string_array,
    scores number_array
) NESTED TABLE tags STORE AS tags_nt
  NESTED TABLE scores STORE AS scores_nt;
```

### Array Creation and Population

#### Creating Arrays
```sql
-- PostgreSQL
INSERT INTO array_example (tags, scores)
VALUES (ARRAY['sql', 'database', 'postgres'], ARRAY[85, 92, 78]);

-- Alternative syntax
INSERT INTO array_example (tags, scores)
VALUES ('{"sql", "database", "postgres"}', '{85, 92, 78}');

-- MySQL (using JSON)
INSERT INTO array_example (tags, scores)
VALUES (JSON_ARRAY('sql', 'database', 'mysql'), JSON_ARRAY(85, 92, 78));

-- Oracle
INSERT INTO array_example (tags, scores)
VALUES (string_array('sql', 'database', 'oracle'), number_array(85, 92, 78));
```

### Array Access and Manipulation

#### Accessing Array Elements
```sql
-- PostgreSQL
SELECT tags[1] FROM array_example;  -- First element (1-indexed)
SELECT scores[1:2] FROM array_example;  -- Range (elements 1 and 2)

-- MySQL (using JSON)
SELECT JSON_EXTRACT(tags, '$[0]') FROM array_example;  -- First element (0-indexed)
SELECT JSON_EXTRACT(scores, '$[0 to 1]') FROM array_example;  -- Range

-- Oracle
SELECT t.column_value FROM array_example, TABLE(tags) t WHERE ROWNUM <= 1;  -- First element
```

#### Array Functions
```sql
-- PostgreSQL
SELECT array_length(tags, 1) FROM array_example;  -- Array length
SELECT array_to_string(tags, ', ') FROM array_example;  -- Join elements
SELECT array_append(tags, 'newitem') FROM array_example;  -- Add element
SELECT array_remove(tags, 'sql') FROM array_example;  -- Remove element
SELECT array_cat(tags, ARRAY['extra1', 'extra2']) FROM array_example;  -- Concatenate arrays

-- MySQL (using JSON)
SELECT JSON_LENGTH(tags) FROM array_example;  -- Array length
SELECT JSON_ARRAY_APPEND(tags, '$', 'newitem') FROM array_example;  -- Add element
SELECT JSON_REMOVE(tags, '$[0]') FROM array_example;  -- Remove element

-- Oracle
SELECT CARDINALITY(tags) FROM array_example;  -- Array length
```

### Array Querying

#### Filtering with Array Conditions
```sql
-- PostgreSQL
SELECT * FROM array_example WHERE 'sql' = ANY(tags);  -- Contains element
SELECT * FROM array_example WHERE tags @> ARRAY['sql', 'database'];  -- Contains all elements
SELECT * FROM array_example WHERE tags && ARRAY['sql', 'java'];  -- Overlaps (shares elements)
SELECT * FROM array_example WHERE array_length(tags, 1) > 2;  -- Array length check

-- MySQL (using JSON)
SELECT * FROM array_example WHERE JSON_CONTAINS(tags, '"sql"');  -- Contains element
SELECT * FROM array_example WHERE JSON_LENGTH(tags) > 2;  -- Array length check

-- Oracle
SELECT * FROM array_example WHERE EXISTS (
    SELECT 1 FROM TABLE(tags) t WHERE t.column_value = 'sql'
);  -- Contains element
```

### Array to Rows Conversion

#### Unnesting Arrays
```sql
-- PostgreSQL
SELECT id, unnest(tags) AS tag FROM array_example;  -- One row per array element

-- MySQL (using JSON)
SELECT id, j.tag
FROM array_example,
     JSON_TABLE(tags, '$[*]' COLUMNS (
         tag VARCHAR(100) PATH '$'
     )) AS j;

-- Oracle
SELECT id, t.column_value AS tag
FROM array_example, TABLE(tags) t;
```

### Aggregating to Arrays

```sql
-- PostgreSQL
SELECT 
    customer_id,
    array_agg(product_name) AS products,
    array_agg(DISTINCT product_name) AS unique_products
FROM orders
GROUP BY customer_id;

-- MySQL (using JSON)
SELECT 
    customer_id,
    JSON_ARRAYAGG(product_name) AS products
FROM orders
GROUP BY customer_id;

-- Oracle
SELECT 
    customer_id,
    CAST(COLLECT(product_name) AS string_array) AS products
FROM orders
GROUP BY customer_id;
```

## 4. String Functions and Regular Expressions

### Basic String Functions

#### String Manipulation
```sql
-- Length
SELECT LENGTH('Hello');  -- PostgreSQL, MySQL, SQLite
SELECT LEN('Hello');  -- SQL Server
SELECT LENGTH('Hello') FROM DUAL;  -- Oracle

-- Concatenation
SELECT 'Hello' || ' ' || 'World';  -- PostgreSQL, SQLite, Oracle
SELECT CONCAT('Hello', ' ', 'World');  -- All databases
SELECT 'Hello' + ' ' + 'World';  -- SQL Server

-- Case conversion
SELECT UPPER('hello'), LOWER('WORLD');  -- All databases

-- Substring
SELECT SUBSTRING('Hello World', 1, 5);  -- PostgreSQL, MySQL, SQL Server
SELECT SUBSTR('Hello World', 1, 5);  -- Oracle, SQLite, PostgreSQL

-- Trim
SELECT TRIM(' Hello ');  -- All databases (removes spaces from both ends)
SELECT LTRIM(' Hello ');  -- Left trim
SELECT RTRIM('Hello ');  -- Right trim

-- Replace
SELECT REPLACE('Hello World', 'World', 'SQL');  -- All databases

-- Position/Index
SELECT POSITION('World' IN 'Hello World');  -- PostgreSQL, MySQL
SELECT INSTR('Hello World', 'World');  -- Oracle, SQLite
SELECT CHARINDEX('World', 'Hello World');  -- SQL Server
```

#### String Formatting
```sql
-- Left/Right pad
SELECT LPAD('Hello', 10, '*');  -- '****Hello'
SELECT RPAD('Hello', 10, '*');  -- 'Hello****'

-- Format numbers
SELECT TO_CHAR(1234.56, '9,999.99');  -- PostgreSQL, Oracle
SELECT FORMAT(1234.56, 2);  -- SQL Server, MySQL

-- Format dates
SELECT TO_CHAR(CURRENT_DATE, 'YYYY-MM-DD');  -- PostgreSQL, Oracle
SELECT FORMAT(GETDATE(), 'yyyy-MM-dd');  -- SQL Server
SELECT DATE_FORMAT(CURRENT_DATE, '%Y-%m-%d');  -- MySQL
```

### Regular Expressions

#### Pattern Matching
```sql
-- PostgreSQL
SELECT * FROM users WHERE name ~ '^A.*';  -- Starts with 'A'
SELECT * FROM users WHERE name ~* '^a.*';  -- Case-insensitive
SELECT * FROM users WHERE name !~ '^A.*';  -- Negation

-- MySQL
SELECT * FROM users WHERE name REGEXP '^A.*';  -- Starts with 'A'
SELECT * FROM users WHERE name REGEXP BINARY '^A.*';  -- Case-sensitive
SELECT * FROM users WHERE NOT name REGEXP '^A.*';  -- Negation

-- Oracle
SELECT * FROM users WHERE REGEXP_LIKE(name, '^A.*');  -- Starts with 'A'
SELECT * FROM users WHERE REGEXP_LIKE(name, '^a.*', 'i');  -- Case-insensitive
SELECT * FROM users WHERE NOT REGEXP_LIKE(name, '^A.*');  -- Negation

-- SQL Server
SELECT * FROM users WHERE name LIKE 'A%';  -- Simple pattern
SELECT * FROM users WHERE name LIKE '[A-Z]%';  -- Character range
SELECT * FROM users WHERE name LIKE '[^A-Z]%';  -- Negated range
```

#### Regex Extraction
```sql
-- PostgreSQL
SELECT REGEXP_MATCHES('abc123', '([a-z]+)(\d+)');  -- Returns array: {abc,123}
SELECT (REGEXP_MATCHES('abc123', '([a-z]+)(\d+)'))[1];  -- Returns 'abc'

-- MySQL
SELECT REGEXP_SUBSTR('abc123', '[a-z]+');  -- Returns 'abc'
SELECT REGEXP_SUBSTR('abc123', '[0-9]+');  -- Returns '123'

-- Oracle
SELECT REGEXP_SUBSTR('abc123', '[a-z]+') FROM DUAL;  -- Returns 'abc'
SELECT REGEXP_SUBSTR('abc123', '[0-9]+') FROM DUAL;  -- Returns '123'

-- SQL Server (limited regex support)
SELECT SUBSTRING('abc123', PATINDEX('%[0-9]%', 'abc123'), 
                LEN('abc123') - PATINDEX('%[0-9]%', 'abc123') + 1);  -- Returns '123'
```

#### Regex Replacement
```sql
-- PostgreSQL
SELECT REGEXP_REPLACE('abc123', '\d+', 'XYZ');  -- Returns 'abcXYZ'

-- MySQL
SELECT REGEXP_REPLACE('abc123', '[0-9]+', 'XYZ');  -- Returns 'abcXYZ'

-- Oracle
SELECT REGEXP_REPLACE('abc123', '[0-9]+', 'XYZ') FROM DUAL;  -- Returns 'abcXYZ'

-- SQL Server
SELECT REPLACE('abc123', '123', 'XYZ');  -- Simple replacement only
```

### Email Validation Example
```sql
-- PostgreSQL
SELECT email FROM users 
WHERE email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';

-- MySQL
SELECT email FROM users 
WHERE email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$';

-- Oracle
SELECT email FROM users 
WHERE REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- SQL Server (using LIKE for simple patterns)
SELECT email FROM users 
WHERE email LIKE '%@%.%' 
AND email NOT LIKE '%@%@%';
```

### Advanced String Processing

#### String Splitting
```sql
-- PostgreSQL
SELECT unnest(string_to_array('apple,banana,orange', ','));

-- MySQL
SELECT SUBSTRING_INDEX(SUBSTRING_INDEX('apple,banana,orange', ',', n.n), ',', -1) AS value
FROM (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3
) n
WHERE n.n <= LENGTH('apple,banana,orange') - LENGTH(REPLACE('apple,banana,orange', ',', '')) + 1;

-- SQL Server
SELECT value FROM STRING_SPLIT('apple,banana,orange', ',');

-- Oracle
SELECT REGEXP_SUBSTR('apple,banana,orange', '[^,]+', 1, LEVEL) AS value
FROM DUAL
CONNECT BY REGEXP_SUBSTR('apple,banana,orange', '[^,]+', 1, LEVEL) IS NOT NULL;
```

#### String Aggregation
```sql
-- PostgreSQL
SELECT string_agg(name, ', ') FROM users;
SELECT string_agg(name, ', ' ORDER BY name) FROM users;

-- MySQL
SELECT GROUP_CONCAT(name SEPARATOR ', ') FROM users;
SELECT GROUP_CONCAT(name ORDER BY name SEPARATOR ', ') FROM users;

-- SQL Server
SELECT STRING_AGG(name, ', ') FROM users;
SELECT STRING_AGG(name, ', ') WITHIN GROUP (ORDER BY name) FROM users;

-- Oracle
SELECT LISTAGG(name, ', ') WITHIN GROUP (ORDER BY name) FROM users;
```

#### Full-Text Search
```sql
-- PostgreSQL
SELECT * FROM articles 
WHERE to_tsvector('english', content) @@ to_tsquery('english', 'database & query');

-- MySQL
SELECT * FROM articles 
WHERE MATCH(title, content) AGAINST('database query' IN NATURAL LANGUAGE MODE);

-- SQL Server
SELECT * FROM articles 
WHERE CONTAINS(content, 'database AND query');

-- Oracle
SELECT * FROM articles 
WHERE CONTAINS(content, 'database AND query') > 0;
``` 