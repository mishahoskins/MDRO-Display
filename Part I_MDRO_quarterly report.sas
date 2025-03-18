/*Part I: import data and run cleaning steps*/
/*Cleaning steps mirror those of the public facing interactive dashboard creation found here:

		https://epi.dph.ncdhhs.gov/cd/figures.html

**IMPORTANT** Make sure your numbers line up! If the dashboard team has changed a code we need to reflect it here. 
			  Deen Gu deen.gu@dhhs.nc.gov or Anna Cope anna.cope@dhhs.nc.gov are good resources to verfiy if changes have been made. 

*/

/* format date for footnotes (if necessary) */
data _null_; 
	today=put(date(),worddate18.); 
	call symputx('date',today); 
run;


proc sql;
create table CASE_COMBO as
select 
	s.*, a.EVENT_STATE,
	b.RPTI_SOURCE_DT_SUBMITTED

from denorm.case 

	as s left join denorm.case_PHI as a on s.case_id=a.case_id
	left join denorm.Admin_question_package_addl as b on s.case_id=b.case_id

where s.CLASSIFICATION_CLASSIFICATION in ("Confirmed", "Probable")
	and s.type in ( "CAURIS", "STRA") /*Add "STRA" for Group A strep when necessary*/
	and s.REPORT_TO_CDC = 'Yes';

quit;

proc sql;
create table CASE_COMBO_2 as
select 
	s.*, a.EVENT_STATE,
	b.RPTI_SOURCE_DT_SUBMITTED

from denorm.case 

	as s left join denorm.case_PHI as a on s.case_id=a.case_id
	left join denorm.Admin_question_package_addl as b on s.case_id=b.case_id

where s.CLASSIFICATION_CLASSIFICATION in ("Confirmed", "Probable")
	and s.type in ("CRE") 
	and s.REPORT_TO_CDC not in ('');

quit;


data CASE_COMBO_SUB;
set CASE_COMBO CASE_COMBO_2;
run;




proc sql;
create table HAI_updated as
select 
		OWNING_JD,
		TYPE, 
		TYPE_DESC, 
		CLASSIFICATION_CLASSIFICATION, 
		CASE_ID,
		REPORT_TO_CDC,

		input(MMWR_YEAR, 4.) as MMWR_YEAR, 
		MMWR_DATE_BASIS, 

		count(distinct CASE_ID) as Case_Ct label = 'Counts', 
		'Healthcare Acquired Infection' as Disease_Group,
		AGE, 
		GENDER, 
		HISPANIC, 
		RACE1, 
		RACE2, 
		RACE3, 
		RACE4, 
		RACE5, 
		RACE6,
/*This piece should match exactly or almost exactly to the dashboard code found here: https://github.com/NC-DPH/Communicable-Disease-Dashboards/blob/main/NCD3v2%20In%20Progress.sas
		some of the variable names may be different but the counts need to align*/

	case 
	    when MMWR_DATE_BASIS ne . then MMWR_DATE_BASIS
		when SYMPTOM_ONSET_DATE ne . then SYMPTOM_ONSET_DATE
	    when (SYMPTOM_ONSET_DATE = . ) and  RPTI_SOURCE_DT_SUBMITTED  ne . then RPTI_SOURCE_DT_SUBMITTED
	    else datepart(CREATE_DT)
	    end as EVENT_DATE format=DATE9., 

	year(calculated EVENT_DATE) as Year, 
	month(calculated EVENT_DATE) as Month, 
	QTR(calculated EVENT_DATE) as Quarter,
/*Additional variables for MDRO report*/
	SYMPTOM_ONSET_DATE, 
	DISEASE_ONSET_QUALIFIER, 
	DATE_FOR_REPORTING,
	RPTI_SOURCE_DT_SUBMITTED, 
	CREATE_DT, 
	STATUS

