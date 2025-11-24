---PL/SQL BLOCK
SET SERVEROUTPUT ON

DECLARE
  -- Specific column from table.
  l_username  all_users.username%TYPE;
  
  -- Whole record from table.
  l_all_users_row  all_users%ROWTYPE;
  
  CURSOR c_user_data IS
    SELECT username,
           created
    FROM   all_users
    WHERE  username = 'SYS';
    
  -- Record that matches cursor definition. 
  l_all_users_cursor_row  c_user_data%ROWTYPE;
BEGIN
  -- Specific column from table.
  SELECT username
  INTO   l_username
  FROM   all_users
  WHERE  username = 'SYS';
  
  DBMS_OUTPUT.put_line('l_username=' || l_username);
  
  -- Whole record from table.
  SELECT *
  INTO   l_all_users_row
  FROM   all_users
  WHERE  username = 'SYS';

  DBMS_OUTPUT.put_line('l_all_users_row.username=' ||
                        l_all_users_row.username);
  DBMS_OUTPUT.put_line('l_all_users_row.user_id=' ||
                        l_all_users_row.user_id);
  DBMS_OUTPUT.put_line('l_all_users_row.created=' ||
                        l_all_users_row.created);
  
  -- Record that matches cursor definition. 
  OPEN  c_user_data;
  FETCH c_user_data
  INTO  l_all_users_cursor_row;
  CLOSE c_user_data;

  DBMS_OUTPUT.put_line('l_all_users_cursor_row.username=' ||
                        l_all_users_cursor_row.username);
  DBMS_OUTPUT.put_line('l_all_users_cursor_row.created=' ||
                        l_all_users_cursor_row.created);
END;
/

---SQL IN PLSQL

CREATE TABLE sql_test (
  id           NUMBER(10),
  description  VARCHAR2(10)
);

INSERT INTO sql_test (id, description) VALUES (1, 'One');
INSERT INTO sql_test (id, description) VALUES (2, 'Two');
INSERT INTO sql_test (id, description) VALUES (3, 'Three');
COMMIT;


SET SERVEROUTPUT ON
DECLARE
  l_description  VARCHAR2(10);
BEGIN
  SELECT description
  INTO   l_description
  FROM   sql_test
  WHERE  id = 1;
  
  DBMS_OUTPUT.put_line('l_description=' || l_description);
END;
/


---CURSOR

SET SERVEROUTPUT ON
DECLARE
  l_description  VARCHAR2(10);
  
  CURSOR c_data (p_id  IN  NUMBER) IS
    SELECT description
    FROM   sql_test
    WHERE  id = p_id;
BEGIN
  OPEN c_data (p_id => 1);
  FETCH c_data
  INTO  l_description;
  CLOSE c_data;

  DBMS_OUTPUT.put_line('l_description=' || l_description);
END;
/


---CURSOR FOR LOOP

SET SERVEROUTPUT ON
BEGIN
  FOR cur_rec IN (SELECT description
                  FROM   sql_test)
  LOOP
    DBMS_OUTPUT.put_line('cur_rec.description=' || cur_rec.description);
  END LOOP;
END;
/


---IF THEN ELSE

SET SERVEROUTPUT ON
DECLARE
  l_day  VARCHAR2(10);
BEGIN
  l_day := TRIM(TO_CHAR(SYSDATE, 'DAY'));
  
  IF l_day IN ('SATURDAY', 'SUNDAY') THEN
    DBMS_OUTPUT.put_line('It''s the weekend!');
  ELSE
    DBMS_OUTPUT.put_line('It''s not the weekend yet!');
  END IF;
END;
/


SET SERVEROUTPUT ON
DECLARE
  l_day  VARCHAR2(10);
BEGIN
  l_day := TRIM(TO_CHAR(SYSDATE, 'DAY'));
  
  IF l_day = 'SATURDAY' THEN
    DBMS_OUTPUT.put_line('The weekend has just started!');
  ELSIF l_day = 'SUNDAY' THEN
    DBMS_OUTPUT.put_line('The weekend is nearly over!');
  ELSE
    DBMS_OUTPUT.put_line('It''s not the weekend yet!');
  END IF;
END;
/


