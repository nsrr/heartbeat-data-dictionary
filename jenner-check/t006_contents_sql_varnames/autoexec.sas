options obs=100;
/*
 * Stand-in for hbeat_baseline (the merged baseline dataset).
 *
 * The variable-renaming section of prepare-heartbeat-for-nsrr.sas runs
 * PROC CONTENTS to capture the column list, then PROC SQL to pull the
 * sf36_-prefixed and the baseline MedsHQ ("b...") column names into macro
 * variables. This autoexec supplies a small hbeat_baseline whose column
 * names follow those naming conventions, so the metadata-driven name
 * collection in script.sas runs unchanged.
 */
data hbeat_baseline;
  input studyid sf36_bp_z sf36_gh_z sf36_mh_z sf36_pf_z
        bwalkhurry bmovelegs bbathroom
        bp24date bmi bothered bsnore;
  datalines;
10001 0.5 -0.3 1.2 0.7 2 1 0 5 27.3 0 1
10002 -1.1 0.8 0.0 -0.4 3 0 1 4 31.8 1 0
10003 0.2 0.1 -0.9 1.5 1 1 1 6 24.9 0 1
;
run;
