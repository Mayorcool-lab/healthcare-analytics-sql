/*
Purpose: Practicing SQL queries on the Healthcare_DB.
 Includes some step-by-step explorations and specific questions.
*/

-- Make sure we're using the right database first!
USE Healthcare_DB;
GO

-- == Initial Exploration Steps (Parts 1-5) ==
-- These seem like building blocks, figuring out data for a specific patient/visit.

--Part 1: Find basic info for a specific patient
SELECT
    FirstName
    ,LastName
    ,City
    ,[State]
FROM dimPatient
WHERE dimPatient.PatientNumber = '21383737'; -- Filtering by the patient's number
GO

---Part 2: Find where and when this patient visited a specific hospital
SELECT DISTINCT -- Using DISTINCT because a patient might have multiple entries on the same day at the same location?
    FirstName
    ,LastName
    ,City
    ,[State]
    ,LocationName
    ,dimDateServicePK -- Which date was the service?
FROM FactTable
INNER JOIN dimPatient -- Connect FactTable to Patient details
    ON dimPatient.dimPatientPK = FactTable.dimPatientPK
INNER JOIN dimLocation -- Connect FactTable to Location details
    ON dimLocation.dimLocationPK = FactTable.dimLocationPK
WHERE dimPatient.PatientNumber = '21383737' -- Same patient as Part 1
    AND LocationName = 'Fairview General Hospital'; -- Specific location
GO

--Part 3: Add the doctor and total charges for those visits
SELECT DISTINCT -- Still using DISTINCT here
    dimPatient.FirstName
    ,dimPatient.LastName
    ,dimPatient.City
    ,dimPatient.[State]
    ,dimLocation.LocationName
    ,dimDateServicePK
    ,dimPhysician.ProviderName
    ,SUM(FactTable.GrossCharge) as Charges -- Calculate total charges for each unique visit combination
FROM FactTable
    INNER JOIN dimPatient
        ON dimPatient.dimPatientPK = FactTable.dimPatientPK
    INNER JOIN dimLocation
        ON dimLocation.dimLocationPK = FactTable.dimLocationPK
    INNER JOIN dimPhysician -- Adding physician info
        ON dimPhysician.dimPhysicianPK = FactTable.dimPhysicianPK
WHERE dimPatient.PatientNumber = '21383737'
    AND LocationName = 'Fairview General Hospital'
GROUP BY -- Grouping by all the selected details to SUM charges correctly
    dimPatient.FirstName
    ,dimPatient.LastName
    ,dimPatient.City
    ,dimPatient.[State]
    ,dimLocation.LocationName
    ,dimDateServicePK
    ,dimPhysician.ProviderName;
GO

--Part 4: Focus on diagnosis and procedure codes for those visits
SELECT
    -- dimPatient.FirstName -- Commented out patient/location details...
    -- ,dimPatient.LastName -- ...to focus on the clinical codes and charges per provider.
    -- ,dimPatient.City
    -- ,[State]
    -- ,dimLocation.LocationName
    -- ,dimDateServicePK
    dimPhysician.ProviderName
    ,dimDiagnosisCode.DiagnosisCode
    ,dimDiagnosisCode.DiagnosisCodeDescription
    ,dimCptCode.CptCode
    ,dimCptCode.CptDesc
    ,SUM(FactTable.GrossCharge) as Charges
FROM FactTable
    INNER JOIN dimPatient
        ON dimPatient.dimPatientPK = FactTable.dimPatientPK
    INNER JOIN dimLocation
        ON dimLocation.dimLocationPK = FactTable.dimLocationPK
    INNER JOIN dimPhysician
        ON dimPhysician.dimPhysicianPK = FactTable.dimPhysicianPK
    INNER JOIN dimDiagnosisCode -- Adding diagnosis info
        ON dimDiagnosisCode.dimDiagnosisCodePK = FactTable.dimDiagnosisCodePK
    INNER JOIN dimCptCode -- Adding procedure (CPT) info
        ON dimCptCode.dimCPTCodePK = FactTable.dimCPTCodePK
WHERE dimPatient.PatientNumber = '21383737'
    AND LocationName = 'Fairview General Hospital'
