# Gravity-Estimation
Estimates gravity parameters as in... 

[1] Eaton, Jonathan, and Samuel Kortum. "Technology, geography, and trade." Econometrica 70.5 (2002): 1741-1779.

[2] Waugh, Michael. "International trade and income differences." The American Economic Review 100.5 (2010): 2093-2124. 

via STATA and computes bilateral trade flows.

Often I get asked how to perform the regressions in Waugh(2010) and inturn EK(2002). My initial code to perform the ``gravity'' regressions (as posted on the AER replication site) is very convoluted, hard to understand. The goal here is to simplify things and make it easy.

This code does several things...

(1) The main driver file is stata_to_tau_to_trade.m It calls a STATA .do file gravity_run.do. The innovation here is that this STATA file shows how to perform this estimation in STATA which is very easy to implement and understand. 

(2) This code then ports in the estimates from STATA into MATLAB. Within MATLAB, there are two options on how to construct trade costs depending upon your view of the them (i.e. the asymmetric component is on the import side as in EK(2002) or the asymmetric componenet is on the export side as in Waugh (2010)). 

(3) Given the trade costs and technology parameters (specifically the S's in EK's notation), I then compute trade flows and compare them to data. I do this via simmulation by calling the file sim_trade_pattern_ek.m. One could also use the formulas from EK or Waugh to construct these as well. 

