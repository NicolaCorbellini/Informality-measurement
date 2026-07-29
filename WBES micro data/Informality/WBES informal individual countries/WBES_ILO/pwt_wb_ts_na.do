clear all
cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO"

** import data from excel
** data from pwt 2002-2019
import excel "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO\WB_ts.xlsx", sheet("STATA 2002-2019 NA") firstrow
rename pop population
rename rgdpna gdp
rename rnna capital
rename delta depreciation
gen gdp_pc = gdp/population

** adjust for non-agriculture. Assume that capital is proportional to non-agriculture GDP
gen gdp_na = gdp * (100-agr_share)/100
gen capital_na = capital * (100-agr_share)/100

** labels
label variable gdp_na "Real non-agr. GDP at constant 2017 national prices (in mil. 2017US$)"
label variable capital_na "Capital stock (non-agr.) at constant 2017 national prices (in mil. 2017US$)"
label variable depreciation "Average depreciation rate of the capital stock"
label variable agr_share "% of GDP in Agriculture" 
label variable gdp_pc "Real GDP per capita at constant 2017 national prices (in 2017US$)"

drop capital gdp

save data_02_19_na.dta, replace

clear all
** data from wb 2019-2023
import excel "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO\WB_ts.xlsx", sheet("STATA 2019-2023 NA") firstrow
rename GrosscapitalformationofGD invest_gdp
rename GDPconstant2015US gdp_wb

** adjust for non-agriculture. Later we assume that investment is proportional to non-agriculture GDP
gen gdp_wb_na = gdp_wb * (100-agr_share)/100

drop gdp_wb

label variable gdp_wb_na "Real non-agr. GDP at constant 2015 USD (WB)"

save data_19_23_na.dta, replace

clear all
use data_02_19_na.dta
merge 1:1 countrycode year using "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO\data_19_23_na.dta"
drop if _merge==2
drop _merge
append using data_19_23_na.dta
drop if year==2019 & gdp_na==.
sort countrycode year

** update the PWT GDP series by taking the growth rates from WB
gen gdp_growth = .
bysort countrycode (year): replace gdp_growth = (gdp_wb_na[_n] / gdp_wb_na[_n-1] - 1) if year>2019
bysort countrycode (year): replace gdp_na = gdp_na[_n-1] * (1 + gdp_growth[_n]) if year > 2019 & year <= 2023

// twoway line gdp_na year if countrycode=="IND"

** update the PWT series on capital by adding the gross capital formation as % of GDP from WB (computed using the new updated gdp series) and subtracting average depreciation from PWT. The assumption is that non-agr investment is proportional to non-agriculture GDP 

gen investment = invest_gdp*gdp_na/100 if year>2019 & year <= 2023
bysort countrycode: egen avg_depreciation = mean(depreciation)
bysort countrycode (year): replace capital = (1 - avg_depreciation) * capital[_n-1] + investment  if capital==.

// twoway line capital year if countrycode=="IND"

keep countrycode year gdp_na capital_na gdp_pc

gen gdp_growth = .
bysort countrycode (year): replace gdp_growth = (gdp_na[_n] / gdp_na[_n-1] - 1)

save wb_pwt_series_na.dta, replace






