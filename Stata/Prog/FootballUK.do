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

//*Cards and final results data from FootballUK*//

foreach season in "9899" "9900" "0001" "0102" "0203" "0304" "0405" "0506" "0607" "0708" "0809" "0910" "1011" "1112" "1213" "1314" "1415" "1516" "1617" "1718" "1819" "1920" "2021" "2122"{

// Import data and keep variables of interest
import delimited "$data\FootballUK\SP1`season'.csv", clear
display "`season'"

if "`season'" == "9899" | "`season'" == "9900" | "`season'" == "0001" | "`season'" == "0102" | "`season'" == "0203" | "`season'" == "0304" | "`season'" == "0405"{
	keep date *team ftr fthg ftag
}
else {
	keep date *team ftr fthg ftag hf af /*ho ao*/ hy ay hr ar
}

gen Season="`season'"

cd "$externaldata"
if "`season'" == "9899"{
	save TeamPMatch.dta,replace
}
else{
	append using TeamPMatch.dta
	save TeamPMatch.dta,replace
}

// Gen Year variable
quietly{
gen Year=1998
replace Year=1999 if Season=="9900"
replace Year=2000 if Season=="0001"
replace Year=2001 if Season=="0102"
replace Year=2002 if Season=="0203"
replace Year=2003 if Season=="0304"
replace Year=2004 if Season=="0405"
replace Year=2005 if Season=="0506"
replace Year=2006 if Season=="0607"
replace Year=2007 if Season=="0708"
replace Year=2008 if Season=="0809"
replace Year=2009 if Season=="0910"
replace Year=2010 if Season=="1011"
replace Year=2011 if Season=="1112"
replace Year=2012 if Season=="1213"
replace Year=2013 if Season=="1314"
replace Year=2014 if Season=="1415"
replace Year=2015 if Season=="1516"
replace Year=2016 if Season=="1617"
replace Year=2017 if Season=="1718"
replace Year=2018 if Season=="1819"
replace Year=2019 if Season=="1920"
replace Year=2020 if Season=="2021"
replace Year=2021 if Season=="2122"
replace Year=2022 if Season=="2223"
replace Year=2023 if Season=="2324"

// Standarize the names of the clubs
foreach var in hometeam awayteam{
replace `var'=subinstr(`var',"Almeria","Almería",.)
replace `var'=subinstr(`var',"Ath Bilbao","Athletic Club",.)
replace `var'=subinstr(`var',"Ath Madrid","Atlético Madrid",.)
replace `var'=subinstr(`var',"Betis","Real Betis",.)
replace `var'=subinstr(`var',"Cadiz","Cádiz",.)
replace `var'=subinstr(`var',"Celta","Celta Vigo",.)
replace `var'=subinstr(`var',"Cordoba","Córdoba",.)
replace `var'=subinstr(`var',"Alaves","Alavés",.)
replace `var'=subinstr(`var',"La Coruna","Deportivo La Coruña",.)
replace `var'=subinstr(`var',"Gimnastic","Gimnàstic",.)
replace `var'=subinstr(`var',"Hercules","Hércules",.)
replace `var'=subinstr(`var',"Malaga","Málaga",.)
replace `var'=subinstr(`var',"Espanol","Espanyol",.)
replace `var'=subinstr(`var',"Leganes","Leganés",.)
replace `var'=subinstr(`var',"Murcia","Real Murcia",.)
replace `var'=subinstr(`var',"Real Oviedo","Oviedo",.)
replace `var'=subinstr(`var',"Sp Gijon","Sporting Gijón",.)
replace `var'=subinstr(`var',"Sociedad","Real Sociedad",.)
replace `var'=subinstr(`var',"Santander","Racing Santander",.)
replace `var'=subinstr(`var',"Vallecano","Rayo Vallecano",.)
replace `var'=subinstr(`var',"Villareal","Villarreal",.)
}
}

sort Year
}

// Rename and label variables
{
rename fthg FinalGHome
rename ftag FinalGAway
rename ftr FullTime
rename hf homefouls
rename af awayfouls
rename ay awayYellow
rename hy homeYellow
rename ar awayRed
rename hr homeRed

label var hometeam "Home Team"
label var awayteam "Away Team"
label var FinalGAway "Full Time Home Team Goals"
label var FinalGHome "Full Time Away Team Goals"
label var FullTime "Full Time Result"
label var homefouls "Home Team Fouls Committed"
label var awayfouls "Away Team Fouls Committed"
label var homeYellow "Home Team Yellow Cards"
label var awayYellow "Away Team Yellow Cards"
label var homeRed "Home Team Red Cards"
label var awayRed "Away Team Red Cards"
label var Season "Season"
label var Year "Year"
}

egen Partido=concat(hometeam awayteam), punc(" vs ")

// Adjust date format
replace date=subinstr(date,"/98","/1998",.)
replace date=subinstr(date,"/99","/1999",.)
replace date=subinstr(date,"/00","/2000",.)

forvalues i = 13/18{
replace date=subinstr(date,"/`i'","/20`i'",.)
}

forvalues year = 1/12{
	forvalues month = 1/12{
		if `year' < 9{
			if `month' < 10{
				replace date=subinstr(date,"/0`month'/0`year'","/0`month'/200`year'",.)
			}
			else{
				replace date=subinstr(date,"/`month'/0`year'","/`month'/200`year'",.)
			}
		}
		else{
			if `month' < 10{
				replace date=subinstr(date,"/0`month'/`year'","/0`month'/20`year'",.)
			}
			else{
				replace date=subinstr(date,"/`month'/`year'","/`month'/20`year'",.)
			}
		}
}
}

