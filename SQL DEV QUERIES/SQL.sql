/*SELF JOIN
To retrieve the employee and manager data from the employees table, you use a self join as shown in the following statement:
*/

SELECT
  (e.first_name || '  ' || e.last_name) employee,
  (m.first_name || '  ' || m.last_name) manager,
  e.job_title
FROM
  employees e
  LEFT JOIN employees m ON m.employee_id = e.manager_id
ORDER BY
  manager;



/*
What are common table expressions (CTEs) in SQL?
A CTE is a temporary result set defined within a query. It improves query readability and can be referenced multiple times.

Example:
*/

WITH TopSalaries AS (  
    SELECT FIRST_NAME, LAST_NAME  
    FROM Employees  
   -- WHERE Salary > 50000  
)  
SELECT * FROM TopSalaries WHERE FIRST_NAME LIKE 'A%';

--WINDOW FUNCTIONS

SELECT * FROM PRODUCTS;

SELECT PRODUCT_NAME, LIST_PRICE, 
    SUM(LIST_PRICE) OVER (ORDER BY LIST_PRICE) AS RUNNINGTOTAL  
FROM PRODUCTS;

/*
NVL(): Replaces a NULL value with a specified replacement value. Example: NVL(Salary, 0) will replace NULL with 0.
NVL2(): Evaluates two arguments:
If the first argument is NOT NULL, returns the second argument.
If the first argument is NULL, returns the third argument.
Example:
*/

SELECT NVL(EMPLOYEE_ID, 0) AS EMP FROM Employees;  -- Replaces NULL with 0

SELECT NVL2(EMPLOYEE_ID, EMPLOYEE_ID, 0) AS EMP FROM Employees;  -- If Salary is NULL, returns 0; otherwise, returns Salary.



/*
RANK(): Assigns a rank to each row, with gaps if there are ties.
DENSE_RANK(): Assigns consecutive ranks without any gaps.
*/

SELECT
    EMPNO,
    DEPTNO,
    SAL,
    RANK()
    OVER(PARTITION BY DEPTNO
         ORDER BY
             SAL
    ) AS MYRANK,
      DENSE_RANK()
    OVER(PARTITION BY DEPTNO
         ORDER BY
             SAL
    ) AS MY_DENSE_RANK
FROM
    EMP;
    
    SELECT * FROM EMP;

SELECT
    EMPNO,
    DEPTNO,
    SAL,
    DENSE_RANK()
    OVER(PARTITION BY DEPTNO
         ORDER BY
             SAL
    ) AS MYRANK
FROM
    EMP;
    


/*
ROW_NUMBER(): Assigns a unique number to each row regardless of ties.
RANK(): Assigns the same number to tied rows and leaves gaps for subsequent ranks.
*/

SELECT
    EMPNO,
    DEPTNO,
    SAL,
    ROW_NUMBER()
    OVER(PARTITION BY DEPTNO
         ORDER BY
             SAL
    ) AS MYRANK
FROM
    EMP;
    
 /*
 LAG
The LAG function is used to access data from a previous row. 
The following query returns the salary from the previous row to calculate the difference between the salary of the current row and that of the previous row.
Notice that the ORDER BY of the LAG function is used to order the data by salary.
*/


SELECT EMPNO,
       ENAME,
       JOB,
       SAL,
       LAG(SAL, 1, 0) OVER (ORDER BY SAL) AS SAL_PREV,
       SAL - LAG(SAL, 1, 0) OVER (ORDER BY SAL) AS SAL_DIFF
FROM   EMP;


---If the LAG would span a partition boundary, the default value is returned. 
-- In the following example we partition by department, so the SAL_PREV column has a default value of "0" for the first row in each department.
select DEPTNO,
       EMPNO,
       ENAME,
       job,
       SAL,
       lag(SAL, 1, 0) over (partition by DEPTNO order by SAL) as SAL_PREV
from   EMP;

/*
LEAD:

The LEAD function is used to return data from rows further down the result set.
The following query returns the salary from the next row to calculate the difference between the salary of the current row and the following row.
*/

SELECT EMPNO,
       ENAME,
       JOB,
       SAL,
       LEAD(SAL, 1, 0) OVER (ORDER BY SAL) AS SAL_NEXT,
       LEAD(SAL, 1, 0) OVER (ORDER BY SAL) - SAL AS SAL_DIFF
FROM   EMP;

---If the LEAD would span a partition boundary, the default value is returned. 
--In the following example we partition by department, so the SAL_NEXT column has a default value of "0" for the last row in each department.

