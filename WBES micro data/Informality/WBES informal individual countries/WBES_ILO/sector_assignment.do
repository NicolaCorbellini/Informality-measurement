** The following are informal WBES where the sector is too granular and it does not exist a services-manufacturing variable. With the help of LLM, I'm assigning the sector variable (a41) and encoding it (a41a). 
clear all

** clean data for Nepal (sector missing)
cd "C:\Users\nzc5436\Desktop\WBES micro data\Informality\WBES informal individual countries\original_files"

use Nepal-2009-Informal-full-data-

drop a41 a41a
gen a41 = ""
replace a41 = "Re-selling goods (Services)" if d1x == "ACCOMODATION" | ///
    d1x == "BEVERAGE" | ///
    d1x == "BICYCLE REPAIR" | ///
    d1x == "CYCLE REPAIR" | ///
    d1x == "DRY CLEANERS" | ///
    d1x == "ELECTRICAL REPARING" | ///
    d1x == "EMBROIDARY" | ///
    d1x == "EMBROIDERY" | ///
	d1x == "FOOD" | ///
    d1x == "FOOD AND BEVERAGE" | ///
    d1x == "GIFT ITEMS" | ///
    d1x == "GRILL" | ///
	d1x == "GROCERY" | ///
    d1x == "LAUNDARY" | ///
	d1x == "MILK" | ///
    d1x == "MOBILE REPAIR" | ///
    d1x == "MOTOR BODY WORKSHOP" | ///
    d1x == "MOTOR CYCLE REPAIR" | ///
    d1x == "MOTOR CYCLE REPAIRING" | ///
    d1x == "MOTOR REPAIRING" | ///
    d1x == "NOODLES" | ///
    d1x == "PHOTOCOPY" | ///
    d1x == "REPAIRING VEHICLES" | ///
	d1x == "RICE" | ///
    d1x == "SALTY SNACKS" | ///
	d1x == "SWEETS" | ///
    d1x == "TAILOR" | ///
    d1x == "TAILORING" | ///
    d1x == "TAILORS" | ///
	d1x == "TEA" | ///
    d1x == "TEA AND BISCUITS" | ///
    d1x == "THANKA TAILORING"| ///
	d1x == "TOBACCO" 

replace a41 = "Making goods (Manufacturing)" if d1x == "BAKERY" | ///
    d1x == "BED (FURNITURE)" | ///
    d1x == "CLOTHING" | ///
    d1x == "COSMETICS" | ///
    d1x == "FURNITURE" | ///
    d1x == "HARD- WARE" | ///
    d1x == "MANUFACTURE OF JEWELLERY" | ///
    d1x == "MEAT DISHES" | ///
    d1x == "METAL PRODUCTS" | ///
    d1x == "METAL WASTE $ SCRAP" | ///
    d1x == "READYMADE GARMENTS" | ///
    d1x == "SHAMPOO" | ///
    d1x == "WOMEN'S CLOTHING" | ///
    d1x == "WOMEN'S WEARING APPAREL" | ///
    d1x == "WOOD" | ///
    d1x == "WOOLEN GLOVES"
	
encode a41, gen (a41a)
	
save Nepal-2009-Informal-full-data-.dta, replace

clear all
** Burkina Faso
use Burkina-Faso-2009-Informal-full-data-
drop a41 a41a
gen a41 = ""

* Replace special characters
replace d1x = subinstr(d1x, char(225), "a", .) // Replace "á" with "a"
replace d1x = subinstr(d1x, char(224), "a", .) // Replace "à" with "a"
replace d1x = subinstr(d1x, char(234), "e", .) // Replace "ê" with "e"
replace d1x = subinstr(d1x, char(233), "e", .) // Replace "é" with "e"

