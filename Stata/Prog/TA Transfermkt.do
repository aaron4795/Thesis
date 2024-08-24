clear all
cls

********************************************************************************
/* Aaron directories */
global data="C:\Users\aaron\Desktop\GitHub\Thesis\Data"  // Define the global path for data
global externaldata="C:\Users\aaron\Desktop\GitHub\Thesis\Datasets"  // Path for external datasets
global prog="C:\Users\aaron\Desktop\GitHub\Thesis\prog"  // Path for programs
global graphs="C:\Users\aaron\Desktop\GitHub\Thesis\graphs"  // Path for saving graphs
global tables="C:\Users\aaron\Desktop\GitHub\Thesis\tables"  // Path for saving tables
********************************************************************************

foreach year in "9899" "9900" "0001" "0102" "0203" "0304" "0405" "0506" "0607" "0708" "0809" "0910" "1011" "1112" "1213" "1314" "1415" /*"1516" "1617" "1718" "1819" "1920" "2021" "2122"*/ {

// Import and keep variables of interest
import excel "C:\Users\aaron\Desktop\GitBuh\Data\Transfermkt\TRANSFERMKT DATA.xlsx", sheet("`year'") firstrow clear
foreach vardel in Points Defencerate Matches TATR A{
	drop `vardel'
}

// Drop the "Fouls" variable for specific years
if "`year'"=="0910" | "`year'"=="1011" | "`year'"=="1112" | "`year'"=="1213" | "`year'"=="1314" | "`year'"=="1415"{
drop Fouls
}

rename E TA2

// Adjust the value of "TA" by adding "TA2"
replace TA=TA+TA2

// Rename variables for clarity
rename Club Equipo
rename TA TA_contra
rename TR TR_contra
rename TA2 TA2_contra
rename SuccessfulConcededPenalties PENEXEC_contra
rename Concededpenalties TPint_contra

label var TPint_contra "Tiros penales intentados en contra"

// Rename specific variables for the first season year "9899"
if "`year'"=="9899"{
	rename Penaltiesreceived TPint_favor
	rename PenaltiesreceiverScored PENEXEC_favor
}

// Rename variables for the specific years where these variables are present
if "`year'"=="0910" | "`year'"=="1011" | "`year'"=="1112" | "`year'"=="1213" | "`year'"=="1314" | "`year'"=="1415"{
	rename CaughtOffside Offside_contra
	rename Fouled Fls_recibidasContra
}

*rename TATR TAplusTR
*rename A Posicion
*label var Posicion "Posición en la tabla"

// Standarize the name of the teams
quietly{
replace Equipo = subinstr(Equipo, "Albacete Balompié", "Albacete", .)
replace Equipo = subinstr(Equipo, "Athletic Bilbao", "Athletic Club", .)
replace Equipo = subinstr(Equipo, "Atlético de Madrid", "Atlético Madrid", .)
replace Equipo = subinstr(Equipo, "CA Osasuna", "Osasuna", .)
replace Equipo = subinstr(Equipo, "Cádiz CF", "Cádiz", .)
replace Equipo = subinstr(Equipo, "CD Numancia", "Numancia", .)
replace Equipo = subinstr(Equipo, "CD Tenerife", "Tenerife", .)
replace Equipo = subinstr(Equipo, "Celta de Vigo", "Celta Vigo", .)
replace Equipo = subinstr(Equipo, "CF Extremadura (- 2010)", "Extremadura", .)
replace Equipo = subinstr(Equipo, "Córdoba CF", "Córdoba", .)
replace Equipo = subinstr(Equipo, "Deportivo Alavés", "Alavés", .)
replace Equipo = subinstr(Equipo, "Deportivo de La Coruña", "La Coruña", .)
replace Equipo = subinstr(Equipo, "Elche CF", "Elche", .)
replace Equipo = subinstr(Equipo, "FC Barcelona", "Barcelona", .)
replace Equipo = subinstr(Equipo, "Getafe CF", "Getafe", .)
replace Equipo = subinstr(Equipo, "Gimnàstic de Tarragona", "Gimnàstic", .)
replace Equipo = subinstr(Equipo, "Granada CF", "Granada", .)
replace Equipo = subinstr(Equipo, "Hércules CF", "Hércules", .)
replace Equipo = subinstr(Equipo, "Levante UD", "Levante", .)
replace Equipo = subinstr(Equipo, "Málaga CF", "Málaga", .)
replace Equipo = subinstr(Equipo, "Racing Santander", "Racing Sant", .)
replace Equipo = subinstr(Equipo, "RCD Espanyol Barcelona", "Espanyol", .)
replace Equipo = subinstr(Equipo, "RCD Mallorca", "Mallorca", .)
replace Equipo = subinstr(Equipo, "Real Betis Balompié", "Betis", .)
replace Equipo = subinstr(Equipo, "Real Murcia CF", "Real Murcia", .)
replace Equipo = subinstr(Equipo, "Real Oviedo", "Oviedo", .)
replace Equipo = subinstr(Equipo, "Real Valladolid", "Valladolid", .)
replace Equipo = subinstr(Equipo, "Real Zaragoza", "Zaragoza", .)
replace Equipo = subinstr(Equipo, "Recreativo Huelva", "Recreativo", .)
replace Equipo = subinstr(Equipo, "SD Eibar", "Eibar", .)
replace Equipo = subinstr(Equipo, "Sevilla FC", "Sevilla", .)
replace Equipo = subinstr(Equipo, "UD Almería", "Almería", .)
replace Equipo = subinstr(Equipo, "UD Las Palmas", "Las Palmas", .)
replace Equipo = subinstr(Equipo, "UD Salamanca (- 2013)", "Salamanca", .)
replace Equipo = subinstr(Equipo, "Valencia CF", "Valencia", .)
replace Equipo = subinstr(Equipo, "Valladolid CF", "Valladolid", .)
replace Equipo = subinstr(Equipo, "Villarreal CF", "Villarreal", .)
replace Equipo = subinstr(Equipo, "Xerez CD", "Xerez", .)
}

// Generate a variable for the season year and label it
gen Season="`year'"
label var Season "Temporada"

// Save and append data in one dta
cd "$externaldata"
if "`year'" == "9899"{
	// Save the first year dataset
	save SZN_TRANSFMKT_9814.dta, replace
}
else{
	// Append data for subsequent years
	append using SZN_TRANSFMKT_9814
	save SZN_TRANSFMKT_9814.dta, replace
}

}

// Drop unnecessary variables
drop TA_favor-TA2_favor

// Save the final dataset, replacing any existing one
save SZN_TRANSFMKT_9814.dta, replace