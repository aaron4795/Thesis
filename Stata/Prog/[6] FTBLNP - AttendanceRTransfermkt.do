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

forvalues i = 2001/2021{
// Define auxiliary variable
local j = `i' + 1
display "`i'-`j'"
display `season'

// Import data and keep obs of interest
import excel "$data\FootballLineups\Aux0102-1415.xlsx", sheet("`i'`j'") clear
keep if strpos(A, "/match/") | strpos(A, "/team/")

// Clean the values of the obs
replace A = subinstr(A, "/team/" , "", .)
replace A = subinstr(A, "-" , " ", .)
replace A = subinstr(A, "/La Liga `i'  `j'/", "", .)

// Generate auxiliary index
gen index = .
replace index = 1 if strpos(A, "match")
replace index = 2 if index[_n-1] == 1

rename A hometeam

// Define the home and away teams
gen awayteam = hometeam[_n+2] if index == . & strpos(hometeam, "match") == 0
gen last = hometeam[_n+1] if index == .

// Keep obs of interest
keep if index == .
drop if strpos(awayteam, "match")

// Define the match 
egen match = concat(hometeam away), punc(" vs ")

// Generate URL for the match
gen inlink = "https://m.football-lineups.com"
egen url = concat(inlink last)

// Keep and order relevant variables
keep home away match url
gen Season = "`i'`j'"
order url match hometeam awayteam Season

// Save and append data in one dta
cd "$externaldata/FootballLineups"
if `i' == 2001{
	save AUXLINKS.dta, replace
}
else{
	append using AUXLINKS
	save AUXLINKS.dta, replace
	
}
}


********************************************************************************
//*FOOTBALL LINEUPS DATA*//

forvalues i=1/56{
// Import data
import excel "$data\FootballLineups\HACKIN\HACKIN`i'.xlsx", sheet("Sheet 1") firstrow clear

// Rename variables
rename X1 Home_Team
rename X2 Stats
rename X3 Away_Team

// Save and append in one dta
cd "$externaldata\FootballLineups"
if `i'==1{
	save StatsFL.dta,replace
}
else{
	append using StatsFL
	save StatsFL.dta,replace
}
}

// Merge with match and url information
cd "$externaldata\FootballLineups"
merge m:m url using AUXLINKS
keep if _merg==3
sort url Stats

// Keep variables and obs of interest
keep if Stats== "Offsides" | Stats== "% possession" | Stats== "Fouls"

drop _merge
gen index=_n

// Clean obs
replace Stats = subinstr(Stats, " ", "", .)
replace Stats = subinstr(Stats, "%", "", .)

// Adjust to have data for away and local in different variables
reshape wide Home Away, i(url match home away Sea index) j(Stats) string

foreach i in Home Away{
	replace `i'_TeamFouls = `i'_TeamFouls[_n+1]
	replace `i'_TeamOffsides = `i'_TeamOffsides[_n+2]
	replace `i'_Teampossession = subinstr(`i'_Teampossession, "%", "", .)
	
	destring Home*, replace
	destring Away*, replace

	rename `i'_Teampossession `i'Possession
	rename `i'_TeamFouls `i'Fouls
	rename `i'_TeamOffsides `i'Offsides
}

// Drop uneeded variables and obs
drop if HomeFouls == . & AwayFouls == . & HomeOffsides == . & AwayOffsides == .
drop index

// Generate variables that measure how many times the team was fouled
gen HomeFld = AwayFouls
gen AwayFld = HomeFouls

// Order variables
order Season hometeam awayteam match *Possession *Fouls *Fld *Offsides

************************************************************************************
************************************************************************************
************************************************************************************

