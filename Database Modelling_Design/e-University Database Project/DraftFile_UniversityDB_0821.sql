

--DBMD LECTURE
--UNIVERSITY DATABASE PROJECT 



--CREATE DATABASE


CREATE DATABASE University

USE University
GO


--//////////////////////////////


--CREATE TABLES 


--Make sure you add the necessary constraints.
--You can define some check constraints while creating the table, but some you must define later with the help of a scalar-valued function you'll write.
--Check whether the constraints you defined work or not.
--Import Values (Use the Data provided in the Github repo). 
--You must create the tables as they should be and define the constraints as they should be. 
--You will be expected to get errors in some points. If everything is not as it should be, you will not get the expected results or errors.
--Read the errors you will get and try to understand the cause of the errors.


CREATE TABLE [Region](
	[RegionID] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[RegionName] [nvarchar](30) NOT NULL
);

-------------------------------------------------

CREATE TABLE [Staff](
	[StaffID] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](30) NOT NULL,
	[LastName] [nvarchar](30) NOT NULL,
	[RegionID] [int] NOT NULL,
	FOREIGN KEY(RegionID) REFERENCES [Region](RegionID)
);

-------------------------------------------------

CREATE TABLE [Student](
	[StudentID] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](30) NOT NULL,
	[LastName] [nvarchar](30) NOT NULL,
	[Register_date] [date] NOT NULL,
	[RegionID] [int] NOT NULL,
	[StaffID] [int] NOT NULL,
	FOREIGN KEY(RegionID) REFERENCES [Region](RegionID),
	FOREIGN KEY(StaffID) REFERENCES [Staff](StaffID) ON UPDATE CASCADE
);

-------------------------------------------------

CREATE FUNCTION fnCourseCredit
	(
		@CourseName AS VARCHAR(20),
		@Credit AS INT
	)
RETURNS VARCHAR(10)
AS
BEGIN
	
	DECLARE @Validation AS VARCHAR(10)
	
	IF @CourseName IN ('Fine Arts', 'German', 'Biology') AND @Credit=15
		SET @Validation = 'Valid'
	ELSE IF @CourseName IN ('Chemistry', 'French', 'Physics', 'History', 'Music', 'Psychology') AND @Credit=30
		SET @Validation = 'Valid'
	ELSE
		SET @Validation = 'InValid'

	RETURN @Validation

END


CREATE TABLE [Course](
	[CourseID] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](30) NOT NULL,
	[Credit] [int] NOT NULL,
	CONSTRAINT [CourseCredit] CHECK (dbo.fnCourseCredit(Title, Credit)='Valid')
);

-------------------------------------------------

CREATE TABLE [Enrollment](
	[StudentID] INT NOT NULL FOREIGN KEY REFERENCES Student(StudentID) ON DELETE CASCADE ON UPDATE CASCADE,
	[CourseID] INT NOT NULL FOREIGN KEY REFERENCES Course(CourseID) ON DELETE CASCADE ON UPDATE CASCADE,

	CONSTRAINT PK_StudentCourse PRIMARY KEY(StudentID, CourseID)
);

-------------------------------------------------

CREATE TABLE [StaffCourse](
	[StaffID] INT NOT NULL FOREIGN KEY REFERENCES Staff(StaffID) ON DELETE CASCADE ON UPDATE CASCADE,
	[CourseID] INT NOT NULL FOREIGN KEY REFERENCES Course(CourseID) ON DELETE CASCADE ON UPDATE CASCADE,

	CONSTRAINT PK_StaffCourse PRIMARY KEY(StaffID, CourseID)
);

-------------------------------------------------

CREATE FUNCTION fnSCourseRegion
	(
		@StudentID AS INT,
		@CourseID AS INT
	)
RETURNS VARCHAR(10)
AS
BEGIN
	
	DECLARE @StudentRegion1 AS INT
	DECLARE @StudentRegion2 AS INT
	DECLARE @Validation AS VARCHAR(10)

	SELECT  @StudentRegion1 = RegionID FROM Student WHERE StudentID = @StudentID
	SELECT  @StudentRegion2 = COUNT(RegionID) FROM Staff WHERE StaffID IN (SELECT StaffID FROM StaffCourse WHERE CourseID=@CourseID)

	IF @StudentRegion1 IN (SELECT RegionID FROM Staff WHERE StaffID IN (SELECT StaffID FROM StaffCourse WHERE CourseID=@CourseID))
		SET @Validation='Valid'
	ELSE IF @StudentRegion2=0
		SET @Validation='Valid'
	ELSE
		SET @Validation='InValid'

	RETURN @Validation

