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

/* Loop over years 1998 to 2003 */
forvalues x=1998/2003{

// Import Excel sheet for the year and clean data
import excel "$data\Transfermkt\penales.xlsx", sheet("`x'") firstrow clear
drop if F == .
keep Date HomeTeam AwayTeam PenAtt

// Rename and create necessary variables
rename PenAtt TeamPenAtt
egen Partido = concat(HomeTeam AwayTeam), punc(" vs ")
gen Penatt = 1

// Collapse data to sum penalty attempts by match
collapse (sum) Penatt, by(Date Partido TeamPenAtt HomeTeam AwayTeam)

gen Year = `x'

// Save the dataset and append for subsequent years
cd "$externaldata\TRANSFERMKT"
if `x' == 1998{
save PenalesAtt9803.dta,replace
}
else{
append using PenalesAtt9803
save PenalesAtt9803.dta,replace
}
}

// Standardize team names across variables
foreach var in HomeTeam AwayTeam TeamPenAtt Partido{
	replace `var' = subinstr(`var', "Albacete Balompié", "Albacete", .)
	replace `var' = subinstr(`var', "Athletic Bilbao", "Athletic Club", .)
	replace `var' = subinstr(`var', "CA ", "", .)
	replace `var' = subinstr(`var', "CD ", "", .)
	replace `var' = subinstr(`var', "CF ", "", .)
	replace `var' = subinstr(`var', "de ", "", .)
	replace `var' = subinstr(`var', "Deportivo Alavés", "Alavés", .)
	replace `var' = subinstr(`var', " CF", "", .)
	replace `var' = subinstr(`var', "FC ", "", .)
	replace `var' = subinstr(`var', " (- 2010)", "", .)
	replace `var' = subinstr(`var', "RC ", "", .)
	replace `var' = subinstr(`var', "REspanyol", "Espanyol", .)
	replace `var' = subinstr(`var', "Espanyol Barcelona", "Espanyol", .)
	replace `var' = subinstr(`var', "RM", "M", .)
	replace `var' = subinstr(`var', " Balompié", "", .)
	replace `var' = subinstr(`var', "Real Oviedo", "Oviedo", .)
	replace `var' = subinstr(`var', "Real Racing Club ", "Racing Santander", .)
	replace `var' = subinstr(`var', "Real Racing Club", "Racing Santander", .)
	replace `var' = subinstr(`var', "Real Z", "Z", .)
	replace `var' = subinstr(`var', "Real Valladolid", "Valladolid", .)
	replace `var' = subinstr(`var', " Huelva", "", .)
	replace `var' = subinstr(`var', " FC", "", .)
	replace `var' = subinstr(`var', "UD ", "", .)
	replace `var' = subinstr(`var', " (- 2013)", "", .)
	replace `var' = subinstr(`var', "Real Betis", "Betis", .)
}

// Generate and collapse penalty data
gen HomeTotPKatt = Penatt if TeamPenAtt == HomeTeam
gen AwayTotPKatt = Penatt if TeamPenAtt == AwayTeam
gen HomeTotPKcon = AwayTotPKatt
gen AwayTotPKcon = HomeTotPKatt

foreach var in HomeTotPKatt AwayTotPKatt HomeTotPKcon AwayTotPKcon{
	replace `var' = 0 if `var' == .
}

rename HomeTeam Home_Team
rename AwayTeam Away_Team

keep Home_Team Away_Team Partido Year *PKatt *PKcon

collapse (sum) HomeTotPKatt AwayTotPKatt HomeTotPKcon AwayTotPKcon, by(Partido Year Home_Team Away_Team)

cd "$externaldata"
save PenalesAtt9803.dta,replace

********************************************************************************
********************************************************************************
********************************************************************************



clear all
cls

