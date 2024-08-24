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


cd "$externaldata"
// Load the dataset containing penalties conceded
use PenaltiesConceded.dta, clear
// Merge with another dataset using multiple variables (m:m merge on Partido and Year)
merge m:m Partido Year using Merge1.dta
sort Year Matchweek

// Set penalty conceded and penalty attempted variables to 0 for years before 2014
foreach var in Home_PKcon Away_PKcon Home_PKatt Away_PKatt{
	replace `var' = 0 if Year < 2014
}

// Replace missing values for total penalties conceded and attempted with 0
foreach var in HomeTotPKcon AwayTotPKcon HomeTotPKatt AwayTotPKatt{
	replace `var' = 0 if `var' == .
}

// Generate combined penalty concession and attempt variables for home and away teams
gen HomePenConc = HomeTotPKcon + Home_PKcon
gen AwayPenConc = AwayTotPKcon + Away_PKcon
gen HomePenAtt = HomeTotPKatt + Home_PKatt
gen AwayPenAtt = AwayTotPKatt + Away_PKatt


keep Home_Team Away_Team date Matchweek Season Partido FinalResult Home_Score Away_Score Home_Yellow_Cards Home_Red_Cards Away_Yellow_Cards Away_Red_Cards Home_Off Away_Off Home_Fouls Away_Fouls Home_Fld Away_Fld HomeEquipo HomeAnnualWagesEUR HomeMktValue AwayEquipo AwayAnnualWagesEUR AwayMktValue HomePenConc AwayPenConc HomePenAtt AwayPenAtt date

order HomePenConc AwayPenConc HomePenAtt AwayPenAtt, after(Away_Red_Cards)

// Merge with Football Lineups dataset using multiple variables (m:m merge on Partido and Season)
cd "$externaldata/FootballLineups"
merge m:m Partido Season using MergeFootballLineups

// Replace missing values for various game statistics with 0
foreach var in Home_Off Away_Off Home_Fouls Away_Fouls Home_Fld Away_Fld HomePossession AwayPossession HomeFouls AwayFouls HomeFld AwayFld HomeOffsides AwayOffsides{
	replace `var' = 0 if `var' == .
}

// Generate total offsides variables by summing individual offsides counts
gen HomeOffs = Home_Off + HomeOffsides
gen AwayOffs = Away_Off + AwayOffsides

*drop if Sea == "0405"

// Drop unnecessary variables from the dataset
foreach var in Home_Off Away_Off /*Home_Fouls Away_Fouls Home_Fld Away_Fld*/ /*HomePossession AwayPossession*/ HomeFouls AwayFouls HomeFld AwayFld *Offsides url *team _mer *Poss*{
	drop `var'
}

sort date

// Rename variables for clarity
{
rename Home_Score HomeGoals
rename Away_Score AwayGoals
rename Home_Yellow_Cards HomeYellow
rename Away_Yellow_Cards AwayYellow
rename Home_Red_Cards HomeRed
rename Away_Red_Cards AwayRed
rename Home_Fouls HomeFouls
rename Away_Fouls AwayFouls
rename Home_Fld HomeFld
rename Away_Fld AwayFld
rename HomeOffs HomeOffsides
rename AwayOffs AwayOffsides
}

order HomeFouls AwayFouls HomeFld AwayFld HomeYellow AwayYellow HomeRed AwayRed HomeOffsides AwayOffsides, after(AwayGoals)

gen Jornada=Matchweek
rename Home_Team hometeam
rename Away_Team awayteam

// Generate a Year variable based on the Season variable
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

// Standardize team names by replacing "Real Betis" with "Betis"
replace Partido = subinstr(Partido,"Real Betis","Betis", .)
drop if hometeam == ""

// Save the updated dataset
cd "$externaldata"
save FullTeamProbit.dta,replace

// Merge with attendance data based on Year, Jornada, and hometeam
merge m:m Year Jornada hometeam using $externaldata/TRANSFERMKT/Attendance9821R.dta, nogen
// Merge with odds data based on Year and Partido
merge m:m Year Partido using $externaldata/ODDS.dta, nogen

// Keep relevant variables after merging and reorder and sort
keep *team Partido Matchweek *Goals *Fouls *Fld *Yellow *Red *Offsides *PenConc *PenAtt date FinalResult *AnnualWagesEUR *MktValue *Equipo Year Attendance index iw*
order date Matchweek Year hometeam awayteam Partido
sort date index
drop index

// Rename variables for clarity
rename Attendance AttendanceTransfMkt
rename hometeam HomeTeam
rename awayteam AwayTeam

// Save the final dataset
cd "$externaldata"
save FullTeamProbit.dta,replace


********************************************************************************
********************************************************************************
********************************************************************************




// Import datasets
cd "$externaldata"
use FullTeamProbit.dta, clear

// Duplicate each observation, creating a new variable "dupindicator" to mark the duplicates
expand 2, gen(dupindicator)
sort date Partido dup

// Loop through the specified variables to separate home and away team data
foreach var in Team /*Equipo*/ Goals Fouls Fld Yellow Red Offsides PenAtt PenConc AnnualWagesEUR MktValue{
	gen `var' = Home`var' if dupindicator == 0
	replace `var' = Away`var' if dupindicator == 1
	drop Home`var'
	drop Away`var'
}

