*******************************************************************************;
/* prepare-heartbeat-for-nsrr.sas */
*******************************************************************************;

*******************************************************************************;
* set options and libnames ;
*******************************************************************************;
  %include "\\rfawin\bwh-sleepepi-heartbeat\sas\heartbeat options and libnames.sas";
  libname obf "\\rfawin\bwh-sleepepi-heartbeat\nsrr-prep\_ids";
  %let a=%sysget(SAS_EXECFILEPATH);
  %let b=%sysget(SAS_EXECFILENAME);
  %let path= %sysfunc(tranwrd(&a,&b,heartbeat-macros.sas));
  %include "&path";
  %let release = 0.5.0;

*******************************************************************************;
* process data ;
*******************************************************************************;
  data dob;
    set hbeat.heartbeatmeasurements;

    keep studyid dob;
  run;

  data frand;
    set hbeat.heartbeatrandomization(keep=studyid treatmentarm);
  run;

  proc sort data=dob nodupkey;
    by studyid;
  run;

  data hbeatages;
    merge dob (in=a) hbeat.heartbeatmeasurements (drop=dob);
    by studyid;
    if a;
    calc_age = (meas_date - dob) / 365.25;
    keep studyid timepoint calc_age;
  run;

  data hbeatelig;
    set hbeat.heartbeateligibility;

    drop eligcheck eligfinal;
  run;

