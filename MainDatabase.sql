CREATE DATABASE University
use University;


CREATE TABLE Groups(
Group_Id int PRIMARY KEY,
Nr_Students int,
yearOfStudy int
)

CREATE TABLE Department(
Department_Id int PRIMARY KEY,
Department_Name varchar(30),
numCourses int,
)

CREATE TABLE Students(
Student_Id int PRIMARY KEY,
First_Name VARCHAR(30),
Last_Name VARCHAR(30),
GPA int,
Specialty VARCHAR(10),
Group_id int,
Department_Id int,
FOREIGN KEY(Department_Id) REFERENCES Department(Department_Id),
FOREIGN KEY(Group_Id) REFERENCES Groups(Group_Id),
)

CREATE TABLE Professors(
Professor_Id int PRIMARY KEY,
First_Name varchar(30),
Last_Name varchar(30),
Specialty varchar(10),
Department_Id int,
FOREIGN KEY(Department_Id) REFERENCES Department(Department_Id),
)

CREATE TABLE Courses(
Course_Id int PRIMARY KEY,
NrEnrolled int,
CourseName varchar(30),
NrCredits int,
Professor_Id int,
FOREIGN KEY(Professor_Id) REFERENCES Professors(Professor_Id),
)

CREATE TABLE Student_Classes(
Student_Id int,
Course_Id int,
FOREIGN KEY(Student_Id) REFERENCES Students(Student_Id),
FOREIGN KEY(Course_Id) REFERENCES Courses(Course_Id),
)

ALTER TABLE Students ALTER COLUMN Specialty VARCHAR (30);
ALTER TABLE Students ADD Passing VARCHAR (5) DEFAULT 'Y';
ALTER TABLE Professors ALTER COLUMN Specialty VARCHAR (30);
ALTER TABLE Students ALTER COLUMN GPA DECIMAL(2, 1);

INSERT INTO Groups (Group_Id, Nr_Students) VALUES (101, 10), (205, 10), (811, 10), (821, 10);
INSERT INTO Groups VALUES (500, 5);

--validator checks that the number of student is within the defined parameters 
CREATE FUNCTION checkNumStudents(@num int)
RETURNS INT AS
BEGIN
	DECLARE @n int
	IF @num < 0 OR @num > 30
		SET @n = 0
	ELSE
		SET @n = 1
	RETURN @n
END

--validator checks that the year of study is within range
CREATE FUNCTION checkStudyYear(@num int)
RETURNS INT AS
BEGIN
	DECLARE @n int
	IF @num < 0 OR @num > 6
		SET @n = 0
	ELSE
		SET @n = 1
	RETURN @n
END

SELECT * FROM Students


--If the given values pass the validators, a new group is created and added to our group table.
CREATE PROCEDURE addGroupandStudent(@gid int, @numStuds int, @studyYear int, 
@Sid int, @FirstName varchar(30), @LastName varchar(30), @GPA int, @Specialty varchar(30), @did int, @passing varchar(2), @grade int)
AS
BEGIN
	IF dbo.checkNumStudents(@numStuds) = 1 AND dbo.checkStudyYear(@studyYear) = 1
		BEGIN
			INSERT INTO Groups(Group_Id, Nr_Students, yearOfStudy) VALUES (@gid, @numStuds, @studyYear)
			PRINT 'Group created.'
			INSERT INTO Students(Student_Id, First_Name, Last_Name, GPA, Specialty, Group_id, Department_Id, Passing, examGrades) VALUES
			(@Sid, @FirstName, @LastName, @GPA, @Specialty, @gid, @did, @passing, @grade)
			PRINT 'Student added'
		END
	ELSE
		BEGIN
			PRINT 'Error. The values entered are incorrect.'
		END
END

truncate table Groups
truncate table Students
exec addGroupandStudent 24, 10, 3, 26, 'Gabriel', 'Herbei', 3, 'Mathematics', 301, 'Y', 8

SELECT * FROM Groups
SELECT * FROM Students

--Shows all of the students group number, the course ID and the name of the courses they are enrolled in. If they are enrolled in 
--multiple classes they show up multiple times as to provide a useful student schedule.
CREATE VIEW studentsView
AS
	SELECT g.Group_Id, s.First_Name, s.Last_Name, c.Course_id, r.CourseName
	FROM Groups g INNER JOIN Students s ON g.Group_Id = s.Group_id INNER JOIN Student_Classes c ON s.Student_Id = c.Student_Id
	INNER JOIN Courses r ON c.Course_Id = r.Course_Id WHERE s.GPA > 2

SELECT * FROM studentsView

--The table where we will keep track of all the new courses added.
CREATE TABLE Logs(
triggerDate date,
triggerType varchar(10),
nameAffectedTable varchar (15),
numOfRecords int,
)

--The table where we will display the new courses, so that students can become aware of any new choices.
CREATE TABLE newCourses(
CourseId int PRIMARY KEY,
CourseName varchar(30),
NrCredits int,
ProfessorId int,
)

DELETE FROM Logs
DELETE FROM newCourses

--Creates a trigger that automatically adds a new course to the table newCourses any time a course is added to the list of options.
CREATE TRIGGER onInsert ON Courses FOR INSERT AS
BEGIN
	INSERT INTO newCourses(CourseId, CourseName, NrCredits, ProfessorId) SELECT Course_Id, CourseName, NrCredits, Professor_Id
	FROM inserted
	INSERT INTO Logs(triggerDate, triggerType, nameAffectedTable, numOfRecords) SELECT GETDATE(), 'INSERT', 'Courses', @@ROWCOUNT
	FROM inserted
END

SELECT * FROM Courses
SELECT * FROM Logs
SELECT * FROM newCourses

insert into Courses values (504,0 ,'Algorithms', 30, 101, null) 

--Creates two triggers within the Students table
IF EXISTS (SELECT name FROM sys.indexes WHERE name = N'N_idx_GPA')
	DROP INDEX N_idx_GPA ON Students;
GO

IF EXISTS (SELECT name FROM sys.indexes WHERE name = N'N_idx_Specialty')
	DROP INDEX N_idx_Specialty
GO

CREATE NONCLUSTERED INDEX N_idx_GPA ON Students(GPA);
CREATE NONCLUSTERED INDEX N_idx_Specialty ON Students(Specialty);

SELECT Student_Id FROM Students WHERE Specialty LIKE 'M%' ORDER BY GPA

