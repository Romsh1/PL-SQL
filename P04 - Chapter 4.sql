-- Romika Chaudhary --
-- C0921918 --
-- Chapter 4 --
-- Jan 31, 2024 --

--1
DECLARE
CURSOR course_cursor IS
    SELECT course_code, course_title 
    FROM gl_courses
    ORDER BY course_code;

v_cur_rec course_cursor%ROWTYPE;

BEGIN
    OPEN course_cursor;
DBMS_OUTPUT.PUT_LINE('Course Code' || ' ' || 'Course Title');
DBMS_OUTPUT.PUT_LINE('------------' || ' ' || '------------');
LOOP
    FETCH course_cursor
    INTO v_cur_rec;
EXIT WHEN course_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(v_cur_rec.course_code || ' ' || v_cur_rec.course_title);
END LOOP;
CLOSE course_cursor;
END;



--3
DECLARE
   v_section_id gl_sections.section_id%TYPE := :ENTER_SECTION_ID;

   v_course_name      gl_courses.course_title%TYPE;
   v_semester_year     DECIMAL(4);
   v_semester_season   VARCHAR(1);
   v_instructor_name   VARCHAR2(100);
   v_course_code       VARCHAR2(100);

   CURSOR class_list_cursor IS
      SELECT s.student_no, s.first_name || ' ' || s.last_name AS student_name
      FROM gl_enrollments e
      JOIN gl_students s ON e.student_no = s.student_no
      WHERE e.section_id = v_section_id;

BEGIN
   SELECT c.course_code, c.course_title, s.semester_year, s.semester_term, p.first_name || ' ' || p.last_name
   INTO v_course_code, v_course_name, v_semester_year, v_semester_season, v_instructor_name
   FROM gl_sections se
   JOIN gl_courses c ON se.course_code = c.course_code
   JOIN gl_semesters s ON se.semester_id = s.semester_id
   JOIN gl_professors p ON se.professor_no = p.professor_no
   WHERE se.section_id = v_section_id;

   DBMS_OUTPUT.PUT_LINE('Class List for '|| v_course_code || ' ' || v_course_name);
   DBMS_OUTPUT.PUT_LINE('Semester: ' || v_semester_year || v_semester_season);
   DBMS_OUTPUT.PUT_LINE('Instructor: ' || v_instructor_name);
   DBMS_OUTPUT.PUT_LINE('');
   DBMS_OUTPUT.PUT_LINE('Student No   Student Name');
   DBMS_OUTPUT.PUT_LINE('----------   -------------');

   FOR class_rec IN class_list_cursor LOOP
      DBMS_OUTPUT.PUT_LINE(class_rec.student_no || '         ' || class_rec.student_name);
   END LOOP;
END;