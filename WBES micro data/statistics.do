
/*
clear all
cd "H:\Research\WBES micro data"
use New_Comprehensive_July_5_2024

** firm status: dummies
replace b1=. if b1<=0 | b1>=7
gen pub_list=(b1==1)   // public listed 
gen pub_unlist=(b1==2) // public unlisted 
gen sole_prop=(b1==3)  // sole proprietorship 
gen part=(b1==4)       // partnership
gen lim_part=(b1==5)   // limited partnership
gen stat_other=(b1==6) // other status

** size dummies
gen small=(size==1) // notice no missing in size
gen medium=(size==2)
gen large=(size==3)

** firm status: shares
bysort country: egen sum_weight = sum(wt) if wt != . & b1 != .

bysort country: egen sum_pub_list = sum(wt*pub_list)  if wt != . & b1 != .
bysort country: egen sum_pub_unlist = sum(wt*pub_unlist) if wt!=. & b1!=.
bysort country: egen sum_sole_prop = sum(wt*sole_prop) if wt!=. & b1!=.
bysort country: egen sum_part = sum(wt*part) if wt!=. & b1!=.
bysort country: egen sum_lim_part = sum(wt*lim_part) if wt!=. & b1!=.
bysort country: egen sum_stat_other = sum(wt*stat_other) if wt!=. & b1!=.

bysort country: gen sh_pub_list_all = sum_pub_list / sum_weight  if wt != . & b1 != .
bysort country: gen sh_pub_unlist_all = sum_pub_unlist / sum_weight if wt!=. & b1!=.
bysort country: gen sh_sole_prop_all = sum_sole_prop / sum_weight if wt!=. & b1!=.
bysort country: gen sh_part_all = sum_part / sum_weight if wt!=. & b1!=.
bysort country: gen sh_lim_part_all = sum_lim_part / sum_weight if wt!=. & b1!=.
bysort country: gen sh_stat_other_all = sum_stat_other / sum_weight if wt!=. & b1!=.

drop sum_* 

// gen check = sh_pub_list+sh_pub_unlist+sh_sole_prop+sh_part+sh_lim_part+sh_stat_other
// sum check, det

** firm status: shares by size: small
bysort country: egen sum_weight = sum(wt*small) if wt != . & b1 != .

bysort country: egen sum_pub_list_small = sum(wt*pub_list*small) if wt!=. & b1!=.
bysort country: egen sum_pub_unlist_small = sum(wt*pub_unlist*small) if wt!=. & b1!=.
bysort country: egen sum_sole_prop_small = sum(wt*sole_prop*small) if wt!=. & b1!=.
bysort country: egen sum_part_small = sum(wt*part*small) if wt!=. & b1!=.
bysort country: egen sum_lim_part_small = sum(wt*lim_part*small) if wt!=. & b1!=.
bysort country: egen sum_stat_other_small = sum(wt*stat_other*small) if wt!=. & b1!=.

bysort country: gen sh_pub_list_small = sum_pub_list_small / sum_weight  if wt != . & b1 !=.
bysort country: gen sh_pub_unlist_small = sum_pub_unlist_small / sum_weight if wt!=. & b1!=.
bysort country: gen sh_sole_prop_small = sum_sole_prop_small / sum_weight if wt!=. & b1!=.
bysort country: gen sh_part_small = sum_part_small / sum_weight if wt!=. & b1!=.
bysort country: gen sh_lim_part_small = sum_lim_part_small / sum_weight if wt!=. & b1!=.
bysort country: gen sh_stat_other_small = sum_stat_other_small / sum_weight if wt!=. & b1!=.

// gen check_small = sh_pub_list_small+sh_pub_unlist_small+sh_sole_prop_small+sh_part_small+sh_lim_part_small+sh_stat_other_small
// sum check_small, det

drop sum_* 

** firm status: shares by size: medium
bysort country: egen sum_weight = sum(wt*medium) if wt != . & b1 != .

bysort country: egen sum_pub_list_med = sum(wt*pub_list*medium) if wt!=. & b1!=.
bysort country: egen sum_pub_unlist_med = sum(wt*pub_unlist*medium) if wt!=. & b1!=.
bysort country: egen sum_sole_prop_med = sum(wt*sole_prop*medium) if wt!=. & b1!=.
bysort country: egen sum_part_med = sum(wt*part*medium) if wt!=. & b1!=.
bysort country: egen sum_lim_part_med = sum(wt*lim_part*medium) if wt!=. & b1!=.
bysort country: egen sum_stat_other_med = sum(wt*stat_other*medium) if wt!=. & b1!=.

bysort country: gen sh_pub_list_med = sum_pub_list_med / sum_weight  if wt != . & b1 !=.
bysort country: gen sh_pub_unlist_med = sum_pub_unlist_med / sum_weight if wt!=. & b1!=.
bysort country: gen sh_sole_prop_med = sum_sole_prop_med / sum_weight if wt!=. & b1!=.
bysort country: gen sh_part_med = sum_part_med / sum_weight if wt!=. & b1!=.
bysort country: gen sh_lim_part_med = sum_lim_part_med / sum_weight if wt!=. & b1!=.
bysort country: gen sh_stat_other_med = sum_stat_other_med / sum_weight if wt!=. & b1!=.
// gen check_med = sh_pub_list_med+sh_pub_unlist_med+sh_sole_prop_med+sh_part_med+sh_lim_part_med+sh_stat_other_med
// sum check_med, det

drop sum_* 

** tax administration costs
** time spent on tax compliance
tab j35a // time spent on tax compliance (hours per year)
tab j35b // time spent on tax compliance (hours per month)
replace j35a=. if j35a==-9
replace j35b=. if j35b==-9
replace j35a=j35b*12 if j35b!=.

bysort country: egen sum_weight = sum(wt) if wt!=. & j35a!=.
bysort country: egen time_tax_sum = sum(wt*j35a) if wt!=. & j35a!=.
bysort country: gen time_tax_all = time_tax_sum/sum_weight if wt!=. & j35a!=.

bysort country: egen sum_weight_small = sum(wt*small) if wt!=. & j35a!=.
bysort country: egen time_tax_sum_small = sum(wt*j35a*small) if wt!=. & j35a!=.
bysort country: gen time_tax_small = time_tax_sum_small/sum_weight_small if wt!=. & j35a!=.

bysort country: egen sum_weight_med = sum(wt*medium) if wt!=. & j35a!=.
bysort country: egen time_tax_sum_med = sum(wt*j35a*medium) if wt!=. & j35a!=.
bysort country: gen time_tax_med = time_tax_sum_med/sum_weight_med if wt!=. & j35a!=.

drop sum_* 

** weeks to get a VAT refund
replace j39=. if j39==-9 | j39==-5

bysort country: egen sum_weight = sum(wt) if wt!=. & j39!=.
bysort country: egen weeks_vat_sum = sum(wt*j39) if wt!=. & j39!=.
bysort country: gen weeks_vat_all = weeks_vat_sum/sum_weight if wt!=. & j39!=.

bysort country: egen sum_weight_small = sum(wt*small) if wt!=. & j39!=.
bysort country: egen weeks_vat_sum_small = sum(wt*j39*small) if wt!=. & j39!=.
bysort country: gen weeks_vat_small = weeks_vat_sum_small/sum_weight_small if wt!=. & j39!=.

bysort country: egen sum_weight_med = sum(wt*medium) if wt!=. & j39!=.
bysort country: egen weeks_vat_sum_med = sum(wt*j39*medium) if wt!=. & j39!=.
bysort country: gen weeks_vat_med = weeks_vat_sum_med/sum_weight_med if wt!=. & j39!=.

drop sum_*

** meetings with tax officials (extensive margin)
replace j3=. if j3<1
replace j3=0 if j3==2 // transform the variable into a dummy

bysort country: egen sum_weight = sum(wt) if wt!=. & j3!=.
bysort country: egen insp_ext_sum = sum(wt*j3) if wt!=. & j3!=.
bysort country: gen insp_ext_all = insp_ext_sum/sum_weight if wt!=. & j3!=.

bysort country: egen sum_weight_small = sum(wt*small) if wt!=. & j3!=.
bysort country: egen insp_ext_sum_small = sum(wt*j3*small) if wt!=. & j3!=.
bysort country: gen insp_ext_small = insp_ext_sum_small/sum_weight_small if wt!=. & j3!=.

bysort country: egen sum_weight_med = sum(wt*medium) if wt!=. & j3!=.
bysort country: egen insp_ext_sum_med = sum(wt*j3*medium) if wt!=. & j3!=.
bysort country: gen insp_ext_med = insp_ext_sum_med/sum_weight_med if wt!=. & j3!=.

drop sum_*

** meetings with tax officials (intensive margin)
replace j4=. if j4<1

bysort country: egen sum_weight = sum(wt) if wt!=. & j4!=.
bysort country: egen insp_int_sum = sum(wt*j4) if wt!=. & j4!=.
bysort country: gen insp_int_all = insp_int_sum/sum_weight if wt!=. & j4!=.

bysort country: egen sum_weight_small = sum(wt*small) if wt!=. & j4!=.
bysort country: egen insp_int_sum_small = sum(wt*j4*small) if wt!=. & j4!=.
bysort country: gen insp_int_small = insp_int_sum_small/sum_weight_small if wt!=. & j4!=.

bysort country: egen sum_weight_med = sum(wt*medium) if wt!=. & j4!=.
bysort country: egen insp_int_sum_med = sum(wt*j4*medium) if wt!=. & j4!=.
bysort country: gen insp_int_med = insp_int_sum_med/sum_weight_med if wt!=. & j4!=.

drop sum_*

** firms identifying tax administration as major obstacle
gen tax_adm_obst=(j30b>=3 & j30b!=.)
replace tax_adm_obst=. if j30b<0

bysort country: egen sum_weight = sum(wt) if wt!=. & tax_adm_obst!=.
bysort country: egen tax_adm_obst_sum = sum(wt*tax_adm_obst) if wt!=. & tax_adm_obst!=.
bysort country: gen sh_tax_adm_obst_all = tax_adm_obst_sum/sum_weight if wt!=. & tax_adm_obst!=.

bysort country: egen sum_weight_small = sum(wt*small) if wt!=. & tax_adm_obst!=.
bysort country: egen tax_adm_obst_sum_small = sum(wt*tax_adm_obst*small) if wt!=. & tax_adm_obst!=.
bysort country: gen sh_tax_adm_obst_small = tax_adm_obst_sum_small/sum_weight_small if wt!=. & tax_adm_obst!=.

bysort country: egen sum_weight_med = sum(wt*medium) if wt!=. & tax_adm_obst!=.
bysort country: egen tax_adm_obst_sum_med = sum(wt*tax_adm_obst*medium) if wt!=. & tax_adm_obst!=.
bysort country: gen sh_tax_adm_obst_med = tax_adm_obst_sum_med/sum_weight_med if wt!=. & tax_adm_obst!=.

drop sum_*

** tax rates
** social security and employment-based taxes as share of cost of labor
replace n2a2=. if n2a2<0
gen payroll_tax = n2a2/n2a
replace payroll_tax=. if payroll_tax>1

bysort country: egen sum_weight = sum(wt) if wt!=. & payroll_tax!=.
bysort country: egen ss_tax_sum = sum(wt*payroll_tax) if wt!=. & payroll_tax!=.
bysort country: gen sh_ss_tax_all = ss_tax_sum/sum_weight if wt!=. & payroll_tax!=.

bysort country: egen sum_weight_small = sum(wt*small) if wt!=. & payroll_tax!=.
bysort country: egen ss_tax_sum_small = sum(wt*payroll_tax*small) if wt!=. & payroll_tax!=.
bysort country: gen sh_ss_tax_small = ss_tax_sum_small/sum_weight_small if wt!=. & payroll_tax!=.

bysort country: egen sum_weight_med = sum(wt*medium) if wt!=. & payroll_tax!=.
bysort country: egen ss_tax_sum_med = sum(wt*payroll_tax*medium) if wt!=. & payroll_tax!=.
bysort country: gen sh_ss_tax_med = ss_tax_sum_med/sum_weight_med if wt!=. & payroll_tax!=.

drop sum_*

** income-based taxes as share of gross profit
replace n11=. if n11<0

bysort country: egen sum_weight = sum(wt) if wt!=. & n11!=.
bysort country: egen inc_tax_sum = sum(wt*n11) if wt!=. & n11!=.
bysort country: gen sh_inc_tax_all = inc_tax_sum/sum_weight if wt!=. & n11!=.

bysort country: egen sum_weight_small = sum(wt*small) if wt!=. & n11!=.
bysort country: egen inc_tax_sum_small = sum(wt*n11*small) if wt!=. & n11!=.
bysort country: gen sh_inc_tax_small = inc_tax_sum_small/sum_weight_small if wt!=. & n11!=.

bysort country: egen sum_weight_med = sum(wt*medium) if wt!=. & n11!=.
bysort country: egen inc_tax_sum_med = sum(wt*n11*medium) if wt!=. & n11!=.
bysort country: gen sh_inc_tax_med = inc_tax_sum_med/sum_weight_med if wt!=. & n11!=.

drop sum_*

** firms identifying tax rates as major obstacle
gen tax_rate_obst=(j30a>=3 & j30a!=.)
replace tax_rate_obst=. if j30a<0

bysort country: egen sum_weight = sum(wt) if wt!=. & tax_rate_obst!=.
bysort country: egen tax_rate_obst_sum = sum(wt*tax_rate_obst) if wt!=. & tax_rate_obst!=.
bysort country: gen sh_tax_rate_obst_all = tax_rate_obst_sum/sum_weight if wt!=. & tax_rate_obst!=.

bysort country: egen sum_weight_small = sum(wt*small) if wt!=. & tax_rate_obst!=.
bysort country: egen tax_rate_obst_sum_small = sum(wt*tax_rate_obst*small) if wt!=. & tax_rate_obst!=.
bysort country: gen sh_tax_rate_obst_small = tax_rate_obst_sum_small/sum_weight_small if wt!=. & tax_rate_obst!=.

bysort country: egen sum_weight_med = sum(wt*medium) if wt!=. & tax_rate_obst!=.
bysort country: egen tax_rate_obst_sum_med = sum(wt*tax_rate_obst*medium) if wt!=. & tax_rate_obst!=.
bysort country: gen sh_tax_rate_obst_med = tax_rate_obst_sum_med/sum_weight_med if wt!=. & tax_rate_obst!=.

drop sum_*

** competition against informal sector
replace e11=. if e11<1 | e11>2
replace e11=0 if e11==2 // transform the variable into a dummy

bysort country: egen sum_weight = sum(wt) if wt!=. & e11!=.
bysort country: egen info_comp_sum = sum(wt*e11) if wt!=. & e11!=.
bysort country: gen sh_info_comp_all = info_comp_sum/sum_weight if wt!=. & e11!=.

bysort country: egen sum_weight_small = sum(wt*small) if wt!=. & e11!=.
bysort country: egen info_comp_sum_small = sum(wt*e11*small) if wt!=. & e11!=.
bysort country: gen sh_info_comp_small = info_comp_sum_small/sum_weight_small if wt!=. & e11!=.

bysort country: egen sum_weight_med = sum(wt*medium) if wt!=. & e11!=.
bysort country: egen info_comp_sum_med = sum(wt*e11*medium) if wt!=. & e11!=.
bysort country: gen sh_info_comp_med = info_comp_sum_med/sum_weight_med if wt!=. & e11!=.

drop sum_*


** firms informal sector competition as major obstacle
gen info_comp_obst=(e30>=3 & e30!=. & e30<5)
replace info_comp_obst=. if e30<0

bysort country: egen sum_weight = sum(wt) if wt!=. & info_comp_obst!=.
bysort country: egen info_comp_obst_sum = sum(wt*info_comp_obst) if wt!=. & info_comp_obst!=.
bysort country: gen sh_info_comp_obst_all = info_comp_obst_sum/sum_weight if wt!=. & info_comp_obst!=.

bysort country: egen sum_weight_small = sum(wt*small) if wt!=. & info_comp_obst!=.
bysort country: egen info_comp_obst_sum_small = sum(wt*info_comp_obst*small) if wt!=. & info_comp_obst!=.
bysort country: gen sh_info_comp_obst_small = info_comp_obst_sum_small/sum_weight_small if wt!=. & info_comp_obst!=.

bysort country: egen sum_weight_med = sum(wt*medium) if wt!=. & info_comp_obst!=.
bysort country: egen info_comp_obst_sum_med = sum(wt*info_comp_obst*medium) if wt!=. & info_comp_obst!=.
bysort country: gen sh_info_comp_obst_med = info_comp_obst_sum_med/sum_weight_med if wt!=. & info_comp_obst!=.

drop sum_*

local varlist sh_pub_list_all sh_pub_unlist_all sh_sole_prop_all sh_part_all sh_lim_part_all sh_stat_other_all sh_pub_list_small sh_pub_unlist_small sh_sole_prop_small sh_part_small sh_lim_part_small sh_stat_other_small sh_pub_list_med sh_pub_unlist_med sh_sole_prop_med sh_part_med sh_lim_part_med sh_stat_other_med insp_ext_all insp_ext_small insp_ext_med insp_int_all insp_int_small insp_int_med sh_tax_adm_obst_all sh_tax_adm_obst_small sh_tax_adm_obst_med sh_tax_rate_obst_all sh_tax_rate_obst_small sh_tax_rate_obst_med sh_info_comp_all sh_info_comp_small sh_info_comp_med sh_info_comp_obst_all sh_info_comp_obst_small sh_info_comp_obst_med time_tax_all time_tax_small time_tax_med weeks_vat_all weeks_vat_small weeks_vat_med sh_ss_tax_all sh_ss_tax_small sh_ss_tax_med sh_inc_tax_all sh_inc_tax_small sh_inc_tax_med

keep country region `varlist'

** get rid of missing values
foreach var in `varlist' {
	bysort country: egen mean_value = mode(`var')
	bysort country: replace `var' = mean_value if missing(`var')
	drop mean_value
}

foreach var in `varlist' {
	count if `var'!=.
// 	dis r()
}

bysort country: keep if _n == 1

** split country and year
rename country country_year
gen country = substr(country_year, 1, length(country_year) - 4)
gen year = substr(country_year, -4, 4)
destring year, replace
order country year, b(country_year)

** merge with country codes
* (for merging purposes) change country names to make them equal across files
replace country="Antigua and Barbuda"               if country=="Antiguaandbarbuda"
replace country="Burkina Faso"                      if country=="BurkinaFaso"
replace country="Cape Verde"                        if country=="CapeVerde"
replace country="Congo, The Democratic Republic of" if country=="DRC"
replace country="Cote d'Ivoire"                     if country=="Côte d'Ivoire"
replace country="Dominican Republic"                if country=="DominicanRepublic"
replace country="El Salvador"                       if country=="ElSalvador"
replace country="Swaziland"                         if country=="Eswatini"
replace country="Guinea-Bissau"                     if country=="GuineaBissau"
replace country="Hong Kong"                         if country=="Hong Kong SAR China"
replace country="Kazakstan"                         if country=="Kazakhstan"
replace country="Kyrgyzstan"                        if country=="Kyrgyz Republic"
replace country="Lao, People's Democratic Republic" if country=="LaoPDR"
replace country="Micronesia, Federated States of"   if country=="Micronesia"
replace country="Moldova, Republic of"              if country=="Moldova"
replace country="Papua New Guinea"                  if country=="PapuaNewGuinea"
replace country="Russia Federation"                 if country=="Russia"
replace country="Republic of Serbia"                if country=="Serbia"
replace country="Slovakia"                          if country=="Slovak Republic"
replace country="South Africa"                      if country=="SouthAfrica"
replace country="South Sudan"                       if country=="Southsudan"
replace country="Sri Lanka"                         if country=="SriLanka"
replace country="Saint Kitts & Nevis"               if country=="StKittsandNevis"
replace country="Saint Lucia"                       if country=="StLucia"
replace country="Saint Vincent and the Grenadines"  if country=="StVincentandGrenadines"
replace country="Tanzania, United Republic of"      if country=="Tanzania"
replace country="Trinidad and Tobago"               if country=="TrinidadandTobago"
replace country="Turkey"                            if country=="Türkiye"
replace country="Vietnam"                           if country=="Viet Nam"
replace country="Palestinian Territory, Occupied"   if country=="West Bank And Gaza"
// replace country=""       if country==""


merge m:1 country using "H:\Research\WBES micro data\country_codes.dta"
sort _merge country year
drop if _merge==2
drop _merge
rename CodeValue countrycode
order countrycode, a(country)

** label variables
local varlist sh_pub_list sh_pub_unlist sh_sole_prop sh_part sh_lim_part sh_stat_other insp_ext  insp_int sh_tax_adm_obst sh_tax_rate_obst sh_info_comp sh_info_comp_obst time_tax  weeks_vat sh_ss_tax sh_inc_tax 

local sizes "all small med"

foreach var in `varlist' {
    local var_label ""
    if "`var'" == "sh_pub_list" local var_label "Share of companies with traded shares"
    if "`var'" == "sh_pub_unlist" local var_label "Share of companies with non-traded shares"
	if "`var'" == "sh_sole_prop" local var_label "Share of sole-proprietorships"
	if "`var'" == "sh_part" local var_label "Share of partnerships"
	if "`var'" == "sh_lim_part" local var_label "Share of limited partnerships"
	if "`var'" == "sh_stat_other" local var_label "Share of other legal status of firms"
	if "`var'" == "insp_ext" local var_label "Share of firms inspected by tax officials"
	if "`var'" == "insp_int" local var_label "Average number of tax inspections among inspected"
	if "`var'" == "sh_tax_adm_obst" local var_label "Share of firms mentioning tax administration as major or severe obstacle"
	if "`var'" == "sh_tax_rate_obst" local var_label "Share of firms mentioning tax rates as major or severe obstacle"
	if "`var'" == "sh_info_comp" local var_label "Share of firms competing against informal firms"
	if "`var'" == "sh_info_comp_obst" local var_label "Share of firms mentioning competition from informal sector as major or severe obstacle"
	if "`var'" == "time_tax" local var_label "Average annual hours spent on tax compliance"
	if "`var'" == "weeks_vat" local var_label "Average weeks to receive VAT refund"
	if "`var'" == "sh_ss_tax" local var_label "Average social security and employment-based tax rates"
	if "`var'" == "sh_inc_tax" local var_label "Average income-based tax rates"
    
    foreach size in `sizes' {
		local size_label ""
        if "`size'" == "all" local size_label "all firms"
		if "`size'" == "small" local size_label "1-19 employees"
		if "`size'" == "med" local size_label "20-99 employees"
        local varname `var'_`size'
        local label "`var_label', `size_label'"
        label variable `varname' "`label'"
    }
}

save country_averages.dta, replace
*/

