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


forvalues x=1/16{
display "`x'"
quiet import delimited "$data\RFEF - CTA\h`x'.csv", varnames(1) clear
compress

cd "$externaldata\RFEF - CTA"
if `x'==1{
	save SOURCODE.dta,replace
}
else{
	append using SOURCODE
	compress
	save SOURCODE.dta,replace
}
}

********************************************************************************

// Import data
cd "$externaldata\RFEF - CTA"
use SOURCODE, clear
drop v1

// Remove tab characters, double spaces, and double quotes from the variable "x"
replace x = subinstr(x, char(9), "", .)
replace x = subinstr(x,"  ","",.)
replace x = subinstr(x,char(34),"",.)

// Drop rows where "x" is either empty or consists only of a space
drop if x == ""
drop if x == " "

// Keep rows where "x" contains any of the following strings
keep if strpos(x, "Temporada") | strpos(x, "Jornada") | strpos(x, "Acta del Partido celebrado") | strpos(x, "<td width=225") | strpos(x, "class=NEGRITA>-") | strpos(x, "EXPULSIONES") | strpos(x, "motivo: doble amarilla")

// Drop rows containing "Liga 2ª División" as it's not needed
drop if strpos(x, "Liga 2ª División")

// Replace instances of "Liga 1ª División" with "Liga 1ra División" for consistency
replace x = "Liga 1ra División" if strpos(x, "Liga 1ª División")

// Iterate over a list of HTML tags and remove them from the variable "x"
foreach var in "<td width=225 class=TEXTO_COLOR>" "</td>" "<td height=15 colspan=2 class=NEGRITA>- " ":" "<td width=30%><span class=TIT_PAG>&nbsp;" "</span>" "<td align=right width=30%><span class=TIT_PAG>" "&nbsp;" "<td class=BG_TIT_PAG><span class=tit4>" "<td height=15 >+ " "<td height=15 colspan=3 class=tit4>B.- "{
	replace x = subinstr(x, "`var'", "", .)
}

// Drop rows where "x" contains specific unwanted strings related to layout and narrative content
drop if strpos(x, "<td align=right class=BG_TIT_PAG>") | strpos(x, "<td height=15 colspan=2 >") | strpos(x, "<td width=570 height=15 >") | strpos(x, "El segundo tiempo comenzó con 30")


// Perform quiet replacements of specific club names with their standardized forms
quiet{
	replace x = subinstr(x, "Málaga CF SAD","Málaga", .)
	replace x = subinstr(x, "Villarreal CF SAD","Villarreal", .)
	replace x = subinstr(x, "RCD Espanyol de Barcelona SAD","Espanyol", .)
	replace x = subinstr(x, "Real Zaragoza SAD","Zaragoza", .)
	replace x = subinstr(x, "FC Barcelona","Barcelona", .)
	replace x = subinstr(x, "Real Sociedad de Fútbol SAD","Real Sociedad", .)
	replace x = subinstr(x, "Real Betis Balompié SAD","Betis", .)
	replace x = subinstr(x, "Real Madrid CF","Real Madrid", .)
	replace x = subinstr(x, "Sevilla FC SAD","Sevilla", .)
	replace x = subinstr(x, "Club Atlético de Madrid SAD","Atlético Madrid", .)
	replace x = subinstr(x, "Real Valladolid CF SAD","Valladolid", .)
	replace x = subinstr(x, "Albacete Balompié SAD","Albacete", .)
	replace x = subinstr(x, "RC Deportivo","Deportivo La Coruña", .)
	replace x = subinstr(x, "RC Celta de Vigo SAD","Celta Vigo", .)
	replace x = subinstr(x, "Club Atlético Osasuna","Osasuna", .)
	replace x = subinstr(x, "Real Murcia CF","Real Murcia", .)
	replace x = subinstr(x, "Real Racing Club de Santander SAD","Racing Santander", .)
	replace x = subinstr(x, "Athletic Club","Athletic Club", .)
	replace x = subinstr(x, "Valencia CF SAD","Valencia", .)
	replace x = subinstr(x, "RCD Mallorca SAD","Mallorca", .)
	replace x = subinstr(x, "Levante UD SAD","Levante", .)
	replace x = subinstr(x, "Getafe CF SAD","Getafe", .)
	replace x = subinstr(x, "CD Numancia de Soria","Numancia", .)
	replace x = subinstr(x, "Cádiz CF SAD","Cádiz", .)
	replace x = subinstr(x, "Deportivo Alavés SAD","Alavés", .)
	replace x = subinstr(x, "RC Recreativo de Huelva SAD","Recreativo", .)
	replace x = subinstr(x, "Gimnàstic de Tarragona","Gimnàstic", .)
	replace x = subinstr(x, "UD Almería SAD","Almería", .)
	replace x = subinstr(x, "Real Sporting de Gijón SAD","Sporting Gijón", .)
	replace x = subinstr(x, "Xerez C.D. SAD","Xerez", .)
	replace x = subinstr(x, "CD Tenerife SAD","Tenerife", .)
	replace x = subinstr(x, "Hércules de Alicante CF SAD","Hércules", .)
	replace x = subinstr(x, "Granada CF SAD","Granada", .)
	replace x = subinstr(x, "Rayo Vallecano de Madrid SAD","Rayo Vallecano", .)
	replace x = subinstr(x, "Elche CF SAD","Elche", .)
	replace x = subinstr(x, "Córdoba CF","Córdoba", .)
	replace x = subinstr(x, "SD Eibar SAD","Eibar", .)
	replace x = subinstr(x, "UD Las Palmas SAD","Las Palmas", .)
	replace x = subinstr(x, "CD Leganés SAD","Leganés", .)
	replace x = subinstr(x, "Girona FC SAD","Girona", .)
	replace x = subinstr(x, "SD Huesca SAD","Huesca", .)
}