* Assign sectors to manufacturing
replace a41 = "Making goods (Manufacturing)" if d1x == "ATELIER DE SOUDURE ( fer )" | /// * Welding workshop (iron)
d1x == "CONFECTION DE CHAISE ( MENUISIER )" | /// * Chair making (Carpenter)
d1x == "Confection d'outillage metallique" | /// * confection means making
d1x == "Confection de chaises" | ///
d1x == "Confection de drap a base de pagne traditionnels" | ///
d1x == "Confection de meubles" | ///
d1x == "CONSTRUCTION" | /// * Construction
d1x == "COUITURE" | /// * Sewing
d1x == "COURURE" | /// * Sewing
d1x == "COUTURE" | ///
d1x == "PRODUCTION DE L'EAU MINERALE EN SACHETS" | /// * Production of mineral water in sachets
d1x == "TEXTILE ARTISANAL ( PAGNE TRADITIONNEL )" | /// * Traditional textile (Pagne)
d1x == "TOREFACTION DE CAFE" | /// * Coffee roasting
d1x == "TRANSFORMATION DE JUS A GRANDE ECHELLE" | /// * Large-scale juice processing
d1x == "TRANSFORMATION DE JUS DE A GRANDE ECHELLE" | /// * Large-scale juice processing
d1x == "TRANSFORMATION DE SAVON" | /// * Soap processing
d1x == "TRANSFORMATION DE SAVON ( SAPONIFICATION )" | /// * Soap processing (Saponification)
d1x == "TRANSFORMATION ET PRODUCTION DE JUS DE FRUITS" | /// * Processing and production of juice
d1x == "TRANSFORMATION MUNI PRESSE ( HUILERIE )" | /// * Processing with press (Oil mill)
d1x == "UNITE DE PRODUCTION DE MANGUE SECHETS" | /// * Mango drying production unit
d1x == "Fabrication de zoom koom" | /// * Making zoom koom (a traditional drink made from millet)
d1x == "Fabrication du soubala" | /// * Making soubala (a traditional seasoning made from African locust beans)
d1x == "Fabriquations de meuble" | /// * Making furniture
d1x == "SOUDURE (FER)" | /// * Welding (iron)
d1x == "Soudure" /// * Welding

replace a41 = "Re-selling goods (Services)" if a41 == "" 

encode a41, gen (a41a)

save Burkina-Faso-2009-Informal-full-data-.dta, replace

clear all
** Cameroon
use Cameroon-2009-Informal-full-data-
drop a41 a41a
gen a41 = ""

* Replace special characters
replace d1x = subinstr(d1x, char(225), "a", .) // Replace "á" with "a"
replace d1x = subinstr(d1x, char(224), "a", .) // Replace "à" with "a"
replace d1x = subinstr(d1x, char(234), "e", .) // Replace "ê" with "e"
replace d1x = subinstr(d1x, char(233), "e", .) // Replace "é" with "e"

* Assign sectors to manufacturing
replace a41 = "Making goods (Manufacturing)" if d1x == "Anti_vol forgés" | /// * Making anti-theft devices
d1x == "Ciment" | /// * Cement
d1x == "Confection des articles d'habillements (tenus)" | /// * Making clothing items
d1x == "Confection des beignets au laits" | /// * Making milk donuts
d1x == "Confection des habits" | /// * Making clothes
d1x == "Confection des rideaux de maison" | /// * Making household curtains
d1x == "Confection des robes de mariages" | /// * Making wedding dresses
d1x == "Confection des vetements" | /// * Making clothes
d1x == "Confectiondes vetements" | /// * Making clothes
d1x == "Couture (tissu)" | /// * Sewing (fabric)
d1x == "Couture femme" | /// * Women's sewing
d1x == "Coutures des vetements" | /// * Sewing clothes
d1x == "Fabrication des antivols" | /// * Making anti-theft devices
d1x == "Fabrication des cercueils" | /// * Making coffins
d1x == "Fabrication des chaises" | /// * Making chairs
d1x == "Fabrication des chaussures" | /// * Making shoes
d1x == "Fabrication des lits" | /// * Making beds
d1x == "Fabrication des meubles" | /// * Making furniture
d1x == "Fabrication des parpaings" | /// * Making concrete blocks
d1x == "Fabrication et unite de vente(styliste,modeliste" | /// * Making and selling unit (stylist..)
d1x == "La fabrication des chaussures" | /// * Making shoes
d1x == "Les tables et chaises en bis pour les bars" | /// * Making tables and chairs for schools
d1x == "Menuiserie" | /// * Carpentry
d1x == "Moulin a ecraser" | /// * Grinding mill
d1x == "Ouvrages metaliques" | /// * Metal works
d1x == "Rebobinage des cables et pieces"  /// * Rewinding cables and parts

