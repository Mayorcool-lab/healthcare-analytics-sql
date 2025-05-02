-- STEP 1: Create and Select the target database
CREATE DATABASE Healthcare_DB;
USE Healthcare_DB;
GO

-- STEP 2: Drop existing tables (for a clean start)
IF OBJECT_ID('FactTable') IS NOT NULL DROP TABLE FactTable; GO
IF OBJECT_ID('dimPatient') IS NOT NULL DROP TABLE dimPatient; GO
IF OBJECT_ID('dimPhysician') IS NOT NULL DROP TABLE dimPhysician; GO
IF OBJECT_ID('dimTransaction') IS NOT NULL DROP TABLE dimTransaction; GO
IF OBJECT_ID('dimPayer') IS NOT NULL DROP TABLE dimPayer; GO
IF OBJECT_ID('dimLocation') IS NOT NULL DROP TABLE dimLocation; GO
IF OBJECT_ID('dimDiagnosisCode') IS NOT NULL DROP TABLE dimDiagnosisCode; GO
IF OBJECT_ID('dimCptCode') IS NOT NULL DROP TABLE dimCptCode; GO
IF OBJECT_ID('dimDate') IS NOT NULL DROP TABLE dimDate; GO

-- STEP 3: Create fact table (central table with all numeric values)
CREATE TABLE FactTable (
	FactTablePK VARCHAR(255) NOT NULL PRIMARY KEY,
	dimPatientPK VARCHAR(255) NOT NULL,
	dimPhysicianPK VARCHAR(255) NOT NULL,
	dimDatePostPK VARCHAR(255) NOT NULL,
	dimDateServicePK VARCHAR(255) NOT NULL,
	dimCPTCodePK VARCHAR(255) NOT NULL,
	dimPayerPK VARCHAR(255) NOT NULL,
	dimTransactionPK VARCHAR(255) NOT NULL,
	dimLocationPK VARCHAR(255) NOT NULL,
	PatientNumber VARCHAR(255) NOT NULL,
	dimDiagnosisCodePK VARCHAR(255) NOT NULL,
	CPTUnits DECIMAL(12,2) NULL DEFAULT 0,
	GrossCharge DECIMAL(12,2) NULL DEFAULT 0,
	Payment DECIMAL(12,2) NULL DEFAULT 0,
	Adjustment DECIMAL(12,2) NULL DEFAULT 0,
	AR DECIMAL(12,2) NULL DEFAULT 0
);
GO

-- STEP 4: Create dimension tables

-- 4.1 Patient
CREATE TABLE dimPatient (
	dimPatientPK VARCHAR(255) NOT NULL PRIMARY KEY,
	PatientNumber VARCHAR(255),
	FirstName VARCHAR(255),
	LastName VARCHAR(255),
	Email VARCHAR(255),
	PatientGender VARCHAR(255),
	PatientAge INT,
	City VARCHAR(255),
	State VARCHAR(255)
);
GO

-- 4.2 Physician
CREATE TABLE dimPhysician (
	dimPhysicianPK VARCHAR(255) NOT NULL PRIMARY KEY,
	ProviderNpi VARCHAR(255),
	ProviderName VARCHAR(255),
	ProviderSpecialty VARCHAR(255),
	ProviderFTE DECIMAL(10,2) DEFAULT 0
);
GO

-- 4.3 Transaction
CREATE TABLE dimTransaction (
	dimTransactionPK VARCHAR(255) NOT NULL PRIMARY KEY,
	TransactionType VARCHAR(255),
	Transaction VARCHAR(255),
	AdjustmentReason VARCHAR(255)
);
GO

-- 4.4 Payer
CREATE TABLE dimPayer (
	dimPayerPK VARCHAR(255) NOT NULL PRIMARY KEY,
	PayerName VARCHAR(255)
);
GO

-- 4.5 Location
CREATE TABLE dimLocation (
	dimLocationPK VARCHAR(255) NOT NULL PRIMARY KEY,
	LocationName VARCHAR(255)
);
GO

-- 4.6 Diagnosis Code
CREATE TABLE dimDiagnosisCode (
	dimDiagnosisCodePK VARCHAR(255) NOT NULL PRIMARY KEY,
	DiagnosisCode VARCHAR(255),
	DiagnosisCodeDescription VARCHAR(255),
	DiagnosisCodeGroup VARCHAR(255)
);
GO

-- 4.7 CPT Code
CREATE TABLE dimCptCode (
	dimCPTCodePK VARCHAR(255) NOT NULL PRIMARY KEY,
	CptCode VARCHAR(255),
	CptDesc VARCHAR(255),
	CptGrouping VARCHAR(255)
);
GO

-- 4.8 Date
CREATE TABLE dimDate (
	dimDatePostPK VARCHAR(255) NOT NULL PRIMARY KEY,
	Date DATE,
	Year VARCHAR(255),
	Month VARCHAR(255),
	MonthPeriod VARCHAR(255),
	MonthYear VARCHAR(255),
	Day VARCHAR(255),
	DayName VARCHAR(255)
);
GO
