options obs=100;
/*
 * Stand-in for the HeartBEAT `hbeat` libname.
 *
 * prepare-heartbeat-for-nsrr.sas reads hbeat.heartbeathhqbaseline from a
 * BWH SleepEpi network share. This autoexec creates a small in-memory
 * heartbeathhqbaseline holding just the columns the race7 recode touches
 * (the race indicators, ethnicity, otherrace, and bwalkhurry), so the
 * recode logic in script.sas runs unchanged.
 */
data heartbeathhqbaseline;
  input studyid ethnicity otherrace white black hawaii asian amerindian bwalkhurry;
  datalines;
10001 2 0 1 0 0 0 0 1
10002 2 0 0 1 0 0 0 2
10003 1 1 0 0 0 0 0 3
10004 2 0 1 1 0 0 0 1
10005 2 0 0 0 0 1 0 2
10006 2 0 0 0 1 0 0 1
10007 2 0 0 0 0 0 1 2
10008 2 0 1 0 1 0 0 1
;
run;
