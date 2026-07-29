clear all
set more off
cd "H:\Research\ILO\Informality"

** (i) employment by status in employment
use out_stat_empl.dta

** cleaning and setting to panel
drop if obs_status_label=="Unreliable"
drop indicator_label source_label sex_label obs_status_label note_source_label note_indicator_label note_classif_label
rename ref_area_label country
rename classif1_label empl_status
label variable empl_status "Employment status ICSE-93"
rename obs_value n_out_form_
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
quietly by country year empl_status: gen dup = cond(_N==1,0,_n) // Armenia has same data from two different sources
drop if dup>1
drop dup

* reshape wide
reshape wide n, i(country year) j(empl_status) string

// ** check total is sum of the other categories
// replace n_out_form_coop_workers=0 if n_out_form_coop_workers==.
// replace n_out_form_dom_workers=0 if n_out_form_dom_workers==.
// replace n_out_form_employee=0 if n_out_form_employee==.
// replace n_out_form_employer=0 if n_out_form_employer==.
// replace n_out_form_own_account=0 if n_out_form_own_account==.
// replace n_out_form_total=0 if n_out_form_total==.
// replace n_out_form_unclassified=0 if n_out_form_unclassified==.
//
// gen check=(n_out_form_total-n_out_form_unclassified-n_out_form_own_account-n_out_form_employer-n_out_form_employee-n_out_form_dom_workers-n_out_form_coop_workers)
// gen check2=(n_out_form_total-n_out_form_unclassified-n_out_form_own_account-n_out_form_employer-n_out_form_employee-n_out_form_dom_workers-n_out_form_coop_workers)/n_out_form_total
// ** some observations with more than 1% difference
// ** generally happening if some missing values

label variable n_out_form_employee "Employment outside formal sector, employees"
label variable n_out_form_employer "Employment outside formal sector, employers"
label variable n_out_form_own_account "Employment outside formal sector, own-account"
label variable n_out_form_coop_workers "Employment outside formal sector, cooperative workers"
label variable n_out_form_dom_workers "Employment outside formal sector, domestic workers"
label variable n_out_form_unclassified "Employment outside formal sector, not classified"
label variable n_out_form_total "Employment outside formal sector, total"

order country year n_out_form_employee n_out_form_employer n_out_form_own_account n_out_form_coop_workers n_out_form_dom_workers n_out_form_unclassified n_out_form_total 

// gen sh_employee=n_out_form_employee/n_out_form_total
// gen sh_employer=n_out_form_employer/n_out_form_total
// gen sh_own_account=n_out_form_own_account/n_out_form_total
// gen sh_coop_workers=n_out_form_coop_workers/n_out_form_total
// gen sh_dom_workers=n_out_form_dom_workers/n_out_form_total
// gen sh_unclassified=n_out_form_unclassified/n_out_form_total
//
// sum sh_employee sh_employer sh_own_account sh_coop_workers sh_dom_workers sh_unclassified


save out_stat_empl_panel.dta, replace