// Adjusting values as there were errors
{
*Atlético Madrid vs Deportivo La Coruña 2005/06
replace HomePoss = 53 if match == "Atlético Madrid vs Deportivo La Coruña" & Sea == "20052006"
replace AwayPoss = 47 if match == "Atlético Madrid vs Deportivo La Coruña" & Sea == "20052006"
replace HomeFoul = 25 if match == "Atlético Madrid vs Deportivo La Coruña" & Sea == "20052006"
replace AwayFoul = 26 if match == "Atlético Madrid vs Deportivo La Coruña" & Sea == "20052006"
replace HomeFld = 26 if match == "Atlético Madrid vs Deportivo La Coruña" & Sea == "20052006"
replace AwayFld = 25 if match == "Atlético Madrid vs Deportivo La Coruña" & Sea == "20052006"
 
 
*Atlético Madrid vs Sevilla 2005/06  
replace HomePoss = 68 if match == "Atlético Madrid vs Sevilla" & Sea == "20052006"
replace AwayPoss = 32 if match == "Atlético Madrid vs Sevilla" & Sea == "20052006"
replace HomeFoul = 13 if match == "Atlético Madrid vs Sevilla" & Sea == "20052006"
replace AwayFoul = 13 if match == "Atlético Madrid vs Sevilla" & Sea == "20052006"
replace HomeFld = 13 if match == "Atlético Madrid vs Sevilla" & Sea == "20052006"
replace AwayFld = 13 if match == "Atlético Madrid vs Sevilla" & Sea == "20052006"
replace HomeOff = 1 if match == "Atlético Madrid vs Sevilla" & Sea == "20052006"
replace AwayOff = 3 if match == "Atlético Madrid vs Sevilla" & Sea == "20052006"
 
 
*Zaragoza Real Madrid 2006/07 
replace HomePossession = 45 if match == "Zaragoza vs Real Madrid" & Sea == "20062007"
replace AwayPossession = 55 if match == "Zaragoza vs Real Madrid" & Sea == "20062007"
replace HomeOffsides = 4 if match == "Zaragoza vs Real Madrid" & Sea == "20062007"
replace AwayOffsides = 3 if match == "Zaragoza vs Real Madrid" & Sea == "20062007"


*20062007 Atlético Madrid vs Sevilla
replace HomePossession = 59 if match == "Atlético Madrid vs Sevilla" & Sea == "20062007"
replace AwayPossession = 41 if match == "Atlético Madrid vs Sevilla" & Sea == "20062007"
replace HomeFouls = 23 if match == "Atlético Madrid vs Sevilla" & Sea == "20062007"
replace AwayFouls = 16 if match == "Atlético Madrid vs Sevilla" & Sea == "20062007"
replace HomeFld = 16 if match == "Atlético Madrid vs Sevilla" & Sea == "20062007"
replace AwayFld = 23 if match == "Atlético Madrid vs Sevilla" & Sea == "20062007"
replace HomeOffsides = 0 if match == "Atlético Madrid vs Sevilla" & Sea == "20062007"
replace AwayOffsides = 4 if match == "Atlético Madrid vs Sevilla" & Sea == "20062007"

 
 
*Sevilla vs Levante 2006/07  
replace HomePoss = 59 if match == "Sevilla vs Levante" & Sea == "20062007"
replace AwayPoss = 41 if match == "Sevilla vs Levante" & Sea == "20062007"
replace HomeFoul = 18 if match == "Sevilla vs Levante" & Sea == "20062007"
replace AwayFoul = 25 if match == "Sevilla vs Levante" & Sea == "20062007"
replace HomeFld = 25 if match == "Sevilla vs Levante" & Sea == "20062007"
replace AwayFld = 18 if match == "Sevilla vs Levante" & Sea == "20062007"
replace HomeOff = 2 if match == "Sevilla vs Levante" & Sea == "20062007"
replace AwayOff = 4 if match == "Sevilla vs Levante" & Sea == "20062007"


*2006/07 Levante vs Valencia
//Checar datos

*Real Murcia Athletic Club 2007/08
replace HomePossession = 55 if match == "Real Murcia vs Athletic Club" & Sea == "20072008"
replace AwayPossession = 45 if match == "Real Murcia vs Athletic Club" & Sea == "20072008"
replace HomeFouls = 20 if match == "Real Murcia vs Athletic Club" & Sea == "20072008"
replace AwayFouls = 13 if match == "Real Murcia vs Athletic Club" & Sea == "20072008"
replace HomeFld = 13 if match == "Real Murcia vs Athletic Club" & Sea == "20072008"
replace AwayFld = 20 if match == "Real Murcia vs Athletic Club" & Sea == "20072008"
replace HomeOffsides = 6 if match == "Real Murcia vs Athletic Club" & Sea == "20072008"
replace AwayOffsides = 3 if match == "Real Murcia vs Athletic Club" & Sea == "20072008"


*Real Murcia Mallorca 2007/08*Real Murcia Mallorca 2007/08
replace HomePossession = 56 if match == "Real Murcia vs Mallorca" & Sea == "20072008"
replace AwayPossession = 44 if match == "Real Murcia vs Mallorca" & Sea == "20072008"
replace HomeFouls = 19 if match == "Real Murcia vs Mallorca" & Sea == "20072008"
replace AwayFouls = 18 if match == "Real Murcia vs Mallorca" & Sea == "20072008"
replace HomeFld = 18 if match == "Real Murcia vs Mallorca" & Sea == "20072008"
replace AwayFld = 19 if match == "Real Murcia vs Mallorca" & Sea == "20072008"
replace HomeOffsides = 4 if match == "Real Murcia vs Mallorca" & Sea == "20072008"
replace AwayOffsides = 5 if match == "Real Murcia vs Mallorca" & Sea == "20072008"


*Sevilla Valladolid 2007/08*Sevilla Valladolid 2007/08
replace HomePossession = 46 if match == "Sevilla vs Valladolid" & Sea == "20072008"
replace AwayPossession = 54 if match == "Sevilla vs Valladolid" & Sea == "20072008"
replace HomeFouls = 16 if match == "Sevilla vs Valladolid" & Sea == "20072008"
replace AwayFouls = 13 if match == "Sevilla vs Valladolid" & Sea == "20072008"
replace HomeFld = 13 if match == "Sevilla vs Valladolid" & Sea == "20072008"
replace AwayFld = 16 if match == "Sevilla vs Valladolid" & Sea == "20072008"
replace HomeOffsides = 6 if match == "Sevilla vs Valladolid" & Sea == "20072008"
replace AwayOffsides = 2 if match == "Sevilla vs Valladolid" & Sea == "20072008"


*Espanyol Real Murcia 2007/08*Espanyol Real Murcia 2007/08
replace HomePossession = 63 if match == "Espanyol vs Real Murcia" & Sea == "20072008"
replace AwayPossession = 37 if match == "Espanyol vs Real Murcia" & Sea == "20072008"
replace HomeFouls = 21 if match == "Espanyol vs Real Murcia" & Sea == "20072008"
replace AwayFouls = 20 if match == "Espanyol vs Real Murcia" & Sea == "20072008"
replace HomeFld = 20 if match == "Espanyol vs Real Murcia" & Sea == "20072008"
replace AwayFld = 21 if match == "Espanyol vs Real Murcia" & Sea == "20072008"
replace HomeOffsides = 5 if match == "Espanyol vs Real Murcia" & Sea == "20072008"
replace AwayOffsides = 4 if match == "Espanyol vs Real Murcia" & Sea == "20072008"

*Sporting Gijón Barcelona 2008/09
replace HomePoss = 32 if match == "Sporting Gijón vs Barcelona" & Season == "20082009"
replace AwayPoss = 68 if match == "Sporting Gijón vs Barcelona" & Season == "20082009"
replace HomeOffsides = 0 if match == "Sporting Gijón vs Barcelona" & Season == "20082009"
replace AwayOffsides = 0 if match == "Sporting Gijón vs Barcelona" & Season == "20082009"


*Tenerife vs Mallorca 2009/10*Tenerife vs Mallorca 2009/10
replace HomePoss = 50 if match == "Tenerife vs Mallorca" & Sea == "20092010"
replace AwayPoss = 50 if match == "Tenerife vs Mallorca" & Sea == "20092010"


*Barcelona Real Sociedad 2010/11*Barcelona Real Sociedad 2010/11
replace HomeFld = 9 if match == "Barcelona vs Real Sociedad" & Sea == "20102011"
replace AwayFld = 9 if match == "Barcelona vs Real Sociedad" & Sea == "20102011"
replace AwayOffsides = 6 if match == "Barcelona vs Real Sociedad" & Sea == "20102011"


*Rayo Vallecano Real Zaragoza 2011/12*Rayo Vallecano Real Zaragoza 2011/12
replace HomePossession = 61 if match == "Rayo Vallecano vs Zaragoza" & Sea == "20112012"
replace AwayPossession = 39 if match == "Rayo Vallecano vs Zaragoza" & Sea == "20112012"
replace HomeFouls = 19 if match == "Rayo Vallecano vs Zaragoza" & Sea == "20112012"
replace AwayFouls = 14 if match == "Rayo Vallecano vs Zaragoza" & Sea == "20112012"
replace HomeFld = 14 if match == "Rayo Vallecano vs Zaragoza" & Sea == "20112012"
replace AwayFld = 19 if match == "Rayo Vallecano vs Zaragoza" & Sea == "20112012"
replace HomeOffsides = 0 if match == "Rayo Vallecano vs Zaragoza" & Sea == "20112012"
replace AwayOffsides = 4 if match == "Rayo Vallecano vs Zaragoza" & Sea == "20112012"


*Valladolid vs Levante 2013/14 *Valladolid vs Levante 2013/14 
replace HomePoss = 67 if match == "Valladolid vs Levante" & Sea == "20132014"
replace AwayPoss = 33 if match == "Valladolid vs Levante" & Sea == "20132014"
replace HomeFoul = 13 if match == "Valladolid vs Levante" & Sea == "20132014"
replace AwayFoul = 16 if match == "Valladolid vs Levante" & Sea == "20132014"
replace HomeFld = 16 if match == "Valladolid vs Levante" & Sea == "20132014"
replace AwayFld = 13 if match == "Valladolid vs Levante" & Sea == "20132014"


*Levante vs Elche 2013/14 *Levante vs Elche 2013/14 
replace HomePoss = 46 if match == "Levante vs Elche" & Sea == "20132014"
replace AwayPoss = 54 if match == "Levante vs Elche" & Sea == "20132014"


/*
if match == "" & Sea=""{
replace HomePoss = 
replace AwayPoss = 
replace HomeFoul = 
replace AwayFoul = 
replace HomeFld = 
replace AwayFld = 
replace HomeOff = 
replace AwayOff = 	
}



if match == "" & Sea=""{
replace HomePoss = 
replace AwayPoss = 
replace HomeFoul = 
replace AwayFoul = 
replace HomeFld = 
replace AwayFld = 
replace HomeOff = 
replace AwayOff = 	
}
*/
}
	
