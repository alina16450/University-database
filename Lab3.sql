use University1;

CREATE TABLE CurrentVersion(
currentVersion int,
)

insert into CurrentVersion(currentVersion) VALUES (0);

--Create a table for exams.
CREATE PROCEDURE do_proc_1 
AS
	CREATE TABLE ExamSession(Exam_Id int PRIMARY KEY, exam_date date, Student_Id int)
	PRINT 'Exam table created.'
GO

--Undo the table created.
CREATE PROCEDURE undo_proc_1
AS
	DROP TABLE ExamSession
	PRINT 'Exam table deleted.'
GO

--Add a table for exam grades in students.
CREATE PROCEDURE do_proc_2
AS
	ALTER TABLE Students
	ADD examGrades int
	PRINT 'Exam grade table added.'
GO

--Remove the exam grades table in students.
CREATE PROCEDURE undo_proc_2
AS 
	ALTER TABLE Students
	DROP COLUMN examGrades
	PRINT'Exam grade table deleted.'
GO

--Set the default passing status to no, to update as needed.
CREATE PROCEDURE do_proc_3
AS
	ALTER TABLE Students
	ADD CONSTRAINT dc DEFAULT 'N' FOR isPassing
	PRINT'Default set to no.'
GO

--Remove the default passing status.
CREATE PROCEDURE undo_proc_3
AS
	ALTER TABLE Students
	DROP CONSTRAINT dc
	PRINT 'Default specification removed.'
GO

--Link the exams to students by adding a foreign key with the student id.
CREATE PROCEDURE do_proc_4
AS
	ALTER TABLE ExamSession
	ADD CONSTRAINT fk_Exam_Student FOREIGN KEY(Student_Id) REFERENCES Students(Student_Id)
	PRINT 'Foreign key created.'
GO

--Unlinking the exams from students.
CREATE PROCEDURE undo_proc_4
AS
	ALTER TABLE ExamSession
	DROP CONSTRAINT fk_Exam_Student
	PRINT 'Foreign key removed.'
GO


CREATE PROCEDURE Main @newVers int
AS
BEGIN
    DECLARE @oldVers int;
    DECLARE @i int;

    SET @oldVers = (SELECT currentVersion FROM CurrentVersion);

	--Checking that the given version is within bounds.
    IF @newVers > 4 OR @newVers < 0
    BEGIN
        RAISERROR('Version can only be between 0 and 4. Try again.', 10, 1);
        RETURN;
    END

	--First case is where we need to increase the version.
    IF @newVers > @oldVers
    BEGIN
        SET @i = @oldVers + 1;
        WHILE @i <= @newVers
        BEGIN
            IF @i = 1 EXEC do_proc_1;
            IF @i = 2 EXEC do_proc_2;
            IF @i = 3 EXEC do_proc_3;
            IF @i = 4 EXEC do_proc_4;
            SET @i = @i + 1;
        END
    END

	--Second case is where we need to decrease the version.
    ELSE IF @newVers < @oldVers
    BEGIN
        SET @i = @oldVers;
        WHILE @i > @newVers
        BEGIN
            IF @i = 1 EXEC undo_proc_1;
            IF @i = 2 EXEC undo_proc_2;
            IF @i = 3 EXEC undo_proc_3;
            IF @i = 4 EXEC undo_proc_4;
            SET @i = @i - 1;
        END
    END

	--Third case is where the versions are already equal.
	ELSE IF @newVers = @oldVers
	BEGIN
		PRINT('Already at that version.');
		RETURN;
	END

	--Version gets updated in table.
    UPDATE CurrentVersion
    SET currentVersion = @newVers;

    PRINT 'Version updated successfully.';
END;

SELECT * FROM CurrentVersion; 

exec Main 0;