/*
proc freq data = hbeat.heartbeathhqbaseline;
table race white black hawaii asian amerindian otherrace otherrace_text race_white
      race_black;
run;

proc print data = hbeat.heartbeathhqbaseline;
var race white black hawaii asian amerindian otherrace otherrace_text race_white
      race_black;
run;
*/

  data heartbeathhqbaseline;
    set hbeat.heartbeathhqbaseline;

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

  /*
  * Old race 3 category variable code not using anymore after harmonization
    *create new `race3` categorical variable to match BioLINCC method;
    *1 = white, 2 = black, 3 = other remove this?;
    if race = 5 then race3 = 1;
    else if race = 4 then race3 = 2;
    else if race not in (7,.) then race3 = 3
  */

    *set timepoint variable;
    timepoint = 2;

    drop white black hawaii asian amerindian otherrace otherrace_text race_white
      race_black race_count race hhqb_date;
  run;

  /*
  proc freq data=  heartbeathhqbaseline;
  table race race7 white race_count;
  run;
  */

  data race;
    set heartbeathhqbaseline(keep=studyid race7);
  run;

  data heartbeathhqfinal;
    merge hbeat.heartbeathhqfinal(in=a) race(in=b) frand(in=c);;
    by studyid;

    if a;

    timepoint = 7;

    drop hhqf_date;
  run;

  data hbeatembletta;
    set hbeat.heartbeatembletta;

    if studyid = 10001 and pass = 1 then pass = 2;
    if studyid = 10599 and pass = 1 then pass = 2;

    if pass > 1;
  run;

  *add dataset from pass 1 to calculate central / obstructive ratio from screening;
  data hbeatembletta_ratio;
    set hbeat.heartbeatembletta;

    if pass = 1;

    cent_obs_ratio = nca / noa;
    format cent_obs_ratio 8.2 nca noa 8.;

    rename nca = n_cent_apneas
      noa = n_obs_apneas;
    
    ahi_screening = aphypi;

    keep studyid embq_date cent_obs_ratio nca noa ahi_screening;
  run;

  data embletta;
    merge hbeatembletta (in=a) hbeat.heartbeatembqs hbeatembletta_ratio;
    by studyid embq_date;

    if a;

    if pass = 2 then timepoint = 2;
    else if pass = 3 then timepoint = 7;

    rename totalmin = totalmin_emb;
    rename totalhrs = totalhrs_emb;
    rename endtime = embq_endtime;
    rename starttime = embq_starttime;

    drop folder inembletta inembqs enddttime startdttime ahi1 ahi2
  napneaa /*incorrectly labelled. should be other hypopneas only (originally mixed apneas)*/
    nmia /*incorrectly labelled. should be other hypopneas only (originally mixed apneas)*/
    noaa /*obstructive apneas were not corretly scored. should be dropped*/
    des50n /*unreliable oxygen saturation measures*/
    des50nc /*unreliable oxygen saturation measures*/
    des50s /*unreliable oxygen saturation measures*/
    des50sc /*unreliable oxygen saturation measures*/
    des50u /*unreliable oxygen saturation measures*/
    des50uc /*unreliable oxygen saturation measures*/
    des60n /*unreliable oxygen saturation measures*/
    des60nc /*unreliable oxygen saturation measures*/
    des60s /*unreliable oxygen saturation measures*/
    des60sc /*unreliable oxygen saturation measures*/
    des60u /*unreliable oxygen saturation measures*/
    des60uc /*unreliable oxygen saturation measures*/
    des70n /*unreliable oxygen saturation measures*/
    des70nc /*unreliable oxygen saturation measures*/
      des70s /*unreliable oxygen saturation measures*/
    des70sc /*unreliable oxygen saturation measures*/
    des70u /*unreliable oxygen saturation measures*/
    des70uc /*unreliable oxygen saturation measures*/
    des80n /*unreliable oxygen saturation measures*/
    des80nc /*unreliable oxygen saturation measures*/
    des80s /*unreliable oxygen saturation measures*/
    des80sc /*unreliable oxygen saturation measures*/
    des80u /*unreliable oxygen saturation measures*/
    des80uc /*unreliable oxygen saturation measures*/
    deslt50n /*unreliable oxygen saturation measures*/
    deslt50s /*unreliable oxygen saturation measures*/
    deslt50u /*unreliable oxygen saturation measures*/
    ndesat60 /*unreliable oxygen saturation measures*/
    ndesat60h /*unreliable oxygen saturation measures*/
    ndesat70 /*unreliable oxygen saturation measures*/
    ndesat70h /*unreliable oxygen saturation measures*/
    ndesat80 /*unreliable oxygen saturation measures*/
    ndesat80h /*unreliable oxygen saturation measures*/
    apnea50s /*unreliable oxygen saturation measures*/
    apnea60s /*unreliable oxygen saturation measures*/
    apnea70s /*unreliable oxygen saturation measures*/
    apnea80s /*unreliable oxygen saturation measures*/
    apnealt50 /*unreliable oxygen saturation measures*/
    ca50s /*unreliable oxygen saturation measures*/
    ca60s /*unreliable oxygen saturation measures*/
    ca70s /*unreliable oxygen saturation measures*/
    ca80s /*unreliable oxygen saturation measures*/
    calt50 /*unreliable oxygen saturation measures*/
    event50s /*unreliable oxygen saturation measures*/
    event60s /*unreliable oxygen saturation measures*/
    event70s /*unreliable oxygen saturation measures*/
    event80s /*unreliable oxygen saturation measures*/
    eventlt50 /*unreliable oxygen saturation measures*/
    hyp50s /*unreliable oxygen saturation measures*/
    hyp60s /*unreliable oxygen saturation measures*/
    hyp70s /*unreliable oxygen saturation measures*/
    hyp80s /*unreliable oxygen saturation measures*/
    hyplt50 /*unreliable oxygen saturation measures*/
    ma50s /*unreliable oxygen saturation measures*/
    ma60s /*unreliable oxygen saturation measures*/
    ma70s /*unreliable oxygen saturation measures*/
    ma80s /*unreliable oxygen saturation measures*/
    malt50 /*unreliable oxygen saturation measures*/
    napnea /*incorrectly labelled. should be other hypopneas only (originally mixed apneas)*/
    napnean /*incorrectly labelled. should be other hypopneas only (originally mixed apneas)*/
    napneas /*incorrectly labelled. should be other hypopneas only (originally mixed apneas)*/
    noa /*obstructive apneas were not corretly scored. should be dropped*/
    noan /*obstructive apneas were not corretly scored. should be dropped*/
    noas /*obstructive apneas were not corretly scored. should be dropped*/
    oa50s /*unreliable oxygen saturation measures*/
    oa60s /*unreliable oxygen saturation measures*/
    oa70s /*unreliable oxygen saturation measures*/
    oa80s /*unreliable oxygen saturation measures*/
    poa /*obstructive apneas were not corretly scored. should be dropped*/
    durapnea /*incorrectly labelled. should be other hypopneas only (originally mixed apneas)*/
    duroa /*obstructive apneas were not corretly scored. should be dropped*/
    maxapnea /*incorrectly labelled. should be other hypopneas only (originally mixed apneas)*/
    papnea /*incorrectly labelled. should be other hypopneas only (originally mixed apneas)*/
    nhypa /* hypopneas scoring based on pass 2/3 too confusing to share with the users */
    apnea90s /* apneas scoring based on pass 2/3 too confusing to share with the users */
    cent_obs_ratio /* obstructive apneas were not corretly scored. should be dropped */
    hyp90s /* hypopneas scoring based on pass 2/3 too confusing to share with the users */
    ma90s /*incorrectly labelled. should be other hypopneas only (originally mixed apneas)*/
    nhyp /* hypopneas scoring based on pass 2/3 too confusing to share with the users */
    nhypn /* hypopneas scoring based on pass 2/3 too confusing to share with the users */
    nhyps /* hypopneas scoring based on pass 2/3 too confusing to share with the users */
    nmi /* hypopneas scoring based on pass 2/3 too confusing to share with the users */
    nmin /* hypopneas scoring based on pass 2/3 too confusing to share with the users */
    nmis /* hypopneas scoring based on pass 2/3 too confusing to share with the users */
    oa90s /*obstructive apneas were not corretly scored. should be dropped*/
    oalt50 /*obstructive apneas were not corretly scored. should be dropped*/
    phyp /* hypopneas scoring based on pass 2/3 too confusing to share with the users */
    pmi /* hypopneas scoring based on pass 2/3 too confusing to share with the users */
    durhyp /* hypopneas scoring based on pass 2/3 too confusing to share with the users */
    durmi /* hypopneas scoring based on pass 2/3 too confusing to share with the users */
    maxhyp /* hypopneas scoring based on pass 2/3 too confusing to share with the users */
    maxmi /* hypopneas scoring based on pass 2/3 too confusing to share with the users */
    maxoa;  /*obstructive apneas were not corretly scored. should be dropped*/
    
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
    merge
      hbeatages

      hbeat.heartbeatbloods (drop=heartbeat_vt_lab_id
        heartbeat_vt_lab_id1 order albumin_assay_date crp_assay_date
        crp_comment d_dimer__comment d_dimer_assay_date e_selectin_assay_date
        e_selectin_comment hstniiuo_assay_date hstniiuo_comment
        il6sr_assay_date il6sr_comment il_6_assay_date il_6_comment
        insulin_assay_date insulin_comment lipid_panel_and_sgl_comment
        mrp_8_14_assay_date mrp_8_14_comment ntprobnp__assay_date
        ntprobnp__comment oxldl_assay_date oxldl_comment pai_1__assay_date
        pai_1__comment tnf_a_assay_date tnf_a_comment tnfar1_assay_date
        tnfar1_comment total_adiponectin_assay_date total_adiponectin_comment
        ucreat_comment rec_d_in_vt)

      hbeat.heartbeatbp24hr (rename=(totalmin = totalmin_bp
        starttime=bp24starttime endtime=bp24endtime))

      embletta (drop=pass scorerid)

      hbeat.heartbeatecg (drop=scorerid)

      hbeat.heartbeatendopat(keep=studyid timepoint en_date en_rhi en_lo_c90_120
        rename=(en_date=endodate en_rhi=rhi en_lo_c90_120=framingham))

      heartbeathhqbaseline (in=a)

      hbeat.heartbeatmeasurements (drop=dob agedob)

      hbeat.heartbeatphq9

      hbeat_sf36;
    by studyid timepoint;

    if timepoint = 2;

    if a;
  run;

  data hbeat_baseline;
    merge
      hbeat.heartbeatscreening (drop=calc_berlin calc_bmi calc_ess htcm htft
        htin wtkg wtlb)
      hbeatelig (in=a)
      hbeat.heartbeatrandomization (in=b)
      heartbeat_baseline (in=c)
      hbeat.heartbeatmedicationscat
      hbeat.heartbeatwithdrawal;
    by studyid;

    if b;

    if hypertro = 8 then hypertro = .;
  run;

  data heartbeat_final;
    merge
      hbeatages

      hbeat.heartbeatbloods(drop=heartbeat_vt_lab_id heartbeat_vt_lab_id1 order
        albumin_assay_date crp_assay_date crp_comment d_dimer__comment
        d_dimer_assay_date e_selectin_assay_date e_selectin_comment
        hstniiuo_assay_date hstniiuo_comment il6sr_assay_date il6sr_comment
        il_6_assay_date il_6_comment insulin_assay_date insulin_comment
        lipid_panel_and_sgl_comment mrp_8_14_assay_date mrp_8_14_comment
        ntprobnp__assay_date ntprobnp__comment oxldl_assay_date oxldl_comment
        pai_1__assay_date pai_1__comment tnf_a_assay_date tnf_a_comment
        tnfar1_assay_date tnfar1_comment total_adiponectin_assay_date
        total_adiponectin_comment ucreat_comment rec_d_in_vt)

      hbeat.heartbeatbp24hr (rename=(totalmin = totalmin_bp
        starttime=bp24starttime endtime=bp24endtime))

      embletta (drop=pass scorerid)

      hbeat.heartbeatecg(drop=scorerid)

      hbeat.heartbeatendopat (keep=studyid timepoint en_date en_rhi
        en_lo_c90_120 rename=(en_date=endodate en_rhi=rhi
        en_lo_c90_120=framingham))

      heartbeathhqfinal (in=a)

      hbeat.heartbeatmeasurements (drop=dob agedob)

      hbeat.heartbeatphq9 (in=b)

      hbeat_sf36;
    by studyid timepoint;

    if timepoint = 7;
    if hypertro = 8 then hypertro = .;

    if b;
  run;

  data hbeat_final;
    merge
      hbeat.heartbeatscreening (keep=studyid male)
      heartbeat_final (in=a)
      hbeat.heartbeatmedicationscat
      hbeat.heartbeatoxycompliance (drop=instaffid outstaffid)
      hbeat.heartbeatpapcompliance
      hbeat.heartbeatrandomization (keep=studyid random_date);
    by studyid;

    if a;
  run;

  proc contents data=hbeat_baseline out=hbeat_base_contents noprint;
  run;

  proc contents data=hbeat_final out=hbeat_final_contents noprint;
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

    select substr(NAME,2) into :medshq_newnames_base separated by ' '
    from hbeat_base_contents
    where substr(NAME,1,1) = "b" and substr(NAME,1,2) not in
      ("bp", "bm") and NAME not in ("bothered", "bathroom", "bsnore",
      "bscore", "bsnorefq");

    select NAME into :medshq_varnames_final separated by ' '
    from hbeat_final_contents
    where substr(NAME,1,1) = "f" and substr(NAME,1,2) not in ("fr")
      and NAME not in ("failpm", "fsnore", "fsnorefq", "feeltired",
      "framingham");

    select substr(NAME,2) into :medshq_newnames_final separated by ' '
    from hbeat_final_contents
    where substr(NAME,1,1) = "f" and substr(NAME,1,2) not in ("fr")
      and NAME not in ("failpm", "fsnore", "fsnorefq", "feeltired",
      "framingham");
  quit;

  data heartbeat_renamed_base;
    set hbeat_baseline;

    rename %parallel_join(&sf36_varnames, &sf36_newnames, =);
    drop sf36_date sf36_sfht;

    rename %parallel_join(&medshq_varnames_base, &medshq_newnames_base, =);
    rename bperdilator = perdilator;
    rename bperdilator_n = perdilator_n;
    rename bmovelegs = movelegs;
    rename bmoverelieve = moverelieve;
    rename bpainbegin = painbegin;
    rename bpaincalves = paincalves;
    rename bpaindisappear = paindisappear;
    rename bpainjoints = painjoints;
    rename bpainwalk = painwalk;
    rename bpresshurry = presshurry;
    rename bpressordinary = pressordinary;
    rename bbathroom = bathroom;
    drop faceinhibitor faldosteroneblocker falphablocker fantihypertensive
      fbetablocker fcalciumblocker fdiabetes fdiuretic flipidlowering fnitrate
      fotherah fperdilator fstatin faceinhibitor_n faldosteroneblocker_n
      falphablocker_n fantihypertensive_n fbetablocker_n fcalciumblocker_n
      fdiabetes_n fdiuretic_n flipidlowering_n fnitrate_n fotherah_n
      fperdilator_n fstatin_n;
  run;

  data heartbeat_renamed_final;
    set hbeat_final;

    rename %parallel_join(&sf36_varnames, &sf36_newnames, =);
    drop sf36_date sf36_sfht;

    rename %parallel_join(&medshq_varnames_final, &medshq_newnames_final, =);
    drop baceinhibitor baldosteroneblocker balphablocker bantihypertensive
      bbetablocker bcalciumblocker bdiabetes bdiuretic blipidlowering
      bnitrate botherah bperdilator bstatin baceinhibitor_n baldosteroneblocker_n
      balphablocker_n bantihypertensive_n bbetablocker_n bcalciumblocker_n
      bdiabetes_n bdiuretic_n blipidlowering_n bnitrate_n botherah_n
      bperdilator_n bstatin_n;
  run;

  data ecgaxis_b;
    set heartbeat_renamed_base;

    keep studyid paxis qrsaxis taxis;
  run;

  data ecgaxis_f;
    set heartbeat_renamed_final;

    keep studyid paxis qrsaxis taxis;
  run;

  data zscore_b;
    set heartbeat_renamed_base;

    keep studyid bp_z gh_z mh_z pf_z re_z rp_z sf_z vt_z mcs pcs agg_ment agg_phys;
  run;

  data zscore_f;
    set heartbeat_renamed_final;

    keep studyid bp_z gh_z mh_z pf_z re_z rp_z sf_z vt_z mcs pcs agg_ment agg_phys;
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

    if 45 =< floor(calc_age) =< 54 then agecat = 1;
    else if 55 =< floor(calc_age) =< 64 then agecat = 2;
    else if 65 =< floor(calc_age) then agecat = 3;

    /*recode dates to be days from index date*/
    dateofwithdrawal = (dateofwithdrawal - random_date);
    bp24date = (bp24date - random_date);
    embq_date = (embq_date - random_date);

    drop i visit staffid bp_z gh_z mh_z pf_z re_z rp_z sf_z vt_z mcs pcs agg_ment
      agg_phys paxis  qrsaxis taxis age rctsourceoth_text withother_text;
  run;

  data hbeat_total_base;
    length nsrrid 8.;
    merge
      baseline_csv
      zscore_b
      ecgaxis_b
      obf.obfid_clusterid (rename=(obf_pptid=nsrrid))
      frand;
    by studyid;

    attrib _all_ label = "";
    format _all_;

    if bp24date < 0 then bp24date = .;

    drop random_date with_date elig_date enroll_date scrn_date receive_date
      review_date scored_date ecg_date visit_date endodate phq_date meas_date
      studyid namecode labelid distance exclusion01 exclusion02 exclusion03
      exclusion04 exclusion05 exclusion07 exclusion08 exclusion09 exclusion10
      extratests inclusion01 inclusion02 inclusion03 misswork nointerest
      nopartoth nopartoth_text partstatus passive toobusy transport siteid
      deslt50nc deslt50sc deslt50uc ndesat5c ndesatc5h ndesatgt20c ndesath
      nevent neventa neventn nevents time_move time_supine time_upright 
      totalhrs_emb totalmin_emb n_cent_apneas n_obs_apneas 
      mean_sat;
  run;

  data followup_csv;
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

    if 45 =< floor(calc_age) =< 54 then agecat = 1;
    else if 55 =< floor(calc_age) =< 64 then agecat = 2;
    else if 65 =< floor(calc_age) then agecat = 3;

    /*recode dates to be days from index date*/
    bp24date = (bp24date - random_date);
    meas_date = (meas_date - random_date);
    embq_date = (embq_date - random_date);

    rename meas_date = followup_visit_date;

    drop i visit staffid bp_z gh_z mh_z pf_z re_z rp_z sf_z vt_z mcs pcs agg_ment
      agg_phys paxis qrsaxis taxis cent_obs_ratio n_cent_apneas n_obs_apneas
      site;
  run;

  data hbeat_total_followup;
    length nsrrid 8.;
    merge
      followup_csv (in=a)
      zscore_f
      ecgaxis_f
      obf.obfid_clusterid (rename=(obf_pptid=nsrrid))
      frand;
    by studyid;

    if a;

    attrib _all_ label = "";
    format _all_;

    if abbott_hstnl__pg_ml_ > 1492 then abbott_hstnl__pg_ml_ = .;
    if hstniiuo_pg_ml > 1000 then hstniiuo_pg_ml = .;

    drop studyid namecode labelid inconc_date outconc_date phq_date endodate
      visit_date ecg_date receive_date review_date scored_date enddate
      mintherdate startdate random_date siteid
      deslt50nc deslt50sc deslt50uc ndesat5c ndesatc5h ndesatgt20c ndesath
      nevent neventa neventn nevents time_move time_supine time_upright 
      totalhrs_emb totalmin_emb n_cent_apneas n_obs_apneas 
      mean_sat;   
  run;

