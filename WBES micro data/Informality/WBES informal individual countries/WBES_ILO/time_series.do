/*
clear all
set more off
cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO"

** import ILO data from excel
** total employment
import excel "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO\ILO_data.xlsx", sheet("Total Employment") firstrow
save ILO_employment_data.dta, replace
clear all
** employment outside formal sector
import excel "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO\ILO_data.xlsx", sheet("Outside Formal Employment") firstrow
save ILO_out_employment_data.dta, replace

append using ILO_employment_data.dta

** cleaning
** (i) some country-year observations are off and do not have a corresponding value for employment outside formal sector => dropped
drop if ref_arealabel=="Angola" & time=="2014" & indicatorlabel=="Employment by sex and age (thousands)"
drop if ref_arealabel=="Bangladesh" & time=="2011" & indicatorlabel=="Employment by sex and age (thousands)"
drop if ref_arealabel=="Cameroon" & time=="2005" & indicatorlabel=="Employment by sex and age (thousands)"
drop if ref_arealabel=="Lao People's Democratic Republic" & time=="2005" & indicatorlabel=="Employment by sex and age (thousands)"
drop if ref_arealabel=="Mali" & time=="2019" & indicatorlabel=="Employment by sex and age (thousands)"
drop if ref_arealabel=="Nepal" & time=="2015" & indicatorlabel=="Employment by sex and age (thousands)"
drop if ref_arealabel=="Rwanda" & time=="2014" & indicatorlabel=="Employment by sex and age (thousands)"
drop if ref_arealabel=="Zambia" & (time=="2010" | time=="2015") & indicatorlabel=="Employment by sex and age (thousands)"
drop if ref_arealabel=="Zimbabwe" & time=="2012" & indicatorlabel=="Employment by sex and age (thousands)"

** (ii) some country-year observations are off but there is an equally off informal figure. Do not want to drop information of informal share. Adjust later after setting to panel.

** setting to panel
drop sourcelabel sexlabel obs_statuslabel note_sourcelabel note_indicatorlabel note_classiflabel classif1label
rename ref_arealabel country
destring time, gen(year)
drop time
order year, a(country)
rename obs_value n_
rename indicatorlabel var
encode var, gen(var2)
replace var="tot_emp" if var2==1
replace var="tot_out_emp" if var2==2
tab var var2
drop var2
* reshape wide
reshape wide n, i(country year) j(var) string
sort country year
gen out_share = n_tot_out_emp/n_tot_emp 
count if out_share>=1 & out_share!=.
drop out_share

* Merge with country codes
replace country="Cape Verde" if country=="Cabo Verde"
replace country="Congo, The Democratic Republic of" if country=="Congo, Democratic Republic of the"
replace country="Cote d'Ivoire" if country=="Côte d'Ivoire"
replace country="Lao, People's Democratic Republic" if country=="Lao People's Democratic Republic"
merge m:1 country using "C:\Users\nzc5436\Desktop\WBES micro data\country_codes.dta"
drop if _merge==2
drop _merge
rename CodeValue countrycode
order countrycode, a(country)
sort country year

** adjust observations in (ii) above: compute informal share, erase values, and adjust later when interpolating
gen out_share = (n_tot_out_emp/ n_tot_emp) if (countrycode=="KHM" & year==2012) | (countrycode=="CPV" & year==2015) | (countrycode=="CIV" & year==2017) | (countrycode=="LAO" & year==2017) | (countrycode=="GHA" & year==2015) | (countrycode=="BFA" & (year==2018 | year==2023)) | (countrycode=="NER" & (year==2012 | year==2017))

replace n_tot_emp =. if (countrycode=="KHM" & year==2012) | (countrycode=="CPV" & year==2015) | (countrycode=="CIV" & year==2017) | (countrycode=="LAO" & year==2017) | (countrycode=="GHA" & year==2015) | (countrycode=="BFA" & (year==2018 | year==2023)) | (countrycode=="NER" & (year==2012 | year==2017))

replace n_tot_out_emp =0 if (countrycode=="KHM" & year==2012) | (countrycode=="CPV" & year==2015) | (countrycode=="CIV" & year==2017) | (countrycode=="LAO" & year==2017) | (countrycode=="GHA" & year==2015) | (countrycode=="BFA" & (year==2018 | year==2023)) | (countrycode=="NER" & (year==2012 | year==2017)) // 0, not missing, otherwise it messes up the min-max years below

// twoway line n_tot_emp year if country=="Afghanistan"
// twoway line n_tot_emp year if country=="Angola" 
// twoway line n_tot_emp year if country=="Argentina"
// twoway line n_tot_emp year if country=="Bangladesh"
// twoway line n_tot_emp year if country=="Botswana"
// twoway line n_tot_emp year if country=="Burkina Faso"
// twoway line n_tot_emp year if country=="Cambodia"
// twoway line n_tot_emp year if country=="Cameroon"
// twoway line n_tot_emp year if country=="Cape Verde"
// twoway line n_tot_emp year if country=="Congo, The Democratic Republic of"
// twoway line n_tot_emp year if country=="Cote d'Ivoire"
// twoway line n_tot_emp year if country=="Egypt"
// twoway line n_tot_emp year if country=="Ghana"
// twoway line n_tot_emp year if country=="Guatemala"
// twoway line n_tot_emp year if country=="India"
// twoway line n_tot_emp year if country=="Indonesia"
// twoway line n_tot_emp year if country=="Iraq"
// twoway line n_tot_emp year if country=="Kenya"
// twoway line n_tot_emp year if country=="Lao, People's Democratic Republic"
// twoway line n_tot_emp year if country=="Madagascar"
// twoway line n_tot_emp year if country=="Mali"
// twoway line n_tot_emp year if country=="Mauritius"
// twoway line n_tot_emp year if country=="Mozambique"
// twoway line n_tot_emp year if country=="Myanmar"
// twoway line n_tot_emp year if country=="Nepal"
// twoway line n_tot_emp year if country=="Niger"
// twoway line n_tot_emp year if country=="Peru"
// twoway line n_tot_emp year if country=="Rwanda"
// twoway line n_tot_emp year if country=="Somalia"
// twoway line n_tot_emp year if country=="Sudan"
// twoway line n_tot_emp year if country=="Tanzania, United Republic of"
// twoway line n_tot_emp year if country=="Zambia"
// twoway line n_tot_emp year if country=="Zimbabwe"

save ilo_data_small.dta, replace

* Get the list of countries
levelsof country, local(countries)

* Create a new dataset with years from 2002 to 2023 for each country
clear
tempfile new_years
save `new_years', emptyok replace

foreach c in `countries' {
    clear
    set obs 22
    gen country = "`c'"
    gen year = 2002 + _n - 1
    tempfile temp
    save `temp', replace
    append using `new_years'
    save `new_years', replace
}

use `new_years', clear
save new_years.dta, replace

* Load the original dataset
use ilo_data_small.dta, clear
* Get the initial and final year for each country
bysort country: egen min_year = min(year) if !missing(n_tot_emp)
bysort country: egen max_year = max(year) if !missing(n_tot_emp)
* Merge with the new dataset
merge 1:1 country year using new_years.dta
sort country year

* Fill missing values for min_year and max_year
bysort country (year): replace min_year = min_year[_n-1] if missing(min_year)
bysort country (year): replace max_year = max_year[_n-1] if missing(max_year)
* Drop observations outside the initial and final year range for each country
drop if min_year==.
drop if year > max_year
drop min_year max_year _merge

bysort country: replace countrycode = countrycode[_n-1] if missing(countrycode)
bysort country: replace countrycode = countrycode[_n+1] if missing(countrycode)

* Linearly interpolate missing values for n_tot_emp
bysort country (year): ipolate n_tot_emp year, gen(n_tot_emp_interp)

* replace values that were dropped but for which we have share informal
replace n_tot_out_emp = n_tot_emp_interp * out_share if out_share!=.
drop out_share

* Linearly interpolate missing values for n_tot_out_emp
bysort country (year): ipolate n_tot_out_emp year, gen(n_tot_out_emp_interp)

gen out_share = n_tot_out_emp_interp/n_tot_emp_interp

label variable n_tot_emp "Number of employed individuals (th) 15+"
label variable n_tot_out_emp "Number of employed individuals (th) 15+, outside formal sector"
label variable out_share "Share of employed individuals outside formal sector"
label variable country ""
label variable countrycode ""
label variable year ""

erase ilo_data_small.dta 
save ilo_data_ts.dta, replace

// twoway line out_share year if country=="Angola" 
// twoway line out_share year if country=="Argentina"
// twoway line out_share year if country=="Bangladesh"
// twoway line out_share year if country=="Congo, The Democratic Republic of"
// twoway line out_share year if country=="Guatemala"
// twoway line out_share year if country=="India"
// twoway line out_share year if country=="Indonesia"
// twoway line out_share year if country=="Myanmar"
// twoway line out_share year if country=="Nepal"
// twoway line out_share year if country=="Peru"
// twoway line out_share year if country=="Zambia"
// twoway line out_share year if country=="Zimbabwe"
*/

