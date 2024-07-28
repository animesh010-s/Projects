-- Patient Table---------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE Patients (
    PatientID INT PRIMARY KEY,
    Name VARCHAR(100),
    Age INT,
    Gender VARCHAR(10),
    BloodType VARCHAR(5)
);

COPY Patients
FROM 'G:\data analyst\Projects\sql\Patient.csv'
DELIMITER ','
CSV HEADER;

select*from Patients;

------------------------------------------------------------------------------------------------------------------------------------------
-- DOCTOR TABLE
CREATE TABLE Doctors (
    DoctorID INT PRIMARY KEY,
    Doctor VARCHAR(100)
);

COPY Doctors
FROM 'G:\data analyst\Projects\sql\Doctor.csv'
DELIMITER ','
CSV HEADER;

select*from doctors;

-------------------------------------------------------------------------------------------------------------------------------------
-- HOSPITALS--------

CREATE TABLE Hospitals (
    HospitalID INT PRIMARY KEY,
    Hospital VARCHAR(255)
);


COPY Hospitals
FROM 'G:\data analyst\Projects\sql\HOSPITAL.csv'
DELIMITER ','
CSV HEADER;

select*from Hospitals;

-----------------------------------------------------------------------------------------------------------------------------------------------
-- InsuranceProviders


CREATE TABLE InsuranceProviders (
    InsuranceProviderID INT PRIMARY KEY,
    InsuranceProvider VARCHAR(255)
);


COPY InsuranceProviders
FROM 'G:\data analyst\Projects\sql\Insurance_provider.csv'
DELIMITER ','
CSV HEADER;

select*from InsuranceProviders;

----------------------------------------------------------------------------------------------------------------------------------------------------
-- MedicalConditions

CREATE TABLE MedicalConditions (
    MedicalConditionID INT PRIMARY KEY,
    MedicalCondition VARCHAR(255)
);

COPY MedicalConditions
FROM 'G:\data analyst\Projects\sql\Medical_condition.csv'
DELIMITER ','
CSV HEADER;

select*from MedicalConditions;


--------------------------------------------------------------------------------------------------------------------------------------

-- Admissions


CREATE TABLE Admissions (
    AdmissionID INT PRIMARY KEY,
    PatientID INT,
    DoctorID INT,
    HospitalID INT,
    InsuranceProviderID INT,
    MedicalConditionID INT,
    DateOfAdmission DATE,
    BillingAmount DECIMAL(10, 2),
    RoomNumber INT,
    AdmissionType VARCHAR(50),
    DischargeDate DATE,
    Medication VARCHAR(255),
    TestResults VARCHAR(255),
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID),
    FOREIGN KEY (HospitalID) REFERENCES Hospitals(HospitalID),
    FOREIGN KEY (InsuranceProviderID) REFERENCES InsuranceProviders(InsuranceProviderID),
    FOREIGN KEY (MedicalConditionID) REFERENCES MedicalConditions(MedicalConditionID)
);


COPY Admissions
FROM 'G:\data analyst\Projects\sql\Admission.csv'
DELIMITER ','
CSV HEADER;

select*from admissions;
select distinct doctorid from admissions;
select distinct MedicalConditionID  from admissions
 order by MedicalConditionID ;
 
--------------------------------------------------------------------------------------------------------------------------------------


-- Q.1 patient names and their ages.

SELECT Name, Age
FROM Patients;

-- Q.2 All doctors' names

SELECT Doctor
FROM Doctors;

-- Q.3 Hospital names.

SELECT Hospital
FROM Hospitals;

-- Q.4 Insurance providers.

SELECT InsuranceProvider
FROM InsuranceProviders;

-- Q.5 Medical conditions.

SELECT MedicalCondition
FROM MedicalConditions;

-- Q.6 patient names along with their corresponding doctors' names

SELECT p.Name AS Patient, d.Doctor AS Doctor
FROM Admissions a
JOIN Patients p ON a.PatientID = p.PatientID
JOIN Doctors d ON a.DoctorID = d.DoctorID;

--Q.7 patient names, hospital names, and the medical conditions they are admitted for

