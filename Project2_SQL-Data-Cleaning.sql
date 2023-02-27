/*
Data Analyst Portfolio Project 2: SQL Data Cleaning

Hi, my name is Jd. 
This project intends to highlight the Data Cleaning queries I learned
in the Data Analyst Bootcamp of Alex Freberg aka Alex The Analyst. Skills used are as follows:
Converting Data Type, Populating NULL cells with most probable data, Breaking out Strings into Substrings, 
Standardizing Entries, Removing Duplicates and Deleting Unused Columns.

Dataset was downloaded from https://bit.ly/3m3MI9r.

Data were then imported via the Import Wizard.

Thank you!
*/

-- -------------------------------------------------------------------------------------------------------------

use portfolioproject

-- -------------------------------------------------------------------------------------------------------------

select *
from nashvillehousing

-- -------------------------------------------------------------------------------------------------------------

/* Converting Data Type: convert the SaleDate data type into a DATE */

-- 1. check the data type of SaleDate (a text/string upon checking)
show columns
from nashvillehousing 

-- 2. it's not industry best practice to change the database itself so we created a new column to store the converted sale dates
alter table nashvillehousing
add 
(
	SaleDateConverted date
) 

-- 3. update the table
update nashvillehousing
set saledateconverted = str_to_date(saledate, '%d-%b-%y')

-- -------------------------------------------------------------------------------------------------------------

/* Populating NULL cells with most probable data */

select x.parcelid, x.propertyaddress, y.parcelid, y.propertyaddress, isnull(x.propertyaddress, y.propertyaddress)
from nashvillehousing as x inner join nashvillehousing as y
	on x.parcelid = y.parcelid and x.uniqueid <> y.uniqueid
where x.propertyaddress is null


update x
set propertyaddress = isnull(x.propertyaddress, y.propertyaddress)
from nashvillehousing as x inner join nashvillehousing as y
	on a.ParcelID = b.ParcelID
	on x.parcelid = y.parcelid and x.uniqueid <> y.uniqueid
where x.propertyaddress is null

-- -------------------------------------------------------------------------------------------------------------

/* Breaking out Strings into Substrings: break out Address into Individual Columns */


-- breaking PropertyAddress into separate Address and City columns --
-- 1. check the column we're working with
select propertyaddress
from nashvillehousing

-- 2. see if we can query the substrings correctly (if yes, proceed to 3)
select substring_index(propertyaddress,',',1) as PropertySplitAddress,
       substring_index(propertyaddress,',',-1) as PropertySplitCity
from nashvillehousing

-- 3. make new columns for the substrings
alter table nashvillehousing
add 
(
	PropertySplitAddress text,
    PropertySplitCity text
)

-- 4. update the table
update nashvillehousing
set propertysplitaddress = substring_index(propertyaddress,',',1),
       propertysplitcity = substring_index(propertyaddress,',',-1)
       


-- breaking OwnerAddress into separate Address, City and State columns --
-- 1. check the column we're working with
select owneraddress
from nashvillehousing

-- 2. see if we can query the substrings correctly (if yes, proceed to 3)
select substring_index(owneraddress, ',', 1) as OwnerSplitAddress,
	   substring_index(substring_index(owneraddress,',',2), ',', -1) as OwnerSplitCity,
       substring_index(owneraddress, ',', -1) as OwnerSplitState
from nashvillehousing

-- 3. make new columns for the substrings
alter table nashvillehousing
add 
(
	OwnerSplitAddress text,
    OwnerSplitCity text,
    OwnerSplitState text
)

-- 4. update the table
update nashvillehousing
set ownersplitaddress = substring_index(owneraddress, ',', 1),
       ownersplitcity = substring_index(substring_index(owneraddress,',',2), ',', -1),
	  ownersplitstate = substring_index(owneraddress, ',', -1)

-- -------------------------------------------------------------------------------------------------------------

/* Standardizing Entries: change Y and N to Yes and No in SoldAsVacant column */

-- 1. see the entries, standardize based on the majority ('Yes' and 'No' are the majorities)
select soldasvacant, count(soldasvacant) 
from nashvillehousing
group by soldasvacant
order by count(soldasvacant) asc

-- 2. test if our query is working correctly (if yes, proceed to 3)
select soldasvacant,
case
	when soldasvacant = 'Y' then 'Yes'
    when soldasvacant = 'N' then 'No'
    else soldasvacant
end StandardizedAnswer
from nashvillehousing

-- 3. make new columns for the standardized version of the SoldAsVacant column
alter table nashvillehousing
add
(
	SoldAsVacantStandardized text
)

-- 4. update the table
update nashvillehousing
set SoldAsVacantStandardized = 
								case
										when soldasvacant = 'Y' then 'Yes'
										when soldasvacant = 'N' then 'No'
										else soldasvacant
								end

-- 5. double-check 
select soldasvacant, soldasvacantstandardized
from nashvillehousing
where soldasvacant = 'Y' or soldasvacant = 'N'

-- -------------------------------------------------------------------------------------------------------------

/* Removing Duplicates (this is not standard practice specially when dealing with raw data in the database but is included in this portfolio project nonetheless) */

-- this is the query to select the duplicated rows 
with CTE_RowNum as
(
select *, row_number() over (partition by parcelid, propertyaddress, saleprice, saledate, legalreference order by parcelid) as row_num
from nashvillehousing
)
select *
from cte_rownum
where row_num > 1


-- this is the query to DELETE the duplicated rows
with CTE_RowNum as
(
select *, row_number() over (partition by parcelid, propertyaddress, saleprice, saledate, legalreference order by parcelid) as row_num
from nashvillehousing
)
delete
from cte_rownum
where row_num > 1

-- -------------------------------------------------------------------------------------------------------------

/* Deleting Unused Columns (this is not standard practice specially when dealing with raw data in the database but is included in this portfolio project nonetheless) */

alter table nashvillehousing 
drop column propertyaddress,
drop column saledate,
drop column soldasvacant,
drop column owneraddress


select UniqueID
from nashvillehousing