clear all
cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO"
use ilo_data_ts

** adjust and merge with pwt/wb series
merge 1:1 countrycode year using "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO\wb_pwt_series.dta"
drop if _merge==2
drop _merge 
rename n_tot_emp employment
rename n_tot_out_emp employment_info
gen tot_emp_interpolated=(employment==. & n_tot_emp_interp!=.)
gen info_emp_interpolated=(employment_info==. & n_tot_out_emp_interp!=.)
replace employment=n_tot_emp_interp if employment==.
replace employment_info=n_tot_out_emp_interp if employment_info==.
drop n_tot_emp_interp n_tot_out_emp_interp
drop if employment_info==. | gdp==.
drop if consumption==. | govt_share==.
drop if consumption_growth==.

** merge with wbes production statistics
merge m:1 countrycode year using "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO\wbes_stats"

bysort country: egen min_year = min(year) if !missing(employment)
bysort country: egen max_year = max(year) if !missing(employment)

bysort country: egen min_year_mode=mode(min_year) 
replace min_year=min_year_mode if min_year==.
bysort country: egen max_year_mode=mode(max_year) 
replace max_year=max_year_mode if max_year==.
drop min_year_mode max_year_mode

drop if max_year==. // drop AFG & CAR since no employment data

** replace sales and va per worker from WBES to the closest year in which employment data are avaiable
local vars sales_per_worker_form sales_per_worker_info va_per_worker_form va_per_worker_info obs_form_spw obs_info_spw obs_form_vapw obs_info_vapw
foreach var of local vars {
    bysort country (year): replace `var' = `var'[_n+1] if missing(`var') & (year == max_year) & !missing(`var'[_n+1])
	bysort country (year): replace `var' = `var'[_n-1] if missing(`var') & (year == min_year) & !missing(`var'[_n-1])
}

** replace production function parameters for all the years in the time series
bysort country: egen beta_n_mode=mode(beta_n)
replace beta_n = beta_n_mode if beta_n==.
bysort country: egen beta_k_mode=mode(beta_k)
replace beta_k = beta_k_mode if beta_k==.
bysort country: egen beta_n_2_mode=mode(beta_n_2)
replace beta_n_2 = beta_n_2_mode if beta_n_2==.
bysort country: egen beta_n_info_mode=mode(beta_n_info)
replace beta_n_info = beta_n_info_mode if beta_n_info==.
drop beta_n_mode beta_k_mode beta_n_2_mode beta_n_info_mode _merge
sort country year

** record wbes year
gen wbes_year=.
replace wbes_year=year[_n-1] if sales_per_worker_form!=. & year==min_year & employment[_n-1]==.
replace wbes_year=year[_n+1] if sales_per_worker_form!=. & year==max_year & employment[_n+1]==.
drop min_year max_year
replace wbes_year=year if sales_per_worker_form!=. & wbes_year==.

drop if employment==.

// drop if beta_n<0 | beta_k<0 |  beta_n_2<0 |  beta_n_info<0 
sort country year
save full_time_series.dta, replace

** drop less recent data if two observations within a country
gen tag = !missing(sales_per_worker_form)
egen total_sales_per_worker_form = total(tag), by(country)
bysort country (year): gen to_drop = (sum(tag) == 1 & total_sales_per_worker_form == 2)
replace sales_per_worker_form = . if to_drop
replace sales_per_worker_info = . if to_drop
replace va_per_worker_form = . if to_drop
replace va_per_worker_info = . if to_drop
drop tag to_drop total_sales_per_worker_form


export excel using "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO\time_series.xlsx", firstrow(variables) replace

drop if sales_per_worker_form==.

export excel using "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\WBES_ILO\time_series_wbes_years.xlsx", firstrow(variables) replace