SELECT p.Name AS Patient, h.Hospital AS Hospital, mc.MedicalCondition
FROM Admissions a
JOIN Patients p ON a.PatientID = p.PatientID
JOIN Hospitals h ON a.HospitalID = h.HospitalID
JOIN MedicalConditions mc ON a.MedicalConditionID = mc.MedicalConditionID;

-- Q.8 patient names along with their insurance providers.

SELECT p.Name AS Patient, ip.InsuranceProvider
FROM Admissions a
JOIN Patients p ON a.PatientID = p.PatientID
JOIN InsuranceProviders ip ON a.InsuranceProviderID = ip.InsuranceProviderID;

-- Q.9 total number of patients.

SELECT DISTINCT COUNT(*) AS TotalPatients
FROM Patients;

-- Q.10 the average billing amount.

SELECT AVG(BillingAmount) AS AverageBilling
FROM Admissions;

Q.11 Highest billing amount.

SELECT MAX(BillingAmount) AS HighestBilling
FROM Admissions;

-- Q.12 Lowest billing amount.

SELECT MIN(BillingAmount) AS LowestBilling
FROM Admissions;

-- Q.13 The number of patients admitted to each hospital.

SELECT h.Hospital, COUNT(*) AS NumberOfPatients
FROM Admissions a
JOIN Hospitals h ON a.HospitalID = h.HospitalID
GROUP BY h.Hospital;

-- Q.14 patients who have been admitted more than once

SELECT p.Name
FROM Patients p
JOIN Admissions a ON p.PatientID = a.PatientID
GROUP BY p.PatientID, p.Name
HAVING COUNT(*) > 1;


-- Q.15 Hospitals with a total billing amount greater than $100,000

SELECT h.Hospital
FROM Hospitals h
JOIN Admissions a ON h.HospitalID = a.HospitalID
GROUP BY h.Hospital
HAVING SUM(a.BillingAmount) > 100000;

-- Q.16 All patients along with the number of times they have been admitted

WITH PatientAdmissions AS (
    SELECT PatientID, COUNT(*) AS AdmissionCount
    FROM Admissions
    GROUP BY PatientID
)
SELECT p.Name, pa.AdmissionCount
FROM PatientAdmissions pa
JOIN Patients p ON pa.PatientID = p.PatientID;

-- Q.17 The average age of patients for each medical condition.

WITH AverageAges AS (
    SELECT mc.MedicalCondition, AVG(p.Age) AS AverageAge
    FROM Admissions a
    JOIN Patients p ON a.PatientID = p.PatientID
    JOIN MedicalConditions mc ON a.MedicalConditionID = mc.MedicalConditionID
    GROUP BY mc.MedicalCondition
)
SELECT *
FROM AverageAges;

-- Q.18 Ranking patients by their total billing amounts.

SELECT p.Name, a.BillingAmount,
       RANK() OVER (ORDER BY a.BillingAmount DESC) AS BillingRank
FROM Admissions a
JOIN Patients p ON a.PatientID = p.PatientID;

-- Q.19 Cumulative billing amount for each patient

SELECT p.Name, a.BillingAmount,
       SUM(a.BillingAmount) OVER (PARTITION BY a.PatientID ORDER BY a.DateOfAdmission) AS CumulativeBilling
FROM Admissions a
JOIN Patients p ON a.PatientID = p.PatientID;

-- Q.20 Patients who have been admitted but have not been billed yet

SELECT p.Name
FROM Patients p
LEFT JOIN Admissions a ON p.PatientID = a.PatientID
WHERE a.BillingAmount IS NULL;

-- Q.21 Doctors who have treated patients with both 'Asthma' and 'Cancer

SELECT d.Doctor
FROM Doctors d
JOIN Admissions a ON d.DoctorID = a.DoctorID
JOIN MedicalConditions mc ON a.MedicalConditionID = mc.MedicalConditionID
WHERE mc.MedicalCondition = 'Asthma'
INTERSECT
SELECT d.Doctor
FROM Doctors d
JOIN Admissions a ON d.DoctorID = a.DoctorID
JOIN MedicalConditions mc ON a.MedicalConditionID = mc.MedicalConditionID
WHERE mc.MedicalCondition = 'Cancer';

-- Q.22 The average age of patients for each gender

SELECT Gender, AVG(Age) AS AverageAge
FROM Patients
GROUP BY Gender;

