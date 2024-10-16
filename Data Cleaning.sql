/*

CLEANING DATA IN SQL QUERIES

*/

SELECT *
FROM PortfolioProject..NashvilleHousing


-- POPULATE NULL PROPERTY ADDRESS
-- ALTERS RECORDS WITH NO PROPERTY ADRESS WITH CORRECT ONE BASED OFF RECORDS WITH IDENTICAL PARCEL ID

SELECT orig.ParcelID, orig.PropertyAddress, dup.ParcelID, dup.PropertyAddress, ISNULL(orig.PropertyAddress, dup.PropertyAddress)
FROM PortfolioProject..NashvilleHousing orig
JOIN PortfolioProject..NashvilleHousing dup
    ON orig.ParcelID = dup.ParcelID
    AND orig.UniqueID <> dup.UniqueID
WHERE orig.PropertyAddress IS NULL

UPDATE orig
SET PropertyAddress = ISNULL(orig.PropertyAddress, dup.PropertyAddress)
FROM PortfolioProject..NashvilleHousing orig
JOIN PortfolioProject..NashvilleHousing dup
    ON orig.ParcelID = dup.ParcelID
    AND orig.UniqueID <> dup.UniqueID
WHERE orig.PropertyAddress IS NULL



-- SPLITTING ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City 
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitAddress NVARCHAR(255)

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)



ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitCity NVARCHAR(255)

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject..NashvilleHousing 



ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)



ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitCity NVARCHAR(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)



ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitState NVARCHAR(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)





-- CHANGING 'Y' AND 'N' TO 'Yes' AND 'No' IN "SOLD AS VACANT" FIELD

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
CASE
    WHEN SoldAsVacant = 'Y' THEN 'YES'
    WHEN SoldAsVacant = 'N' THEN 'NO'
    ELSE  SoldAsVacant
END 
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' THEN 'YES'
    WHEN SoldAsVacant = 'N' THEN 'NO'
    ELSE  SoldAsVacant
END 




-- REMOVING DUPLICATES

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress





-- REMOVING UNUSED COLUMNS

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate