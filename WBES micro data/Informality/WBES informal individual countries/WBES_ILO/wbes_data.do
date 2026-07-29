/*
clear all

cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\original_files"
	
** clean data for DRC
clear all
use DRCInformal-2013-data-

drop a41 a41a
gen a41 = "Making goods (Manufacturing)" if sc2a<=14
replace a41 = "Re-selling goods (Services)" if a41==""
encode a41, gen (a41a)
save DRCInformal-2013-data-, replace
	
	
clear all 
cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\original_files"

local files : dir . files "*.dta"

foreach file in `files' {
	cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\original_files"
    use `file', clear

	replace l1a=. if l1a==-9
    replace l1b=. if l1b==-9
	gen sc2 = l1a+l1b
    rename n1a n2a
    rename n1c n2c
	
	** rename variables country and city
	decode a1 , gen(country) 
    capture confirm numeric variable a3a
    if !_rc {
        decode a3a, gen(cityx)
    }
	
	* rename variable year
	capture rename sc4y a14y
        if _rc {
			capture rename Sc4y a14y
			if _rc {
				capture rename a8y a14y
			}
		}
		
	 * Check if a41a exists, if not, create it
    capture confirm variable a41a
    if _rc {
        gen a41 = ""
    
	capture confirm variable Sc2a
	if !_rc {
        replace a41 = "Re-selling goods (Services)" if Sc2a == 2 
        replace a41 = "Making goods (Manufacturing)" if Sc2a == 1 
    }
	
    capture confirm variable sect
    if !_rc {
        replace a41 = "Re-selling goods (Services)" if sect == 0
        replace a41 = "Making goods (Manufacturing)" if sect == 1
    }
	
	encode a41, gen(a41a)
    }
	
    local newname = substr("`file'", 1, length("`file'") - 4) + "renamed.dta"
	cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\renamed_files"
    save `newname', replace
}

clear all

** add data for Myanmar 
cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\original_files_other"
use Myanmar-Informal-2014-full-data

gen country="Myanmar"
gen sc2 = L1a+L1b
gen a41 = "Making goods (Manufacturing)" if sc2b=="1" | sc2b=="2" | sc2b=="3" | sc2b=="5"| sc2b=="7" | sc2b=="8" |  sc2b=="14"
replace a41 = "Re-selling goods (Services)" if a41==""
encode a41, gen (a41a)
decode a3a, gen(cityx)
rename n1a n2a
rename n1c n2c
rename sc4y a14y

cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\renamed_files"
save Myanmar-Informal-2014-full-data-renamed, replace

** add data for Afghanistan 
clear all
cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\original_files_other"
use Afghanistan_idstd_Informal

gen country="Afghanistan"
gen a41 = "Making goods (Manufacturing)" if a4b==1 | a4b==45 
replace a41 = "Re-selling goods (Services)" if a41==""
encode a41, gen (a41a)
decode a3a, gen(cityx)
rename d4 d4_old
gen d4 = d2/12
rename l1 sc2
replace n2a = n2a/12 // yearly figures, but later in the code multiplied by 12
replace n2c = n2c/12

cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\renamed_files"
save Afghanistan_idstd_Informal-renamed, replace

** add data for Cambodia (2024) 
clear all
cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\original_files_other"
use Cambodia-2024-ISBS-full-data

gen country="Cambodia"
gen a41 = "Making goods (Manufacturing)" if a41a1==1 
replace a41 = "Re-selling goods (Services)" if a41==""
encode a41, gen (a41a)

cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\renamed_files"
save Cambodia-2024-ISBS-full-data-renamed, replace

** add data for Cambodia (2013) 
clear all
cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\original_files_other"
use Cambodia-Informal-2013-full-data

gen country="Cambodia"
gen a14y=2012 // see date
gen a41 = "Making goods (Manufacturing)" if sector_frame==0 | sector_frame==1 
replace a41 = "Re-selling goods (Services)" if a41==""
encode a41, gen (a41a)
rename q145a_11 sc2
gen d4 = q78_17/12
gen n2a = q135f_43/12
gen n2c = q135d_41/12
rename w wmedian

cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\renamed_files"
save Cambodia-Informal-2013-full-data-renamed, replace

** add data for Egypt 
clear all
cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\original_files_other"
use Egypt--Arab-Rep.-2008-Informal-full-data-1.dta

gen country="Egypt"
rename hyear a14y
gen a41 = "Making goods (Manufacturing)" if indust>=50 
replace a41 = "Re-selling goods (Services)" if a41==""
encode a41, gen (a41a)
rename q57a1 sc2
gen d4 = q94c/12
gen n2c = q95e/12

cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\renamed_files"
save Egypt--Arab-Rep.-2008-Informal-full-data-1-renamed.dta, replace

** add data for Niger 
clear all
cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\original_files_other"
use Niger-2005-Informal-full-data-1.dta

replace country="Niger" if country=="niger2005"
gen a14y=2004
gen a41 = "Making goods (Manufacturing)" if sect==1 | sect==4
replace a41 = "Re-selling goods (Services)" if a41==""
encode a41, gen (a41a)
rename h21a1 sc2
gen d4 = c6a/12 if c6a>0 & c6a!=.   // c6a annual, c6b 6 months, c6c 3 months, c6d 1 month sales
replace d4 = c6b/6 if c6b>0 & c6b!=.
replace d4 = c6c/3 if c6c>0 & c6c!=.
replace d4 = c6d if c6d>0 & c6d!=.

gen n2c = j33f1 / 12 // cost of labor missing

cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\renamed_files"
save Niger-2005-Informal-full-data-1-renamed, replace

** append
clear all
cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries"

use Informal-Sector-Enterprise-Surveys-Combined-Raw-Database_October_10_2024

cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\renamed_files"

local files : dir . files "*.dta"
** append to comprehensive file
foreach file in `files' {
	append using `file', force
}

** cleaning
replace country="Peru" if cityx=="Arequipa" | cityx=="Lima"
replace country="Congo, The Democratic Republic of" if country=="DRC" |  country=="Democratic Republic of Congo" 
replace country="Burkina Faso" if country=="burkina faso  "
replace country="Cameroon" if country=="cameroon      "
replace country="Cape Verde" if country=="cape verde"
replace country="Cote d'Ivoire" if country=="Ivory Coast"
replace country="Madagascar" if country=="madagascar"
replace country="Mauritius" if country=="mauritius"
replace country="Lao, People's Democratic Republic" if country=="Lao PDR"
replace country="Tanzania, United Republic of" if country=="Tanzania"


merge m:1 country using "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\country_codes.dta"
drop if _merge==2
drop _merge

replace country_abr=CodeValue if country_abr==""

sort country a14y

keep idstd country country_abr wmedian a41a a14y cityx sc2 d4 n2a n2c n1b

cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO"

bysort country: egen survey_year = mode(a14y)
** There are two different surveys for Peru, DRC, and Cambodia 
replace survey_year=2010 if country=="Peru" & a14y==2010 
replace survey_year=2010 if country=="Congo, The Democratic Republic of" & a14y==2010 
replace survey_year=2012 if country=="Cambodia" & a14y==2012 

save informal_merged.dta, replace

** get standard WBES for 35 countries 
clear all
cd "C:\Users\nzc5436\Desktop\WBES micro data"
use New_Comprehensive_May_5_2025

gen country_name = substr(country, 1, length(country) - 4)
gen year_2       = substr(country, length(country) - 3, 4)
drop country
rename country_name country
destring year_2, gen (survey_year)
replace a14y=survey_year if a14y==. | a14y<0 | a14y>2030

replace country="Lao, People's Democratic Republic" if country=="Lao PDR"
replace country="Congo, The Democratic Republic of" if country=="DRC"
replace country="Cote d'Ivoire" if country=="Côte d'Ivoire"
replace country="Burkina Faso" if country=="BurkinaFaso"
replace country="Cape Verde" if country=="Cabo Verde"
replace country="Tanzania, United Republic of" if country=="Tanzania"

keep if country=="Afghanistan" | country=="Angola" | country=="Argentina" | country=="Bangladesh" |country=="Botswana" | country=="Burkina Faso" | country=="Cape Verde" | country=="Cambodia" | country=="Cameroon" | country=="Central African Republic" | country=="Cote d'Ivoire" | country=="Congo, The Democratic Republic of" | country=="Egypt" | country=="Ghana" | country=="Guatemala" | country=="India" | country=="Indonesia" | country=="Iraq" | country=="Kenya" | country=="Lao, People's Democratic Republic" | country=="Madagascar" | country=="Mali" | country=="Mauritius" | country=="Mozambique" | country=="Myanmar" | country=="Nepal" | country=="Niger" | country=="Peru" | country=="Rwanda" | country=="Somalia" | country=="Sudan" | country=="Tanzania, United Republic of" | country=="Zambia" | country=="Zimbabwe"

// gen year_string = substr(country, -4, 4)
// destring year_string, gen(year)

gen formal=1

rename a14y year
rename a3ax city_region
rename d2 sales
rename n2a wage_bill
rename n2b electricity
rename n2e intermediate
rename l1 employees
rename sector_MS sector
rename n7a capital

// order country year sales wage_bill electricity employees sector, a(idstd)
keep idstd country year survey_year city_region sales wage_bill capital electricity intermediate employees sector formal wt 

replace sales=. if sales<0
replace wage_bill=. if wage_bill<0
replace electricity=. if electricity<0
replace intermediate=. if intermediate<0
replace employees=. if employees<0
replace capital=. if capital<0

cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO"

save formal_abridged.dta, replace

** informal firms data
clear all
use informal_merged

// keep if country=="Bangladesh" | country=="India" | country=="Indonesia" |  country=="Lao, People's Democratic Republic" | country=="Peru" |  country=="Zambia" | country=="Zimbabwe"| country=="Argentina"| country=="Angola"| country=="Congo, The Democratic Republic of"| country=="Guatemala"| country=="Myanmar"| country=="Nepal"

// drop if country=="Peru" & a14y==2010 // using later survey only
// drop if country=="Congo, The Democratic Republic of" & a14y==2010 // using later survey only

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
keep idstd country country_abr year survey_year city sales wage_bill electricity intermediate employees sector formal wmedian

replace sales=. if sales<0
replace wage_bill=. if wage_bill<0
replace electricity=. if electricity<0
replace intermediate=. if intermediate<0
replace employees=. if employees<0

** append standard WBES
append using formal_abridged.dta

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

rename city_region city_standard
gen city_region=city
replace city_region=city_standard if city_standard!=""
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
replace weight=1 if weight==. // give a weight equal to 1 to each observation where weights are missing (informal sector in Angola, Argentina, DRC, Guatemala, Myanmar, Nepal)

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
label variable capital "Capital (cost to repurchase machinery)"
label variable electricity "Cost of electricity (last fiscal year)"
label variable intermediate "Cost of material/intermediate goods (last fiscal year)"
label variable sector "Manufacturing or services" // 39 unknown from CAR
label variable country "Country"
label variable countrycode "Country code"
label variable wmedian "Weight from WBES informal or micro"
label variable wt "Weight from WBES standard"
label variable weight "Weight (merged across WBES)"

order survey_year city city_standard city_region sector, a(year)
order employees sales wage_bill capital electricity intermediate, a(sector)
order wmedian wt weight, a(intermediate)


save ILO_informal_standard.dta, replace

tab country

* import exchange rates into STATA
clear all 
import excel "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO\WB_ts.xlsx", sheet("STATA Exchange rates") firstrow
save exchange_rates.dta, replace

*/