clear all
cd "H:\Research\WBES micro data"
use country_averages.dta

* merge with average firm size
* the underlying data are in H:\Research\Tax Evasion\GEM Survey
merge 1:1 countrycode year using "H:\Research\ILO\gem_ts.dta"
drop if _merge==2
drop _merge
* merge with TFP and GDP per capita
merge 1:1 countrycode year using ts_tfp.dta
drop if _merge==2
drop _merge
sort country year

gen cgdpo_pc = log(cgdpo/pop)
gen rgdpo_pc =  log(rgdpo/pop) 
gen rgdpna_pc = log(rgdpna/pop)

drop cgdpo rgdpo rgdpna

* label variables
label variable countrycode "Country code"
label variable country "Country"
label variable ctfp "TFP level, USA value = 1 in all years, 2018 value if year>2018" // To compare across countries in each year 
label variable rtfpna "TFP index, 2005 value = 1 for all countries, 2018 value if year>2018" //Growth of  productivity over time in each country
label variable rgdpo_pc "Log of real GDP per cap, constant prices across countries given year, millions 2005 US$, 2018 value if year>2018" // Productive capacity across countries in each year
label variable cgdpo_pc "Log of real GDP per cap, constant prices across countries over time, millions 2005 US$, 2018 value if year>2018" // Productive capacity across countries and across years
label variable rgdpna_pc "Log of real GDP per cap, constant national prices, millions of 2005 US$, 2018 value if year>2018" // Growth of GDP over time in each country 
label variable pop "Population (million), 2018 value if year>2018"

