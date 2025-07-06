
/*
 *------------------------------------------------------------------------------
 * Program Name:  MDRO_longtidy_20250619
 * Author:        Mikhail Hoskins
 * Date Created:  06/19/2025
 * Date Modified: 
 * Description:   The purpose of this code is to keep only columns needed from CRE/CAURIS/GAS extraction from denormalized tables 
 *				  and create a table that is formatted for easy Power BI integration. Power BI uses a "long-tidy" format that weill look like this:
 *						EVENT_ID | DATE_VALUE | YEAR_VALUE | METRIC | METRIC_VALUE
 *				
 *				  It will basically be a very long denomalized table. Starting with just the demographics and mechanisms, we will expand to health equity components. 
 *						
 *
 * Inputs:       SASdata.recordssas (from MDRO reports).
 * Output:       MDRO_longtidy_&sysdate..xlsx , MDRO_longtidy_&sysdate..sas7bdat
 * Notes:         
 *				
 *				
 *				
 *
 *------------------------------------------------------------------------------
 */






/*Import just for disease of interest*/

data records;
set SASdata.recordssas;
	if type not in ("&disease") then delete;

		where  EVENT_DATE >= "01jan2024"d and  EVENT_DATE <= "&qtr_dte"d;
run;

proc contents data=records;run;

proc sql;
/*mechanism*/
create table mech_val as
select 
	CASE_ID,
	EVENT_DATE,
	mechanism as value,
	case when mechanism not in ('dummy') then 'mechanism' else '' end as metric

from records
;
/*race*/
create table race_val as
select 
	CASE_ID,
	EVENT_DATE,
	RACE1 as value,
	case when RACE1 not in ('dummy') then 'race' else '' end as metric

from records
;
/*Ethnicity*/
create table eth_val as
select 
	CASE_ID,
	EVENT_DATE,
	Hispanic as value,
	case when Hispanic not in ('dummy') then 'ethnicity' else '' end as metric

from records
;
/*Gender*/
create table gender_val as
select 
	CASE_ID,
	EVENT_DATE,
	Gender as value,
	case when Gender not in ('dummy') then 'gender' else '' end as metric

from records
;
/*Age*/
create table age_val as
select 
	CASE_ID,
	EVENT_DATE,
		 /*age groups*/
		case when 0 LE age LT 5 then 'MDRO_04'
			 when 5 LE age LT 18 then 'MDRO_0517'
			 when 18 LE age LT 25 then 'MDRO_1824'
			 when 25 LE age LT 50 then 'MDRO_2549'
			 when 50 LE age LT 65 then 'MDRO_5064'
			 when age GE 65 then 'MDRO_65'
				else '' end as value,
	case when calculated value not in ('') then 'age' else '' end as metric

from records
;
quit;

data combine_long_tidy;
set mech_val race_val eth_val gender_val age_val;
run;



title; footnote;
/*Set your output pathway here*/
ods excel file="C:\Users\mhoskins1\Desktop\Work Files\MDRO_longtidy_&disease._&sysdate..xlsx";*<----- Named a generic overwriteable name so we can continue to reproduce and autopopulate a template;

ods excel options (sheet_interval = "none" sheet_name = "long_tidy" embedded_titles='Yes');



proc print data=combine_long_tidy noobs;run;

ods excel close;



