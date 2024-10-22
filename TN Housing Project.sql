
--Standadrdize the date formate across the data
Select *
From ProtfolioProject..NashvilleHousing

Select SaleDateConverted, CONVERT (Date, SaleDate)
From ProtfolioProject..NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted= CONVERT(Date, SaleDate)

----------------------------------------------------------------------------------------------------------------------------
--Populate the Property Address
Select *
From ProtfolioProject..NashvilleHousing
Where PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From ProtfolioProject..NashvilleHousing a
Join ProtfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress= ISNULL(a.PropertyAddress, b.PropertyAddress)
From ProtfolioProject..NashvilleHousing a
Join ProtfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

------------------------------------------------------------------------------------------------------
--Breaking out Address into seprate columns address, city,state

Select PropertyAddress
From ProtfolioProject..NashvilleHousing
--Order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From ProtfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitAddress= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select*
From ProtfolioProject..NashvilleHousing

Select OwnerAddress
From ProtfolioProject..NashvilleHousing

SELECT
PARSENAME (REPLACE (OwnerAddress,',','.'), 3)
,PARSENAME (REPLACE (OwnerAddress,',','.'), 2)
,PARSENAME (REPLACE (OwnerAddress,',','.'), 1)
From ProtfolioProject..NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitAddress= PARSENAME (REPLACE (OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity= PARSENAME (REPLACE (OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState= PARSENAME (REPLACE (OwnerAddress,',','.'), 1)



Select*
From ProtfolioProject..NashvilleHousing

------------------------------------------------------------------------------------------------------------
-- Changing Y and N to Yes and No for more standardize data in SoldAsVacant
Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
 From ProtfolioProject..NashvilleHousing
 Group by SoldAsVacant
 Order by 2

 Select SoldAsVacant
 , CASE WHEN SoldAsVacant= 'Y' THEN 'YES'
		WHEN SoldAsVacant= 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
	From ProtfolioProject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant= 'Y' THEN 'YES'
		WHEN SoldAsVacant= 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
	From ProtfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------

-- Remove Duplicates using CTE
WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID ) row_num
From ProtfolioProject..NashvilleHousing 
--ORDER BY ParcelID
)
--CTE
--DELETE
--FROM  RowNumCTE
--WHERE row_num >1

SELECT *
FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress

----------------------------------------------------------------------------------------------------------------

--Delete unused columns

SELECT *
From ProtfolioProject..NashvilleHousing 

ALTER TABLE ProtfolioProject..NashvilleHousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE ProtfolioProject..NashvilleHousing 
DROP COLUMN SaleDate
