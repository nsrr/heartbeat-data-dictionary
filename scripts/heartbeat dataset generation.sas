%include "\\rfa01\bwh-sleepepi-heartbeat\sas\heartbeat options and libnames.sas";
libname obf "\\rfa01\bwh-sleepepi-heartbeat\nsrr-prep\_ids";
%let a=%sysget(SAS_EXECFILEPATH);
%let b=%sysget(SAS_EXECFILENAME);
%let path= %sysfunc(tranwrd(&a,&b,heartbeat dataset macros.sas));
%include "&path";
%let release = 0.2.0.beta2;

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
  merge dob(in=a) hbeat.heartbeatmeasurements(drop=dob);
  by studyid;
  if a;
  calc_age = (meas_date - dob)/365.25;
  keep studyid timepoint calc_age;
run;

data hbeatelig;
  set hbeat.heartbeateligibility;
run;

data heartbeathhqbaseline;
  set hbeat.heartbeathhqbaseline;

  if bwalkhurry = 3 then bwalkhurry = .;
  timepoint = 2;
run;

data race;
	set heartbeathhqbaseline(keep=studyid race);
run;

data heartbeathhqfinal;
  merge hbeat.heartbeathhqfinal(in=a) race(in=b) frand(in=c);;
	by studyid;

	if a;

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

  rename totalmin = totalmin_emb;
  rename totalhrs = totalhrs_emb;
  rename endtime = embq_endtime;
  rename starttime = embq_starttime;

  drop folder inembletta inembqs enddttime startdttime;
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
  merge hbeatages hbeat.heartbeatbloods(drop=heartbeat_vt_lab_id heartbeat_vt_lab_id1 order albumin_assay_date crp_assay_date crp_comment d_dimer__comment d_dimer_assay_date e_selectin_assay_date e_selectin_comment hstniiuo_assay_date hstniiuo_comment il6sr_assay_date il6sr_comment il_6_assay_date il_6_comment insulin_assay_date insulin_comment lipid_panel_and_sgl_comment mrp_8_14_assay_date mrp_8_14_comment ntprobnp__assay_date ntprobnp__comment oxldl_assay_date oxldl_comment pai_1__assay_date pai_1__comment tnf_a_assay_date tnf_a_comment tnfar1_assay_date tnfar1_comment total_adiponectin_assay_date total_adiponectin_comment ucreat_comment rec_d_in_vt) hbeat.heartbeatbp24hr(rename=(totalmin = totalmin_bp starttime=bp24starttime endtime=bp24endtime)) embletta(drop=pass scorerid) hbeat.heartbeatecg(drop=scorerid) hbeat.heartbeatendopat(keep=studyid timepoint en_date en_rhi en_lo_c90_120 rename=(en_date=endodate en_rhi=rhi en_lo_c90_120=framingham)) heartbeathhqbaseline (in=a) hbeat.heartbeatmeasurements(drop=dob agedob)  hbeat.heartbeatphq9 hbeat_sf36;
  by studyid timepoint;

  if timepoint = 2;

  if a;
run;

data hbeat_baseline;
  merge hbeat.heartbeatscreening hbeatelig (in=a) hbeat.heartbeatrandomization (in=b) heartbeat_baseline (in=c) hbeat.heartbeatmedicationscat hbeat.heartbeatwithdrawal;
  by studyid;

  if b;

  if hypertro = 8 then hypertro = .;
run;