** Can start from here
clear all
cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO"
use ILO_informal_standard.dta

** merge exchange rates and USD deflators to obtain 2017 USD values of sales and capital
merge m:1 countrycode year using "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO\exchange_rates.dta"
drop if _merge==2
drop _merge
rename Exchangerate exchange_rate
rename USD US_defl

** transform sales and capital in 2017 USD (to be consistent with PWT)
gen sales2 = 100*sales/(exchange_rate*US_defl)
gen wage_bill2 = 100*wage_bill/(exchange_rate*US_defl)
gen capital2 = 100*capital/(exchange_rate*US_defl)
gen electricity2 = 100*electricity/(exchange_rate*US_defl)
gen intermediate2 = 100*intermediate/(exchange_rate*US_defl)

rename sales sales_curr
rename wage_bill wage_bill_curr
rename capital capital_curr
rename electricity electricity_curr
rename intermediate intermediate_curr

rename sales2 sales 
rename wage_bill2 wage_bill 
rename capital2 capital 
rename electricity2 electricity 
rename intermediate2 intermediate 

label variable sales "Sales (last fiscal year) in 2017 USD"
label variable wage_bill "Cost of employees (last fiscal year) in 2017 USD"
label variable capital "Capital (cost to repurchase machinery) in 2017 USD"
label variable electricity "Cost of electricity (last fiscal year) in 2017 USD"
label variable intermediate "Cost of material/intermediate goods (last fiscal year) in 2017 USD"

