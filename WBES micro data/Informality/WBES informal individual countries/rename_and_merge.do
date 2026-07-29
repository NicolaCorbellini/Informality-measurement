clear all 

cd "H:\Research\WBES micro data\WBES informal individual countries\original_files"

local files : dir . files "*.dta"

foreach file in `files' {
	cd "H:\Research\WBES micro data\WBES informal individual countries\original_files"
    use `file', clear

    rename l2 sc2
    rename n1a n2a
    rename n1c n2c
	
	** rename variables country and city
	decode a1 , gen(country) 
    capture confirm numeric variable a3a
    if !_rc {
        decode a3a, gen(cityx)
    }
	
	* rename variable year
	capture rename sc4y a14y
        if _rc {
			capture rename Sc4y a14y
			if _rc {
				capture rename a8y a14y
			}
		}

	
    local newname = substr("`file'", 1, length("`file'") - 4) + "renamed.dta"
	cd "H:\Research\WBES micro data\WBES informal individual countries\renamed_files"
    save `newname', replace
}

clear all

cd "H:\Research\WBES micro data\WBES informal individual countries"

use Informal-Sector-Enterprise-Surveys-Combined-Raw-Database_October_10_2024

cd "H:\Research\WBES micro data\WBES informal individual countries\renamed_files"

local files : dir . files "*.dta"
** append to comprehensive file
foreach file in `files' {
	append using `file', force
}

** cleaning
replace country="Peru" if cityx=="Arequipa" | city=="Lima"
replace country="Congo, The Democratic Republic of" if country=="DRC" |  country=="Democratic Republic of Congo" 
replace country="Burkina Faso" if country=="burkina faso  "
replace country="Cameroon" if country=="cameroon      "
replace country="Cape Verde" if country=="cape verde"
replace country="Cote d'Ivoire" if country=="Ivory Coast"
replace country="Madagascar" if country=="madagascar"
replace country="Mauritius" if country=="mauritius"


merge m:1 country using "H:\Research\WBES micro data\WBES informal individual countries\country_codes.dta"
drop if _merge==2
drop _merge

replace country_abr=CodeValue if country_abr==""

sort country a14y

keep idstd country country_abr wmedian a41a a14y cityx sc2 d4 n2a n2c n1b

cd "H:\Research\WBES micro data\WBES informal individual countries"
save informal_microdata_merged.dta, replace

tab a14y if country=="Cote d'Ivoire"
tab wmedian if a14y<=2017
 