---CASE

SET SERVEROUTPUT ON
DECLARE
  l_day  VARCHAR2(10);
BEGIN
  l_day := TRIM(TO_CHAR(SYSDATE, 'DAY'));
  
  CASE l_day
    WHEN 'SATURDAY' THEN
      DBMS_OUTPUT.put_line('The weekend has just started!');
    WHEN 'SUNDAY' THEN
      DBMS_OUTPUT.put_line('The weekend is nearly over!');
    ELSE
      DBMS_OUTPUT.put_line('It''s not the weekend yet!');
  END CASE;
END;
/


---PROCEDURES

CREATE OR REPLACE PROCEDURE display_numbers (
  p_lower  IN   NUMBER,
  p_upper  IN   NUMBER)
AS
BEGIN
  FOR i IN p_lower .. p_upper LOOP
    DBMS_OUTPUT.put_line(i);
  END LOOP;
END;
/


SET SERVEROUTPUT ON

EXECUTE display_numbers(2, 6);


--FUNCTION

CREATE OR REPLACE FUNCTION difference (
  p_lower  IN   NUMBER,
  p_upper  IN   NUMBER)
  RETURN NUMBER
AS
BEGIN
  RETURN p_upper - p_lower;
END;
/

VARIABLE l_result NUMBER
BEGIN
  :l_result := difference(2, 6);
END;
/

PRINT l_result

SELECT difference(3, 6) FROM DUAL;



--PACKAGE


CREATE OR REPLACE PACKAGE my_package AS

PROCEDURE display_numbers (
  p_lower  IN   NUMBER,
  p_upper  IN   NUMBER);
  
FUNCTION difference (
  p_lower  IN   NUMBER,
  p_upper  IN   NUMBER)
  RETURN NUMBER;

END;
/

CREATE OR REPLACE PACKAGE BODY my_package AS

PROCEDURE display_numbers (
  p_lower  IN   NUMBER,
  p_upper  IN   NUMBER)
AS
BEGIN
  FOR i IN p_lower .. p_upper LOOP
    DBMS_OUTPUT.put_line(i);
  END LOOP;
END;
  
FUNCTION difference (
  p_lower  IN   NUMBER,
  p_upper  IN   NUMBER)
  RETURN NUMBER
AS
BEGIN
  RETURN p_upper - p_lower;
END;

END;
/


SET SERVEROUTPUT ON
EXECUTE my_package.display_numbers(2, 6);


VARIABLE l_result NUMBER
BEGIN
  :l_result := my_package.difference(2, 6);
  --PRINT l_result;
END;
/

PRINT l_result



---TRIGGERS

-- Create and populate an items table and creat an audit log table.
CREATE TABLE items (
  id           NUMBER(10),
  description  VARCHAR2(50),
  price        NUMBER(10,2),
  CONSTRAINT items_pk PRIMARY KEY (id)
);

CREATE SEQUENCE items_seq;

INSERT INTO items (id, description, price) VALUES (items_seq.NEXTVAL, 'PC', 399.99);

CREATE TABLE items_audit_log (
  id           NUMBER(10),
  item_id      NUMBER(10),
  description  VARCHAR2(50),
  old_price    NUMBER(10,2),
  new_price    NUMBER(10,2),
  log_date     DATE,
  CONSTRAINT items_audit_log_pk PRIMARY KEY (id)
);

CREATE SEQUENCE items_audit_log_seq;



-- Create a trigger to log price changes of items.
CREATE OR REPLACE TRIGGER items_aru_trg
  AFTER UPDATE OF price ON items
  FOR EACH ROW
BEGIN
   INSERT INTO items_audit_log (id, item_id, description, old_price, new_price, log_date)
   VALUES (items_audit_log_seq.NEXTVAL, :new.id, :new.description, :old.price, :new.price, SYSDATE);
END;
/


-- Check the current data in the audit table, should be no rows.
COLUMN description FORMAT A10
SELECT * FROM items_audit_log;


-- Update the price of an item.
UPDATE items
SET    price = 499.99
WHERE  id    = 1;


-- Check the audit table again.
COLUMN description FORMAT A10
SELECT * FROM items_audit_log;