replace a41 = "Re-selling goods (Services)" if a41 == "" 

encode a41, gen (a41a)

save Cameroon-2009-Informal-full-data-.dta, replace

clear all
** Cape Verde
use Cape-Verde-2009-Informal-full-data-
drop a41 a41a
gen a41 = ""

* Replace special characters
replace d1x = subinstr(d1x, char(225), "a", .) // Replace "á" with "a"
replace d1x = subinstr(d1x, char(224), "a", .) // Replace "à" with "a"
replace d1x = subinstr(d1x, char(234), "e", .) // Replace "ê" with "e"
replace d1x = subinstr(d1x, char(233), "e", .) // Replace "é" with "e"
replace d1x = subinstr(d1x, char(231), "c", .) // Replace "ç" with "c"
replace d1x = subinstr(d1x, char(227), "a", .) // Replace "ã" with "a"

* Assign sectors to manufacturing
replace a41 = "Making goods (Manufacturing)" if d1x == "Cadeiras" | /// * Chairs
d1x == "Cama" | /// * Bed
d1x == "Chinelos/Sapatos" | /// * Slippers/Shoes
d1x == "Costurar roupas" | /// * Sewing clothes
d1x == "Grades" | /// * Grills
d1x == "Mobiliarios de Madeira" | /// * Wooden furniture
d1x == "Moveis" | /// * Furniture
d1x == "Portas" | /// * Doors
d1x == "Portas de ferro" | /// * Iron doors
d1x == "Portas, janelas e Varandas de ferro" | /// * Iron doors, windows, and balconies
d1x == "armario de cozinha" | /// * Kitchen cabinet
d1x == "artesanato" | /// * Handicrafts
d1x == "camas de ferro" | /// * Iron beds
d1x == "confeccao de enfeites para festas" | /// * Making party decorations
d1x == "cortes e costuras-bordados e rendas" | /// * Cutting and sewing - embroidery and lace
d1x == "costura" | /// * Sewing
d1x == "pasteis de milho" | /// * Corn pastries
d1x == "portao de ferro" | /// * Iron gate
d1x == "producao de artesanato(colaes,pulseir..)" | /// * Production of handicrafts (necklaces, bracelets, etc.)
d1x == "producao de queijo" | /// * Cheese production
d1x == "sapateira" | /// * Shoemaker
d1x == "vestuario/costura"  /// * Clothing/sewing


replace a41 = "Re-selling goods (Services)" if a41 == "" 

encode a41, gen (a41a)

save Cape-Verde-2009-Informal-full-data-.dta, replace

clear all
** Cote d'Ivoire
use C-te-d-Ivoire-2009-Informal-full-data-
drop a41 a41a
gen a41 = ""

replace a41 = "Making goods (Manufacturing)" if a5<=45 // 45 is construction
replace a41 = "Re-selling goods (Services)" if a41 == "" 

encode a41, gen (a41a)
save C-te-d-Ivoire-2009-Informal-full-data-, replace

clear all
** Madagascar
use Madagascar-2009-Informal-full-data-
drop a41 a41a
gen a41 = ""

replace a41 = "Making goods (Manufacturing)" if a5<=45 // 45 is construction
replace a41 = "Re-selling goods (Services)" if a41 == "" 

encode a41, gen (a41a)
save Madagascar-2009-Informal-full-data-, replace

clear all
** Mauritius
use Mauritius-2009-Informal-full-data-
drop a41 a41a
gen a41 = ""

replace a41 = "Making goods (Manufacturing)" if a5<=45 // 45 is construction
replace a41 = "Re-selling goods (Services)" if a41 == "" 

encode a41, gen (a41a)
save Mauritius-2009-Informal-full-data-, replace

clear all
** Kenya
use KenyaInformal-2013-data-
drop a41 a41a
gen a41 = ""

replace a41 = "Making goods (Manufacturing)" if sc2a<=7 // check sc2a
replace a41 = "Re-selling goods (Services)" if a41 == "" 

encode a41, gen (a41a)
save KenyaInformal-2013-data-, replace

