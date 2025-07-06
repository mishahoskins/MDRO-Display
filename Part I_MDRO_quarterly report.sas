/*Part I: import data and run cleaning steps*/
/*Cleaning steps mirror those of the public facing interactive dashboard creation found here:

		https://epi.dph.ncdhhs.gov/cd/figures.html

**IMPORTANT** Make sure your numbers line up! If the dashboard team has changed a code we need to reflect it here. 
			  Deen Gu deen.gu@dhhs.nc.gov or Anna Cope anna.cope@dhhs.nc.gov are good resources to verfiy if changes have been made. 

*/

/*Get C.auris and STRA (GAS)*/
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
/*Get CRE*/
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


proc contents data=CASE_COMBO_SUB order=varnum;run;



/*Keep standard variables and define timeframe*/
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
		MMWR_DATE_BASIS,
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
where calculated EVENT_DATE >= "&yr_begin"d and calculated EVENT_DATE <= "&qtr_dte"d
	and STATUS = 'Closed'
	/*and STATE in ('NC' ' ')*/
order by TYPE_DESC, YEAR, OWNING_JD;


quit;



proc sql; 
create table dates_investigation as
select

	input(case_id, best12.) as case_id_new,
	type,
	EVENT_DATE,
	MMWR_DATE_BASIS

from HAI_updated
	where type in ('CRE')
;
quit;




/*Now import NCEDSS line lists for more demographic variables*/
proc import
datafile = "&ncedssdata./All_Models_Deidentified_Cases_and_Contacts_Line_List_by_Date_for_Reporting_20250620113744.xlsx"
out=ncedss_specdate
dbms=xlsx replace;
getnames=yes;

run;
proc contents data=ncedss_specdate order=varnum;run;

proc sql;
create table scatter as
select
	
	a.case_id_new,
	a.type,

	/*crude values*/
	intnx("month", (a.EVENT_DATE), 0, "end") as report_event_date "Event Date Month" format=MONYY5.,
	intnx("month", (a.MMWR_DATE_BASIS), 0, "end") as report_MMWR "Month" format=MONYY5.,
	intnx("month", (b.Specimen_Date), 0, "end") as report_spec_dte "Specimen Month" format=MONYY5.,
	intnx("month", (b.Symptom_Onset_Date), 0, "end") as report_symp_dte "Month" format=MONYY5.,

		calculated report_event_date - calculated report_spec_dte as difference_rep_spec "Report and Specimen Date difference",

		case when calculated difference_rep_spec in (0) then 1 else 0 end as diff_date_flag "Report and Specimen Date are Same"




from dates_investigation as a left join ncedss_specdate as b on a.case_id_new = b.EVENT_ID

	order by report_event_date	
;

quit;


ods graphics/ noborder;
proc sgplot data=scatter noborder noautolegend;

		histogram difference_rep_spec / transparency=0.5 fillattrs=(color= papk);
		density difference_rep_spec / type=normal lineattrs=(color="red");
/*
histogram log_report_event_date /transparency=0.5 fillattrs=(color= vligb);
	density log_report_event_date / type=normal lineattrs=(color="blue");

histogram log_report_spec_dte / transparency=0.5 fillattrs=(color= papk);
		density log_report_spec_dte / type=normal lineattrs=(color="red");




histogram log_report_MMWR / transparency=0.5 fillattrs=(color= VLIGB);
		density log_report_MMWR / type=normal lineattrs=(color="blue");



histogram log_report_symp_dte / transparency=0.5 fillattrs=(color= VLIV);
		density log_report_symp_dte / type=normal lineattrs=(color="purple");
*/
		xaxis valueshint values=(9.5 to 10.5 by 0.2); /*display =(novalue);*/

		inset ("Blue=" = "Event Date Distribution" "Red=" = "Specimen Date Distribution" /*"Yellow=" = "Speciment Date Distribution" "Purple=" = "Symptom Onset Date Dist."*/) / position=topleft;

run;

proc freq data=scatter; tables diff_date_flag / norow nocol nocum;run;

proc ttest data=scatter;

paired report_event_date*report_spec_dte;

	where diff_date_flag in (0);

run;


proc univariate data=scatter normal;
    var difference_rep_spec;
    histogram difference_rep_spec / normal(color=blue);

    inset mean std median mode / position=ne;

		where diff_date_flag in (0);
run;

proc sgplot data=scatter noborder;

vbox report_event_date / transparency=0.5;
vbox report_spec_dte / transparency=0.5;
	yaxis display=(nolabel);
run;

/*Missing values by variable*/
proc format; 
   value $missfmt ' '='Missing' other='Not Missing'; 
   value missfmt .  ='Missing' other='Not Missing'; 
run;


proc means data=scatter maxdec=0 mean median max min;

var difference_rep_spec;
run;

proc freq data=scatter; 
/*format _character_ $missfmt.; 
table _character_ / missing missprint nocum nopercent; */
format _numeric_ missfmt.; 
tables report_event_date report_spec_dte diff_date_flag/ missing missprint nocum ; 
run; 
/*Equity vars to keep

RECENT_TRAVEL : RNT_TRV (source: risk_travel_cd)
HOSPITALIZED
HCE_HOSPITAL_NAME_0 : HCE (source: risk_health_care_exp_cd)




proc contents data=denorm.clinic_hospitalizations order=varnum;run;
proc freq data=denorm.clinic_hospitalizations; tables CODE /norow nocol nopercent;run;

*/

/*Now join with disease specific denormalized tables for certain variables for analysis. Some re-coding to reassign missing values as unknown or define them as "Missing" for graphs/tables.*/
proc sql;
create table test_import as
select distinct /*Only want one value per event_id (and all other variables too).*/

	a.*,
	/*b. are variables needed from CRE risk history for equity/risk factor q's*/
	b.HCE,
	/*c. mechanism for CRE*/
	case when c.CRE_CARB_PRODUCE_MECHANISM not in ('') then c.CRE_CARB_PRODUCE_MECHANISM 
		 else "Missing" end as mechanism,
	/*d. are variables needed from C.auris risk history for equity/risk factor q's*/
	RNT_TRV as travel,
	/*e. hospitaliztion*/
	case when e.HOSPITALIZED not in ('','Unknown') then e.HOSPITALIZED
		 else 'Unknown' end as hospitalized_new
	/*f. are variables need from GAS risk history for equity/risk factor q's*/


	/*join all tables*/
from HAI_updated as a 
	left join denorm.risk_health_care_exp_cd as b on a.case_ID = b.case_ID
	left join denorm.laboratory_dd_table_cre as c on a.case_ID = c.case_ID
	left join denorm.risk_travel_cd as d on a.case_ID = d.case_ID
	left join denorm.clinic_hospitalizations as e on a.case_ID = e.case_ID


	/*left join denorm.gas_risk as E on a.case_ID = E.case_ID*/


;

quit;


/*Check for duplicates obs should = 0*/
proc sql;
create table dupes as
select
	case_ID, 
	count(*) as id_count

from test_import
	group by case_ID
	having Count(*) >1
;
quit;




/*Output our working datasets into two. One for standard evalautions and one for risk factor/equity evaluation.*/
data SASdata.healthequitySAS;
	set work.test_import;
run;

data SASdata.recordssas;
	set work.test_import;
	where type in ('CRE');
run;


