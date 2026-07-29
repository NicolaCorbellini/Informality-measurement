clear all
cd "H:\Research\WBES micro data"
use New_Comprehensive_July_5_2024

** cleaning, dummies, etc.
gen sole_prop_part=(b1==3|b1==4)  // sole proprietorship or partnership dummy
replace a14y=. if a14y<2005 | a14y>2025 // a14y is year survey 
replace b5=. if b5<1600 | b5>2025 // b5 is year establishment started 
gen age=a14y-b5 // age of establishment
drop if age<0 
gen multi_estab=(a7==1) // establishment part of larger firm dummy
replace d3b=. if d3b<0 | d3b>100 // indirect (d3b) and direct (export)
replace d3c=. if d3c<0 | d3c>100
gen tot_export=d3b+d3c
tab tot_export
gen info_comp=(e11==1) // competition from the informal sector dummy
gen tax_rate_obst=(j30a>=3 & j30a<=4) // tax rates major or sever obstacle
gen tax_adm_obst=(j30b>=3 & j30b<=4) // tax administration major or sever obstacle
replace n2a2=. if n2a2<0 // payments for social security and employment-base taxes 
replace n2a=. if n2a<0 // payments for labor compensation
replace n11=. if n11<0 // % income-based taxes
gen tax_rate=n2a2*100/n2a + n11 // sum of income and ss tax rates
replace tax_rate=100 if tax_rate>100 & tax_rate!=.
gen tax_insp_ext=(j3==1) // tax inspection yes/no dummy 
replace j4=. if j4<0
gen tax_insp_int=j4 // number inspections 
replace tax_insp_int=0 if j3==2

** label variables
label variable sole_prop_part "Dummy sole-proprietorship or partnership"
label variable multi_estab "Dummy multi-establishment firm"
label variable age "Age"

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

merge m:1 country using country_codes.dta
sort _merge country year
drop if _merge==2
drop _merge
rename CodeValue countrycode
order countrycode, a(country)

* merge with TFP and GDP per capita
merge m:1 countrycode year using ts_tfp.dta
sort _merge country year
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

** multiply shares by 100 for easier readibility of coefficients
gen tax_adm_obst2 = tax_adm_obst*100
drop tax_adm_obst
rename tax_adm_obst2 tax_adm_obst
label variable tax_adm_obst "Tax administration as major or severe obstacle"

gen tax_rate_obst2 = tax_rate_obst*100
drop tax_rate_obst
rename tax_rate_obst2 tax_rate_obst
label variable tax_rate_obst "Tax rates as major or severe obstacle"

gen tax_insp_ext2 = tax_insp_ext*100
drop tax_insp_ext
rename tax_insp_ext2 tax_insp_ext
label variable tax_insp_ext "Tax Inspection Dummy"

** regression analysis
rename stra_sector stra_sector_old
encode stra_sector_old, gen(stra_sector)