--Error Handling

SET SERVEROUTPUT ON
DECLARE
  l_user_id   all_users.username%TYPE := 999999;
  l_username  all_users.username%TYPE; 
BEGIN
  SELECT username
  INTO   l_username
  FROM   all_users
  WHERE  user_id = l_user_id;

  DBMS_OUTPUT.put_line('l_username=' || l_username);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.put_line('No users have a user_id=' || l_user_id);
END;
/



---USER DEFINED EXCEPTION

SET SERVEROUTPUT ON
DECLARE
  l_user_id   all_users.username%TYPE := 0;
  l_username  all_users.username%TYPE;
  
  ex_forbidden_users  EXCEPTION;
BEGIN
  SELECT username
  INTO   l_username
  FROM   all_users
  WHERE  user_id = l_user_id;
  
  -- Signal an error if the SYS or SYSTEM users are queried.
  IF l_username IN ('SYS', 'SYSTEM') THEN
    RAISE ex_forbidden_users;
  END IF;
  
  DBMS_OUTPUT.put_line('l_username=' || l_username);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.put_line('No users have a user_id=' || l_user_id);
  WHEN ex_forbidden_users THEN
    DBMS_OUTPUT.put_line('Don''t mess with the ' || l_username || ' user, it is forbidden!');
END;
/


---RAISE _APPLICATION_ERROR


SET SERVEROUTPUT ON
DECLARE
  l_user_id   all_users.username%TYPE := 0;
  l_username  all_users.username%TYPE;
BEGIN
  SELECT username
  INTO   l_username
  FROM   all_users
  WHERE  user_id = l_user_id;

  -- Signal an error is the SYS or SYSTEM users are queried.
  IF l_username IN ('SYS', 'SYSTEM') THEN
    RAISE_APPLICATION_ERROR(-20000, 'Don''t mess with the ' || l_username || ' user, it is forbidden!');
  END IF;

  DBMS_OUTPUT.put_line('l_username=' || l_username);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.put_line('No users have a user_id=' || l_user_id);
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line(SQLERRM);
END;
/


--- PRAGMA EXCEPTION_INIT
SET SERVEROUTPUT ON
DECLARE
  l_user_id   all_users.username%TYPE := 0;
  l_username  all_users.username%TYPE;

  ex_forbidden_users  EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_forbidden_users, -20000);
BEGIN
  SELECT username
  INTO   l_username
  FROM   all_users
  WHERE  user_id = l_user_id;

  -- Signal an error is the SYS or SYSTEM users are queried.
  IF l_username IN ('SYS', 'SYSTEM') THEN
    RAISE_APPLICATION_ERROR(-20000, 'Don''t mess with the ' || l_username || ' user, it is forbidden!');
  END IF;

  DBMS_OUTPUT.put_line('l_username=' || l_username);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.put_line('No users have a user_id=' || l_user_id);
  WHEN ex_forbidden_users THEN
    DBMS_OUTPUT.put_line(SQLERRM);
END;
/



--COLLECTIONS
/*
In Oracle PL/SQL, collections are composite data types that allow you to store multiple elements of the same type within a single variable.
They are analogous to arrays or lists in other programming languages. Oracle provides three main types of collections:
*/

--Index-By Tables (Associative Arrays)
/*
The first type of collection is known as index-by tables. 
These behave in the same way as arrays except that have no upper bounds, allowing them to constantly extend. As the name implies,
the collection is indexed using BINARY_INTEGER values, which do not need to be consecutive.
The collection is extended by assigning values to an element using an index value that does not currently exist.
*/

SET SERVEROUTPUT ON
DECLARE
  -- Declare an associative array type
  TYPE employee_salary IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  -- Declare a variable of this type
  emp_salaries employee_salary;
BEGIN
  -- Insert data into the associative array
  emp_salaries(101) := 50000;
  emp_salaries(102) := 60000;
  emp_salaries(103) := 55000;

  -- Access and display the data

  DBMS_OUTPUT.PUT_LINE('Salary of employee 101: ' || emp_salaries(101));
  DBMS_OUTPUT.PUT_LINE('Salary of employee 102: ' || emp_salaries(102));
  DBMS_OUTPUT.PUT_LINE('Salary of employee 103: ' || emp_salaries(103));