// Drop the original home and away team identifier variables
drop HomeEquipo
drop AwayEquipo

// Create a binary variable "Local" to indicate if the team is playing at home (1 = home team)
gen Local=1 if dupindicator==0
replace Local=0 if Local == .

// Create a binary variable "Win" to indicate if the team won the match
gen Win=1 if (FinalResult==1 & dupindicator==0) | FinalResult==3 & dupindicator==1
replace Win=0 if Win == .

// Calculate the difference in market value and goal difference between the home and away teams
gen DiffMktValue=MktValue[_n]-MktValue[_n+1] if Local==1
replace DiffMktValue=-DiffMktValue[_n-1] if Local==0

gen GoalDiff=Goals[_n]-Goals[_n+1] if Local==1
replace GoalDiff=-GoalDiff[_n-1] if Local==0

gen index=_n
drop dupindicator

// Convert the "Team" variable to a numeric format and create the new variable "Equipo"
encode Team, gen(Equipo)
drop Team

// Set the panel structure with "Equipo" as the panel identifier and "date" as the time variable
xtset Equipo date
sort index
order date Year Matchweek Equipo index Local Win Goals Fouls Fld Yellow Red Offsides PenAtt PenConc AnnualWagesEUR MktValue iwh iwd iwa DiffMktValue GoalDiff

********************************************************************************
// Loop through the variables Yellow and Red cards
foreach var in Yellow Red{
	    // Create a new variable `var'1 to store the value of `var' for the away team (Local == 0)
	
	gen `var'1=`var' if Local==0 // Replace the value of `var'1 with the value of the next row (shifting it upwards)
	replace `var'1=`var'1[_n+1]
	replace `var'1=0 if `var'1 == .
	
	// Create a new variable `var'2 to store the value of `var' for the home team (Local == 1)
	gen `var'2=`var' if Local==1
	gen `var'3=.
	
	// Replace the value of `var'3 with the value of the previous row (shifting it downwards)
	replace `var'3=`var'2[_n-1]
	replace `var'3=0 if `var'3 == .

	drop `var'2
	
	// Create a new variable `var'Favor by summing `var'1 and `var'3 (for away and home teams)
	gen `var'Favor=`var'1+`var'3
	
	drop `var'1-`var'3

	// Rename the original variable `var' to `var'Contra to indicate it's for the opposing team
	rename `var' `var'Contra
}
********************************************************************************


// Generate the square of the market value difference (MktValue^2)
gen SqDifMktValue=DiffMktValue^2

// Handle missing data for Fouls, Fld, and Offsides by setting them to missing if the year is before 2005replace Fouls=. if Year<2005
replace Fld=. if Year<2005
replace Offsides=. if Year<2005

// Generate variable for difference in bookmaker probabilities (iwh - iwa) based on Local status
gen DifBookMkr=iwh-iwa if Local==1
replace DifBookMkr=iwa-iwh if Local==0

// Generate the square of the difference in bookmaker probabilities
gen SqDifBookMkr=DifBookMkr^2

// Using the Buraimo methodology, generate variables for bookmaker probabilities adjusted by epsilon
gen SumBooker=iwa+iwd+iwh
gen epsilon=SumBooker-1

gen iwhe=iwh/epsilon
gen iwde=iwd/epsilon
gen iwae=iwa/epsilon

// Generate difference in adjusted bookmaker probabilities based on Local status
gen DifBookMaker=iwhe-iwae if Local==1
replace DifBookMaker=iwae-iwhe if Local==0

*drop SumBooker-iwae

// Generate the square of the difference in adjusted bookmaker probabilities
gen SqDifBookMaker=DifBookMaker^2

// Generate a variable to indicate if any payments were made during the years 2001-2017
gen TdePagos=1 if Year>2000 & Year<2018
replace TdePagos=0 if TdePagos == .


