/* 
Cleaning Data In SQL

Project about Nashville Housing
*/ 



Select * 
From PortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date; 

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate Property Address data
Select *
From PortfolioProject..NashvilleHousing
where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is NULL

Update a
SET PropertyAddress = ISNULL( a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is NULL

--   Breaking out Address into Individual Columns(Address, City, State)
Select PropertyAddress 
From PortfolioProject..NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))  as Address
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255); 

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255); 

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 



select OwnerAddress
from PortfolioProject..NashvilleHousing

Select
PARSENAME (REPLACE(OwnerAddress,',','.') ,3),
PARSENAME (REPLACE(OwnerAddress,',','.') ,2),
PARSENAME (REPLACE(OwnerAddress,',','.') ,1)
from PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add  OwnerSplitAddress Nvarchar(255); 

Update NashvilleHousing
SET OwnerSplitAddress  = PARSENAME (REPLACE(OwnerAddress,',','.') ,3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255); 

Update NashvilleHousing
SET  OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress,',','.') ,2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255); 

Update NashvilleHousing
SET  OwnerSplitState = PARSENAME (REPLACE(OwnerAddress,',','.') ,1)



-- Change Y and N to Yes and NO i "Sold As Vacant"

Select Distinct(SoldAsVacant),Count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant,
CASE when SoldAsVacant = 'Y' THEN 'YES'
     when SoldAsVacant = 'N' THEN 'NO'
	 else SoldAsVacant
	 END
from PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'YES'
     when SoldAsVacant = 'N' THEN 'NO'
	 else SoldAsVacant
	 END

--Remove duplicates

WITH RowNumCTE AS( 
select * , 
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
                PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				ORDER BY UniqueID)
				row_num
				
from PortfolioProject..NashvilleHousing
)
--select * 
DELETE
from RowNumCTE
where row_num >1


-- Delete Unused Columns

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