END;

SET SERVEROUTPUT ON

DECLARE
  -- Declare an associative array type
  TYPE product_price IS TABLE OF NUMBER INDEX BY VARCHAR2(50);
  -- Declare a variable of this type
  product_prices product_price;
BEGIN
  -- Insert data into the associative array
  product_prices('Laptop') := 1200;
  product_prices('Smartphone') := 800;
  product_prices('Tablet') := 400;

  -- Access and display the data
  DBMS_OUTPUT.PUT_LINE('Price of Laptop: ' || product_prices('Laptop'));
  DBMS_OUTPUT.PUT_LINE('Price of Smartphone: ' || product_prices('Smartphone'));
  DBMS_OUTPUT.PUT_LINE('Price of Tablet: ' || product_prices('Tablet'));
END;


/*
Nested Table Collections
Nested table collections are an extension of the index-by tables. 
The main difference between the two is that nested tables can be stored in a database column but index-by tables cannot.
In addition some DML operations are possible on nested tables when they are stored in the database.
During creation the collection must be dense, having consecutive subscripts for the elements. 
Once created elements can be deleted using the DELETE method to make the collection sparse.
The NEXT method overcomes the problems of traversing sparse collections.
*/


SET SERVEROUTPUT ON;
DECLARE
   TYPE First_nested_table IS TABLE OF NUMBER;
   example_one First_nested_table;
BEGIN
   -- Initialize the nested table
   example_one := First_nested_table(1, 2, 3, 4, 5);
   FOR i IN example_one.FIRST .. example_one.LAST LOOP
      DBMS_OUTPUT.PUT_LINE('Element ' || i || ': ' || example_one(i));
   END LOOP;
   -- Free up memory
   example_one := NULL;
END;


--Varray Collections
/*
A VARRAY is similar to a nested table except you must specifiy an upper bound in the declaration. 
Like nested tables they can be stored in the database, but unlike nested tables individual elements cannot be deleted so they remain dense.
*/


SET SERVEROUTPUT ON SIZE 1000000
DECLARE
  TYPE table_type IS VARRAY(5) OF NUMBER(10);
  v_tab  table_type;
  v_idx  NUMBER;
BEGIN
  -- Initialise the collection with two values.
  v_tab := table_type(1, 2);

  -- Extend the collection with extra values.
  << load_loop >>
  FOR i IN 3 .. 5 LOOP
    v_tab.extend;
    v_tab(v_tab.last) := i;
  END LOOP load_loop;
  
  -- Can't delete from a VARRAY.
  -- v_tab.DELETE(3);

  -- Traverse collection
  v_idx := v_tab.FIRST;
  << display_loop >>
  WHILE v_idx IS NOT NULL LOOP
    DBMS_OUTPUT.PUT_LINE('The number ' || v_tab(v_idx));
    v_idx := v_tab.NEXT(v_idx);
  END LOOP display_loop;
END;
/


---BULK COLLECT
/*
BULK COLLECT
Bulk binds can improve the performance when loading collections from a queries. 
The BULK COLLECT INTO construct binds the output of the query to the collection. To test this create the following table.
*/

CREATE TABLE bulk_collect_test AS
SELECT owner,
       object_name,
       object_id
FROM   all_objects;

---The following code compares the time taken to populate a collection manually and using a bulk bind.

SET SERVEROUTPUT ON
DECLARE
  TYPE t_bulk_collect_test_tab IS TABLE OF bulk_collect_test%ROWTYPE;

  l_tab    t_bulk_collect_test_tab := t_bulk_collect_test_tab();
  l_start  NUMBER;
BEGIN
  -- Time a regular population.
  l_start := DBMS_UTILITY.get_time;

  FOR cur_rec IN (SELECT *
                  FROM   bulk_collect_test)
  LOOP
    l_tab.extend;
    l_tab(l_tab.last) := cur_rec;
  END LOOP;

  DBMS_OUTPUT.put_line('Regular (' || l_tab.count || ' rows): ' || 
                       (DBMS_UTILITY.get_time - l_start));
  
  -- Time bulk population.  
  l_start := DBMS_UTILITY.get_time;

  SELECT *
  BULK COLLECT INTO l_tab
  FROM   bulk_collect_test;

  DBMS_OUTPUT.put_line('Bulk    (' || l_tab.count || ' rows): ' || 
                       (DBMS_UTILITY.get_time - l_start));