END


ALTER TABLE Enrollment
ADD CONSTRAINT [CourseRegion] CHECK (dbo.fnSCourseRegion(StudentID, CourseID)='Valid');

-- /////////////////////////////////////////////////// -------


INSERT INTO Region VALUES ('England'),('Northern Ireland'),('Scotland'),('Wales');


INSERT INTO Staff VALUES
	('October', 'Lime', (SELECT RegionID FROM Region WHERE RegionName = 'Wales')),
	('Ross', 'Island', (SELECT RegionID FROM Region WHERE RegionName = 'Scotland')),
	('Harry', 'Smith', (SELECT RegionID FROM Region WHERE RegionName = 'England')),
	('Neil', 'Mango', (SELECT RegionID FROM Region WHERE RegionName = 'Scotland')),
	('Kellie', 'Pear', (SELECT RegionID FROM Region WHERE RegionName = 'England')),
	('Victor', 'Fig', (SELECT RegionID FROM Region WHERE RegionName = 'Wales')),
	('Margeret', 'Nolan', (SELECT RegionID FROM Region WHERE RegionName = 'England')),
	('Yavette', 'Berry', (SELECT RegionID FROM Region WHERE RegionName = 'Northern Ireland')),
	('Tom', 'Garden', (SELECT RegionID FROM Region WHERE RegionName = 'Northern Ireland'));


INSERT INTO Student VALUES
	('Alec', 'Hunter', '2020-05-12', 4, 1),
	('Bronwin', 'Blueberry', '2020-05-12', 3, 2),
	('Charlie', 'Apricot', '2020-05-12', 1, 3),
	('Ursula', 'Douglas', '2020-05-12', 3, 4),
	('Zorro', 'Apple', '2020-05-12', 1, 5),
	('Debbie', 'Orange', '2020-05-12', 4, 6);


INSERT INTO Course VALUES
	('Fine Arts', 15),
	('German', 15),
	('Chemistry', 30),
	('French', 30),
	('Physics', 30),
	('History', 30),
	('Music', 30),
	('Psychology', 30),
	('Biology', 15);


INSERT INTO StaffCourse VALUES (4,1),(3,2),(7,3),(5,4),(7,4),(3,5),(5,5),(8,9);


INSERT INTO Enrollment VALUES (1,1);  -- ERROR - The INSERT statement conflicted with the CHECK constraint "CourseRegion"
INSERT INTO Enrollment VALUES (1,2);  -- ERROR - The INSERT statement conflicted with the CHECK constraint "CourseRegion"
INSERT INTO Enrollment VALUES (2,1);  
INSERT INTO Enrollment VALUES (2,2);  -- ERROR - The INSERT statement conflicted with the CHECK constraint "CourseRegion"
INSERT INTO Enrollment VALUES (3,1);  -- ERROR - The INSERT statement conflicted with the CHECK constraint "CourseRegion"
INSERT INTO Enrollment VALUES (3,2);  
INSERT INTO Enrollment VALUES (4,1);
INSERT INTO Enrollment VALUES (4,2);  -- ERROR - The INSERT statement conflicted with the CHECK constraint "CourseRegion"


--///////////////////////////////////////////////


--CONSTRAINTS

--1. Students are constrained in the number of courses they can be enrolled in at any one time. 
--	 They may not take courses simultaneously if their combined points total exceeds 180 points.


CREATE FUNCTION fnTotalCreditLimit
	(
		@StudentID AS INT
	)
RETURNS VARCHAR(10)
AS
BEGIN
	
	DECLARE @Validation AS VARCHAR(10)
	DECLARE @StudentTotalCredit AS INT

	SELECT  @StudentTotalCredit = SUM(Credit)
	FROM    Enrollment AS e INNER JOIN Course AS c ON e.CourseID=c.CourseID
	WHERE   StudentID = @StudentID

	IF @StudentTotalCredit <= 180
		SET @Validation = 'Valid'
	ELSE
		SET @Validation = 'InValid'

	RETURN @Validation

END

----------

ALTER TABLE Enrollment
ADD CONSTRAINT TotalCreditControl CHECK (dbo.fnTotalCreditLimit(StudentID)='Valid');


--------/////////////////////////////////////////


--2. The student's region and the counselor's region must be the same.


