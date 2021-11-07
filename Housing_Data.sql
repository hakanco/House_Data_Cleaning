-- Data Cleaning in sql queries using MySQL 

select *
from nashville_housing_data;

-- Standardize Data Format
select SaleDate, str_to_date(SaleDate, '%M %d, %Y')
from nashville_housing_data;

update nashville_housing_data
set SaleDate = str_to_date(SaleDate, '%M %d, %Y');

-- Creating new columns from PropertyAddress such as address and city

select substring_index(PropertyAddress, ',', 1) as Address, 
substr(PropertyAddress, position(',' in PropertyAddress)+2, length(PropertyAddress)) as city
from nashville_housing_data;

--
alter table nashville_housing_data
add property_split_address varchar(255);

update nashville_housing_data
set property_split_address = substring_index(PropertyAddress, ',', 1);

alter table nashville_housing_data
add property_split_city varchar(255);

update nashville_housing_data
set property_split_city = substr(PropertyAddress, position(',' in PropertyAddress)+2, length(PropertyAddress));

-- Creating new columns from OwnerAddress such as address, city and state
select substring_index(OwnerAddress, ',', 1) as owner_address_1,
substring_index(substring_index(OwnerAddress, ',', 2), ',', -1) as owner_city,
substring_index(substring_index(OwnerAddress, ',', 3), ',', -1) as owner_state
from nashville_housing_data;

--
alter table nashville_housing_data
add owner_address_1 varchar(255);

update nashville_housing_data
set owner_address_1 = substring_index(OwnerAddress, ',', 1);

alter table nashville_housing_data
add owner_city varchar(255);

update nashville_housing_data
set owner_city = substring_index(substring_index(OwnerAddress, ',', 2), ',', -1);

alter table nashville_housing_data
add owner_state varchar(255);

update nashville_housing_data
set owner_state = substring_index(substring_index(OwnerAddress, ',', 3), ',', -1);

-- Changing Y and N to Yes and No in SoldAsVacant column

select distinct(SoldAsVacant), count(SoldAsVacant) as numberofSoldAsVacant
from nashville_housing_data
group by SoldAsVacant
order by numberofSoldAsVacant desc;

select SoldAsVacant,
case when SoldAsVacant = "Y" then "Yes"
     when SoldAsVacant = "N" then "No"
     else SoldAsVacant
     end
from nashville_housing_data;

update nashville_housing_data
set SoldAsVacant = case when SoldAsVacant = "Y" then "Yes"
     when SoldAsVacant = "N" then "No"
     else SoldAsVacant
     end;

-- The following query finds duplicates and removes them using common table expressions

with cte as (select *,
  row_number() over (
    partition by ParcelID, PropertyAddress, SalePrice,
				 SaleDate, LegalReference order by UniqueID) as row_num
from nashville_housing_data)

delete
from cte
where cte.row_num > 1;

-- Deleting Unnecessary Columns

alter table nashville_housing_data
drop column OwnerAddress, 
drop column TaxDistrict, 
drop column PropertyAddress, 
drop column castedsaledate;

select * 
from nashville_housing_data;






