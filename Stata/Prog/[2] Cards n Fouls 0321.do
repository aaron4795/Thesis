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

foreach year in "0506" "0607" "0708" "0809" "0910" "1011" "1112" "1213" "1314" "1415" "1516" "1617" "1718" "1819" "1920" "2021" "2122"{
// Loop over each season year

// Import and keepp only team and foul/card-related variables
import delimited "$data\FootballUK\SP1`year'.csv", clear
keep *team hf af hy ay hr ar

// Rename variables for better clarity
rename hf homefouls
rename af awayfouls
rename hy homeyellow
rename ay awayyellow
rename hr homered
rename ar awayred

// Standarize the names of the teams
quietly{
foreach team in home away{
	replace `team'team = subinstr(`team'team, "Almeria", "Almería", .)
	replace `team'team = subinstr(`team'team, "Ath Bilbao", "Athletic Club", .)
	replace `team'team = subinstr(`team'team, "Ath Madrid", "Atlético Madrid", .)
	replace `team'team = subinstr(`team'team, "Cadiz", "Cádiz", .)
	replace `team'team = subinstr(`team'team, "Celta", "Celta Vigo", .)
	replace `team'team = subinstr(`team'team, "Córdoba CF", "Córdoba", .)
	replace `team'team = subinstr(`team'team, "Alaves", "Alavés", .)
	replace `team'team = subinstr(`team'team, "La Coruna", "La Coruña", .)
	replace `team'team = subinstr(`team'team, "Gimnastic", "Gimnàstic", .)
	replace `team'team = subinstr(`team'team, "Hercules", "Hércules", .)
	replace `team'team = subinstr(`team'team, "Malaga", "Málaga", .)
	replace `team'team = subinstr(`team'team, "Espanol", "Espanyol", .)
	replace `team'team = subinstr(`team'team, "Leganes", "Leganés", .)
	replace `team'team = subinstr(`team'team, "Murcia", "Real Murcia", .)
	replace `team'team = subinstr(`team'team, "Real Oviedo", "Oviedo", .)
	replace `team'team = subinstr(`team'team, "Sp Gijon", "Sporting Gijón", .)
	replace `team'team = subinstr(`team'team, "Sociedad", "Real Sociedad", .)
	replace `team'team = subinstr(`team'team, "Santander", "Racing Sant", .)
	replace `team'team = subinstr(`team'team, "Vallecano", "Rayo Vallecano", .)
}
}


foreach local in away home{
	// Loop over "away" and "home" categories
	// Define auxiliary variables based on whether the loop is for "home" or "away"
	if ("`local'" == "away") global control hometeam
	if ("`local'" == "home") global control awayteam
	
	foreach invlocal in $control{
	
	display "`local'-$control"
	
	foreach type in CARDS FOULS{
	// Preserve the data before collapsing
	preserve
	
	if "`type'" == "CARDS"{
		// Collapse data to sum yellow and red cards by the inverse team 
		collapse (sum) `local'yellow `local'red, by(`invlocal')
	}
	
	if "`type'" == "FOULS"{
		// Collapse data to sum fouls by the inverse team (invlocal)
		collapse (sum) `local'fouls, by(`invlocal')
	}
	
	gen Season="`year'"
	rename `invlocal' Equipo
	
	cd "$externaldata/FootballUK"
	if "`year'" == "0506"{
		// For the first year, save the data and replace any existing file
		save `invlocal'_`type'.dta, replace
	}
	else{
		// For subsequent years, append the data to the existing file
		append using `invlocal'_`type'
		save `invlocal'_`type'.dta, replace
	}
	// Restore the original data
	restore

}
}
}
}

// Merge datasets for home and away fouls/cards into a single dataset
cd "$externaldata/FootballUK"
use hometeam_FOULS.dta, clear
merge 1:1 Equipo Season using hometeam_CARDS.dta, nogen
merge 1:1 Equipo Season using awayteam_CARDS.dta, nogen
merge 1:1 Equipo Season using awayteam_FOULS.dta, nogen

// Generate variables for total yellow/red cards and fouls committed against each team
gen TA_favor = awayyellow + homeyellow
gen TR_favor = awayred + homered
gen fouls_favor = awayfouls + homefouls

// Drop unnecessary variables
foreach vardel in awayyellow awayred homeyellow homered awayfouls homefouls {
	drop `vardel'
}

// Clean up the Season variable
destring Sea, gen(aux)
drop if aux > 1314 // Drop observations after the 1314 season
drop aux

// Rename and sort variables for clarity
rename fouls_favor Fls_recibidasContra
sort Season Equipo

// Save the final dataset
cd "$externaldata"
save FAVOR_CARDSNFOULS.dta,replace