** correlation charts
** time spent on tax administration
** all 
twoway scatter time_tax_all rgdpo_pc, mlabel(countrycode) color(blue) || lfit time_tax_all rgdpo_pc,  leg(off) scheme(s1mono) lc(red) ytitle("`: variable label time_tax_all'")
** small
twoway scatter time_tax_small rgdpo_pc, mlabel(countrycode) color(blue) || lfit time_tax_small rgdpo_pc,  leg(off) scheme(s1mono) lc(red) ytitle("`: variable label time_tax_small'")
// positive correlation

** share of inspected firms
** all 
twoway scatter insp_ext_all rgdpo_pc, mlabel(countrycode) color(blue) || lfit insp_ext_all rgdpo_pc,  leg(off) scheme(s1mono) lc(red) ytitle("`: variable label insp_ext_all'")
** small
twoway scatter insp_ext_small rgdpo_pc, mlabel(countrycode) color(blue) || lfit insp_ext_small rgdpo_pc,  leg(off) scheme(s1mono) lc(red) ytitle("`: variable label insp_ext_small'")
// striking negative correlation GDP pc and share inspected formal firms (even within size) 

** share of firms mentioning tax administration as major constraint
** all 
twoway scatter sh_tax_adm_obst_all rgdpo_pc, mlabel(countrycode) color(blue) || lfit sh_tax_adm_obst_all rgdpo_pc,  leg(off) scheme(s1mono) lc(red) ytitle("`: variable label sh_tax_adm_obst_all'")
** small
twoway scatter sh_tax_adm_obst_small rgdpo_pc, mlabel(countrycode) color(blue) || lfit sh_tax_adm_obst_small rgdpo_pc,  leg(off) scheme(s1mono) lc(red) ytitle("`: variable label sh_tax_adm_obst_small'")
// slightly negative correlation