data heartbeat_final;
  merge hbeatages hbeat.heartbeatbloods(drop=heartbeat_vt_lab_id heartbeat_vt_lab_id1 order albumin_assay_date crp_assay_date crp_comment d_dimer__comment d_dimer_assay_date e_selectin_assay_date e_selectin_comment hstniiuo_assay_date hstniiuo_comment il6sr_assay_date il6sr_comment il_6_assay_date il_6_comment insulin_assay_date insulin_comment lipid_panel_and_sgl_comment mrp_8_14_assay_date mrp_8_14_comment ntprobnp__assay_date ntprobnp__comment oxldl_assay_date oxldl_comment pai_1__assay_date pai_1__comment tnf_a_assay_date tnf_a_comment tnfar1_assay_date tnfar1_comment total_adiponectin_assay_date total_adiponectin_comment ucreat_comment rec_d_in_vt) hbeat.heartbeatbp24hr(rename=(totalmin = totalmin_bp starttime=bp24starttime endtime=bp24endtime)) embletta(drop=pass scorerid) hbeat.heartbeatecg(drop=scorerid)  hbeat.heartbeatendopat(keep=studyid timepoint en_date en_rhi en_lo_c90_120 rename=(en_date=endodate en_rhi=rhi en_lo_c90_120=framingham)) heartbeathhqfinal (in=a) hbeat.heartbeatmeasurements(drop=dob agedob)  hbeat.heartbeatphq9 (in=b) hbeat_sf36;
  by studyid timepoint;

  if timepoint = 7;
  if hypertro = 8 then hypertro = .;

  if b;
run;

data hbeat_final;
  merge hbeat.heartbeatscreening(keep=studyid male) heartbeat_final (in=a) hbeat.heartbeatmedicationscat hbeat.heartbeatoxycompliance(drop=instaffid outstaffid) hbeat.heartbeatpapcompliance hbeat.heartbeatrandomization(keep=studyid random_date);
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
  where substr(NAME,1,1) = "b" and substr(NAME,1,2) not in ("bp", "bm") and NAME not in ("bothered", "bathroom", "black", "bsnore", "bscore", "bsnorefq");

  select substr(NAME,2) into :medshq_newnames_base separated by ' '
  from hbeat_base_contents
  where substr(NAME,1,1) = "b" and substr(NAME,1,2) not in ("bp", "bm") and NAME not in ("bothered", "bathroom", "black", "bsnore", "bscore", "bsnorefq");

	select NAME into :medshq_varnames_final separated by ' '
  from hbeat_final_contents
  where substr(NAME,1,1) = "f" and substr(NAME,1,2) not in ("fr") and NAME not in ("failpm", "fsnore", "fsnorefq", "feeltired", "framingham");

  select substr(NAME,2) into :medshq_newnames_final separated by ' '
  from hbeat_final_contents
  where substr(NAME,1,1) = "f" and substr(NAME,1,2) not in ("fr") and NAME not in ("failpm", "fsnore", "fsnorefq", "feeltired", "framingham");
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
	rename hhqb_date = hhq_date;
	rename bbathroom = bathroom;
  drop faceinhibitor faldosteroneblocker falphablocker fantihypertensive fbetablocker fcalciumblocker fdiabetes fdiuretic flipidlowering fnitrate fotherah fperdilator fstatin faceinhibitor_n 
		faldosteroneblocker_n falphablocker_n fantihypertensive_n fbetablocker_n fcalciumblocker_n fdiabetes_n fdiuretic_n flipidlowering_n fnitrate_n fotherah_n fperdilator_n fstatin_n;
run;

data heartbeat_renamed_final;
  set hbeat_final;

  rename %parallel_join(&sf36_varnames, &sf36_newnames, =);
  drop sf36_date sf36_sfht;

	rename %parallel_join(&medshq_varnames_final, &medshq_newnames_final, =);
	rename hhqf_date = hhq_date;
	drop baceinhibitor baldosteroneblocker balphablocker bantihypertensive bbetablocker bcalciumblocker bdiabetes bdiuretic blipidlowering bnitrate botherah bperdilator bstatin baceinhibitor_n
		baldosteroneblocker_n balphablocker_n bantihypertensive_n bbetablocker_n bcalciumblocker_n bdiabetes_n bdiuretic_n blipidlowering_n bnitrate_n botherah_n bperdilator_n bstatin_n;
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

  if 45 =< floor(calc_age) =< 54 then agecat = 6;
  else if 55 =< floor(calc_age) =< 64 then agecat = 7;
  else if 65 =< floor(calc_age) =< 74 then agecat = 8;
  else if 75 =< floor(calc_age) =< 84 then agecat = 9;

  /*recode dates to be days from index date*/
  visit_date = (visit_date-random_date);
  elig_date = (elig_date-random_date);
  enroll_date = (enroll_date-random_date);
  scrn_date = (scrn_date-random_date);
  dateofwithdrawal = (dateofwithdrawal-random_date);
  with_date = (with_date-random_date);
  bp24date = (bp24date-random_date);
  meas_date = (meas_date-random_date);
  ecg_date = (ecg_date-random_date);
  embq_date = (embq_date-random_date);
  receive_date = (receive_date-random_date);
  review_date = (review_date-random_date);
  scored_date = (scored_date-random_date);
  endodate = (endodate-random_date);
  hhq_date = (hhq_date-random_date);
  phq_date = (phq_date-random_date);
  random_date = 0;

  drop i visit staffid bp_z gh_z mh_z pf_z re_z rp_z sf_z vt_z mcs pcs agg_ment agg_phys paxis qrsaxis taxis;

