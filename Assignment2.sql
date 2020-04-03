-- Answer to the 2nd Database Assignment 2019/20
--
-- CANDIDATE NUMBER 198735
-- Please insert your candidate number in the line above.
-- Do NOT remove ANY lines of this template.


-- In each section below put your answer in a new line 
-- BELOW the corresponding comment.
-- Use ONE SQL statement ONLY per question.
-- If you don’t answer a question just leave 
-- the corresponding space blank. 
-- Anything that does not run in SQL you MUST put in comments.
-- Your code should never throw a syntax error.
-- Questions with syntax errors will receive zero marks.

-- DO NOT REMOVE ANY LINE FROM THIS FILE.

-- START OF ASSIGNMENT CODE


-- @@01
CREATE TABLE Hospital_MedicalRecord(
recNo       bigint,
patient     char(9),
doctor      char(9),
enteredOn   datetime default CURRENT_TIMESTAMP not null,
diagnosis   mediumtext not null,
treatment   text,
PRIMARY KEY (recNo,patient),
CONSTRAINT FK_patient
FOREIGN KEY (patient) references hospital_patient(NINumber) on update restrict on delete cascade,
CONSTRAINT FK_doctor
FOREIGN KEY (doctor) references hospital_doctor(NINumber) on update restrict,
check(recNo > 0 and recNo <= 65535 and treatment <= 1000)
);

-- @@02
ALTER TABLE Hospital_MedicalRecord
add column duration time;

-- @@03
UPDATE Hospital_Doctor
SET salary = 9/10 * salary
WHERE expertise like '%ear%';

-- @@04
SELECT fname, lname, YEAR(dateOfBirth) as born
FROM Hospital_Patient
WHERE city LIKE BINARY '%right%'
ORDER BY lname, fname;

-- @@05
SELECT NINumber, fname, lname, round(weight/power(height/100,2),3) as BMI
FROM Hospital_Patient
WHERE (YEAR(current_date) - YEAR(dateOfBirth)) < 30;

-- @@06
SELECT COUNT(*) as number
FROM Hospital_Doctor;

-- @@07
SELECT A.NINumber, A.lname, COUNT(B.doctor) as operations
From Hospital_Doctor A LEFT OUTER JOIN Hospital_CarriesOut B
ON A.NINumber = B.doctor
GROUP BY A.NINumber
ORDER BY operations DESC;

-- @@08
SELECT NINumber, LEFT(UPPER(fname),1) as init, lname
FROM Hospital_Doctor
WHERE (mentored_by IS NULL) and (NINumber in
                                     (SELECT mentored_by FROM Hospital_Doctor));

-- @@09
SELECT A.theatreNo as theatre, A.startDateTime as startTime1, TIME(B.startDateTime) as startTime2
FROM Hospital_Operation A JOIN Hospital_Operation B
WHERE A.theatreNo = B.theatreNo AND
      A.startDateTime != B.startDateTime AND
      DATE(A.startDateTime) = DATE(B.startDateTime) AND
      TIME(A.startDateTime) + A.duration >= TIME(B.startDateTime) AND
      TIME(A.startDateTime) + A.duration <= TIME(B.startDateTime) + B.duration;

-- @@10
SELECT B.theatreNo, DAY(A.DATE) as dom, MONTHNAME(A.DATE) as month,
       YEAR(A.DATE) as year,  B.numOps
FROM (SELECT theatreNo, DATE(startDateTime) as DATE, COUNT(theatreNo) as numA
FROM Hospital_Operation
GROUP BY DATE) A JOIN (SELECT theatreNo, MAX(numC) as numOps
    FROM (SELECT theatreNo, COUNT(theatreNo) AS numC
    FROM Hospital_Operation GROUP BY DATE(startDateTime)) C
    GROUP BY theatreNo) B
WHERE A.theatreNo = B.theatreNo AND A.numA = B.numOps
ORDER BY theatreNo, A.DATE;

-- @@11
SELECT *
FROM(SELECT A.theatreNo, Coalesce(numB,0) AS lastMay, numA AS thisMay, numA - Coalesce(numB,0) AS increase
FROM (SELECT theatreNo, COUNT(theatreNo) as numA
    FROM Hospital_Operation
    WHERE YEAR(CURRENT_DATE) = YEAR(startDateTime) and MONTH(startDateTime) = 5
    GROUP BY theatreNo)A LEFT OUTER JOIN
    (SELECT theatreNo, COUNT(theatreNo) as numB
    FROM Hospital_Operation
    WHERE YEAR(startDateTime) = YEAR(DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR)) and MONTH(startDateTime) = 5
    GROUP BY theatreNo)B
ON A.theatreNo = B.theatreNo) C
WHERE C.increase >= 0
ORDER BY C.increase Desc;

-- @@12
DROP FUNCTION IF EXISTS usage_theatre;
delimiter $$
CREATE FUNCTION usage_theatre(thNo tinyint unsigned, yr smallint unsigned) RETURNS VARCHAR(60)
deterministic
begin
declare totalsecs, totalmins, totalhrs, totaldays VARCHAR(30);
if length(yr) > 4 or yr > year(current_timestamp) then
    return 'The year is in the future';
elseif not thNo in (select theatreNo from hospital_operation) then
    return concat('There is no operating theatre ', thNo);
elseif not thNo in (select theatreNo from hospital_operation where YEAR(startDateTime) = yr) then
    return concat('Operating theatre ', thNo, ' had no operations in ', yr);
else
select sum(time_to_sec(duration)) into totalsecs from hospital_operation where theatreNo = thNo and yr = YEAR(startDateTime);
select totalsecs div 60 into totalmins;
select totalmins div 60 into totalhrs;
select totalmins mod 60 into totalmins;
select totalhrs div 24 into totaldays;
select totalhrs mod 24 into totalhrs;
end if;
return concat(totaldays,'days ',totalhrs,'hrs ',totalmins,'mins');
end $$;
delimiter ;


-- END OF ASSIGNMENT CODE
