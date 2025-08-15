/*Part I: import data and run cleaning steps*/
/*Cleaning steps mirror those of the public facing interactive dashboard creation found here:

		https://epi.dph.ncdhhs.gov/cd/figures.html

**IMPORTANT** Make sure your numbers line up! If the dashboard team has changed a code we need to reflect it here. 
			  Deen Gu deen.gu@dhhs.nc.gov or Linda Yelton are good resources to verfiy if changes have been made. 

*/

/*Get C.auris and STRA (GAS)*/
proc sql;
create table CASE_COMBO as
select 

	s.*, /*a.State*/
	a.EVENT_STATE, 
	b.RPTI_SOURCE_DT_SUBMITTED

from DENORM.CASE as s left join Denorm.CASE_PHI as a on s.case_id=a.case_id
		left join Denorm.Admin_question_package_addl as b on s.case_id=b.case_id

	where s.CLASSIFICATION_CLASSIFICATION in ("Confirmed", "Probable")
			and s.type in ("CAURIS", "STRA", "SAUR", "TSS", "TSSS")
			and s.REPORT_TO_CDC = 'Yes'
;

quit;

/*Get CRE*/
proc sql;
create table CASE_COMBO_2 as
select 

	s.*, 
	a.EVENT_STATE, 
	b.RPTI_SOURCE_DT_SUBMITTED

from DENORM.CASE as s left join Denorm.CASE_PHI as a on s.case_id=a.case_id
		left join Denorm.Admin_question_package_addl as b on s.case_id=b.case_id

	where s.CLASSIFICATION_CLASSIFICATION in ("Confirmed", "Probable")
			and (s.type = "CRE" or s.type = "CPO");	*CRE became CPO event in May 2025;
/*Removed the REPORT_TO_CDC=”Yes” filter for Carbapenem-resistant Enterobacteriaceae*/

quit;

data CASE_COMBO_SUB;
set CASE_COMBO CASE_COMBO_2;
run;

/*TEST*/


proc sql;
create table HAI_updated as
select 
	OWNING_JD, 
	TYPE, 
	TYPE_DESC, 
	CLASSIFICATION_CLASSIFICATION, 
	CASE_ID,
	input(MMWR_YEAR, 4.) as MMWR_YEAR, MMWR_DATE_BASIS, 
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
	case 
	    when MMWR_DATE_BASIS ne . then MMWR_DATE_BASIS
		when SYMPTOM_ONSET_DATE ne . then SYMPTOM_ONSET_DATE
	    when (SYMPTOM_ONSET_DATE = . ) and RPTI_SOURCE_DT_SUBMITTED  ne . then RPTI_SOURCE_DT_SUBMITTED
	    else datepart(CREATE_DT)
	    end as EVENT_DATE format=DATE9., 
	year(calculated EVENT_DATE) as Year, month(calculated EVENT_DATE) as Month, QTR(calculated EVENT_DATE) as Quarter,
	SYMPTOM_ONSET_DATE, 
	DISEASE_ONSET_QUALIFIER, 
	RPTI_SOURCE_DT_SUBMITTED, 
	CREATE_DT, 
	STATUS, 
	EVENT_STATE

from CASE_COMBO_SUB
	where calculated EVENT_DATE >= '01JAN2015'd and calculated EVENT_DATE <= "&qtr_dte"d
		and STATUS = 'Closed'
		and /*state*/EVENT_STATE in ('NC' ' ')
			order by TYPE_DESC, YEAR, OWNING_JD;
quit;




/*Now join with disease specific denormalized tables for certain variables for analysis. Some re-coding to reassign missing values as unknown or define them as "Missing" for graphs/tables.*/
proc sql;
create table test_import as
select distinct /*Only want one value per event_id (and all other variables too).*/

	a.*,
	/*b. are variables needed from CRE risk history for equity/risk factor q's*/
	b.HCE,
	/*c. mechanism for CRE*/
	c.CRE_CARB_PRODUCE_MECHANISM 
		as mechanism,
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



proc freq data=test_import; tables type*year /norow nocol nopercent;run;



/*Output our working datasets into two. One for standard evalautions and one for risk factor/equity evaluation.*/
data SASdata.healthequitySAS;
	set work.test_import;
run;

data SASdata.recordssas;
	set work.test_import;
	where type in ('CRE');
run;