GROUP BY -- Grouping by provider and the codes
    -- dimPatient.FirstName -- Match commented fields in SELECT
    -- ,dimPatient.LastName
    -- ,dimPatient.City
    -- ,[State]
    -- ,dimLocation.LocationName
    -- ,dimDateServicePK
    dimPhysician.ProviderName
    ,dimDiagnosisCode.DiagnosisCode
    ,dimDiagnosisCode.DiagnosisCodeDescription
    ,dimCptCode.CptCode
    ,dimCptCode.CptDesc;
GO

---Part 5: Get the overall financial summary for these visits
SELECT
    -- (Keeping previous fields commented out for reference)
    -- dimPatient.FirstName
    -- ,dimPatient.LastName
    -- ,dimPatient.City
    -- ,[State]
    -- ,dimLocation.LocationName
    -- ,dimDateServicePK
    -- ,dimPhysician.ProviderName
    -- ,dimDiagnosisCode.DiagnosisCode
    -- ,dimDiagnosisCode.DiagnosisCodeDescription
    -- ,dimCptCode.CptCode
    -- ,dimCptCode.CptDesc
    -- dimDate.[Date]
    -- dimTransaction.[Transaction]

    -- Just summing up the main financial numbers
    SUM(FactTable.GrossCharge) as Charges
    ,SUM(FactTable.Payment) as Payments -- Note: Payments might be negative in the table?
    ,SUM(FactTable.Adjustment) as Adjustments -- Adjustments might also be negative?
    ,SUM(FactTable.AR) as AR -- Accounts Receivable (Balance)
FROM FactTable
    INNER JOIN dimPatient
        ON dimPatient.dimPatientPK = FactTable.dimPatientPK
    INNER JOIN dimLocation
        ON dimLocation.dimLocationPK = FactTable.dimLocationPK
    INNER JOIN dimPhysician
        ON dimPhysician.dimPhysicianPK = FactTable.dimPhysicianPK
    INNER JOIN dimDiagnosisCode
        ON dimDiagnosisCode.dimDiagnosisCodePK = FactTable.dimDiagnosisCodePK
    INNER JOIN dimCptCode
        ON dimCptCode.dimCPTCodePK = FactTable.dimCPTCodePK
    INNER JOIN dimTransaction -- Adding transaction details (though not selected)
        ON dimTransaction.dimTransactionPK = FactTable.dimTransactionPK
    INNER JOIN dimDate -- Adding date details (using Post Date link)
        ON dimDate.dimDatePostPK = FactTable.dimDatePostPK
WHERE dimPatient.PatientNumber = '21383737'
    AND LocationName = 'Fairview General Hospital'
GROUP BY -- Since we only want the grand total for this patient/location, no GROUP BY needed if all detail fields are commented out
    -- (If you only select SUMs for the filtered data, you might not need a GROUP BY here)
    -- dimPatient.FirstName
    -- ... etc ...
    -- dimDate.[Date]
    -- dimTransaction.[Transaction]
    ; -- Removed GROUP BY fields as we are summing everything for the patient/location filter.
GO


-- == Practice Questions ==
-- Trying to answer specific questions using the data.

------ Quick Checks (Commented Out) ------
    -- Handy for peeking at the raw data sometimes.
    -- Select * from FactTable;
    -- Select * from dimPatient;
    -- ... (rest of select *) ...

-- SHOW TABLES; -- Command to list tables (might depend on the SQL tool, e.g., MySQL)
                -- In SQL Server, often use Object Explorer or `SELECT name FROM sys.tables;`


-- Question 1: How many rows in FactTable have GrossCharge > $100?
-- Approach: Simple count with a WHERE clause.
SELECT
    COUNT(*) AS CountOfRows_ChargeOver100 -- Using underscore alias, easier than spaces sometimes
FROM FactTable
WHERE FactTable.GrossCharge > 100; -- Comparing GrossCharge directly
GO

-- Question 2: How many unique patients?
-- Approach: Count distinct patient numbers from the patient dimension table.
SELECT
    COUNT(DISTINCT PatientNumber) AS UniquePatientCount
FROM dimPatient;
GO

-- Question 3: How many CPT codes per CPT grouping?
-- Approach: Group by the CPT grouping field and count distinct codes within each group.
-- SELECT * FROM dimCptCode -- (Useful check sometimes, commented out for final script)
SELECT
    CptGrouping
    ,COUNT(DISTINCT CptCode) as NumberOfCptCodes -- Alias clarifies the count
