clear all
set more off
cd "H:\Research\ILO"

** Import ILO data. Check excel file for sources
import excel "H:\Research\ILO\time series.xlsx", sheet("Time Series") cellrange(A3:AD1494) firstrow

destring year, gen(year2)
drop year
order year2, a(country)
rename year2 year

* Merge with country codes
replace country="Bolivia" if country=="Bolivia (Plurinational State of)"
replace country="Cape Verde" if country=="Cabo Verde"
replace country="Congo, The Democratic Republic of" if country=="Congo, Democratic Republic of the"
replace country="Swaziland" if country=="Eswatini"
replace country="Hong Kong" if country=="Hong Kong, China"
replace country="Iran, Islamic Republic of" if country=="Iran (Islamic Republic of)"
replace country="Lao, People's Democratic Republic" if country=="Lao People's Democratic Republic"
replace country="Micronesia, Federated States of" if country=="Micronesia (Federated States of)"
replace country="Palestinian Territory, Occupied" if country=="Occupied Palestinian Territory"
replace country="Korea, Republic of" if country=="Republic of Korea"
replace country="Moldova, Republic of" if country=="Republic of Moldova"
replace country="Russia Federation" if country=="Russian Federation"
replace country="Republic of Serbia" if country=="Serbia"
replace country="Turkey" if country=="Türkiye"
replace country="United Kingdom" if country=="United Kingdom of Great Britain and Northern Ireland"
replace country="United States" if country=="United States of America"
replace country="Venezuela" if country=="Venezuela (Bolivarian Republic of)"
replace country="Vietnam" if country=="Viet Nam"

merge m:1 country using "H:\Research\ILO\country_codes.dta"
sort _merge country
drop if _merge==2
drop _merge
rename CodeValue countrycode
order countrycode, a(country)

** rename and label variables
rename TotalManufacturing total_manuf
rename ManagersManufacturing manag_manuf
rename ManagersISO88Manufacturing manag2_manuf
rename ProfessionalsManufacturing profe_manuf
rename OtherprofessionalsManufacturi other_manuf
rename ArmedforcesManufacturing armed_manuf
rename NCManufacturing nc_manuf
rename TotalConstruction total_const
rename ManagersConstruction manag_const
rename ManagersISO88Construction manag2_const
rename ProfessionalsConstruction profe_const
rename OtherprofessionalsConstructio other_const
rename ArmedforcesConstruction armed_const
rename NCConstruction nc_const
rename TotalMiningutilities total_mines
rename ManagersMiningutilities manag_mines
rename ManagersISO88Miningutil manag2_mines
rename ProfessionalsMiningutilitie profe_mines
rename OtherprofessionalsMiningut other_mines
rename ArmedforcesMiningutilities armed_mines
rename NCMiningutilities nc_mines
rename TotalServices total_servi
rename ManagersServices manag_servi
rename ManagersISO88Services manag2_servi
rename ProfessionalsServices profe_servi
rename OtherprofessionalsServices other_servi
rename ArmedforcesServices armed_servi
rename NCServices nc_servi

label variable manag_manuf "Managers (ISCO-08), Manufacturing" 
label variable manag2_manuf "Legislators, senior officials and managers (ISCO-88), Manufacturing" 
label variable other_manuf "Technicians and associate professionals, Manufacturing"
label variable nc_manuf "Not elsewhere classified (ISCO-08), Manufacturing"

label variable manag_const "Managers (ISCO-08),  Construction" 
label variable manag2_const "Legislators, senior officials and managers (ISCO-88),  Construction" 
label variable other_const "Technicians and associate professionals,  Construction"
label variable nc_const "Not elsewhere classified (ISCO-08),  Construction"

label variable manag_mines "Managers (ISCO-08), Mining and quarrying; Electricity, gas and water supply" 
label variable manag2_mines "Legislators, senior officials and managers (ISCO-88), Mining and quarrying; Electricity, gas and water supply" 
label variable other_mines "Technicians and associate professionals, Mining and quarrying; Electricity, gas and water supply"
label variable nc_mines "Not elsewhere classified (ISCO-08), Mining and quarrying; Electricity, gas and water supply"

