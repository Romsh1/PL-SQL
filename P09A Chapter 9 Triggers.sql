-- Romika Chaudhary --
-- C0921918 --
-- March 30, 2024 --
-- P09A Chapter 9: Triggers --

-- 1
--Step 1
CREATE TABLE GL_PRO_AUDIT_LOG (
    user_id VARCHAR2(30) DEFAULT USER,
    last_change_date DATE DEFAULT SYSDATE,
    trigger_name VARCHAR2(15),
    log_action VARCHAR2(30)
);

--Step 2
CREATE OR REPLACE TRIGGER GL_PROFESSOR_TRG
AFTER INSERT ON GL_PROFESSORS_COPY
DECLARE
    v_trigger_name VARCHAR2(15) := 'gl_professor_trg';
BEGIN
    INSERT INTO GL_PRO_AUDIT_LOG (trigger_name, log_action)
    VALUES (v_trigger_name, 'INSERT');
END;

--Step 3
DECLARE
    v_professor_no VARCHAR2(30); 
    v_first_name VARCHAR2(30);
    v_last_name VARCHAR2(30);
    v_office_no VARCHAR2(30);
    v_office_ext VARCHAR2(30);
    v_school_code VARCHAR2(30);
BEGIN
    v_professor_no := :ENTER_PROFESSOR_NO;
    v_first_name := INITCAP(:ENTER_FIRST_NAME);
    v_last_name := INITCAP(:ENTER_LAST_NAME);
    v_office_no := :ENTER_OFFICE_NO;
    v_office_ext := :ENTER_OFFICE_EXT;
    v_school_code := UPPER(:ENTER_SCHOOL_CODE);

    --Call ADD_PROFESSOR procedure
    ADD_PROFESSOR(v_professor_no, v_first_name, v_last_name, v_office_no, v_office_ext, v_school_code);

    --Display output
    DBMS_OUTPUT.PUT_LINE('Inserted 1 row');
    DBMS_OUTPUT.PUT_LINE('Professor: ' || v_professor_no || ' - ' || v_first_name || ' ' || v_last_name);
    DBMS_OUTPUT.PUT_LINE('Office No: ' || v_office_no);
    DBMS_OUTPUT.PUT_LINE('Office Ext: ' || v_office_ext);
    DBMS_OUTPUT.PUT_LINE('School Code: ' || v_school_code);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: Duplicate professor number');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

--Step 4
SELECT * FROM GL_PRO_AUDIT_LOG;




-- 2
--Step 1
CREATE OR REPLACE FUNCTION convert_numeric_grade(p_numeric_grade IN NUMBER)
RETURN VARCHAR2
IS
    v_letter_grade VARCHAR2(2);
BEGIN
    CASE
        WHEN p_numeric_grade >= 90 THEN v_letter_grade := 'A';
        WHEN p_numeric_grade >= 80 THEN v_letter_grade := 'B';
        WHEN p_numeric_grade >= 70 THEN v_letter_grade := 'C';
        WHEN p_numeric_grade >= 60 THEN v_letter_grade := 'D';
        ELSE v_letter_grade := 'F';
    END CASE;
    
    RETURN v_letter_grade;
END;

--Step 2
CREATE TABLE GL_ENROLL_UPDATE_LOG (
    user_id VARCHAR2(30) DEFAULT USER,
    last_change_date DATE DEFAULT SYSDATE,
    section_id NUMBER(5, 0),
    student_no NUMBER(7,0),
    old_grade VARCHAR2(2),
    new_grade VARCHAR2(2),
    log_action VARCHAR2(30)
);

--Step 3
CREATE OR REPLACE TRIGGER GL_ENROLL_UPDATE_TRG
AFTER UPDATE OF letter_grade ON gl_enrollments_copy
FOR EACH ROW
BEGIN
    INSERT INTO GL_ENROLL_UPDATE_LOG (section_id, student_no, old_grade, new_grade, log_action)
    VALUES (:OLD.section_id, :OLD.student_no, :OLD.letter_grade, :NEW.letter_grade,
            CASE
                WHEN :OLD.letter_grade = :NEW.letter_grade THEN 'grade is the same'
                WHEN :OLD.letter_grade < :NEW.letter_grade THEN 'grade went up'
                ELSE 'grade went down'
            END);
END;

--Step 4
DECLARE
    v_section_id NUMBER(5);
    v_student_no NUMBER(7);
    v_new_numeric_grade NUMBER;
BEGIN
    v_section_id := :section_id;
    v_student_no := :student_no;
    v_new_numeric_grade := :new_numeric_grade;
    
    UPDATE gl_enrollments_copy
    SET numeric_grade = v_new_numeric_grade
    WHERE section_id = v_section_id
    AND student_no = v_student_no;

    DBMS_OUTPUT.PUT_LINE('Update successful');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;