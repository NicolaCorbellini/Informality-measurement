clear all
set more off
cd "H:\Research\ILO"
use occupation_size_finer.dta

** cleaning and setting to panel
// drop if obs_status_label=="Unreliable" // check woth and without this
drop indicator_label source_label sex_label obs_status_label note_source_label note_indicator_label note_classif_label
rename ref_area_label country
rename classif1_label occupation
rename classif2_label size_class
rename obs_value n
destring time, gen(year)
drop time
order year, a(country)

// destring time, gen(year)
// order year, a(country)
// drop time

* reduce to 3 occupation values 
encode occupation, gen(occupation2)
replace occupation="Unclassified" if occupation2==1 
replace occupation="Managers" if occupation2==2
replace occupation="Total" if occupation2==3 

tab occupation occupation2
drop occupation2

* rename size class (eliminate spaces in string)
encode size_class, gen(size_class2)
replace size_class="1p" if size_class2==1
replace size_class="10_19" if size_class2==2
replace size_class="2_4" if size_class2==3
replace size_class="20_49" if size_class2==4
replace size_class="5_9" if size_class2==5
replace size_class="50m" if size_class2==6
drop if size_class2==7 // drop if class not stated
replace size_class="Total" if size_class2==8

tab size_class size_class2
drop size_class2

* reshape wide
egen occup_size = concat(occupation size_class)
drop occupation size_class

reshape wide n, i(country year) j(occup_size) string
sort country year

* Merge with country codes
replace country="Bolivia" if country=="Bolivia (Plurinational State of)"
replace country="Congo, The Democratic Republic of" if country=="Congo, Democratic Republic of the"
replace country="Cote d'Ivoire" if substr(country,1,5) == "Côte"
replace country="Palestinian Territory, Occupied" if country=="Occupied Palestinian Territory"
replace country="Moldova, Republic of" if country=="Republic of Moldova"
replace country="Republic of Serbia" if country=="Serbia"
replace country="Venezuela" if country=="Venezuela (Bolivarian Republic of)"
replace country="Vietnam" if country=="Viet Nam"

merge m:1 country using "H:\Research\ILO\country_codes.dta"
sort _merge country
drop if _merge==2
drop _merge
rename CodeValue countrycode
order countrycode, a(country)

** Share of managers
sort country year
* replace . with 0 to avoid missing values
local varlist 1p 2_4 5_9 10_19 20_49 50m Total
foreach var of local varlist {
	replace nUnclassified`var'=0 if nUnclassified`var'==.
	
	* share of managers and other professionals excluding unclassified and armed forces
	gen share_profe_`var' = (nManagers`var')/(nTotal`var'- nUnclassified`var')
	label variable share_profe_`var' "Share of managers and professionals `var' (excluding unclassified)"
}

drop n*

save shares_profe_size_finer.dta, replace



 





