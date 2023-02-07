/* 

Cleaning Data in SQL Queries

*/



Select *
From syy..NashvilleHousing


---Standardized the Date Format
Select SaleDateConverted
From syy..NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(date,SaleDate)

--------------------------------------------------------------------------------------

---- Populate Property Address Data

Select *
From syy..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

--- if for the same ParcelID, one is not associated with a PropertyAddress, fille the emptry 
--- entry with the address of the other one since they will be the same


Select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From syy..NashvilleHousing a 
Join syy..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ] -- First you want join the table on itself based on ParcelID column
Where a.PropertyAddress is null	       -- So that you can Filled the null with values you have
--And b.PropertyAddress is not null    


Update a -- use alias when use join statement in update
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From syy..NashvilleHousing a 
Join syy..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ] 
Where a.PropertyAddress is null	       
--And b.PropertyAddress is not null  

-- check if we still have nulls
Select ParcelID,PropertyAddress
From syy..NashvilleHousing
Where PropertyAddress is null


--- Breaking out Address into Individual Columns(Address, City, State)

Select PropertyAddress
From syy..NashvilleHousing

--- I want to split the address and city in the current ProperyAddress column


--- query data based on newly created columns
Select 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address2
From syy..NashvilleHousing

Select A.Address, A.Address2
From
(Select 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address2
From syy..NashvilleHousing A
) A
Where A.Address2 like '%GOODLETTSVILLE%'

Select 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address2
From syy..NashvilleHousing
Where SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) like '%GOODLETTSVILLE%'

--- I need to add these two new columns to oringal tables

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

--Check the new added columns
Select *
From syy..NashvilleHousing


Select OwnerAddress
From syy..NashvilleHousing



--ANOTHER simpler method
SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From syy..NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select OwnerSplitAddress,OwnerSplitCity,OwnerSplitState
From syy..NashvilleHousing


---Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant) as n
From syy..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END
From syy..NashvilleHousing

---then we update

Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END


---Remove Duplicates
--- need cte

With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
				UniqueID
						) row_num
From syy..NashvilleHousing
)

Select * --USE DELETE TO DELTE EVERYTHING
From RowNumCTE
Where row_num > 1



---Remove unused columns

Select *
From syy..NashvilleHousing

ALTER TABLE syy..NashvilleHousing
DROP COLUMN TaxDistrict, PropertyAddress,OwnerAddress

ALTER TABLE syy..NashvilleHousing
DROP COLUMN SaleDate