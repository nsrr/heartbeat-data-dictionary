*******************************************************************************;
* checking harmonized datasets                                                ;
* (QC block from scripts/prepare-heartbeat-for-nsrr.sas)                      ;
*                                                                              ;
* The HeartBEAT prepare program screens the harmonized dataset before          ;
* release: PROC MEANS scans the continuous nsrr_* variables for extreme        ;
* values, and PROC FREQ tabulates the harmonized categorical variables.        ;
*******************************************************************************;

/* Checking for extreme values for continuous variables */

proc means data=hbeat_total_base_harmonized;
VAR   nsrr_age
    nsrr_bmi
    nsrr_bp_systolic
    nsrr_bp_diastolic
    nsrr_ahi_hp3u
    nsrr_ttldursp_f1;
run;

/* Checking categorical variables */

proc freq data=hbeat_total_base_harmonized;
table   nsrr_age_gt89
    nsrr_sex
    nsrr_race
    nsrr_ethnicity
    nsrr_current_smoker
    nsrr_ever_smoker;
run;
