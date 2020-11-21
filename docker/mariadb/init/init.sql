-- 스키마 생성 시작

CREATE TABLE departments (
    dept_no CHAR(4) NOT NULL,
    dept_name VARCHAR(40) NOT NULL,
    PRIMARY KEY (dept_no)
);

CREATE INDEX UX_DEPTNAME ON departments(dept_name);

CREATE TABLE employees (
    emp_no BIGINT(20) NOT NULL,
    birth_date DATE NOT NULL,
    first_name VARCHAR(14) NOT NULL,
    last_name VARCHAR(16) NOT NULL,
    gender ENUM('M','F') NOT NULL,
    hire_date DATE NOT NULL,
    PRIMARY KEY (emp_no)
);

CREATE INDEX IX_FIRSTNAME ON employees (first_name);
CREATE INDEX IX_HIREDATE ON employees (hire_date);

CREATE TABLE salaries (
    emp_no BIGINT(20) NOT NULL,
    salary BIGINT(20) NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    PRIMARY KEY (emp_no, from_date)
);

CREATE INDEX IX_SALARY ON salaries (salary);


CREATE TABLE dept_emp (
    emp_no BIGINT(20) NOT NULL,
    dept_no char(4) NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    PRIMARY KEY (dept_no, emp_no)
);

CREATE INDEX IX_FROMDATE ON dept_emp (from_date);
CREATE INDEX IX_EMPNO_FROMDATE ON dept_emp (emp_no, from_date);

CREATE TABLE dept_manager (
    dept_no CHAR(4) NOT NULL,
    emp_no BIGINT(20) NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    PRIMARY KEY (dept_no, emp_no)
);

CREATE TABLE titles (
    emp_no BIGINT(20) NOT NULL,
    title VARCHAR(50) NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE DEFAULT NULL,
    PRIMARY KEY (emp_no, from_date, title)
);

CREATE INDEX IX_TODATE ON titles (to_date);

CREATE TABLE employee_name (
    emp_no BIGINT(20) NOT NULL,
    first_name VARCHAR(14) NOT NULL,
    last_name VARCHAR(16) NOT NULL,
    PRIMARY KEY (emp_no)
);

CREATE FULLTEXT INDEX FX_NAME ON employee_name (first_name, last_name);

CREATE TABLE tb_dual (
    fd1 TINYINT(4) NOT NULL,
    PRIMARY KEY (fd1)
);

-- 스키마 생성 끝