** tax administration as a major constraint
eststo clear
qui reghdfe tax_adm_obst cgdpo_pc [aw=wt], absorb(stra_sector) 
estadd local sector_fe "YES"
eststo reg1_1
qui reghdfe tax_adm_obst cgdpo_pc size_num [aw=wt], absorb(stra_sector)
estadd local sector_fe "YES"
eststo reg1_2
qui reghdfe tax_adm_obst c.cgdpo_pc##c.size_num [aw=wt], absorb(stra_sector) 
estadd local sector_fe "YES"
eststo reg1_3
qui reghdfe tax_adm_obst c.cgdpo_pc##c.size_num sole_prop_part age multi_estab d3c [aw=wt], absorb(stra_sector) 
estadd local sector_fe "YES"
eststo reg1_4
esttab reg1_1 reg1_2 reg1_3 reg1_4 using table_tax_adm_obst.tex, keep(cgdpo_pc size_num c.cgdpo_pc#c.size_num sole_prop_part age multi_estab d3c) s(sector_fe N, label("Sector Fixed Effects" "Observations"))b se label star(* .10 ** .05 *** .01) mlabels(,none) varlabels(cgdpo_pc "GDP per Capita" size_num "Firm Size" c.cgdpo_pc#c.size_num "GDP per Capita * Firm Size") replace

** tax rates as a major constraint
eststo clear
qui reghdfe tax_rate_obst cgdpo_pc [aw=wt], absorb(stra_sector) 
estadd local sector_fe "YES"
eststo reg1_1
qui reghdfe tax_rate_obst cgdpo_pc size_num [aw=wt], absorb(stra_sector)
estadd local sector_fe "YES"
eststo reg1_2
qui reghdfe tax_rate_obst c.cgdpo_pc##c.size_num [aw=wt], absorb(stra_sector) 
estadd local sector_fe "YES"
eststo reg1_3
qui reghdfe tax_rate_obst c.cgdpo_pc##c.size_num sole_prop_part age multi_estab d3c [aw=wt], absorb(stra_sector) 
estadd local sector_fe "YES"
eststo reg1_4
esttab reg1_1 reg1_2 reg1_3 reg1_4 using table_tax_rate_obst.tex, keep(cgdpo_pc size_num c.cgdpo_pc#c.size_num sole_prop_part age multi_estab d3c) s(sector_fe N, label("Sector Fixed Effects" "Observations"))b se label star(* .10 ** .05 *** .01) mlabels(,none) varlabels(cgdpo_pc "GDP per Capita" size_num "Firm Size" c.cgdpo_pc#c.size_num "GDP per Capita * Firm Size") replace

** tax rates (small sample)
eststo clear
qui reghdfe tax_rate cgdpo_pc [aw=wt], absorb(stra_sector) 
estadd local sector_fe "YES"
eststo reg1_1
qui reghdfe tax_rate cgdpo_pc size_num [aw=wt], absorb(stra_sector)
estadd local sector_fe "YES"
eststo reg1_2
qui reghdfe tax_rate c.cgdpo_pc##c.size_num [aw=wt], absorb(stra_sector) 
estadd local sector_fe "YES"
eststo reg1_3
qui reghdfe tax_rate c.cgdpo_pc##c.size_num sole_prop_part age multi_estab d3c [aw=wt], absorb(stra_sector) 
estadd local sector_fe "YES"
eststo reg1_4
esttab reg1_1 reg1_2 reg1_3 reg1_4 using table_tax_rate.tex, keep(cgdpo_pc size_num c.cgdpo_pc#c.size_num sole_prop_part age multi_estab d3c) s(sector_fe N, label("Sector Fixed Effects" "Observations"))b se label star(* .10 ** .05 *** .01) mlabels(,none) varlabels(cgdpo_pc "GDP per Capita" size_num "Firm Size" c.cgdpo_pc#c.size_num "GDP per Capita * Firm Size") replace

** tax inspection (extensive margin)
eststo clear
qui reghdfe tax_insp_ext cgdpo_pc [aw=wt], absorb(stra_sector) 
estadd local sector_fe "YES"
eststo reg1_1
qui reghdfe tax_insp_ext cgdpo_pc size_num [aw=wt], absorb(stra_sector)
estadd local sector_fe "YES"
eststo reg1_2
qui reghdfe tax_insp_ext c.cgdpo_pc##c.size_num [aw=wt], absorb(stra_sector) 
estadd local sector_fe "YES"
eststo reg1_3
qui reghdfe tax_insp_ext c.cgdpo_pc##c.size_num sole_prop_part age multi_estab d3c [aw=wt], absorb(stra_sector) 
estadd local sector_fe "YES"
eststo reg1_4
esttab reg1_1 reg1_2 reg1_3 reg1_4 using table_tax_insp_ext.tex, keep(cgdpo_pc size_num c.cgdpo_pc#c.size_num sole_prop_part age multi_estab d3c) s(sector_fe N, label("Sector Fixed Effects" "Observations"))b se label star(* .10 ** .05 *** .01) mlabels(,none) varlabels(cgdpo_pc "GDP per Capita" size_num "Firm Size" c.cgdpo_pc#c.size_num "GDP per Capita * Firm Size") replace

** tax inspection (intensive margin)
eststo clear
qui reghdfe tax_insp_int cgdpo_pc [aw=wt], absorb(stra_sector) 
estadd local sector_fe "YES"
eststo reg1_1
qui reghdfe tax_insp_int cgdpo_pc size_num [aw=wt], absorb(stra_sector)
estadd local sector_fe "YES"
eststo reg1_2
qui reghdfe tax_insp_int c.cgdpo_pc##c.size_num [aw=wt], absorb(stra_sector) 
estadd local sector_fe "YES"
eststo reg1_3
qui reghdfe tax_insp_int c.cgdpo_pc##c.size_num sole_prop_part age multi_estab d3c [aw=wt], absorb(stra_sector) 
estadd local sector_fe "YES"
eststo reg1_4
esttab reg1_1 reg1_2 reg1_3 reg1_4 using table_tax_insp_int.tex, keep(cgdpo_pc size_num c.cgdpo_pc#c.size_num sole_prop_part age multi_estab d3c) s(sector_fe N, label("Sector Fixed Effects" "Observations"))b se label star(* .10 ** .05 *** .01) mlabels(,none) varlabels(cgdpo_pc "GDP per Capita" size_num "Firm Size" c.cgdpo_pc#c.size_num "GDP per Capita * Firm Size") replace