from CASE_COMBO_sub
where calculated EVENT_DATE >= '01JAN2023'd and calculated EVENT_DATE <= "&qtr_dte"d
	and STATUS = 'Closed'
	/*and STATE in ('NC' ' ')*/
order by TYPE_DESC, YEAR, OWNING_JD;


quit;


/*Combine all HAI data sets*/
data HAI3 ;
length Reporting_Date_Type $25;
set HAI_updated;
Disease_Group='Healthcare Acquired Infection';
run;

/*Using a quick age-group recode to confine to the year we want to evaluate: not sure why I put this here but yea... here it is.*/
data work.records; 
	set HAI3;


	format age_group $12.;
	age_group = " ";

	if age <5 then age_group ="0-04";
	if 5<= age <18 then age_group ="05-17";
	if 18<= age <25 then age_group ="18-24";
	if 25<= age <50 then age_group ="25-49";
	if 50<= age <65 then age_group ="50-64";
	if 65<= age then age_group ="65+";

	

	where year = &year_dte.; *<--- set the year here to confine data roughtly to year(s) we're interested in. If looking over many years comment out;
/*
	if type in ('CAURIS') and REPORT_TO_CDC not in ('Yes') then delete;
	if type in ('CRE') and REPORT_TO_CDC in ('') then delete;									<---- defined this earlier 1/31/2025
	if type in ('STRA') and REPORT_TO_CDC not in ('Yes') then delete;
*/
run;



/*Now import NCEDSS line lists for more demographic variables: these are additional datasets from NCEDSS that you'll need to pull within the defined dates and save/update in the prior macro step*/
proc import
datafile = "&ncedssdata./&CREfile..xlsx"
out=test_import
dbms=xlsx replace;
getnames=yes;

run;
/*Import risk factor quesstions from NCEDSS*/
proc import
datafile = "&ncedssdata./&caurisfile..xlsx"
out=caurisRH_import
dbms=xlsx replace;
getnames=yes;

run;
/*Rename event ID variable for CAURIS*/
data caurisRH_import2;
set caurisRH_import (rename=(CaseID=case_ID));

run;

/*Import risk factor questions/additional data from NCEDSS for GAS(STRA)*/
proc import
datafile = "&ncedssdata./&GASfile..xlsx"
out=GASRH_import
dbms=xlsx replace;
getnames=yes;

run;

proc print data=caurisRH_import2 noobs;run;





/*Sort and merge with "records" to create an expanded variable pool*/
proc sort data=test_import; by case_ID;run;
proc sort data=work.records; by case_ID;run;


data test_merge;
merge work.records (in=a) test_import work.caurisRH_import2;

	by case_ID;

	if a;

run;

/*Deduplicate because we'll have many tests for one person*/
proc sort data=test_merge out=test_merge_dedupe nodupkey;

	by type case_ID;

run; 

/*Output our working datasets*/
data SASdata.healthequitySAS;
	set work.test_merge_dedupe;
run;

data SASdata.recordsSAS;
	set work.records;
run;

/*You can incorporate different analyses here.


Additional analysis: CRE screening created 11/18/2024.



*/
/*NCEDSS line lists 2019-2023 CRE*/
proc import
datafile = "&ncedssdata./CRE_2019_2023.xlsx"
out=CRE_19_23
dbms=xlsx replace;
getnames=yes;

run;

proc sort data=CRE_19_23; by case_ID;run;
proc sort data=work.HAI3; by case_ID;run;

data CRE_merge;
merge work.HAI3 (in=a) CRE_19_23 ;

	by case_ID;

	if a;

run;
/*Deduplicate because we'll have many tests for one person*/
proc sort data=CRE_merge out=CRE_merge_dedupe nodupkey;

	by type case_ID;

	where type in ('CRE') and 2019 LE year LE 2023;
run; 
/*Output dataset for analysis*/
data SASdata.analysis_CRE;
	set work.CRE_merge_dedupe;
run;