select DEPTNO,
       EMPNO,
       ENAME,
       job,
       SAL,
       lead(SAL, 1, 0) over (partition by DEPTNO order by SAL) as SAL_NEXT
from   EMP;

---Top-N Queries

---Write a query to find the second-highest salary of an employee in a table.

SELECT MAX(Sal) AS SecondHighestSalary
FROM Emp
WHERE Sal < (SELECT MAX(Sal) FROM Emp);

--- Write a query to retrieve employees who earn more than the average salary.

SELECT * 
FROM Emp
WHERE Sal > (SELECT AVG(Sal) FROM Emp);

---Write a query to fetch the duplicate values from a column in a table.

SELECT ENAME, COUNT(*)
FROM EMP
GROUP BY ENAME
HAVING COUNT(*) > 1;

 ---Write a query to delete duplicate rows in a table without using the ROWID keyword.
 
DELETE FROM EMP 
WHERE EmployeeID NOT IN (
   SELECT MIN(EmployeeID)
   FROM Employee
   GROUP BY Column1, Column2
);


DELETE FROM emp_1
WHERE ROWID IN (
  SELECT rid FROM (
    SELECT ROWID AS rid,
           ROW_NUMBER() OVER (PARTITION BY empno ORDER BY ROWID) AS rn
    FROM emp_1
  ) WHERE rn > 1
);

WITH DuplicateRows AS (
    SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY column1, column2 ORDER BY (SELECT NULL)) as rn  -- Replace column1, column2 with the actual columns to check for duplicates
    FROM
        your_table
)
DELETE FROM DuplicateRows WHERE rn > 1;

---Write a query to fetch the 3rd and 4th highest salaries.

WITH SalaryRank AS (
    SELECT SAL, DENSE_RANK() OVER (ORDER BY SAL DESC) AS Rank
    FROM EMP
)
SELECT SAL
FROM SalaryRank
WHERE Rank IN (3, 4);

---Write a query to fetch top 3 earning employees.

SELECT ENAME, SAL
FROM (
  SELECT ENAME, SAL,
         DENSE_RANK() OVER (ORDER BY SAL DESC) as salary_rank
  FROM EMP
) ranked_employees
WHERE salary_rank <= 3;

--- ----Oracle 12c or later

SELECT ENAME, SAL
FROM EMP
ORDER BY SAL DESC
FETCH FIRST 3 ROWS ONLY;


--- Write a query to check if a table contains any records.
SELECT CASE 
       WHEN EXISTS (SELECT * FROM EMP) THEN 'Has Records'
       ELSE 'No Records'
       END AS Status;


---Write a query to find employees whose salaries are higher than their managers.

SELECT e.EmployeeID, e.Salary
FROM Employee e
JOIN Employee m ON e.ManagerID = m.EmployeeID
WHERE e.Salary > m.Salary;

---Write a query to fetch alternating rows from a table.

SELECT *
FROM (SELECT rownum, ENAME, EMPNO FROM EMP A) -- Replace Employee with your table name and ID, Name with desired columns
WHERE MOD(rownum, 2) = 0; -- Filter for rows where the remainder of division by 2 is 0

---Write a query to find departments with the highest average salary.

WITH dept_avg AS (
  SELECT deptno, AVG(sal) AS avg_sal
  FROM emp
  GROUP BY deptno
)
SELECT deptno, avg_sal
FROM (
  SELECT deptno, avg_sal,
         DENSE_RANK() OVER (ORDER BY avg_sal DESC) AS rnk
  FROM dept_avg
)
WHERE rnk = 1;

---Oracle 12c or above

WITH dept_avg AS (
  SELECT deptno, AVG(sal) AS avg_sal
  FROM emp
  GROUP BY deptno
)
SELECT deptno, avg_sal
FROM dept_avg
ORDER BY avg_sal DESC
FETCH FIRST 1 ROWS WITH TIES
;


--- Write a query to fetch the nth record from a table.
WITH OrderedEmployees AS (
    SELECT ENAME,SAL,
           ROW_NUMBER() OVER (ORDER BY SAL DESC) AS OrderedRowNum
    FROM EMP
)
SELECT *
FROM OrderedEmployees
WHERE OrderedRowNum = 1;


SELECT * FROM  EMP ;

/*
 What are the trade-offs of using indexes in SQL databases?
 
Advantages:

Faster query performance, especially for SELECT queries with WHERE clauses, JOIN conditions, or ORDER BY clauses.
Improved sorting and filtering efficiency.

Disadvantages:

Increased storage space for the index structures.
Additional overhead for write operations (INSERT, UPDATE, DELETE), as indexes must be updated whenever the underlying data changes.
Potentially slower bulk data loads or batch inserts due to the need to maintain index integrity.
In short, indexes make read operations faster but can slow down write operations and increase storage requirements.
*/

