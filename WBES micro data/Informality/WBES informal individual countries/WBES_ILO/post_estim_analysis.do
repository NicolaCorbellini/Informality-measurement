clear all
cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO"

** import data from excel
import excel "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO\informality_series_na.xlsx", firstrow

save myseries.dta, replace

** correlation gdp per capita and informal GDP
bysort country: egen avg_gdp_pc = mean(gdp_pc) 
bysort country: egen avg_info_share = mean(info_share) if gdp_pc!=. // sales-based
bysort country: egen avg_info_share_2 = mean(info_share_2) if gdp_pc!=. // va-based
// gen log_gdp_pc = log(avg_gdp_pc)

scatter avg_info_share avg_gdp_pc if wbes_year!=. , mlabel(countrycode) color(blue) ///
|| lfit avg_info_share avg_gdp_pc if wbes_year!=. , leg(off) scheme(s1mono) lc(red) ///
xtitle("GDP per Capita", size(large)) ///
ytitle("") ///
title("Informal GDP (Sales-based)", size(large) placement(11) ) ///
ylabel(,angle(0))
graph export "corr_gdppc_1.png", replace

scatter avg_info_share_2 avg_gdp_pc if wbes_year!=., mlabel(countrycode) color(blue) ///
|| lfit avg_info_share_2 avg_gdp_pc if wbes_year!=., leg(off) scheme(s1mono) lc(red) ///
xtitle("GDP per Capita", size(large)) ///
ytitle("") ///
title("Informal GDP (VA-based)", placement(11) size(large)) ///
ylabel(,angle(0))
graph export "corr_gdppc_2.png", replace

** relationship between variation in informality and GDP change
bysort country: gen info_change = info_share[_n] - info_share[_n-1] 
bysort country: gen info_change_2 = info_share_2[_n] - info_share_2[_n-1] 

** informal employment
bysort country: gen info_empl_change = out_share[_n] - out_share[_n-1] 

** charts
scatter info_change gdp_growth if abs(info_change)<0.05,  color(blue) ///
|| lfit info_change gdp_growth if abs(info_change)<0.05, leg(off) scheme(s1mono) lc(red) ///
xtitle("GDP Growth Rate", size(large)) ///
ytitle("") ///
title("Change in Informal GDP (Sales-based)", placement(11) size(large)) ///
ylabel(,angle(0))
graph export "corr_gdpgr_1.png", replace

scatter info_change_2 gdp_growth if abs(info_change)<0.05,  color(blue) ///
|| lfit info_change_2 gdp_growth if abs(info_change)<0.05, leg(off) scheme(s1mono) lc(red) ///
xtitle("GDP Growth Rate", size(large)) ///
ytitle("") ///
title("Change in Informal GDP (VA-based)", placement(11) size(large)) ///
ylabel(,angle(0))
graph export "corr_gdpgr_2.png", replace

// encode countrycode, gen(country_num)

** regressions
reg info_empl_change gdp_growth 
reg info_change gdp_growth 
reg info_change_2 gdp_growth 

// sum info_empl_change info_change info_change_2 if info_emp_interpolated==0 & gdp_growth<0
// sum info_empl_change info_change info_change_2 if info_emp_interpolated==0 & gdp_growth>0


** comparison with other measures of informality
clear all
cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO"

** import and save data from Elgin et al 2021
import excel "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO\informal-economy-database.xlsx", sheet("STATA") firstrow
save elgin-et-al-data.dta, replace

** import data from excel
clear all
use myseries
** keep relevant variables only
keep country countrycode year out_share gdp_pc gdp_growth info_share info_share_2
** merge with Elgin et al 2021 measures
merge 1:1 countrycode year using "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO\elgin-et-al-data.dta"
drop _merge
drop if year>=2019 // Elgin et al. last avail. year is 2018

sort country year

** averages
preserve
bysort country: egen avg_info_share=mean(info_share) 
bysort country: egen avg_info_share_2=mean(info_share_2) 
bysort country: egen avg_info_dge=mean(dge) 
bysort country: egen avg_info_mimic=mean(mimic) 
collapse (mean) out_share avg_info_share avg_info_share_2 avg_info_dge avg_info_mimic, by (country countrycode)
sum out_share avg_info_share avg_info_share_2 avg_info_dge avg_info_mimic
restore

** volatility
preserve
bysort country: egen sd_info_share=sd(info_share) 
bysort country: egen sd_info_share_2=sd(info_share_2) 
bysort country: egen sd_info_dge=sd(dge) 
bysort country: egen sd_info_mimic=sd(mimic) 
bysort country: egen avg_info_share=mean(info_share) 
bysort country: egen avg_info_share_2=mean(info_share_2) 
bysort country: egen avg_info_dge=mean(dge) 
bysort country: egen avg_info_mimic=mean(mimic) 
collapse (mean) out_share avg_info_share avg_info_share_2 avg_info_dge avg_info_mimic sd_info_share sd_info_share_2 sd_info_dge sd_info_mimic, by (country countrycode)

gen cv_info   = sd_info_share / avg_info_share
gen cv_info_2 = sd_info_share_2 / avg_info_share_2
gen cv_dge    = sd_info_dge / avg_info_dge
gen cv_mimic  = sd_info_mimic / avg_info_mimic

list country cv_info cv_info_2 cv_dge cv_mimic
sum cv_info cv_info_2 cv_dge cv_mimic
sum sd_info_share sd_info_share_2 sd_info_dge sd_info_mimic

restore

** table
preserve
bysort country: egen avg_info_share=mean(info_share) 
bysort country: egen avg_info_share_2=mean(info_share_2) 
bysort country: egen avg_info_dge=mean(dge) 
bysort country: egen avg_info_mimic=mean(mimic) 
bysort country: egen min_year=min(year) 
bysort country: egen max_year=max(year) 

collapse (mean) out_share avg_info_share avg_info_share_2 avg_info_dge avg_info_mimic min_year max_year, by (country countrycode)

drop if avg_info_share==.

gen years = string(min_year) + "-" + string(max_year)

gen avg_info_pct = string(round(avg_info_share * 100, 0.1), "%4.1f") + "%"
gen avg_info_2_pct = string(round(avg_info_share_2 * 100, 0.1), "%4.1f") + "%"
gen avg_dge_pct = string(round(avg_info_dge * 100, 0.1), "%4.1f") + "%"
gen avg_mimic_pct = string(round(avg_info_mimic * 100, 0.1), "%4.1f") + "%"

keep country years avg_info_pct avg_info_2_pct avg_dge_pct avg_mimic_pct

order country years avg_info_pct avg_info_2_pct avg_dge_pct avg_mimic_pct

export excel using "summary_table.xlsx", firstrow(variables) replace

restore













