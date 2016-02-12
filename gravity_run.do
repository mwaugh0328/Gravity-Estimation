*********************************************************************************************************
* Sample code on how to run a gravity regression of the type in Eaton and Kortum (2002) or in Waugh (2010).
* The code is intended to be called from matlab, from which the estimated coefficients are used to construct
* trade costs, trade pattern computed, etc...
*
* Note that the regression one runs here is independent of the interpretation of their being import or export
* fixed effects on the trade costs. The interpretation only matters when reconstructing the implied trade costs
* to compute an equilibrium...the matlab code makes that very clear...
*
* Michael Waugh 1/2016
*********************************************************************************************************
clear all

set more off
cd "C:\Users\mwaugh\Dropbox\Github Code\EK Waugh Gravity"
insheet using "gravity_data.csv"

*********************************************************************************************************
* Just some house keeping here
rename v1 importer
rename v2 exporter
rename v3 trade_data
rename v4 distance
rename v5 border

*********************************************************************************************************
* Put the relavent stuff in logs, and if using the non-parametric approach construct the
* distance intervals

* Drop the home trade share observations
drop if trade_data == 1

gen ln_trade = ln(trade_data)
gen ln_distc = ln(distance)

gen dis1 = 0
replace dis1 = 1 if distance <= 375

gen dis2 =0
replace dis2 = 1 if distance > 375 & distance <= 750

gen dis3 =0
replace dis3 = 1 if distance > 750 & distance <= 1500

gen dis4 =0
replace dis4 = 1 if distance > 1500 & distance <= 3000

gen dis5 =0
replace dis5 = 1 if distance > 3000 & distance <= 6000

gen dis6 = 0 
replace dis6 = 1 if distance > 6000

*set matsize 1000
*mkmat dis1 dis2 dis3 dis4 dis5 dis6, matrix(dist)

* Drop zeros---NOT A BIG DEAL!
drop if trade_data == 0

*********************************************************************************************************
* This allows one to arbitrarily pick the base for the dummy variables. If base = 1, then all the exporter
* effects are interpreted relative to county 1, etc. This does not matter for constructing trade costs or trade
* flows, etc. It can matter for the counterfactual.

fvset base 1 importer
fvset base 1 exporter

regress ln_trade i.exporter i.importer dis1 dis2 dis3 dis4 dis5 dis6 border, noconstant robust

*********************************************************************************************************
* Now we want to take the regression coeffecients and pop them into matlab so we can construct the trade
* frictions

matrix define coeff = e(b)
drop*
svmat coeff
outsheet coeff* using "coeff.txt", replace nonames
clear

exit, STATA
