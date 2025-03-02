# SQL Unique Features Cheatsheet

This cheatsheet provides a comprehensive reference for specialized SQL features:
1. Recursive Queries
2. Geospatial Data Queries
3. Graph Queries

## 1. Recursive Queries

### Common Table Expressions (CTE) with Recursion

#### PostgreSQL, SQL Server, MySQL (8.0+)
```sql
-- Basic recursive CTE structure
WITH RECURSIVE recursive_cte AS (
    -- Base case (anchor member)
    SELECT id, parent_id, name, 1 AS level
    FROM hierarchy_table
    WHERE parent_id IS NULL
    
    UNION ALL
    
    -- Recursive case
    SELECT h.id, h.parent_id, h.name, r.level + 1
    FROM hierarchy_table h
    JOIN recursive_cte r ON h.parent_id = r.id
)
SELECT * FROM recursive_cte;
```

#### Oracle (Prior to 11g R2)
```sql
-- Using CONNECT BY for hierarchical queries
SELECT 
    id, 
    parent_id, 
    name, 
    LEVEL AS level
FROM hierarchy_table
START WITH parent_id IS NULL
CONNECT BY PRIOR id = parent_id;
```

### Hierarchical Data Traversal

#### Employee Hierarchy Example
```sql
-- PostgreSQL, SQL Server, MySQL (8.0+)
WITH RECURSIVE employee_hierarchy AS (
    -- Base case: top-level employees (CEO, etc.)
    SELECT 
        id,
        name,
        title,
        manager_id,
        1 AS level,
        ARRAY[name] AS path,
        name AS path_text
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive case: employees with managers
    SELECT 
        e.id,
        e.name,
        e.title,
        e.manager_id,
        eh.level + 1,
        eh.path || e.name,
        eh.path_text || ' > ' || e.name
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.id
)
SELECT 
    id,
    name,
    title,
    level,
    path_text AS reporting_chain
FROM employee_hierarchy
ORDER BY path;

-- Oracle
SELECT 
    id,
    name,
    title,
    LEVEL AS level,
    SYS_CONNECT_BY_PATH(name, ' > ') AS reporting_chain
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR id = manager_id
ORDER BY LEVEL, name;
```

### Tree Structure Navigation

#### File System Example
```sql
-- PostgreSQL, SQL Server, MySQL (8.0+)
WITH RECURSIVE file_paths AS (
    -- Base case: root directories
    SELECT 
        id,
        name,
        parent_id,
        name AS path,
        1 AS depth,
        ARRAY[id] AS path_ids
    FROM files
    WHERE parent_id IS NULL
    
    UNION ALL
    
    -- Recursive case: subdirectories and files
    SELECT 
        f.id,
        f.name,
        f.parent_id,
        fp.path || '/' || f.name,
        fp.depth + 1,
        fp.path_ids || f.id
    FROM files f
    JOIN file_paths fp ON f.parent_id = fp.id
)
SELECT id, name, path, depth
FROM file_paths
ORDER BY path;

-- Oracle
SELECT 
    id,
    name,
    parent_id,
    LEVEL AS depth,
    SYS_CONNECT_BY_PATH(name, '/') AS path
FROM files
START WITH parent_id IS NULL
CONNECT BY PRIOR id = parent_id
ORDER BY path;
```

### Generating Series and Sequences

```sql
-- PostgreSQL: Generate a series of dates
WITH RECURSIVE date_series AS (
    SELECT 
        '2023-01-01'::date AS date
    
    UNION ALL
    
    SELECT 
        date + 1
    FROM date_series
    WHERE date < '2023-12-31'
)
SELECT date FROM date_series;

-- SQL Server: Generate a series of numbers
WITH numbers AS (
    SELECT 1 AS n
    
    UNION ALL
    
    SELECT n + 1
    FROM numbers
    WHERE n < 100
)
SELECT n FROM numbers
OPTION (MAXRECURSION 100);

-- Oracle: Generate a series of numbers using CONNECT BY
SELECT LEVEL AS n
FROM dual
CONNECT BY LEVEL <= 100;
```

### Cycle Detection

