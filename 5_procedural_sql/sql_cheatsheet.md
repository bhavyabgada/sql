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

## 2. Functions

### Basic Function Syntax

#### SQL Server
```sql
CREATE FUNCTION function_name
(
    @param1 datatype,
    @param2 datatype
)
RETURNS return_datatype
AS
BEGIN
    DECLARE @result return_datatype;
    -- SQL statements
    SET @result = ...;
    RETURN @result;
END;
```

#### MySQL
```sql
DELIMITER //
CREATE FUNCTION function_name(
    param1 datatype,
    param2 datatype
)
RETURNS return_datatype
DETERMINISTIC
BEGIN
    DECLARE result return_datatype;
    -- SQL statements
    SET result = ...;
    RETURN result;
END //
DELIMITER ;
```

#### PostgreSQL
```sql
CREATE OR REPLACE FUNCTION function_name(
    param1 datatype,
    param2 datatype
)
RETURNS return_datatype
LANGUAGE plpgsql
AS $$
DECLARE
    result return_datatype;
BEGIN
    -- SQL statements
    result := ...;
    RETURN result;
END;
$$;
```

#### Oracle
```sql
CREATE OR REPLACE FUNCTION function_name(
    param1 IN datatype,
    param2 IN datatype
)
RETURN return_datatype
AS
    result return_datatype;
BEGIN
    -- SQL statements
    result := ...;
    RETURN result;
END;
/
```

### Types of Functions

#### Scalar Functions
```sql
-- SQL Server
CREATE FUNCTION calculate_bonus(@salary DECIMAL(10,2), @years INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @bonus DECIMAL(10,2);
    SET @bonus = @salary * 0.1 * @years;
    RETURN @bonus;
END;

-- MySQL
CREATE FUNCTION calculate_bonus(salary DECIMAL(10,2), years INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE bonus DECIMAL(10,2);
    SET bonus = salary * 0.1 * years;
    RETURN bonus;
END;

-- PostgreSQL
CREATE FUNCTION calculate_bonus(salary DECIMAL, years INT)
RETURNS DECIMAL
LANGUAGE plpgsql
AS $$
DECLARE
    bonus DECIMAL;
BEGIN
    bonus := salary * 0.1 * years;
    RETURN bonus;
END;
$$;

-- Oracle
CREATE FUNCTION calculate_bonus(
    salary IN NUMBER,
    years IN NUMBER
)
RETURN NUMBER
AS
    bonus NUMBER;
BEGIN
    bonus := salary * 0.1 * years;
    RETURN bonus;
END;
/
```

#### Table-Valued Functions
```sql
-- SQL Server
CREATE FUNCTION get_employees_by_dept(@dept_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM employees WHERE department_id = @dept_id
);

-- Alternatively, with a multi-statement function
CREATE FUNCTION get_employees_by_dept(@dept_id INT)
RETURNS @result TABLE
(
    id INT,
    name VARCHAR(100),
    salary DECIMAL(10,2)
)
AS
BEGIN
    INSERT INTO @result
    SELECT id, name, salary FROM employees WHERE department_id = @dept_id;
    RETURN;
END;

-- MySQL
CREATE FUNCTION get_employees_by_dept(dept_id INT)
RETURNS TABLE (
    id INT,
    name VARCHAR(100),
    salary DECIMAL(10,2)
)
READS SQL DATA
BEGIN
    RETURN SELECT id, name, salary FROM employees WHERE department_id = dept_id;
END;

-- PostgreSQL
CREATE FUNCTION get_employees_by_dept(dept_id INT)
RETURNS TABLE (
    id INT,
    name VARCHAR,
    salary DECIMAL
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT e.id, e.name, e.salary 
                 FROM employees e 
                 WHERE e.department_id = dept_id;
END;
$$;

-- Oracle
CREATE FUNCTION get_employees_by_dept(dept_id IN NUMBER)
RETURN SYS_REFCURSOR
AS
    emp_cursor SYS_REFCURSOR;
BEGIN
    OPEN emp_cursor FOR
        SELECT id, name, salary 
        FROM employees 
        WHERE department_id = dept_id;
    RETURN emp_cursor;
END;
/
```

### Calling Functions

```sql
-- SQL Server
-- Scalar function
SELECT dbo.calculate_bonus(salary, years_of_service) AS bonus
FROM employees;

-- Table-valued function
SELECT * FROM dbo.get_employees_by_dept(10);

-- MySQL
-- Scalar function
SELECT calculate_bonus(salary, years_of_service) AS bonus
FROM employees;

-- PostgreSQL
-- Scalar function
SELECT calculate_bonus(salary, years_of_service) AS bonus
FROM employees;

-- Table-valued function
SELECT * FROM get_employees_by_dept(10);

-- Oracle
-- Scalar function
SELECT calculate_bonus(salary, years_of_service) AS bonus
FROM employees;

-- Table-valued function (using ref cursor)
DECLARE
    emp_cursor SYS_REFCURSOR;
    emp_id NUMBER;
    emp_name VARCHAR2(100);
    emp_salary NUMBER;
BEGIN
    emp_cursor := get_employees_by_dept(10);
    LOOP
        FETCH emp_cursor INTO emp_id, emp_name, emp_salary;
        EXIT WHEN emp_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(emp_id || ' ' || emp_name || ' ' || emp_salary);
    END LOOP;
    CLOSE emp_cursor;
END;
/
```

### Function Properties

#### Deterministic vs. Non-deterministic
```sql
-- SQL Server
CREATE FUNCTION deterministic_function(@input INT)
RETURNS INT
WITH RETURNS NULL ON NULL INPUT, SCHEMABINDING, DETERMINISTIC
AS
BEGIN
    RETURN @input * 2;
END;

-- MySQL
CREATE FUNCTION deterministic_function(input INT)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN input * 2;
END;

-- PostgreSQL
CREATE FUNCTION deterministic_function(input INT)
RETURNS INT
LANGUAGE plpgsql
IMMUTABLE  -- Deterministic
AS $$
BEGIN
    RETURN input * 2;
END;
$$;

-- Oracle
CREATE FUNCTION deterministic_function(input IN NUMBER)
RETURN NUMBER
DETERMINISTIC
AS
BEGIN
    RETURN input * 2;
END;
/
```

#### Function Security
```sql
-- SQL Server
CREATE FUNCTION secure_function(@input INT)
RETURNS INT
WITH ENCRYPTION  -- Obfuscates the function definition
AS
BEGIN
    RETURN @input * 2;
END;

-- SQL Server - Execute as
CREATE FUNCTION owner_function(@input INT)
RETURNS INT
WITH EXECUTE AS OWNER  -- Executes with owner's permissions
AS
BEGIN
    RETURN @input * 2;
END;

-- MySQL
CREATE DEFINER = 'admin'@'localhost'  -- Defines who owns the function
FUNCTION secure_function(input INT)
RETURNS INT
SQL SECURITY DEFINER  -- Executes with definer's permissions
BEGIN
    RETURN input * 2;
END;

-- PostgreSQL
CREATE FUNCTION secure_function(input INT)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER  -- Executes with definer's permissions
AS $$
BEGIN
    RETURN input * 2;
END;
$$;

-- Oracle
CREATE FUNCTION secure_function(input IN NUMBER)
RETURN NUMBER
AUTHID DEFINER  -- Executes with definer's permissions
AS
BEGIN
    RETURN input * 2;
END;
/
```

### Altering and Dropping Functions

```sql
-- SQL Server
ALTER FUNCTION function_name
(
    @param1 datatype,
    @param2 datatype
)
RETURNS return_datatype
AS
BEGIN
    -- New SQL statements
    RETURN ...;
END;

DROP FUNCTION function_name;

-- MySQL
DROP FUNCTION IF EXISTS function_name;
-- Then recreate with CREATE FUNCTION

-- PostgreSQL
CREATE OR REPLACE FUNCTION function_name(
    param1 datatype,
    param2 datatype
)
RETURNS return_datatype
LANGUAGE plpgsql
AS $$
BEGIN
    -- New SQL statements
    RETURN ...;
END;
$$;

DROP FUNCTION IF EXISTS function_name(param1_type, param2_type);

-- Oracle
CREATE OR REPLACE FUNCTION function_name(
    param1 IN datatype,
    param2 IN datatype
)
RETURN return_datatype
AS
BEGIN
    -- New SQL statements
    RETURN ...;
END;
/

DROP FUNCTION function_name;
```

## 3. Triggers

### Basic Trigger Syntax

#### SQL Server
```sql
CREATE TRIGGER trigger_name
ON table_name
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- SQL statements
    -- Use inserted and deleted virtual tables
END;
```