order employees sales wage_bill capital electricity intermediate, a(sector)

** change some of the survey-year to match formal and informal. In some cases the survey-year variable is incorrect, in other cases there is effectively one year difference between formal and informal surveys. However, recall that all sales values are in 2017 USD
replace survey_year=2013 if country=="Cambodia" & survey_year==2012
replace survey_year=2023 if country=="Cambodia" & survey_year==2024
replace survey_year=2009 if country=="Cote d'Ivoire" & survey_year==2008
replace survey_year=2022 if country=="Ghana" & survey_year==2023 // 1-year diff in reality
replace survey_year=2022 if country=="Iraq" & survey_year==2021 // 1-year diff in reality
replace survey_year=2018 if country=="Lao, People's Democratic Republic" & survey_year==2019 // 1-year diff in reality
replace survey_year=2009 if country=="Niger" & survey_year==2004
replace survey_year=2009 if country=="Madagascar" & survey_year==2008
replace survey_year=2009 if country=="Mauritius" & survey_year==2008
replace survey_year=2022 if country=="Peru" & survey_year==2023
replace survey_year=2019 if country=="Zambia" & survey_year==2020
replace survey_year=2016 if country=="Zimbabwe" & survey_year==2017
** countries with some time difference between formal and informal survey
replace survey_year=2013 if country=="Egypt" & survey_year==2008
replace survey_year=2022 if country=="Sudan" & survey_year==2014

** drop survey_year in which there is only formal WBES
gen has_formal0 = (formal == 0)
bysort country survey_year (has_formal0): egen any_formal0 = max(has_formal0)
keep if any_formal0 == 1

**# Bookmark #1

// egen va_ind = sum(vapw*weight) if countrycode=="IDN" & formal==1 & vapw!=.
// egen l_ind = sum(weight) if countrycode=="IDN" & formal==1  & vapw!=. 
// gen ratio = va_ind/l_ind
// sum ratio

// ** sales per worker distribution charts
// gen spw = log(sales/employees)
//
// cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO\spw_charts"
// levelsof countrycode, local(levels)
// foreach j of local levels {
// 	kdensity spw if countrycode=="`j'" & formal==1 [aw=weight], lpattern(dash)  ///
//     addplot(kdensity spw if countrycode=="`j'" & formal==0 [aw=weight]) ///
//     title(Sales Per Worker in `j') legend( label(1 "Formal") label(2 "Informal") ///
//     rows(1) ) note("") 
// 	graph export spw_`j'.png, replace 
// }
//
// ** value added per worker distribution charts
// gen va     = sales - intermediate if formal==1
// replace va = sales - electricity if formal==0
// replace va=0.1 if va<0 & va!=. 
// gen vapw = log(va/employees)
//
// cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO\vapw_charts"
// levelsof countrycode, local(levels)
// foreach j of local levels {
// 	kdensity vapw if countrycode=="`j'" & formal==1 [aw=weight], lpattern(dash)  ///
//     addplot(kdensity vapw if countrycode=="`j'" & formal==0 [aw=weight]) ///
//     title(Value Added Per Worker in `j') legend( label(1 "Formal") label(2 "Informal") ///
//     rows(1) ) note("") 
// 	graph export vapw_`j'.png, replace 
// }

