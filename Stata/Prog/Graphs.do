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


cd "$externaldata"
use FinalCorr.dta,clear

// Create a new variable 'RMFB' to categorize teams: 
// 1 for Barcelona (Equipo == 6), 2 for Real Madrid (Equipo == 32), and 0 for others
gen RMFB = 1 if Equipo == 6
replace RMFB = 2 if Equipo == 32
replace RMFB = 0 if RMFB == .

// Save the current dataset state
preserve

// Collapse the data by calculating the mean of certain variables (e.g., Fouls, Yellow Cards) grouped by 'RMFB' and 'TdePagos'
// Drop the 'FinalResult' variable as it is no longer needed after collapsing
collapse (mean) GoalD F* Yellow* Red* Pen*, by(RMFB TdePagos)
drop FinalResult

set scheme s2color

cd "$graphs"

// Generate a connected line graph for fouls against teams (Barcelona, other teams, Real Madrid)
twoway (connected Fouls TdePagos if RMFB==1, color(dknavy)) ///
	(connected Fouls TdePagos if RMFB==0, color(magenta)) ///
	(connected Fouls TdePagos if RMFB==2, color(gold)), ///
	xlabel(0(1)1, labsize(large)) ylabel(, labsize(large)) ///
	legend(label(1 "Barcelona") label(2 "Rest of the LaLiga teams") label(3 "Real Madrid")) ///
	ytitle("Fouls against", size(large)) xtitle("") name(FoulsC1tr,replace)

// Generate a connected line graph for fouls in favor of teams (Barcelona, other teams, Real Madrid)
twoway (connected Fld TdePagos if RMFB==1, color(dknavy)) ///
	(connected Fld TdePagos if RMFB==0, color(magenta)) ///
	(connected Fld TdePagos if RMFB==2, color(gold)), ///
	xlabel(0(1)1, labsize(large)) ylabel(, labsize(large)) ///
	legend(label(1 "Barcelona") label(2 "Rest of the LaLiga teams") label(3 "Real Madrid")) ///
	ytitle("Fouls in Favor", size(large)) xtitle("") name(FoulsF1tr,replace)

// Generate a connected line graph for yellow cards against teams (Barcelona, other teams, Real Madrid)
twoway (connected YellowC TdePagos if RMFB==1, color(dknavy)) ///
	(connected YellowC TdePagos if RMFB==0, color(magenta)) ///
	(connected YellowC TdePagos if RMFB==2, color(gold)), ///
	xlabel(0(1)1, labsize(large)) ylabel(, labsize(large)) ///
	legend(label(1 "Barcelona") label(2 "Rest of the LaLiga teams") label(3 "Real Madrid")) ///
	ytitle("Yellow Cards against", size(large)) xtitle("") name(YellowC1tr,replace)

// Generate a connected line graph for yellow cards in favor of teams (Barcelona, other teams, Real Madrid)
twoway (connected YellowF TdePagos if RMFB==1, color(dknavy)) ///
	(connected YellowF TdePagos if RMFB==0, color(magenta)) ///
	(connected YellowF TdePagos if RMFB==2, color(gold)), ///
	xlabel(0(1)1, labsize(large)) ylabel(, labsize(large)) ///
	legend(label(1 "Barcelona") label(2 "Rest of the LaLiga teams") label(3 "Real Madrid")) ///
	ytitle("Yellow Cards in Favor", size(large)) xtitle("") name(YellowF1tr,replace)

// Generate a connected line graph for red cards against teams (Barcelona, other teams, Real Madrid)
twoway (connected RedC TdePagos if RMFB==1, color(dknavy)) ///
	(connected RedC TdePagos if RMFB==0, color(magenta)) ///
	(connected RedC TdePagos if RMFB==2, color(gold)), ///
	xlabel(0(1)1, labsize(large)) ylabel(, labsize(large)) ///
	legend(label(1 "Barcelona") label(2 "Rest of the LaLiga teams") label(3 "Real Madrid")) ///
	ytitle("Red Cards against", size(large)) xtitle("") name(RedC1tr,replace)

// Generate a connected line graph for red cards in favor of teams (Barcelona, other teams, Real Madrid)
twoway (connected RedF TdePagos if RMFB==1, color(dknavy)) ///
	(connected RedF TdePagos if RMFB==0, color(magenta)) ///
	(connected RedF TdePagos if RMFB==2, color(gold)), ///
	xlabel(0(1)1, labsize(large)) ylabel(, labsize(large)) ///
	legend(label(1 "Barcelona") label(2 "Rest of the LaLiga teams") label(3 "Real Madrid")) ///
	ytitle("Red Cards in Favor", size(large)) xtitle("") name(RedF1tr,replace)

// Generate a connected line graph for penalty kicks against teams (Barcelona, other teams, Real Madrid)
twoway (connected PenC TdePagos if RMFB==1, color(dknavy)) ///
	(connected PenC TdePagos if RMFB==0, color(magenta)) ///
	(connected PenC TdePagos if RMFB==2, color(gold)), ///
	xlabel(0(1)1, labsize(large)) ylabel(, labsize(large)) ///
	legend(label(1 "Barcelona") label(2 "Rest of the LaLiga teams") label(3 "Real Madrid")) ///
	ytitle("Penalty Kicks against", size(large)) xtitle("") name(PenC1tr,replace)

// Generate a connected line graph for penalty kicks in favor of teams (Barcelona, other teams, Real Madrid)
twoway (connected PenA TdePagos if RMFB==1, color(dknavy)) ///
	(connected PenA TdePagos if RMFB==0, color(magenta)) ///
	(connected PenA TdePagos if RMFB==2, color(gold)), ///
	xlabel(0(1)1, labsize(large)) ylabel(, labsize(large)) ///
	legend(label(1 "Barcelona") label(2 "Rest of the LaLiga teams") label(3 "Real Madrid")) ///
	ytitle("Penalty Kicks in Favor", size(large)) xtitle("") name(PenF1tr,replace)

// Generate a connected line graph for goal difference across teams (Barcelona, other teams, Real Madrid)
twoway (connected GoalD TdePagos if RMFB==1, color(dknavy) sort) (connected GoalD TdePagos if RMFB==0, color(magenta) sort) (connected GoalD TdePagos if RMFB==2, color(gold)), ///
	xlabel(0(1)1, labsize(large)) ylabel(, labsize(large)) ///
	legend(label(1 "Barcelona") label(2 "Rest of the LaLiga teams") label(3 "Real Madrid")) ///
	ytitle("Goal Difference", size(large)) xtitle("") name(GoalF1tr,replace)

// Combine fouls-related graphs into one graph with a common y-axis
graph combine FoulsC1tr FoulsF1tr, ycommon name(combineFoulsC1tr,replace)

// Combine penalty-related graphs into one graph with a common y-axis
graph combine PenC1tr PenF1tr, ycommon name(combinePenaltiesC1tr,replace)

// Combine yellow card-related graphs into one graph with a common y-axis
graph combine YellowC1tr YellowF1tr, ycommon name(combineYellowC1tr,replace)

// Combine red card-related graphs into one graph with a common y-axis
graph combine RedC1tr RedF1tr, ycommon name(combineRedC1tr,replace)

// Generate a combined graph of fouls, penalties, yellow cards, and red cards with a common legend and smaller labels
grc1leg2 combineFoulsC1tr combinePenaltiesC1tr combineYellowC1tr combineRedC1tr, legendfrom(combineFoulsC1tr) labsize(small) saving(graphRMFCB_stats, replace) lcols(3)

restore