```sql
-- PostgreSQL: Detect cycles in hierarchical data
WITH RECURSIVE hierarchy_with_cycle_check AS (
    SELECT 
        id,
        parent_id,
        name,
        ARRAY[id] AS path,
        false AS has_cycle
    FROM hierarchy_table
    WHERE parent_id IS NULL
    
    UNION ALL
    
    SELECT 
        h.id,
        h.parent_id,
        h.name,
        hc.path || h.id,
        h.id = ANY(hc.path) AS has_cycle
    FROM hierarchy_table h
    JOIN hierarchy_with_cycle_check hc ON h.parent_id = hc.id
    WHERE NOT hc.has_cycle
)
SELECT id, name, has_cycle, path
FROM hierarchy_with_cycle_check
ORDER BY path;

-- SQL Server: Detect cycles with MAXRECURSION
WITH hierarchy_with_cycle_check AS (
    SELECT 
        id,
        parent_id,
        name,
        CAST(id AS VARCHAR(MAX)) AS path,
        0 AS cycle_check
    FROM hierarchy_table
    WHERE parent_id IS NULL
    
    UNION ALL
    
    SELECT 
        h.id,
        h.parent_id,
        h.name,
        hc.path + ',' + CAST(h.id AS VARCHAR(MAX)),
        CASE WHEN CHARINDEX(CAST(h.id AS VARCHAR(MAX)), hc.path) > 0 THEN 1 ELSE 0 END
    FROM hierarchy_table h
    JOIN hierarchy_with_cycle_check hc ON h.parent_id = hc.id
    WHERE hc.cycle_check = 0
)
SELECT id, name, 
       CASE WHEN cycle_check = 1 THEN 'Has Cycle' ELSE 'No Cycle' END AS cycle_status,
       path
FROM hierarchy_with_cycle_check
OPTION (MAXRECURSION 100);
```

## 2. Geospatial Data Queries

### Spatial Data Types

#### PostgreSQL (PostGIS)
```sql
-- Create a table with geometry column
CREATE TABLE locations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    location GEOMETRY(POINT, 4326)  -- SRID 4326 = WGS84
);

-- Insert point data
INSERT INTO locations (name, location)
VALUES ('Central Park', ST_SetSRID(ST_MakePoint(-73.965355, 40.782865), 4326));

-- Create a polygon
CREATE TABLE neighborhoods (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    boundary GEOMETRY(POLYGON, 4326)
);

-- Insert polygon data
INSERT INTO neighborhoods (name, boundary)
VALUES ('Downtown', ST_GeomFromText('POLYGON((-74.01 40.70, -73.99 40.70, -73.99 40.72, -74.01 40.72, -74.01 40.70))', 4326));
```

#### SQL Server
```sql
-- Create a table with geometry column
CREATE TABLE locations (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100),
    location GEOGRAPHY
);

-- Insert point data
INSERT INTO locations (name, location)
VALUES ('Central Park', geography::Point(40.782865, -73.965355, 4326));

-- Create a polygon
CREATE TABLE neighborhoods (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100),
    boundary GEOGRAPHY
);

-- Insert polygon data
INSERT INTO neighborhoods (name, boundary)
VALUES ('Downtown', geography::STGeomFromText('POLYGON((-74.01 40.70, -73.99 40.70, -73.99 40.72, -74.01 40.72, -74.01 40.70))', 4326));
```

#### MySQL
```sql
-- Create a table with geometry column
CREATE TABLE locations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    location POINT SRID 4326
);

-- Insert point data
INSERT INTO locations (name, location)
VALUES ('Central Park', ST_GeomFromText('POINT(-73.965355 40.782865)', 4326));

-- Create a polygon
CREATE TABLE neighborhoods (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    boundary POLYGON SRID 4326
);

-- Insert polygon data
INSERT INTO neighborhoods (name, boundary)
VALUES ('Downtown', ST_GeomFromText('POLYGON((-74.01 40.70, -73.99 40.70, -73.99 40.72, -74.01 40.72, -74.01 40.70))', 4326));
```

### Distance Calculations

#### PostgreSQL (PostGIS)
```sql
-- Calculate distance between two points (in meters)
SELECT ST_Distance(
    ST_SetSRID(ST_MakePoint(-73.985428, 40.748817), 4326)::geography,  -- Empire State Building
    ST_SetSRID(ST_MakePoint(-73.965355, 40.782865), 4326)::geography   -- Central Park
) AS distance_meters;

-- Find all locations within 5km of a point
SELECT 
    name,
    ST_Distance(
        location::geography,
        ST_SetSRID(ST_MakePoint(-73.985428, 40.748817), 4326)::geography
    ) AS distance_meters
FROM locations
WHERE ST_DWithin(
    location::geography,
    ST_SetSRID(ST_MakePoint(-73.985428, 40.748817), 4326)::geography,
    5000  -- 5km radius
)
ORDER BY distance_meters;
```