FROM dimCptCode
GROUP BY CptGrouping
ORDER BY NumberOfCptCodes DESC; -- Show the groups with most codes first
GO

-- Question 4: How many physicians submitted a Medicare claim?
-- Approach: Join FactTable, Physician, Payer tables. Filter by PayerName and count distinct providers.
SELECT
    COUNT(DISTINCT ProviderNpi) AS CountOfMedicareProviders
FROM FactTable
INNER JOIN dimPhysician
    ON dimPhysician.dimPhysicianPK = FactTable.dimPhysicianPK
INNER JOIN dimPayer
    ON dimPayer.dimPayerPK = FactTable.dimPayerPK
WHERE PayerName = 'Medicare'; -- Filter specifically for Medicare
GO
--- (Alternative query showing counts for all payers - good for comparison)
-- SELECT
--     PayerName
--     ,COUNT(DISTINCT ProviderNpi) AS CountOfProviders
-- FROM FactTable
-- INNER JOIN dimPhysician
--     ON dimPhysician.dimPhysicianPK = FactTable.dimPhysicianPK
-- INNER JOIN dimPayer
--     ON dimPayer.dimPayerPK = FactTable.dimPayerPK
-- GROUP BY PayerName;
-- GO

-- Question 5: Calculate Gross Collection Rate (GCR) per location.
-- GCR = Payments / GrossCharge
-- Approach: Group by location, sum payments and charges, then divide. Using FORMAT for percentage.
-- Note: Using -SUM(Payment) assumes payments are stored as negative numbers. Need to confirm this data convention!
SELECT
    LocationName
    -- Assuming payments are negative: -SUM(Payment) makes them positive for calculation.
    -- If payments are positive, just use SUM(Payment).
    ,FORMAT( COALESCE(-SUM(Payment), 0) / NULLIF(SUM(GrossCharge), 0), 'P1') as GCR_Percent -- Added COALESCE/NULLIF for safety (handle potential nulls/zero charges)
FROM FactTable
INNER JOIN dimLocation
    ON dimLocation.dimLocationPK = FactTable.dimLocationPK
GROUP BY LocationName
ORDER BY 2 DESC; -- Order by GCR percentage (calculated value)
GO

-- Question 6: How many CPT codes have total units > 100?
-- Approach: First, find total units per CPT code (using a subquery/derived table). Then, count how many of those codes meet the criteria.
SELECT
    COUNT(*) as CountOfCPTCodes_Over100Units
FROM (
    -- Inner query: Calculate total units for each CPT code
    SELECT
        CptCode
        ,CptDesc
        ,SUM(CPTUnits) as TotalUnits
    FROM FactTable
    INNER JOIN dimCptCode
        ON dimCptCode.dimCPTCodePK = FactTable.dimCPTCodePK
    GROUP BY
        CptCode
        ,CptDesc
    HAVING SUM(CPTUnits) > 100 -- Filter groups *after* aggregation
) as CptTotals; -- Alias for the derived table is required
GO

-- Question 7: Find the specialty with highest payments, then show monthly payments for them.
-- Approach: Two steps. First query finds the top specialty. Second query filters for that specialty and shows monthly breakdown.
-- Step 1: Find the top specialty by payment amount
SELECT TOP 1 -- Get only the highest one
    dimPhysician.ProviderSpecialty
    ,-SUM(Payment) AS TotalPayments -- Assuming payments are negative, make positive for comparison
FROM FactTable
INNER JOIN dimPhysician
    ON dimPhysician.dimPhysicianPK  = FactTable.dimPhysicianPK
GROUP by dimPhysician.ProviderSpecialty
ORDER BY TotalPayments DESC; -- Order to find the highest
GO
-- Step 2: Show monthly payments for the top specialty found above (e.g., 'Internal Medicine')
-- Note: Hardcoded 'Internal Medicine' here based on running Step 1. Could make this dynamic later if needed.
SELECT
    dimPhysician.ProviderSpecialty
    ,dimDate.MonthPeriod -- e.g., 'Jan', 'Feb'
    ,dimDate.MonthYear -- e.g., 'Jan 2025'
    ,FORMAT(-SUM(Payment),'$#,##0') AS MonthlyPayments -- Format as currency, assuming negative payments