************************************************************************************
************************************************************************************
************************************************************************************
// Add matches that were not available in the website
insobs 10

{
*20062007 Valencia vs Real Sociedad
replace Season = "20062007" in 3948
replace hometeam = "Valencia" in 3948
replace awayteam = "Real Sociedad" in 3948
replace match = "Valencia vs Real Sociedad" in 3948
replace HomePossession = 53 in 3948
replace AwayPossession = 47 in 3948
replace HomeFouls = 19 in 3948
replace AwayFouls = 19 in 3948
replace HomeFld = 19 in 3948
replace AwayFld = 19 in 3948
replace HomeOffsides = 4 in 3948
replace AwayOffsides = 2 in 3948
replace url = "" in 3948

*20062007 Gimnàstic vs Villarreal
replace Season = "20062007" in 3949
replace hometeam = "Gimnàstic" in 3949
replace awayteam = "Villarreal" in 3949
replace match = "Gimnàstic vs Villarreal" in 3949
replace HomePossession = 61 in 3949
replace AwayPossession = 39 in 3949
replace HomeFouls = 21 in 3949
replace AwayFouls = 14 in 3949
replace HomeFld = 14 in 3949
replace AwayFld = 21 in 3949
replace HomeOffsides = 1 in 3949
replace AwayOffsides = 0 in 3949
replace url = "" in 3949


*20062007 Real Sociedad vs Sevilla
replace Season = "20062007" in 3950
replace hometeam = "Real Sociedad" in 3950
replace awayteam = "Sevilla" in 3950
replace match = "Real Sociedad vs Sevilla" in 3950
replace HomePossession = 47 in 3950
replace AwayPossession = 53 in 3950
replace HomeFouls = 20 in 3950
replace AwayFouls = 16 in 3950
replace HomeFld = 16 in 3950
replace AwayFld = 20 in 3950
replace HomeOffsides = 3 in 3950
replace AwayOffsides = 2 in 3950
replace url = "" in 3950

*20062007 Sevilla vs Betis
replace Season = "20062007" in 3951
replace hometeam = "Sevilla" in 3951
replace awayteam = "Betis" in 3951
replace match = "Sevilla vs Betis" in 3951
replace HomePossession = 51 in 3951
replace AwayPossession = 49 in 3951
replace HomeFouls = 29 in 3951
replace AwayFouls = 24 in 3951
replace HomeFld = 24 in 3951
replace AwayFld = 29 in 3951
replace HomeOffsides = 1 in 3951
replace AwayOffsides = 1 in 3951
replace url = "" in 3951

*20062007 Sevilla vs Getafe
replace Season = "20062007" in 3952
replace hometeam = "Sevilla" in 3952
replace awayteam = "Getafe" in 3952
replace match = "Sevilla vs Getafe" in 3952
replace HomePossession = 50 in 3952
replace AwayPossession = 50 in 3952
replace HomeFouls = 16 in 3952
replace AwayFouls = 19 in 3952
replace HomeFld = 19 in 3952
replace AwayFld = 16 in 3952
replace HomeOffsides = 4 in 3952
replace AwayOffsides = 4 in 3952
replace url = "" in 3952

*20062007 Villarreal vs Sevilla
replace Season = "20062007" in 3953
replace hometeam = "Villarreal" in 3953
replace awayteam = "Sevilla" in 3953
replace match = "Villarreal vs Sevilla" in 3953
replace HomePossession = 52 in 3953
replace AwayPossession = 48 in 3953
replace HomeFouls = 28 in 3953
replace AwayFouls = 18 in 3953
replace HomeFld = 18 in 3953
replace AwayFld = 28 in 3953
replace HomeOffsides = 3 in 3953
replace AwayOffsides = 1 in 3953
replace url = "" in 3953

*20062007 Atlético Madrid vs Racing Santander
replace Season = "20062007" in 3954
replace hometeam = "Atlético Madrid" in 3954
replace awayteam = "Racing Santander" in 3954
replace match = "Atlético Madrid vs Racing Santander" in 3954
replace HomePossession = 66 in 3954
replace AwayPossession = 34 in 3954
replace HomeFouls = 18 in 3954
replace AwayFouls = 24 in 3954
replace HomeFld = 24 in 3954
replace AwayFld = 18 in 3954
replace HomeOffsides = 4 in 3954
replace AwayOffsides = 3 in 3954
replace url = "" in 3954


*20092010 Barcelona vs Almería
replace Season = "20092010" in 3955
replace hometeam = "Barcelona" in 3955
replace awayteam = "Almería" in 3955
replace match = "Barcelona vs Almería" in 3955
replace HomePossession = 73 in 3955
replace AwayPossession = 27 in 3955
replace HomeFouls = 18 in 3955
replace AwayFouls = 14 in 3955
replace HomeFld = 14 in 3955
replace AwayFld = 18 in 3955
replace HomeOffsides = 3 in 3955
replace AwayOffsides = 3 in 3955
replace url = "" in 3955


*20092010 Racing Santander vs Deportivo La Coruña
replace Season = "20092010" in 3956
replace hometeam = "Racing Santander" in 3956
replace awayteam = "Deportivo La Coruña" in 3956
replace match = "Racing Santander vs Deportivo La Coruña" in 3956
replace HomePossession = 51 in 3956
replace AwayPossession = 49 in 3956
replace HomeFouls = 18 in 3956
replace AwayFouls = 12 in 3956
replace HomeFld = 12 in 3956
replace AwayFld = 18 in 3956
replace HomeOffsides = 0 in 3956
replace AwayOffsides = 2 in 3956
replace url = "" in 3956


*20132014 Granada vs Celta Vigo
replace Season = "20132014" in 3957
replace hometeam = "Granada" in 3957
replace awayteam = "Celta Vigo" in 3957
replace match = "Granada vs Celta Vigo" in 3957
replace HomePossession = 49 in 3957
replace AwayPossession = 51 in 3957
replace HomeFouls = 10 in 3957
replace AwayFouls = 14 in 3957
replace HomeFld = 14 in 3957
replace AwayFld = 10 in 3957
replace HomeOffsides = 1 in 3957
replace AwayOffsides = 2 in 3957
replace url = "" in 3957

/*
replace Season = "" in L
replace hometeam = "" in L
replace awayteam = "" in L
replace match = "" in L
replace HomePossession =  in L
replace AwayPossession =  in L
replace HomeFouls =  in L
replace AwayFouls =  in L
replace HomeFld =  in L
replace AwayFld =  in L
replace HomeOffsides =  in L
replace AwayOffsides =  in L
replace url = "" in L
*/
}

