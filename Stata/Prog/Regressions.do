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
xtset Equipo date

cd "$tables/Regressions"

// WIN

xtprobit Win DiffMktValue Local Yellow* Red* PenAtt PenConc
outreg2 using WIN_MKT.doc, dec(3) replace depvar cttop(All teams in La Liga)

xtprobit Win DiffMktValue Local Yellow* Red* PenAtt PenConc Fouls Fld
outreg2 using WIN_MKT.doc, dec(3) append depvar cttop(All teams in La Liga)


xtprobit Win DifBookMaker Local Yellow* Red* PenAtt PenConc
outreg2 using WIN_BOOKMAKER.doc, dec(3) replace depvar cttop(All teams in La Liga)

xtprobit Win DifBookMaker Local Yellow* Red* PenAtt PenConc Fouls Fld
outreg2 using WIN_BOOKMAKER.doc, dec(3) append depvar cttop(All teams in La Liga)



// GoalDiff

xtprobit GoalDiff DifBookMaker i.Local Yellow* Red* Pen* Fouls Fld i.Bribe
outreg2 using GD_BOOKMAKER.doc, replace cttop(Toda La Liga) depvar

xtprobit GoalDiff DifBookMaker i.Local Yellow* Red* Pen* i.Bribe
outreg2 using GD_BOOKMAKER.doc, append cttop(Toda La Liga) depvar
