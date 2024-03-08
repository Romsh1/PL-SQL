--- Romika Chaudhary ---
--- March 5, 2024 ---
--- P06 Chapter 6: Procedures ---

-- 1
CREATE OR REPLACE PROCEDURE ADD_PROFESSOR
    (p_professor_no IN GL_PROFESSORS_COPY.professor_no%TYPE, 
    p_first_name IN GL_PROFESSORS_COPY.first_name%TYPE, 
    p_last_name IN GL_PROFESSORS_COPY.last_name%TYPE, 
    p_office_no IN GL_PROFESSORS_COPY.office_no%TYPE, 
    p_office_ext IN GL_PROFESSORS_COPY.office_ext%TYPE, 
    p_school_code IN GL_PROFESSORS_COPY.school_code%TYPE)
IS
    v_school_name GL_SCHOOLS.school_name%TYPE;
BEGIN
    INSERT INTO GL_PROFESSORS_COPY(professor_no, first_name, last_name, office_no, office_ext, school_code)
    VALUES (p_professor_no, p_first_name, p_last_name, p_office_no, p_office_ext, p_school_code);

    SELECT school_name
    INTO v_school_name
    FROM GL_SCHOOLS
    WHERE school_code = p_school_code;

    DBMS_OUTPUT.PUT_LINE('Inserted '|| SQL%ROWCOUNT ||' row');
  DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Professor: ' || p_professor_no || ' - ' || p_first_name || ' ' || p_last_name);
    DBMS_OUTPUT.PUT_LINE('Office No: ' || p_office_no);
    DBMS_OUTPUT.PUT_LINE('Office EXT: ' || p_office_ext);
    DBMS_OUTPUT.PUT_LINE('School Code: ' || p_school_code || ' - ' || v_school_name);
END ADD_PROFESSOR;


DECLARE
    v_professor_no GL_PROFESSORS_COPY.professor_no%TYPE := :ENTER_PROFESSOR_NO;
    v_first_name GL_PROFESSORS_COPY.first_name%TYPE := :ENTER_FIRST_NAME;
    v_last_name GL_PROFESSORS_COPY.last_name%TYPE := :ENTER_LAST_NAME; 
    v_office_no GL_PROFESSORS_COPY.office_no%TYPE := :ENTER_OFFICE_NO;
    v_office_ext GL_PROFESSORS_COPY.office_ext%TYPE := :ENTER_OFFICE_EXT;
    v_school_code GL_PROFESSORS_COPY.school_code%TYPE := UPPER(:ENTER_SCHOOL_CODE);
BEGIN
    v_first_name := UPPER(SUBSTR(v_first_name, 1, 1)) || LOWER(SUBSTR(v_first_name, 2));
    v_last_name := UPPER(SUBSTR(v_last_name, 1, 1)) || LOWER(SUBSTR(v_last_name, 2));
    ADD_PROFESSOR(v_professor_no, v_first_name, v_last_name, v_office_no, v_office_ext, v_school_code);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Professor ' || v_professor_no || ' already in the table');
  WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error code: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Error message: ' || SQLERRM);
END;



-- 2
CREATE OR REPLACE PROCEDURE CONVERT_GRADE(
    p_numeric_grade IN GL_ENROLLMENTS.NUMERIC_GRADE%TYPE, 
    p_letter_grade OUT GL_ENROLLMENTS.LETTER_GRADE%TYPE)
IS
BEGIN
CASE 
    WHEN p_numeric_grade >= 90 THEN p_letter_grade := 'A';
    WHEN p_numeric_grade >= 80 THEN p_letter_grade := 'B';
    WHEN p_numeric_grade >= 70 THEN p_letter_grade := 'C';
    WHEN p_numeric_grade >= 60 THEN p_letter_grade := 'D';
    WHEN p_numeric_grade < 60 THEN p_letter_grade := 'F';
END CASE;
EXCEPTION
  WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error code: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Error message: ' || SQLERRM);
END CONVERT_GRADE;


DECLARE
    v_numeric_grade GL_ENROLLMENTS.numeric_grade%TYPE :=  :ENTER_NUMERIC_GRADE;
    v_letter_grade GL_ENROLLMENTS.letter_grade%TYPE;
    OUT_OF_RANGE EXCEPTION;
    PRAGMA EXCEPTION_INIT(OUT_OF_RANGE, -6502);
BEGIN
    IF v_numeric_grade < 0 OR v_numeric_grade > 100 THEN
        RAISE OUT_OF_RANGE;
    END IF;
    CONVERT_GRADE(v_numeric_grade, v_letter_grade);
    DBMS_OUTPUT.PUT_LINE('Numeric grade: ' || v_numeric_grade);
    DBMS_OUTPUT.PUT_LINE('Letter grade: ' || v_letter_grade);
EXCEPTION
WHEN OUT_OF_RANGE THEN
    DBMS_OUTPUT.PUT_LINE('Grade ' || v_numeric_grade || ' invalid. Must be between 0 and 100.');
WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error code: ' || SQLCODE);
    DBMS_OUTPUT.PUT_LINE('Error message: ' || SQLERRM);
END;



