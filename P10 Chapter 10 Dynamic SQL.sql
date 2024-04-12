-- Romika Chaudhary --
-- C0921918 --
-- April 10, 2024 --
-- P10 Chapter 10 Dynamic SQL --

CREATE OR REPLACE PROCEDURE P1001 (
    p_section_id IN NUMBER,
    p_professor_no IN NUMBER DEFAULT NULL,
    p_room_no IN NUMBER DEFAULT NULL,
    p_enroll_max IN NUMBER DEFAULT NULL
) AS
    v_error_code NUMBER;
    v_error_message VARCHAR2(200);
    v_professor_exists NUMBER;
BEGIN
    IF p_professor_no IS NOT NULL THEN
        --Check if the professor exists--
        SELECT COUNT(*)
        INTO v_professor_exists
        FROM gl_professors_copy
        WHERE professor_no = p_professor_no;
        
        IF v_professor_exists = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Professor no ' || p_professor_no || ' does not exist');
            RETURN;
        END IF;
        
        UPDATE gl_sections_copy
        SET professor_no = p_professor_no
        WHERE section_id = p_section_id;
        
        DBMS_OUTPUT.PUT_LINE('1 section updated');
        DBMS_OUTPUT.PUT_LINE('section_id = ' || p_section_id || ' updated professor_no = ' || p_professor_no);
    END IF;

    IF p_room_no IS NOT NULL THEN
        UPDATE gl_sections_copy
        SET room_no = p_room_no
        WHERE section_id = p_section_id;
        
        DBMS_OUTPUT.PUT_LINE('1 section updated');
        DBMS_OUTPUT.PUT_LINE('section_id = ' || p_section_id || ' updated room_no = ' || p_room_no);
    END IF;

    IF p_enroll_max IS NOT NULL THEN
        UPDATE gl_sections_copy
        SET enroll_max = p_enroll_max
        WHERE section_id = p_section_id;
        
        DBMS_OUTPUT.PUT_LINE('1 section updated');
        DBMS_OUTPUT.PUT_LINE('section_id = ' || p_section_id || ' updated enroll_max = ' || p_enroll_max);
    END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_error_code := SQLCODE;
            v_error_message := 'section id = ' || p_section_id || ' not found';
            DBMS_OUTPUT.PUT_LINE(v_error_message);
        WHEN OTHERS THEN
            v_error_code := SQLCODE;
            v_error_message := SQLERRM;
            DBMS_OUTPUT.PUT_LINE(v_error_message);
END;

--test 1
BEGIN
P1001(10001, 5005);
END;

--test 2
BEGIN
 P1001(10002, NULL, 222);
END;

--test 3
BEGIN
 P1001(10003, NULL, NULL, 55);
END;

--test 4
BEGIN
  P1001(10004, NULL, 666, 75);
END;

--test 5
BEGIN
P1001(1, 5001);
END;

--test 6
BEGIN
 P1001(10005, 111);
END;