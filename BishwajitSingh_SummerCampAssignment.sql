-- =========================================
-- Bishwajit_SummerCampAssignment.sql
-- Camp Management Database Script
-- Tasks 1, 2, 3 Combined
-- =========================================

USE CampManagnebtDb;
GO

-- =========================================
-- Drop existing tables if they exist
-- =========================================
IF OBJECT_ID('Registration', 'U') IS NOT NULL DROP TABLE Registration;
GO
IF OBJECT_ID('Camp', 'U') IS NOT NULL DROP TABLE Camp;
GO
IF OBJECT_ID('Person', 'U') IS NOT NULL DROP TABLE Person;
GO

-- =========================================
-- Task 1: Create Tables
-- =========================================

CREATE TABLE Person (
    PersonID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50),
    MiddleName NVARCHAR(50),
    LastName NVARCHAR(50),
    DateOfBirth DATE,
    Email NVARCHAR(100),
    Gender CHAR(1),
    PersonalPhone NVARCHAR(15)
);
GO

CREATE TABLE Camp (
    CampID INT PRIMARY KEY IDENTITY(1,1),
    CampTitle NVARCHAR(100),
    StartDate DATE,
    EndDate DATE,
    Price DECIMAL(10,2),
    Capacity INT
);
GO

CREATE TABLE Registration (
    RegistrationID INT PRIMARY KEY IDENTITY(1,1),
    PersonID INT FOREIGN KEY NOT NULL REFERENCES Person(PersonID),
    CampID INT FOREIGN KEY NOT NULL REFERENCES Camp(CampID),
    RegistrationDate DATE DEFAULT GETDATE()
);
GO

-- =========================================
-- Task 2: Insert 5000 Random People
-- =========================================

WITH Numbers AS (
    SELECT TOP (5000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects a CROSS JOIN sys.objects b
),
AgeGender AS (
    SELECT n,
        CASE
            WHEN n <= 900 THEN 7 + (n-1)%6
            WHEN n <= 2250 THEN 13 + (n-901)%2
            WHEN n <= 3250 THEN 15 + (n-2251)%3
            ELSE 18 + (n-3251)%2
        END AS Age,
        CASE
            WHEN n <= 900 THEN CASE WHEN n <= 900*0.55 THEN 'M' ELSE 'F' END
            WHEN n <= 2250 THEN CASE WHEN n <= 900 + 1350*0.46 THEN 'M' ELSE 'F' END
            WHEN n <= 3250 THEN CASE WHEN n <= 2250 + 1000*0.64 THEN 'M' ELSE 'F' END
            ELSE CASE WHEN n <= 3250 + 1750*0.64 THEN 'M' ELSE 'F' END
        END AS Gender
    FROM Numbers
)
INSERT INTO Person (FirstName, MiddleName, LastName, Email, DateOfBirth, Gender, PersonalPhone)
SELECT 
    'FN' + CAST(n AS VARCHAR(5)),
    'MN' + CAST(n AS VARCHAR(5)),
    'LN' + CAST(n AS VARCHAR(5)),
    'user' + CAST(n AS VARCHAR(5)) + '@mail.com',
    DATEADD(YEAR,-Age,GETDATE()),
    Gender,
    '98' + RIGHT(CAST(ABS(CHECKSUM(NEWID()))%100000000 AS VARCHAR(8)),8)
FROM AgeGender;
GO

-- Task 2 Verification: Age + Gender %
SELECT
    CASE 
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 7 AND 12 THEN '7-12'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 13 AND 14 THEN '13-14'
        WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 15 AND 17 THEN '15-17'
        ELSE '18-19'
    END AS AgeGroup,
    ROUND(100.0 * SUM(CASE WHEN Gender='M' THEN 1 ELSE 0 END)/COUNT(*),2) AS MalePercent,
    ROUND(100.0 * SUM(CASE WHEN Gender='F' THEN 1 ELSE 0 END)/COUNT(*),2) AS FemalePercent
FROM Person
GROUP BY CASE 
            WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 7 AND 12 THEN '7-12'
            WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 13 AND 14 THEN '13-14'
            WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 15 AND 17 THEN '15-17'
            ELSE '18-19'
         END
ORDER BY AgeGroup;
GO

-- =========================================
-- Task 3: Generation-wise Male/Female %
-- =========================================
SELECT
    Generation,
    ROUND(100.0 * SUM(CASE WHEN Gender='M' THEN 1 ELSE 0 END)/COUNT(*),2) AS MalePercent,
    ROUND(100.0 * SUM(CASE WHEN Gender='F' THEN 1 ELSE 0 END)/COUNT(*),2) AS FemalePercent
FROM (
    SELECT *,
        CASE 
            WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 7 AND 12 THEN 'Gen X'
            WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 13 AND 14 THEN 'Millennials'
            WHEN DATEDIFF(YEAR, DateOfBirth, GETDATE()) BETWEEN 15 AND 17 THEN 'Gen Z'
            ELSE 'Gen Alpha'
        END AS Generation
    FROM Person
) AS t
GROUP BY Generation
ORDER BY 
    CASE Generation
        WHEN 'Gen X' THEN 1
        WHEN 'Millennials' THEN 2
        WHEN 'Gen Z' THEN 3
        WHEN 'Gen Alpha' THEN 4
    END;
GO