// Generate a new variables when "x" or the previous row contains certain words or phrases
gen Season = x if strpos(x, "Temporada")
gen Jornada = x if strpos(x, "Jornada")
gen Acta = x if strpos(x, "Acta del Partido")
gen homeEquipo = x if strpos(x[_n-1], "Acta del Partido")
gen awayEquipo = x if strpos(x[_n-2], "Acta del Partido")
gen Exp = x if strpos(x, "EXPULSIONES")
gen ExpJ = x if strpos(x, "En el minuto") & strpos(x, "el jugador")

// Generate a new variable "Aux" as 1 if any of the variables Jornada, Acta, homeEquipo, or awayEquipo are not empty
gen Aux = 1 if Jornada != "" | Acta != "" | homeEquipo != "" | awayEquipo != ""
replace Jornada = Jornada[_n+1]
replace Acta = Acta[_n+2]
replace homeEquipo = homeEquipo[_n+3]
replace awayEquipo = awayEquipo[_n+4]
drop if Aux == 1

// Generate the variable "Equipo" based on the condition that it is near an expulsion (EXPULSIONES) entry, but not itself an entry for "En el minuto"
gen Equipo = x if (strpos(x[_n-1], "EXPULSIONES") | strpos(x[_n-2], "EXPULSIONES") | strpos(x[_n+1], "En el minuto")) & strpos(x, "En el minuto") == 0 ///
	| (strpos(x[_n-1], "En el minuto") & strpos(x, "En el minuto") == 0 & strpos(x[_n+3], "EXPULSIONES"))
	
// Drop rows where all of awayEquipo, Exp, ExpJ, and Equipo are empty
drop if awayEquipo == "" & Exp == "" & ExpJ == "" & Equipo == ""

// Replace "Aux" with 1 if Exp is not empty and either ExpJ in the previous row contains "En el minuto" or awayEquipo three rows below is not empty
replace Aux = 1 if (Exp != "" & strpos(ExpJ[_n-1], "En el minuto")) | (Exp != "" & awayEquipo[_n+3] != "")

// Generate a new variable "Aux2" to flag rows where the previous row or two rows up had Aux equal to 1
gen Aux2 = 1 if Aux[_n-1] == 1 | Aux[_n-2] == 1

// Drop rows where either Aux2 or Aux equals 1
drop if Aux2 == 1 | Aux == 1
drop Aux*