#### SQL Server
```sql
-- Calculate distance between two points (in meters)
DECLARE @point1 GEOGRAPHY = geography::Point(40.748817, -73.985428, 4326);  -- Empire State Building
DECLARE @point2 GEOGRAPHY = geography::Point(40.782865, -73.965355, 4326);  -- Central Park

SELECT @point1.STDistance(@point2) AS distance_meters;

-- Find all locations within 5km of a point
DECLARE @center GEOGRAPHY = geography::Point(40.748817, -73.985428, 4326);

SELECT 
    name,
    location.STDistance(@center) AS distance_meters
FROM locations
WHERE location.STDistance(@center) <= 5000  -- 5km radius
ORDER BY distance_meters;
```

#### MySQL
```sql
-- Calculate distance between two points (in meters)
SELECT ST_Distance_Sphere(
    ST_GeomFromText('POINT(-73.985428 40.748817)', 4326),  -- Empire State Building
    ST_GeomFromText('POINT(-73.965355 40.782865)', 4326)   -- Central Park
) AS distance_meters;

-- Find all locations within 5km of a point
SELECT 
    name,
    ST_Distance_Sphere(
        location,
        ST_GeomFromText('POINT(-73.985428 40.748817)', 4326)
    ) AS distance_meters
FROM locations
WHERE ST_Distance_Sphere(
    location,
    ST_GeomFromText('POINT(-73.985428 40.748817)', 4326)
) <= 5000  -- 5km radius
ORDER BY distance_meters;
```

### Spatial Relationships

#### PostgreSQL (PostGIS)
```sql
-- Find points within a polygon
SELECT 
    l.name AS location_name,
    n.name AS neighborhood
FROM locations l
JOIN neighborhoods n ON ST_Contains(n.boundary, l.location)
WHERE n.name = 'Downtown';

-- Find polygons that intersect
SELECT 
    a.name AS neighborhood_a,
    b.name AS neighborhood_b
FROM neighborhoods a
JOIN neighborhoods b ON ST_Intersects(a.boundary, b.boundary)
WHERE a.id < b.id;  -- Avoid duplicates

-- Find the area of intersection between two polygons
SELECT 
    a.name AS neighborhood_a,
    b.name AS neighborhood_b,
    ST_Area(ST_Intersection(a.boundary, b.boundary)::geography) AS intersection_area_m2
FROM neighborhoods a
JOIN neighborhoods b ON ST_Intersects(a.boundary, b.boundary)
WHERE a.id < b.id;
```

#### SQL Server
```sql
-- Find points within a polygon
SELECT 
    l.name AS location_name,
    n.name AS neighborhood
FROM locations l
JOIN neighborhoods n ON n.boundary.STContains(l.location) = 1
WHERE n.name = 'Downtown';

-- Find polygons that intersect
SELECT 
    a.name AS neighborhood_a,
    b.name AS neighborhood_b
FROM neighborhoods a
JOIN neighborhoods b ON a.boundary.STIntersects(b.boundary) = 1
WHERE a.id < b.id;  -- Avoid duplicates

-- Find the area of intersection between two polygons
SELECT 
    a.name AS neighborhood_a,
    b.name AS neighborhood_b,
    a.boundary.STIntersection(b.boundary).STArea() AS intersection_area_m2
FROM neighborhoods a
JOIN neighborhoods b ON a.boundary.STIntersects(b.boundary) = 1
WHERE a.id < b.id;
```

#### MySQL
```sql
-- Find points within a polygon
SELECT 
    l.name AS location_name,
    n.name AS neighborhood
FROM locations l
JOIN neighborhoods n ON ST_Contains(n.boundary, l.location)
WHERE n.name = 'Downtown';

-- Find polygons that intersect
SELECT 
    a.name AS neighborhood_a,
    b.name AS neighborhood_b
FROM neighborhoods a
JOIN neighborhoods b ON ST_Intersects(a.boundary, b.boundary)
WHERE a.id < b.id;  -- Avoid duplicates

-- Find the area of intersection between two polygons
SELECT 
    a.name AS neighborhood_a,
    b.name AS neighborhood_b,
    ST_Area(ST_Intersection(a.boundary, b.boundary)) AS intersection_area_m2
FROM neighborhoods a
JOIN neighborhoods b ON ST_Intersects(a.boundary, b.boundary)
WHERE a.id < b.id;
```

### Spatial Indexing and Optimization

