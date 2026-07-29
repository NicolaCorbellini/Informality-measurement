clear all 

cd "H:\Research\WBES micro data\WBES informal individual countries\micro"

local group1 Bosaso-and-Mogadishu-Micro-2019-full-data-long-form ZambiaMicro-2019-full-data-long-form
local group2 IndiaMicro-2022-full-data IraqMicro-2022-full-data Central-African-RepublicMicro-2023-full-data

// use Bosaso-and-Mogadishu-Micro-2019-full-data-long-form, clear
// use ZambiaMicro-2019-full-data-long-form, clear
// use IndiaMicro-2022-full-data, clear
// use Central-African-RepublicMicro-2023-full-data, clear
// use IraqMicro-2022-full-data, clear
// use ZimbabweMicro-2016-full-data.dta, clear
// use MozambiqueMicro-2018-full-data.dta, clear

foreach file in `group1' {
	cd "H:\Research\WBES micro data\WBES informal individual countries\micro"
	use `file'.dta, clear
	
    rename sc2 employees
    gen sales=MICd2*12
    gen wage_bill=n2a*12 
	gen intermediate=n2e2*12
    rename wweak wmedian
	gen wweak_renamed ="yes"
	rename a14y year
	decode a41a1, gen(sector)
    decode a1 , gen(country) 
	decode(city), gen(city_2)
	drop city
	rename city_2 city
