
Select * 
From SQL_Portfolio_Project..Housing_Data$

-- Standardize the Date Format

Select SaleDateNew, Convert(Date, SaleDate) 
From SQL_Portfolio_Project..Housing_Data$

Update Housing_Data$
SET SaleDate = Convert(Date, SaleDate)

ALTER TABLE Housing_Data$
Add SaleDateNew Date;

Update Housing_Data$
SET SaleDateNew = Convert(Date, SaleDate)


-- Populate Property Address

Select *
From SQL_Portfolio_Project..Housing_Data$
Order by ParcelID


Select a.ParcelID, a. PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From SQL_Portfolio_Project..Housing_Data$ a
JOIN SQL_Portfolio_Project..Housing_Data$ b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress IS NULL


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From SQL_Portfolio_Project..Housing_Data$ a
JOIN SQL_Portfolio_Project..Housing_Data$ b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress IS NULL


-- Break Address into individual Columns ( Address, City, State)

Select PropertyAddress
From SQL_Portfolio_Project..Housing_Data$

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From SQL_Portfolio_Project..Housing_Data$


Select *
From SQL_Portfolio_Project..Housing_Data$


ALTER TABLE Housing_Data$
Add PropertySplitAddress Nvarchar(255);

Update Housing_Data$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Housing_Data$
Add PropertySplitCity nvarchar(255);

Update Housing_Data$
SET PropertySplitCity = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) +1) 

Select *
From SQL_Portfolio_Project..Housing_Data$


Select OwnerAddress
From SQL_Portfolio_Project..Housing_Data$


Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From SQL_Portfolio_Project..Housing_Data$


ALTER TABLE Housing_Data$
Add OwnerSplitAddress Nvarchar(255);

Update Housing_Data$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE Housing_Data$
Add OwnerSplitCity nvarchar(255);

Update Housing_Data$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) 

ALTER TABLE Housing_Data$
Add OwnerSplitState Nvarchar(255);

Update Housing_Data$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From SQL_Portfolio_Project..Housing_Data$

-- Change Y and N in "Sold and Vacant Field

Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
From SQL_Portfolio_Project..Housing_Data$
Group by SoldAsVacant
Order by 2



Select SoldAsVacant,
  CASE When SoldAsVacant = 'Y' THEN 'YES'
	When SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
From SQL_Portfolio_Project..Housing_Data$



Update Housing_Data$
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
	When SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END


--Remove Duplicates
-- First Display the Distinct Values

Select *
From SQL_Portfolio_Project..Housing_Data$


WITH ROWNUMCTE AS(
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
From SQL_Portfolio_Project..Housing_Data$
)
SELECT *
From ROWNUMCTE
Where row_num > 1
Order by PropertyAddress

--  Then Delete the Duplicate Values

WITH ROWNUMCTE AS(
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
From SQL_Portfolio_Project..Housing_Data$
)
DELETE
From ROWNUMCTE
Where row_num > 1

-- Check to confirm that there are no duplicates

WITH ROWNUMCTE AS(
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
From SQL_Portfolio_Project..Housing_Data$
)
SELECT *
From ROWNUMCTE
Where row_num > 1
Order by PropertyAddress


-- Delete Unused Columns

Select *
From SQL_Portfolio_Project..Housing_Data$

ALTER TABLE SQL_Portfolio_Project..Housing_Data$
DROP COLUMN  OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


