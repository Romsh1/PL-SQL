--- Romika Chaudhary ---
--- C0921918 ---
--- P05B Chapter 5: Exception Handling ---
--- Feb 8, 2024 ---

-- 2
DECLARE
v_major_code gl_students.major_code%TYPE := :ENTER_MAJOR_CODE;
v_first_name VARCHAR2(50);
v_last_name VARCHAR2(50);
BEGIN
SELECT major_code, first_name, last_name
INTO v_major_code, v_first_name, v_last_name
FROM gl_students
WHERE major_code = v_major_code;
DBMS_OUTPUT.PUT_LINE('Student' || v_first_name || ' ' || v_last_name);
EXCEPTION
WHEN TOO_MANY_ROWS THEN
DBMS_OUTPUT.PUT_LINE('Request returned multiple rows');
WHEN NO_DATA_FOUND THEN
DBMS_OUTPUT.PUT_LINE('No students found for Major ' || v_major_code);
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('An unknown error occurred. Contact software support.');
END;



--3
DECLARE
e_program_code_not_found_ex EXCEPTION;
v_program_code gl_programs.program_code%TYPE := :ENTER_PROGRAM_CODE;
v_new_program_name VARCHAR2(100) := :ENTER_NEW_PROGRAM_NAME;
BEGIN
UPDATE gl_programs
SET program_name = v_new_program_name
WHERE program_code = v_program_code;
IF SQL%NOTFOUND THEN
RAISE e_program_code_not_found_ex;
END IF;
EXCEPTION
WHEN e_program_code_not_found_ex THEN
DBMS_OUTPUT.PUT_LINE('Program ' || v_program_code || ' does not exist.');
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('An unknown error occurred. Contact software support.');
END;



--4
DECLARE
e_school_code_not_found EXCEPTION;

e_school_code_too_long EXCEPTION;
PRAGMA EXCEPTION_INIT(e_school_code_too_long, -06502);

e_fk_exception EXCEPTION;
PRAGMA EXCEPTION_INIT(e_fk_exception, -2292);

v_school_code gl_schools.school_code%TYPE := :ENTER_SCHOOL_CODE;
BEGIN
    DELETE
    FROM gl_schools
    WHERE school_code = v_school_code;
IF SQL%NOTFOUND THEN
    RAISE e_school_code_not_found;
END IF;
EXCEPTION
    WHEN e_school_code_not_found THEN
    DBMS_OUTPUT.PUT_LINE('School code ' || v_school_code || ' does not exist.');
    WHEN e_school_code_too_long THEN
    DBMS_OUTPUT.PUT_LINE('School code is too long. Can only be two characters long.'); 
    WHEN e_fk_exception THEN
    DBMS_OUTPUT.PUT_LINE('Cannot delete row because of integrity constraint error. \nThere are child foreign key relationship with the GL_SCHOOLS table.'); 
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error occurred. Contact software support.');
    DBMS_OUTPUT.PUT_LINE('SQL Error Code: ' || SQLCODE);
    DBMS_OUTPUT.PUT_LINE('SQL Error Message: ' || SQLERRM);
END;