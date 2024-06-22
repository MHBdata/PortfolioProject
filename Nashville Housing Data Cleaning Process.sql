/* Course Project 1 : NashvilleHousing Dataset

This dataset includes data regarding the Nashville housing market from 2013 to 2019. The porpuse of the project is to clean the data and prepare it for analysis. */


SELECT *
FROM dbo.NashvilleHousing


-- Task 1: Change Date Format

SELECT SaleDate, 
CONVERT(Date, SaleDate)
FROM dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

-- The above formula sometimes doesn't work so I try the following one

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


-- Task 2: Populate Property Adress Data

-- Identify what properties are lacking the adress

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress is null

-- Same properties have the same ParcelID meaning they should have the same adress

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID

-- First we create a join from the table with itself so we can determine which rows are null and compare them agains other columns in the same table

SELECT NH.ParcelID,
NH.PropertyAddress,
NH2.ParcelID,
NH2.PropertyAddress,
ISNULL(NH.PropertyAddress, NH2.PropertyAddress)
FROM NashvilleHousing NH
JOIN NashvilleHousing NH2
	ON NH.ParcelID = NH2.ParcelID
	AND NH.[UniqueID ]	<> NH2.[UniqueID ]
WHERE NH.PropertyAddress is null

-- Now we replace the null values with the correct adresses

UPDATE NH
SET PropertyAddress = ISNULL(NH.PropertyAddress, NH2.PropertyAddress)
FROM NashvilleHousing NH
JOIN NashvilleHousing NH2
	ON NH.ParcelID = NH2.ParcelID
	AND NH.[UniqueID ]	<> NH2.[UniqueID ]
WHERE NH.PropertyAddress is null

	
-- Task 3: Breaking out PropertyAddress into indivdual columns (Adress, City, State)

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Street,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City

FROM NashvilleHousing

-- Add the columns

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


-- Task 4: Breaking out OwnerAddress into indivdual columns (Adress, City, State)
-- (Another way to do a SUBSTRING)

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM NashvilleHousing

-- Add the columns and values

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


-- Task 5: Change Y and N to Yes and No in "Sold as Vacand" Field

-- Check fields

SELECT SoldAsVacant,
COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

-- Prepare a case

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing

-- Update Table

UPDATE NashvilleHousing
SET SoldAsVacant =
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


-- Task 6: Remove duplicates (not a standard practise in SQL)

-- Find duplicate values
-- Create a CTE to work with

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY
				UniqueID
				) Row_num

FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE Row_num > 1
ORDER BY PropertyAddress

-- Delete duplicate rows

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY
				UniqueID
				) Row_num

FROM NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE Row_num > 1


-- Task 7: Delete unused columns (usually common for views, not for raw data)

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate
