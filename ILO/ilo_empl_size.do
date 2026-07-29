clear all
set more off
cd "H:\Research\ILO"
use ilo_empl_size.dta

/* This file contains employment statistics by status of employment and establishment size.
There are 8 status categories, 4 aggregate, 4 detailed
- 4 aggregate: total, unclassified, employee, self-employed
- 4 detailed: employer, own-account, domestic worker, cooperative worker
- I have checked the 4 detailed categories sum up to self-employed (i.e., self-employment is actually entrepreneurship). I import data including the aggregate categories since some countries are missing for detailed categories. I have also checked that total, unclassified, and employee are not missing if the detailed is available, so there is no need to import the detailed ones.

There are 9 size categories, 4 aggregate, 5 detailed
- 4 aggregate: total, 1-4, 5-49, 50+
- 4 detailed: 1, 2-4, 5-9, 10-19, 20-49
- I import data including the aggregate categories since some countries are missing for detailed categories. I have checked that total and 50+ are not missing if the detailed is available, so there is no need to import the detailed ones.
*/

** cleaning and setting to panel
drop indicator_label source_label sex_label obs_status_label note_source_label note_indicator_label note_classif_label
rename ref_area_label country
rename classif1_label status
rename classif2_label size_class
rename obs_value n
destring time, gen(year)
drop time
order year, a(country)

* rename the 8 status values 
encode status, gen(status2)
replace status="Employee" if status2==1
replace status="Self_employed" if status2==2 // self-employed is the sum of employer, own account, cooperative, and domestic, when available
replace status="Total" if status2==3
replace status="Unclassified" if status2==4
replace status="Employer" if status2==5
replace status="Own_account" if status2==6
replace status="Cooperative" if status2==7
replace status="Domestic" if status2==8

drop status2

* rename the 9 size class 
encode size_class, gen(size_class2)
replace size_class="1_4" if size_class2==1
replace size_class="5_49" if size_class2==2
replace size_class="50m" if size_class2==3
replace size_class="Total" if size_class2==4
replace size_class="1p" if size_class2==5
replace size_class="10_19" if size_class2==6
replace size_class="2_4" if size_class2==7
replace size_class="20_49" if size_class2==8
replace size_class="5_9" if size_class2==9

drop size_class2

* reshape wide
egen status_size = concat(status size_class)
drop status size_class

reshape wide n, i(country year) j(status_size) string

* Merge with country codes
replace country="Bolivia" if country=="Bolivia (Plurinational State of)"
replace country="Cape Verde" if country=="Cabo Verde"
replace country="Congo, The Democratic Republic of" if country=="Congo, Democratic Republic of the"
replace country="Cote d'Ivoire" if substr(country,1,5) == "Côte"
replace country="Iran, Islamic Republic of" if country=="Iran (Islamic Republic of)"
replace country="Lao, People's Democratic Republic" if country=="Lao People's Democratic Republic"
replace country="Palestinian Territory, Occupied" if country=="Occupied Palestinian Territory"
replace country="Korea, Republic of" if country=="Republic of Korea"
replace country="Moldova, Republic of" if country=="Republic of Moldova"
replace country="Republic of Serbia" if country=="Serbia"
replace country="Turkey" if country=="Türkiye"
replace country="Venezuela" if country=="Venezuela (Bolivarian Republic of)"
replace country="Vietnam" if country=="Viet Nam"

merge m:1 country using "H:\Research\ILO\country_codes.dta"
sort _merge country
drop if _merge==2
drop _merge
rename CodeValue countrycode
order countrycode, a(country)
sort country year

** Entrepreneurship and own-account rates by country and size
local varlist 1_4 5_49 50m Total 1p 2_4 5_9 10_19 20_49
foreach var of local varlist {
	replace nUnclassified`var'=0 if nUnclassified`var'==.
	gen entr_rate_`var' = nSelf_employed`var'/(nTotal`var' - nUnclassified`var') // entrepreneurship rate
	label variable entr_rate_`var' "Share of entrepreneurs `var' (excluding nc)"
	gen owna_rate_`var' = nOwn_account`var'/(nTotal`var' - nUnclassified`var')   // own-account rate
	label variable owna_rate_`var' "Share of own-account `var' (excluding nc)"
	// Unclassified are less than 1%
}

sum entr_rate_Total entr_rate_1_4 entr_rate_5_49 owna_rate_Total owna_rate_1_4 owna_rate_5_49

* employees shares: 1-4, 1-9, 1-19, 1-49
gen empl_1_4  = nTotal1_4/nTotalTotal
gen empl_1_9  = (nTotal1_4+nTotal5_9)/nTotalTotal
gen empl_1_19 = (nTotal1_4+nTotal5_9+nTotal10_19)/nTotalTotal
gen empl_1_49 = (nTotal1_4+nTotal5_49)/nTotalTotal

label variable empl_1_4 "Share of workers in firms with less than 5 employees"
label variable empl_1_9 "Share of workers in firms with less than 10 employees"
label variable empl_1_19 "Share of workers in firms with less than 20 employees"
label variable empl_1_49 "Share of workers in firms with less than 50 employees"

keep country countrycode year entr_rate* owna_rate* empl*
save shares_employment.dta, replace





 





