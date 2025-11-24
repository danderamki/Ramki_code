---Here’s a complete Oracle 19c PL/SQL example that parses your JSON BLOB data and inserts it into a table.


CREATE TABLE emp_json (
  empno    NUMBER,
  ename    VARCHAR2(50),
  job      VARCHAR2(50),
  mgr      NUMBER,
  hiredate DATE,
  sal      NUMBER,
  comm     NUMBER,
  deptno   NUMBER
);

-- Audit log table for error tracking
CREATE TABLE emp_json_audit (
  audit_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  error_time  TIMESTAMP DEFAULT SYSTIMESTAMP,
  error_msg   VARCHAR2(4000),
  context     VARCHAR2(1000)
);

---SELECT * FROM emp_json;

---select * from emp_json_audit


-- filepath: emp_json_loader.sql


-- filepath: emp_json_loader.sql
/*
  Procedure: load_emp_from_json_blob

  Comprehensive Summary:
  ----------------------------------------------------------------------------
  Purpose:
    This procedure ingests employee data from a JSON BLOB and inserts it into
    the emp_json table in Oracle 23ai. The JSON BLOB should contain an array
    of employee objects, each with fields like EMPNO, ENAME, JOB, etc.

  Error Handling:
    - If any error occurs during processing, the transaction is rolled back.
    - The error message, timestamp, and context are logged to emp_json_audit.
    - For production, you can extend the audit table with more columns as needed.
  ----------------------------------------------------------------------------
*/

-- Make sure this audit table exists:
-- CREATE TABLE emp_json_audit (
--   audit_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
--   error_time  TIMESTAMP DEFAULT SYSTIMESTAMP,
--   error_msg   VARCHAR2(4000),
--   context     VARCHAR2(1000)
-- );

CREATE OR REPLACE PROCEDURE load_emp_from_json_blob(p_json_blob IN BLOB) AS
  l_json_text  CLOB; -- Holds the JSON text after converting from BLOB
BEGIN
  -- Step 1: Convert the input BLOB (assumed to be UTF-8 encoded JSON) to a CLOB
  l_json_text := TO_CLOB(UTL_RAW.CAST_TO_VARCHAR2(
    DBMS_LOB.SUBSTR(p_json_blob, DBMS_LOB.getlength(p_json_blob), 1)
  ));

  -- Step 2: Use JSON_TABLE to parse the JSON array and insert each object as a row in emp_json
  INSERT INTO emp_json (
    empno, ename, job, mgr, hiredate, sal, comm, deptno
  )
  SELECT
    empno,                                 -- Employee number from JSON
    ename,                                 -- Employee name from JSON
    job,                                   -- Job title from JSON
    mgr,                                   -- Manager's employee number from JSON
    TO_DATE(hiredate, 'YYYY-MM-DD"T"HH24:MI:SS'), -- Convert ISO date string to Oracle DATE
    sal,                                   -- Salary from JSON
    comm,                                  -- Commission from JSON (can be null)
    deptno                                 -- Department number from JSON
  FROM
    JSON_TABLE(
      l_json_text,                         -- The JSON CLOB to parse
      '$[*]'                               -- Path: parse each element in the root array (array of employees)
      COLUMNS (
        empno    NUMBER       PATH '$.EMPNO',      -- Map JSON "EMPNO" to empno column
        ename    VARCHAR2(50) PATH '$.ENAME',      -- Map JSON "ENAME" to ename column
        job      VARCHAR2(50) PATH '$.JOB',        -- Map JSON "JOB" to job column
        mgr      NUMBER       PATH '$.MGR',        -- Map JSON "MGR" to mgr column
        hiredate VARCHAR2(30) PATH '$.HIREDATE',   -- Map JSON "HIREDATE" to hiredate column
        sal      NUMBER       PATH '$.SAL',        -- Map JSON "SAL" to sal column
        comm     NUMBER       PATH '$.COMM',       -- Map JSON "COMM" to comm column
        deptno   NUMBER       PATH '$.DEPTNO'      -- Map JSON "DEPTNO" to deptno column
      )
    );

  -- Step 3: Commit the transaction to save the inserted rows
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    -- Rollback any changes if an error occurs
    ROLLBACK;
    -- Log the error message and context to the audit table
   -- INSERT INTO emp_json_audit (error_time, error_msg, context)
   ---   VALUES (SYSTIMESTAMP, SQLERRM, 'Error in load_emp_from_json_blob');
    -- Optionally, re-raise the error if you want the caller to handle it
    -- RAISE;
END;
/




