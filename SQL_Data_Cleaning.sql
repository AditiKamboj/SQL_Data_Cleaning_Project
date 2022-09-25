/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[NashvilleHousing]

  ---------------------------------------------------
  Select * FROM PortfolioProject.dbo.NashvilleHousing
  -------------------Standardize date format---------
  Select SaleDateConverted
  From PortfolioProject.dbo.NashvilleHousing

  Update NashvilleHousing
  SET SaleDate = CONVERT(Date, SaleDate)

  ALTER Table NashvilleHousing 
  Add SaleDateConverted Date

  Update NashvilleHousing
  SET SaleDateConverted = Convert (Date, SaleDate)

  --------------Populate Property Address Data---------------
Select * From PortfolioProject.dbo.NashvilleHousing
order by ParcelID
 
 Select a.ParcelID, a.PropertyAddress, b.ParcelID, ISNULL(a.PropertyAddress, b.PropertyAddress)
 From PortfolioProject.dbo.NashvilleHousing a
 JOIN PortfolioProject.dbo.NashvilleHousing b
 On a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
 where a.PropertyAddress is null

Select * From PortfolioProject.dbo.NashvilleHousing

Update a
SET PropertyAddress =ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
 JOIN PortfolioProject.dbo.NashvilleHousing b
 On a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
 where a.PropertyAddress is null


 ----------------Breaking out Address into Individual Columns (Address, City, State)--------------
Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

ALTER Table PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress NVarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER Table PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity NVarchar(255)

Update NashvilleHousing
SET PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
From NashvilleHousing
Select
PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
From NashvilleHousing
Select
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From NashvilleHousing


ALTER Table PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress NVarchar(255)

ALTER Table PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity NVarchar(255)

ALTER Table PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState NVarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

Update NashvilleHousing
SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

Update NashvilleHousing
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

-------------Change Y and N to Yes and No in SoldAsVacant field---------------
Select distinct(SoldAsVacant), count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
ORDER BY 2

Select SoldAsVacant, CASE When SoldAsVacant ='Y' THEN 'Yes'
When SoldAsVacant ='N' THEN 'No'
Else
SoldAsVacant
END as SoldAsVacantUpdated
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant= CASE When SoldAsVacant ='Y' THEN 'Yes'
When SoldAsVacant ='N' THEN 'No'
Else
SoldAsVacant
END 
----------------------Remove Duplicates using CTE---------------
With RowNumCTE as(
Select *,  ROW_NUMBER() Over (
Partition  by ParcelID,
PropertyAddress,
SaleDate,
SalePrice,
LegalReference
ORDER BY UniqueID) 
row_num
From NashvilleHousing
)
Delete from RowNumCTE
where row_num>1

With RowNumCTE as(
Select *,  ROW_NUMBER() Over (
Partition  by ParcelID,
PropertyAddress,
SaleDate,
SalePrice,
LegalReference
ORDER BY UniqueID) 
row_num
From NashvilleHousing
)
Select *  from RowNumCTE
where row_num>1