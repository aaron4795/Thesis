clear all
cls

********************************************************************************
/* Aaron directories */
global data="C:\Users\aaron\Desktop\GitHub\Thesis\Stata\Data"  // Define the global path for data
global externaldata="C:\Users\aaron\Desktop\GitHub\Thesis\Stata\Datasets"  // Path for external datasets
global prog="C:\Users\aaron\Desktop\GitHub\Thesis\Stata\prog"  // Path for programs
global graphs="C:\Users\aaron\Desktop\GitHub\Thesis\Stata\Graphs"  // Path for saving graphs
global tables="C:\Users\aaron\Desktop\GitHub\Thesis\Stata\Tables"  // Path for saving tables
********************************************************************************

//*FBREF DATA*//

foreach year in "9899" "9900" "0001" "0102" "0203" "0304" "0405" "0506" "0607" "0708" "0809" "0910" "1011" "1112" "1213" "1314" "1415" "1516" "1617" "1718" "1819" "1920" "2021" "2122"{
foreach stat in "STANDARD" "PORTERIA" "EXTRA" "REGULAR"{
foreach locvis in "SQ" "VS" {

// Display where we are in the loop
display "`stat'" " " "`locvis'" " " "`year'"

********************************************************************************
if "`stat'" == "STANDARD"{
// Import data and keep variables of interest
import excel "$data/FBREF/STANDARD/STANDARD `locvis' `year'.xlsx", sheet("Worksheet") cellrange(A2:W22) firstrow clear
keep Equipo PJ /*GATP*/ TP TPint TA TR
gen Season = "`year'"

// Rename variables
if "`locvis'" == "SQ"{
	rename TP PENEXEC_favor
	rename TPint TPint_favor
	rename TA TA_contra
	rename TR TR_contra
}

if "`locvis'" == "VS"{
	rename TP PENEXEC_contra
	rename TPint TPint_contra
	rename TA TA_favor
	rename TR TR_favor
}

// Append STANDARD data in one dta
cd "$externaldata\FBREF"
if "`year'" == "9899"{
	save STANDARD_`locvis'.dta,replace
}
else{
	append using STANDARD_`locvis'
	save STANDARD_`locvis'.dta,replace
}
}

********************************************************************************
********************************************************************************
********************************************************************************

if "`stat'" == "PORTERIA"{
if "`year'"!="9899"{
// Import data
import excel "$data/FBREF/PORTERIA/PORTERIA `locvis' `year'.xlsx", sheet("Worksheet") cellrange(A2:U22) firstrow clear
keep Equipo TPint PD S PC
gen Season = "`year'"

// Rename variables
if "`locvis'" == "SQ"{
	rename TPint TPint_contra
	rename PD PENEXEC_contra
	rename S PDet_contra
	rename PC PFail_contra
}

if "`locvis'" == "VS"{
	rename TPint TPint_favor
	rename PD PENEXEC_favor
	rename S PDet_favor
	rename PC PFail_favor
}

// Append PORTERIA data in one dta
cd "$externaldata\FBREF"
if "`year'" == "9900"{
	save PORTERIA_`locvis'.dta,replace
}
else{
	append using PORTERIA_`locvis'
	save PORTERIA_`locvis'.dta,replace
}

}
}


********************************************************************************
********************************************************************************
********************************************************************************
if "`stat'" == "EXTRA"{
// Import data
import excel "$data/FBREF/EXTRA/EXTRA `locvis' `year'.xlsx", sheet("Worksheet") cellrange(A2:O22) firstrow clear
keep Equipo TA TR aamarilla Fls FR PA
gen Season = "`year'"

// Rename variables
if "`locvis'" == "SQ"{
	rename TA TA_contra
	rename TR TR_contra
	rename aamarilla TA2_contra
	rename Fls Fls_cometidasPor
	rename FR Fls_recibidasContra
	rename PA Offside_contra
}

if "`locvis'" == "VS"{
	rename TA TA_favor
	rename TR TR_favor
	rename aamarilla TA2_favor
	rename Fls Fls_cometidasContra //Faltas cometidas contra el RM
	rename FR Fls_recibidasPor //Faltas recibidas por el RM
	rename PA Offside_favor
}

// Append EXTRA data in one dta
cd "$externaldata\FBREF"
if "`year'" == "9899"{
	save EXTRA_`locvis'.dta,replace
}
else{
	append using EXTRA_`locvis'
	save EXTRA_`locvis'.dta,replace
}
}

********************************************************************************
********************************************************************************
********************************************************************************

if "`stat'" == "REGULAR"{
// Import data
import excel "$data/FBREF/REGULAR/REGULAR `locvis' `year'.xlsx", sheet("Sheet1") firstrow clear
keep RL Equipo PJ PG PE PP DG
gen Season = "`year'"

// Append REGULAR data in one dta
cd "$externaldata\FBREF"
if "`year'" == "9899"{
	save REGULAR_`locvis'.dta,replace
}
else{
	append using REGULAR_`locvis'
	save REGULAR_`locvis'.dta,replace
}
}
}

}
}

foreach stat in "STANDARD" "PORTERIA" "EXTRA" "REGULAR"{
foreach locvis in "SQ" "VS" {
cd "$externaldata\FBREF"
// Import data
use `stat'_`locvis'.dta, clear

// Clean the value of the observations
replace Equipo = subinstr(Equipo, "Ã¡", "á", .)
replace Equipo = subinstr(Equipo, "Ã ", "à", .)
replace Equipo = subinstr(Equipo, "Ã©", "é", .)
replace Equipo = subinstr(Equipo, "Ã­", "í", .)
replace Equipo = subinstr(Equipo, "Ã³", "ó", .)
replace Equipo = subinstr(Equipo, "Ã±", "ñ", .)
replace Equipo = subinstr(Equipo, "GimnÃ stic", "Gimnàstic", .)
replace Equipo = subinstr(Equipo, "Deportivo La Coruña", "La Coruña", .)
replace Equipo = subinstr(Equipo, "Real Betis", "Betis", .)

sort Season Equipo

if "`locvis'" == "VS"{
	replace Equipo = subinstr(Equipo, "vs. ", "", .)
}

// Merge data and save in one dta, separating by their source SQ and VS
cd "$externaldata"
if "`stat'" == "STANDARD"{
	save STATS_`locvis'.dta, replace
}
else{
	cd "$externaldata"
	merge 1:1 Equipo Season using STATS_`locvis', nogen
	save STATS_`locvis'.dta, replace
}
}
}


********************************************************************************
********************************************************************************
********************************************************************************
//*TRANSFERMKT DATA*//

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

********************************************************************************
********************************************************************************
********************************************************************************
//*MERGING DATA*//
//*Squad data*//
clear all
cls

// Import data
cd "$externaldata"
use STATS_SQ.dta, clear

// Merge with Transfermkt info and update values
merge 1:1 Equipo Season using SZN_TRANSFMKT_9814.dta, replace update
gen TA_favor = .
gen TR_favor = .
gen TA2_favor = .

// Keep variables of interest
foreach var in PENEXEC_favor PENEXEC_contra MissedConcededpenalties Rating PenaltiesreceivedMissed PDet_contra PFail_contra{
	drop `var'
}

// Order, sort and save data
order RL Equipo Season PJ TA_contra TR_contra TA2_contra TA_favor TR_favor TA2_favor TPint_favor TPint_contra Fls_cometidasPor Fls_recibidasContra Offside_contra PG PE PP DG
sort Season RL
drop _merge
save SQF, replace


********************************************************************************
********************************************************************************
********************************************************************************
//*VS Data*//
clear all
cls

// Import data and keep variables of interest
use "$externaldata\STATS_VS.dta", clear
replace PJ=PJ*2
keep Equipo Season TA_favor TR_favor TA2_favor RL PG PE PP DG

// Merge with cards adjustment data
cd "$externaldata"
merge 1:1 Equipo Season using FAVOR_CARDSNFOULS.dta, update

// Sort and save data
sort Season RL
save VSF.dta,replace

********************************************************************************
********************************************************************************
********************************************************************************
//*Merging both datasets*/
cd "$externaldata"
use VSF.dta, clear
drop _merge
merge 1:1 Equipo Season using SQF, replace update nogen

order RL Equipo Season PJ TA_contra TR_contra TA2_contra TA_favor TR_favor TA2_favor TPint_favor TPint_contra Fls_cometidasPor Fls_recibidasContra Offside_contra PG PE PP DG
sort Season RL

// Add Year variable
{
gen Year = 1998 if Season == "9899"
replace Year = 1999 if Season == "9900"
replace Year = 2000 if Season == "0001"
replace Year = 2001 if Season == "0102"
replace Year = 2002 if Season == "0203"
replace Year = 2003 if Season == "0304"
replace Year = 2004 if Season == "0405"
replace Year = 2005 if Season == "0506"
replace Year = 2006 if Season == "0607"
replace Year = 2007 if Season == "0708"
replace Year = 2008 if Season == "0809"
replace Year = 2009 if Season == "0910"
replace Year = 2010 if Season == "1011"
replace Year = 2011 if Season == "1112"
replace Year = 2012 if Season == "1213"
replace Year = 2013 if Season == "1314"
replace Year = 2014 if Season == "1415"
replace Year = 2015 if Season == "1516"
replace Year = 2016 if Season == "1617"
replace Year = 2017 if Season == "1718"
replace Year = 2018 if Season == "1819"
replace Year = 2019 if Season == "1920"
replace Year = 2020 if Season == "2021"
replace Year = 2021 if Season == "2122"
}

// Add labels to the variables
{
label var TPint_favor "Tiros penales intentados a favor"
label var TA_contra "Tarjetas Amarillas en contra"
label var TR_contra "Tarjetas Rojas en contra"
label var TPint_contra "Tiros penales intentados en contra"
label var TA_favor "Tarjetas Amarillas a favor"
label var TR_favor "Tarjetas Rojas a favor"
label var TA2_contra "Segunda tarjeta amarilla en contra"
label var Fls_cometidasPor "Faltas cometidas por" //Faltas cometidas por el RM
label var Offside_contra "Offsides marcados en contra"
label var TA2_favor "Segunda tarjeta amarilla a favor"
label var Equipo "Equipo"
label var PJ "Partidos jugados"
label var RL "Posición en la tabla"
label var PG "Partidos ganados"
label var PE "Partidos empatados"
label var PP "Partidos perdidos"
label var DG "Diferencia de goles"
}

// Save merged data
cd "$externaldata"
save SQVS.dta, replace