********************************************************************************

// Generate treatment variables for specific teams
// Variable indicating if the team is Barcelona (Equipo == 6)
gen Barca=1 if Equipo==6
replace Barca=0 if Barca == .

// Variable indicating if the team is either Barcelona or Real Madrid (Equipo == 6 or 32)
gen BarcaRM=1 if Equipo==6 | Equipo==32
replace BarcaRM=0 if BarcaRM == .

// Variable indicating if the team is either Barcelona or Real Madrid, assigning Real Madrid to 0
gen BarcaOReal=1 if Equipo==6
replace BarcaOReal=0 if Equipo==32

// Variable indicating if the team is Barcelona during the payment years (2001-2017)
gen BarcaNegreira=1 if Equipo==6 & TdePagos==1
replace BarcaNegreira=0 if BarcaNegreira == .

// Variable indicating if the team is either Barcelona or Real Madrid during the payment years (2001-2017)
gen BarcaRM_Negreira=1 if (Equipo==6 & TdePagos==1) | (Equipo==32 & TdePagos==1)
replace BarcaRM_Negreira=0 if BarcaRM_Negreira == .

// Variable indicating if the team is either Barcelona or Real Madrid during the payment years, assigning Real Madrid to 0
gen BarcaOReal_Negreira=1 if Equipo==6 & TdePagos==1
replace BarcaOReal_Negreira=0 if Equipo==32 & TdePagos==1


// Generate a variable indicating the cohort in relation to the payments: Before, During, After
gen Cohortes="Durante" if Year>2000 & Year<2018
replace Cohortes="Antes" if Year<2001
replace Cohortes="Posterior" if Year>2017

// Create numeric variable for cohorts: 1 for Before, 2 for During, 3 for After
gen Cohorte=2 if Year>2000 & Year<2018
replace Cohorte=1 if Year<2001
replace Cohorte=3 if Year>2017

*encode Cohortes, gen(Cohorte)
*drop Cohortes


// Generate variable indicating whether a club paid the CTA (1 for Barcelona during payment years)
gen Bribe=0
replace Bribe=1 if Equipo==6 & Year>2000 & Year<2018

// Generate binary variables indicating if the team received more yellow cards, red cards, fouls, or penalties compared to the opposing team
gen MoreYellow=1 if YellowC>YellowF
gen MoreRed=1 if RedC>RedF
gen MoreFouls=1 if Fouls>Fld
gen MorePen=1 if PenC>PenA

replace MoreYellow=0 if MoreYellow == .
replace MoreRed=0 if MoreRed == .
replace MorePen=0 if MorePen == .
replace MoreFouls=0 if MoreFouls == .
replace MoreFouls=. if Fouls == .

// Save the final dataset
cd "$externaldata"
save Final.dta,replace


********************************************************************************
********************************************************************************
********************************************************************************



// Import the different csv and append in one dta
forvalues i=1/100{
quiet import delimited "$data\FootballLineups\Attendance\FTBLNP`i'.csv", varnames(1) clear
display "`i'"

cd "$externaldata"
if `i'==1{
quiet save AttendanceFTBLNPFTBLNP.dta,replace
}
else{
quiet append using AttendanceFTBLNPFTBLNP
quiet save AttendanceFTBLNPFTBLNP.dta,replace
}
}

// Split data by " -  " and keep only the data that will be used
split text, p(" -  ")
keep text1 text2 text4 text url
drop if text1 == "character(0)"

// Clean the content of observations
replace text2 = subinstr(text2, "Matchday", "La Liga (Matchweek", .)

forvalues i = 0/10{
	replace text2 = subinstr(text2, "`i' ", "`i')", .)
	replace text1 = subinstr(text1, " `i' ", "", .)
}

// Generate Year data
gen Year = substr(text1, -10, 4)
destring Year, replace

// Generate Attendance data
replace text4 = "" if strpos(text4, "Attendance") == 0 | strpos(text4, "Referee") == 0
split text4, p(" Referee") limit(1)
replace text41 = subinstr(text41, "Attendance: ", "", .)
replace text41 = subinstr(text41, "closed doors", "0", .)
destring text41, replace
drop text4
rename text41 AttendanceFTBLNP

// Generate home and away teams
split text1, p("La Liga") limit(1)
replace text1 = text11
drop text11

split text1, p(":")
rename text11 home
rename text12 away

expand 2, gen(expy)
sort text

replace home = "" if expy == 0
replace away = "" if expy == 1

