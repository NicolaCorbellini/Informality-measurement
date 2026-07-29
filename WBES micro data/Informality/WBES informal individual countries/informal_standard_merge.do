** get standard WBES for 14 countries in the comprehensive informal database (the ones with weights)
clear all
cd "H:\Research\WBES micro data"
use New_Comprehensive_July_5_2024

keep if country=="Bangladesh2022" | country=="Central African Republic2023" | country=="Ghana2023" | country=="India2022" | country=="Indonesia2023" | country=="Iraq2022" | country=="LaoPDR2018" | country=="Mozambique2018" | country=="Peru2023" | country=="Tanzania2023" | country=="Zambia2019" | country=="Zimbabwe2016" 

replace country="Lao PDR2018" if country=="LaoPDR2018"


cd "H:\Research\WBES micro data\WBES informal individual countries"

// use "Bosaso and Mogadishu-2019-full data", clear
// gen sector_MS="Manufacturing"
// replace sector_MS="Services" if a4a!=1
// decode a3a, gen(a3ax)
// rename wmedian wt
// save "Bosaso and Mogadishu-2019-full data_modified", replace

** Add data from Somalia not in original comprehensive
append using "Bosaso and Mogadishu-2019-full data_modified"

// gen year_string = substr(country, -4, 4)
// destring year_string, gen(year)
gen country_name = substr(country, 1, length(country) - 4)
drop country
rename country_name country
replace country="Somalia" if country==""

gen formal=1

rename a14y year
rename a3ax city_region
rename d2 sales
rename n2a wage_bill
rename n2b electricity
rename n2e intermediate
rename l1 employees
rename sector_MS sector

// order country year sales wage_bill electricity employees sector, a(idstd)
keep idstd country year city_region sales wage_bill electricity intermediate employees sector formal wt 

replace sales=. if sales<0
replace wage_bill=. if wage_bill<0
replace electricity=. if electricity<0
replace intermediate=. if intermediate<0
replace employees=. if employees<0

cd "H:\Research\WBES micro data\WBES informal individual countries"

save standard_WBES_abridged.dta, replace

** informal firms data
clear all
use informal_microdata_merged

drop if a14y<2014

gen sector="Services"
replace sector="Manufacturing" if a41a==1
replace sector="" if a41a==.

gen formal=0

rename a14y year
rename cityx city
rename sc2 employees
gen sales=d4*12 // since yearly figures in standard WBES
gen wage_bill=n2a*12
gen electricity=n2c*12 
gen intermediate=n1b*12 // not many observations since missing in informal comprehensive
// order country country_abr year sales wage_bill electricity employees sector wmedian, a(idstd)
keep idstd country country_abr year city sales wage_bill electricity intermediate employees sector formal wmedian

replace sales=. if sales<0
replace wage_bill=. if wage_bill<0
replace electricity=. if electricity<0
replace intermediate=. if intermediate<0
replace employees=. if employees<0

** append standard WBES
append using standard_WBES_abridged.dta
erase standard_WBES_abridged.dta

** replace missing country codes
egen temp_abr = mode(country_abr), by(country)
replace country_abr = temp_abr if missing(country_abr)
drop temp_abr

levelsof country, local(countries)
foreach c in `countries' {
    display "Country: `c'"
    tab city if country == "`c'"
    tab city_region if country == "`c'"
}

save microdata_informal_standard.dta, replace

tab country

// tab city_region if country=="Bangladesh" 
// tab city if country=="Bangladesh" 
//
// sum wt wmedian if country=="Bangladesh" 
//
// sum wt wmedian if city_region=="Dhaka MA" | city=="Dhaka MA"
// sum sales if city_region=="Dhaka MA" 
// sum sales if city=="Dhaka MA"
//
// tab city_region if country=="Central African Republic" 
// tab city if country=="Central African Republic" 


