clear all
set more off
cd "H:\Research\ILO\Informality"

** (i) employment by status in employment
use form_stat_emp.dta

** cleaning and setting to panel
drop if obs_status_label=="Unreliable"
drop indicator_label source_label sex_label obs_status_label note_source_label note_indicator_label classif2_label
rename ref_area_label country
rename classif1_label nature_job
label variable nature_job "Nature of job: formal or informal"
rename obs_value n_
destring time, gen(year)
drop time
order year, a(country)

* rename the 8 status values 
encode nature_job, gen(nature_job2)
replace nature_job="formal" if nature_job2==1 
replace nature_job="informal" if nature_job2==2 
replace nature_job="total_2" if nature_job2==3 // 2 because n_total is already in another dataset

drop nature_job2

* eliminate duplicates
sort country year nature_job
quietly by country year nature_job: gen dup = cond(_N==1,0,_n) // Armenia has same data from two different sources
drop if dup>1
drop dup

* reshape wide
reshape wide n_, i(country year) j(nature_job) string

label variable n_total "Employment, total"
label variable n_formal "Employment, formal jobs"
label variable n_informal "Employment, informal jobs"


order country year n_formal n_informal n_total

save form_stat_empl_panel.dta, replace