FROM FactTable
INNER JOIN dimPhysician
    ON dimPhysician.dimPhysicianPK  = FactTable.dimPhysicianPK
INNER JOIN dimDate -- Need date dimension for month info
    ON dimDate.dimDatePostPK = FactTable.dimDatePostPK -- Using Post Date here
WHERE dimPhysician.ProviderSpecialty = 'Internal Medicine' -- Filter for the top specialty
GROUP by
    dimPhysician.ProviderSpecialty
    ,dimDate.MonthPeriod
    ,dimDate.MonthYear
ORDER BY dimDate.MonthYear, dimDate.MonthPeriod; -- Order chronologically
GO

-- Question 8: CPT Units for Diagnosis Codes starting with 'J'.
-- Approach: Filter DiagnosisCode using LIKE 'J%' and sum CPTUnits, grouped by diagnosis.
SELECT
    DiagnosisCode
    ,DiagnosisCodeGroup
    ,SUM(CPTUnits) AS TotalUnits_J_Codes
FROM FactTable
INNER JOIN dimDiagnosisCode
    ON dimDiagnosisCode.dimDiagnosisCodePK = FactTable.dimDiagnosisCodePK
WHERE dimDiagnosisCode.DiagnosisCode LIKE 'J%' -- Filter codes starting with J
GROUP BY DiagnosisCode
    ,DiagnosisCodeGroup;
GO

-- Question 9: Patient demographic report with age buckets.
-- Approach: Use CASE WHEN for age buckets, CONCAT (or +) for combining fields.
SELECT
    CONCAT(FirstName, ' ', LastName) AS PatientName -- Combine first and last names
    ,Email
    ,PatientAge
    , CASE -- Create age groups based on PatientAge
        WHEN PatientAge < 18 THEN 'Under 18'
        WHEN PatientAge BETWEEN 18 AND 65 THEN '18 - 65' -- Inclusive range
        WHEN PatientAge > 65 THEN 'Over 65'
        ELSE 'Unknown' -- Handle cases where age might be NULL or unexpected
        END AS PatientAgeBucket
    ,CONCAT(City, ', ', [State]) AS CityState -- Combine city and state
FROM dimPatient;
GO

-- Question 10: Analyze credentialing adjustments.
-- Approach: Filter by AdjustmentReason, group by location/physician to see impact.
-- Step 1: Find total credentialing write-offs per physician at a specific location ('Angelstone Community Hospital').
SELECT DISTINCT
    dimPhysician.ProviderNpi
    ,dimPhysician.ProviderName
    ,FORMAT(-SUM(Adjustment),'$#,##0') as CredentialingWriteOffAmount -- Format as currency, assuming adjustments are negative
    ,-SUM(Adjustment) as RawWriteOffAmount -- Keep raw number for sorting
FROM FactTable
INNER JOIN dimTransaction
    ON dimTransaction.dimTransactionPK = FactTable.dimTransactionPK
INNER JOIN dimLocation
    ON dimLocation.dimLocationPK = FactTable.dimLocationPK
INNER JOIN dimPhysician
    ON dimPhysician.dimPhysicianPK = FactTable.dimPhysicianPK
WHERE AdjustmentReason = 'Credentialing' -- Filter for the specific reason
  AND LocationName = 'Angelstone Community Hospital' -- Filter for the specific location mentioned
GROUP BY dimPhysician.ProviderNpi
    ,dimPhysician.ProviderName
ORDER BY RawWriteOffAmount DESC; -- Show physicians with highest write-offs first
-- Interpretation (What does this mean?): High credentialing write-offs might mean delays in getting doctors approved by payers,
-- causing claims during that period to be denied or reduced. It hits revenue.
GO

-- Question 11: Average patient age by gender for specific hospital and diagnosis.
-- Approach: Use a subquery to get unique patients matching criteria first, then calculate AVG age and COUNT.
SELECT
    PatientGender
    ,FORMAT(AVG(PatientAge),'N1') AS AveragePatientAge -- Format to one decimal place
    ,COUNT(PatientNumber) AS CountOfPatients -- Count unique patients from subquery result
    -- ,SUM(PatientAge) / COUNT(PatientNumber) AS AVGCheck -- Manual check (optional)
