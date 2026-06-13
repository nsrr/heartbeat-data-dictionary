*******************************************************************************;
* embletta processing                                                         ;
* (from scripts/prepare-heartbeat-for-nsrr.sas)                               ;
*                                                                              ;
* Reclassifies two participants whose first home sleep study should count as   ;
* pass 2, keeps the post-screening passes, and (from the original screening    ;
* pass) computes the central-to-obstructive apnea ratio, renaming the apnea    ;
* counts to their published names and carrying the screening AHI forward.      ;
*******************************************************************************;

  data hbeatembletta;
    set heartbeatembletta;

    if studyid = 10001 and pass = 1 then pass = 2;
    if studyid = 10599 and pass = 1 then pass = 2;

    if pass > 1;
  run;

  *add dataset from pass 1 to calculate central / obstructive ratio from screening;
  data hbeatembletta_ratio;
    set heartbeatembletta;

    if pass = 1;

    cent_obs_ratio = nca / noa;
    format cent_obs_ratio 8.2 nca noa 8.;

    rename nca = n_cent_apneas
      noa = n_obs_apneas;

    ahi_screening = aphypi;

    keep studyid embq_date cent_obs_ratio nca noa ahi_screening;
  run;

  proc print data=hbeatembletta noobs;
    title "HeartBEAT embletta records, pass > 1";
  run;

  proc print data=hbeatembletta_ratio noobs;
    title "HeartBEAT central/obstructive ratio from screening (pass 1)";
  run;