*******************************************************************************;
* create harmonized datasets ;
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
  *race3: 1-->"white" 2-->"black or african american" 3-->"other" others --> "not reported";
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

*******************************************************************************;
* checking harmonized datasets ;
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

*******************************************************************************;
* make all variable names lowercase ;
*******************************************************************************;
  options mprint;
  %macro lowcase(dsn);
       %let dsid=%sysfunc(open(&dsn));
       %let num=%sysfunc(attrn(&dsid,nvars));
       %put &num;
       data &dsn;
             set &dsn(rename=(
          %do i = 1 %to &num;
          %let var&i=%sysfunc(varname(&dsid,&i));    /*function of varname returns the name of a SAS data set variable*/
          &&var&i=%sysfunc(lowcase(&&var&i))         /*rename all variables*/
          %end;));
          %let close=%sysfunc(close(&dsid));
    run;
  %mend lowcase;

  %lowcase(hbeat_total_base);
  %lowcase(hbeat_total_followup);
  %lowcase(hbeat_total_base_harmonized);




  proc sort data=hbeat_total_base;
    by nsrrid;
  run;

  proc sort data=hbeat_total_followup;
    by nsrrid;
  run;

*******************************************************************************;
* create csv exports for nsrr ;
*******************************************************************************;
  proc export data=hbeat_total_base
    outfile="\\rfawin\bwh-sleepepi-heartbeat\nsrr-prep\_releases\&release\heartbeat-baseline-dataset-&release..csv"
    dbms=csv
    replace;
  run;

  proc export data=hbeat_total_followup
    outfile="\\rfawin\bwh-sleepepi-heartbeat\nsrr-prep\_releases\&release\heartbeat-followup-dataset-&release..csv"
    dbms=csv
    replace;
  run;

    proc export data=hbeat_total_base_harmonized
    outfile="\\rfawin\bwh-sleepepi-heartbeat\nsrr-prep\_releases\&release\heartbeat-baseline-harmonized-dataset-&release..csv"
    dbms=csv
    replace;
  run;