run;

data hbeat_total_base;
  length obf_pptid 8.;
  merge baseline_csv zscore_b ecgaxis_b obf.obfid;
  by studyid;

	if enroll_date > 0 then enroll_date = .;
	if scrn_date > 0 then scrn_date = .;
	if bp24date < 0 then bp24date = .;

  drop ecg_date visit_date endodate hhq_date phq_date meas_date studyid namecode labelid distance exclusion01 exclusion02 exclusion03 exclusion04 exclusion05 exclusion07 exclusion08 exclusion09 exclusion10 extratests inclusion01 inclusion02 inclusion03 misswork nointerest nopartoth nopartoth_text partstatus passive toobusy transport;
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

  if 45 =< floor(calc_age) =< 54 then agecat = 6;
  else if 55 =< floor(calc_age) =< 64 then agecat = 7;
  else if 65 =< floor(calc_age) =< 74 then agecat = 8;
  else if 75 =< floor(calc_age) =< 84 then agecat = 9;

  /*recode dates to be days from index date*/
  visit_date = (visit_date-random_date);
  bp24date = (bp24date-random_date);
  meas_date = (meas_date-random_date);
  ecg_date = (ecg_date-random_date);
  embq_date = (embq_date-random_date);
  receive_date = (receive_date-random_date);
  review_date = (review_date-random_date);
  scored_date = (scored_date-random_date);
  endodate = (endodate-random_date);
  inconc_date = (inconc_date-random_date);
  outconc_date = (outconc_date-random_date);
  enddate = (enddate-random_date);
  mintherdate = (mintherdate-random_date);
  startdate = (startdate-random_date);
  hhq_date = (hhq_date-random_date);
  phq_date = (phq_date-random_date);
  random_date = 0;

	rename meas_date = final_visit_date;

  drop i visit staffid bp_z gh_z mh_z pf_z re_z rp_z sf_z vt_z mcs pcs agg_ment agg_phys paxis qrsaxis taxis;
run;

data hbeat_total_final;
  length obf_pptid 8.;
  merge final_csv(in=a) zscore_f ecgaxis_f obf.obfid;
  by studyid;

  if a;

	if abbott_hstnl__pg_ml_ > 1492 then abbott_hstnl__pg_ml_ = .;
	if hstniiuo_pg_ml > 1000 then hstniiuo_pg_ml = .;

  drop studyid namecode labelid inconc_date outconc_date phq_date hhq_date endodate visit_date ecg_date;
run;

proc sort data = hbeat_total_base;
  by obf_pptid;
run;

proc sort data = hbeat_total_final;
  by obf_pptid;
run;

proc export data=hbeat_total_base outfile="\\rfa01\bwh-sleepepi-heartbeat\nsrr-prep\_releases\&release\heartbeat-baseline-dataset-&release..csv" dbms=csv replace; run;

proc export data=hbeat_total_final outfile="\\rfa01\bwh-sleepepi-heartbeat\nsrr-prep\_releases\&release\heartbeat-final-dataset-&release..csv" dbms=csv replace; run;