// 	kdensity vapw if countrycode=="GHA" & formal==1 [aw=weight], lpattern(dash)  ///
//     addplot(kdensity vapw if countrycode=="GHA" & formal==0 [aw=weight]) ///
//     title(Value Added Per Worker India) legend( label(1 "Formal") label(2 "Informal") ///
//     rows(1) ) note("") 
//	
// cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO"

** compute value added - subtract intermediate in formal sector, electricity in informal sector
gen va     = sales - intermediate if formal==1
replace va = sales - electricity if formal==0
replace va=0.1 if va<0 & va!=. // .1 for logs reasons	
** drop observations whose weighted value added is more than 50% of the country-sector weighted value added
gen va_weighted = va * weight
egen group_total = total(va_weighted), by(country formal)
gen group_threshold = 0.50 * group_total
gen flag = va_weighted > group_threshold if va_weighted!=.
drop if flag>0 & flag!=. //10 obs
drop va_weighted group_total group_threshold flag

** Generate tables for paper
** sales
preserve
gen obs_form = !missing(employees) & !missing(sales) & formal==1
egen obs_form_count = total(obs_form), by(country survey_year)
gen obs_info = !missing(employees) & !missing(sales) & formal==0
egen obs_info_count = total(obs_info), by(country survey_year)
bysort country survey_year: egen sum_weight_form = sum(weight) if obs_form==1
bysort country survey_year: egen sum_weight_info = sum(weight) if obs_info==1
bysort country survey_year: egen sum_empl_form = sum(employees*weight) if obs_form==1
bysort country survey_year: egen sum_empl_info = sum(employees*weight) if obs_info==1
bysort country survey_year: egen sum_sales_form = sum(sales*weight) if obs_form==1
bysort country survey_year: egen sum_sales_info = sum(sales*weight) if obs_info==1
gen avg_empl_form = sum_empl_form/sum_weight_form
gen avg_empl_info = sum_empl_info/sum_weight_info
gen avg_sales_form = sum_sales_form/(sum_weight_form*1000)
gen avg_sales_info = sum_sales_info/(sum_weight_info*1000)
format avg_empl_form %15.2fc
format avg_empl_info %15.2fc
format avg_sales_form %15.1fc
format avg_sales_info %15.1fc
collapse (mean) obs_form_count avg_empl_form avg_sales_form obs_info_count avg_empl_info avg_sales_info, by(country survey_year)
drop if obs_form_count==0 | obs_info_count==0
** drop less recent if two surveys
gen tag = !missing(obs_form_count)
egen total_tag = total(tag), by(country)
bysort country (survey_year): gen to_drop = (sum(tag) == 1 & total_tag == 2)
drop if to_drop
drop tag total_tag to_drop
sort survey_year country
outsheet using "summary_sales.csv", replace comma // copy pasted in copilot to obtain Latex table
restore 


