clear all 
cd "H:\Research\WBES micro data\WBES informal individual countries"
use informal_microdata_merged

** rename variable for better visualization
rename a14y year
rename d4 sales
rename n2a wage_bill
rename n2c electricity
order year sales wage_bill electricity, a(country_abr)

** missing values
replace sales=. if sales==-9
replace wage_bill=. if wage_bill==-7 | wage_bill==-9
replace electricity=. if electricity==-7 | electricity==-9
replace electricity=0 if electricity==. & wage_bill!=. // replace missing electricity with 0

** value added calculation
gen va = sales - wage_bill - electricity 
gen va2 = sales - wage_bill

sum va, det
sum va2, det

