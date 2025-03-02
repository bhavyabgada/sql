# SQL Transactions and Concurrency Cheatsheet

This cheatsheet provides an exhaustive reference for SQL transaction control and concurrency management covered in the lesson:
1. Transaction Control
2. Row Locking
3. Concurrency Control and Isolation Levels

## 1. Transaction Control

### Basic Transaction Structure

#### Standard SQL Syntax
```sql
BEGIN TRANSACTION;
    -- SQL statements here
COMMIT;
```

#### Database-Specific Variations
```sql
-- MySQL/MariaDB
START TRANSACTION;
    -- SQL statements
COMMIT;

-- PostgreSQL
BEGIN;
    -- SQL statements
COMMIT;

-- Oracle
BEGIN
    -- SQL statements
COMMIT;

-- SQL Server
BEGIN TRANSACTION;
    -- SQL statements
COMMIT TRANSACTION;
```

### Transaction Operations

#### COMMIT
```sql
COMMIT;
```
- Makes all changes permanent
- Ends the current transaction
- Releases locks acquired during the transaction
- Cannot be undone

#### ROLLBACK
```sql
ROLLBACK;
```
- Undoes all changes made in the current transaction
- Ends the current transaction
- Releases locks acquired during the transaction
- Returns the database to its state before the transaction began

#### SAVEPOINT
```sql
SAVEPOINT savepoint_name;
```
- Creates a point within a transaction to which you can later roll back
- Does not end the current transaction
- Multiple savepoints can be created within a transaction

#### ROLLBACK TO SAVEPOINT
```sql
ROLLBACK TO SAVEPOINT savepoint_name;
```
- Rolls back to the named savepoint
- Undoes changes made after the savepoint
- Keeps changes made before the savepoint
- Does not end the transaction

### Error Handling in Transactions

#### SQL Server TRY-CATCH
```sql
BEGIN TRANSACTION;
BEGIN TRY
    -- SQL statements
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    -- Error handling code
END CATCH;
```

#### PostgreSQL Error Handling
```sql
BEGIN;
    -- SQL statements
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
```

#### Oracle PL/SQL Error Handling
```sql
BEGIN
    -- SQL statements
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
```

### Automatic Transaction Control

#### Auto-Commit Mode
- Default behavior in many database systems
- Each SQL statement is treated as a separate transaction
- Automatically committed if successful
- Can be disabled to allow explicit transaction control

```sql
-- Disable auto-commit in MySQL
SET autocommit = 0;

-- Enable auto-commit in MySQL
SET autocommit = 1;
```

#### Implicit Transactions
```sql
-- SQL Server: Enable implicit transactions
SET IMPLICIT_TRANSACTIONS ON;

-- SQL Server: Disable implicit transactions
SET IMPLICIT_TRANSACTIONS OFF;
```
- Automatically starts a transaction when certain statements are executed
- Requires explicit COMMIT or ROLLBACK to end the transaction

## 2. Row Locking

### Explicit Locking

#### SELECT FOR UPDATE
```sql
-- Lock rows for update
SELECT * FROM employees
WHERE department_id = 10
FOR UPDATE;

-- Lock specific rows with NOWAIT option (Oracle, PostgreSQL)
SELECT * FROM employees
WHERE department_id = 10
FOR UPDATE NOWAIT;

-- Lock with timeout (PostgreSQL)
SELECT * FROM employees
WHERE department_id = 10
FOR UPDATE WAIT 5; -- Wait up to 5 seconds
```
- Locks selected rows for the duration of the transaction
- Prevents other transactions from modifying or locking the same rows
- Other transactions can still read the rows (depending on isolation level)
- NOWAIT: Fails immediately if rows are already locked
- WAIT n: Waits up to n seconds before failing

#### SELECT FOR SHARE / LOCK IN SHARE MODE
```sql
-- PostgreSQL
SELECT * FROM employees
WHERE department_id = 10
FOR SHARE;

-- MySQL
SELECT * FROM employees
WHERE department_id = 10
LOCK IN SHARE MODE;
```
- Locks selected rows for reading
- Prevents other transactions from modifying the rows
- Allows other transactions to read or acquire share locks on the same rows
- Less restrictive than FOR UPDATE