label variable manag_servi "Managers (ISCO-08), Trade, Transportation, Accommodation and Food, and Business and Administrative Services" 
label variable manag2_servi "Legislators, senior officials and managers (ISCO-88), Trade, Transportation, Accommodation and Food, and Business and Administrative Services" 
label variable other_servi "Technicians and associate professionals, Trade, Transportation, Accommodation and Food, and Business and Administrative Services"
label variable nc_servi "Not elsewhere classified (ISCO-08), Trade, Transportation, Accommodation and Food, and Business and Administrative Services"

* Check no overlap two measures of managers
count if manag_manuf!=. & manag2_manuf!=.
count if manag_const!=. & manag2_const!=.
count if manag_mines!=. & manag2_mines!=.
count if manag_servi!=. & manag2_servi!=.
* no overlap
replace manag_manuf=manag2_manuf if manag_manuf==. & manag2_manuf!=.
replace manag_const=manag2_const if manag_const==. & manag2_const!=.
replace manag_mines=manag2_mines if manag_mines==. & manag2_mines!=.
replace manag_servi=manag2_servi if manag_servi==. & manag2_servi!=.
drop manag2*

label variable manag_manuf "Managers, Manufacturing" 
label variable manag_const "Managers, Construction"
label variable manag_mines "Managers, Mining and quarrying; Electricity, gas and water supply" 
label variable manag_servi "Managers, Services" 

** Further cleaning
sort country year
drop if total_manuf==. & total_servi==.

** Share of managers: manufacturing, services, non-agriculture, subtracting not classified and armed forces from total
** replace . with 0 to avoid missing values
replace armed_manuf=0 if armed_manuf==.
replace nc_manuf=0 if nc_manuf==. 
replace armed_const=0 if armed_const==.  
replace nc_const=0 if nc_const==.  
replace armed_mines=0 if armed_mines==.  
replace nc_mines=0 if nc_mines==.  
replace armed_servi=0 if armed_servi==.  
replace nc_servi=0 if nc_servi==. 

gen share_profe_manuf = (manag_manuf + profe_manuf + other_manuf)/(total_manuf - armed_manuf - nc_manuf )

gen share_profe_servi = (manag_servi + profe_servi + other_servi)/(total_servi - armed_servi - nc_servi)

gen share_profe_nonagr = (manag_manuf + profe_manuf + other_manuf + manag_servi + profe_servi + other_servi + manag_const + profe_const + other_const + manag_mines + profe_mines + other_mines)/(total_manuf + total_const + total_mines + total_servi - armed_manuf - nc_manuf - armed_const - nc_const - armed_mines - nc_mines - armed_servi - nc_servi)

** label new variables
// label variable share_prof_manuf "Share of managers & professionals, Manufacturing" 
// label variable share_prof_const "Share of managers & professionals, Construction"
// label variable share_prof_mines "Share of managers & professionals, Mining and quarrying; Electricity, gas and water supply" 
// label variable share_prof_servi "Share of managers & professionals, Services" 
// label variable share_prof_manuf

label variable share_profe_manuf "Share of managers & professionals, Manufacturing (excluding military and not classified)" 
label variable share_profe_servi "Share of managers & professionals, Services (excluding military and not classified)" 
label variable share_profe_nonagr "Share of managers & professionals, Non-agriculture (excluding military and not classified)" 

** Share of managers: manufacturing, services, non-agriculture, subtracting not classified and armed forces from total, excluding professionals (as in Akcigit et al. (2021, AER))

gen share_man_manuf = (manag_manuf)/(total_manuf - armed_manuf - nc_manuf )

gen share_man_servi = (manag_servi)/(total_servi - armed_servi - nc_servi)

gen share_man_nonagr = (manag_manuf + manag_servi + manag_const + manag_mines)/(total_manuf + total_const + total_mines + total_servi - armed_manuf - nc_manuf - armed_const - nc_const - armed_mines - nc_mines - armed_servi - nc_servi)


** label new variables
label variable share_man_manuf "Share of managers, Manufacturing (excluding military and not classified)" 
label variable share_man_servi "Share of managers, Services (excluding military and not classified)" 
label variable share_man_nonagr "Share of managers, Non-agriculture (excluding military and not classified)" 

drop total* manag* other* profe* nc* armed*

save shares_managers_sector.dta, replace




 





