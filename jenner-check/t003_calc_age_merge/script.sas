*******************************************************************************;
* hbeatages: calculate age at each measurement                                ;
* (from scripts/prepare-heartbeat-for-nsrr.sas)                               ;
*                                                                              ;
* Pulls one date-of-birth row per participant (PROC SORT NODUPKEY), merges it  ;
* back onto every measurement record, keeps only matched participants, and     ;
* computes age in years at each timepoint from the measurement-date minus      ;
* date-of-birth difference.                                                    ;
*******************************************************************************;

  data dob;
    set heartbeatmeasurements;

    keep studyid dob;
  run;

  proc sort data=dob nodupkey;
    by studyid;
  run;

  data hbeatages;
    merge dob (in=a) heartbeatmeasurements (drop=dob);
    by studyid;
    if a;
    calc_age = (meas_date - dob) / 365.25;
    keep studyid timepoint calc_age;
  run;

  proc print data=hbeatages noobs;
    format calc_age 8.2;
    title "HeartBEAT age at each measurement (hbeatages)";
  run;