#### Table-Level Locks
```sql
-- PostgreSQL
LOCK TABLE employees IN EXCLUSIVE MODE;

-- MySQL
LOCK TABLES employees WRITE;

-- SQL Server
BEGIN TRANSACTION;
    SELECT * FROM employees WITH (TABLOCKX);
```
- Locks the entire table
- Prevents other transactions from accessing the table
- Can cause significant blocking in multi-user environments
- Should be used sparingly

### Implicit Locking

- Automatically applied by the database system
- INSERT, UPDATE, DELETE statements implicitly lock affected rows
- Level of locking depends on the database system and isolation level
- No explicit syntax required

### Deadlock Prevention

#### Consistent Lock Acquisition Order
```sql
-- Always acquire locks in the same order
BEGIN TRANSACTION;
    -- First lock table A
    SELECT * FROM table_a WHERE id = 1 FOR UPDATE;
    -- Then lock table B
    SELECT * FROM table_b WHERE id = 2 FOR UPDATE;
COMMIT;
```
- Always acquire locks in the same order across all transactions
- Helps prevent deadlocks caused by circular waiting

#### Deadlock Detection and Resolution
```sql
-- Set deadlock timeout (PostgreSQL)
SET deadlock_timeout = 1000; -- 1 second

-- Set deadlock priority (SQL Server)
SET DEADLOCK_PRIORITY HIGH;
```
- Database systems automatically detect and resolve deadlocks
- One transaction is chosen as the "victim" and rolled back
- The other transaction(s) can proceed

#### Minimizing Lock Duration
```sql
-- Gather data first without locks
SELECT * FROM employees WHERE id = 10;

-- Process data outside transaction

-- Start transaction only when ready to update
BEGIN TRANSACTION;
    UPDATE employees SET salary = 55000 WHERE id = 10;
COMMIT;
```
- Keep transactions as short as possible
- Acquire locks as late as possible
- Release locks as early as possible

## 3. Concurrency Control and Isolation Levels

### Transaction Isolation Levels

#### Setting Isolation Level
```sql
-- Standard SQL
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- SQL Server
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

-- PostgreSQL
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
```

#### READ UNCOMMITTED
- Lowest isolation level
- Transactions can read uncommitted changes from other transactions
- Allows dirty reads, non-repeatable reads, and phantom reads
- Highest concurrency, lowest consistency

#### READ COMMITTED
- Default in many database systems (PostgreSQL, Oracle, SQL Server)
- Transactions can only read committed changes from other transactions
- Prevents dirty reads
- Allows non-repeatable reads and phantom reads
- Good balance between concurrency and consistency

#### REPEATABLE READ
- Default in MySQL/MariaDB
- Ensures that if a row is read twice within the same transaction, the values will be the same
- Prevents dirty reads and non-repeatable reads
- May allow phantom reads (except in MySQL which prevents them)
- Lower concurrency, higher consistency

#### SERIALIZABLE
- Highest isolation level
- Transactions are completely isolated from each other
- Prevents dirty reads, non-repeatable reads, and phantom reads
- Lowest concurrency, highest consistency
- May use locking to enforce isolation

#### SNAPSHOT (SQL Server, PostgreSQL)
- Transactions see a snapshot of the database as it was at the start of the transaction
- Prevents dirty reads, non-repeatable reads, and phantom reads
- Uses row versioning instead of locking
- Good balance between isolation and concurrency

### Concurrency Phenomena

#### Dirty Read
- Transaction reads data that has been modified by another transaction but not yet committed
- Can lead to inconsistent data if the other transaction is rolled back
- Prevented by all isolation levels except READ UNCOMMITTED

#### Non-repeatable Read
- Transaction reads the same row twice and gets different values
- Occurs when another transaction modifies and commits changes to the row between reads
- Prevented by REPEATABLE READ, SERIALIZABLE, and SNAPSHOT isolation levels