CREATE FUNCTION fnStudentStaffRegion
	(
		@StudentID AS INT,
		@StaffID AS INT
	)
RETURNS VARCHAR(10)
AS
BEGIN
	
	DECLARE @Validation AS VARCHAR(10)
	DECLARE @StudentRegion AS INT
	DECLARE @StaffRegion AS INT

	SELECT  @StudentRegion = RegionID FROM Student WHERE StudentID = @StudentID
	SELECT  @StaffRegion = RegionID FROM Staff WHERE StaffID = @StaffID

	IF @StudentRegion = @StaffRegion
		SET @Validation = 'Valid'
	ELSE
		SET @Validation = 'InValid'

	RETURN @Validation

END

----------

ALTER TABLE Student
ADD CONSTRAINT CheckRegion CHECK (dbo.fnStudentStaffRegion(StudentID, StaffID)='Valid');


--///////////////////////////////////////////////


------ADDITIONALLY TASKS


--1. Test the credit limit constraint.


SELECT SUM(Credit) 
FROM Enrollment AS e INNER JOIN Course AS c ON e.CourseID=c.CourseID
WHERE StudentID = 3

-- 15

INSERT INTO Enrollment VALUES(3,8);
INSERT INTO Enrollment VALUES(3,7);
INSERT INTO Enrollment VALUES(3,6);
INSERT INTO Enrollment VALUES(3,5);
INSERT INTO Enrollment VALUES(3,4);
INSERT INTO Enrollment VALUES(3,3);   -- ERROR - The INSERT statement conflicted with the CHECK constraint "TotalCreditControl"


SELECT SUM(Credit) 
FROM Enrollment AS e INNER JOIN Course AS c ON e.CourseID=c.CourseID
WHERE StudentID = 3

-- 165


--///////////////////////////////////////////////

--2. Test that you have correctly defined the constraint for the student counsel's region. 

INSERT INTO Student (FirstName, LastName, Register_date, RegionID, StaffID)
VALUES('John', 'Snow', '2020-05-12', 1, 9)

-- The INSERT statement conflicted with the CHECK constraint "CheckRegion". The conflict occurred in database "University", table "dbo.Student".


--///////////////////////////////////////////////

--3. Try to set the credits of the History course to 20. (You should get an error.)

UPDATE Course SET Credit = 20 WHERE Title = 'History';

-- The UPDATE statement conflicted with the CHECK constraint "CourseCredit". The conflict occurred in database "University", table "dbo.Course", column 'Credit'.


--///////////////////////////////////////////////

--4. Try to set the credits of the Fine Arts course to 30.(You should get an error.)

UPDATE Course SET Credit = 30 WHERE Title = 'Fine Arts';

-- The UPDATE statement conflicted with the CHECK constraint "CourseCredit". The conflict occurred in database "University", table "dbo.Course".


--///////////////////////////////////////////////

--5. Debbie Orange wants to enroll in Chemistry instead of German. (You should get an error.)

SELECT * FROM Student  -- StudentID=6

SELECT * FROM Course   -- CourseID=3

INSERT INTO Enrollment VALUES(6,3);  -- ERROR - The INSERT statement conflicted with the CHECK constraint "CourseRegion"


--///////////////////////////////////////////////

--6. Try to set Tom Garden as counsel of Alec Hunter (You should get an error.)

SELECT * FROM Staff     -- StaffID=9

SELECT * FROM Student   -- StudentID=1

UPDATE Student SET StaffID=9 WHERE StudentID=1;  -- ERROR - The UPDATE statement conflicted with the CHECK constraint "CheckRegion".


--///////////////////////////////////////////////

--7. Swap counselors of Ursula Douglas and Bronwin Blueberry.

SELECT * FROM Student   -- StudentID=4,2, StaffID=4,2

UPDATE Student SET StaffID=2 WHERE StudentID=4;
UPDATE Student SET StaffID=4 WHERE StudentID=2;


--///////////////////////////////////////////////

--8. Remove a staff member from the staff table.
--	 If you get an error, read the error and update the reference rules for the relevant foreign key.

SELECT * FROM Staff 

DELETE FROM Staff WHERE StaffID=1;  -- ERROR

ALTER TABLE STUDENT DROP CONSTRAINT FK__Student__StaffID__3D5E1FD2

ALTER TABLE STUDENT ADD CONSTRAINT FK_StudentStaffID FOREIGN KEY (StaffID) REFERENCES Staff (StaffID) ON UPDATE CASCADE ON DELETE CASCADE;



 



















