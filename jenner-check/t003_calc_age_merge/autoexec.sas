options obs=100;
/*
 * Stand-in for hbeat.heartbeatmeasurements.
 *
 * The hbeatages step in prepare-heartbeat-for-nsrr.sas reads date of birth
 * and measurement date from hbeat.heartbeatmeasurements (a network-share
 * libname). This autoexec supplies a small heartbeatmeasurements with two
 * timepoints per participant so the dedup-then-merge logic in script.sas
 * runs unchanged. Dates use the date9. informat as SAS date values.
 */
data heartbeatmeasurements;
  informat dob meas_date date9.;
  format dob meas_date date9.;
  input studyid timepoint dob meas_date;
  datalines;
10001 2 15JUN1958 20MAR2012
10001 7 15JUN1958 12SEP2013
10002 2 03JAN1949 18MAY2012
10002 7 03JAN1949 02NOV2013
10003 2 22DEC1962 09AUG2012
;
run;
