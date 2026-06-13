*******************************************************************************;
* metadata-driven variable-name collection                                    ;
* (from scripts/prepare-heartbeat-for-nsrr.sas)                               ;
*                                                                              ;
* The HeartBEAT prepare program reads the baseline dataset's column metadata   ;
* with PROC CONTENTS, then uses PROC SQL to collect the SF-36 z-score columns  ;
* (sf36_ prefix) and the baseline MedsHQ columns (a single leading "b", with   ;
* a handful of explicit exclusions) into space-delimited macro variables that  ;
* later drive the bulk rename.                                                 ;
*******************************************************************************;

  proc contents data=hbeat_baseline out=hbeat_base_contents noprint;
  run;

  proc sql noprint;
    select NAME into :sf36_varnames separated by ' '
    from hbeat_base_contents
    where substr(NAME,1,5) = "sf36_";

    select substr(NAME,6) into :sf36_newnames separated by ' '
    from hbeat_base_contents
    where substr(NAME,1,5) = "sf36_";

    select NAME into :medshq_varnames_base separated by ' '
    from hbeat_base_contents
    where substr(NAME,1,1) = "b" and substr(NAME,1,2) not in
      ("bp", "bm") and NAME not in ("bothered", "bathroom", "bsnore",
      "bscore", "bsnorefq");
  quit;

  %put NOTE: sf36_varnames = &sf36_varnames;
  %put NOTE: sf36_newnames = &sf36_newnames;
  %put NOTE: medshq_varnames_base = &medshq_varnames_base;

  data captured_names;
    length list_name $24 names $200;
    list_name = "sf36_varnames";        names = "&sf36_varnames";        output;
    list_name = "sf36_newnames";        names = "&sf36_newnames";        output;
    list_name = "medshq_varnames_base"; names = "&medshq_varnames_base"; output;
  run;

  proc print data=captured_names noobs;
    title "HeartBEAT variable-name lists collected by PROC SQL";
  run;
