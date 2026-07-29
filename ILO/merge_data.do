/*
clear 
cd "H:\Research\ILO"

* merge various employment and managers shares
use shares_managers_sector.dta
merge 1:1 countrycode year using "H:\Research\ILO\shares_managers_size.dta"
drop _merge
merge 1:1 countrycode year using "H:\Research\ILO\shares_profe_size_finer.dta"
drop _merge
merge 1:1 countrycode year using "H:\Research\ILO\shares_employment.dta"
drop _merge
merge 1:1 countrycode year using "H:\Research\ILO\shares_entr.dta"
drop if _merge==2 & entr_rate==. & owna_rate==.
drop _merge

** For a few countries (Italy, Australia, Chile, Panama, Costa Rica, Colombia, Bolivia, Korea, Greec, Turkey and few others), there are marginal differences when computing entrepreneurship and own account shares from employment data as opposed to employment and size data. The difference is due to different data sources. However, the scatter plots below suggest the difference is minimal
// twoway scatter entr_rate entr_rate_Total if entr_rate!=entr_rate_Total
// twoway scatter owna_rate owna_rate_Total if owna_rate!=owna_rate_Total


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

save ilo_size_tfp.dta, replace
*/

** Can start from here
clear 
cd "H:\Research\ILO"
use ilo_size_tfp.dta

// ** count countries with at least one observation of managerial shares by country and sector
// preserve 
// gen dummy=1 if share_profe_manuf!=. | share_profe_servi!=. | share_profe_nonagr!=. | share_man_manuf!=. | share_man_servi!=. | share_man_nonagr!=.
// drop if dummy==.
// count
// bysort country: drop if _n>1
// count
// restore
//
// ** count countries with at least one observation of managerial shares by country and size class
// preserve 
// gen dummy=1 if share_man_1_4!=. | share_profe_1_4!=. | share_man_5_49!=. | share_profe_5_49!=. | share_profe_50m!=. | share_profe_50m!=. | share_man_Total!=. | share_profe_Total!=. | share_profe_1p!=. | share_profe_2_4!=. | share_profe_5_9!=. | share_profe_10_19!=. | share_profe_20_49!=.
// drop if dummy==.
// count
// bysort country: drop if _n>1
// count
// restore
//
// ** count countries with at least one observation of employment shares by country and size class
// preserve 
// gen dummy=1 if empl_1_4!=. | empl_1_9!=. | empl_1_19!=. | empl_1_49!=. 
// drop if dummy==.
// count
// bysort country: drop if _n>1
// count
// restore


** compare two different measures of manager shares
// sum share_man_nonagr share_man_Total if share_man_Total!=. & share_man_nonagr!=.
// twoway scatter share_man_nonagr share_man_Total if share_man_Total!=. & share_man_nonagr!=.
/*
The two measures are highly correlated. share_man_nonagr is computed from employment data disggregated by SECTOR, and then aggregated got non-agriculture. share_man_Total is computed from employment data disaggregated by SIZE CLASS, which therefore might include agricultural observations. However, it seems reasonable to create a variable that assigns one of the values if the other is missing
*/

replace share_man_nonagr=share_man_Total if share_man_nonagr==. & share_man_Total!=. 

drop if year<2015 | year>2019
** country averages 2014-2018
bysort country: egen avg_man_share         = mean(share_man_nonagr)
bysort country: egen avg_man_share_1_4     = mean(share_man_1_4)
bysort country: egen avg_man_share_5_49    = mean(share_man_5_49)
bysort country: egen avg_man_share_50m     = mean(share_man_50m)
bysort country: egen avg_profe_share_5_9   = mean(share_profe_5_9)
bysort country: egen avg_profe_share_10_19 = mean(share_profe_10_19)
bysort country: egen avg_profe_share_20_49 = mean(share_profe_20_49)
bysort country: egen avg_profe_share_50m   = mean(share_profe_50m)
bysort country: egen avg_entr_rate         = mean(entr_rate)
bysort country: egen avg_empl_1_9          = mean(empl_1_9)
bysort country: egen avg_empl_1_49         = mean(empl_1_49)
bysort country: egen avg_size              = mean(size_gem)
bysort country: egen avg_tfp               = mean(ctfp)
bysort country: egen avg_gdp_pc            = mean(cgdpo_pc)

** keep one observation per country
bysort country: keep if _n==1
keep country countrycode avg_*

** tables by gdp_pc quartiles
xtile avg_gdp_pc_4      = avg_gdp_pc, nq(4) 
xtile avg_gdp_pc_4_size = avg_gdp_pc if avg_man_share_1_4!=., nq(4)

global xlist1 avg_man_share avg_size avg_entr_rate avg_tfp avg_gdp_pc

global xlist2 avg_man_share avg_man_share_1_4 avg_man_share_5_49 avg_man_share_50m avg_gdp_pc 

global xlist3 avg_profe_share_5_9 avg_profe_share_10_19 avg_profe_share_20_49 avg_profe_share_50m avg_entr_rate avg_empl_1_9 avg_empl_1_49 avg_size avg_gdp_pc

tabstat $xlist1, by(avg_gdp_pc_4) stat(mean n) format(%9.3g) nototal long
tabstat $xlist2, by(avg_gdp_pc_4_size) stat(mean n) format(%9.3g) nototal long
tabstat $xlist3, by(avg_gdp_pc_4_size) stat(mean n) format(%9.3g) nototal long

eststo clear

qui estpost summarize $xlist1 if avg_gdp_pc_4==1
eststo
qui estpost summarize $xlist1 if avg_gdp_pc_4==2
eststo
qui estpost summarize $xlist1 if avg_gdp_pc_4==3
eststo
qui estpost summarize $xlist1 if avg_gdp_pc_4==4
eststo

esttab, main(mean) aux(n) unstack mtitles(First Second Third Fourth) nonotes nonumbers  title ("Summary Table") depvars nogaps replace