-- filepath: emp_json_loader_test.sql
/*
  Example: Calling load_emp_from_json_blob

  Steps:
    1. Define a CLOB variable containing your JSON array (as in Untitled-3).
    2. Create a temporary BLOB and write the JSON text into it as RAW data.
    3. Call the procedure, passing the BLOB as input.
    4. Free the temporary BLOB resource.

  This simulates loading JSON data from an external source (file, API, etc.)
  and demonstrates the end-to-end process of ingesting JSON into a relational table.
*/

DECLARE
  l_blob BLOB;        -- Temporary BLOB to hold the JSON data
  l_json_text CLOB := '[{"EMPNO":7369,"ENAME":"SMITH","JOB":"CLERK","MGR":7902,"HIREDATE":"1980-12-17T00:00:00","SAL":800,"COMM":null,"DEPTNO":20},{"EMPNO":7499,"ENAME":"ALLEN","JOB":"SALESMAN","MGR":7698,"HIREDATE":"1981-02-20T00:00:00","SAL":1600,"COMM":300,"DEPTNO":30},{"EMPNO":7521,"ENAME":"WARD","JOB":"SALESMAN","MGR":7698,"HIREDATE":"1981-02-22T00:00:00","SAL":1250,"COMM":500,"DEPTNO":30},{"EMPNO":7566,"ENAME":"JONES","JOB":"MANAGER","MGR":7839,"HIREDATE":"1981-04-02T00:00:00","SAL":2975,"COMM":null,"DEPTNO":20},{"EMPNO":7654,"ENAME":"MARTIN","JOB":"SALESMAN","MGR":7698,"HIREDATE":"1981-09-28T00:00:00","SAL":1250,"COMM":1400,"DEPTNO":30},{"EMPNO":7698,"ENAME":"BLAKE","JOB":"MANAGER","MGR":7839,"HIREDATE":"1981-05-01T00:00:00","SAL":2850,"COMM":null,"DEPTNO":30},{"EMPNO":7782,"ENAME":"CLARK","JOB":"MANAGER","MGR":7839,"HIREDATE":"1981-06-09T00:00:00","SAL":2450,"COMM":null,"DEPTNO":10},{"EMPNO":7788,"ENAME":"SCOTT","JOB":"ANALYST","MGR":7566,"HIREDATE":"1987-04-19T00:00:00","SAL":3000,"COMM":null,"DEPTNO":20},{"EMPNO":7839,"ENAME":"KING","JOB":"PRESIDENT","MGR":null,"HIREDATE":"1981-11-17T00:00:00","SAL":5000,"COMM":null,"DEPTNO":10},{"EMPNO":7844,"ENAME":"TURNER","JOB":"SALESMAN","MGR":7698,"HIREDATE":"1981-09-08T00:00:00","SAL":1500,"COMM":0,"DEPTNO":30},{"EMPNO":7876,"ENAME":"ADAMS","JOB":"CLERK","MGR":7788,"HIREDATE":"1987-05-23T00:00:00","SAL":1100,"COMM":null,"DEPTNO":20},{"EMPNO":7900,"ENAME":"JAMES","JOB":"CLERK","MGR":7698,"HIREDATE":"1981-12-03T00:00:00","SAL":950,"COMM":null,"DEPTNO":30},{"EMPNO":7902,"ENAME":"FORD","JOB":"ANALYST","MGR":7566,"HIREDATE":"1981-12-03T00:00:00","SAL":3000,"COMM":null,"DEPTNO":20},{"EMPNO":7934,"ENAME":"MILLER","JOB":"CLERK","MGR":7782,"HIREDATE":"1982-01-23T00:00:00","SAL":1300,"COMM":null,"DEPTNO":10}]';
BEGIN
  -- Step 1: Create a temporary BLOB to hold the JSON data
  DBMS_LOB.createtemporary(l_blob, TRUE);

  -- Step 2: Write the JSON text into the BLOB as RAW data (UTF-8 encoding)
  --   - UTL_RAW.cast_to_raw(l_json_text): Converts the CLOB text to RAW bytes.
  --   - DBMS_LOB.writeappend: Appends the RAW bytes to the BLOB.
  DBMS_LOB.writeappend(l_blob, LENGTH(l_json_text), UTL_RAW.cast_to_raw(l_json_text));

  -- Step 3: Call the procedure to load the JSON data into the emp_json table
  load_emp_from_json_blob(l_blob);

  -- Step 4: Free the temporary BLOB resource to avoid memory leaks
  DBMS_LOB.freetemporary(l_blob);
END;
/