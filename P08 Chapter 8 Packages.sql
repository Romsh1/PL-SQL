-- Romika Chaudhary --
-- C0921918 --
-- March 24, 2024 --
-- P08 Chapter 8: Packages --

--Q1
--Step 1--
CREATE OR REPLACE PROCEDURE reset_COPY_tables 
AS
  v_count INTEGER;
BEGIN
DBMS_OUTPUT.PUT_LINE('starting the script');
  SELECT COUNT(*) INTO v_count
  FROM USER_TABLES
  WHERE TABLE_NAME = 'GL_PROFESSORS_COPY';
  IF v_count = 1 THEN
    EXECUTE IMMEDIATE 'DROP TABLE gl_professors_copy CASCADE CONSTRAINTS';
  END IF;

  SELECT COUNT(*) INTO v_count
  FROM USER_TABLES
  WHERE TABLE_NAME = 'GL_PROFESSORS';
  IF v_count = 1 THEN
    EXECUTE IMMEDIATE ' 
    CREATE TABLE gl_professors_copy AS
      SELECT * FROM gl_professors ';
	  
	EXECUTE IMMEDIATE '
    ALTER TABLE gl_professors_copy 
    ADD CONSTRAINT gl_professors_copy_pk
    PRIMARY KEY ( professor_no ) ';
  ELSE
    DBMS_OUTPUT.PUT_LINE('GL_PROFESSORS table is missing - unable to create GL_PROFESSORS_COPY table');
  END IF;

  SELECT COUNT(*) INTO v_count
  FROM USER_TABLES
  WHERE TABLE_NAME = 'GL_ENROLLMENTS_COPY';
  IF v_count = 1 THEN
    EXECUTE IMMEDIATE 'DROP TABLE gl_enrollments_copy CASCADE CONSTRAINTS';
  END IF;
  
  SELECT COUNT(*) INTO v_count
  FROM USER_TABLES
  WHERE TABLE_NAME = 'GL_ENROLLMENTS';
  IF v_count = 1 THEN
    EXECUTE IMMEDIATE ' 
    CREATE TABLE gl_enrollments_copy AS
    SELECT * FROM gl_enrollments ';

    EXECUTE IMMEDIATE '
    ALTER TABLE gl_enrollments_copy 
    ADD CONSTRAINT gl_enrollments_copy_pk
    PRIMARY KEY ( section_id, student_no ) ';
  ELSE
    DBMS_OUTPUT.PUT_LINE('GL_ENROLLMENTS table is missing - unable to create GL_ENROLLMENTS_COPY table');
  END IF;
END reset_COPY_tables;

-- Steps 2 ,3 ,5 --
--Package Specification
CREATE OR REPLACE PACKAGE college_pkg IS
    TYPE professor_rec IS RECORD (
        professor_no gl_professors_copy.professor_no%TYPE,
        first_name gl_professors_copy.first_name%TYPE,
        last_name gl_professors_copy.last_name%TYPE,
        office_ext gl_professors_copy.office_ext%TYPE,
        office_no gl_professors_copy.office_no%TYPE
    );

    PROCEDURE get_professor(
        p_professor_no IN gl_professors_copy.professor_no%TYPE,
        p_professor OUT professor_rec
    );
    
    PROCEDURE add_professor(
        p_professor_no IN gl_professors_copy.professor_no%TYPE,
        p_first_name IN gl_professors_copy.first_name%TYPE,
        p_last_name IN gl_professors_copy.last_name%TYPE,
        p_office_ext IN gl_professors_copy.office_ext%TYPE,
        p_office_no IN gl_professors_copy.office_no%TYPE
    );
    
    PROCEDURE delete_professor(
        p_professor_no IN gl_professors_copy.professor_no%TYPE
    );
END college_pkg;

--Package Body
CREATE OR REPLACE PACKAGE BODY college_pkg IS
    PROCEDURE get_professor(
        p_professor_no IN gl_professors_copy.professor_no%TYPE,
        p_professor OUT professor_rec
    ) IS
    BEGIN
        SELECT professor_no, first_name, last_name, office_ext, office_no
        INTO p_professor
        FROM gl_professors_copy
        WHERE professor_no = p_professor_no;
    END get_professor;
    
    PROCEDURE add_professor(
        p_professor_no IN gl_professors_copy.professor_no%TYPE,
        p_first_name IN gl_professors_copy.first_name%TYPE,
        p_last_name IN gl_professors_copy.last_name%TYPE,
        p_office_ext IN gl_professors_copy.office_ext%TYPE,
        p_office_no IN gl_professors_copy.office_no%TYPE
    ) IS
    BEGIN
        INSERT INTO gl_professors_copy (professor_no, first_name, last_name, office_ext, office_no)
        VALUES (p_professor_no, p_first_name, p_last_name, p_office_ext, p_office_no);
    END add_professor;
    
    PROCEDURE delete_professor(
        p_professor_no IN gl_professors_copy.professor_no%TYPE
    ) IS
    BEGIN
        DELETE FROM gl_professors_copy
        WHERE professor_no = p_professor_no;
    END delete_professor;