// Generate a new "Aux" variable as 1 if Exp is not empty and the Exp value four rows down is not empty
gen Aux = 1 if Exp != "" & Exp[_n+4] != "".

// Generate a new "Aux2" variable to flag rows where the previous row or two rows up had Aux equal to 1
gen Aux2 = 1 if Aux[_n-1] == 1 | Aux[_n-2] == 1

// Drop rows where either Aux2 or Aux equals 1
drop if Aux2 == 1 | Aux == 1
drop Aux*

// Drop rows where Season is not empty, but Exp in the next row is empty
drop if Season != "" & Exp[_n+1] == ""
drop if Exp != ""

// Replace "Equipo" with the value from the previous row if ExpJ is not empty, propagating the team name downwards
replace Equipo = Equipo[_n-1] if ExpJ != ""

drop Exp
drop x

// Iterate over the variables Season, Jornada, Acta, homeEquipo, and awayEquipo
foreach var in Season Jornada Acta homeEquipo awayEquipo{
	    // Replace the current variable with the value from the previous row if it is empty
replace `var' = `var'[_n-1] if `var' == ""
}

// Generate a new variable "Partido" by concatenating homeEquipo and awayEquipo with "vs" as the punctuation
egen Partido = concat(homeEquipo awayEquipo), punct(" vs ")

replace ExpJ = "1" if ExpJ != ""
destring ExpJ, replace

// Collapse the dataset by summing ExpJ for each combination of Season, Jornada, Acta, Partido, and Equipo
collapse (sum) ExpJ, by(Season Jornada Acta Partido Equipo)
drop if Equipo == ""

// Replace the string "Jornada Nº " with "La Liga (Matchweek " in the Jornada variable for better formatting
replace Jornada = subinstr(Jornada, "Jornada Nº ", "La Liga (Matchweek ", .)
gen Aux = ")"

// Concatenate Jornada and Aux into a new variable "J"
egen J = concat(Jornada Aux)
replace Jornada = J
drop Aux-J

// Assign season, matchweek, match details, and expulsion data for missing matches
{
insobs 4
replace Season = "Temporada 2006/2007" in 2165/2166
replace Jornada = "La Liga (Matchweek 19)" in 2165/2166
replace Partido = "Atlético Madrid vs Osasuna" in 2165/2166
replace ExpJ = 1 in 2165
replace Equipo = "Osasuna" in 2165

replace ExpJ = 0 in 2166
replace Equipo = "Atlético Madrid" in 2166

replace Season = "Temporada 2009/2010" in 2167/2168
replace Jornada = "La Liga (Matchweek 10)" in 2167/2168
replace Partido = "Valladolid vs Xerez" in 2167/2168
replace ExpJ = 0 in 2167
replace Equipo = "Valladolid" in 2167

replace ExpJ = 1 in 2168
replace Equipo = "Xerez" in 2168
}

// Define a label for matchweeks (1 to 38) with corresponding descriptions
{
lab def Matchweek 1 "La Liga (Matchweek 1)" 2 "La Liga (Matchweek 2)" 3 "La Liga (Matchweek 3)" 4 "La Liga (Matchweek 4)" 5 "La Liga (Matchweek 5)" 6 "La Liga (Matchweek 6)" 7 "La Liga (Matchweek 7)" 8 "La Liga (Matchweek 8)" 9 "La Liga (Matchweek 9)" 10 "La Liga (Matchweek 10)" 11 "La Liga (Matchweek 11)" 12 "La Liga (Matchweek 12)" 13 "La Liga (Matchweek 13)" 14 "La Liga (Matchweek 14)" 15 "La Liga (Matchweek 15)" 16 "La Liga (Matchweek 16)" 17 "La Liga (Matchweek 17)" 18 "La Liga (Matchweek 18)" 19 "La Liga (Matchweek 19)" 20 "La Liga (Matchweek 20)" 21 "La Liga (Matchweek 21)" 22 "La Liga (Matchweek 22)" 23 "La Liga (Matchweek 23)" 24 "La Liga (Matchweek 24)" 25 "La Liga (Matchweek 25)" 26 "La Liga (Matchweek 26)" 27 "La Liga (Matchweek 27)" 28 "La Liga (Matchweek 28)" 29 "La Liga (Matchweek 29)" 30 "La Liga (Matchweek 30)" 31 "La Liga (Matchweek 31)" 32 "La Liga (Matchweek 32)" 33 "La Liga (Matchweek 33)" 34 "La Liga (Matchweek 34)" 35 "La Liga (Matchweek 35)" 36 "La Liga (Matchweek 36)" 37 "La Liga (Matchweek 37)" 38 "La Liga (Matchweek 38)"
encode Jornada, gen(Matchweek)
drop Jornada
}