/*
Creation of Global Temporary Tables
The data in a global temporary table is private, such that data inserted by a session can only be accessed by that session. 
The session-specific rows in a global temporary table can be preserved for the whole session, or just for the current transaction.

The ON COMMIT DELETE ROWS clause indicates the data should be deleted at the end of the transaction, or the end of the session.
In contrast, the ON COMMIT PRESERVE ROWS clause indicates that rows should persist beyond the end of the transaction. They will only be removed at the end of the session.
*/

CREATE GLOBAL TEMPORARY TABLE my_gt_table (
  ID           NUMBER,
  DESCRIPTION  VARCHAR2(20)
)
ON COMMIT DELETE ROWS;

-- Insert, but don't commit, then check contents of GTT.
INSERT INTO my_gt_table VALUES (1, 'ONE');

SELECT COUNT(*) FROM my_gt_table;

COMMIT;

--ON COMMIT PRESERVE ROWS

CREATE GLOBAL TEMPORARY TABLE GT_TABLE (
  id           NUMBER,
  description  VARCHAR2(20)
)
ON COMMIT PRESERVE ROWS;

-- Insert and commit, then check contents of GTT.
INSERT INTO GT_TABLE VALUES (1, 'ONE');
COMMIT;

SELECT COUNT(*) FROM GT_TABLE;

/*
What is a materialized view, and how does it differ from a standard view?

Standard View:
A virtual table defined by a query.
Does not store data; the underlying query is executed each time the view is referenced.
A standard view shows real-time data.

Materialized View:
A physical table that stores the result of the query.
Data is precomputed and stored, making reads faster.
Requires periodic refreshes to keep data up to date.
materialized view is used to store aggregated sales data, updated nightly, for fast reporting.

-- Normal
CREATE MATERIALIZED VIEW view-name
BUILD [IMMEDIATE | DEFERRED]
REFRESH [FAST | COMPLETE | FORCE ]
ON [COMMIT | DEMAND ]
[[ENABLE | DISABLE] QUERY REWRITE]
AS
SELECT ...;

-- Pre-Built
CREATE MATERIALIZED VIEW view-name
ON PREBUILT TABLE
REFRESH [FAST | COMPLETE | FORCE ]
ON [COMMIT | DEMAND ]
[[ENABLE | DISABLE] QUERY REWRITE]
AS
SELECT ...;
The BUILD clause options are shown below.

IMMEDIATE : The materialized view is populated immediately.
DEFERRED : The materialized view is populated on the first requested refresh.
The following refresh types are available.

FAST : A fast refresh is attempted. If materialized view logs are not present against the source tables in advance, the creation fails.
COMPLETE : The table segment supporting the materialized view is truncated and repopulated completely using the associated query.
FORCE : A fast refresh is attempted. If one is not possible a complete refresh is performed.
A refresh can be triggered in one of two ways.

ON COMMIT : The refresh is triggered by a committed data change in one of the dependent tables.
ON DEMAND : The refresh is initiated by a manual request or a scheduled task.
The QUERY REWRITE clause tells the optimizer if the materialized view should be consider for query rewrite operations. An example of the query rewrite functionality is shown below.

The ON PREBUILT TABLE clause tells the database to use an existing table segment, which must have the same name as the materialized view and support the same column structure as the query.
*/

select * from dba_users;

select * from all_users;

SELECT * FROM user_users;

SELECT * FROM all_users
ORDER BY created;

select username from all_users;

---CREATE MV
CREATE MATERIALIZED VIEW emp_mv
BUILD IMMEDIATE 
REFRESH FORCE
ON DEMAND
AS
SELECT * FROM emp;


--gather stats after building the materialized view.
BEGIN
  DBMS_STATS.gather_table_stats(
    ownname => 'SYS',
    tabname => 'EMP_MV');
END;
/

---Create Materialized View Logs
/*
Since a complete refresh involves truncating the materialized view segment and re-populating it using the related query,
it can be quite time consuming and involve a considerable amount of network traffic when performed against a remote table.
To reduce the replication costs, materialized view logs can be created to capture all changes to the base table since the last refresh.
This information allows a fast refresh, which only needs to apply the changes rather than a complete refresh of the materialized view.

To take advantage of the of the fast refresh, connect to the master instance and create the materialized view log.
*/


--Create Materialized View Logs