END college_pkg;

--Step 4 --
DECLARE
    v_professor college_pkg.professor_rec;
BEGIN
    college_pkg.get_professor(:ENTER_PROFESSOR_NO, v_professor);
    DBMS_OUTPUT.PUT_LINE('No: ' || v_professor.professor_no);
    DBMS_OUTPUT.PUT_LINE('Name: ' || v_professor.first_name || ' ' || v_professor.last_name);
    DBMS_OUTPUT.PUT_LINE('Office ext: ' || v_professor.office_ext);
    DBMS_OUTPUT.PUT_LINE('Office no: ' || v_professor.office_no);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Professor ' || :ENTER_PROFESSOR_NO || ' does not exist in the professor''s table');
END;

--Step 6
DECLARE
    v_professor_no gl_professors_copy.professor_no%TYPE := :ENTER_PROFESSOR_NO;
    v_first_name gl_professors_copy.first_name%TYPE := :ENTER_FIRST_NAME;
    v_last_name gl_professors_copy.last_name%TYPE := :ENTER_LAST_NAME;
    v_office_ext gl_professors_copy.office_ext%TYPE := :ENTER_OFFICE_EXT;
    v_office_no gl_professors_copy.office_no%TYPE := :ENTER_OFFICE_NO;
BEGIN
    college_pkg.add_professor(v_professor_no, v_first_name, v_last_name, v_office_ext, v_office_no);
    DBMS_OUTPUT.PUT_LINE('Inserted 1 row');
    DBMS_OUTPUT.PUT_LINE('Professor: ' || v_professor_no || ' - ' || v_first_name || ' ' || v_last_name);
    DBMS_OUTPUT.PUT_LINE('Office ext.: ' || v_office_ext);
    DBMS_OUTPUT.PUT_LINE('Office no: ' || v_office_no);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Professor ' || v_professor_no || ' already exists in the professors table');
END;

--Step 8
DECLARE
    v_professor_no gl_professors_copy.professor_no%TYPE := :ENTER_PROFESSOR_NO;
BEGIN
    college_pkg.delete_professor(v_professor_no);
    IF SQL%ROWCOUNT = 0 THEN
        RAISE NO_DATA_FOUND;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Delete professor request completed');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Professor ' || v_professor_no || ' does not exist in the professors table');
END;



--Q2
--Creating the overload package
CREATE OR REPLACE PACKAGE donor_overload_pkg AS
    FUNCTION get_donor_by_id(
        p_donor_id IN gl_donors.donor_id%TYPE
    ) RETURN VARCHAR2;
    

    FUNCTION get_donor_by_registration(
        p_registration_code IN gl_donors.registration_code%TYPE
    ) RETURN VARCHAR2;
END donor_overload_pkg;

CREATE OR REPLACE PACKAGE BODY donor_overload_pkg AS
    FUNCTION get_donor_by_id(
        p_donor_id IN gl_donors.donor_id%TYPE
    ) RETURN VARCHAR2 AS
        v_donor_info VARCHAR2(4000);
    BEGIN
        SELECT 'Donor name: ' || donor_name || CHR(10) ||
               'Donor type: ' || donor_type || CHR(10) ||
               'Pledge amount: $' || TO_CHAR(monthly_pledge_amount, '99999.99') || CHR(10) ||
               'Pledge months: ' || pledge_months || CHR(10) ||
               'Total amounts: $' || TO_CHAR(monthly_pledge_amount * pledge_months, '99999.99')
        INTO v_donor_info
        FROM gl_donors
        WHERE donor_id = p_donor_id;
        
        RETURN v_donor_info || CHR(10) || 'Donor request by donor id completed';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Donor not found';
    END get_donor_by_id;
    
    --Function to retrieve donor info
    FUNCTION get_donor_by_registration(
        p_registration_code IN gl_donors.registration_code%TYPE
    ) RETURN VARCHAR2 AS
        v_donor_info VARCHAR2(4000);
    BEGIN
        SELECT 'Donor name: ' || donor_name || CHR(10) ||
               'Donor type: ' || donor_type || CHR(10) ||
               'Pledge amount: $' || TO_CHAR(monthly_pledge_amount, '99999.99') || CHR(10) ||
               'Pledge months: ' || pledge_months || CHR(10) ||
               'Total amounts: $' || TO_CHAR(monthly_pledge_amount * pledge_months, '99999.99')
        INTO v_donor_info
        FROM gl_donors
        WHERE registration_code = p_registration_code;
        
        RETURN v_donor_info || CHR(10) || 'Donor request by registration code completed';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Donor not found';
    END get_donor_by_registration;