FROM (
    -- Inner query: Get distinct patients matching the criteria
    SELECT DISTINCT
        FactTable.PatientNumber -- Need unique patient identifier
        ,PatientGender
        ,CONVERT(DECIMAL(6,2),PatientAge) AS PatientAge -- Convert age to decimal for accurate AVG
    FROM FactTable
    INNER JOIN dimPatient
        ON dimPatient.dimPatientPK = FactTable.dimPatientPK
    INNER JOIN dimDiagnosisCode
        ON dimDiagnosisCode.dimDiagnosisCodePK = FactTable.dimDiagnosisCodePK
    INNER JOIN dimLocation
        ON dimLocation.dimLocationPK = FactTable.dimLocationPK
    WHERE LocationName = 'Big Heart Community Hospital'
      AND DiagnosisCodeDescription LIKE '%Type 2%' -- Find diagnoses containing 'Type 2'
) as FilteredPatients -- Alias for the subquery results
GROUP BY PatientGender;
GO

-- Question 12: Compare charge per unit for specific visit types.
-- Approach: Filter by CptDesc, group by CPT code/desc, calculate SUM(Charge) / SUM(Units).
SELECT
    CptCode
    ,CptDesc
    ,SUM(CPTUnits) AS TotalCptUnits
    -- Use NULLIF to avoid division by zero if CPTUnits sum is 0 for any CPT code
    ,FORMAT(SUM(GrossCharge) / NULLIF(SUM(CPTUnits), 0), 'C2') AS ChargePerUnit -- Format as currency ($#.##)
FROM FactTable
INNER JOIN dimCptCode
    ON dimCptCode.dimCPTCodePK = FactTable.dimCPTCodePK
WHERE CptDesc in ('Office/outpatient visit est' -- Using IN for multiple descriptions
                ,'Office/outpatient visit new')
GROUP BY CptCode
        ,CptDesc
ORDER BY CptCode, CptDesc;
-- Interpretation (What does this mean?): Shows the billed amount for each unit of service for these common visit types.
-- Differences might reflect complexity (e.g., 'new' vs 'established' patient visits).
GO

-- Question 13: Calculate Payment per Unit by Payer for a specific visit type.
-- Approach: Similar to Q12 but using Payments, grouping also by Payer, and filtering for 'Initial hospital care'. Handles division by zero.
SELECT
    CptCode
    ,CptDesc
    ,PayerName
    ,SUM(CPTUnits) AS TotalCptUnits
    -- Assuming payments are negative, use -SUM(Payment). Use NULLIF for safety.
    , FORMAT(-SUM(Payment) / NULLIF(SUM(CPTUnits),0), 'C0') AS PaymentsPerUnit -- Format as currency ($#)
    , -SUM(Payment) / NULLIF(SUM(CPTUnits),0) AS RawPaymentPerUnit -- Raw value for sorting
FROM FactTable
INNER JOIN dimCptCode
    ON dimCptCode.dimCPTCodePK = FactTable.dimCPTCodePK
INNER JOIN dimPayer
    ON dimPayer.dimPayerPK = FactTable.dimPayerPK
WHERE CptDesc = 'Initial hospital care'
-- AND CptCode = '99223' -- Can filter for specific CPT code if needed, commented out now
GROUP BY CptCode
        ,CptDesc
        ,PayerName
ORDER BY RawPaymentPerUnit DESC; -- Show payers with highest payment per unit first
-- Interpretation (What does this mean?): Shows how much each insurance payer actually reimburses per unit for this hospital stay code.
-- Variations highlight differences in payer contracts/fee schedules.
GO


-- Question 14: Calculate Net Collection Rate (NCR) by specialty.
-- NCR = Payments / (GrossCharges - Contractual Adjustments)
-- Approach: Use a subquery to calculate intermediate sums (GrossCharges, ContractualAdj, NetCharges, Payments, etc.) per specialty. Then calculate NCR in the outer query.
SELECT
    ProviderSpecialty
    ,FORMAT(GrossCharges, 'C0') AS GrossChargesFormatted -- Currency, no decimals
    ,FORMAT(ContractualAdj, 'C0') AS ContractualAdjFormatted -- Assuming adjustments are negative
    ,FORMAT(NetCharges, 'C0') AS NetChargesFormatted
    ,FORMAT(Payments, 'C0') AS PaymentsFormatted -- Assuming payments are negative
    ,FORMAT(OtherAdjustments, 'C0') AS OtherAdjustmentsFormatted -- Non-contractual adjustments
    ,FORMAT(NetCollectionRate, 'P0') AS NetCollectionRatePercent -- Percentage, no decimals
    ,FORMAT(AR, 'C0') AS AR_Formatted
    -- Adding some potentially insightful ratios
    ,FORMAT(AR / NULLIF(NetCharges, 0), 'P0') AS PercentOfNetChargeInAR
    ,FORMAT(-OtherAdjustments / NULLIF(NetCharges,0),'P0') AS OtherWriteOffPercentOfNetCharge
FROM (
        -- Inner query: Calculate the components needed for NCR
        SELECT
            ProviderSpecialty
            ,SUM(GrossCharge) AS GrossCharges
            -- Sum only contractual adjustments (assuming they are negative)
            ,COALESCE(SUM(CASE WHEN AdjustmentReason = 'Contractual' THEN Adjustment ELSE 0 END), 0) AS ContractualAdj
            -- Calculate Net Charges: Gross Charges + Contractual Adjustments (since adjustments are likely negative)
            , (SUM(GrossCharge) + COALESCE(SUM(CASE WHEN AdjustmentReason = 'Contractual' THEN Adjustment ELSE 0 END), 0)) AS NetCharges
            -- Assuming payments are negative, make positive for calculation
            , COALESCE(-SUM(Payment), 0) AS Payments
            -- Calculate other adjustments (total adjustments - contractual adjustments)
            , (COALESCE(SUM(Adjustment), 0) - COALESCE(SUM(CASE WHEN AdjustmentReason = 'Contractual' THEN Adjustment ELSE 0 END), 0)) AS OtherAdjustments
            , COALESCE(SUM(AR), 0) AS AR
        FROM FactTable
        INNER JOIN dimPhysician
            ON dimPhysician.dimPhysicianPK = FactTable.dimPhysicianPK
        INNER JOIN dimTransaction
            ON dimTransaction.dimTransactionPK = FactTable.dimTransactionPK
        GROUP BY ProviderSpecialty
) AS FinancialSummary -- Alias for the subquery results
-- Outer query: Calculate NCR and apply final filtering/ordering
CROSS APPLY (
    -- Calculate NCR safely using NULLIF
    SELECT Payments / NULLIF(NetCharges, 0) AS NetCollectionRate
) AS CalculatedRate
WHERE NetCharges > 25000 -- Filter for specialties with significant charges
ORDER BY NetCollectionRate ASC; -- Find the *worst* NCR first (lowest rate)
-- Interpretation (What does this mean?): Shows how effectively each specialty collects the money they expect to receive after contractual discounts.
-- Low NCR might indicate issues with billing, denials, or high non-contractual write-offs (bad debt, etc.).
-- The other percentages help see *where* the uncollected money is (still in AR or written off).
GO

-- Question 15: Summary table by location.
-- Approach: Group by location and calculate various counts and aggregates.
SELECT
    LocationName
    ,FORMAT(COUNT(DISTINCT ProviderNpi),'N0') AS CountOfPhysicians -- Format as number, no decimals
    ,FORMAT(COUNT(DISTINCT dimpatient.PatientNumber),'N0') AS CountOfPatients
    ,FORMAT(SUM(GrossCharge),'C0') AS TotalGrossCharges -- Format as currency
    ,FORMAT(SUM(GrossCharge)/NULLIF(COUNT(DISTINCT dimpatient.PatientNumber), 0), 'C0') AS AvgChargePerPatient -- Use NULLIF for safety
FROM FactTable
INNER JOIN dimLocation
    ON dimLocation.dimLocationPK = FactTable.dimLocationPK
INNER JOIN dimPhysician
    ON dimPhysician.dimPhysicianPK = FactTable.dimPhysicianPK
INNER JOIN dimPatient
    ON dimPatient.dimPatientPK = FactTable.dimPatientPK
GROUP BY
    LocationName
ORDER BY LocationName; -- Alphabetical order by location
GO