** share of firms mentioning tax rates as major constraint
** all 
twoway scatter sh_tax_rate_obst_all rgdpo_pc, mlabel(countrycode) color(blue) || lfit sh_tax_rate_obst_all rgdpo_pc,  leg(off) scheme(s1mono) lc(red) ytitle("`: variable label sh_tax_rate_obst_all'")
** small
twoway scatter sh_tax_rate_obst_small rgdpo_pc, mlabel(countrycode) color(blue) || lfit sh_tax_rate_obst_small rgdpo_pc,  leg(off) scheme(s1mono) lc(red) ytitle("`: variable label sh_tax_rate_obst_small'")
// slightly negative, almost flat

** Average social security and employment-base tax rate
** all 
twoway scatter sh_ss_tax_all rgdpo_pc, mlabel(countrycode) color(blue) || lfit sh_ss_tax_all rgdpo_pc,  leg(off) scheme(s1mono) lc(red) ytitle("`: variable label sh_ss_tax_all'")
** small
twoway scatter sh_ss_tax_small rgdpo_pc, mlabel(countrycode) color(blue) || lfit sh_ss_tax_small rgdpo_pc,  leg(off) scheme(s1mono) lc(red) ytitle("`: variable label sh_ss_tax_small'")
// slightly positive correlation