#### MySQL
```sql
DELIMITER //
CREATE TRIGGER trigger_name
AFTER INSERT ON table_name
FOR EACH ROW
BEGIN
    -- SQL statements
    -- Use NEW and OLD row references
END //
DELIMITER ;
```

#### PostgreSQL
```sql
CREATE OR REPLACE FUNCTION trigger_function()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- SQL statements
    -- Use NEW and OLD row references
    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_name
AFTER INSERT ON table_name
FOR EACH ROW
EXECUTE FUNCTION trigger_function();
```

#### Oracle
```sql
CREATE OR REPLACE TRIGGER trigger_name
AFTER INSERT ON table_name
FOR EACH ROW
BEGIN
    -- SQL statements
    -- Use :NEW and :OLD row references
END;
/
```

### Types of Triggers

#### DML Triggers (Data Manipulation)

##### Row-Level Triggers
```sql
-- SQL Server
CREATE TRIGGER employee_audit_trigger
ON employees
AFTER UPDATE
AS
BEGIN
    INSERT INTO employee_audit (employee_id, changed_by, change_date)
    SELECT i.id, SYSTEM_USER, GETDATE()
    FROM inserted i;
END;

-- MySQL
CREATE TRIGGER employee_audit_trigger
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employee_audit (employee_id, changed_by, change_date)
    VALUES (NEW.id, USER(), NOW());
END;

-- PostgreSQL
CREATE FUNCTION employee_audit_function()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO employee_audit (employee_id, changed_by, change_date)
    VALUES (NEW.id, CURRENT_USER, CURRENT_TIMESTAMP);
    RETURN NEW;
END;
$$;

CREATE TRIGGER employee_audit_trigger
AFTER UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION employee_audit_function();

-- Oracle
CREATE OR REPLACE TRIGGER employee_audit_trigger
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employee_audit (employee_id, changed_by, change_date)
    VALUES (:NEW.id, USER, SYSDATE);
END;
/
```

##### Statement-Level Triggers
```sql
-- SQL Server
CREATE TRIGGER prevent_mass_delete
ON employees
AFTER DELETE
AS
BEGIN
    IF (SELECT COUNT(*) FROM deleted) > 100
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50000, 'Cannot delete more than 100 employees at once.', 1;
    END;
END;

-- MySQL
CREATE TRIGGER prevent_mass_delete
BEFORE DELETE ON employees
FOR EACH STATEMENT
BEGIN
    DECLARE row_count INT;
    SELECT COUNT(*) INTO row_count FROM employees WHERE id IN (SELECT id FROM employees WHERE ...);
    IF row_count > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete more than 100 employees at once.';
    END IF;
END;

-- PostgreSQL
CREATE FUNCTION prevent_mass_delete_function()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_NARGS > 0 THEN
        RAISE EXCEPTION 'Cannot delete more than 100 employees at once.';
    END IF;
    RETURN NULL;
END;
$$;

CREATE TRIGGER prevent_mass_delete
AFTER DELETE ON employees
FOR EACH STATEMENT
WHEN (pg_trigger_depth() = 0)
EXECUTE FUNCTION prevent_mass_delete_function();

-- Oracle
CREATE OR REPLACE TRIGGER prevent_mass_delete
BEFORE DELETE ON employees
DECLARE
    row_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO row_count FROM employees WHERE id IN (SELECT id FROM employees WHERE ...);
    IF row_count > 100 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cannot delete more than 100 employees at once.');
    END IF;
END;
/
```

#### DDL Triggers (Data Definition)
```sql
-- SQL Server
CREATE TRIGGER prevent_table_drop
ON DATABASE
FOR DROP_TABLE
AS
BEGIN
    PRINT 'Tables cannot be dropped in this database.';
    ROLLBACK;
END;

-- Oracle
CREATE OR REPLACE TRIGGER prevent_table_drop
BEFORE DROP ON SCHEMA
BEGIN
    RAISE_APPLICATION_ERROR(-20000, 'Tables cannot be dropped in this schema.');
END;
/
```

#### INSTEAD OF Triggers
```sql
-- SQL Server
CREATE TRIGGER instead_of_insert_view
ON employee_view
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO employees (name, department_id, salary)
    SELECT name, department_id, salary
    FROM inserted;
END;

-- PostgreSQL
CREATE FUNCTION instead_of_insert_view_function()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO employees (name, department_id, salary)
    VALUES (NEW.name, NEW.department_id, NEW.salary);
    RETURN NEW;
END;
$$;

CREATE TRIGGER instead_of_insert_view
INSTEAD OF INSERT ON employee_view
FOR EACH ROW
EXECUTE FUNCTION instead_of_insert_view_function();

-- Oracle
CREATE OR REPLACE TRIGGER instead_of_insert_view
INSTEAD OF INSERT ON employee_view
FOR EACH ROW
BEGIN
    INSERT INTO employees (name, department_id, salary)
    VALUES (:NEW.name, :NEW.department_id, :NEW.salary);
END;
/
```

### Trigger Timing

#### BEFORE Triggers
```sql
-- MySQL
CREATE TRIGGER before_insert_employee
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    -- Set default values or validate data
    IF NEW.salary < 0 THEN
        SET NEW.salary = 0;
    END IF;
END;

-- PostgreSQL
CREATE FUNCTION before_insert_employee_function()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Set default values or validate data
    IF NEW.salary < 0 THEN
        NEW.salary := 0;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER before_insert_employee
BEFORE INSERT ON employees
FOR EACH ROW
EXECUTE FUNCTION before_insert_employee_function();

-- Oracle
CREATE OR REPLACE TRIGGER before_insert_employee
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    -- Set default values or validate data
    IF :NEW.salary < 0 THEN
        :NEW.salary := 0;
    END IF;
END;
/
```

#### AFTER Triggers
```sql
-- MySQL
CREATE TRIGGER after_insert_employee
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    -- Log or perform additional actions
    INSERT INTO employee_log (employee_id, action, action_date)
    VALUES (NEW.id, 'INSERT', NOW());
END;

-- PostgreSQL
CREATE FUNCTION after_insert_employee_function()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Log or perform additional actions
    INSERT INTO employee_log (employee_id, action, action_date)
    VALUES (NEW.id, 'INSERT', CURRENT_TIMESTAMP);
    RETURN NULL;
END;
$$;

CREATE TRIGGER after_insert_employee
AFTER INSERT ON employees
FOR EACH ROW
EXECUTE FUNCTION after_insert_employee_function();

-- Oracle
CREATE OR REPLACE TRIGGER after_insert_employee
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    -- Log or perform additional actions
    INSERT INTO employee_log (employee_id, action, action_date)
    VALUES (:NEW.id, 'INSERT', SYSDATE);
END;
/
```

### Accessing Trigger Data

#### Accessing Changed Data
```sql
-- SQL Server
CREATE TRIGGER update_audit
ON employees
AFTER UPDATE
AS
BEGIN
    INSERT INTO salary_changes (employee_id, old_salary, new_salary, change_date)
    SELECT i.id, d.salary, i.salary, GETDATE()
    FROM inserted i
    JOIN deleted d ON i.id = d.id
    WHERE i.salary <> d.salary;
END;

-- MySQL
CREATE TRIGGER update_audit
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    IF NEW.salary <> OLD.salary THEN
        INSERT INTO salary_changes (employee_id, old_salary, new_salary, change_date)
        VALUES (NEW.id, OLD.salary, NEW.salary, NOW());
    END IF;
END;

-- PostgreSQL
CREATE FUNCTION update_audit_function()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.salary <> OLD.salary THEN
        INSERT INTO salary_changes (employee_id, old_salary, new_salary, change_date)
        VALUES (NEW.id, OLD.salary, NEW.salary, CURRENT_TIMESTAMP);
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER update_audit
AFTER UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION update_audit_function();

-- Oracle
CREATE OR REPLACE TRIGGER update_audit
AFTER UPDATE OF salary ON employees
FOR EACH ROW
BEGIN
    IF :NEW.salary <> :OLD.salary THEN
        INSERT INTO salary_changes (employee_id, old_salary, new_salary, change_date)
        VALUES (:NEW.id, :OLD.salary, :NEW.salary, SYSDATE);
    END IF;
END;
/
```

### Managing Triggers

