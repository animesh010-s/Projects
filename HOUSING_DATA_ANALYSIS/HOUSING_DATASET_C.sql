CREATE TABLE Housing (
    UniqueID INT,
    ParcelID VARCHAR(50),
    LandUse VARCHAR(50),
    PropertyAddress VARCHAR(255),
    SaleDate DATE,
    SalePrice DECIMAL(10, 2),
    LegalReference VARCHAR(50),
    SoldAsVacant VARCHAR(3),
    OwnerName VARCHAR(255),
    OwnerAddress VARCHAR(255),
    Acreage DECIMAL(5, 2),
    TaxDistrict VARCHAR(50),
    LandValue DECIMAL(10, 2),
    BuildingValue DECIMAL(10, 2),
    TotalValue DECIMAL(10, 2),
    YearBuilt INT,
    Bedrooms INT,
    FullBath INT,
    HalfBath INT
);

-----------------------------------------------------------------------------------------------------------------------------------
COPY Housing
FROM 'G:\data analyst\Projects\sql\Housing_data_Cleaning.csv'
DELIMITER ','
CSV HEADER;
-----------------------------------------------------------------------------------------------------------------------------------

-- \SQL QUERIES TO CLEAN HOUSING DATASET---------
SELECT*FROM HOUSING;

-------------------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format


SELECT SaleDate, SaleDate::DATE AS SaleDateConverted
FROM Housing;


UPDATE Housing
SET SaleDate = SaleDate::date;

---------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM Housing
ORDER BY ParcelID;

--Select records with null PropertyAddress and attempt to populate them from other rows

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
       COALESCE(a.PropertyAddress, b.PropertyAddress) AS PropertyAddressPopulated
FROM Housing a
JOIN Housing b
  ON a.ParcelID = b.ParcelID
  AND a.uniqueid <> b.uniqueid
WHERE a.PropertyAddress IS NULL;

--Update PropertyAddress where it is null using values from other rows

UPDATE Housing a
SET PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
FROM Housing b
WHERE a.ParcelID = b.ParcelID
  AND a.uniqueid <> b.uniqueid
  AND a.PropertyAddress IS NULL;
  
-----------------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

-- Selecting the PropertyAddress column

SELECT PropertyAddress
FROM Housing;


--Breaking out PropertyAddress into individual columns (Address, City)

SELECT 
    SUBSTRING(PropertyAddress FROM 1 FOR POSITION(',' IN PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress FROM POSITION(',' IN PropertyAddress) + 1) AS City
FROM Housing;

--Adding new columns to the Housing table

ALTER TABLE Housing
ADD COLUMN PropertySplitAddress VARCHAR(255);

ALTER TABLE Housing
ADD COLUMN PropertySplitCity VARCHAR(255);

--Updating the new columns with parsed address and city

UPDATE Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress FROM 1 FOR POSITION(',' IN PropertyAddress) - 1);

UPDATE Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress FROM POSITION(',' IN PropertyAddress) + 1);


--Selecting all columns from Housing

SELECT *
FROM Housing;


--Selecting the OwnerAddress column

SELECT OwnerAddress
FROM Housing order by OwnerAddress ;


-- Breaking out OwnerAddress into individual components

SELECT 
    SPLIT_PART(OwnerAddress, ',', 1) AS Address,
    SPLIT_PART(OwnerAddress, ',', 2) AS City,
    SPLIT_PART(OwnerAddress, ',', 3) AS State
FROM Housing;

-- Adding new columns to the Housing table

ALTER TABLE Housing
ADD COLUMN OwnerSplitAddress VARCHAR(255);

ALTER TABLE Housing
ADD COLUMN OwnerSplitCity VARCHAR(255);

ALTER TABLE Housing
ADD COLUMN OwnerSplitState VARCHAR(255);

--Updating the new columns with parsed address, city, and state

UPDATE Housing
SET OwnerSplitAddress = SPLIT_PART(OwnerAddress, ',', 1);

UPDATE Housing
SET OwnerSplitCity = SPLIT_PART(OwnerAddress, ',', 2);

UPDATE Housing
SET OwnerSplitState = SPLIT_PART(OwnerAddress, ',', 3);

---------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

-- Select distinct values of "SoldAsVacant" and count their occurrences

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM Housing
GROUP BY SoldAsVacant
ORDER BY 2;

--Select "SoldAsVacant" with a case statement to replace 'Y' with 'Yes' and 'N' with 'No'

SELECT SoldAsVacant,
       CASE
           WHEN SoldAsVacant = 'Y' THEN 'Yes'
           WHEN SoldAsVacant = 'N' THEN 'No'
           ELSE SoldAsVacant
       END AS SoldAsVacantUpdated
FROM Housing;

--Update the "SoldAsVacant" field to replace 'Y' with 'Yes' and 'N' with 'No'

UPDATE Housing
SET SoldAsVacant = CASE
                       WHEN SoldAsVacant = 'Y' THEN 'Yes'
                       WHEN SoldAsVacant = 'N' THEN 'No'
                       ELSE SoldAsVacant
                   END;

select*from housing;

-------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID,
                            PropertyAddress,
                            SalePrice,
                            SaleDate,
                            LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM Housing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;


-- Delete duplicates

WITH RowNumCTE AS (
    SELECT ctid, -- ctid is a unique identifier for rows in PostgreSQL
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID,
                            PropertyAddress,
                            SalePrice,
                            SaleDate,
                            LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM Housing
)
DELETE FROM Housing
WHERE ctid IN (
    SELECT ctid
    FROM RowNumCTE
    WHERE row_num > 1
);

-----------------------------------------------------------------------------------------------------------------------------------


-- Delete Unused Columns

ALTER TABLE Housing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;


SELECT *
FROM Housing;

