// Remove the word "Temporada" and spaces from the Season variable for formatting purposes
replace Season = subinstr(Season, "Temporada ", "", .)
replace Season = subinstr(Season, " ", "", .)

// Create a new variable "Year" by extracting the first 4 characters from Season
gen Year = substr(Season,1,4)
destring Year, replace

// Define a label for teams with their corresponding numeric codes
{
lab def team 1 "Alavés" 2 "Albacete" 3 "Almería" 4 "Athletic Club" 5 "Atlético Madrid" 6 "Barcelona" 7 "Betis" 8 "Celta Vigo" 9 "Cádiz" 10 "Córdoba" 11 "Deportivo La Coruña" 12 "Eibar" 13 "Elche" 14 "Espanyol" 15 "Extremadura" 16 "Getafe" 17 "Gimnàstic" 18 "Girona" 19 "Granada" 20 "Huesca" 21 "Hércules" 22 "Las Palmas" 23 "Leganés" 24 "Levante" 25 "Mallorca" 26 "Málaga" 27 "Numancia" 28 "Osasuna" 29 "Oviedo" 30 "Racing Santander" 31 "Rayo Vallecano" 32 "Real Madrid" 33 "Real Murcia" 34 "Real Sociedad" 35 "Recreativo" 36 "Salamanca" 37 "Sevilla" 38 "Sporting Gijón" 39 "Tenerife" 40 "Valencia" 41 "Valladolid" 42 "Villarreal" 43 "Xerez" 44 "Zaragoza" 
// Convert the Equipo variable to numeric based on the team label
encode Equipo, gen(team)
}


// Split the Partido variable into two new variables (Partido1 and Partido2) by using "vs" as the separator
split Partido, p(" vs ") limit(1)
gen Local = 1 if Equipo == Partido1
sort Matchweek Year Partido Local

// Generate variables for yellow cards (second yellow card leading to red) for home and away teams
gen SecYCrdHOME = ExpJ if Local == 1
gen SecYCrdAWAY = ExpJ if Local != 1
replace SecYCrdAWAY = 0 if SecYCrdAWAY == .
replace SecYCrdHOME = 0 if SecYCrdHOME == .

// Calculate the mean of SecYCrdHOME and SecYCrdAWAY by Partido and Acta, then drop matches where both means are zero (no expulsions)
by Partido Acta, sort: egen mean=mean(SecYCrdHOME)
by Partido Acta, sort: egen mean1=mean(SecYCrdAW)
drop if mean == 0 & mean1 == 0

// Keep only the relevant variables and rename team back to Equipo
keep Year Season Matchweek Partido Sec* team
rename team Equipo
sort Year Season Matchweek Partido

// Save the dataset
cd "$externaldata"
save YellowCrdsCorrection.dta, replace

/*
/*
Temporada	Jornada	Acta	Partido	ExpJ
Temporada 2005/2006 	Jornada Nº 29	Acta del Partido celebrado el 23 de marzo de 2006, en Madrid	Club Atlético de Madrid SAD vs Sevilla FC SAD	2 *********
Temporada 2007/2008 	Jornada Nº 5	Acta del Partido celebrado el 26 de septiembre de 2007, en Murcia	Real Murcia CF vs UD Almería SAD	2 *******
Temporada 2009/2010 	Jornada Nº 37	Acta del Partido celebrado el 08 de mayo de 2010, en Villarreal	Villarreal CF SAD vs Valencia CF SAD	2*****
Temporada 2009/2010 	Jornada Nº 6	Acta del Partido celebrado el 04 de octubre de 2009, en Valladolid	Real Valladolid CF SAD vs Athletic Club	2 *****
*/
*/