#### Enabling/Disabling Triggers
```sql
-- SQL Server
DISABLE TRIGGER trigger_name ON table_name;
ENABLE TRIGGER trigger_name ON table_name;

-- Disable all triggers on a table
DISABLE TRIGGER ALL ON table_name;

-- MySQL
ALTER TABLE table_name DISABLE KEYS;  -- Disables only foreign key constraints
ALTER TABLE table_name ENABLE KEYS;

-- PostgreSQL
ALTER TABLE table_name DISABLE TRIGGER trigger_name;
ALTER TABLE table_name ENABLE TRIGGER trigger_name;

-- Disable all triggers on a table
ALTER TABLE table_name DISABLE TRIGGER ALL;

-- Oracle
ALTER TRIGGER trigger_name DISABLE;
ALTER TRIGGER trigger_name ENABLE;

-- Disable all triggers on a table
ALTER TABLE table_name DISABLE ALL TRIGGERS;
```

#### Dropping Triggers
```sql
-- SQL Server
DROP TRIGGER trigger_name;

-- MySQL
DROP TRIGGER trigger_name;

-- PostgreSQL
DROP TRIGGER IF EXISTS trigger_name ON table_name;

-- Oracle
DROP TRIGGER trigger_name;
```

### Trigger Best Practices

1. Keep triggers lightweight and efficient
2. Avoid recursive trigger chains
3. Handle errors properly
4. Document trigger behavior
5. Consider alternatives (constraints, application logic) when appropriate
6. Test thoroughly with various data scenarios 

## 4. Cursors

### Basic Cursor Syntax

#### SQL Server
```sql
DECLARE cursor_name CURSOR FOR
    SELECT column1, column2 FROM table_name WHERE condition;

OPEN cursor_name;

DECLARE @column1 datatype, @column2 datatype;
FETCH NEXT FROM cursor_name INTO @column1, @column2;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Process data
    -- ...
    
    FETCH NEXT FROM cursor_name INTO @column1, @column2;
END;

CLOSE cursor_name;
DEALLOCATE cursor_name;
```

#### MySQL
```sql
DELIMITER //
CREATE PROCEDURE process_data()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE column1_val datatype;
    DECLARE column2_val datatype;
    
    DECLARE cursor_name CURSOR FOR
        SELECT column1, column2 FROM table_name WHERE condition;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cursor_name;
    
    read_loop: LOOP
        FETCH cursor_name INTO column1_val, column2_val;
        
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Process data
        -- ...
    END LOOP;
    
    CLOSE cursor_name;
END //
DELIMITER ;
```

#### PostgreSQL
```sql
CREATE OR REPLACE FUNCTION process_data()
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    cursor_name CURSOR FOR
        SELECT column1, column2 FROM table_name WHERE condition;
    
    row_record RECORD;
BEGIN
    OPEN cursor_name;
    
    LOOP
        FETCH cursor_name INTO row_record;
        EXIT WHEN NOT FOUND;
        
        -- Process data using row_record.column1, row_record.column2
        -- ...
    END LOOP;
    
    CLOSE cursor_name;
END;
$$;
```

#### Oracle
```sql
DECLARE
    CURSOR cursor_name IS
        SELECT column1, column2 FROM table_name WHERE condition;
    
    column1_val datatype;
    column2_val datatype;
BEGIN
    OPEN cursor_name;
    
    LOOP
        FETCH cursor_name INTO column1_val, column2_val;
        EXIT WHEN cursor_name%NOTFOUND;
        
        -- Process data
        -- ...
    END LOOP;
    
    CLOSE cursor_name;
END;
/
```

### Cursor Types and Options

#### SQL Server Cursor Options
```sql
-- Declare cursor with options
DECLARE cursor_name CURSOR
    LOCAL                   -- Scope limited to batch, procedure, or trigger
    FORWARD_ONLY            -- Can only move forward (default)
    STATIC                  -- Static copy of data
    READ_ONLY               -- Cannot update data through cursor
    FAST_FORWARD            -- Optimized forward-only, read-only cursor
FOR
    SELECT column1, column2 FROM table_name;

-- Alternative options
DECLARE cursor_name CURSOR
    GLOBAL                  -- Available to all connections
    SCROLL                  -- Can move in any direction
    DYNAMIC                 -- Sees changes made during cursor lifetime
    KEYSET                  -- Sees updates but not inserts/deletes
    FOR UPDATE              -- Can update data through cursor
FOR
    SELECT column1, column2 FROM table_name;
```

#### MySQL Cursor Options
```sql
-- Declare cursor with options
DECLARE cursor_name CURSOR FOR
    SELECT column1, column2 FROM table_name;

-- Handlers for cursor events
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
    -- Error handling
    CLOSE cursor_name;
END;
```

#### PostgreSQL Cursor Options
```sql
-- Declare cursor with options
DECLARE cursor_name CURSOR
    [NO] SCROLL             -- With/without scrolling capability
    FOR SELECT column1, column2 FROM table_name;

-- Scroll options in FETCH
FETCH NEXT FROM cursor_name;     -- Next row (default)
FETCH PRIOR FROM cursor_name;    -- Previous row
FETCH FIRST FROM cursor_name;    -- First row
FETCH LAST FROM cursor_name;     -- Last row
FETCH ABSOLUTE n FROM cursor_name;  -- Nth row from start
FETCH RELATIVE n FROM cursor_name;  -- Nth row from current position
```

#### Oracle Cursor Options
```sql
-- Declare cursor with options
DECLARE
    CURSOR cursor_name IS
        SELECT column1, column2 FROM table_name;
    
    -- Cursor FOR loop (simplified syntax)
    FOR record_name IN cursor_name LOOP
        -- Process data using record_name.column1, record_name.column2
    END LOOP;
    
    -- Cursor attributes
    cursor_name%ISOPEN      -- Returns TRUE if cursor is open
    cursor_name%FOUND       -- Returns TRUE if row was fetched
    cursor_name%NOTFOUND    -- Returns TRUE if no row was fetched
    cursor_name%ROWCOUNT    -- Returns number of rows fetched so far
```

### Cursor Operations

#### Updating Data Through Cursors
```sql
-- SQL Server
DECLARE update_cursor CURSOR FOR
    SELECT id, salary FROM employees
    FOR UPDATE OF salary;

OPEN update_cursor;

DECLARE @id INT, @salary DECIMAL(10,2);
FETCH NEXT FROM update_cursor INTO @id, @salary;

WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE employees
    SET salary = @salary * 1.1
    WHERE CURRENT OF update_cursor;
    
    FETCH NEXT FROM update_cursor INTO @id, @salary;
END;

CLOSE update_cursor;
DEALLOCATE update_cursor;

-- MySQL
DECLARE update_cursor CURSOR FOR
    SELECT id, salary FROM employees FOR UPDATE;

-- PostgreSQL
UPDATE employees
SET salary = salary * 1.1
WHERE id IN (SELECT id FROM employees WHERE department_id = 10)
RETURNING id, salary;

-- Oracle
DECLARE
    CURSOR update_cursor IS
        SELECT id, salary FROM employees
        FOR UPDATE OF salary;
BEGIN
    FOR emp_rec IN update_cursor LOOP
        UPDATE employees
        SET salary = emp_rec.salary * 1.1
        WHERE CURRENT OF update_cursor;
    END LOOP;
END;
/
```

#### Deleting Data Through Cursors
```sql
-- SQL Server
DECLARE delete_cursor CURSOR FOR
    SELECT id FROM employees
    WHERE last_login_date < DATEADD(YEAR, -1, GETDATE())
    FOR UPDATE;

OPEN delete_cursor;

DECLARE @id INT;
FETCH NEXT FROM delete_cursor INTO @id;

WHILE @@FETCH_STATUS = 0
BEGIN
    DELETE FROM employees
    WHERE CURRENT OF delete_cursor;
    
    FETCH NEXT FROM delete_cursor INTO @id;
END;

CLOSE delete_cursor;
DEALLOCATE delete_cursor;

-- Oracle
DECLARE
    CURSOR delete_cursor IS
        SELECT id FROM employees
        WHERE last_login_date < ADD_MONTHS(SYSDATE, -12)
        FOR UPDATE;
BEGIN
    FOR emp_rec IN delete_cursor LOOP
        DELETE FROM employees
        WHERE CURRENT OF delete_cursor;
    END LOOP;
END;
/
```

### Cursor Performance Considerations

1. **Avoid Cursors When Possible**
   - Set-based operations are generally more efficient
   - Use cursors only when row-by-row processing is necessary

2. **Optimize Cursor Declarations**
   - Use the most restrictive options (FORWARD_ONLY, READ_ONLY)
   - Limit the result set with appropriate WHERE clauses
   - Select only the columns you need

3. **Minimize Work Inside Cursor Loops**
   - Keep processing inside loops as simple as possible
   - Avoid nested cursors

4. **Close and Deallocate Cursors Promptly**
   - Release resources as soon as you're done with the cursor