#### PostgreSQL (PostGIS)
```sql
-- Create a spatial index
CREATE INDEX idx_locations_location ON locations USING GIST (location);
CREATE INDEX idx_neighborhoods_boundary ON neighborhoods USING GIST (boundary);

-- Analyze the tables for better query planning
ANALYZE locations;
ANALYZE neighborhoods;

-- Use spatial index for efficient querying
EXPLAIN ANALYZE
SELECT 
    name,
    ST_Distance(
        location::geography,
        ST_SetSRID(ST_MakePoint(-73.985428, 40.748817), 4326)::geography
    ) AS distance_meters
FROM locations
WHERE ST_DWithin(
    location::geography,
    ST_SetSRID(ST_MakePoint(-73.985428, 40.748817), 4326)::geography,
    5000  -- 5km radius
)
ORDER BY distance_meters;
```

#### SQL Server
```sql
-- Create a spatial index
CREATE SPATIAL INDEX idx_locations_location ON locations(location);
CREATE SPATIAL INDEX idx_neighborhoods_boundary ON neighborhoods(boundary);

-- Use spatial index for efficient querying
DECLARE @center GEOGRAPHY = geography::Point(40.748817, -73.985428, 4326);

SELECT 
    name,
    location.STDistance(@center) AS distance_meters
FROM locations WITH(INDEX(idx_locations_location))
WHERE location.STDistance(@center) <= 5000  -- 5km radius
ORDER BY distance_meters;
```

#### MySQL
```sql
-- Create a spatial index
CREATE SPATIAL INDEX idx_locations_location ON locations(location);
CREATE SPATIAL INDEX idx_neighborhoods_boundary ON neighborhoods(boundary);

-- Use spatial index for efficient querying
SELECT 
    name,
    ST_Distance_Sphere(
        location,
        ST_GeomFromText('POINT(-73.985428 40.748817)', 4326)
    ) AS distance_meters
FROM locations
WHERE MBRContains(
    ST_Buffer(
        ST_GeomFromText('POINT(-73.985428 40.748817)', 4326),
        0.05  -- Approximate 5km buffer in degrees
    ),
    location
)
ORDER BY distance_meters;
```

## 3. Graph Queries

### Property Graph Models

#### Oracle (Property Graph)
```sql
-- Create a property graph
CREATE PROPERTY GRAPH employees_graph
    VERTEX TABLES (
        employees AS employees_v
        KEY (id)
        PROPERTIES (id, name, title, department)
    )
    EDGE TABLES (
        employee_relations AS reports_to_e
        KEY (id)
        SOURCE KEY (employee_id) REFERENCES employees_v
        DESTINATION KEY (manager_id) REFERENCES employees_v
        PROPERTIES (relationship_type)
        LABEL reports_to
    );
```

#### SQL Server (Graph Database - SQL Server 2017+)
```sql
-- Create node table
CREATE TABLE Person (
    ID INTEGER PRIMARY KEY,
    name VARCHAR(100),
    age INTEGER
) AS NODE;

-- Create edge table
CREATE TABLE Friendship (
    start_date DATE
) AS EDGE;

-- Insert nodes
INSERT INTO Person (ID, name, age)
VALUES (1, 'Alice', 30),
       (2, 'Bob', 32),
       (3, 'Charlie', 25);

-- Insert edges
INSERT INTO Friendship
    VALUES ((SELECT $node_id FROM Person WHERE ID = 1),
            (SELECT $node_id FROM Person WHERE ID = 2),
            '2020-01-15');
```

### Path Finding Algorithms

#### PostgreSQL (Using recursive CTE)
```sql
-- Find all paths between two nodes
WITH RECURSIVE paths(start_id, end_id, path, depth) AS (
    -- Base case: direct connections from start node
    SELECT 
        e.source_id,
        e.target_id,
        ARRAY[e.source_id, e.target_id],
        1
    FROM edges e
    WHERE e.source_id = 1  -- Start node
    
    UNION ALL
    
    -- Recursive case: extend paths
    SELECT 
        p.start_id,
        e.target_id,
        p.path || e.target_id,
        p.depth + 1
    FROM edges e
    JOIN paths p ON e.source_id = p.end_id
    WHERE NOT e.target_id = ANY(p.path)  -- Avoid cycles
      AND p.depth < 5  -- Limit path length
)
SELECT 
    start_id,
    end_id,
    path,
    depth
FROM paths
WHERE end_id = 5  -- End node
ORDER BY depth;
```

#### Oracle (Using CONNECT BY)
```sql
-- Find all paths between two nodes
SELECT 
    CONNECT_BY_ROOT source_id AS start_id,
    target_id AS end_id,
    SYS_CONNECT_BY_PATH(source_id, '->') || '->' || target_id AS path,
    LEVEL AS depth
FROM edges
START WITH source_id = 1  -- Start node
CONNECT BY NOCYCLE PRIOR target_id = source_id
           AND LEVEL <= 5  -- Limit path length
HAVING target_id = 5  -- End node
ORDER BY LEVEL;
```