replace text1 = home if home != ""
replace text1 = away if away != ""

// Drop auxiliary variables
drop home-expy

// Define labels for Matchweek data and encode it
lab def Matchweek 1 "La Liga (Matchweek 1)" 2 "La Liga (Matchweek 2)" 3 "La Liga (Matchweek 3)" 4 "La Liga (Matchweek 4)" 5 "La Liga (Matchweek 5)" 6 "La Liga (Matchweek 6)" 7 "La Liga (Matchweek 7)" 8 "La Liga (Matchweek 8)" 9 "La Liga (Matchweek 9)" 10 "La Liga (Matchweek 10)" 11 "La Liga (Matchweek 11)" 12 "La Liga (Matchweek 12)" 13 "La Liga (Matchweek 13)" 14 "La Liga (Matchweek 14)" 15 "La Liga (Matchweek 15)" 16 "La Liga (Matchweek 16)" 17 "La Liga (Matchweek 17)" 18 "La Liga (Matchweek 18)" 19 "La Liga (Matchweek 19)" 20 "La Liga (Matchweek 20)" 21 "La Liga (Matchweek 21)" 22 "La Liga (Matchweek 22)" 23 "La Liga (Matchweek 23)" 24 "La Liga (Matchweek 24)" 25 "La Liga (Matchweek 25)" 26 "La Liga (Matchweek 26)" 27 "La Liga (Matchweek 27)" 28 "La Liga (Matchweek 28)" 29 "La Liga (Matchweek 29)" 30 "La Liga (Matchweek 30)" 31 "La Liga (Matchweek 31)" 32 "La Liga (Matchweek 32)" 33 "La Liga (Matchweek 33)" 34 "La Liga (Matchweek 34)" 35 "La Liga (Matchweek 35)" 36 "La Liga (Matchweek 36)" 37 "La Liga (Matchweek 37)" 38 "La Liga (Matchweek 38)"
encode text2, gen(Matchweek)

// Clean the names of the teams to make sure they will match with other dtas
replace text1 = subinstr(text1, " de Tarragona", "", .)
replace text1 = subinstr(text1, "Hercules", "Hércules", .)
replace text1 = subinstr(text1, "Malaga", "Málaga", .)
replace text1 = subinstr(text1, " de Santander", " Santander", .)
replace text1 = subinstr(text1, "Real Valladolid", "Valladolid", .)
replace text1 = subinstr(text1, "Real Z", "Z", .)
replace text1 = subinstr(text1, " de Huelva", "", .)
replace text1 = subinstr(text1, " CD", "", .)
replace text1 = subinstr(text1, "Cadiz", "Cádiz", .)
replace text1 = subinstr(text1, "Atletico Madrid", "Atlético Madrid", .)
replace text1 = subinstr(text1, " CF", "", .)
replace text1 = subinstr(text1, "Deportivo Alaves", "Alavés", .)
replace text1 = subinstr(text1, " de Barcelona", "", .)
replace text1 = subinstr(text1, "Real Betis", "Betis", .)

// Define labels for Teams data and encode it
lab def Equipo 1 "Alavés" 2 "Albacete" 3 "Almería" 4 "Athletic Club" 5 "Atlético Madrid" 6 "Barcelona" 7 "Betis" 8 "Celta Vigo" 9 "Cádiz" 10 "Córdoba" 11 "Deportivo La Coruña" 12 "Eibar" 13 "Elche" 14 "Espanyol" 15 "Extremadura" 16 "Getafe" 17 "Gimnàstic" 18 "Girona" 19 "Granada" 20 "Huesca" 21 "Hércules" 22 "Las Palmas" 23 "Leganés" 24 "Levante" 25 "Mallorca" 26 "Málaga" 27 "Numancia" 28 "Osasuna" 29 "Oviedo" 30 "Racing Santander" 31 "Rayo Vallecano" 32 "Real Madrid" 33 "Real Murcia" 34 "Real Sociedad" 35 "Recreativo" 36 "Salamanca" 37 "Sevilla" 38 "Sporting Gijón" 39 "Tenerife" 40 "Valencia" 41 "Valladolid" 42 "Villarreal" 43 "Xerez" 44 "Zaragoza" 
encode text1, gen(Equipo)

// Adjust Attendance data for matches that happened during COVID
replace AttendanceFTBLNP=0 if Year==2020 & Matchweek<37
replace AttendanceFTBLNP=0 if Year==2020 & AttendanceFTBLNP==.

// Keep and order variables
keep Year AttendanceFTBLNP Matchweek Equipo
order Year Matchweek Equipo AttendanceFTBLNP

