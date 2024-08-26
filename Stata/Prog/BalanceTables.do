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

// Import final datasets
use $externaldata/FinalCorr.dta, clear
//Tablas de balance
cd "$tables\BalanceTables"

// Create a balance table for several variables, grouped by 'Barca', and save the table as 'BarcaLaLiga'
iebaltab Fouls Fld Yellow* Red* Offsides PenAtt PenConc, grpvar(Barca) save(BarcaLaLiga) replace

// Create a balance table for several variables, grouped by 'BarcaOReal', and save the table as 'BarcaOReal'
iebaltab Fouls Fld Yellow* Red* Offsides PenAtt PenConc, grpvar(BarcaOReal) save(BarcaOReal) replace

// Create a balance table for yellow cards, red cards, penalties attempted and conceded, grouped by 'Cohorte', and save as 'Cohorte'
iebaltab Yellow* Red* PenAtt PenConc, grpvar(Cohorte) save(Cohorte) replace

// Create a balance table for the same variables but only for the team with 'Equipo' equal to 6 (likely Barcelona), grouped by 'Cohorte', and save as 'CohortesBarca'
iebaltab Yellow* Red* PenAtt PenConc if Equipo==6, grpvar(Cohorte) save(CohortesBarca) replace

// Create a balance table for the same variables but only for the team with 'Equipo' equal to 32 (likely Real Madrid), grouped by 'Cohorte', and save as 'CohortesRealMadrid'
iebaltab Yellow* Red* PenAtt PenConc if Equipo==32, grpvar(Cohorte) save(CohortesRealMadrid) replace

/*
No stars: This indicates that there is no statistically significant evidence that the difference in means between the two groups is different from zero. In other words, the data suggests that the difference in means is likely to be zero, implying balance between the groups.

With stars: Stars indicate that the difference in means between the two groups is statistically significant. This means there is evidence that the difference in means is not zero, suggesting an imbalance. This could imply that one group is favored or has a different outcome compared to the other.
*/