/*Chi square analysis for travel and CRE*/


data CRE_analysis;

	set SASdata.analysis_CRE;

run;

proc freq data=CRE_analysis; tables year /norow nocol nopercent;run;


data cre_recodes;
	
	set CRE_analysis;

	length travel $8.;
	length screening_event $26.;

	/*i.travel*/
	travel= "Missing";
	if recent_travel in ("Yes") or RECENT_TRAVEL in ("YES") or RECENT_TRAVEL in ("Yes") then travel="Yes";
	if recent_travel in ("No") or RECENT_TRAVEL in ("NO") or RECENT_TRAVEL in ("No") then travel="No";
	if recent_travel in ("Unknown") or RECENT_TRAVEL in ("UNKNOWN") or RECENT_TRAVEL in ("Unknown") then travel="Unknown";

	/*ii.screening*/
	if (find (REASON_FOR_TESTING,'Colonization screening')>0) or (find (REASON_FOR_TESTING,'Screening in community')>0)
		then screening_event='Yes';
	if  (find (REASON_FOR_TESTING,'Part of clinical care')>0)
		then screening_event='No';
	if REASON_FOR_TESTING in (' ') 
		then screening_event='Mising/Unknown';

/*now binary*/

		trav_binary=.;

	if travel in ('Yes') then trav_binary=1;
	if travel in ('No') then trav_binary=0;

		screen_binary=.;
	if screening_event in ('Yes') then screen_binary=1;
	if screening_event in ('No') then screen_binary=0;

run;
/*
expected = (row total)(col total) / (grand total)

*/
proc sql;
create table obs_expected_cre as
select
	
	year "Year of detection",
	sum (case when screen_binary in (1) then 1 else 0 end) as screen_y_obs "Observed CRE detected through screening",
	((sum (case when screen_binary not in (.) then 1 else 0 end)) *80) / 1071 as screen_y_exp "Expected CRE detected through screening" format 10.0, /* 896 total constant, 56 total screening ID'd CRE*/

	sum (case when screen_binary in (0) then 1 else 0 end) as screen_n_obs "Observed CRE detected through clinical processes",
	((sum (case when screen_binary not in (.) then 1 else 0 end)) *991) / 1071 as screen_n_exp "Expected CRE detected through clinical processes" format 10.0 /* 896 total constant, 840 total clinical ID'd CRE*/


from CRE_recodes
	group by year
;

create table chisq_manual as
select
	
	((screen_y_obs -  screen_y_exp)**2) / ( screen_y_exp) as chisq_screen_y_pt1,
	((screen_n_obs -  screen_n_exp)**2) / ( screen_n_exp) as chisq_screen_n_pt2

from obs_expected_cre
;

create table chsq_manual_2 as
select 
	sum (chisq_screen_y_pt1) as test_stat_y,
	sum (chisq_screen_n_pt1) as test_stat_n

from obs_expected_cre

;
quit;

proc print data=obs_expected_cre noobs label;run;
proc print data=chisq_manual noobs label;run;



/*
Question: Is there a relationship between screening identified CRE and year?

H0: "Screening resulting in postive is NOT associated with MMWR Year"
H1: "Screening resulting in postive IS associated with MMWR Year"

*/
proc freq data=CRE_recodes; 

	tables year*screen_binary /chisq exact norow nocol nopercent nocum;
	*weight count;

run;

/*Travel for funsies (40% missing)*/

proc freq data=CRE_recodes; 

	tables year*trav_binary /chisq exact norow nocol nopercent nocum;
	*weight count;

run;



proc sql;
create table table_1a as
select

	year "Year of detection",

	sum (case when screen_binary in (1) then 1 else 0 end) as screen_y "CRE detected through screening",
	sum (case when screen_binary in (0) then 1 else 0 end) as screen_n "CRE detected through clinical process",
	sum (case when screen_binary in (.) then 1 else 0 end) as screen_m "CRE missing screening information",
	sum (case when screen_binary in (.,1,0) then 1 else 0 end) as screen_all "Total CRE",

	sum (case when screen_binary in (1,0) then 1 else 0 end) as screen_nomiss "Total CRE not missing screening information",

	calculated screen_y / calculated screen_nomiss as prop_screen_y "Proportion CRE detected through screening" format 10.2,
	calculated screen_n / calculated screen_nomiss as prop_screen_n "Proportion CRE detected through clinical process" format 10.2,
	calculated screen_m / calculated screen_nomiss as prop_screen_m "Proportion CRE missing screening information" format 10.2


from CRE_recodes
	group by year
;
/*reorder*/
create table table_1afinal as
select

	year,
	screen_nomiss,

	screen_y,
	prop_screen_y,

	screen_n,
	prop_screen_n,

	screen_m,
	prop_screen_m


from table_1a
	group by year
;
quit;
/*
expected = (row total)(col total) / (grand total)

*/

/*Output*/

title; footnote;
/*Set your output pathway here*/
ods excel file="T:\HAI\Code library\Epi curve example\analysis\CRE_screening_analysis_&sysdate..xlsx";


/*Tables*/
title justify=left height=10pt font='Helvetica' "Table 1";
ods excel options (sheet_interval = "none" frozen_headers="1" sheet_name = "CRE screen" embedded_titles='Yes');
proc print data=table_1afinal noobs label;run;

title justify=left height=10pt font='Helvetica' "Table 2";
proc print data=obs_expected_cre noobs label;run;

title justify=left height=10pt font='Helvetica' "Figure 1";
proc sgplot  data=table_1afinal noborder noautolegend;
title  height=8pt font='Helvetica' "CRE Case and Proportion by Detection Method";
	styleattrs datacontrastcolors=(darkblue lightblue);

	series x=year y=screen_y / lineattrs=(thickness=2) ;
	series x=year y=screen_n / lineattrs=(thickness=2) ;

	series x=year y=prop_screen_y /y2axis lineattrs=(thickness=2);
	series x=year y=prop_screen_n /y2axis lineattrs=(thickness=2);

		keylegend / title="Screening Method" location=outside position=bottom noborder across=1;

	yaxis label="Count CRE";
	y2axis label="Proportion screening-identified CRE";
	xaxis label="Year";

run;
title;




title;
title justify=left height=10pt font='Helvetica' "Table 3";
ods excel options (sheet_interval = "now" frozen_headers="1" sheet_name = "CRE chisq" embedded_titles='Yes');

proc freq data=CRE_recodes; 
	tables year*screen_binary /chisq norow nocol nopercent nocum;

run;

ods excel close;