** Average income tax rate
** all 
twoway scatter sh_inc_tax_all rgdpo_pc, mlabel(countrycode) color(blue) || lfit sh_inc_tax_all rgdpo_pc,  leg(off) scheme(s1mono) lc(red) ytitle("`: variable label sh_inc_tax_all'")
** small
twoway scatter sh_inc_tax_small rgdpo_pc, mlabel(countrycode) color(blue) || lfit sh_inc_tax_small rgdpo_pc,  leg(off) scheme(s1mono) lc(red) ytitle("`: variable label sh_inc_tax_small'")
// slightly negative correlation

** Share of firms competing against the informal sector
twoway scatter sh_info_comp_all rgdpo_pc, mlabel(countrycode) color(blue) || lfit sh_info_comp_all rgdpo_pc,  leg(off) scheme(s1mono) lc(red) ytitle("`: variable label sh_info_comp_all'")
** small
twoway scatter sh_info_comp_small rgdpo_pc, mlabel(countrycode) color(blue) || lfit sh_info_comp_small rgdpo_pc,  leg(off) scheme(s1mono) lc(red) ytitle("`: variable label sh_info_comp_small'")
// strongly negative correlation

** Share of firms mentioning competition from informal sector as major constraint
twoway scatter sh_info_comp_obst_all rgdpo_pc, mlabel(countrycode) color(blue) || lfit sh_info_comp_obst_all rgdpo_pc,  leg(off) scheme(s1mono) lc(red) ytitle("`: variable label sh_info_comp_obst_all'")
** small
twoway scatter sh_info_comp_obst_small rgdpo_pc, mlabel(countrycode) color(blue) || lfit sh_info_comp_obst_small rgdpo_pc,  leg(off) scheme(s1mono) lc(red) ytitle("`: variable label sh_info_comp_obst_small'")
// strongly negative correlation

gen sh_tax_tot_all = sh_ss_tax_all + sh_inc_tax_all/100
gen sh_tax_tot_small = sh_ss_tax_small + sh_inc_tax_small/100
gen sh_tax_tot_med = sh_ss_tax_med + sh_inc_tax_med/100

** Average tax rate (sum of income tax and employment-based tax)
** all 
twoway scatter sh_tax_tot_all rgdpo_pc, mlabel(countrycode) color(blue) || lfit sh_tax_tot_all rgdpo_pc,  leg(off) scheme(s1mono) lc(red) ytitle("`: variable label sh_tax_tot_all'")
** small
twoway scatter sh_tax_tot_small rgdpo_pc, mlabel(countrycode) color(blue) || lfit sh_tax_tot_small rgdpo_pc,  leg(off) scheme(s1mono) lc(red) ytitle("`: variable label sh_tax_tot_small'")
// flat line as expected


scatter insp_ext_small insp_ext_med









