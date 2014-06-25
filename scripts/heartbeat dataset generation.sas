%include "\\rfa01\bwh-sleepepi-heartbeat\sas\heartbeat options and libnames.sas";

data hbeatelig;
  set hbeat.heartbeateligibility;
run;

data heartbeathhqbaseline;
  set hbeat.heartbeathhqbaseline;

  timepoint = 2;
run;


data heartbeathhqfinal;
  set hbeat.heartbeathhqfinal;

  timepoint = 7;
run;

data hbeatembletta;
  set hbeat.heartbeatembletta;

  if studyid = 10001 and pass = 1 then pass = 2;
  if studyid = 10599 and pass = 1 then pass = 2;

  if pass > 1;
run;

data embletta;
  merge hbeatembletta (in=a) hbeat.heartbeatembqs;
  by studyid embq_date;

  if a;

  if pass = 2 then timepoint = 2;
  else if pass = 3 then timepoint = 7;

run;

data heartbeat_baseline;
  merge hbeat.heartbeatbloods hbeat.heartbeatbp24hr embletta hbeat.heartbeatecg  hbeat.heartbeatendopat(keep=studyid timepoint en_date en_rhi en_lo_c90_120 rename=(en_date=endodate en_rhi=rhi en_lo_c90_120=framingham)) heartbeathhqbaseline (in=a) hbeat.heartbeatmeasurements  hbeat.heartbeatphq9 hbeat.heartbeatsf36;
  by studyid timepoint;

  if timepoint = 2;

  if a;
run;

data hbeat_baseline;
  merge hbeatelig (in=a) hbeat.heartbeatrandomization (in=b) heartbeat_baseline (in=c) hbeat.heartbeatmedicationscat;
  by studyid;

  if b;
run;

data heartbeat_final;
  merge hbeat.heartbeatbloods hbeat.heartbeatbp24hr embletta hbeat.heartbeatecg  hbeat.heartbeatendopat heartbeathhqfinal (in=a) hbeat.heartbeatmeasurements  hbeat.heartbeatphq9 (in=b) hbeat.heartbeatsf36;
  by studyid timepoint;

  if timepoint = 7;

  if b;
run;

data hbeat_final;
  merge heartbeat_final (in=a) hbeat.heartbeatmedicationscat hbeat.heartbeatoxycompliance hbeat.heartbeatpapcompliance hbeat.heartbeatwithdrawal;
  by studyid;

  if a;
run;

proc export data=hbeat_baseline outfile="\\rfa01\bwh-sleepepi-heartbeat\nsrr-prep\_releases\0.1.0.beta1\heartbeat-baseline-dataset-0.1.0.beta1.csv" dbms=csv replace; run;

proc export data=hbeat_final outfile="\\rfa01\bwh-sleepepi-heartbeat\nsrr-prep\_releases\0.1.0.beta1\heartbeat-final-dataset-0.1.0.beta1.csv" dbms=csv replace; run;
