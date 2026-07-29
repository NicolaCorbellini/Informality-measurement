clear all
set more off
cd "H:\Research\ILO"

** (i) employment by status in employment
use info_stat_empl.dta

** cleaning and setting to panel
drop if obs_status_label=="Unreliable"
drop indicator_label source_label sex_label obs_status_label note_source_label note_indicator_label note_classif_label
rename ref_area_label country
rename classif1_label empl_status
label variable empl_status "Employment status ICSE-93"
rename obs_value n_info_
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
// replace n_info_coop_workers=0 if n_info_coop_workers==.
// replace n_info_dom_workers=0 if n_info_dom_workers==.
// replace n_info_employee=0 if n_info_employee==.
// replace n_info_employer=0 if n_info_employer==.
// replace n_info_own_account=0 if n_info_own_account==.
// replace n_info_total=0 if n_info_total==.
// replace n_info_unclassified=0 if n_info_unclassified==.
//
// gen check=(n_info_total-n_info_unclassified-n_info_own_account-n_info_employer-n_info_employee-n_info_dom_workers-n_info_coop_workers)
// gen check2=(n_info_total-n_info_unclassified-n_info_own_account-n_info_employer-n_info_employee-n_info_dom_workers-n_info_coop_workers)/n_info_total
// ** some observations with more than 1% difference
// ** generally happening if some missing values

label variable n_info_employee "Informal employment, employees"
label variable n_info_employer "Informal employment, employers"
label variable n_info_own_account "Informal employment, own-account"
label variable n_info_coop_workers "Informal employment, cooperative workers"
label variable n_info_dom_workers "Informal employment, domestic workers"
label variable n_info_unclassified "Informal employment, not classified"
label variable n_info_total "Informal employment, total"

order country year n_info_employee n_info_employer n_info_own_account n_info_coop_workers n_info_dom_workers n_info_unclassified n_info_total 

save info_stat_empl_panel.dta, replace

** (ii) employment by establishment size and economic activity
clear all
use info_act_size.dta

** cleaning and setting to panel
drop if obs_status_label=="Unreliable" // it mostly drops if industry not classified or agriculture
drop indicator_label source_label sex_label obs_status_label note_source_label note_indicator_label note_classif_label
rename ref_area_label country
rename classif1_label sector
rename classif2_label size_class
rename obs_value n_info_
destring time, gen(year)
drop time
order year, a(country)

* rename the 5 sector values 
encode sector, gen(sector2)
replace sector="agri_" if sector2==1
replace sector="ind_" if sector2==2 
replace sector="nc_" if sector2==3
replace sector="serv_" if sector2==4
replace sector="tot_" if sector2==5

drop sector2

* rename the 9 size class 
encode size_class, gen(size_class2)
tab size_class2
* eliminate duplicates
* total (aggregate v. detailed)
gen dup_dummy=1 if size_class2==4 | size_class2==11
sort country year n_
quietly by country year n_: gen dup = cond(_N==1,0,_n) if dup_dummy==1
count if dup==0 & size_class2==11
** this is equal to 0, meaning that detailed-total can be dropped, since there always is aggregate-total
drop if size_class2==11
* 50+ (aggregate v. detailed)
drop dup_dummy dup
gen dup_dummy=1 if size_class2==3 | size_class2==10
sort country year n_
quietly by country year n_: gen dup = cond(_N==1,0,_n) if dup_dummy==1
count if dup==0 & size_class2==10
** this is equal to 0, meaning that detailed-50p can be dropped, since there always is aggregate-50p
drop if size_class2==10
drop dup_dummy dup

replace size_class="1_4" if size_class2==1
replace size_class="5_49" if size_class2==2
replace size_class="50m" if size_class2==3
replace size_class="total" if size_class2==4
replace size_class="1p" if size_class2==5
replace size_class="10_19" if size_class2==6
replace size_class="2_4" if size_class2==7
replace size_class="20_49" if size_class2==8
replace size_class="5_9" if size_class2==9

