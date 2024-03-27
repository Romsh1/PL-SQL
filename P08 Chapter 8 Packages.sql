-- Romika Chaudhary --
-- C0921918 --
-- March 24, 2024 --
-- P08 Chapter 8: Packages --

--1
CREATE OR REPLACE PACKAGE college_pkg IS
TYPE college_pkg_rec_type IS RECORD (
    first_name gl_professors.first_name%TYPE,
    last_name gl_professors.last_name%TYPE,
    office_no gl_professors.office_no%TYPE,
    office_ext gl_professors.office_ext%TYPE
);
PROCEDURE get_professor(
    p_professor_no IN gl_professors.professor_no%TYPE,
    college_pkg OUT college_pkg_rec_type
);
-- PROCEDURE add_professor
-- PROCEDURE delete_professor
END college_pkg;

CREATE OR REPLACE PACKAGE BODY college_pkg IS
PROCEDURE get_professor
(
    p_professor_no IN gl_professors.professor_no%TYPE,
    p_college_pkg_rec OUT college_pkg_rec_type
)
IS
BEGIN
SELECT first_name, last_name, office_no, office_ext 
INTO p_college_pkg_rec
FROM gl_professors
WHERE professor_no = p_professor_no;
EXCEPTION
WHEN NO_DATA_FOUND THEN
DBMS_OUTPUT.PUT_LINE('No data found');
END get_professor;
END college_pkg;