5. **Consider Alternatives**
   - Table variables or temporary tables
   - Common Table Expressions (CTEs)
   - Window functions
   - APPLY operator (SQL Server) 

## 5. Control Flow Statements

### Conditional Statements

#### IF-ELSE Statements

```sql
-- SQL Server
IF condition
BEGIN
    -- Statements executed when condition is TRUE
END
ELSE IF another_condition
BEGIN
    -- Statements executed when another_condition is TRUE
END
ELSE
BEGIN
    -- Statements executed when all conditions are FALSE
END;

-- MySQL
IF condition THEN
    -- Statements executed when condition is TRUE
ELSEIF another_condition THEN
    -- Statements executed when another_condition is TRUE
ELSE
    -- Statements executed when all conditions are FALSE
END IF;

-- PostgreSQL
IF condition THEN
    -- Statements executed when condition is TRUE
ELSIF another_condition THEN
    -- Statements executed when another_condition is TRUE
ELSE
    -- Statements executed when all conditions are FALSE
END IF;

-- Oracle
IF condition THEN
    -- Statements executed when condition is TRUE
ELSIF another_condition THEN
    -- Statements executed when another_condition is TRUE
ELSE
    -- Statements executed when all conditions are FALSE
END IF;
```

#### CASE Statements

```sql
-- SQL Server, MySQL, PostgreSQL
CASE
    WHEN condition1 THEN result1
    WHEN condition2 THEN result2
    ...
    ELSE default_result
END;

-- Simple CASE (value comparison)
CASE expression
    WHEN value1 THEN result1
    WHEN value2 THEN result2
    ...
    ELSE default_result
END;

-- Oracle
CASE
    WHEN condition1 THEN result1
    WHEN condition2 THEN result2
    ...
    ELSE default_result
END;

-- Simple CASE (value comparison)
CASE expression
    WHEN value1 THEN result1
    WHEN value2 THEN result2
    ...
    ELSE default_result
END;
```

#### CASE in Procedural Code

```sql
-- SQL Server
DECLARE @grade CHAR(1) = 'B';
DECLARE @message VARCHAR(100);

SET @message = CASE @grade
    WHEN 'A' THEN 'Excellent'
    WHEN 'B' THEN 'Good'
    WHEN 'C' THEN 'Average'
    WHEN 'D' THEN 'Below Average'
    WHEN 'F' THEN 'Failing'
    ELSE 'Invalid Grade'
END;

-- MySQL
DELIMITER //
CREATE PROCEDURE grade_message(IN grade CHAR(1), OUT message VARCHAR(100))
BEGIN
    CASE grade
        WHEN 'A' THEN SET message = 'Excellent';
        WHEN 'B' THEN SET message = 'Good';
        WHEN 'C' THEN SET message = 'Average';
        WHEN 'D' THEN SET message = 'Below Average';
        WHEN 'F' THEN SET message = 'Failing';
        ELSE SET message = 'Invalid Grade';
    END CASE;
END //
DELIMITER ;

-- PostgreSQL
CREATE OR REPLACE FUNCTION grade_message(grade CHAR)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
DECLARE
    message VARCHAR(100);
BEGIN
    CASE grade
        WHEN 'A' THEN message := 'Excellent';
        WHEN 'B' THEN message := 'Good';
        WHEN 'C' THEN message := 'Average';
        WHEN 'D' THEN message := 'Below Average';
        WHEN 'F' THEN message := 'Failing';
        ELSE message := 'Invalid Grade';
    END CASE;
    
    RETURN message;
END;
$$;

-- Oracle
CREATE OR REPLACE FUNCTION grade_message(grade CHAR)
RETURN VARCHAR2
IS
    message VARCHAR2(100);
BEGIN
    CASE grade
        WHEN 'A' THEN message := 'Excellent';
        WHEN 'B' THEN message := 'Good';
        WHEN 'C' THEN message := 'Average';
        WHEN 'D' THEN message := 'Below Average';
        WHEN 'F' THEN message := 'Failing';
        ELSE message := 'Invalid Grade';
    END CASE;
    
    RETURN message;
END;
/
```

### Loop Statements

#### WHILE Loops

```sql
-- SQL Server
DECLARE @counter INT = 1;

WHILE @counter <= 10
BEGIN
    -- Loop body
    PRINT @counter;
    SET @counter = @counter + 1;
    
    -- Optional early exit
    IF @counter = 5
        BREAK;
END;

-- MySQL
DELIMITER //
CREATE PROCEDURE while_example()
BEGIN
    DECLARE counter INT DEFAULT 1;
    
    WHILE counter <= 10 DO
        -- Loop body
        SELECT counter;
        SET counter = counter + 1;
        
        -- Optional early exit
        IF counter = 5 THEN
            LEAVE while_loop;
        END IF;
    END WHILE;
END //
DELIMITER ;

-- PostgreSQL
CREATE OR REPLACE FUNCTION while_example()
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    counter INT := 1;
BEGIN
    WHILE counter <= 10 LOOP
        -- Loop body
        RAISE NOTICE 'Counter: %', counter;
        counter := counter + 1;
        
        -- Optional early exit
        IF counter = 5 THEN
            EXIT;
        END IF;
    END LOOP;
END;
$$;

-- Oracle
DECLARE
    counter NUMBER := 1;
BEGIN
    WHILE counter <= 10 LOOP
        -- Loop body
        DBMS_OUTPUT.PUT_LINE('Counter: ' || counter);
        counter := counter + 1;
        
        -- Optional early exit
        IF counter = 5 THEN
            EXIT;
        END IF;
    END LOOP;
END;
/
```

#### FOR Loops

```sql
-- SQL Server (using WHILE as a substitute)
DECLARE @counter INT = 1;

WHILE @counter <= 10
BEGIN
    -- Loop body
    PRINT @counter;
    SET @counter = @counter + 1;
END;

-- MySQL
DELIMITER //
CREATE PROCEDURE for_example()
BEGIN
    DECLARE counter INT;
    
    FOR counter IN 1..10 DO
        -- Loop body
        SELECT counter;
    END FOR;
END //
DELIMITER ;

-- PostgreSQL
CREATE OR REPLACE FUNCTION for_example()
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    FOR counter IN 1..10 LOOP
        -- Loop body
        RAISE NOTICE 'Counter: %', counter;
    END LOOP;
END;
$$;

-- Oracle
BEGIN
    FOR counter IN 1..10 LOOP
        -- Loop body
        DBMS_OUTPUT.PUT_LINE('Counter: ' || counter);
    END LOOP;
END;
/
```

#### LOOP with EXIT Condition

```sql
-- MySQL
DELIMITER //
CREATE PROCEDURE loop_example()
BEGIN
    DECLARE counter INT DEFAULT 1;
    
    my_loop: LOOP
        -- Loop body
        SELECT counter;
        SET counter = counter + 1;
        
        -- Exit condition
        IF counter > 10 THEN
            LEAVE my_loop;
        END IF;
    END LOOP my_loop;
END //
DELIMITER ;

-- PostgreSQL
CREATE OR REPLACE FUNCTION loop_example()
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    counter INT := 1;
BEGIN
    LOOP
        -- Loop body
        RAISE NOTICE 'Counter: %', counter;
        counter := counter + 1;
        
        -- Exit condition
        EXIT WHEN counter > 10;
    END LOOP;
END;
$$;

-- Oracle
DECLARE
    counter NUMBER := 1;
BEGIN
    LOOP
        -- Loop body
        DBMS_OUTPUT.PUT_LINE('Counter: ' || counter);
        counter := counter + 1;
        
        -- Exit condition
        EXIT WHEN counter > 10;
    END LOOP;
END;
/
```

#### Cursor FOR Loops

```sql
-- PostgreSQL
CREATE OR REPLACE FUNCTION process_employees()
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    FOR emp_rec IN (SELECT id, name, salary FROM employees) LOOP
        -- Process each employee record
        RAISE NOTICE 'Employee: % (ID: %) - Salary: %', 
                     emp_rec.name, emp_rec.id, emp_rec.salary;
    END LOOP;
END;
$$;

-- Oracle
DECLARE
    CURSOR emp_cursor IS
        SELECT id, name, salary FROM employees;
BEGIN
    FOR emp_rec IN emp_cursor LOOP
        -- Process each employee record
        DBMS_OUTPUT.PUT_LINE('Employee: ' || emp_rec.name || 
                             ' (ID: ' || emp_rec.id || ') - ' || 
                             'Salary: ' || emp_rec.salary);
    END LOOP;
END;
/
```

### GOTO Statements (SQL Server)

