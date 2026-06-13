*******************************************************************************;
* race7 derivation from scripts/prepare-heartbeat-for-nsrr.sas                 ;
*                                                                              ;
* Builds the 7-category `race7` variable from the five race indicator flags,   ;
* exactly as the HeartBEAT prepare program does: zero out `otherrace` when      ;
* ethnicity is Hispanic, count how many race flags are set, then assign a       ;
* single race when the count is 1, "other" when only otherrace is set, and      ;
* "multiple" when more than one flag is set.                                    ;
*******************************************************************************;

  data heartbeathhqbaseline;
    set heartbeathhqbaseline;

    if bwalkhurry = 3 then bwalkhurry = .;

   *making new race with 7 categories. There is a race variable with 7 categories, but did not take into account ethncity, also unclear which race corresponded to which number;
    if ethnicity = 1 and otherrace = 1 then otherrace = 0;
    race_count = 0;
    array elig_race(5) white black hawaii asian amerindian;
    do i = 1 to 5;
      if elig_race(i) in (0,1) then race_count = race_count + elig_race(i);
    end;
    drop i;

    if white = 1 and race_count = 1 then race7 = 1; *White;
  if amerindian = 1 and race_count = 1 then race7 = 2; *American indian or Alaskan native;
    if black = 1 and race_count = 1 then race7 = 3; *Black or african american;
    if asian = 1 and race_count = 1 then race7 = 4; *Asian;
  if hawaii = 1 and race_count = 1 then race7 =5; *native hawaiian or other pacific islander;
    if otherrace = 1 and race_count = 0 then race7 = 6; *Other;
  if race_count > 1 then race7 = 7;  *Multiple;
    label race7 = "Race";

    *set timepoint variable;
    timepoint = 2;
  run;

  proc print data=heartbeathhqbaseline noobs;
    var studyid race_count race7 bwalkhurry;
    title "HeartBEAT race7 derivation";
  run;

  proc freq data=heartbeathhqbaseline;
    tables race7;
  run;
