clear all
set more off
cd "H:\Research\ILO"
use ilo_empl.dta

** cleaning and setting to panel
drop indicator_label source_label sex_label obs_status_label note_source_label note_indicator_label note_classif_label
rename ref_area_label country
rename classif1_label status
rename obs_value n
destring time, gen(year)
drop time
order year, a(country)

* rename the 8 status values 
encode status, gen(status2)
replace status="Self_employed" if status2==1 // self-employed is the sum of employer, own account, cooperative, and domestic, when available
replace status="Own_account" if status2==2
replace status="Unclassified" if status2==3
replace status="Total" if status2==4

drop status2

* reshape wide
reshape wide n, i(country year) j(status) string

* Merge with country codes
replace country="Bolivia" if country=="Bolivia (Plurinational State of)"
replace country="Cape Verde" if country=="Cabo Verde"
replace country="Congo, The Democratic Republic of" if country=="Congo, Democratic Republic of the"
replace country="Cote d'Ivoire" if substr(country,1,5) == "Côte"
replace country="Iran, Islamic Republic of" if country=="Iran (Islamic Republic of)"
replace country="Lao, People's Democratic Republic" if country=="Lao People's Democratic Republic"
replace country="Palestinian Territory, Occupied" if country=="Occupied Palestinian Territory"
replace country="Korea, Republic of" if country=="Republic of Korea"
replace country="Moldova, Republic of" if country=="Republic of Moldova"
replace country="Republic of Serbia" if country=="Serbia"
replace country="Turkey" if country=="Türkiye"
replace country="Venezuela" if country=="Venezuela (Bolivarian Republic of)"
replace country="Vietnam" if country=="Viet Nam"
replace country="Hong Kong" if country=="Hong Kong, China"
replace country="Swaziland" if country=="Eswatini"
replace country="Kazakstan" if country=="Kazakhstan"
replace country="Macao" if country=="Macao, China"
replace country="Micronesia, Federated States of" if country=="Micronesia (Federated States of)"
replace country="Russia Federation" if country=="Russian Federation"
replace country="Reunion" if country=="Réunion"
replace country="Saint Kitts & Nevis" if country=="Saint Kitts and Nevis"
replace country="Taiwan, Province of China" if country=="Taiwan, China"
replace country="United Kingdom" if country=="United Kingdom of Great Britain and Northern Ireland"
replace country="United States" if country=="United States of America"

merge m:1 country using "H:\Research\ILO\country_codes.dta"
sort _merge country
drop if _merge!=3
drop _merge
rename CodeValue countrycode
order countrycode, a(country)
sort country year

replace nUnclassified=0 if nUnclassified==.
gen entr_rate = nSelf_employed/(nTotal - nUnclassified) // entrepreneurship rate
label variable entr_rate "Share of entrepreneurs (excluding nc)"
gen owna_rate = nOwn_account/(nTotal - nUnclassified)  // own-account rate
label variable owna_rate "Share of own-account (excluding nc)"


keep country countrycode year entr_rate owna_rate
save shares_entr.dta, replace





 