```sql
-- SQL Server
DECLARE @counter INT = 1;

start_label:
    PRINT @counter;
    SET @counter = @counter + 1;
    
    IF @counter <= 10
        GOTO start_label;
    ELSE
        GOTO end_label;

middle_label:
    PRINT 'This will be skipped';
    
end_label:
    PRINT 'Loop completed';
```

### CONTINUE and BREAK Statements

```sql
-- SQL Server
DECLARE @counter INT = 0;

WHILE @counter < 10
BEGIN
    SET @counter = @counter + 1;
    
    -- Skip even numbers
    IF @counter % 2 = 0
        CONTINUE;
        
    PRINT 'Odd number: ' + CAST(@counter AS VARCHAR);
    
    -- Exit loop early
    IF @counter >= 7
        BREAK;
END;

-- MySQL
DELIMITER //
CREATE PROCEDURE continue_break_example()
BEGIN
    DECLARE counter INT DEFAULT 0;
    
    my_loop: LOOP
        SET counter = counter + 1;
        
        -- Skip even numbers
        IF counter % 2 = 0 THEN
            ITERATE my_loop;  -- CONTINUE equivalent
        END IF;
        
        SELECT CONCAT('Odd number: ', counter);
        
        -- Exit loop early
        IF counter >= 7 THEN
            LEAVE my_loop;  -- BREAK equivalent
        END IF;
    END LOOP my_loop;
END //
DELIMITER ;

-- PostgreSQL
CREATE OR REPLACE FUNCTION continue_break_example()
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    counter INT := 0;
BEGIN
    LOOP
        counter := counter + 1;
        
        -- Skip even numbers
        CONTINUE WHEN counter % 2 = 0;
        
        RAISE NOTICE 'Odd number: %', counter;
        
        -- Exit loop early
        EXIT WHEN counter >= 7;
    END LOOP;
END;
$$;

-- Oracle
DECLARE
    counter NUMBER := 0;
BEGIN
    LOOP
        counter := counter + 1;
        
        -- Skip even numbers
        CONTINUE WHEN MOD(counter, 2) = 0;
        
        DBMS_OUTPUT.PUT_LINE('Odd number: ' || counter);
        
        -- Exit loop early
        EXIT WHEN counter >= 7;
    END LOOP;
END;
/
```

### RETURN Statements

```sql
-- SQL Server
CREATE FUNCTION get_employee_status(@employee_id INT)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @years_of_service INT;
    DECLARE @status VARCHAR(20);
    
    SELECT @years_of_service = DATEDIFF(YEAR, hire_date, GETDATE())
    FROM employees
    WHERE id = @employee_id;
    
    IF @years_of_service IS NULL
        RETURN 'Employee not found';
        
    IF @years_of_service < 2
        RETURN 'Probationary';
    ELSE IF @years_of_service < 5
        RETURN 'Regular';
    ELSE
        RETURN 'Senior';
        
    -- This line will never execute
    RETURN 'Unknown';
END;

-- MySQL
DELIMITER //
CREATE FUNCTION get_employee_status(employee_id INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE years_of_service INT;
    
    SELECT TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) INTO years_of_service
    FROM employees
    WHERE id = employee_id;
    
    IF years_of_service IS NULL THEN
        RETURN 'Employee not found';
    END IF;
        
    IF years_of_service < 2 THEN
        RETURN 'Probationary';
    ELSEIF years_of_service < 5 THEN
        RETURN 'Regular';
    ELSE
        RETURN 'Senior';
    END IF;
END //
DELIMITER ;

-- PostgreSQL
CREATE OR REPLACE FUNCTION get_employee_status(employee_id INT)
RETURNS VARCHAR(20)
LANGUAGE plpgsql
AS $$
DECLARE
    years_of_service INT;
BEGIN
    SELECT EXTRACT(YEAR FROM AGE(CURRENT_DATE, hire_date)) INTO years_of_service
    FROM employees
    WHERE id = employee_id;
    
    IF years_of_service IS NULL THEN
        RETURN 'Employee not found';
    END IF;
        
    IF years_of_service < 2 THEN
        RETURN 'Probationary';
    ELSIF years_of_service < 5 THEN
        RETURN 'Regular';
    ELSE
        RETURN 'Senior';
    END IF;
END;
$$;

-- Oracle
CREATE OR REPLACE FUNCTION get_employee_status(employee_id IN NUMBER)
RETURN VARCHAR2
IS
    years_of_service NUMBER;
BEGIN
    SELECT FLOOR(MONTHS_BETWEEN(SYSDATE, hire_date) / 12) INTO years_of_service
    FROM employees
    WHERE id = employee_id;
    
    IF years_of_service IS NULL THEN
        RETURN 'Employee not found';
    END IF;
        
    IF years_of_service < 2 THEN
        RETURN 'Probationary';
    ELSIF years_of_service < 5 THEN
        RETURN 'Regular';
    ELSE
        RETURN 'Senior';
    END IF;
END;
/
``` 

## 6. Error Handling

### Basic Error Handling

#### SQL Server TRY-CATCH
```sql
BEGIN TRY
    -- SQL statements that might cause an error
    INSERT INTO employees (name, email) VALUES ('John Doe', 'john@example.com');
    UPDATE departments SET manager_id = 101 WHERE id = 5;
END TRY
BEGIN CATCH
    -- Error handling code
    PRINT 'Error occurred: ' + ERROR_MESSAGE();
    PRINT 'Error number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT 'Error line: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Error procedure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
    PRINT 'Error severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    PRINT 'Error state: ' + CAST(ERROR_STATE() AS VARCHAR);
END CATCH;
```

#### MySQL Handler
```sql
DELIMITER //
CREATE PROCEDURE insert_employee(IN emp_name VARCHAR(100), IN emp_email VARCHAR(100))
BEGIN
    -- Declare error handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            @sqlstate = RETURNED_SQLSTATE,
            @errno = MYSQL_ERRNO,
            @text = MESSAGE_TEXT;
        
        SELECT CONCAT('Error occurred: ', @text) AS error_message;
        -- Rollback transaction if needed
        ROLLBACK;
    END;
    
    -- Start transaction
    START TRANSACTION;
    
    -- SQL statements that might cause an error
    INSERT INTO employees (name, email) VALUES (emp_name, emp_email);
    UPDATE departments SET manager_id = 101 WHERE id = 5;
    
    -- Commit if successful
    COMMIT;
END //
DELIMITER ;
```

#### PostgreSQL Exception Handling
```sql
CREATE OR REPLACE FUNCTION insert_employee(emp_name VARCHAR, emp_email VARCHAR)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- SQL statements that might cause an error
    INSERT INTO employees (name, email) VALUES (emp_name, emp_email);
    UPDATE departments SET manager_id = 101 WHERE id = 5;
    
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Duplicate key violation: %', SQLERRM;
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key violation: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unknown error: %', SQLERRM;
END;
$$;
```

#### Oracle Exception Handling
```sql
CREATE OR REPLACE PROCEDURE insert_employee(
    emp_name IN VARCHAR2,
    emp_email IN VARCHAR2
)
AS
BEGIN
    -- SQL statements that might cause an error
    INSERT INTO employees (name, email) VALUES (emp_name, emp_email);
    UPDATE departments SET manager_id = 101 WHERE id = 5;
    
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate key violation: ' || SQLERRM);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unknown error: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Error code: ' || SQLCODE);
END;
/
```

### Transaction Management with Error Handling

#### SQL Server
```sql
BEGIN TRY
    BEGIN TRANSACTION;
    
    INSERT INTO orders (customer_id, order_date, total)
    VALUES (101, GETDATE(), 1500.00);
    
    DECLARE @order_id INT = SCOPE_IDENTITY();
    
    INSERT INTO order_items (order_id, product_id, quantity, price)
    VALUES (@order_id, 1, 2, 750.00);
    
    -- Simulate error
    -- INSERT INTO nonexistent_table VALUES (1);
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    
    PRINT 'Error occurred: ' + ERROR_MESSAGE();
    
    -- Optionally re-throw the error
    -- THROW;
END CATCH;
```

#### MySQL
```sql
DELIMITER //
CREATE PROCEDURE create_order(
    IN customer_id INT,
    IN product_id INT,
    IN quantity INT,
    IN price DECIMAL(10,2)
)
BEGIN
    DECLARE order_id INT;
    
    -- Declare error handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback transaction
        ROLLBACK;
        SELECT 'Error occurred, transaction rolled back' AS message;
    END;
    
    -- Start transaction
    START TRANSACTION;
    
    -- Insert order
    INSERT INTO orders (customer_id, order_date, total)
    VALUES (customer_id, CURDATE(), quantity * price);
    
    -- Get the new order ID
    SET order_id = LAST_INSERT_ID();
    
    -- Insert order item
    INSERT INTO order_items (order_id, product_id, quantity, price)
    VALUES (order_id, product_id, quantity, price);
    
    -- Commit transaction
    COMMIT;
    
    SELECT 'Order created successfully' AS message;
END //
DELIMITER ;
```