-- 3
CREATE OR REPLACE PROCEDURE UPGRADE_GRADE
    (p_section_id IN GL_ENROLLMENTS_COPY.section_id%TYPE,
    p_student_no IN GL_ENROLLMENTS_COPY.student_no%TYPE,
    p_numeric_grade IN GL_ENROLLMENTS_COPY.numeric_grade%TYPE,
    p_old_numeric_grade OUT GL_ENROLLMENTS_COPY.numeric_grade%TYPE,
    p_old_letter_grade OUT GL_ENROLLMENTS_COPY.LETTER_GRADE%TYPE,
    p_new_letter_grade OUT GL_ENROLLMENTS_COPY.LETTER_GRADE%TYPE)
IS
BEGIN
    SELECT numeric_grade, letter_grade
    INTO p_old_numeric_grade, p_old_letter_grade
    FROM GL_ENROLLMENTS_COPY
    WHERE student_no = p_student_no AND section_id = p_section_id;

    CONVERT_GRADE(p_numeric_grade, p_new_letter_grade);
    UPDATE GL_ENROLLMENTS_COPY
  SET  
    numeric_grade = p_numeric_grade, 
    letter_grade = p_new_letter_grade
    WHERE section_id = p_section_id AND student_no = p_student_no;
END UPGRADE_GRADE;


DECLARE
    v_section_id GL_ENROLLMENTS_COPY.student_no%TYPE := :ENTER_SECTION_ID;
    v_student_no GL_ENROLLMENTS_COPY.section_id%TYPE := :ENTER_STUDENT_NO;
    v_numeric_grade GL_ENROLLMENTS_COPY.numeric_grade%TYPE := :ENTER_NUMERIC_GRADE;
    v_old_numeric_grade GL_ENROLLMENTS_COPY.numeric_grade%TYPE;
    v_old_letter_grade GL_ENROLLMENTS_COPY.LETTER_GRADE%TYPE;
    v_new_letter_grade GL_ENROLLMENTS_COPY.LETTER_GRADE%TYPE;

    OUT_OF_RANGE EXCEPTION;
    PRAGMA EXCEPTION_INIT(OUT_OF_RANGE, -6502);
BEGIN
    IF v_numeric_grade < 0 OR v_numeric_grade > 100 THEN
        RAISE OUT_OF_RANGE;
    END IF;

    UPGRADE_GRADE(v_section_id, v_student_no, v_numeric_grade, v_old_numeric_grade, v_old_letter_grade, v_new_letter_grade);
  
    DBMS_OUTPUT.PUT_LINE('Student: ' || v_student_no);
    DBMS_OUTPUT.PUT_LINE('Section: ' || v_section_id);
    DBMS_OUTPUT.PUT_LINE('Numeric grade: Old - ' || COALESCE(TO_CHAR(v_old_numeric_grade, '999'), 'NG') || ' New - ' || v_numeric_grade);
    DBMS_OUTPUT.PUT_LINE('Letter grade: Old - ' || COALESCE(v_old_letter_grade, 'NG') || ' New - ' || v_new_letter_grade);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Student ' || v_student_no || ' Section: ' || v_section_id || ' not found');
    WHEN OUT_OF_RANGE THEN
        DBMS_OUTPUT.PUT_LINE('Grade ' || v_numeric_grade || ' invalid. Must be between 0 and 100.');
  WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error code: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Error message: ' || SQLERRM);
END;



-- 4
CREATE OR REPLACE PROCEDURE GET_GRADE
    (p_section_id IN GL_ENROLLMENTS_COPY.section_id%TYPE,
    p_student_no IN GL_ENROLLMENTS_COPY.student_no%TYPE,
    p_numeric_grade OUT GL_ENROLLMENTS_COPY.numeric_grade%TYPE,
    p__letter_grade OUT GL_ENROLLMENTS_COPY.LETTER_GRADE%TYPE)
IS
BEGIN
    SELECT numeric_grade, letter_grade
    INTO p_numeric_grade, p__letter_grade
    FROM GL_ENROLLMENTS_COPY
    WHERE student_no = p_student_no AND section_id = p_section_id;
END GET_GRADE;


DECLARE
    v_section_id GL_ENROLLMENTS_COPY.student_no%TYPE := :ENTER_SECTION_ID;
    v_student_no GL_ENROLLMENTS_COPY.section_id%TYPE := :ENTER_STUDENT_NO;
    v_numeric_grade GL_ENROLLMENTS_COPY.numeric_grade%TYPE;
    v_letter_grade GL_ENROLLMENTS_COPY.LETTER_GRADE%TYPE;
BEGIN
    GET_GRADE(v_section_id, v_student_no, v_numeric_grade, v_letter_grade);
  
    DBMS_OUTPUT.PUT_LINE('Student: ' || v_student_no);
    DBMS_OUTPUT.PUT_LINE('Section: ' || v_section_id);
    DBMS_OUTPUT.PUT_LINE('Numeric grade: ' || COALESCE(TO_CHAR(v_numeric_grade, '999'), 'NG'));
    DBMS_OUTPUT.PUT_LINE('Letter grade: ' || COALESCE(v_letter_grade, 'NG'));
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Student ' || v_student_no || ' Section: ' || v_section_id || ' not found');
  WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error code: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Error message: ' || SQLERRM);
END;