END donor_overload_pkg;

--Anonymous block to retrieve donor info by donor ID
DECLARE
    v_donor_id gl_donors.donor_id%TYPE := :ENTER_DONOR;
    v_donor_info VARCHAR2(4000);
BEGIN
    v_donor_info := donor_overload_pkg.get_donor_by_id(v_donor_id);
    DBMS_OUTPUT.PUT_LINE(v_donor_info);
END;

--Anonymous block to retrieve donor info by registration code
DECLARE
    v_registration_code gl_donors.registration_code%TYPE := :ENTER_REGISTRATION_CODE;
    v_donor_info VARCHAR2(4000);
BEGIN
    v_donor_info := donor_overload_pkg.get_donor_by_registration(v_registration_code);
    DBMS_OUTPUT.PUT_LINE(v_donor_info);
END;



--Q3
--Creating the package currency_exchange_pkg
CREATE OR REPLACE PACKAGE currency_exchange_pkg AS
    USD_TO_CAD CONSTANT NUMBER := 1.34470;
    CAD_TO_USD CONSTANT NUMBER := 0.743731;
    EUR_TO_USD CONSTANT NUMBER := 1.06570;
    USD_TO_EUR CONSTANT NUMBER := 0.938351;
    EUR_TO_CAD CONSTANT NUMBER := 1.43287;
    CAD_TO_EUR CONSTANT NUMBER := 0.697899;
END currency_exchange_pkg;

--Creating an anonymous block to calculate currency exchange amount
DECLARE
    v_conversion_type NUMBER := :ENTER_CONVERSION_TYPE;
    v_currency_amount NUMBER := :ENTER_CURRENCY_AMOUNT;
    v_exchange_amount NUMBER;
BEGIN
    CASE v_conversion_type
        --Converting from USD to CAD
        WHEN 1 THEN
            v_exchange_amount := v_currency_amount * currency_exchange_pkg.USD_TO_CAD;
            DBMS_OUTPUT.PUT_LINE('$' || TO_CHAR(v_currency_amount, '9999.99') || ' United States dollars = $' ||
                                 TO_CHAR(v_exchange_amount, '9999.99') || ' Canadian dollars');
        --Converting from CAD to USD
        WHEN 2 THEN
            v_exchange_amount := v_currency_amount * currency_exchange_pkg.CAD_TO_USD;
            DBMS_OUTPUT.PUT_LINE('$' || TO_CHAR(v_currency_amount, '9999.99') || ' Canadian dollars = $' ||
                                 TO_CHAR(v_exchange_amount, '9999.99') || ' United States dollars');
        --Converting from Euro to USD
        WHEN 3 THEN
            v_exchange_amount := v_currency_amount * currency_exchange_pkg.EUR_TO_USD;
            DBMS_OUTPUT.PUT_LINE('$' || TO_CHAR(v_currency_amount, '9999.99') || ' Euro = $' ||
                                 TO_CHAR(v_exchange_amount, '9999.99') || ' United States dollars');
        --Convert from USD to Euro
        WHEN 4 THEN
            v_exchange_amount := v_currency_amount * currency_exchange_pkg.USD_TO_EUR;
            DBMS_OUTPUT.PUT_LINE('$' || TO_CHAR(v_currency_amount, '9999.99') || ' United States dollars = $' ||
                                 TO_CHAR(v_exchange_amount, '9999.99') || ' Euro');
        --Converting from Euro to CAD
        WHEN 5 THEN
            v_exchange_amount := v_currency_amount * currency_exchange_pkg.EUR_TO_CAD;
            DBMS_OUTPUT.PUT_LINE('$' || TO_CHAR(v_currency_amount, '9999.99') || ' Euro = $' ||
                                 TO_CHAR(v_exchange_amount, '9999.99') || ' Canadian dollars');
        --Converting from CAD to Euro
        WHEN 6 THEN
            v_exchange_amount := v_currency_amount * currency_exchange_pkg.CAD_TO_EUR;
            DBMS_OUTPUT.PUT_LINE('$' || TO_CHAR(v_currency_amount, '9999.99') || ' Canadian dollars = $' ||
                                 TO_CHAR(v_exchange_amount, '9999.99') || ' Euro');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Invalid conversion type');
    END CASE;
END;