#### PostgreSQL
```sql
CREATE OR REPLACE FUNCTION create_order(
    customer_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    order_id INT;
BEGIN
    -- Start transaction (implicit in function)
    
    -- Insert order
    INSERT INTO orders (customer_id, order_date, total)
    VALUES (customer_id, CURRENT_DATE, quantity * price)
    RETURNING id INTO order_id;
    
    -- Insert order item
    INSERT INTO order_items (order_id, product_id, quantity, price)
    VALUES (order_id, product_id, quantity, price);
    
    -- Return the new order ID
    RETURN order_id;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Rollback transaction (automatic in function on error)
        RAISE NOTICE 'Error occurred: %', SQLERRM;
        RAISE; -- Re-throw the error
END;
$$;
```

#### Oracle
```sql
CREATE OR REPLACE PROCEDURE create_order(
    customer_id IN NUMBER,
    product_id IN NUMBER,
    quantity IN NUMBER,
    price IN NUMBER,
    order_id OUT NUMBER
)
AS
BEGIN
    -- Start transaction (implicit)
    
    -- Insert order
    INSERT INTO orders (customer_id, order_date, total)
    VALUES (customer_id, SYSDATE, quantity * price)
    RETURNING id INTO order_id;
    
    -- Insert order item
    INSERT INTO order_items (order_id, product_id, quantity, price)
    VALUES (order_id, product_id, quantity, price);
    
    -- Commit transaction
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Rollback transaction
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
        RAISE; -- Re-throw the error
END;
/
```

### Custom Error Handling

#### SQL Server Custom Errors
```sql
-- Raising a custom error
DECLARE @employee_id INT = 101;
DECLARE @min_salary DECIMAL(10,2) = 30000.00;
DECLARE @current_salary DECIMAL(10,2);

SELECT @current_salary = salary FROM employees WHERE id = @employee_id;

IF @current_salary < @min_salary
BEGIN
    -- RAISERROR (deprecated but still used)
    RAISERROR('Employee %d salary ($%.2f) is below minimum ($%.2f)', 16, 1, 
              @employee_id, @current_salary, @min_salary);
    
    -- THROW (newer method)
    -- THROW 50000, 'Employee salary is below minimum', 1;
END;

-- Creating a custom error message
EXEC sp_addmessage 
    @msgnum = 50001, 
    @severity = 16, 
    @msgtext = 'Employee %d salary ($%.2f) is below minimum ($%.2f)',
    @lang = 'us_english';

-- Using the custom error message
RAISERROR(50001, 16, 1, @employee_id, @current_salary, @min_salary);
```

#### MySQL Custom Errors
```sql
DELIMITER //
CREATE PROCEDURE check_employee_salary(IN employee_id INT)
BEGIN
    DECLARE current_salary DECIMAL(10,2);
    DECLARE min_salary DECIMAL(10,2) DEFAULT 30000.00;
    
    SELECT salary INTO current_salary FROM employees WHERE id = employee_id;
    
    IF current_salary < min_salary THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = CONCAT('Employee ', employee_id, 
                                 ' salary ($', current_salary, 
                                 ') is below minimum ($', min_salary, ')');
    END IF;
END //
DELIMITER ;
```

#### PostgreSQL Custom Errors
```sql
CREATE OR REPLACE FUNCTION check_employee_salary(employee_id INT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    current_salary DECIMAL;
    min_salary CONSTANT DECIMAL := 30000.00;
BEGIN
    SELECT salary INTO current_salary FROM employees WHERE id = employee_id;
    
    IF current_salary < min_salary THEN
        RAISE EXCEPTION 'Employee % salary ($%) is below minimum ($%)', 
                        employee_id, current_salary, min_salary;
    END IF;
END;
$$;
```

#### Oracle Custom Errors
```sql
CREATE OR REPLACE PROCEDURE check_employee_salary(employee_id IN NUMBER)
AS
    current_salary NUMBER;
    min_salary CONSTANT NUMBER := 30000.00;
    salary_too_low EXCEPTION;
BEGIN
    SELECT salary INTO current_salary FROM employees WHERE id = employee_id;
    
    IF current_salary < min_salary THEN
        RAISE salary_too_low;
    END IF;
    
EXCEPTION
    WHEN salary_too_low THEN
        RAISE_APPLICATION_ERROR(-20001, 
            'Employee ' || employee_id || 
            ' salary ($' || current_salary || 
            ') is below minimum ($' || min_salary || ')');
END;
/
```

### Error Logging

#### SQL Server Error Logging
```sql
-- Create error log table
CREATE TABLE error_log (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    error_number INT,
    error_severity INT,
    error_state INT,
    error_procedure VARCHAR(128),
    error_line INT,
    error_message VARCHAR(4000),
    log_date DATETIME DEFAULT GETDATE(),
    user_name VARCHAR(128) DEFAULT SUSER_SNAME()
);

-- Procedure with error logging
CREATE PROCEDURE process_data_with_logging
AS
BEGIN
    BEGIN TRY
        -- SQL statements that might cause an error
        SELECT 1/0; -- Deliberate error: division by zero
    END TRY
    BEGIN CATCH
        -- Log the error
        INSERT INTO error_log (
            error_number, error_severity, error_state,
            error_procedure, error_line, error_message
        )
        VALUES (
            ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(),
            ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE()
        );
        
        -- Re-throw the error or handle it
        THROW;
    END CATCH;
END;
```

#### MySQL Error Logging
```sql
-- Create error log table
CREATE TABLE error_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    error_code INT,
    error_state VARCHAR(5),
    error_message TEXT,
    procedure_name VARCHAR(128),
    log_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_name VARCHAR(128)
);

-- Procedure with error logging
DELIMITER //
CREATE PROCEDURE process_data_with_logging()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            @sqlstate = RETURNED_SQLSTATE,
            @errno = MYSQL_ERRNO,
            @text = MESSAGE_TEXT;
        
        -- Log the error
        INSERT INTO error_log (
            error_code, error_state, error_message,
            procedure_name, user_name
        )
        VALUES (
            @errno, @sqlstate, @text,
            'process_data_with_logging', CURRENT_USER()
        );
        
        -- Re-throw or handle the error
        SIGNAL SQLSTATE @sqlstate SET MESSAGE_TEXT = @text;
    END;
    
    -- SQL statements that might cause an error
    SELECT 1/0; -- Deliberate error: division by zero
END //
DELIMITER ;
```

#### PostgreSQL Error Logging
```sql
-- Create error log table
CREATE TABLE error_log (
    log_id SERIAL PRIMARY KEY,
    error_code VARCHAR(5),
    error_message TEXT,
    procedure_name TEXT,
    log_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_name TEXT
);

-- Function with error logging
CREATE OR REPLACE FUNCTION process_data_with_logging()
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- SQL statements that might cause an error
    PERFORM 1/0; -- Deliberate error: division by zero
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log the error
        INSERT INTO error_log (
            error_code, error_message,
            procedure_name, user_name
        )
        VALUES (
            SQLSTATE, SQLERRM,
            'process_data_with_logging', CURRENT_USER
        );
        
        -- Re-throw or handle the error
        RAISE;
END;
$$;
```

#### Oracle Error Logging
```sql
-- Create error log table
CREATE TABLE error_log (
    log_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    error_code NUMBER,
    error_message VARCHAR2(4000),
    procedure_name VARCHAR2(128),
    log_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    user_name VARCHAR2(128)
);

-- Procedure with error logging
CREATE OR REPLACE PROCEDURE process_data_with_logging
AS
BEGIN
    -- SQL statements that might cause an error
    SELECT 1/0 FROM DUAL; -- Deliberate error: division by zero
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log the error
        INSERT INTO error_log (
            error_code, error_message,
            procedure_name, user_name
        )
        VALUES (
            SQLCODE, SQLERRM,
            'PROCESS_DATA_WITH_LOGGING', USER
        );
        
        -- Re-throw or handle the error
        RAISE;
END;
/
```

## 7. Dynamic SQL

### Basic Dynamic SQL

#### SQL Server
```sql
-- Simple dynamic SQL
DECLARE @sql NVARCHAR(MAX);
DECLARE @table_name NVARCHAR(128) = 'employees';

SET @sql = 'SELECT * FROM ' + @table_name;
EXEC sp_executesql @sql;

-- With parameters
DECLARE @sql NVARCHAR(MAX);
DECLARE @table_name NVARCHAR(128) = 'employees';
DECLARE @department_id INT = 10;

SET @sql = 'SELECT * FROM ' + @table_name + ' WHERE department_id = @dept_id';
EXEC sp_executesql @sql, N'@dept_id INT', @dept_id = @department_id;
```

