%include "\\rfa01\bwh-sleepepi-heartbeat\sas\heartbeat options and libnames.sas";
%let a=%sysget(SAS_EXECFILEPATH);
%let b=%sysget(SAS_EXECFILENAME);
%let path= %sysfunc(tranwrd(&a,&b,heartbeat dataset macros.sas));
%include "&path";
%let release = beta2;

data hbeatelig;
  set hbeat.heartbeateligibility;
run;

data heartbeathhqbaseline;
  set hbeat.heartbeathhqbaseline;

  if bwalkhurry = 3 then bwalkhurry = .;
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

data hbeat_sf36;
  set hbeat.heartbeatsf36;

  array rcd(*) gh01--gh05;
  do i=1 to dim(rcd);
    if rcd(i) not in (.,1,2,3,4,5) then do;
      rcd(i) = round(rcd(i));
    end;
  end;
  drop i;

run;

data heartbeat_baseline;
  merge hbeat.heartbeatbloods hbeat.heartbeatbp24hr embletta hbeat.heartbeatecg  hbeat.heartbeatendopat(keep=studyid timepoint en_date en_rhi en_lo_c90_120 rename=(en_date=endodate en_rhi=rhi en_lo_c90_120=framingham)) heartbeathhqbaseline (in=a) hbeat.heartbeatmeasurements  hbeat.heartbeatphq9 hbeat_sf36;
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
  merge hbeat.heartbeatbloods hbeat.heartbeatbp24hr embletta hbeat.heartbeatecg  hbeat.heartbeatendopat(keep=studyid timepoint en_date en_rhi en_lo_c90_120 rename=(en_date=endodate en_rhi=rhi en_lo_c90_120=framingham)) heartbeathhqfinal (in=a) hbeat.heartbeatmeasurements  hbeat.heartbeatphq9 (in=b) hbeat_sf36;
  by studyid timepoint;

  if timepoint = 7;

  if b;
run;

data hbeat_final;
  merge heartbeat_final (in=a) hbeat.heartbeatmedicationscat hbeat.heartbeatoxycompliance hbeat.heartbeatpapcompliance hbeat.heartbeatwithdrawal;
  by studyid;

  if a;
run;

proc contents data=hbeat_baseline out=hbeat_base_contents noprint;
run;

proc sql noprint;
  select NAME into :sf36_varnames separated by ' '
  from hbeat_base_contents
  where substr(NAME,1,5) = "sf36_";

  select substr(NAME,6) into :sf36_newnames separated by ' '
  from hbeat_base_contents
  where substr(NAME,1,5) = "sf36_";
quit;

data heartbeat_renamed_base;
  set hbeat_baseline;

  rename %parallel_join(&sf36_varnames, &sf36_newnames, =);
  drop sf36_date sf36_sfht;
run;

data heartbeat_renamed_final;
  set hbeat_final;

  rename %parallel_join(&sf36_varnames, &sf36_newnames, =);
  drop sf36_date sf36_sfht;
run;

data baseline_csv;
  set heartbeat_renamed_base;

  attrib _all_ label = "";
  format _all_;

  array rcd(*) _numeric_;
  do i=1 to dim(rcd);
    if rcd(i) < 0 then do;
      if rcd(i) in (-1,-2,-8,-9,-10) then rcd(i) = .;
      else rcd(i) = .;
    end;
  end;
  drop i;

run;

data final_csv;
  set heartbeat_renamed_final;

  attrib _all_ label = "";
  format _all_;

  array rcd(*) _numeric_;
  do i=1 to dim(rcd);
    if rcd(i) < 0 then do;
      if rcd(i) in (-1,-2,-8,-9,-10) then rcd(i) = .;
      else rcd(i) = .;
    end;
  end;
  drop i;
run;

proc export data=baseline_csv outfile="\\rfa01\bwh-sleepepi-heartbeat\nsrr-prep\_releases\0.1.0.&release\heartbeat-baseline-dataset-0.1.0.&release..csv" dbms=csv replace; run;

proc export data=final_csv outfile="\\rfa01\bwh-sleepepi-heartbeat\nsrr-prep\_releases\0.1.0.&release\heartbeat-final-dataset-0.1.0.&release..csv" dbms=csv replace; run;
