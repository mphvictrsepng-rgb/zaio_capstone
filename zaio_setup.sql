-- ============================================================
-- ZAIO DATABASE INTERMEDIATE CAPSTONE PROJECT
-- zaio_setup.sql
-- ============================================================

-- Q1: Create the production database
CREATE DATABASE zaio_management_db;

-- Q2: Switch active connection to the new database
\c zaio_management_db

-- Q3: Initialize a Git repository
-- git init

-- Q4: .gitignore content (i wrote the answer here, even thooug i have a separate file for it)
-- .env
-- *.log

-- Q5: Verify database exists and display its encoding
SELECT datname, pg_encoding_to_char(encoding) AS encoding
FROM pg_database
WHERE datname = 'zaio_management_db';

-- Q6: Create the tracks lookup table
CREATE TABLE tracks (
    track_id SERIAL PRIMARY KEY,
    track_name VARCHAR(50) NOT NULL UNIQUE
);

-- Q7: Create the zaio_students table
CREATE TABLE zaio_students (
    student_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    cohort_year INTEGER
);

-- Q8: Set DEFAULT 2026 on cohort_year
ALTER TABLE zaio_students
ALTER COLUMN cohort_year SET DEFAULT 2026;

-- Q9: Add foreign key referencing tracks
ALTER TABLE zaio_students
ADD COLUMN track_id INTEGER REFERENCES tracks(track_id);

-- Q10: Create the courses table (with description for Q15 to drop)
CREATE TABLE courses (
    course_code VARCHAR(10) PRIMARY KEY,
    course_name VARCHAR(255) NOT NULL,
    description TEXT
);

-- Q11: Create the enrollments intersection table
CREATE TABLE enrollments (
    student_id INTEGER REFERENCES zaio_students(student_id),
    course_code VARCHAR(10) REFERENCES courses(course_code),
    final_grade NUMERIC
);

-- Q12: Add composite primary key to enrollments
ALTER TABLE enrollments
ADD PRIMARY KEY (student_id, course_code);

-- Q13: Add CHECK constraint for grade range 0-100
ALTER TABLE enrollments
ADD CONSTRAINT chk_grade_range CHECK (final_grade >= 0 AND final_grade <= 100);

-- Q14: Add mandatory unique email column to zaio_students
ALTER TABLE zaio_students
ADD COLUMN email VARCHAR(255) NOT NULL UNIQUE;

-- Q15: Drop the description column from courses
ALTER TABLE courses
DROP COLUMN description;

-- Q16: Bulk insert three tracks
INSERT INTO tracks (track_name) VALUES
    ('Data Science'),
    ('AI Engineering'),
    ('Full Stack Web Dev');

-- Q17: Bulk load 50 students from zaio_student_data.txt
--\Copy zaio_students(full_name, track_id, cohort_year) FROM 'zaio_student_data.txt' WITH (FORMAT csv, DELIMITER ',');

-- Q18: Bulk update cohort_year for a specific track
UPDATE zaio_students
SET cohort_year = 2027
WHERE track_id = 1;

-- Q19: Insert with ON CONFLICT DO NOTHING
INSERT INTO tracks (track_id, track_name)
VALUES (1, 'Data Science')
ON CONFLICT (track_id) DO NOTHING;

-- Q20: Delete enrollments with grade below 10
DELETE FROM enrollments
WHERE final_grade < 10;

-- Q21: Select students in the Data Science track
SELECT zs.full_name
FROM zaio_students zs
JOIN tracks t ON zs.track_id = t.track_id
WHERE t.track_name = 'Data Science';

-- Q22: Students whose name starts with 'A'
SELECT * FROM zaio_students
WHERE full_name LIKE 'A%';

-- Q23: Courses with no enrollments
SELECT c.course_code, c.course_name
FROM courses c
WHERE c.course_code NOT IN (
    SELECT DISTINCT course_code FROM enrollments
);

-- Q24: All students sorted by name descending.
SELECT * FROM zaio_students
ORDER BY full_name DESC;

-- Q25: Assignments with deadlines in the future
--SELECT * FROM assignments
--WHERE deadline > NOW();

-- Q26: Count of students per track.
SELECT t.track_name, COUNT(zs.student_id) AS total_students
FROM tracks t
JOIN zaio_students zs ON t.track_id = zs.track_id
GROUP BY t.track_name;

-- Q27: Average final grade for a specific course.
SELECT AVG(final_grade) AS average_grade
FROM enrollments
WHERE course_code = 'CS101';

-- Q28: Join students with their course names.
SELECT zs.full_name, c.course_name
FROM zaio_students zs
JOIN enrollments e ON zs.student_id = e.student_id
JOIN courses c ON e.course_code = c.course_code;

-- Q29: Tracks with zero enrollments (outer join)
SELECT t.track_name, COUNT(zs.student_id) AS enrollment_count
FROM tracks t
LEFT JOIN zaio_students zs ON t.track_id = zs.track_id
GROUP BY t.track_name
HAVING COUNT(zs.student_id) = 0;