replace HomeOffsides = 0 if url == "https://m.football-lineups.com/match/64162/"
replace AwayOffsides = 2 if url == "https://m.football-lineups.com/match/64162/"

duplicates drop url match, force


***************************************************
***************************************************

// Adjust Season obs
{
replace Season = "0405" if Season == "20042005"
replace Season = "0506" if Season == "20052006"
replace Season = "0607" if Season == "20062007"
replace Season = "0708" if Season == "20072008"
replace Season = "0809" if Season == "20082009"
replace Season = "0910" if Season == "20092010"
replace Season = "1011" if Season == "20102011"
replace Season = "1112" if Season == "20112012"
replace Season = "1213" if Season == "20122013"
replace Season = "1314" if Season == "20132014"
replace Season = "1415" if Season == "20142015"
}

// Adjust the missing
replace HomeFouls = . if HomeFld == 0 & AwayFld == 0
replace AwayFouls = . if HomeFld == 0 & AwayFld == 0
replace HomeFld = . if HomeFouls == . & AwayFouls == .
replace AwayFld = . if HomeFouls == . & AwayFouls == .

rename match Partido

foreach var in hometeam awayteam Partido{
	replace `var'=subinstr(`var', "Betis", "Real Betis", .)
}

sort Season

// Save data
cd "$externaldata\FootballLineups"
save MergeFootballLineups.dta,replace


