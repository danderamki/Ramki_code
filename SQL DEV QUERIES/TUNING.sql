---Top 10 Oracle SQL & PL/SQL tuning tips, with a short one‑line explanation per example.

--1. Analyze Execution Plans


--Example: generate a plan and display it with actual statistics.

--SQL:

EXPLAIN PLAN FOR  SELECT e.emp_id, e.salary  FROM employees e  WHERE e.department_id = 10;

--Display:

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY());

--Or show actual execution plan for a cursor:

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));

--One‑line: Use DBMS_XPLAN to find expensive operators (full scans, sorts, nested loops).

----2. Leverage Indexes Wisely

---B‑tree index (high cardinality):
CREATE INDEX emp_empid_idx ON employees(emp_id);
---Composite index (multiple predicates):
CREATE INDEX emp_dept_hiredate_idx ON employees(department_id, hire_date);
---Function‑based index (preserve index usage when using functions):
CREATE INDEX emp_name_upper_idx ON employees(UPPER(last_name));

--Query that can use it:
SELECT * FROM employees WHERE UPPER(last_name) = 'SMITH';
---Bitmap index (low cardinality, read‑heavy DW):
CREATE BITMAP INDEX emp_status_bmidx ON employees(status);

---One‑line: Pick index type by cardinality and query patterns; use function‑based indexes instead of wrapping columns.

---3. Use Bind Variables

--Simple parameterized query (client/OCI/SQL*Plus):

VARIABLE b_emp_id NUMBER  
EXEC :b_emp_id := 101;  
SELECT * FROM employees WHERE emp_id = :b_emp_id;

--PL/SQL using EXECUTE IMMEDIATE with bind:

DECLARE   
v_dept NUMBER := 10;  
v_count NUMBER;  
BEGIN   
EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM employees WHERE manager_id = :1'  INTO v_count USING v_dept;   
DBMS_OUTPUT.PUT_LINE('Count=' || v_count);
END;

---One‑line: Bind variables reduce hard parsing and improve shared SQL cache reuse.

---4. Keep Statistics Current

---Gather table stats (recommended options):
/*
"The DBMS_STATS.GATHER_TABLE_STATS procedure collects statistics about a table and its indexes so the cost-based optimizer can make efficient decisions.
It’s essential for performance tuning, especially after large data changes.
Parameters like estimate_percent, method_opt, and cascade control sampling, histograms, and index stats."
*/

BEGIN  
DBMS_STATS.GATHER_TABLE_STATS( ownname => 'MYREYA', tabname => 'EMPLOYEES', estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE, cascade => TRUE); 
END;

---Create histogram (for skewed column):
BEGIN  
DBMS_STATS.GATHER_TABLE_STATS( ownname => 'HR', tabname => 'EMPLOYEES', method_opt => 'FOR (SALARY) SIZE 254');  
END;

--One‑line: Fresh stats and histograms help the optimizer choose the right plan.

---5. Optimize Joins & Subqueries

---IN → EXISTS rewrite (prefer EXISTS for correlated checks):

---IN version:

SELECT e.*  FROM employees e  
WHERE e.department_id IN (SELECT d.department_id FROM departments d WHERE d.location = 'NY');

---EXISTS version:

SELECT e.*  FROM employees e  
WHERE EXISTS 
(SELECT 1 FROM departments d WHERE d.department_id = e.department_id AND d.location = 'NY');

---Push predicates down and join on indexed keys:
SELECT e.emp_id, d.department_name 
FROM employees e 
JOIN departments d 
ON e.department_id = d.department_id 
WHERE d.location = 'NY'
AND e.hire_date >= DATE '2022-01-01';

---One‑line: Rewriting subqueries and pushing predicates reduces rows early, improving joins.

--6. Partition Large Tables
--Apply RANGE/LIST/HASH (or composite) partitioning to limit I/O to relevant partitions for large tables or time‑series data.
--Create a range‑partitioned table by date:

CREATE TABLE orders (    order_id NUMBER,    customer_id NUMBER,    order_date DATE,    total NUMBER  )
PARTITION BY RANGE (order_date) (    PARTITION p2023 VALUES LESS THAN (DATE '2024-01-01'), 
PARTITION p2024 VALUES LESS THAN (DATE '2025-01-01'),   
PARTITION pmax VALUES LESS THAN (MAXVALUE)  );

