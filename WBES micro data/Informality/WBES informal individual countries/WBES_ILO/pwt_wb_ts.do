clear all
cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO"

** import data from excel
** data from pwt 2002-2019
import excel "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO\WB_ts.xlsx", sheet("STATA 2002-2019") firstrow
rename pop population
rename rgdpna gdp
rename rconna consumption
rename rnna capital
rename delta depreciation
rename csh_g govt_share

gen gdp_pc = gdp/population

label variable gdp "Real GDP at constant 2017 national prices (in mil. 2017US$)"
label variable consumption "Real consumption at constant 2017 national prices (in mil. 2017US$)"
label variable capital "Capital stock at constant 2017 national prices (in mil. 2017US$)"
label variable depreciation "Average depreciation rate of the capital stock"
label variable govt_share "Share of government consumption at current PPPs"
label variable gdp_pc "Real GDP per capita at constant 2017 national prices (in 2017US$)"

save data_02_19.dta, replace

clear all
** data from wb 2019-2023
import excel "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO\WB_ts.xlsx", sheet("STATA 2019-2023") firstrow
rename Finalconsumptionexpenditurec consumption_const
rename D consumption_curr
rename Finalconsumptionexpenditure cons_share
rename Consumerpriceindex2010100 cpi
rename Generalgovernmentfinalconsump govt_const
rename H govt_curr
rename I govt_share_wb
rename Grosscapitalformationconstan invest_const
rename GrosscapitalformationofGD invest_gdp
rename Adjustedsavingsconsumptionof cons_capital
rename GDPconstant2015US gdp_wb

save data_19_23.dta, replace

clear all
use data_02_19.dta
merge 1:1 countrycode year using "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO\data_19_23.dta"
drop if _merge==2
drop _merge
append using data_19_23.dta
drop if year==2019 & gdp==.
sort countrycode year

tab countrycode if consumption_const==. & year>=2019
tab countrycode if govt_const==. & year>=2019
tab countrycode if invest_const==. & year>=2019
** missing: Afghanistan, Lao, Myanmar, and Zambia. current LCU available for Zambia

** The values of consumption and govt expenditures in US $ are missing for Zambia. I can compute them by using LCU and adjusting for CPI
gen cpi_zmb_19 = 212.30876 if countrycode == "ZMB"
replace consumption_const = consumption_curr * cpi_zmb_19 / cpi if countrycode == "ZMB" & year>=2019
replace govt_const = govt_curr * cpi_zmb_19 / cpi if countrycode == "ZMB" & year>=2019

** update the PWT series consumption series by taking the growth rates from WB
gen cons_growth = .
bysort countrycode (year): replace cons_growth = (consumption_const[_n] / consumption_const[_n-1] - 1) if year>2019
bysort countrycode (year): replace consumption = consumption[_n-1] * (1 + cons_growth[_n]) if year > 2019 & year <= 2023

// twoway line consumption year if countrycode=="IND"

** update the PWT GDP series by taking the growth rates from WB
gen gdp_growth = .
bysort countrycode (year): replace gdp_growth = (gdp_wb[_n] / gdp_wb[_n-1] - 1) if year>2019
bysort countrycode (year): replace gdp = gdp[_n-1] * (1 + gdp_growth[_n]) if year > 2019 & year <= 2023

// twoway line gdp year if countrycode=="IND"

** update the PWT series on capital by adding the gross capital formation as % of GDP from WB (computed using the new updated gdp series) and subtracting average depreciation from PWT  

gen investment = invest_gdp*gdp/100 if year>2019 & year <= 2023
bysort countrycode: egen avg_depreciation = mean(depreciation)
bysort countrycode (year): replace capital = (1 - avg_depreciation) * capital[_n-1] + investment  if capital==.

// twoway line capital year if countrycode=="IND"

** update the PWT series on govt expenditures shares by (i) compute govt expenditures based on pwt in 2019; (ii) update series based on wb growth rates; (iii) compute shares based on updated series on government expenditures and gdp

gen govt_exp = govt_share * gdp / 100
gen govt_growth = .
bysort countrycode (year): replace govt_growth = (govt_const[_n] / govt_const[_n-1] - 1) if year>2019
bysort countrycode (year): replace govt_exp = govt_exp[_n-1] * (1 + govt_growth[_n]) if year > 2019 & year <= 2023
bysort countrycode (year): replace govt_share = 100*govt_exp/gdp if year > 2019 & year <= 2023

gen govt_share_wb2 = govt_share_wb/100

// twoway line govt_share year if countrycode=="IND" || line govt_share_wb2 year if countrycode=="IND" 

replace depreciation = avg_depreciation if depreciation==.
keep countrycode year gdp consumption capital depreciation govt_share gdp_pc

gen consumption_growth = .
bysort countrycode (year): replace consumption_growth = (consumption[_n] / consumption[_n-1] - 1)

gen gdp_growth = .
bysort countrycode (year): replace gdp_growth = (gdp[_n] / gdp[_n-1] - 1)

save wb_pwt_series.dta, replace






