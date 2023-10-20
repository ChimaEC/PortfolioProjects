--Cleaing Data in SQL Queries

Select *
From PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------------------------------------------

--Standardise Data Format

Select SaleDateConverted, CONVERT(Date, saledate)
From PortfolioProject..NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date, saledate)

--If it doesn't update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = Convert(date, SaleDate)


---------------------------------------------------------------------------------------------------------------------

--Populated Property Address data

Select *
From PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a
SET PropertyAddress =ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null




---------------------------------------------------------------------------------------------------------------------

--Breaking out Address Into Individual Columns (Address, County, State)
--First of PropertyAddress Using SUBSTR


Select PropertyAddress
from PortfolioProject..NashvilleHousing

Select 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as County
from PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitCounty nvarchar(255),
	PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitCounty = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


--Now on Owner's Address, using PARSENAME

Select OwnerAddress
From PortfolioProject..NashvilleHousing


Select 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as County,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
From PortfolioProject..NashvilleHousing


Alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255),
	OwnerSplitCounty Nvarchar(255),
	OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	OwnerSplitCounty = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



--------------------------------------------------------------------------------------------------------------------


--Change Y and N to Yes and No respectively in 'Sold as Vacant' field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group By SoldAsVacant
Order By 2



Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' then 'Yes'
		 When SoldAsVacant = 'N' then 'No'
		 ELSE SoldAsVacant
		 END
From PortfolioProject..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
						When SoldAsVacant = 'N' then 'No'
						ELSE SoldAsVacant
						END



---------------------------------------------------------------------------------------------------------------------

--Remove Duplication

WITH RowNumCTE AS(
Select*,
	ROW_NUMBER() 
	OVER(PARTITION BY ParcelID,
					  PropertyAddress,
					  SalePrice,
					  SaleDate,
					  LegalReference
		ORDER BY UniqueID
		) Row_Num

From PortfolioProject..NashvilleHousing
--Order By ParcelID
)
Select *
From RowNumCTE
where Row_Num > 1
order by PropertyAddress





---------------------------------------------------------------------------------------------------------------------


--Delete Unused Columns


ALTER Table NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

--also

ALTER Table NashvilleHousing
DROP COLUMN SaleDate