END;
/



--LIMIT

/*
Remember that collections are held in memory, so doing a bulk collect from a large query could cause a considerable performance problem. 
In actual fact you would rarely do a straight bulk collect in this manner.
Instead you would limit the rows returned using the LIMIT clause and move through the data processing smaller chunks.
This gives you the benefits of bulk binds, without hogging all the server memory. The following code shows how to chunk through the data in a large table.
*/

SET SERVEROUTPUT ON
DECLARE
  TYPE t_bulk_collect_test_tab IS TABLE OF bulk_collect_test%ROWTYPE;

  l_tab t_bulk_collect_test_tab;

  CURSOR c_data IS
    SELECT *
    FROM bulk_collect_test;
BEGIN
  OPEN c_data;
  LOOP
    FETCH c_data
    BULK COLLECT INTO l_tab LIMIT 10000;
    EXIT WHEN l_tab.count = 0;

    -- Process contents of collection here.
    DBMS_OUTPUT.put_line(l_tab.count || ' rows');
  END LOOP;
  CLOSE c_data;
END;
/


---FORALL

/*
The FORALL syntax allows us to bind the contents of a collection to a single DML statement, allowing the DML to be run for each row in the collection without requiring a context switch each time. 
To test bulk binds using records we first create a test table.
*/

CREATE TABLE forall_test (
  id           NUMBER(10),
  code         VARCHAR2(10),
  description  VARCHAR2(50));

ALTER TABLE forall_test ADD (
  CONSTRAINT forall_test_pk PRIMARY KEY (id));

ALTER TABLE forall_test ADD (
  CONSTRAINT forall_test_uk UNIQUE (code));
  
  SET SERVEROUTPUT ON
DECLARE
  TYPE t_forall_test_tab IS TABLE OF forall_test%ROWTYPE;

  l_tab    t_forall_test_tab := t_forall_test_tab();
  l_start  NUMBER;
  l_size   NUMBER            := 10000;
BEGIN
  -- Populate collection.
  FOR i IN 1 .. l_size LOOP
    l_tab.extend;

    l_tab(l_tab.last).id          := i;
    l_tab(l_tab.last).code        := TO_CHAR(i);
    l_tab(l_tab.last).description := 'Description: ' || TO_CHAR(i);
  END LOOP;

  EXECUTE IMMEDIATE 'TRUNCATE TABLE forall_test';

  -- Time regular inserts.
  l_start := DBMS_UTILITY.get_time;

  FOR i IN l_tab.first .. l_tab.last LOOP
    INSERT INTO forall_test (id, code, description)
    VALUES (l_tab(i).id, l_tab(i).code, l_tab(i).description);
  END LOOP;

  DBMS_OUTPUT.put_line('Normal Inserts: ' || 
                       (DBMS_UTILITY.get_time - l_start));
  
  EXECUTE IMMEDIATE 'TRUNCATE TABLE forall_test';

  -- Time bulk inserts.  
  l_start := DBMS_UTILITY.get_time;

  FORALL i IN l_tab.first .. l_tab.last
    INSERT INTO forall_test VALUES l_tab(i);

  DBMS_OUTPUT.put_line('Bulk Inserts  : ' || 
                       (DBMS_UTILITY.get_time - l_start));

  COMMIT;
END;
/


SELECT * FROM forall_test;



---JSON

select * from emp_1;

/*
Generating JSON Data
There are many functions that you can generate json data. I mentioned the most usable ones. 
You can combine them in order to create complex json objects. Basically, the intended usage of each one can be understandable from the examples below.
*/

---JSON_OBJECT
--It Creates a JSON object from the specified key-value pairs.

SELECT
    JSON_OBJECT(
        KEY 'name' VALUE e.ename,
        KEY 'job' VALUE e.job,
        KEY 'hiredate' VALUE e.hiredate
    ) AS json_data
FROM emp e
WHERE e.deptno = 30;