** value added
preserve
gen obs_form = !missing(employees) & !missing(va) & formal==1
egen obs_form_count = total(obs_form), by(country survey_year)
gen obs_info = !missing(employees) & !missing(va) & formal==0
egen obs_info_count = total(obs_info), by(country survey_year)
bysort country survey_year: egen sum_weight_form = sum(weight) if obs_form==1
bysort country survey_year: egen sum_weight_info = sum(weight) if obs_info==1
bysort country survey_year: egen sum_empl_form = sum(employees*weight) if obs_form==1
bysort country survey_year: egen sum_empl_info = sum(employees*weight) if obs_info==1
bysort country survey_year: egen sum_va_form = sum(va*weight) if obs_form==1
bysort country survey_year: egen sum_va_info = sum(va*weight) if obs_info==1
gen avg_empl_form = sum_empl_form/sum_weight_form
gen avg_empl_info = sum_empl_info/sum_weight_info
gen avg_va_form = sum_va_form/(sum_weight_form*1000)
gen avg_va_info = sum_va_info/(sum_weight_info*1000)
format avg_empl_form %15.2fc
format avg_empl_info %15.2fc
format avg_va_form %15.1fc
format avg_va_info %15.1fc
collapse (mean) obs_form_count avg_empl_form avg_va_form obs_info_count avg_empl_info avg_va_info, by(country survey_year)
drop if obs_form_count==0 | obs_info_count==0
** drop less recent if two surveys
gen tag = !missing(obs_form_count)
egen total_tag = total(tag), by(country)
bysort country (survey_year): gen to_drop = (sum(tag) == 1 & total_tag == 2)
drop if to_drop
drop tag total_tag to_drop
sort survey_year country
outsheet using "summary_va.csv", replace comma // copy pasted in copilot to obtain Latex table
restore


** COMPUTE Sales-per-Worker (aggregate)
bysort country survey_year: egen sum_sales_form = sum(sales*weight) if formal==1 & sales!=. & employees!=.
bysort country survey_year: egen sum_empl_form = sum(employees*weight) if formal==1 & sales!=. & employees!=.
gen sales_per_worker_form = sum_sales_form/sum_empl_form 

bysort country survey_year: egen sum_sales_info = sum(sales*weight) if formal==0 & sales!=. & employees!=.
bysort country survey_year: egen sum_empl_info = sum(employees*weight) if formal==0 & sales!=. & employees!=.
gen sales_per_worker_info = sum_sales_info/sum_empl_info 

bysort country survey_year: sum sales_per_worker_form sales_per_worker_info

gen flag1 = formal == 1 & sales != . & employees != .
egen obs_form_spw = total(flag1), by(country survey_year)

gen flag2 = formal == 0 & sales != . & employees != .
egen obs_info_spw = total(flag2), by(country survey_year)
drop flag*

** COMPUTE VA-per-Worker (aggregate)
bysort country survey_year: egen sum_va_form = sum(va*weight) if formal==1 & va!=. & employees!=.
bysort country survey_year: egen sum_empl_form2 = sum(employees*weight) if formal==1 & va!=. & employees!=.
gen va_per_worker_form = sum_va_form/sum_empl_form2 

bysort country survey_year: egen sum_va_info = sum(va*weight) if formal==0
bysort country survey_year: egen sum_empl_info2 = sum(employees*weight) if formal==0 & va!=. & employees!=.
gen va_per_worker_info = sum_va_info/sum_empl_info2 

bysort country survey_year: sum sales_per_worker_form sales_per_worker_info va_per_worker_form va_per_worker_info

gen flag1 = formal == 1 & va != . & employees != .
egen obs_form_vapw = total(flag1), by(country survey_year)

gen flag2 = formal == 0 & va != . & employees != .
egen obs_info_vapw = total(flag2), by(country survey_year)
drop flag*

***COMPUTE PRODUCTION FACTORS***
**VALUE-ADDED-BASED**

*Initialize coefficients beta_n beta_k
gen beta_n=.
gen beta_k=.
gen beta_n_2=. // in th regression without capital
gen beta_n_info=.

