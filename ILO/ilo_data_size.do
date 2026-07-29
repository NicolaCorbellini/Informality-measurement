clear all
set more off
cd "H:\Research\ILO"
use occupation_size.dta

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

* reduce to 6 occupation values (merge 08 and 88)
encode occupation, gen(occupation2)
replace occupation="Total" if occupation2==5 | occupation2==11
replace occupation="Managers" if occupation2==2 | occupation2==8
replace occupation="Professionals" if occupation2==3 | occupation2==9
replace occupation="Other" if occupation2==4 | occupation2==10
replace occupation="Armed" if occupation2==1 | occupation2==7
replace occupation="Unclassified" if occupation2==6 | occupation2==12

tab occupation occupation2
drop occupation2

* rename size class (eliminate spaces in string)
encode size_class, gen(size_class2)
replace size_class="1_4" if size_class2==1
replace size_class="5_49" if size_class2==2
replace size_class="50m" if size_class2==3
drop if size_class2==4 // drop if class not stated
replace size_class="Total" if size_class2==5

tab size_class size_class2
drop size_class2

* reshape wide
egen occup_size = concat(occupation size_class)
drop occupation size_class

// encode occup_size, gen(occup_size2)
// destring occupation2, gen(occupation3)
// encode size_class, gen(size_class2)

reshape wide n, i(country year) j(occup_size) string
sort country year

* Merge with country codes
replace country="Bolivia" if country=="Bolivia (Plurinational State of)"
replace country="Cape Verde" if country=="Cabo Verde"
replace country="Congo, The Democratic Republic of" if country=="Congo, Democratic Republic of the"
replace country="Cote d'Ivoire" if substr(country,1,5) == "Côte"
replace country="Iran, Islamic Republic of" if country=="Iran (Islamic Republic of)"
replace country="Lao, People's Democratic Republic" if country=="Lao People's Democratic Republic"
replace country="Palestinian Territory, Occupied" if country=="Occupied Palestinian Territory"
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

** Share of managers
sort country year
* replace . with 0 to avoid missing values
local varlist 1_4 5_49 50m Total
foreach var of local varlist {
	replace nArmed`var'=0 if nArmed`var'==.
	replace nUnclassified`var'=0 if nUnclassified`var'==.
	
	* share of managers excluding unclassified and armed forces
	gen share_man_`var' = (nManagers`var')/(nTotal`var' - nArmed`var' - nUnclassified`var')
	label variable share_man_`var' "Share of managers `var' (excluding armed and nc)"

	* share of managers and other professionals excluding unclassified and armed forces
	gen share_profe_`var' = (nManagers`var'+nProfessionals`var'+nOther`var')/(nTotal`var' - nArmed`var' - nUnclassified`var')
	label variable share_profe_`var' "Share of managers and professionals `var' (excluding armed and nc)"
}

drop n*

save shares_managers_size.dta, replace






 