---JSON_OBJECTAGG
--aggregate into sigle json doc

SELECT
    JSON_OBJECTAGG(
         to_char(e.empno) VALUE e.ename 
         ) AS json_data
FROM emp e
WHERE e.deptno = 30
ORDER BY e.empno;


--JSON_ARRAY
SELECT
    JSON_ARRAY(
        e.empno,
        JSON_OBJECT(
            KEY 'name' VALUE e.ename,
            KEY 'job' VALUE e.job,
            KEY 'hiredate' VALUE e.hiredate         
        )
    ) AS json_data
FROM emp e
ORDER BY e.empno;

--JSON_ARRAYAGG

--Unlike JSON_ARRAY, JSON_ARRAYAGG function combines the result set into a single JSON array. The query result in SQL*Plus is formatted to look properly.

SELECT
        JSON_ARRAYAGG(
           JSON_OBJECT(
                KEY 'name' VALUE e.ename,
               KEY 'job' VALUE e.job,
                KEY 'hiredate' VALUE e.hiredate
            )
            ORDER BY e.empno
       ) AS json_data
   FROM emp e
   order by e.empno;
   
   
   SELECT
        JSON_ARRAYAGG(e.ename) AS json_data
  FROM emp e
  order by e.empno;
  
--Converting row to JSON
---You can use the wildcard “*” as input to the JSON_OBJECT function in order to convert table rows to JSON without key:value mapping.

  SELECT JSON_OBJECT(*) FROM emp;
  
  SELECT
    JSON_ARRAYAGG (  
        JSON_OBJECT(*) RETURNING CLOB   
    ) AS JSON_DOC  
FROM emp;

---JSON_DATAGUIDE
--As the name suggests, JSON_DATAGUIDE function returns the metadata of the given JSON input.
SELECT
    JSON_SERIALIZE(
            JSON_DATAGUIDE(JSON_DATA) 
            PRETTY)
FROM (
    SELECT
        JSON_ARRAYAGG(JSON_OBJECT(*)) JSON_DATA
    FROM EMP
);


---Parsing JSON Data

CREATE TABLE T_JSON_DOC
(
    ID RAW(16) PRIMARY KEY,
    DATA CLOB,
    CONSTRAINT JSON_DOC_CHK CHECK (DATA IS JSON)
);


select * from T_JSON_DOC;

SELECT t.data.brand FROM T_JSON_DOC t;


SELECT
    t.*
FROM T_JSON_DOC,
     JSON_TABLE(data, '$'
          COLUMNS (brand                VARCHAR2(50 CHAR) PATH '$.brand',
                   model                VARCHAR2(50 CHAR) PATH '$.model',
                   year                 NUMBER            PATH '$.year',
                   country              VARCHAR2(50 CHAR) PATH '$.country',
                   price                VARCHAR2(20 CHAR) PATH '$.price',
                   number_of_cylinders  VARCHAR2(20 CHAR) PATH '$.engine.number_of_cylinders',
                   fuel_system          VARCHAR2(20 CHAR) PATH '$.engine.fuel_system'
                  )
              ) t;
              
              
 --With the version of Oracle 18c, we can use the path expressions instead of dot notation as shown below.

SELECT
    t.*
FROM T_JSON_DOC,
     JSON_TABLE(data, '$'
          COLUMNS (brand                VARCHAR2(50 CHAR) PATH brand,
                   model                VARCHAR2(50 CHAR) PATH model,
                   year                 NUMBER            PATH year,
                   country              VARCHAR2(50 CHAR) PATH country,
                   price                VARCHAR2(20 CHAR) PATH price,
                   number_of_cylinders  VARCHAR2(20 CHAR) PATH engine.number_of_cylinders,
                   fuel_system          VARCHAR2(20 CHAR) PATH engine.fuel_system
                  )
              ) t;        
              
              
--- Moreover, you don’t need any function to parse the JSON data. With using dot notation, you can easily use it as a predicate as shown below.         
 SELECT
        t.data.brand,
        t.data.model,
        t.data.year,
        t.data.country,
        t.data.price
    FROM T_JSON_DOC t
   -- where t.data.brand = 'Porche';