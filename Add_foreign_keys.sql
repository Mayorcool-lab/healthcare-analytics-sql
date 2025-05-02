
--Purpose: Adds foreign key constraints to FactTable to link it with related dimension tables.
         --Ensures data integrity between fact and dimension tables.

-- STEP 1: Set the working database
USE Healthcare_DB;
GO

-- STEP 2: Drop existing foreign key constraints (if they exist)
-- This avoids duplication or conflict when re-running the script

IF OBJECT_ID('FK_dimPatientPK', 'F') IS NOT NULL ALTER TABLE FactTable DROP CONSTRAINT FK_dimPatientPK;
GO
IF OBJECT_ID('FK_dimPhysicianPK', 'F') IS NOT NULL ALTER TABLE FactTable DROP CONSTRAINT FK_dimPhysicianPK;
GO
IF OBJECT_ID('FK_dimTransactionPK', 'F') IS NOT NULL ALTER TABLE FactTable DROP CONSTRAINT FK_dimTransactionPK;
GO
IF OBJECT_ID('FK_dimPayerPK', 'F') IS NOT NULL ALTER TABLE FactTable DROP CONSTRAINT FK_dimPayerPK;
GO
IF OBJECT_ID('FK_dimLocationPK', 'F') IS NOT NULL ALTER TABLE FactTable DROP CONSTRAINT FK_dimLocationPK;
GO
IF OBJECT_ID('FK_dimDiagnosisCodePK', 'F') IS NOT NULL ALTER TABLE FactTable DROP CONSTRAINT FK_dimDiagnosisCodePK;
GO
IF OBJECT_ID('FK_dimCptCodePK', 'F') IS NOT NULL ALTER TABLE FactTable DROP CONSTRAINT FK_dimCptCodePK;
GO
IF OBJECT_ID('FK_dimDatePK', 'F') IS NOT NULL ALTER TABLE FactTable DROP CONSTRAINT FK_dimDatePK;
GO

-- STEP 3: Add new foreign key constraints
-- This links FactTable to each dimension table by their primary key

ALTER TABLE FactTable
ADD
    CONSTRAINT FK_dimPatientPK         FOREIGN KEY (dimPatientPK)       REFERENCES dimPatient(dimPatientPK),
    CONSTRAINT FK_dimPhysicianPK       FOREIGN KEY (dimPhysicianPK)     REFERENCES dimPhysician(dimPhysicianPK),
    CONSTRAINT FK_dimTransactionPK     FOREIGN KEY (dimTransactionPK)   REFERENCES dimTransaction(dimTransactionPK),
    CONSTRAINT FK_dimPayerPK           FOREIGN KEY (dimPayerPK)         REFERENCES dimPayer(dimPayerPK),
    CONSTRAINT FK_dimLocationPK        FOREIGN KEY (dimLocationPK)      REFERENCES dimLocation(dimLocationPK),
    CONSTRAINT FK_dimDiagnosisCodePK   FOREIGN KEY (dimDiagnosisCodePK) REFERENCES dimDiagnosisCode(dimDiagnosisCodePK),
    CONSTRAINT FK_dimCptCodePK         FOREIGN KEY (dimCptCodePK)       REFERENCES dimCptCode(dimCptCodePK),
    CONSTRAINT FK_dimDatePK            FOREIGN KEY (dimDatePostPK)      REFERENCES dimDate(dimDatePostPK);
GO
