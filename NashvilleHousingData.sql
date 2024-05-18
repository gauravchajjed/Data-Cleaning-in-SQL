/*

DATA CLEANING PROJECT

*/

SELECT * 
FROM DataCleaning..NashvilleHousing

----------------------------------------------------------------------------------------------------------------
--Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate) as SaleDate2
FROM DataCleaning..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

----------------------------------------------------------------------------------------------------------------
--Populating Property address
--Checking for null values to populate it 

SELECT PropertyAddress
FROM DataCleaning..NashvilleHousing
where PropertyAddress is null

--Populating the Property Adress based on OrderID using JOIN concept

SELECT PA.ParcelID, PA.PropertyAddress, OI.ParcelID, OI.PropertyAddress, ISNULL(PA.PropertyAddress, OI.PropertyAddress)
FROM DataCleaning..NashvilleHousing PA
JOIN DataCleaning..NashvilleHousing OI
on PA.ParcelID = OI.ParcelID
and PA.[UniqueID ] <> OI.[UniqueID ]
WHERE PA.PropertyAddress is null

--Updating the Property Address from OI to PA

UPDATE PA 
SET PropertyAddress = ISNULL(PA.PropertyAddress, OI.PropertyAddress)
FROM DataCleaning..NashvilleHousing PA
JOIN DataCleaning..NashvilleHousing OI
on PA.ParcelID = OI.ParcelID
and PA.[UniqueID ] <> OI.[UniqueID ]
WHERE PA.PropertyAddress is null

--Successfully populated the Property Address rows that had NULL value 

SELECT PA.ParcelID, PA.PropertyAddress, OI.ParcelID, OI.PropertyAddress, ISNULL(PA.PropertyAddress, OI.PropertyAddress)
FROM DataCleaning..NashvilleHousing PA
JOIN DataCleaning..NashvilleHousing OI
on PA.ParcelID = OI.ParcelID
and PA.[UniqueID ] <> OI.[UniqueID ]
WHERE PA.PropertyAddress is not null

----------------------------------------------------------------------------------------------------------------
--Breaking down the Property Address and Owner Adrress in individual Columns (Address, City, State) 

---PROPERTY ADDRESS

SELECT PropertyAddress
FROM DataCleaning..NashvilleHousing

--Using the concept of SubString and CHARINDEX 

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM DataCleaning..NashvilleHousing

--Let's add the tables required

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

--Updating the newly Added tables

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--RESULT

SELECT *
FROM DataCleaning..NashvilleHousing

---------------------------------------------------------
--OWNER ADDRESS

SELECT OwnerAddress
FROM DataCleaning..NashvilleHousing

--Using the concept of PARSENAME

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM DataCleaning..NashvilleHousing

--Let's add the tables required

ALTER TABLE NashvilleHousing
ADD OwnerStreetAddress Nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerCity Nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerState Nvarchar(255);

--Updating the newly Added tables

UPDATE NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) 

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) 

--RESULTS

SELECT *
FROM DataCleaning..NashvilleHousing

----------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant)
FROM DataCleaning..NashvilleHousing

--Now lets check the number of Y, N, Yes and No in the dataset

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM DataCleaning..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

--Using the concept of CASE statement

SELECT SoldAsVacant ,
CASE WHEN  SoldAsVacant = 'Y' THEN 'Yes'
     WHEN  SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM DataCleaning..NashvilleHousing

--Now let's Update

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN  SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN  SoldAsVacant = 'N' THEN 'No'
                   ELSE SoldAsVacant
                  END

--RESULTS

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM DataCleaning..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

----------------------------------------------------------------------------------------------------------------
--REMOVIMG DUPLICATES from the dataset
--Using CTE

WITH RowNumCTE AS( 
SELECT * ,
ROW_NUMBER() OVER (
PARTITION BY ParcelId, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID ) row_num
FROM DataCleaning..NashvilleHousing
--ORDER BY ParcelID
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY ParcelID

--DELETE the Duplicates

WITH RowNumCTE AS( 
SELECT * ,
ROW_NUMBER() OVER (
PARTITION BY ParcelId, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID ) row_num
FROM DataCleaning..NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY ParcelID

-----------------------------------------------------------------------------------------------------------------

--DELETE unused COLUMNS

SELECT * 
FROM DataCleaning..NashvilleHousing

ALTER TABLE DataCleaning..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

ALTER TABLE DataCleaning..NashvilleHousing
DROP COLUMN  

