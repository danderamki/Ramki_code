----comments

EXPLAIN PLAN FOR
WITH salaryrank AS (
    SELECT
        sal,
        DENSE_RANK()
        OVER(
            ORDER BY
                sal DESC
        ) AS rank
    FROM
        emp
)
SELECT
    sal
FROM
    salaryrank
WHERE
    rank IN ( 3, 4 );
    
    
    
    with myra as
    (select * from employees    --WHERE Salary > 50000  
)
select * from myra where last_name like '%a%';


SELECT
    employee_id,
    manager_id,
    first_name,
    last_name
FROM
         employees a
    INNER JOIN employees b 
    ON a.employee_id = b.MANAGER_id;
    
    
SELECT
  (e.first_name || '  ' || e.last_name) employee,
  (m.first_name || '  ' || m.last_name) manager,
  e.job_title
FROM
  employees e
  LEFT JOIN employees m ON m.employee_id = e.manager_id
ORDER BY
  manager;
    
    
    SELECT e.employee_id,m.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    m.first_name || ' ' || m.last_name AS manager_name
FROM
    employees e
LEFT JOIN
    employees m ON e.manager_id = m.employee_id;

SELECT EMPNO, JOB, SAL, 
RANK() OVER (PARTITION BY DEPTNO ORDER BY SAL) AS RANK,
DENSE_RANK() OVER (PARTITION BY DEPTNO ORDER BY SAL) AS D_RANK
FROM EMP A;



SELECT  * FROM EMP;


SELECT ENAME, JOB, MGR,SAL,
LAG(SAL, 1,0) OVER (PARTITION  BY DEPTNO ORDER BY SAL) AS PREV_SAL,
SAL-LAG(SAL, 1,0) OVER (PARTITION  BY DEPTNO ORDER BY SAL) AS SAL_DIFF
FROM EMP;

2ND HIG;

SELECT
    MAX(sal) AS sec FROM EMP
WHERE
    sal < (
        SELECT
            MAX(sal)
        FROM
            emp
    );
    
    
    
    --- Write a query to retrieve employees who earn more than the average salary.
    
    
    SELECT * FROM EMP_1 WHERE SAL> (SELECT AVG(SAL) FROM EMP);
    
    
    
    SELECT COUNT(1), EMPNO FROM EMP_1
    GROUP BY EMPNO
    HAVING COUNT(*)>1
    ORDER BY 2;
    
    
WITH delete_dups AS (
    SELECT
        COUNT(1) AS cnt,
        empno
    FROM
        emp_1
    GROUP BY
        empno
    HAVING
        COUNT(*) > 1
    ORDER BY
        2
)
DELETE FROM DELETE_DUPS WHERE CNT > 1;










WITH delete_dups AS (
    SELECT
        empno
    FROM
        emp_1
    GROUP BY
        empno
    HAVING
        COUNT(*) > 1
)
DELETE FROM emp_1
WHERE empno IN (SELECT empno FROM delete_dups);


DELETE FROM emp_1
WHERE empno IN (
    SELECT
        empno
    FROM
        emp_1
    GROUP BY
        empno
    HAVING
        COUNT(*) > 1
);

rollback;



SELECT *
FROM (
  SELECT ROWID     AS rid,
         ROW_NUMBER() OVER (PARTITION BY empno ORDER BY ROWID) AS rn,
         empno, ename, sal -- add other columns you want to see
  FROM emp_1
)
WHERE rn > 1
ORDER BY empno;




WITH to_delete AS (
  SELECT ROWID AS rid,
         ROW_NUMBER() OVER (PARTITION BY empno ORDER BY ROWID) AS rn
  FROM emp_1
)
DELETE FROM emp_1
WHERE ROWID IN (
  SELECT rid FROM to_delete WHERE rn > 1
);


---Write a query to fetch the 3rd and 4th highest salaries.


WITH RK AS 
(SELECT  ENAME, JOB, MGR,SAL, DENSE_RANK() OVER ( order by sal) as rk_sal from emp)
select SAL from RK where rk_sal in (3,4);



DELETE FROM emp_1
WHERE ROWID IN (
  SELECT rid FROM (
    SELECT ROWID AS rid,
           ROW_NUMBER() OVER (PARTITION BY empno ORDER BY ROWID) AS rn
    FROM emp_1
  ) WHERE rn > 1
);
    