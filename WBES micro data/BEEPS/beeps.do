clear all
cd "H:\Research\WBES micro data\BEEPS"
use "combined WBES_ECA MENA_2020"

// gen year_string = substr(country, -4, 4)
// destring year_string, gen(year)
gen country_name = substr(country, 1, length(country) - 4)
drop country
rename country_name country
order country, b(idstd)

rename a20y year
rename d2 sales
rename n2a wage_bill
rename n2b electricity
rename n2e materials
rename n2f fuel
rename n2p total_cost
rename l1 employees
rename a0 sector_MS
rename a4ax sector_2d
rename a6a size

replace sales=. if sales<0
replace wage_bill=. if wage_bill<0
replace electricity=. if electricity<0
replace fuel=. if fuel<0
replace materials=. if materials<0
replace total_cost=. if total_cost<0
replace employees=. if employees<0

** BMb1: share firm owned by same family
** BMb2: share management within family
replace BMb1=. if BMb1<0
replace BMb2=. if BMb2<0

gen fam_owned=. 
replace fam_owned=0 if BMb1<50
replace fam_owned=1 if BMb1>=50
gen fam_managed=. 
replace fam_managed=0 if BMb1<50 | BMb2<100
replace fam_managed=1 if BMb1>=50 & BMb2==100

tab fam_owned
tab fam_managed

** country weighted share of family owned firms
bysort country size: egen sum_weight = sum(wmedian) if fam_owned!=.
bysort country size: egen fam_own_sum = sum(wmedian*fam_owned) if fam_owned!=.
bysort country size: gen fam_own_share = fam_own_sum/sum_weight if fam_owned!=.
** get rid of missing values
bysort country size: egen mean_value = mode(fam_own_share)
bysort country size: replace fam_own_share = mean_value if missing(fam_own_share)
drop mean_value
drop sum_weight

** country weighted share of family managed firms
bysort country size: egen sum_weight = sum(wmedian) if fam_managed!=.
bysort country size: egen fam_man_sum = sum(wmedian*fam_managed) if fam_managed!=.
bysort country size: gen fam_man_share = fam_man_sum/sum_weight if fam_managed!=.
** get rid of missing values
bysort country size: egen mean_value = mode(fam_man_share)
bysort country size: replace fam_man_share = mean_value if missing(fam_man_share)
drop mean_value
drop sum_weight

bysort country size: keep if _n == 1
order fam_own_share fam_man_share, a(country)

replace country="Kazakstan"                         if country=="Kazakhstan"
replace country="Russia Federation"                 if country=="Russia"
replace country="Republic of Serbia"                if country=="Serbia"
replace country="Slovakia"                          if country=="Slovak Republic"
replace country="Palestinian Territory, Occupied"   if country=="West Bank And Gaza"
replace country="Moldova, Republic of"              if country=="Moldova"
replace country="Kyrgyzstan"                        if country=="Kyrgyz Republic"
replace country="Turkey"                            if country=="Türkiye"

merge m:1 country using "H:\Research\WBES micro data\country_codes.dta"
sort _merge country year
drop if _merge==2
drop _merge
rename CodeValue countrycode
order countrycode, a(country)

* merge with TFP and GDP per capita
merge m:1 countrycode year using "H:\Research\WBES micro data\ts_tfp.dta"
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
twoway scatter fam_own_share rgdpo_pc if size==1, mlabel(countrycode) color(blue) || lfit fam_own_share rgdpo_pc if size==1,  leg(off) scheme(s1mono) lc(red) 

twoway scatter fam_own_share rgdpo_pc if size==2, mlabel(countrycode) color(blue) || lfit fam_own_share rgdpo_pc if size==2,  leg(off) scheme(s1mono) lc(red) 

twoway scatter fam_own_share rgdpo_pc if size==3, mlabel(countrycode) color(blue) || lfit fam_own_share rgdpo_pc if size==3,  leg(off) scheme(s1mono) lc(red) 

twoway scatter fam_man_share rgdpo_pc if size==1, mlabel(countrycode) color(blue) || lfit fam_man_share rgdpo_pc if size==1,  leg(off) scheme(s1mono) lc(red) 

twoway scatter fam_man_share rgdpo_pc if size==2, mlabel(countrycode) color(blue) || lfit fam_man_share rgdpo_pc if size==2,  leg(off) scheme(s1mono) lc(red) 

twoway scatter fam_man_share rgdpo_pc if size==3, mlabel(countrycode) color(blue) || lfit fam_man_share rgdpo_pc if size==3,  leg(off) scheme(s1mono) lc(red) 