#### MySQL
```sql
-- Simple dynamic SQL
SET @sql = CONCAT('SELECT * FROM ', 'employees');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- With parameters
SET @sql = 'SELECT * FROM employees WHERE department_id = ?';
SET @dept_id = 10;
PREPARE stmt FROM @sql;
EXECUTE stmt USING @dept_id;
DEALLOCATE PREPARE stmt;
```

#### PostgreSQL
```sql
-- Simple dynamic SQL
DO $$
DECLARE
    sql_text TEXT;
    table_name TEXT := 'employees';
BEGIN
    sql_text := 'SELECT * FROM ' || table_name;
    EXECUTE sql_text;
END $$;

-- With parameters
DO $$
DECLARE
    sql_text TEXT;
    table_name TEXT := 'employees';
    dept_id INT := 10;
BEGIN
    sql_text := 'SELECT * FROM ' || table_name || ' WHERE department_id = $1';
    EXECUTE sql_text USING dept_id;
END $$;
```

#### Oracle
```sql
-- Simple dynamic SQL
DECLARE
    sql_text VARCHAR2(4000);
    table_name VARCHAR2(128) := 'employees';
BEGIN
    sql_text := 'SELECT * FROM ' || table_name;
    EXECUTE IMMEDIATE sql_text;
END;
/

-- With parameters
DECLARE
    sql_text VARCHAR2(4000);
    table_name VARCHAR2(128) := 'employees';
    dept_id NUMBER := 10;
    
    -- For storing results
    emp_id NUMBER;
    emp_name VARCHAR2(100);
BEGIN
    sql_text := 'SELECT id, name FROM ' || table_name || ' WHERE department_id = :dept_id';
    EXECUTE IMMEDIATE sql_text INTO emp_id, emp_name USING dept_id;
    
    DBMS_OUTPUT.PUT_LINE('Employee: ' || emp_id || ' - ' || emp_name);
END;
/
```

### Dynamic SQL for Data Manipulation

#### SQL Server
```sql
-- Dynamic INSERT
DECLARE @sql NVARCHAR(MAX);
DECLARE @table_name NVARCHAR(128) = 'employees';
DECLARE @name NVARCHAR(100) = 'John Doe';
DECLARE @email NVARCHAR(100) = 'john@example.com';

SET @sql = 'INSERT INTO ' + @table_name + ' (name, email) VALUES (@emp_name, @emp_email)';
EXEC sp_executesql @sql, N'@emp_name NVARCHAR(100), @emp_email NVARCHAR(100)', 
                  @emp_name = @name, @emp_email = @email;

-- Dynamic UPDATE
DECLARE @sql NVARCHAR(MAX);
DECLARE @table_name NVARCHAR(128) = 'employees';
DECLARE @id INT = 101;
DECLARE @new_salary DECIMAL(10,2) = 55000.00;

SET @sql = 'UPDATE ' + @table_name + ' SET salary = @salary WHERE id = @emp_id';
EXEC sp_executesql @sql, N'@salary DECIMAL(10,2), @emp_id INT', 
                  @salary = @new_salary, @emp_id = @id;

-- Dynamic DELETE
DECLARE @sql NVARCHAR(MAX);
DECLARE @table_name NVARCHAR(128) = 'employees';
DECLARE @id INT = 101;

SET @sql = 'DELETE FROM ' + @table_name + ' WHERE id = @emp_id';
EXEC sp_executesql @sql, N'@emp_id INT', @emp_id = @id;
```

#### MySQL
```sql
-- Dynamic INSERT
SET @sql = 'INSERT INTO employees (name, email) VALUES (?, ?)';
SET @name = 'John Doe';
SET @email = 'john@example.com';
PREPARE stmt FROM @sql;
EXECUTE stmt USING @name, @email;
DEALLOCATE PREPARE stmt;

-- Dynamic UPDATE
SET @sql = 'UPDATE employees SET salary = ? WHERE id = ?';
SET @new_salary = 55000.00;
SET @id = 101;
PREPARE stmt FROM @sql;
EXECUTE stmt USING @new_salary, @id;
DEALLOCATE PREPARE stmt;

-- Dynamic DELETE
SET @sql = 'DELETE FROM employees WHERE id = ?';
SET @id = 101;
PREPARE stmt FROM @sql;
EXECUTE stmt USING @id;
DEALLOCATE PREPARE stmt;
```

#### PostgreSQL
```sql
-- Dynamic INSERT
DO $$
DECLARE
    sql_text TEXT;
    emp_name TEXT := 'John Doe';
    emp_email TEXT := 'john@example.com';
BEGIN
    sql_text := 'INSERT INTO employees (name, email) VALUES ($1, $2)';
    EXECUTE sql_text USING emp_name, emp_email;
END $$;

-- Dynamic UPDATE
DO $$
DECLARE
    sql_text TEXT;
    emp_id INT := 101;
    new_salary DECIMAL := 55000.00;
BEGIN
    sql_text := 'UPDATE employees SET salary = $1 WHERE id = $2';
    EXECUTE sql_text USING new_salary, emp_id;
END $$;

-- Dynamic DELETE
DO $$
DECLARE
    sql_text TEXT;
    emp_id INT := 101;
BEGIN
    sql_text := 'DELETE FROM employees WHERE id = $1';
    EXECUTE sql_text USING emp_id;
END $$;
```

#### Oracle
```sql
-- Dynamic INSERT
DECLARE
    sql_text VARCHAR2(4000);
    emp_name VARCHAR2(100) := 'John Doe';
    emp_email VARCHAR2(100) := 'john@example.com';
BEGIN
    sql_text := 'INSERT INTO employees (name, email) VALUES (:name, :email)';
    EXECUTE IMMEDIATE sql_text USING emp_name, emp_email;
END;
/

-- Dynamic UPDATE
DECLARE
    sql_text VARCHAR2(4000);
    emp_id NUMBER := 101;
    new_salary NUMBER := 55000.00;
BEGIN
    sql_text := 'UPDATE employees SET salary = :salary WHERE id = :id';
    EXECUTE IMMEDIATE sql_text USING new_salary, emp_id;
END;
/

-- Dynamic DELETE
DECLARE
    sql_text VARCHAR2(4000);
    emp_id NUMBER := 101;
BEGIN
    sql_text := 'DELETE FROM employees WHERE id = :id';
    EXECUTE IMMEDIATE sql_text USING emp_id;
END;
/
```

### Dynamic SQL for DDL Operations

#### SQL Server
```sql
-- Create table dynamically
DECLARE @sql NVARCHAR(MAX);
DECLARE @table_name NVARCHAR(128) = 'new_employees';

SET @sql = '
CREATE TABLE ' + @table_name + ' (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    email NVARCHAR(100) UNIQUE,
    salary DECIMAL(10,2),
    hire_date DATE DEFAULT GETDATE()
)';

EXEC sp_executesql @sql;

-- Add column dynamically
DECLARE @sql NVARCHAR(MAX);
DECLARE @table_name NVARCHAR(128) = 'employees';
DECLARE @column_name NVARCHAR(128) = 'phone_number';
DECLARE @column_type NVARCHAR(128) = 'VARCHAR(20)';

SET @sql = 'ALTER TABLE ' + @table_name + ' ADD ' + @column_name + ' ' + @column_type;
EXEC sp_executesql @sql;

-- Drop table dynamically
DECLARE @sql NVARCHAR(MAX);
DECLARE @table_name NVARCHAR(128) = 'temp_employees';

SET @sql = 'DROP TABLE IF EXISTS ' + @table_name;
EXEC sp_executesql @sql;
```

#### MySQL
```sql
-- Create table dynamically
SET @table_name = 'new_employees';
SET @sql = CONCAT('
CREATE TABLE ', @table_name, ' (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    salary DECIMAL(10,2),
    hire_date DATE DEFAULT CURRENT_DATE
)');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add column dynamically
SET @table_name = 'employees';
SET @column_name = 'phone_number';
SET @column_type = 'VARCHAR(20)';
SET @sql = CONCAT('ALTER TABLE ', @table_name, ' ADD COLUMN ', @column_name, ' ', @column_type);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Drop table dynamically
SET @table_name = 'temp_employees';
SET @sql = CONCAT('DROP TABLE IF EXISTS ', @table_name);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
```

