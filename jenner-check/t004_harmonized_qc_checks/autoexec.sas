options obs=100;
/*
 * Stand-in for the harmonized output of prepare-heartbeat-for-nsrr.sas.
 *
 * The QC step runs PROC MEANS and PROC FREQ over hbeat_total_base_harmonized
 * (the harmonized dataset produced earlier in the program). This autoexec
 * supplies a small harmonized dataset with the same continuous and
 * categorical nsrr_* columns the checks reference, so the QC step in
 * script.sas runs unchanged.
 */
data hbeat_total_base_harmonized;
  length nsrr_age_gt89 nsrr_sex nsrr_race nsrr_ethnicity
         nsrr_current_smoker nsrr_ever_smoker $50;
  input nsrr_age nsrr_bmi nsrr_bp_systolic nsrr_bp_diastolic
        nsrr_ahi_hp3u nsrr_ttldursp_f1
        nsrr_age_gt89 $ nsrr_sex $ nsrr_race $ nsrr_ethnicity $
        nsrr_current_smoker $ nsrr_ever_smoker $;
  datalines;
52.4 27.3 128.5 82.1 12.4 410.2 no male white not_hispanic yes yes
67.1 31.8 141.2 90.4 28.7 388.0 no female black not_hispanic no no
90.0 24.9 119.0 76.5 5.1 425.6 yes male asian hispanic no yes
58.0 29.1 135.7 88.0 18.3 401.1 no female multiple not_hispanic notreported notreported
45.8 22.0 122.4 79.9 9.8 415.0 no male notreported notreported no no
61.3 28.5 130.1 84.0 15.5 405.5 no female white not_hispanic yes yes
;
run;