-- Q.23 The total billing amount for each insurance provider

SELECT ip.InsuranceProvider, SUM(a.BillingAmount) AS TotalBilling
FROM Admissions a
JOIN InsuranceProviders ip ON a.InsuranceProviderID = ip.InsuranceProviderID
GROUP BY ip.InsuranceProvider;

-- Q.24 Total number of admissions for each admission type

SELECT AdmissionType, COUNT(*) AS TotalAdmissions
FROM Admissions
GROUP BY AdmissionType;


-- Q.25 Maximum and minimum billing amounts for each medical condition

SELECT mc.MedicalCondition, MAX(a.BillingAmount) AS MaxBilling, MIN(a.BillingAmount) AS MinBilling
FROM Admissions a
JOIN MedicalConditions mc ON a.MedicalConditionID = mc.MedicalConditionID
GROUP BY mc.MedicalCondition;

-- Q.26 Top 5 patients with the highest total billing amounts.

SELECT p.Name, SUM(a.BillingAmount) AS TotalBilling
FROM Admissions a
JOIN Patients p ON a.PatientID = p.PatientID
GROUP BY p.Name
ORDER BY TotalBilling DESC
LIMIT 5;

-- Q.27 The average billing amount per patient for each medical condition

SELECT mc.MedicalCondition, AVG(a.BillingAmount) AS AvgBillingPerPatient
FROM Admissions a
JOIN MedicalConditions mc ON a.MedicalConditionID = mc.MedicalConditionID
GROUP BY mc.MedicalCondition;


-- Q.28 Number of admissions per hospital and hospital with the highest number of admissions.

SELECT h.Hospital, COUNT(*) AS NumberOfAdmissions
FROM Admissions a
JOIN Hospitals h ON a.HospitalID = h.HospitalID
GROUP BY h.Hospital
ORDER BY NumberOfAdmissions DESC
LIMIT 1;

-- Q.29 Top 3 doctors with the most patient visits.

SELECT d.Doctor, COUNT(*) AS Number_Of_Visits
FROM Admissions a
JOIN Doctors d ON a.DoctorID = d.DoctorID
GROUP BY d.Doctor
ORDER BY Number_Of_Visits DESC
LIMIT 3;

-- Q.30 All unique patients who have been admitted but not have any billing record

SELECT p.Name
FROM Patients p
LEFT JOIN Admissions a ON p.PatientID = a.PatientID
WHERE a.BillingAmount IS NULL;


-- Q.31 Patients admitted in "LTD HANSON" and those who have INSURANCE IN  "Cigna".

SELECT p.Name
FROM Admissions a
JOIN Patients p ON a.PatientID = p.PatientID
JOIN Hospitals h ON a.HospitalID = h.HospitalID
JOIN InsuranceProviders ip ON a.InsuranceProviderID = ip.InsuranceProviderID
WHERE h.Hospital = 'LTD HANSON'
INTERSECT
SELECT p.Name
FROM Admissions a
JOIN Patients p ON a.PatientID = p.PatientID
JOIN InsuranceProviders ip ON a.InsuranceProviderID = ip.InsuranceProviderID
WHERE ip.InsuranceProvider = 'Cigna';

-- Q.32  patients admitted in either 'LTD HANSON' or "ADAMS-FLYNN"
SELECT DISTINCT p.Name
FROM Admissions a
JOIN Patients p ON a.PatientID = p.PatientID
JOIN Hospitals h ON a.HospitalID = h.HospitalID
WHERE h.Hospital IN ('LTD HANSON', 'ADAMS-FLYNN');

-- Q.33 Patients who have been admitted in 'LTD HANSON' but not in 'ADAMS-FLYNN'

SELECT p.Name
FROM Admissions a
JOIN Patients p ON a.PatientID = p.PatientID
JOIN Hospitals h ON a.HospitalID = h.HospitalID
WHERE h.Hospital = 'LTD HANSON'
EXCEPT
SELECT p.Name
FROM Admissions a
JOIN Patients p ON a.PatientID = p.PatientID
JOIN Hospitals h ON a.HospitalID = h.HospitalID
WHERE h.Hospital = 'ADAMS-FLYNN';
