// Loop over penalty types ("Scored" or "Missed") and years 2004-2013
foreach type in Scored Missed{
forvalues i = 2004/2013{

// Import Excel sheet for the year and process data
import excel "$data\Transfermkt\\`type'.xlsx", sheet("`i'") firstrow clear
gen Year=`i'

gen index = _n
gen indexPoss = 0

// Identify rows with penalties and keep them
forvalues i = 1(2)200{
	quiet replace indexPoss = 1 if index == `i'
}

drop if indexPoss == 0
drop index*

// Rename and create necessary variables
rename Result Home_Team
rename I Away_Team
rename Penaltytakerand PenaltyTaker

quiet gen PenaltyConc = Home_Team if Home_Team != PenaltyTaker
quiet replace PenaltyConc = Away_Team if PenaltyConc == ""

keep Matchday PenaltyTaker PenaltyConc Year *Team
order Year Matchday Home_Team Away_Team PenaltyTaker PenaltyConc

// Create variables for penalties missed or scored
if "`type'" == "Missed"{
	foreach var in PKMissed PKconcM{
		foreach local in Home Away{
			gen `local'`var'=0
			
			if "`var'"=="PKMissed"{
				quiet replace `local'`var' = 1 if `local'_Team == PenaltyTaker
			}
			else{
				quiet replace `local'`var' = 1 if `local'_Team == PenaltyConc
			}
		}
	}
}

else if "`type'" == "Scored"{
	foreach var in PKScored PKconcS{
		foreach local in Home Away{
			gen `local'`var' = 0
			
			if "`var'"=="PKScored"{
				quiet replace `local'`var' = 1 if `local'_Team == PenaltyTaker
			}
			else{
				quiet replace `local'`var' = 1 if `local'_Team == PenaltyConc
			}
		}
	}
}

// Save the dataset and append for subsequent years
cd "$externaldata\TRANSFERMKT"
if Year == 2004{
	save Penalties`type'.dta,replace
}

else{
	append using Penalties`type'
	save Penalties`type', replace
	tab Year
}
}

// Standardize team names across variables
foreach var in Home_Team Away_Team PenaltyTaker PenaltyConc{
quiet{
	replace `var' = subinstr(`var', "Albacete Balompié", "Albacete", .)	
	replace `var' = subinstr(`var', "Athletic Bilbao", "Athletic Club", .)
	replace `var' = subinstr(`var', "Atlético de Madrid", "Atlético Madrid", .)
	replace `var' = subinstr(`var', "CA Osasuna", "Osasuna", .)
	replace `var' = subinstr(`var', "Cádiz CF", "Cádiz", .)
	replace `var' = subinstr(`var', "CD Numancia", "Numancia", .)
	replace `var' = subinstr(`var', "CD Tenerife", "Tenerife", .)
	replace `var' = subinstr(`var', "Celta de Vigo", "Celta Vigo", .)
	replace `var' = subinstr(`var', "Deportivo Alavés", "Alavés", .)
	replace `var' = subinstr(`var', "Deportivo de La Coruña", "Deportivo La Coruña", .)
	replace `var' = subinstr(`var', "Elche CF", "Elche", .)
	replace `var' = subinstr(`var', "FC Barcelona", "Barcelona", .)
	replace `var' = subinstr(`var', "Getafe CF", "Getafe", .)
	replace `var' = subinstr(`var', "Gimnàstic de Tarragona", "Gimnàstic", .)
	replace `var' = subinstr(`var', "Granada CF", "Granada", .)
	replace `var' = subinstr(`var', "Hércules CF", "Hércules", .)
	replace `var' = subinstr(`var', "Levante UD", "Levante", .)
	replace `var' = subinstr(`var', "Málaga CF", "Málaga", .)
	replace `var' = subinstr(`var', "RCD Espanyol Barcelona", "Espanyol", .)
	replace `var' = subinstr(`var', "RCD Mallorca", "Mallorca", .)
	replace `var' = subinstr(`var', "Real Betis Balompié", "Betis", .)
	replace `var' = subinstr(`var', "Real Murcia CF", "Real Murcia", .)
	replace `var' = subinstr(`var', "Real Valladolid CF", "Valladolid", .)
	replace `var' = subinstr(`var', "Real Zaragoza", "Zaragoza", .)
	replace `var' = subinstr(`var', "Recreativo Huelva", "Recreativo", .)
	replace `var' = subinstr(`var', "Sevilla FC", "Sevilla", .)
	replace `var' = subinstr(`var', "UD Almería", "Almería", .)
	replace `var' = subinstr(`var', "Valencia CF", "Valencia", .)
	replace `var' = subinstr(`var', "Villarreal CF", "Villarreal", .)
	replace `var' = subinstr(`var', "Xerez CD", "Xerez", .)
}
}

sort Year Matchday
save Penalties`type',replace

}

********************************************************************************
********************************************************************************
********************************************************************************


clear all
cls

// Merge Scored and Missed data
cd "$externaldata\TRANSFERMKT"
use PenaltiesScored, clear
merge m:m Year Matchday Home_Team Away_Team using PenaltiesMissed

// Collapse data to get the number of PK scored and Missed for each team
collapse (sum) HomePKScored AwayPKScored HomePKconcS AwayPKconcS HomePKMissed AwayPKMissed HomePKconcM AwayPKconcM, by(Year Matchday Home_Team Away_Team)
sort Year Home_Team Away_Team

// Change values with wrong values
{
*Villareal Valencia 2004
replace AwayPKMissed = 1 in 64
replace HomePKconcM = 1 in 64

*Barcelona Racing 2005
replace HomePKMissed = 1 in 85
replace AwayPKconcM = 1 in 85

*Real Madrid Málaga 2008
replace HomePKMissed = 1 in 439
replace AwayPKconcM = 1 in 439

*Sevilla Athletic Club 2010
replace AwayPKMissed = 1 in 613
replace HomePKconcM = 1 in 613

*Real Madrid Sevilla 2013
replace AwayPKMissed = 1 in 882
replace HomePKconcM = 1 in 882
}

// Generate PK conceded and attempted variables
gen HomeTotPKcon = HomePKconcS + HomePKconcM
gen AwayTotPKcon = AwayPKconcS + AwayPKconcM

gen HomeTotPKatt = AwayTotPKcon
gen AwayTotPKatt = HomeTotPKcon

// Generate Match data by concatenating Home and Away team
egen Partido = concat(Home_Team Away_Team), pun(" vs ")

// Sort and Append with PenalesAtt9803
sort Year Matchday
append using $externaldata/PenalesAtt9803.dta

// Keep variables of interest and save data
keep Yea Matchday Home_Team Away_Team HomeTotPKcon AwayTotPKcon HomeTotPKatt AwayTotPKatt Partido

cd "$externaldata"
save PenaltiesConceded.dta,replace