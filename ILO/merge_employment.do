clear all
set more off
cd "H:\Research\ILO"

**merge
use tot_stat_empl_panel.dta
merge 1:1 country year using "H:\Research\ILO\tot_act_size_panel.dta"
drop _merge
merge 1:1 country year using "H:\Research\ILO\info_stat_empl_panel.dta"
drop _merge
merge 1:1 country year using "H:\Research\ILO\info_act_size_panel.dta"
drop _merge

** compute shares
** Define occupations
local occups "employee employer own_account coop_workers dom_workers unclassified total"
// Loop through occupations and label variables
foreach occup in `occups' {
    local occup_label ""
    if "`occup'" == "employee" local occup_label "employees"
    if "`occup'" == "employer" local occup_label "employers"
    if "`occup'" == "own_account" local occup_label "own-account"
    if "`occup'" == "coop_workers" local occup_label "cooperative workers"
	if "`occup'" == "dom_workers" local occup_label "domestic workers"
    if "`occup'" == "unclassified" local occup_label "not classified"
    if "`occup'" == "total" local occup_label "total"

	gen info_share_`occup' = n_info_`occup' / n_`occup' 
    local label "Share informal employment, `occup_label'"
    label variable info_share_`occup' "`label'"
    }

// Define sectors and sizes
local sectors "agri ind serv nc tot"
local sizes "1_4 5_49 50m total 1p 2_4 5_9 10_19 20_49"
// Loop through sectors and sizes and label variables
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
		gen info_share_`sector'_`size' = n_info_`sector'_`size' / n_`sector'_`size'
        local label "Share informal employment in `sector_label' for size class `size_label'"
        label variable info_share_`sector'_`size' "`label'"
    }
}

gen info_share_tot_size = n_info_tot_size / n_tot_size  
label variable info_share_tot_size "Share of informal employment in total for size class all (excluding not classified size class)" // excluding not classified size class
// sum across size classes is NOT equal to total in many cases, because the category unclassified is not in the downloaded data.

save merged_employment_informal.dta, replace


// local sectors "agri ind serv nc tot"
// local sizes "1_4 5_49 50m total 1p 2_4 5_9 10_19 20_49"
// // Loop through sectors and sizes and label variables
// foreach sector in `sectors' {
//     local sector_label ""
//     if "`sector'" == "agri" local sector_label "agriculture"
//     if "`sector'" == "ind" local sector_label "industry"
//     if "`sector'" == "serv" local sector_label "services"
//     if "`sector'" == "nc" local sector_label "not classified sectors"
//     if "`sector'" == "tot" local sector_label "total economy"
//    
//     foreach size in `sizes' {
// 		local size_label ""
//         if "`size'" == "1_4" local size_label "1-4"
//         if "`size'" == "5_49" local size_label "5-49"
// 		if "`size'" == "50m" local size_label "50+"
// 		if "`size'" == "total" local size_label "all (including not classified size class)"
// 		if "`size'" == "1p" local size_label "1"
// 		if "`size'" == "2_4" local size_label "2-4"
// 		if "`size'" == "5_9" local size_label "5-9"
// 		if "`size'" == "10_19" local size_label "10-19"
// 		if "`size'" == "20_49" local size_label "20-49"
// 		count if info_share_`sector'_`size' > 1 & info_share_`sector'_`size'!=. 
//     }
// }
// A few observations with more informal than total employees (?)

** merge with 
drop n_*

count
count if info_share_employee!=.
count if info_share_employer!=.
count if info_share_own_account!=.
count if info_share_total!=.
count if info_share_ind_total!=.
count if info_share_serv_total!=.
count if info_share_tot_total!=.
count if info_share_tot_size!=.
 

* Merge with country codes
replace country="Bolivia" if country=="Bolivia (Plurinational State of)"
replace country="Cape Verde" if country=="Cabo Verde"
replace country="Congo, The Democratic Republic of" if country=="Congo, Democratic Republic of the"
replace country="Cote d'Ivoire" if country=="Côte d'Ivoire"
replace country="Swaziland" if country=="Eswatini"
replace country="Falkland Islands (Malvinas)" if country=="Falkland Islands, Malvinas"
replace country="Hong Kong" if country=="Hong Kong, China"
replace country="Iran, Islamic Republic of" if country=="Iran (Islamic Republic of)"
replace country="Lao, People's Democratic Republic" if country=="Lao People's Democratic Republic"
replace country="Kazakstan" if country=="Kazakhstan"
replace country="Macao" if country=="Macao, China"
replace country="Micronesia, Federated States of" if country=="Micronesia (Federated States of)"
replace country="Palestinian Territory, Occupied" if country=="Occupied Palestinian Territory"
replace country="Korea, Republic of" if country=="Republic of Korea"
replace country="Moldova, Republic of" if country=="Republic of Moldova"
replace country="Reunion" if country=="Réunion"
replace country="Russia Federation" if country=="Russian Federation"
replace country="Republic of Serbia" if country=="Serbia"
replace country="Saint Kitts & Nevis" if country=="Saint Kitts and Nevis"
replace country="Taiwan, Province of China" if country=="Taiwan, China"
replace country="Turkey" if country=="Türkiye"
replace country="United Kingdom" if country=="United Kingdom of Great Britain and Northern Ireland"
replace country="United States" if country=="United States of America"
replace country="Venezuela" if country=="Venezuela (Bolivarian Republic of)"
replace country="Vietnam" if country=="Viet Nam"

// replace country="" if country=="Netherlands Antilles"

merge m:1 country using "H:\Research\ILO\country_codes.dta"
sort _merge country
drop if _merge==2
drop _merge
rename CodeValue countrycode
order countrycode, a(country)

* merge with average firm size
* the underlying data are in H:\Research\Tax Evasion\GEM Survey
merge 1:1 countrycode year using "H:\Research\ILO\gem_ts.dta"
drop if _merge==2
drop _merge
* merge with TFP and GDP per capita
merge 1:1 countrycode year using "H:\Research\ts_tfp.dta"
drop if _merge==2
drop _merge
sort country year

gen cgdpo_pc = cgdpo/pop
gen rgdpo_pc =  rgdpo/pop 
gen rgdpna_pc = rgdpna/pop

drop cgdpo rgdpo rgdpna

* label variables
label variable countrycode "Country code"
label variable country "Country"
label variable ctfp "TFP level, USA value = 1 in all years" // To compare across countries in each year 
label variable rtfpna "TFP index, 2005 value = 1 for all countries" //Growth of  productivity over time in each country
label variable rgdpo_pc "Real GDP per cap, constant prices across countries given year, millions 2005 US$" // Productive capacity across countries in each year
label variable cgdpo_pc "Real GDP per cap, constant prices across countries over time, millions 2005 US$" // Productive capacity across countries and across years
label variable rgdpna_pc "Real GDP per cap, constant national prices, millions of 2005 US$" // Growth of GDP over time in each country 
label variable pop "Population (million)"

scatter info_share_total ctfp if year==2010
scatter info_share_tot_size ctfp if year==2010