drop size_class2

** combine sector and size_class
egen sector_size = concat(sector size_class)
drop sector size_class

* eliminate duplicates
sort country year sector_size
quietly by country year sector_size: gen dup = cond(_N==1,0,_n) // Armenia has same data from two different sources
drop if dup>1
drop dup

* reshape wide
reshape wide n, i(country year) j(sector_size) string

// ** checks
// egen n_info_total = rowtotal(n_info_agri_total n_info_ind_total n_info_nc_total n_info_serv_total)
// gen check = (n_info_tot_total-n_info_total)/(n_info_tot_total)
// sort check
// drop n_info_total check
// ** sum across sectors is equal to total
// egen n_info_total = rowtotal(n_info_tot_1_4 n_info_tot_5_49 n_info_tot_50m)
// gen check = (n_info_tot_total-n_info_total)/(n_info_tot_total)
// sort check
// drop n_info_total check
// ** sum across size classes is NOT equal to total in many cases, because the category unclassified is not in the downloaded data. I need to compute a size-specific class when computing shares

** generate total for size class
egen n_info_tot_size = rowtotal(n_info_tot_1_4 n_info_tot_5_49 n_info_tot_50m)
label variable n_info_tot_size "Informal employment in total for size class all (excluding not classified size class)" 

// Define sectors and sizes
local sectors "agri ind serv nc tot"
local sizes "1_4 5_49 50m total 1p 2_4 5_9 10_19 20_49"

// Loop through sectors and sizes to label variables with updated sector names
foreach sector in `sectors' {
    local sector_label ""
    if "`sector'" == "agri" local sector_label "agriculture"
    if "`sector'" == "ind" local sector_label "industry"
    if "`sector'" == "serv" local sector_label "services"
    if "`sector'" == "nc" local sector_label "not classified sectors"
    if "`sector'" == "tot" local sector_label "total economy"
    
    foreach size in `sizes' {
		local size_label ""
        if "`size'" == "1_4" local size_label "1-4"
        if "`size'" == "5_49" local size_label "5-49"
		if "`size'" == "50m" local size_label "50+"
		if "`size'" == "total" local size_label "all (including not classified size class)"
		if "`size'" == "1p" local size_label "1"
		if "`size'" == "2_4" local size_label "2-4"
		if "`size'" == "5_9" local size_label "5-9"
		if "`size'" == "10_19" local size_label "10-19"
		if "`size'" == "20_49" local size_label "20-49"
        local varname n_info_`sector'_`size'
        local label "Informal employment in `sector_label' for size class `size_label'"
        label variable `varname' "`label'"
    }
}

order country year ///
      n_info_agri_1_4 n_info_agri_5_49 n_info_agri_50m n_info_agri_total n_info_agri_1p n_info_agri_2_4 n_info_agri_5_9 n_info_agri_10_19 n_info_agri_20_49 ///
      n_info_ind_1_4 n_info_ind_5_49 n_info_ind_50m n_info_ind_total n_info_ind_1p n_info_ind_2_4 n_info_ind_5_9 n_info_ind_10_19 n_info_ind_20_49 ///
      n_info_serv_1_4 n_info_serv_5_49 n_info_serv_50m n_info_serv_total n_info_serv_1p n_info_serv_2_4 n_info_serv_5_9 n_info_serv_10_19 n_info_serv_20_49 ///
      n_info_nc_1_4 n_info_nc_5_49 n_info_nc_50m n_info_nc_total n_info_nc_1p n_info_nc_2_4 n_info_nc_5_9 n_info_nc_10_19 n_info_nc_20_49 ///
      n_info_tot_1_4 n_info_tot_5_49 n_info_tot_50m n_info_tot_total n_info_tot_1p n_info_tot_2_4 n_info_tot_5_9 n_info_tot_10_19 n_info_tot_20_49
	  
save info_act_size_panel.dta, replace







 