********************************************************************************
********************************************************************************
********************************************************************************
//*ATTENDANCE R TRANSFERMKT*//


forvalues x=1998/2021{
// Import data
quiet import delimited "$data\FootballLineups\HACKIN\TEAMS - ATTENDANCE\Teams`x'.csv", delimiter(tab) varnames(1) clear

// Keep variables of interest and rename them
drop if v17==""
keep v17 v24

rename v17 hometeam
rename v24 url

gen index=_n
gen Year=`x'

// Generate Jornada values by cleaning the URL variable
replace url=substr(url,3,100)
gen Jornada=substr(url,-2,2)
replace Jornada = subinstr(Jornada, "=", "", .)
destring Jornada,replace

// Save and append in one dta
cd "$externaldata\TRANSFERMKT"
if `x'==1998{
	save AttendanceTeams.dta,replace
}
else{
	append using AttendanceTeams.dta
	save AttendanceTeams.dta,replace
}
}

// Standarize name of the teams
{
	replace hometeam = subinstr(hometeam, "Almeria", "Almería", .)
	replace hometeam = subinstr(hometeam, "Athletic", "Athletic Club", .)
	replace hometeam = subinstr(hometeam, "CA Osasuna", "Osasuna", .)
	replace hometeam = subinstr(hometeam, "Cádiz CF", "Cádiz", .)
	replace hometeam = subinstr(hometeam, "Celta de Vigo", "Celta Vigo", .)
	replace hometeam = subinstr(hometeam, "Córdoba CF", "Córdoba", .)
	replace hometeam = subinstr(hometeam, "Hércules CF", "Hércules", .)
	replace hometeam = subinstr(hometeam, "Dep. La Coruña", "Deportivo La Coruña", .)
	replace hometeam = subinstr(hometeam, "Málaga CF", "Málaga", .)
	replace hometeam = subinstr(hometeam, "Racing", "Racing Santander", .)
	replace hometeam = subinstr(hometeam, "Sp Gijon", "Sporting Gijón", .)
	replace hometeam = subinstr(hometeam, "Villareal", "Villarreal", .)
	replace hometeam = subinstr(hometeam, "CD Leganés", "Leganés", .)
	replace hometeam = subinstr(hometeam, "CD Numancia", "Numancia", .)
	replace hometeam = subinstr(hometeam, "CD Tenerife", "Tenerife", .)
	replace hometeam = subinstr(hometeam, "Elche CF", "Elche", .)
	replace hometeam = subinstr(hometeam, "RCD Mallorca", "Mallorca", .)
	replace hometeam = subinstr(hometeam, "Real Betis", "Betis", .)
	replace hometeam = subinstr(hometeam, "Real Oviedo", "Oviedo", .)
	replace hometeam = subinstr(hometeam, "Real Valladolid", "Valladolid", .)
	replace hometeam = subinstr(hometeam, "Real Zaragoza", "Zaragoza", .)
	replace hometeam = subinstr(hometeam, "Recr. Huelva", "Recreativo", .)
	replace hometeam = subinstr(hometeam, "SD ", "", .)
	replace hometeam = subinstr(hometeam, "Sevilla FC", "Sevilla", .)
	replace hometeam = subinstr(hometeam, "UD ", "", .)
	replace hometeam = subinstr(hometeam, "Xerez CD", "Xerez", .)
	replace hometeam = subinstr(hometeam, "Granada CF", "Granada", .)
	/*
	replace hometeam = subinstr(hometeam, "", "", .)
	replace hometeam = subinstr(hometeam, "", "", .)
	replace hometeam = subinstr(hometeam, "", "", .)
	*/
}

