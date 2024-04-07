-- Romika Chaudhary --
-- C0921918 --
-- P09B Chapter 9 Instead of Triggers --
-- April 6, 2024 --

--3
--Step 2
CREATE OR REPLACE VIEW professor_section_view AS
SELECT p.professor_no, NVL(COUNT(s.section_id), 0) AS total_sections
FROM gl_professors p
LEFT JOIN gl_sections s ON p.professor_no = s.professor_no
GROUP BY p.professor_no;

--To view output of professor_section_view
SELECT * FROM professor_section_view ORDER BY professor_no;

--Step 3
DELETE 
FROM professor_section_view
WHERE professor_no = 5008;

--When trying to delete professor no 5008 I am getting an error: data manipulation 
--operation not legal on this view as I am trying to perform a DELETE operation on the view
--that contains joins.


--Step 4
DELETE 
FROM professor_section_view
WHERE professor_no = 5001;

--When trying to delete professor no 5008 I am getting an error: data manipulation 
--operation not legal on this view as I am trying to perform a DELETE operation 
--on the view that contains joins.


--Step 5
CREATE OR REPLACE TRIGGER professor_delete_trg
INSTEAD OF DELETE ON professor_section_view
FOR EACH ROW
BEGIN
    DELETE FROM reset_COPY_tables.gl_sections_copy WHERE professor_no = :OLD.professor_no;
    DELETE FROM reset_COPY_tables.gl_professors_copy WHERE professor_no = :OLD.professor_no;
END;

--Step 6
DELETE 
FROM professor_section_view
WHERE professor_no = 5001;

--Step 7
SELECT * FROM professor_section_view WHERE professor_no = 5001;

SELECT * FROM gl_professors_copy WHERE professor_no = 5001;

SELECT * FROM gl_sections_copy WHERE professor_no = 5001