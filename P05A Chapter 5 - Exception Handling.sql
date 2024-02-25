--- Romika Chaudhary ---
--- C0921918 ---
--- P05A Chapter 5 - Exception Handling ---
--- Feb 7, 2024 ---


-- 1
DECLARE
    v_error_code NUMBER(20);
    v_error_msg VARCHAR2(100);
    v_first_name VARCHAR2(50);
    v_last_name VARCHAR2(50);
    v_student_no NUMBER(20) := :ENTER_STUDENT_NO;
BEGIN
SELECT first_name, last_name
    INTO v_first_name, v_last_name
    FROM gl_students
    WHERE student_no = v_student_no;
    DBMS_OUTPUT.PUT_LINE(v_first_name || ' ' || v_last_name);
EXCEPTION
WHEN NO_DATA_FOUND THEN
DBMS_OUTPUT.PUT_LINE('Student ' || v_student_no || ' not found.');
WHEN OTHERS THEN
v_error_code := SQLCODE;
v_error_msg := SQLERRM;
DBMS_OUTPUT.PUT_LINE('Error code: ' || v_error_code || ' Error message: ' || v_error_msg);
END;