// Sort and save data
cd "$externaldata\TRANSFERMKT"
sort Year Jornada index
drop index
gen index=_n
save AttendanceTeams.dta,replace


cls
forvalues x=1998/2021{
// Import data
import excel "$data\FootballLineups\HACKIN\TEAMS - ATTENDANCE\Attendance`x'.xlsx", sheet("Sheet 1") firstrow clear

// Clean values in obs
replace A = "" if strpos(A, "day")
split A, p("·") limit(1)

replace A = A1
replace A = subinstr(A, ".", "", .)
replace A = subinstr(A, "sold out", "", .)
replace A = "" if strpos(A, "a") != 0 | strpos(A, "e") != 0 | strpos(A, "i") != 0 | strpos(A, "o") != 0 | strpos(A, "u") != 0

drop A1

destring A,replace
rename A Attendance

// Generate Index, Year and Matchweek variable
gen index = _n
gen Year = `x'
gen Jornada = substr(url,-2,2)

replace Jornada = subinstr(Jornada, "=", "", .)
replace Jornada = subinstr(Jornada, "/", "", .)

destring Jornada,replace

// Save and append in one dta
cd "$externaldata\TRANSFERMKT"
if `x' == 1998{
	save AttendanceYears.dta,replace
}
else{
	append using AttendanceYears.dta
	save AttendanceYears.dta,replace
}
sort Year Jornada index
}

// Drop even obs
gen dupindi=0
forvalues i=1(2)20000{
qui replace dupindi=1 if `i'==index
}
drop if dupindi==1
drop dupindi
drop index

gen index=_n

// Merge with AttendanceTeams.dta and save output
merge m:m Year Jornada index using AttendanceTeams
drop _merge
cd "$externaldata\TRANSFERMKT"
save Attendance9821R.dta,replace