#### PostgreSQL
```sql
-- Create table dynamically
DO $$
DECLARE
    sql_text TEXT;
    table_name TEXT := 'new_employees';
BEGIN
    sql_text := '
    CREATE TABLE ' || table_name || ' (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        email VARCHAR(100) UNIQUE,
        salary DECIMAL(10,2),
        hire_date DATE DEFAULT CURRENT_DATE
    )';
    
    EXECUTE sql_text;
END $$;

-- Add column dynamically
DO $$
DECLARE
    sql_text TEXT;
    table_name TEXT := 'employees';
    column_name TEXT := 'phone_number';
    column_type TEXT := 'VARCHAR(20)';
BEGIN
    sql_text := 'ALTER TABLE ' || table_name || ' ADD COLUMN ' || column_name || ' ' || column_type;
    
    EXECUTE sql_text;
END $$;

-- Drop table dynamically
DO $$
DECLARE
    sql_text TEXT;
    table_name TEXT := 'temp_employees';
BEGIN
    sql_text := 'DROP TABLE IF EXISTS ' || table_name;
    
    EXECUTE sql_text;
END $$;
```

#### Oracle
```sql
-- Create table dynamically
DECLARE
    sql_text VARCHAR2(4000);
    table_name VARCHAR2(128) := 'new_employees';
BEGIN
    sql_text := '
    CREATE TABLE ' || table_name || ' (
        id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        name VARCHAR2(100) NOT NULL,
        email VARCHAR2(100) UNIQUE,
        salary NUMBER(10,2),
        hire_date DATE DEFAULT SYSDATE
    )';
    
    EXECUTE IMMEDIATE sql_text;
END;
/

-- Add column dynamically
DECLARE
    sql_text VARCHAR2(4000);
    table_name VARCHAR2(128) := 'employees';
    column_name VARCHAR2(128) := 'phone_number';
    column_type VARCHAR2(128) := 'VARCHAR2(20)';
BEGIN
    sql_text := 'ALTER TABLE ' || table_name || ' ADD ' || column_name || ' ' || column_type;
    
    EXECUTE IMMEDIATE sql_text;
END;
/

-- Drop table dynamically
DECLARE
    sql_text VARCHAR2(4000);
    table_name VARCHAR2(128) := 'temp_employees';
BEGIN
    sql_text := 'DROP TABLE ' || table_name;
    
    EXECUTE IMMEDIATE sql_text;
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN  -- ORA-00942: table or view does not exist
            RAISE;
        END IF;
END;
/
```

### Dynamic SQL with Conditional Logic

#### SQL Server
```sql
-- Dynamic query with conditional WHERE clauses
CREATE PROCEDURE search_employees
    @name NVARCHAR(100) = NULL,
    @department_id INT = NULL,
    @min_salary DECIMAL(10,2) = NULL
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @params NVARCHAR(MAX);
    
    SET @sql = 'SELECT * FROM employees WHERE 1=1';
    
    IF @name IS NOT NULL
        SET @sql = @sql + ' AND name LIKE ''%'' + @name + ''%''';
        
    IF @department_id IS NOT NULL
        SET @sql = @sql + ' AND department_id = @dept_id';
        
    IF @min_salary IS NOT NULL
        SET @sql = @sql + ' AND salary >= @min_sal';
    
    SET @params = N'@name NVARCHAR(100), @dept_id INT, @min_sal DECIMAL(10,2)';
    
    EXEC sp_executesql @sql, @params, 
                      @name = @name, 
                      @dept_id = @department_id, 
                      @min_sal = @min_salary;
END;
```

#### MySQL
```sql
-- Dynamic query with conditional WHERE clauses
DELIMITER //
CREATE PROCEDURE search_employees(
    IN p_name VARCHAR(100),
    IN p_department_id INT,
    IN p_min_salary DECIMAL(10,2)
)
BEGIN
    SET @sql = 'SELECT * FROM employees WHERE 1=1';
    
    IF p_name IS NOT NULL THEN
        SET @sql = CONCAT(@sql, ' AND name LIKE CONCAT(''%'', ?, ''%'')');
    END IF;
    
    IF p_department_id IS NOT NULL THEN
        SET @sql = CONCAT(@sql, ' AND department_id = ?');
    END IF;
    
    IF p_min_salary IS NOT NULL THEN
        SET @sql = CONCAT(@sql, ' AND salary >= ?');
    END IF;
    
    SET @name = p_name;
    SET @dept_id = p_department_id;
    SET @min_sal = p_min_salary;
    
    PREPARE stmt FROM @sql;
    
    IF p_name IS NOT NULL AND p_department_id IS NOT NULL AND p_min_salary IS NOT NULL THEN
        EXECUTE stmt USING @name, @dept_id, @min_sal;
    ELSEIF p_name IS NOT NULL AND p_department_id IS NOT NULL THEN
        EXECUTE stmt USING @name, @dept_id;
    ELSEIF p_name IS NOT NULL AND p_min_salary IS NOT NULL THEN
        EXECUTE stmt USING @name, @min_sal;
    ELSEIF p_department_id IS NOT NULL AND p_min_salary IS NOT NULL THEN
        EXECUTE stmt USING @dept_id, @min_sal;
    ELSEIF p_name IS NOT NULL THEN
        EXECUTE stmt USING @name;
    ELSEIF p_department_id IS NOT NULL THEN
        EXECUTE stmt USING @dept_id;
    ELSEIF p_min_salary IS NOT NULL THEN
        EXECUTE stmt USING @min_sal;
    ELSE
        EXECUTE stmt;
    END IF;
    
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;
```

#### PostgreSQL
```sql
-- Dynamic query with conditional WHERE clauses
CREATE OR REPLACE FUNCTION search_employees(
    p_name VARCHAR DEFAULT NULL,
    p_department_id INT DEFAULT NULL,
    p_min_salary DECIMAL DEFAULT NULL
)
RETURNS SETOF employees
LANGUAGE plpgsql
AS $$
DECLARE
    sql_text TEXT;
    params TEXT[];
    param_values TEXT[];
    param_count INT := 0;
BEGIN
    sql_text := 'SELECT * FROM employees WHERE 1=1';
    
    IF p_name IS NOT NULL THEN
        param_count := param_count + 1;
        sql_text := sql_text || ' AND name LIKE ''%'' || $' || param_count || ' || ''%''';
        param_values := array_append(param_values, p_name);
    END IF;
    
    IF p_department_id IS NOT NULL THEN
        param_count := param_count + 1;
        sql_text := sql_text || ' AND department_id = $' || param_count;
        param_values := array_append(param_values, p_department_id::TEXT);
    END IF;
    
    IF p_min_salary IS NOT NULL THEN
        param_count := param_count + 1;
        sql_text := sql_text || ' AND salary >= $' || param_count;
        param_values := array_append(param_values, p_min_salary::TEXT);
    END IF;
    
    RETURN QUERY EXECUTE sql_text USING VARIADIC param_values;
END;
$$;
```

#### Oracle
```sql
-- Dynamic query with conditional WHERE clauses
CREATE OR REPLACE PROCEDURE search_employees(
    p_name IN VARCHAR2 DEFAULT NULL,
    p_department_id IN NUMBER DEFAULT NULL,
    p_min_salary IN NUMBER DEFAULT NULL,
    p_result OUT SYS_REFCURSOR
)
AS
    sql_text VARCHAR2(4000);
BEGIN
    sql_text := 'SELECT * FROM employees WHERE 1=1';
    
    IF p_name IS NOT NULL THEN
        sql_text := sql_text || ' AND name LIKE ''%'' || :name || ''%''';
    END IF;
    
    IF p_department_id IS NOT NULL THEN
        sql_text := sql_text || ' AND department_id = :dept_id';
    END IF;
    
    IF p_min_salary IS NOT NULL THEN
        sql_text := sql_text || ' AND salary >= :min_sal';
    END IF;
    
    OPEN p_result FOR sql_text USING p_name, p_department_id, p_min_salary;
END;
/
```

### Security Considerations for Dynamic SQL

1. **SQL Injection Prevention**
   - Always use parameterized queries
   - Never concatenate user input directly into SQL strings
   - Validate and sanitize input data

2. **Privilege Management**
   - Execute dynamic SQL with appropriate permissions
   - Use EXECUTE AS or similar features to control execution context
   - Grant minimal necessary privileges

3. **Error Handling**
   - Implement robust error handling for dynamic SQL
   - Log errors and unexpected behavior
   - Prevent error messages from revealing sensitive information

4. **Code Reviews**
   - Subject dynamic SQL to thorough code reviews
   - Look for potential security vulnerabilities
   - Consider alternatives to dynamic SQL when possible

5. **Testing**
   - Test dynamic SQL with various inputs including edge cases
   - Include security testing in your test plan
   - Verify that error handling works as expected 