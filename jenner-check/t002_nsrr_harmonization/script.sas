*******************************************************************************;
* create harmonized datasets                                                  ;
* (harmonization block from scripts/prepare-heartbeat-for-nsrr.sas)           ;
*                                                                              ;
* Maps the HeartBEAT source variables onto NSRR's harmonized `nsrr_*` naming  ;
* and value conventions: age (capped at 90), age_gt89 flag, sex, the 7-level   ;
* race string, ethnicity, BMI, systolic/diastolic blood pressure, current and  ;
* ever-smoker status, the apnea-hypopnea index, and total sleep duration.      ;
*******************************************************************************;
data hbeat_total_base_harmonized;
  set hbeat_total_base;

*demographics
*age;
*use calc_age;
  format nsrr_age 8.2;
  if calc_age gt 89 then nsrr_age = 90;
  else if calc_age le 89 then nsrr_age = calc_age;

*age_gt89;
*use calc_age;
  format nsrr_age_gt89 $100.;
  if calc_age gt 89 then nsrr_age_gt89='yes';
  else if calc_age le 89 then nsrr_age_gt89='no';

*sex;
*use male;
  format nsrr_sex $100.;
    if male = 1 then nsrr_sex='male';
  else if male = 0 then nsrr_sex='female';
  else nsrr_sex = 'not reported';

*race;
*race7 created above for hbeat baseline from race variables;
    format nsrr_race $100.;
  if race7 = 1 then nsrr_race = 'white';
    else if race7 = 2 then nsrr_race = 'american indian or alaska native';
  else if race7 = 3 then nsrr_race = 'black or african american';
  else if race7 = 4 then nsrr_race = 'asian';
  else if race7 = 5 then nsrr_race = 'native hawaiian or other pacific islander';
    else if race7 = 6 then nsrr_race = 'other';
    else if race7 = 7 then nsrr_race = 'multiple';
  else nsrr_race  = 'not reported';

*ethnicity;
*use ethnicity;
  format nsrr_ethnicity $100.;
    if ethnicity = 1 then nsrr_ethnicity = 'hispanic or latino';
    else if ethnicity = 2 then nsrr_ethnicity = 'not hispanic or latino';
  else if ethnicity = . then nsrr_ethnicity = 'not reported';

*anthropometry
*bmi;
*use bmi;
  format nsrr_bmi 10.9;
  nsrr_bmi = bmi;

*clinical data/vital signs
*bp_systolic;
*use sysmean;
  format nsrr_bp_systolic 8.2;
  nsrr_bp_systolic = sysmean;

*bp_diastolic;
*use diasmean;
  format nsrr_bp_diastolic 8.2;
  nsrr_bp_diastolic = diasmean;

*lifestyle and behavioral health
*current_smoker;
*use smokedmonth;
format nsrr_current_smoker $100.;
if smoked = 2 then nsrr_current_smoker = 'no';
else if smokedmonth = 1 then nsrr_current_smoker = 'yes';
else if smokedmonth = 2 then nsrr_current_smoker = 'no';
else if smoked = 1 then nsrr_current_smoker = 'no';
else nsrr_current_smoker = 'not reported';

*ever_smoker;
*use smoked;
format nsrr_ever_smoker $100.;
if smoked = 1 then nsrr_ever_smoker = 'yes';
else if smoked = 2 then nsrr_ever_smoker = 'no';
else nsrr_ever_smoker = 'not reported';

*polysomnography;
*nsrr_ahi_hp3u;
*use ahi_screening;
  format nsrr_ahi_hp3u 8.2;
  nsrr_ahi_hp3u = ahi_screening;

*nsrr_ttldursp_f1;
*use index_time;
  format nsrr_ttldursp_f1 8.2;
  nsrr_ttldursp_f1 = index_time;

  keep
    nsrrid
    timepoint
    nsrr_age
    nsrr_age_gt89
    nsrr_sex
    nsrr_race
    nsrr_ethnicity
    nsrr_bp_systolic
    nsrr_bp_diastolic
    nsrr_bmi
    nsrr_current_smoker
    nsrr_ever_smoker
    nsrr_ahi_hp3u
    nsrr_ttldursp_f1
    ;
run;

proc print data=hbeat_total_base_harmonized noobs;
  var nsrrid nsrr_age nsrr_sex nsrr_race nsrr_ethnicity
      nsrr_current_smoker nsrr_ever_smoker;
  title "HeartBEAT NSRR harmonized demographics";
run;
