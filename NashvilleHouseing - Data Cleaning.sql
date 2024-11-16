select *
from PorfolioProject.dbo.NashvilleHousing


--standardize date format
select SaleDateConverted, CONVERT(date, SaleDate)
from PorfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date, SaleDate)

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = CONVERT(Date, SaleDate)


--populate property address data

select *
from PorfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID



select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PorfolioProject.dbo.NashvilleHousing a
join PorfolioProject.dbo.NashvilleHousing b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PorfolioProject.dbo.NashvilleHousing a
join PorfolioProject.dbo.NashvilleHousing b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- breaking out address into individual columns

select PropertyAddress
from PorfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID


select
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1) as address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as address
from PorfolioProject.dbo.NashvilleHousing


alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


select *
from PorfolioProject.dbo.NashvilleHousing


select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PorfolioProject.dbo.NashvilleHousing




alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState Nvarchar(255);

update NashvilleHousing
set OwnerSplitState= PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



select *
from PorfolioProject.dbo.NashvilleHousing


--Change y and n to Yes and No


select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PorfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2



select SoldAsVacant
,	case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from PorfolioProject.dbo.NashvilleHousing



update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end



--remove duplicates


with RowNumCTE as(
select *,
	ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
	             ) row_num
from PorfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress



--delete unused columns

select *
from PorfolioProject.dbo.NashvilleHousing


alter table PorfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PorfolioProject.dbo.NashvilleHousing
drop column SaleDate