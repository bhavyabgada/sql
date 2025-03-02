-- 5. PROCEDURAL SQL
-- This file covers procedural extensions to SQL including stored procedures and triggers

-- 5.1 Stored Procedures (CREATE PROCEDURE, CALL, EXECUTE IMMEDIATE)
-- Example of stored procedure from the master query
CREATE PROCEDURE DynamicQueryExecution(IN sql_query TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
    EXECUTE sql_query;
END;
$$;

-- Calling a stored procedure
CALL DynamicQueryExecution('SELECT * FROM main_table WHERE id = 1');

-- MySQL stored procedure with parameters and logic
DELIMITER //
CREATE PROCEDURE UpdateEmployeeSalary(
    IN employee_id INT,
    IN salary_increase DECIMAL(10,2)
)
BEGIN
    DECLARE current_salary DECIMAL(10,2);
    
    -- Get current salary
    SELECT salary INTO current_salary
    FROM employees
    WHERE id = employee_id;
    
    -- Update with increase
    UPDATE employees
    SET salary = current_salary + salary_increase
    WHERE id = employee_id;
    
    -- Log the change
    INSERT INTO salary_changes (employee_id, old_salary, new_salary, change_date)
    VALUES (employee_id, current_salary, current_salary + salary_increase, CURRENT_DATE);
END //
DELIMITER ;

-- 5.2 Triggers (CREATE TRIGGER, AFTER UPDATE, BEFORE INSERT)
-- Example of trigger from the master query
CREATE TRIGGER after_update_trigger
AFTER UPDATE ON some_table
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, operation, timestamp)
    VALUES ('some_table', 'UPDATE', CURRENT_TIMESTAMP);
END;

-- Before insert trigger example
CREATE TRIGGER before_employee_insert
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    -- Set default department if not specified
    IF NEW.department_id IS NULL THEN
        SET NEW.department_id = 1;
    END IF;
    
    -- Set creation timestamp
    SET NEW.created_at = CURRENT_TIMESTAMP;
END;

-- 5.3 Dynamic SQL (EXECUTE IMMEDIATE, PREPARE)
-- Example from stored procedure above using EXECUTE
-- Additional Oracle-style dynamic SQL example
CREATE OR REPLACE PROCEDURE GenerateReport(
    table_name IN VARCHAR2,
    where_clause IN VARCHAR2
)
AS
    v_sql VARCHAR2(1000);
BEGIN
    v_sql := 'SELECT * FROM ' || table_name;
    
    IF where_clause IS NOT NULL THEN
        v_sql := v_sql || ' WHERE ' || where_clause;
    END IF;
    
    EXECUTE IMMEDIATE v_sql;
END;

-- Note: Procedural SQL extends the declarative nature of SQL with programming constructs.
-- This allows for more complex logic and automation within the database itself. 