create table departments (
    dept_no char(4) not null,
    dept_name varchar(40) not null,
    primary key (dept_no),
    key ux_deptname (dept_name)
) ENGINE=InnoDB;

create table employees (
    emp_no int(11) not null,
    birth_date date not null,
    first_name varchar(14) not null,
    last_name varchar(16) not null,
    gender enum('M', 'F') not null,
    hire_date date not null,
    primary key (emp_no),
    key ix_firstname (first_name),
    key ix_hiredate (hire_date)
) ENGINE=InnoDB;

create table salaries (
    emp_no int(11) not null,
    salary int(11) not null,
    from_date date not null,
    to_date date not null,
    primary key (emp_no, from_date),
    key ix_salary (salary)
) ENGINE=InnoDB;


create table dept_emp (
    emp_no int(11) not null,
    dept_no char(4) not null,
    from_date date not null,
    to_date date not null,
    primary key (dept_no, emp_no),
    key ix_fromdate (from_date),
    key ix_empno_fromdate (emp_no, from_date)
) ENGINE=InnoDB;

create table dept_manager (
    dept_no char(4) not null,
    emp_no int(11) not null,
    from_date date not null,
    to_date date not null,
    primary key (dept_no, emp_no)
) ENGINE=InnoDB;


create table titles (
    emp_no int(11) not null,
    title varchar(50) not null,
    from_date date not null,
    to_date date default null,
    primary key (emp_no, from_date, title),
    key ix_todate (to_date)
) ENGINE=InnoDB;

create table employee_name (
    emp_no int(11) not null,
    first_name varchar(14) not null,
    last_name varchar(16) not null,
    primary key (emp_no),
    fulltext key fx_name (first_name, last_name)
) ENGINE=MyISAM;

create table tb_dual (
    fd1 tinyint(4) not null,
    primary key (fd1)
) ENGINE=InnoDB;