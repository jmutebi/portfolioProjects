
use PortifolioProject;

select * from PortifolioProject..NashvilleHousing;
-----------------------------------------------------------

-----------------------------------------------------------------
--Standaise Date Format

select [SaleDate]
from PortifolioProject..NashvilleHousing;

-- convert SalesDate column to Date type 
select CONVERT(date, SaleDate) SalesDate
from PortifolioProject..NashvilleHousing;


--------------------------------------------------------------------
-- Populate Property Address Date
-- look up Property Address null values

select PropertyAddress 
from nashvilleHousing
where PropertyAddress is null;

-- Replace the null values will the correct missing data

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) as PropertyAddress_modified
from PortifolioProject..NashvilleHousing a
JOIN PortifolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL;

-- Update PropertyAddress column with the new column

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortifolioProject..NashvilleHousing a
JOIN PortifolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL;

-- Check updated changes
select PropertyAddress 
from nashvilleHousing
where PropertyAddress is null;



--------------------------------------------------------------------------
--Break Addresses into individual columns (Address, City, State)

select PropertyAddress 
from nashvilleHousing;

--Address
select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1) AS Address -- , CHARINDEX(',' , PropertyAddress)
from nashvilleHousing;

--City
select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress)) AS City
from nashvilleHousing;

-- Alter table to add new created columns
select * 
from nashvilleHousing;

Alter TABLE nashvilleHousing
ADD PropertyStreetAddress nvarchar(255),
PropertyAddressCity nvarchar (255);


update nashvilleHousing
set PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1),
	PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress));

select * 
from nashvilleHousing;

--owner address
 
select OwnerAddress
from nashvilleHousing;

-- Split Address
select PARSENAME(replace(OwnerAddress, ',', '.'), 3) as OwnerStreetAddress,
		PARSENAME(replace(OwnerAddress, ',', '.'), 2) as OwnerAddressCity,
		PARSENAME(replace(OwnerAddress, ',', '.'), 1) as OwnerAddressState
from nashvilleHousing;

-- Add new owner address columns

Alter TABLE nashvilleHousing
ADD OwnerStreetAddress nvarchar(255),
	OwnerAddressCity nvarchar (255),
	OwnerAddressState nvarchar (255);


update nashvilleHousing
set OwnerStreetAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3),
	OwnerAddressCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2),
	OwnerAddressState = PARSENAME(replace(OwnerAddress, ',', '.'), 1);

select * 
from nashvilleHousing;

-----------------------------------------------------------------------------
-- Explore other Cols

select Distinct(SoldAsVacant)
from nashvilleHousing; 

select Distinct(SoldAsVacant), COUNT(SoldAsVacant) 
from nashvilleHousing
group by SoldAsVacant
order by 1 desc;

-- Replace values

select CASE when SoldAsVacant = 'Y' then 'Yes'
			When SoldAsVacant = 'N' then 'N'
			Else SoldAsVacant
			End as SoldAsVacantEdited
from nashvilleHousing;

-- Alter table for the updated changes

Alter table nashvilleHousing
add SoldAsVacantEdited nvarchar (255)

-- Update values in the new created column
update nashvilleHousing
set SoldAsVacantEdited = CASE when SoldAsVacant = 'Y' then 'Yes'
			When SoldAsVacant = 'N' then 'N'
			Else SoldAsVacant
			End; 

-- Check changes
select *
from nashvilleHousing; 

-- Convert SalesDate to date type
select convert(date,SaleDate)
from nashvilleHousing; 

--Alter table
Alter table nashvilleHousing
add SalesDateEdited date;

-- update values
update nashvilleHousing
set SalesDateEdited = convert(date,SaleDate);

-- check changes
select *
from nashvilleHousing; 

--CTE
WITH rowNumCTE AS(
select *, ROW_NUMBER() OVER (
				PARTITION BY ParcelID,
				PropertyAddress, 
				SalePrice,
				SaleDate,
				LegalReference
				order by UniqueID
				) row_num
from nashvilleHousing
)
select * from rowNumCTE;

-- Checking for duplicates
WITH rowNumCTE AS(
select *, ROW_NUMBER() OVER (
				PARTITION BY ParcelID,
				PropertyAddress, 
				SalePrice,
				SaleDate,
				LegalReference
				order by UniqueID
				) row_num
from nashvilleHousing
)
select * from rowNumCTE
where row_num >1;

-- Remove duplicates
WITH rowNumCTE AS(
select *, ROW_NUMBER() OVER (
				PARTITION BY ParcelID,
				PropertyAddress, 
				SalePrice,
				SaleDate,
				LegalReference
				order by UniqueID
				) row_num
from nashvilleHousing
)
DELETE from rowNumCTE
where row_num >1;

--Recheck duplicate values and updated changes

WITH rowNumCTE AS(
select *, ROW_NUMBER() OVER (
				PARTITION BY ParcelID,
				PropertyAddress, 
				SalePrice,
				SaleDate,
				LegalReference
				order by UniqueID
				) row_num
from nashvilleHousing
)
select * from rowNumCTE
where row_num >1
order by SaleDate;

-----------------------------------------------------------------------------------------------------------------------
-- Drop Unnecessary columns

select *
from nashvilleHousing; 

Alter table nashvilleHousing
DROP column PropertyAddress, OwnerAddress, SoldAsVacant, SaleDate;

select *
from nashvilleHousing; 