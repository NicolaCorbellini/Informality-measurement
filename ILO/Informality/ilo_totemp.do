clear all
set more off
cd "H:\Research\ILO\Informality"

** (i) employment by status in employment
use tot_stat_empl.dta

** cleaning and setting to panel
drop if obs_status_label=="Unreliable"
// drop if ref_area_label=="Albania" & source_label!="LFS - Labour Force Survey"
drop indicator_label source_label sex_label obs_status_label note_source_label note_indicator_label note_classif_label
rename ref_area_label country
rename classif1_label empl_status
label variable empl_status "Employment status ICSE-93"
rename obs_value n_
destring time, gen(year)
drop time
order year, a(country)

* rename the 8 status values 
encode empl_status, gen(empl_status2)
replace empl_status="employee" if empl_status2==1 
replace empl_status="employer" if empl_status2==2 
replace empl_status="own_account" if empl_status2==3 
replace empl_status="coop_workers" if empl_status2==4 
replace empl_status="dom_workers" if empl_status2==5 
replace empl_status="unclassified" if empl_status2==6 
replace empl_status="total" if empl_status2==7

drop empl_status2

* eliminate duplicates
sort country year empl_status
quietly by country year empl_status: gen dup = cond(_N==1,0,_n) // Albania has same data from two different sources
drop if dup>1
drop dup

* reshape wide
reshape wide n, i(country year) j(empl_status) string

// ** check total is sum of the other categories
// replace n_coop_workers=0 if n_coop_workers==.
// replace n_dom_workers=0 if n_dom_workers==.
// replace n_employee=0 if n_employee==.
// replace n_employer=0 if n_employer==.
// replace n_own_account=0 if n_own_account==.
// replace n_total=0 if n_total==.
// replace n_unclassified=0 if n_unclassified==.
//
// gen check=(n_total-n_unclassified-n_own_account-n_employer-n_employee-n_dom_workers-n_coop_workers)
// gen check2=(n_total-n_unclassified-n_own_account-n_employer-n_employee-n_dom_workers-n_coop_workers)/n_total
// gsort - check2 
** very few observations with more than 1% difference
** if greater than 1% than missing values besides total

label variable n_employee "Employment, employees"
label variable n_employer "Employment, employers"
label variable n_own_account "Employment, own-account"
label variable n_coop_workers "Employment, cooperative workers"
label variable n_dom_workers "Employment, domestic workers"
label variable n_unclassified "Employment, not classified"
label variable n_total "Employment, total"

order country year n_employee n_employer n_own_account n_coop_workers n_dom_workers n_unclassified n_total 

gen sh_employee=n_employee/n_total
gen sh_employer=n_employer/n_total
gen sh_own_account=n_own_account/n_total
gen sh_coop_workers=n_coop_workers/n_total
gen sh_dom_workers=n_dom_workers/n_total
gen sh_unclassified=n_unclassified/n_total

sum sh_employee sh_employer sh_own_account sh_coop_workers sh_dom_workers sh_unclassified

save tot_stat_empl_panel.dta, replace

