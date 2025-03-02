# SQL Procedural Programming Cheatsheet

This cheatsheet provides an exhaustive reference for procedural SQL programming covered in the lesson:
1. Stored Procedures
2. Functions
3. Triggers
4. Cursors
5. Control Flow Statements
6. Error Handling
7. Dynamic SQL

## 1. Stored Procedures

### Basic Stored Procedure Syntax

#### SQL Server
```sql
CREATE PROCEDURE procedure_name
    @param1 datatype,
    @param2 datatype
AS
BEGIN
    -- SQL statements
    SELECT * FROM table_name WHERE column1 = @param1;
END;
```

#### MySQL
```sql
DELIMITER //
CREATE PROCEDURE procedure_name(
    IN param1 datatype,
    IN param2 datatype
)
BEGIN
    -- SQL statements
    SELECT * FROM table_name WHERE column1 = param1;
END //
DELIMITER ;
```

#### PostgreSQL
```sql
CREATE OR REPLACE PROCEDURE procedure_name(
    param1 datatype,
    param2 datatype
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- SQL statements
    SELECT * FROM table_name WHERE column1 = param1;
END;
$$;
```

#### Oracle
```sql
CREATE OR REPLACE PROCEDURE procedure_name(
    param1 IN datatype,
    param2 IN datatype
)
AS
BEGIN
    -- SQL statements
    SELECT * FROM table_name WHERE column1 = param1;
END;
/
```

### Parameter Types

#### Input Parameters
```sql
-- SQL Server
CREATE PROCEDURE get_employee
    @employee_id INT
AS
BEGIN
    SELECT * FROM employees WHERE id = @employee_id;
END;

-- MySQL
CREATE PROCEDURE get_employee(
    IN employee_id INT
)
BEGIN
    SELECT * FROM employees WHERE id = employee_id;
END;

-- PostgreSQL
CREATE PROCEDURE get_employee(
    employee_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT * FROM employees WHERE id = employee_id;
END;
$$;

-- Oracle
CREATE PROCEDURE get_employee(
    employee_id IN NUMBER
)
AS
BEGIN
    SELECT * FROM employees WHERE id = employee_id;
END;
```

#### Output Parameters
```sql
-- SQL Server
CREATE PROCEDURE get_employee_salary
    @employee_id INT,
    @salary DECIMAL(10,2) OUTPUT
AS
BEGIN
    SELECT @salary = salary FROM employees WHERE id = @employee_id;
END;

-- MySQL
CREATE PROCEDURE get_employee_salary(
    IN employee_id INT,
    OUT salary DECIMAL(10,2)
)
BEGIN
    SELECT salary INTO salary FROM employees WHERE id = employee_id;
END;

-- PostgreSQL
CREATE PROCEDURE get_employee_salary(
    IN employee_id INT,
    INOUT salary DECIMAL(10,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT salary INTO salary FROM employees WHERE id = employee_id;
END;
$$;

-- Oracle
CREATE PROCEDURE get_employee_salary(
    employee_id IN NUMBER,
    salary OUT NUMBER
)
AS
BEGIN
    SELECT salary INTO salary FROM employees WHERE id = employee_id;
END;
```

#### Input/Output Parameters
```sql
-- SQL Server
CREATE PROCEDURE adjust_salary
    @employee_id INT,
    @adjustment DECIMAL(10,2),
    @new_salary DECIMAL(10,2) OUTPUT
AS
BEGIN
    SELECT @new_salary = salary + @adjustment 
    FROM employees WHERE id = @employee_id;
    
    UPDATE employees 
    SET salary = @new_salary 
    WHERE id = @employee_id;
END;

-- MySQL
CREATE PROCEDURE adjust_salary(
    IN employee_id INT,
    IN adjustment DECIMAL(10,2),
    OUT new_salary DECIMAL(10,2)
)
BEGIN
    SELECT salary + adjustment INTO new_salary 
    FROM employees WHERE id = employee_id;
    
    UPDATE employees 
    SET salary = new_salary 
    WHERE id = employee_id;
END;

-- Oracle
CREATE PROCEDURE adjust_salary(
    employee_id IN NUMBER,
    adjustment IN NUMBER,
    new_salary OUT NUMBER
)
AS
BEGIN
    SELECT salary + adjustment INTO new_salary 
    FROM employees WHERE id = employee_id;
    
    UPDATE employees 
    SET salary = new_salary 
    WHERE id = employee_id;
END;
```

### Executing Stored Procedures

```sql
-- SQL Server
EXEC procedure_name @param1 = value1, @param2 = value2;

-- With output parameter
DECLARE @result INT;
EXEC procedure_name @param1 = value1, @result OUTPUT;
SELECT @result AS result;

-- MySQL
CALL procedure_name(value1, value2);

-- With output parameter
CALL procedure_name(value1, @result);
SELECT @result AS result;

-- PostgreSQL
CALL procedure_name(value1, value2);

-- Oracle
BEGIN
    procedure_name(value1, value2);
END;
/

-- With output parameter
DECLARE
    result NUMBER;
BEGIN
    procedure_name(value1, result);
    DBMS_OUTPUT.PUT_LINE('Result: ' || result);
END;
/
```

### Altering and Dropping Procedures

```sql
-- SQL Server
ALTER PROCEDURE procedure_name
    @param1 datatype,
    @param2 datatype
AS
BEGIN
    -- New SQL statements
END;

DROP PROCEDURE procedure_name;

-- MySQL
DROP PROCEDURE IF EXISTS procedure_name;
-- Then recreate with CREATE PROCEDURE

-- PostgreSQL
CREATE OR REPLACE PROCEDURE procedure_name(
    param1 datatype,
    param2 datatype
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- New SQL statements
END;
$$;

DROP PROCEDURE IF EXISTS procedure_name;

-- Oracle
CREATE OR REPLACE PROCEDURE procedure_name(
    param1 IN datatype,
    param2 IN datatype
)
AS
BEGIN
    -- New SQL statements
END;
/

DROP PROCEDURE procedure_name;
``` 