// Generate date variable
gen newdate = date(date, "DMY")
format newdate %td
drop date
rename newdate date

// Order, sort and save data
order date, first
sort date

cd "$externaldata/FootballUK"
save FootballUKdata.dta,replace

********************************************************************************
********************************************************************************
********************************************************************************

//*Odds data from FootballUK*//
foreach season in "9899" "9900" "0001" "0102" "0203" "0304" "0405" "0506" "0607" "0708" "0809" "0910" "1011" "1112" "1213" "1314" "1415" "1516" "1617" "1718" "1819" "1920" "2021" "2122"{
display "`season'"

// Import data
import delimited "$data\FootballUK\SP1`season'.csv", clear

// Generate Season data
gen year="`season'"
quietly{
	gen Season = 1998 if "`season'" == "9899"
	replace Season = 1999 if "`season'" == "9900"
	replace Season = 2000 if "`season'" == "0001"
	replace Season = 2001 if "`season'" == "0102"
	replace Season = 2002 if "`season'" == "0203"
	replace Season = 2003 if "`season'" == "0304"
	replace Season = 2004 if "`season'" == "0405"
	replace Season = 2005 if "`season'" == "0506"
	replace Season = 2006 if "`season'" == "0607"
	replace Season = 2007 if "`season'" == "0708"
	replace Season = 2008 if "`season'" == "0809"
	replace Season = 2009 if "`season'" == "0910"
	replace Season = 2010 if "`season'" == "1011"
	replace Season = 2011 if "`season'" == "1112"
	replace Season = 2012 if "`season'" == "1213"
	replace Season = 2013 if "`season'" == "1314"
	replace Season = 2014 if "`season'" == "1415"
	replace Season = 2015 if "`season'" == "1516"
	replace Season = 2016 if "`season'" == "1617"
	replace Season = 2017 if "`season'" == "1718"
	replace Season = 2018 if "`season'" == "1819"
	replace Season = 2019 if "`season'" == "1920"
	replace Season = 2020 if "`season'" == "2021"
	replace Season = 2021 if "`season'" == "2122"
}

// Save and append in one dta
cd "$externaldata"
if "`season'" == "9899"{
	save ODDS.dta,replace
}
else {
	append using ODDS.dta
	save ODDS.dta,replace
}
}

/*
keep b365h b365d b365a bwh bwd bwa iwh iwd iwa psh psd psa whh whd wha vch vcd vca maxh maxd maxa avgh avgd avga lbh lbd lba sjd sja sjh gbh gbd gba bsh bsd bsa sbh sbd sba v45 v46 v47 v48 v50 soh sod soa syh syd sya v11 v12 v13 v14 v15 v16
*/


// Generate Partido variable
egen Partido = concat(hometeam awayteam), punct(" vs ")

// Keep variables needed
keep date hometeam awayteam iwh iwa iwd Season Partido

// Add labels
label var iwh "Interwetten home win odds"
label var iwd "Interwetten draw odds"
label var iwa "Interwetten away win odds"
label var Season "Season"
label var Partido "Partido"

qui{

// Adjust date information
replace date= subinstr(date, "/00", "/2000", .)

forvalues i=1/12{
if `i'<10{
	replace date= subinstr(date, "/0`i'/01", "/0`i'/2001", .)
	replace date= subinstr(date, "/0`i'/02", "/0`i'/2002", .)
}
else{
	replace date= subinstr(date, "/`i'/01", "/`i'/2001", .)
	replace date= subinstr(date, "/`i'/02", "/`i'/2002", .)
}
}

// Generate date
gen matchday=date(date, "DMY")
format matchday %td
sort matchday

// Standarize the names of the teams
foreach var in hometeam awayteam Partido{
	replace `var'= subinstr(`var', "Alaves", "Alavés", .)
	replace `var'= subinstr(`var', "Almeria", "Almería", .)
	replace `var'= subinstr(`var', "Ath Bilbao", "Athletic Club", .)
	replace `var'= subinstr(`var', "Ath Madrid", "Atlético Madrid", .)
	replace `var'= subinstr(`var', "Cadiz", "Cádiz", .)
	replace `var'= subinstr(`var', "Celta", "Celta Vigo", .)
	replace `var'= subinstr(`var', "Cordoba", "Córdoba", .)
	replace `var'= subinstr(`var', "Espanol", "Espanyol", .)
	replace `var'= subinstr(`var', "Gimnastic", "Gimnàstic", .)
	replace `var'= subinstr(`var', "Hercules", "Hércules", .)
	replace `var'= subinstr(`var', "La Coruna", "Deportivo La Coruña", .)
	replace `var'= subinstr(`var', "Malaga", "Málaga", .)
	replace `var'= subinstr(`var', "Murcia", "Real Murcia", .)
	replace `var'= subinstr(`var', "Santander", "Racing Santander", .)
	replace `var'= subinstr(`var', "Sp Gijon", "Sporting Gijón", .)
	replace `var'= subinstr(`var', "Sociedad", "Real Sociedad", .)
	replace `var'= subinstr(`var', "Vallecano", "Rayo Vallecano", .)
	replace `var'= subinstr(`var', "Villareal", "Villarreal", .)
	replace `var'= subinstr(`var', "Leganes", "Leganés", .)
	*replace `var'= subinstr(`var', "", "", .)
	*replace `var'= subinstr(`var', "", "", .)
}
}

rename Season Year
keep iw* Year Partido matchday
sort matchday

// Save data
cd "$externaldata"
save ODDS.dta,replace