use University

--Deleting the department with id 302.
DELETE FROM Department WHERE Department_Id = 302;

--Updating the passing field to show n for those with a gpa below passing.
UPDATE Students SET Passing = 'N' WHERE GPA <=1.0;

--Showing all students whose first name starts with s or last name starts with m.
SELECT * FROM Students WHERE Last_Name LIKE 'M%' UNION SELECT * FROM Students WHERE First_Name LIKE 'S%';

--Filtering the top 3 students which have a gpa above 3.1, and checks which of them are from groups 811 or 821.
SELECT TOP 3 * FROM Students WHERE GPA >3.1 INTERSECT SELECT TOP 3 * FROM Students WHERE Group_id=811 OR Group_id=821;

--Showing the unique specialties where we have studetns with a gpa below 3 except the top two specialties that show up in group 811 with a student id below 8.
SELECT Specialty FROM Students WHERE GPA <3.0 EXCEPT SELECT TOP 2 Specialty FROM Students WHERE Group_id=811 AND Student_Id<8;

--Showing the professors and courses taught by the professors in the Mathematics Informatics department.
SELECT * FROM Professors p INNER JOIN Courses c ON p.Professor_Id=c.Professor_Id WHERE p.Professor_Id IN (101, 104);

--Showing all students based on the student classes enrolled in, based on the courses set up. If a course has no students, it is listed as null.
SELECT * FROM Students s RIGHT JOIN Student_Classes c ON s.Student_Id=c.Student_Id RIGHT JOIN Courses l ON c.Course_Id=l.Course_Id;

--Showing all professors based on the department they are in, and any empty departments.
SELECT * FROM Department d LEFT JOIN Professors p ON p.Department_Id=d.Department_Id;

--Showing the id's of the students enrolled in each class, and any blanks on either side.
SELECT CourseName, Student_Id FROM Courses l FULL OUTER JOIN Student_Classes c ON l.Course_Id=c.Course_Id;

--Showing the students with a gpa above 3 that are in groups 821 and 811.
SELECT * FROM Students s WHERE GPA > 3 AND s.Group_Id IN (821, 811);

--Showing the departments that have at least one assigned Professor in it.
SELECT * FROM Department d WHERE EXISTS (SELECT * from Professors p WHERE d.Department_Id=p.Department_Id);

--Showing the names and groups of the students whose gpa is above 3.
SELECT Z.First_Name, Z.Last_Name, Z.Group_id FROM (SELECT * FROM Students WHERE GPA > 3)Z ORDER BY Group_id;

--Showing the number of students grouped by the specialty they are in, excluding any specialty having less than 3 students, and showing it in a decreasing order.
SELECT Specialty, COUNT(*) FROM Students GROUP BY Specialty HAVING COUNT(*)>3 ORDER BY COUNT(*) DESC;

--Showing each group average gpa if it is greater than the minimum mark 
SELECT Group_id, AVG(GPA), COUNT(*) FROM Students GROUP BY Group_id HAVING AVG(GPA)>(SELECT MIN(GPA) FROM Students);

--e) Showing the course id of the courses that students are enrolled in based on the number of students attending it.
SELECT Course_Id, COUNT(*) FROM Student_Classes GROUP BY Course_Id;

SELECT DISTINCT Last_Name from Students WHERE Passing='Y';