--Query benefiting from pruning:
SELECT COUNT(*) FROM orders WHERE order_date BETWEEN DATE '2024-01-01' AND DATE '2024-03-31';

---One‑line: Partitioning narrows I/O to relevant partitions and speeds maintenance.

---7. Bulk Operations in PL/SQL

---BULK COLLECT + FORALL example (batch update):

DECLARE   
TYPE t_empid IS TABLE OF employees.emp_id%TYPE; 
l_empids t_empid; 
BEGIN
SELECT emp_id BULK COLLECT INTO l_empids FROM employees
WHERE department_id = 10;   FORALL i IN 1..l_empids.COUNT
UPDATE employees 
SET salary = salary * 1.05 
WHERE emp_id = l_empids(i);
COMMIT; 
END;

---One‑line: BULK COLLECT and FORALL minimize context switches and speed batch DML.

---8. Minimize Context Switching

---Row‑by‑row (bad):
BEGIN   
FOR r IN (SELECT emp_id FROM employees WHERE department_id = 20) 
LOOP
UPDATE employees SET salary = salary * 1.02 WHERE emp_id = r.emp_id; 
END LOOP;  
COMMIT;
END;

---Set‑based (good):
UPDATE employees SET salary = salary * 1.02 WHERE department_id = 20;

---One‑line: Set‑based SQL replaces slow row‑by‑row loops and is almost always faster.

---9. Monitor & Diagnose

---Enable SQL Trace for session and create tkprof report (run in OS/SQL*Plus environment):
--Enable:
ALTER SESSION SET SQL_TRACE = TRUE;
or using DBMS_MONITOR:
EXEC DBMS_MONITOR.SESSION_TRACE_ENABLE(session_id => SYS_CONTEXT('USERENV','SID'));

---After reproducing workload, find tracefile and run TKPROF:
tkprof C:\oracle\diag\rdbms\...\<sid>_ora_12345.trc output.prf EXPLAIN=SYS/ SYS FORMAT=ALL
--Generate AWR report (SQL*Plus):
@?/rdbms/admin/awrrpt.sql

---One‑line: Trace + TKPROF and AWR identify top consumers and wait events.

---10. Apply Optimizer Hints (Carefully)

---Example hint forcing index use:
SELECT /*+ INDEX(e emp_empid_idx) */ e.emp_id, e.last_name 
FROM employees e  
WHERE e.emp_id = 101;
---Use LEADING, USE_NL to influence join order/method:
SELECT /*+ LEADING(e d) USE_NL(d) */ ...  FROM employees e JOIN departments d ON ...;

--Prefer SQL Plan Baselines instead of permanent hints:
-- Capture plan baseline (example) 
DECLARE    c NUMBER; 
BEGIN    c := DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE(       schema_name => 'HR',       sql_id => 'abcd1234');
END;

---One‑line: Hints can fix paths but should be last resort; prefer statistics and plan management.

"My tuning approach starts with analyzing the execution plan using  and . I check for costly operations like full table scans and optimize them with proper indexing. 
For high‑cardinality columns, I use B‑tree indexes, and for low‑cardinality columns, bitmap indexes.
I also make sure statistics are up to date using , including histograms for skewed data distributions, so the optimizer can make the best decisions."
"I always use bind variables to reduce hard parsing and improve shared pool efficiency. 
For large tables, I apply partitioning so queries only scan relevant partitions. 
In PL/SQL, I avoid row‑by‑row processing by using bulk operations —  for fetching and  for batch DML — which minimizes context switches between SQL and PL/SQL engines."
"For deeper analysis, I rely on SQL Trace and TKPROF to identify bottlenecks, and I use AWR reports or Enterprise Manager for system‑wide monitoring. 
Optimizer hints are my last resort when I need to influence execution plans directly. 
Overall, my philosophy is to write efficient SQL first, then use PL/SQL features like bulk operations and collections to handle large volumes of data effectively.


---One‑line structure to deliver:
“I start by analyzing the execution plan, then check indexing and statistics. I use bind variables to reduce parsing,
partition large tables where appropriate, and apply bulk operations in PL/SQL to minimize context switches. 
For deeper analysis I use SQL Trace/TKPROF and AWR reports; optimizer hints are a last resort.”

---Quick talking points: start → explain plan; next → indexing & stats; then → set/batch operations; finish → diagnostics & conservative hints.