### Graph Traversal and Pattern Matching

#### Oracle (Property Graph)
```sql
-- Find direct reports
SELECT 
    src.name AS employee,
    dst.name AS manager
FROM employees_graph
MATCH (src)-[:REPORTS_TO]->(dst)
WHERE dst.department = 'Engineering';

-- Find second-level reports (skip connections)
SELECT 
    src.name AS employee,
    mid.name AS manager,
    dst.name AS director
FROM employees_graph
MATCH (src)-[:REPORTS_TO]->(mid)-[:REPORTS_TO]->(dst)
WHERE dst.title = 'Director';
```

#### SQL Server (Graph Database)
```sql
-- Find direct friends
SELECT 
    Person1.name AS person,
    Person2.name AS friend
FROM Person AS Person1,
     Friendship,
     Person AS Person2
WHERE MATCH(Person1-(Friendship)->Person2);

-- Find friends of friends
SELECT 
    Person1.name AS person,
    Person2.name AS friend_of_friend
FROM Person AS Person1,
     Friendship AS Friendship1,
     Person AS Friend1,
     Friendship AS Friendship2,
     Person AS Person2
WHERE MATCH(Person1-(Friendship1)->Friend1-(Friendship2)->Person2)
  AND Person1.ID <> Person2.ID  -- Not the same person
  AND NOT EXISTS (  -- Not already direct friends
      SELECT 1
      FROM Friendship AS DirectFriendship
      WHERE MATCH(Person1-(DirectFriendship)->Person2)
  );
```

### Relationship Analysis

#### PostgreSQL (Using recursive CTE)
```sql
-- Find the shortest path between two nodes
WITH RECURSIVE shortest_paths AS (
    -- Base case: direct connections from start node
    SELECT 
        e.source_id,
        e.target_id,
        ARRAY[e.source_id, e.target_id] AS path,
        1 AS depth,
        e.weight
    FROM edges e
    WHERE e.source_id = 1  -- Start node
    
    UNION ALL
    
    -- Recursive case: extend paths
    SELECT 
        sp.source_id,
        e.target_id,
        sp.path || e.target_id,
        sp.depth + 1,
        sp.weight + e.weight
    FROM edges e
    JOIN shortest_paths sp ON e.source_id = sp.target_id
    WHERE NOT e.target_id = ANY(sp.path)  -- Avoid cycles
      AND sp.depth < 10  -- Limit path length
)
SELECT 
    source_id,
    target_id,
    path,
    depth,
    weight
FROM shortest_paths
WHERE target_id = 5  -- End node
ORDER BY weight, depth
LIMIT 1;  -- Get the shortest path

-- Find all nodes within N connections
WITH RECURSIVE connected_nodes AS (
    -- Base case: start node
    SELECT 
        id,
        name,
        0 AS distance
    FROM nodes
    WHERE id = 1  -- Start node
    
    UNION ALL
    
    -- Recursive case: connected nodes
    SELECT 
        n.id,
        n.name,
        cn.distance + 1
    FROM nodes n
    JOIN edges e ON n.id = e.target_id
    JOIN connected_nodes cn ON e.source_id = cn.id
    WHERE cn.distance < 3  -- Limit to 3 connections
      AND n.id NOT IN (SELECT id FROM connected_nodes)  -- Avoid duplicates
)
SELECT id, name, distance
FROM connected_nodes
ORDER BY distance, name;
```

#### SQL Server (Graph Database)
```sql
-- Find the influence score (number of connections)
SELECT 
    Person.name,
    COUNT(Friendship.start_date) AS connection_count
FROM Person,
     Friendship
WHERE MATCH(Person-(Friendship)->())
GROUP BY Person.name
ORDER BY connection_count DESC;

-- Find communities (groups of densely connected people)
WITH friendship_counts AS (
    SELECT 
        p1.$node_id AS person1_id,
        p2.$node_id AS person2_id,
        COUNT(*) AS common_friends
    FROM Person p1, 
         Friendship f1, 
         Person common, 
         Friendship f2, 
         Person p2
    WHERE MATCH(p1-(f1)->common-(f2)->p2)
      AND p1.ID <> p2.ID
    GROUP BY p1.$node_id, p2.$node_id
)
SELECT 
    p1.name AS person1,
    p2.name AS person2,
    fc.common_friends
FROM friendship_counts fc
JOIN Person p1 ON fc.person1_id = p1.$node_id
JOIN Person p2 ON fc.person2_id = p2.$node_id
WHERE fc.common_friends >= 3  -- At least 3 common friends
ORDER BY fc.common_friends DESC;
``` 