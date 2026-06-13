options obs=100;
/*
 * Stand-in for the HeartBEAT `hbeat` libname / merged base dataset.
 *
 * The harmonization step in prepare-heartbeat-for-nsrr.sas runs against
 * hbeat_total_base, which is assembled from many merged source tables. This
 * autoexec creates a small hbeat_total_base holding just the upstream
 * columns the harmonization reads (demographics, anthropometry, vitals,
 * smoking, and the polysomnography screening measures), so the harmonization
 * logic in script.sas runs unchanged.
 */
data hbeat_total_base;
  input nsrrid timepoint calc_age male race7 ethnicity bmi sysmean diasmean
        smoked smokedmonth ahi_screening index_time;
  datalines;
3001 2 52.4 1 1 2 27.3 128.5 82.1 1 1 12.4 410.2
3002 2 67.1 0 3 2 31.8 141.2 90.4 2 . 28.7 388.0
3003 2 91.5 1 4 1 24.9 119.0 76.5 1 2 5.1 425.6
3004 2 58.0 0 7 2 29.1 135.7 88.0 . . 18.3 401.1
3005 2 45.8 1 . . 22.0 122.4 79.9 2 . 9.8 415.0
;
run;