********************************************************************************
// Merge with other dtas
cd "$externaldata"
merge 1:1 Year Matchweek Equipo using Final
replace AttendanceTransfMkt=AttendanceFTBLNP if AttendanceTransfMkt==. & Year>2000
drop _merge

merge 1:1 Year Matchweek Equipo using YellowCrdsCorrection.dta
drop Season
sort Year Matchweek date Partido Local

// Minor adjustments on the Yellow Cards information
replace YellowContra=YellowContra-SecYCrdHOME if _merg==3
replace YellowContra=YellowContra-SecYCrdAWAY if _merg==3

gen YelloFav=YellowContra if Local==0
gen YelloFav2=YellowContra if Local==1
gen YellowFav3=YelloFav[_n-1]
replace YelloFav2=YelloFav2[_n+1]
replace YellowFav3=YelloFav2 if YellowFav3==.

// Drop auxiliary variables
drop YellowFavor
drop YelloFav2
drop YelloFav

rename YellowFav3 YellowFavor

// Order variables
order index date Year Matchweek Equipo AttendanceFTBLNP AttendanceTransfMkt Local Win Goals Fouls Fld YellowContra RedContra YellowFavor RedFavor Offsides PenAtt PenConc AnnualWagesEUR MktValue iwh iwd iwa DiffMktValue GoalDiff Partido SqDifMktValue DifBookMkr SqDifBookMkr SumBooker epsilon iwhe iwde iwae DifBookMaker SqDifBookMaker TdePagos Barca BarcaRM BarcaOReal BarcaNegreira BarcaRM_Negreira BarcaOReal_Negreira Cohortes Cohorte Bribe MoreYellow MoreRed MoreFouls MorePen 

// Replace data
replace YellowContra = 2 if index==9392
replace YellowFavor = 2 if index==9391
replace YellowContra = 14 if index==8248
replace YellowFavor = 14 if index==8247

// Drop variables
drop SecYCrdHOME-_merge
drop index

// Create index and order obs
gen index=_n
order index, first

// Label variables
{
label var index "Index"
label var date "Date of the Match"
label var Year "Year that the season started"
label var Matchweek "Matchweek"
label var Equipo "Equipo"
label var AttendanceFTBLNP "Attendance according to Football Lineups"
label var AttendanceTransfMkt "Attendance according to Transfermkt"
label var Local "Dummy if the Team is Local"
label var Win "Dummy if the Team Win"
label var Goals "Goals that the team scored"
label var Fouls "Fouls that the team commited"
label var Fld "Fouls that the team received"
label var YellowContra "T. Amarillas en Contra"
label var RedContra "T. Rojas en Contra"
label var YellowFavor "T. Amarillas a Favor"
label var RedFavor "T. Rojas a Favor"
label var Offsides "Fueras de juego en Contra"
label var PenAtt "Penales a Favor"
label var PenConc "Penales en Contra"
label var AnnualWagesEUR "Annual Wages in Euros"
label var MktValue "Market Value of the Team"
label var iwh ""
label var iwd ""
label var iwa ""
label var DiffMktValue "Diferencia en el Valor de Mercado entre el equipo y su contrincante para ese partido"
label var GoalDiff "Goal Difference"
label var Partido "Partido Jugado"
label var SqDifMktValue "Diferencia al cuadrado del valor de Mercado entre el equipo y su contrincante para ese partido"
label var DifBookMkr "Diferencia entre momios entre el equipo y su contrincante para ese partido"
label var SqDifBookMkr "Diferencia al cuadrado entre momios entre el equipo y su contrincante para ese partido"
label var SumBooker ""
label var epsilon ""
label var iwhe ""
label var iwde ""
label var iwae ""
label var DifBookMaker "Diferencia entre momios entre el equipo y su contrincante para ese partido"
label var SqDifBookMaker "Diferencia al cuadrado entre momios entre el equipo y su contrincante para ese partido"
label var TdePagos "Dummy que indica si hubo pagos en ese año"
label var Barca "Dummy que indica si el Equipo es el Barcelona"
label var BarcaRM ""
label var BarcaOReal ""
label var BarcaNegreira ""
label var BarcaRM_Negreira ""
label var BarcaOReal_Negreira ""
label var Cohortes ""
label var Cohorte ""
label var Bribe ""
/*label var MoreYellowContra ""
label var MoreRedContra ""
label var MoreFoulsContra ""
label var MorePenContra ""
*/
}



// Save data
cd "$externaldata"
save FinalCorr.dta,replace