*Log of variables
gen ln_y=log(va)
gen ln_n=log(employees)
gen ln_wb=log(wage_bill)
gen ln_k=log(capital)

label var ln_y "Log of value added"
label var ln_k "Log of capital"
label var ln_n "Log of employees"
label var ln_wb "Log of wage bill"

* encode sector
encode sector, gen(sector2)
// encode country, gen(country2)

// drop if country=="Somalia" // no formal observaions for Somalia

* country regression with sector and year fixed effects (formal sector) 
** might have to drop country if no capital observations
levelsof country, local(countries)
foreach c of local countries {
	qui count if country == "`c'" & ln_y!=. & ln_n!=. & ln_k!=. & sector2!=. & formal==1
	if r(N)>0 {
		reg ln_y ln_n ln_k i.sector2 i.year [aw=weight] if country == "`c'" & formal==1
	    replace beta_n = _b[ln_n] if country == "`c'" & formal==1
	    replace beta_k = _b[ln_k] if country == "`c'" & formal==1
	}
}

* country regression with sector and year fixed effects (formal sector) - no capital
levelsof country, local(countries)
foreach c of local countries {
	qui count if country == "`c'" & ln_y!=. & ln_n!=. & sector2!=. & formal==1
	if r(N)>0 {
		reg ln_y ln_n i.sector2 i.year [aw=weight] if country == "`c'" & formal==1
	    replace beta_n_2 = _b[ln_n] if country == "`c'" & formal==1
	}
}


* country regression (informal sector)
levelsof country, local(countries)
foreach c of local countries {
	qui count if country == "`c'" & ln_y!=. & ln_n!=. & sector2!=. & formal==0
	if r(N)>0 {
		reg ln_y ln_n i.sector2 i.year [aw=weight] if country == "`c'" & formal==0
		replace beta_n_info = _b[ln_n] if country == "`c'" & formal==0
	}
}

* save abridged dataset
collapse (mean) beta_n beta_k beta_n_2 beta_n_info sales_per_worker_form sales_per_worker_info va_per_worker_form va_per_worker_info obs_form_spw obs_info_spw obs_form_vapw obs_info_vapw, by (country countrycode survey_year)

// drop if va_per_worker_form==. | va_per_worker_info==.

** replace negative or missing values with averages of positive coefficients
replace beta_n=. if beta_n<0 | beta_k<0 
replace beta_k=. if beta_n==. & beta_k!=. 
replace beta_n_2=. if beta_n_2<0
replace beta_n_info=. if beta_n_info<0 

local vars beta_n beta_k beta_n_2 beta_n_info
foreach var of local vars {
    sum `var', meanonly
	replace `var' = r(mean) if missing(`var')
}

gen survey_note=""
replace survey_note="Actual survey year informal is 2008" if country=="Egypt" & survey_year==2013
replace survey_note="Actual survey year formal is 2014" if country=="Sudan" & survey_year==2022

label variable beta_n "Labor Share Formal (prod. func. with Capital)"
label variable beta_k "Capital Share Formal (prod. func. with Capital)"
label variable beta_n_2 "Labor Share Formal (prod. func. without Capital)"
label variable beta_n_info "Labor Share Informal"
label variable sales_per_worker_form "Sales per Employee Formal, 2017 USD"
label variable sales_per_worker_info "Sales per Employee Informal, 2017 USD"
label variable va_per_worker_form "Value Added per Employee Formal, 2017 USD"
label variable va_per_worker_info "Value Added per Employee Informal, 2017 USD"
label variable obs_form_spw "Number of Observations Formal (Sales)"
label variable obs_info_spw "Number of Observations Informal (Sales)"
label variable obs_form_vapw "Number of Observations Formal (Value Added)"
label variable obs_info_vapw "Number of Observations Informal (Value Added)"

rename survey_year year

save wbes_stats.dta, replace