CREATE MATERIALIZED VIEW LOG ON emp
TABLESPACE users
WITH PRIMARY KEY
INCLUDING NEW VALUES;


---Refresh Materialized Views
/*
If a materialized view is configured to refresh on commit, you should never need to manually refresh it, unless a rebuild is necessary.
Remember, refreshing on commit is a very intensive operation for volatile base tables. It makes sense to use fast refreshes where possible.

For on demand refreshes, you can choose to manually refresh the materialized view or refresh it as part of a refresh group.

The following code creates a refresh group defined to refresh every minute and assigns a materialized view to it.
*/

BEGIN
   DBMS_REFRESH.make(
     name                 => 'SCOTT.MINUTE_REFRESH',
     list                 => '',
     next_date            => SYSDATE,
     interval             => '/*1:Mins*/ SYSDATE + 1/(60*24)',
     implicit_destroy     => FALSE,
     lax                  => FALSE,
     job                  => 0,
     rollback_seg         => NULL,
     push_deferred_rpc    => TRUE,
     refresh_after_errors => TRUE,
     purge_option         => NULL,
     parallelism          => NULL,
     heap_size            => NULL);
END;
/

BEGIN
   DBMS_REFRESH.add(
     name => 'SCOTT.MINUTE_REFRESH',
     list => 'SCOTT.EMP_MV',
     lax  => TRUE);
END;
/

---TABLE PARTITIONING
/*
Table partition :
There are so many aspects which are important in improving the performance of SQL. Partition allows tables, indexes and index organized tables to be subdivided into smaller pieces. Table partition is used to reduce the cost and improving performance of the application. There are some partition mechanisms using which one can divide a table into smaller pieces. Partitions can be used in so many application where we need to improve the performance. Each partition has its own name and it has own memory storage. partition allows table,index or index organized tables to be subdivided in to smaller pieces and each piece of table,index or index organized table is called as Partition
What is mean by Table Partition :
Following are Advantages of Partition:
1.Increase Performance
2.Increases availability
3.Enable storage cost optimization
4.Enables Simpler management
“We can not partition a table with Long and long raw datatype…”
When to partition the table?
1.Table should be greater than 2 GB
2.Tables which contains historical data in which new data will be added in to newest partition. The real life example of this is historical table which contains updatable data for one year other data is read only.
3.When contents of the table needs to be distributed in different storage devices.
4.When table performance is weak and we need to improve performance of application. Each row in partitioned table is unambiguously assigned to single partition table. The Partitioning key is comprised of one or more columns that determine the partition where each row will be stored.
Types Of Table partitioning
There are following types of Table partition:
1.Range Partition
2.List Partition
3.Hash Partition
*/

 ---Range Partition:  DATE OR SALARY 
 
Create table Employee_1(emp_no number(2),
Salary number)
partition by range(Salary)
(partition p1 values less than(10000),
partition p2 values less than(20000),
partition p3 values less than(30000),
partition p4 values less than(maxvalue));


Select * from Employee_1 order by 1;

Select * from Employee_1 partition(p4);


--To see how many partitioned tables are there in your schema give the following statement
select  TABLE_NAME , PARTITIONING_TYPE  from    
         user_part_tables
   where  TABLE_NAME ='EMPLOYEE_1';
 
 
 ---List Partitioning: DISTINCT REGION 
 
 Create table Employee_2(emp_no number(2),
State varchar2(20))
partition by List(State)
(partition p1_Maharashtra values ('Maharashtra'),
partition p2_Gujrath values('Gujrath'),
partition p3_Rajsthan values('Bengal'),
partition p4_Other values (Default));


Select * from Employee_2;

Select * from Employee_2 partition(p1_Maharashtra)


--Hash Partitioning Tables
--Hash partitioning is useful when there is no obvious range key, or range partitioning will cause uneven distribution of data. 
--The number of partitions must be a power of 2 (2, 4, 8, 16...) and can be specified by the PARTITIONS...STORE IN clause.

CREATE TABLE invoices
(invoice_no    NUMBER NOT NULL,
 invoice_date  DATE   NOT NULL,
 comments      VARCHAR2(500))
PARTITION BY HASH (invoice_no)
(PARTITION invoices_q1 TABLESPACE users,
 PARTITION invoices_q2 TABLESPACE users,
 PARTITION invoices_q3 TABLESPACE users,
 PARTITION invoices_q4 TABLESPACE users);



--To see how many partitioned tables are there in your schema give the following statement
select  TABLE_NAME , PARTITIONING_TYPE  from    
         user_part_tables
   where  TABLE_NAME ='invoices';