#### Phantom Read
- Transaction executes the same query twice and gets different sets of rows
- Occurs when another transaction adds or removes rows that match the query between executions
- Prevented by SERIALIZABLE isolation level (and by REPEATABLE READ in MySQL)

#### Lost Update
- Two transactions read the same row, modify it based on the original value, and update it
- The second update overwrites the first update without considering its changes
- Can be prevented using SELECT FOR UPDATE or optimistic concurrency control

### Optimistic vs. Pessimistic Concurrency Control

#### Pessimistic Concurrency Control
- Assumes conflicts will occur and prevents them using locks
- Uses explicit locking (SELECT FOR UPDATE, etc.)
- Prevents conflicts but may reduce concurrency
- Good for high-contention environments

#### Optimistic Concurrency Control
```sql
-- Using version column
BEGIN TRANSACTION;
    -- Read the current data and version
    SELECT id, name, salary, version FROM employees WHERE id = 10;
    
    -- Update with version check
    UPDATE employees 
    SET salary = 55000, version = version + 1 
    WHERE id = 10 AND version = 5;
    
    -- Check if update succeeded (affected rows = 1)
    -- If not, handle concurrency conflict
COMMIT;

-- Using timestamp
BEGIN TRANSACTION;
    -- Read the current data and last_updated timestamp
    SELECT id, name, salary, last_updated FROM employees WHERE id = 10;
    
    -- Update with timestamp check
    UPDATE employees 
    SET salary = 55000, last_updated = CURRENT_TIMESTAMP 
    WHERE id = 10 AND last_updated = '2023-01-15 14:30:00';
COMMIT;
```
- Assumes conflicts are rare and detects them at commit time
- No locks during the transaction
- Higher concurrency but must handle conflicts when they occur
- Good for low-contention environments

### Multi-Version Concurrency Control (MVCC)

- Used by PostgreSQL, Oracle, MySQL (InnoDB), SQL Server (snapshot isolation)
- Maintains multiple versions of data
- Readers don't block writers, and writers don't block readers
- Each transaction sees a consistent snapshot of the database
- Improves concurrency while maintaining isolation

### Practical Applications

#### Financial Transactions
```sql
BEGIN TRANSACTION;
    -- Deduct amount from source account
    UPDATE accounts 
    SET balance = balance - 1000 
    WHERE account_id = 123;
    
    -- Add amount to destination account
    UPDATE accounts 
    SET balance = balance + 1000 
    WHERE account_id = 456;
    
    -- Record the transfer
    INSERT INTO transfers (source_account, destination_account, amount, transfer_date)
    VALUES (123, 456, 1000, CURRENT_TIMESTAMP);
COMMIT;
```
- All operations must succeed or fail together
- Maintains consistency between related tables
- Prevents partial updates

#### Inventory Management
```sql
BEGIN TRANSACTION;
    -- Check if enough inventory is available
    SELECT quantity FROM inventory WHERE product_id = 789;
    
    -- If quantity >= 5, proceed with order
    UPDATE inventory
    SET quantity = quantity - 5
    WHERE product_id = 789 AND quantity >= 5;
    
    -- Check if update succeeded (affected rows = 1)
    -- If not, roll back and report insufficient inventory
    
    -- Create order
    INSERT INTO orders (customer_id, product_id, quantity, order_date)
    VALUES (101, 789, 5, CURRENT_TIMESTAMP);
COMMIT;
```
- Ensures inventory is not oversold
- Maintains consistency between inventory and orders
- Handles race conditions between concurrent orders

#### Batch Processing
```sql
BEGIN TRANSACTION;
    -- Process a batch of records
    UPDATE large_table
    SET processed = TRUE
    WHERE processed = FALSE
    LIMIT 1000;
    
    -- Record the batch processing
    INSERT INTO processing_log (batch_size, process_date)
    VALUES (@@ROW_COUNT, CURRENT_TIMESTAMP);
COMMIT;
```
- Processes records in manageable batches
- Reduces lock duration and contention
- Allows for recovery if a batch fails 