// 	rename a2 city

    local newname = substr("`file'", 1, length("`file'") - 4) + "renamed.dta"
	cd "H:\Research\WBES micro data\WBES informal individual countries\micro\renamed_files"
    save `newname', replace
}

foreach file in `group2' {
	cd "H:\Research\WBES micro data\WBES informal individual countries\micro"
	use `file'.dta, clear
	
    rename ml1 employees
    gen sales=md4*12
    gen wage_bill=mn2a*12
	gen intermediate=mn2e*12
	rename a14y year
	decode a4a, gen(sector)
	
	** rename variables country and city
	decode a1 , gen(country) 
	decode a2 , gen(city) 

    local newname = substr("`file'", 1, length("`file'") - 4) + "renamed.dta"
	cd "H:\Research\WBES micro data\WBES informal individual countries\micro\renamed_files"
    save `newname', replace
}

	cd "H:\Research\WBES micro data\WBES informal individual countries\micro"
	use ZimbabweMicro-2016-full-data.dta, clear	
    rename l1 employees
    rename d2 sales
    rename n2a wage_bill
	rename n2e intermediate
	rename a14y year
	decode a4a, gen(sector)
	decode a1 , gen(country) 
	decode a3a , gen(city) 
	cd "H:\Research\WBES micro data\WBES informal individual countries\micro\renamed_files"
    save ZimbabweMicro-2016-full-renamed.dta, replace
	
	cd "H:\Research\WBES micro data\WBES informal individual countries\micro"
	use MozambiqueMicro-2018-full-data.dta, clear
    rename lm1 employees
    gen sales=dm4*12
    gen wage_bill=n2a1*12
	gen intermediate=n2e2*12 
	rename a14y year
	decode a4a, gen(sector)
	decode a1 , gen(country) 
	decode a3a , gen(city) 
	cd "H:\Research\WBES micro data\WBES informal individual countries\micro\renamed_files"
    save MozambiqueMicro-2018-full--renamed.dta, replace
	
	

clear all

cd "H:\Research\WBES micro data\WBES informal individual countries\micro\renamed_files"

local files : dir . files "*.dta"
foreach file in `files' {
	append using `file', force
}

keep idstd country city year employees sales wage_bill intermediate wmedian sector wweak_renamed

** cleaning
replace country="Central African Republic" if country=="CAR"
replace country="Somalia" if country=="Bosaso and Mogadishu"
tab country

merge m:1 country using "H:\Research\WBES micro data\WBES informal individual countries\country_codes.dta"
drop if _merge==2
drop _merge

rename CodeValue country_abr

gen micro=1
gen formal=1

gen sector2="Manufacturing"
replace sector2="" if sector=="Unknown"
replace sector2="Services" if sector=="Other Services" | sector=="Provision of services" | sector=="Re-selling goods  (Services)" | sector=="Retail" | sector=="Services" | sector=="Tourism" | sector=="Wholesale & Retail" 
drop sector
rename sector2 sector

replace sales=. if sales<0
replace wage_bill=. if wage_bill<0
replace intermediate=. if intermediate<0
replace employees=. if employees<0

cd "H:\Research\WBES micro data\WBES informal individual countries"
*merge with standard-informal
append using microdata_informal_standard.dta

order country country_abr, a(idstd)
replace micro=0 if micro==.
gen survey="Standard"
replace survey="Informal" if formal==0
replace survey="Micro" if micro==1

** match city and regions across surveys
rename city_region city_standard
gen city_region=city
replace city_region=city_standard if city_standard!=""
** Mozambique: Beira (city) = Sofala (province), Maputo
replace city_region="Maputo (Greater)" if city=="Maputo"
replace city_region="Sofala" if city=="Beira"
** India
replace city_region="Telangana" if city=="Hyderabad"
replace city_region="Rajasthan" if city=="Jaipur"
replace city_region="Kerala" if city=="Kochi"
replace city_region="Punjab" if city=="Ludhiana"
replace city_region="Maharashtra" if city=="Mumbai"
replace city_region="Madhya Pradesh" if city=="Sehore"
replace city_region="Gujarat" if city=="Surat"
replace city_region="Assam" if city=="Tezpur"
replace city_region="Uttar Pradesh" if city=="Varanasi"
** Laos
replace city_region="Champasak" if city=="Pakse"
** Ghana
replace city_region="Greater Accra-Eastern-Volta-Oti" if city=="Accra"
replace city_region="Ashanti-Bono-Bono East-Ahafo" if city=="Kumasi"
replace city_region="Northern-Savannah-North East-Upper East-Upper West" if city=="Tamale"
** Tanzania
replace city_region="Dar-es-salaam" if city=="Dar es Salaam"
** Indonesia
replace city_region="Bali" if city=="Denpasar (Bali)"
replace city_region="Special Capital Region of Jakarta" if city=="Jakarta DKI (Java)"
replace city_region="Sulawesi" if city=="Makassar (Sulawesi)"
replace city_region="North Sumatra" if city=="Medan (Sumatra)"
replace city_region="West Kalimantan" if city=="Pontianak (Kalimantan)"
replace city_region="East Java" if city=="Surabaya (Java)"
** Bangladesh
replace city_region="Chattogram" if city=="Chittagong MA"

** weights
gen weight=wmedian
replace weight=wt if wt!=.

** decode employees
gen employees2=0
replace employees2=employees2+employees
drop employees
rename employees2 employees

rename country_abr countrycode
** label variables
label variable city "City or region from WBES informal or micro"
label variable city_standard "City or region from WBES standard"
label variable city_region "City or region (merged across WBES)"
label variable employees "Number of employees (last fiscal year or last month)"
label variable sales "Sales (last fiscal year)"
label variable wage_bill "Cost of employees (last fiscal year)"
label variable electricity "Cost of electricity (last fiscal year)"
label variable intermediate "Cost of material/intermediate goods (last fiscal year)"
label variable sector "Manufacturing or services" // 39 unknown from CAR
label variable country "Country"
label variable countrycode "Country code"
label variable wmedian "Weight from WBES informal or micro"
label variable wt "Weight from WBES standard"
label variable weight "Weight (merged across WBES)"
label variable wweak_renamed "=yes if wweak used in place of wmedian"

order city city_standard city_region sector, a(year)
order employees sales wage_bill electricity intermediate, a(sector)
order wmedian wt weight wweak_renamed, a(intermediate)

sort country city_region survey

save standard-informal-micro-merge.dta, replace

 



