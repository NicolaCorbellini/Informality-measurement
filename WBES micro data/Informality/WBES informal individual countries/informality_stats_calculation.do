clear all
cd "H:\Research\WBES micro data\WBES informal individual countries"
use standard-informal-micro-merge.dta

* Count (weighed) formal and informal firms and drop city/regions with only formal or informal firms
bysort city_region: egen num_informal = total((formal == 0) * weight)
bysort city_region: egen num_formal = total((formal == 1) * weight)
drop if num_informal == 0 | num_formal == 0
* Calculate the (weighted) total number of firms in each city/region
bysort city_region: egen total_firms = total(weight)

gen share_formal = num_formal / total_firms
gen share_informal = num_informal / total_firms

* Calculate the number of employees in formal and informal firms by city/region
bysort city_region: egen employees_formal = total((formal == 1) * employees * weight)
bysort city_region: egen employees_informal = total((formal == 0) * employees * weight)
bysort city_region: egen employees_total = total(employees * weight)

gen share_formal_empl = employees_formal / employees_total
gen share_informal_empl = employees_informal / employees_total

collapse (mean) share_informal_empl, by(country city_region)
list country city_region share_informal_empl, noobs

* Calculate sales 
bysort city_region: egen sales_formal = total((formal == 1) * sales * weight)
bysort city_region: egen sales_informal = total((formal == 0) * sales * weight)
bysort city_region: egen sales_total = total(sales * weight)

gen share_formal_sales = sales_formal / sales_total
gen share_informal_sales = sales_informal / sales_total

collapse (mean) share_formal_sales, by(country city_region)
list country city_region share_formal_sales, noobs


count
sum sales wage_bill electricity if sales !=. & electricity!=.
sum sales wage_bill intermediate if sales !=. & intermediate!=.

collapse (mean) share_formal, by(country city_region)
list country city_region share_formal, noobs

