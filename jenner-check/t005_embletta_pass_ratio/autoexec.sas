options obs=100;
/*
 * Stand-in for hbeat.heartbeatembletta.
 *
 * The embletta steps in prepare-heartbeat-for-nsrr.sas read the home
 * sleep-study (Embletta) records from a network-share libname. This autoexec
 * supplies a small heartbeatembletta with the columns those steps touch
 * (study id, scoring pass, central/obstructive apnea counts, AHI, date),
 * including the two participants the program reclassifies by hand, so the
 * pass-filter and ratio logic in script.sas runs unchanged.
 */
data heartbeatembletta;
  informat embq_date date9.;
  format embq_date date9.;
  input studyid pass nca noa aphypi embq_date;
  datalines;
10001 1 12 30 22.4 05FEB2011
10001 2 8 25 18.1 14MAR2012
10599 1 5 40 31.7 21JUN2011
10599 3 6 22 12.9 09NOV2013
10002 1 9 33 25.0 03JAN2011
10003 2 4 18 9.8 17AUG2012
;
run;
