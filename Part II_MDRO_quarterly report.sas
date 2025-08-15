/*Part II: import data sets and create tables/plots datasets*/

/*Reset Macros in case running separately*/
options compress=yes;
options nofmterr;
title;footnote;

/*Clear results from prior code*/
dm 'odsresults; clear';

/*Health Equity Cleaning, New Variables*/
data analysis;

set SASdata.healthequitySAS;


/*First thing here is to confine to the disease we want to run, defined in MACRO, it will determine what our output reflects: CRE, CAURIS, or STRA (GAS)*/
	if type not in ("&disease") then delete;/*Runs only the disease you specify*/
	/*Rurality
			1=non-rural
			0=rural
	*/
	density=.;

	if owning_jd= "Alamance County"
	or owning_jd= "Buncombe County"
	or owning_jd= "Cabarrus County"
	or owning_jd= "Catawba County"
	or owning_jd= "Cumberland County"
	or owning_jd= "Davidson County"
	or owning_jd= "Durham County"
	or owning_jd= "Forsyth County"
	or owning_jd= "Gaston County"
	or owning_jd= "Guilford County"
	or owning_jd= "Henderson County"
	or owning_jd= "Iredell County"
	or owning_jd= "Johnston County"
	or owning_jd= "Lincoln County"
	or owning_jd= "Mecklenburg County"
	or owning_jd= "New Hanover County"
	or owning_jd= "Onslow County"
	or owning_jd= "Orange County"
	or owning_jd= "Pitt County"
	or owning_jd= "Rowan County"
	or owning_jd= "Union County"
	or owning_jd= "Wake County"

	then density=1;

	else density=0;

	/*SVI
		1= GE than 0.80
		0= LT than 0.80
	*/
		svi=.;

	if owning_jd= 'Lenoir County'
	or owning_jd= 'Robeson County'
	or owning_jd= 'Scotland County'
	or owning_jd= 'Greene County'
	or owning_jd= 'Halifax County'
	or owning_jd= 'Warren County'
	or owning_jd= 'Richmond County'
	or owning_jd= 'Vance County'
	or owning_jd= 'Bertie County'
	or owning_jd= 'Sampson County'
	or owning_jd= 'Anson County'
	or owning_jd= 'Wayne County'
	or owning_jd= 'Edgecombe County'
	or owning_jd= 'Wilson County'
	or owning_jd= 'Duplin County'
	or owning_jd= 'Columbus County'
	or owning_jd= 'Hertford County'
	or owning_jd= 'Cumberland County'
	or owning_jd= 'Swain County'
	or owning_jd= 'Hyde County'

	then svi=1;

	else svi=0;
	

	where  EVENT_DATE >= "01jan2024"d and  EVENT_DATE <= "&qtr_dte"d;


run;


/*End cleaning; begin tables*/

/*Health Equity Tables*/
proc sql;
create table hlth_equity_trav as
select

		intnx("qtr", (EVENT_DATE), 0, "end") as testreportqtr "Quarter Ending Date" format=date11.,

	/*MDRO travel*/
	sum (case when /*type in ('CRE','CAURIS') and*/ travel in ('Yes') then 1 else 0 end) as sum_travel_y "MDRO in Quarter, Travel: Yes",
	sum (case when /*type in ('CRE','CAURIS') and*/ travel in ('No') then 1 else 0 end) as sum_travel_n "MDRO in Quarter, Travel: No",
	sum (case when /*type in ('CRE','CAURIS') and*/ travel in ('Unknown') then 1 else 0 end) as sum_travel_u "MDRO in Quarter, Travel: Unknown",
	sum (case when/*type in ('CRE','CAURIS') and*/ travel in (' ') then 1 else 0 end) as sum_travel_m "MDRO in Quarter, Travel: Missing"


from analysis
	group by testreportqtr 
;

/*healthcare experience is a bit more complex. We want to search across all experiences, so an individual could be in a LTCF but diagnosed in an acute care setting. The result would be grouping in each, ie. people can fall into more than
one bucket for healthcare experience.*/
create table hlth_equity_HCE as
select

		intnx("qtr", (EVENT_DATE), 0, "end") as testreportqtr "Quarter Ending Date" format=date11.,

	/*MDRO healthcare experience*/
	sum (case when hce in ('Acute Care Hospitalization') then 1 else 0 end)
		as sum_hce_acute "MDRO in Quarter, HCE: Acute Care Hospital",

	sum (case when hce in ('Long term care facility - resident (e.g. nursing home, rest home, rehab)') then 1 else 0 end)
		as sum_hce_ltc "MDRO in Quarter, HCE: Long term care facility",

	sum (case when hce in ('No') then 1 else 0 end)
		as sum_hce_no "MDRO in Quarter, HCE: None",

	sum (case when hce in ('Long term acute care hospital (LTACH)') then 1 else 0 end)
		as sum_hce_ltach "MDRO in Quarter, HCE: Long Term Acute Care Hospital",

	sum (case when hce in ('Surgery (besides oral surgery), obstetrical or invasive procedure', 'Hemodialysis' , 'Complex medical devices (e.g. duodenoscopes)')
			  then 1 else 0 end)
		as sum_hce_surg "MDRO in Quarter, HCE: Surgery, Hemodialysis, other procedure(s)",

	sum (case when hce in ('Unknown') then 1 else 0 end)
		as sum_hce_unk "MDRO in Quarter, HCE: Unknown",

	sum (case when hce in (' ') then 1 else 0 end)
		as sum_hce_miss "MDRO in Quarter, HCE: Missing"

from analysis
	group by testreportqtr 
;


create table hlth_equity_hosp as
select

		intnx("qtr", (EVENT_DATE), 0, "end") as testreportqtr "Quarter Ending Date" format=date11.,

	/*MDRO travel*/
	sum (case when hospitalized_new in ('Yes') then 1 else 0 end) as sum_hosp_y "MDRO in Quarter, Hospitalized: Yes",
	sum (case when hospitalized_new in ('No') then 1 else 0 end) as sum_hosp_n "MDRO in Quarter, Hospitalized: No",
	sum (case when hospitalized_new in ('Unknown') then 1 else 0 end) as sum_hosp_unkmiss "MDRO in Quarter, Hospitalized: Unknown/Missing"

from analysis
	group by testreportqtr 
;


/*Rurality*/
/*For plot*/
create table hlth_equity_density_month as
select

		intnx("month", (EVENT_DATE), 0, "end") as testreportmonth "Month Ending Date" format=date11.,

	/*Rurality travel*/
	sum (case when density in (1) then 1 else 0 end) as mdro_NONrural "MDRO non-Rural Residency in month",
	sum (case when density in (0) then 1 else 0 end) as mdro_rural "MDRO Rural Residency in month",


	/*IR per 100k population*/

	(calculated mdro_rural / &ruraltotalpop) * 100000 as mdro_rural_IR "Rural" format 10.2,
	(calculated mdro_NONrural / &nonruralpop) * 100000 as mdro_NONrural_IR "Non-rural" format 10.2

from analysis

where EVENT_DATE < "&qtr_dte."d 
	group by testreportmonth 
;
/*Table*/
create table hlth_equity_density_qt as
select

		intnx("qtr", (EVENT_DATE), 0, "end") as testreportqtr "Quarter Ending Date" format=date11.,

	/*Rurality residency*/
	sum (case when density in (1) then 1 else 0 end) as mdro_NONrural "MDRO Urban Residency in quarter",
	sum (case when density in (0) then 1 else 0 end) as mdro_rural "MDRO Rural Residency in quarter",

	/*IR Density per 100k population*/

	(calculated mdro_rural / &ruraltotalpop) * 100000 as mdro_rural_IR "IR/100k Rural in quarter" format 10.2,
	(calculated mdro_NONrural / &nonruralpop) * 100000 as mdro_NONrural_IR "IR/100K Non-Rural in quarter" format 10.2,

	/*SVI*/
	sum (case when svi in (1) then 1 else 0 end) as mdro_svi_HI "MDRO High SVI County",
	sum (case when svi in (0) then 1 else 0 end) as mdro_svi_LO "MDRO not High SVI County",

	/*IR SVI per 100k population*/
	(calculated mdro_svi_HI / &svihighpop) *100000 as mdro_sviHI_IR "IR/100k SVI 0.80 or greater in quarter",
	(calculated mdro_svi_LO / &svilowpop) * 100000 as mdro_sviLO_IR "IR/100K SVI less than 0.80 in quarter"

from analysis

where EVENT_DATE < "&qtr_dte."d
	group by testreportqtr
;
quit;



data equity_combine;
merge hlth_equity_density_qt hlth_equity_hosp hlth_equity_HCE hlth_equity_trav 
;
	by testreportqtr;
	where testreportqtr <= "&qtr_dte."d; *<----- set date parameters here, it can mess up cumulative counts if you do it later on;
run;

/*make all of our cumulative values*/
data equity_combine_cum;
set equity_combine;

	cum_mdro_rural+mdro_rural;
	cum_mdro_NONrural+mdro_NONrural;

	cum_mdro_svi_HI + mdro_svi_HI;
	cum_mdro_svi_LO + mdro_svi_LO;

/*IR*/
	/*Density*/
		cum_mdro_rural_IR = ((cum_mdro_rural / (&ruraltotalpop-cum_mdro_rural)) * 100000);
		cum_mdro_NONrural_IR = ((cum_mdro_NONrural / (&nonruralpop-cum_mdro_NONrural)) * 100000);

	/*SVI*/
		cum_mdro_sviHI_IR + mdro_sviHI_IR;
		cum_mdro_sviLO_IR + mdro_sviLO_IR;

	cum_sum_hosp_y+sum_hosp_y;
	cum_sum_hosp_n+sum_hosp_n;
	cum_sum_hosp_unkmiss+sum_hosp_unkmiss;
	cum_sum_hce_acute+sum_hce_acute;
	cum_sum_hce_ltc+sum_hce_ltc;
	cum_sum_hce_no+sum_hce_no;
	cum_sum_hce_ltach+sum_hce_ltach;
	cum_sum_hce_surg+sum_hce_surg;
	cum_sum_hce_unk+sum_hce_unk;
	cum_sum_hce_miss+sum_hce_miss;
	cum_sum_travel_y+sum_travel_y;
	cum_sum_travel_n+sum_travel_n;
	cum_sum_travel_u+sum_travel_u;
	cum_sum_travel_m+sum_travel_m;

		
		label cum_mdro_rural="Cumulative MDRO in quarter: Rural";
		label cum_mdro_NONrural="Cumulative MDRO in quarter: Non-rural";
		label cum_mdro_rural_IR="Cumulative MDRO in quarter: Rural IR";
		label cum_mdro_NONrural_IR="Cumulative MDRO in quarter: Non-rural IR";

		label cum_mdro_svi_LO= "Cumulative MDRO in quarter: SVI less than 0.80";
		label cum_mdro_svi_HI= "Cumulative MDRO in quarter: SVI greater than or equal to 0.80";
		label cum_mdro_sviLO_IR= "Cumulative MDRO in quarter: SVI less than 0.80 IR";
		label cum_mdro_sviHI_IR= "Cumulative MDRO in quarter: SVI greater than or equal to 0.80 IR";


		label cum_sum_hosp_y="Cumulative MDRO in quarter: Hospitalized";
		label cum_sum_hosp_n="Cumulative MDRO in quarter: Not Hospitalized";
		label cum_sum_hosp_unkmiss="Cumulative MDRO in quarter: Unknown/Missing Hospitalization Status";
		label cum_sum_hce_acute="Cumulative MDRO in quarter: HCE Acute Care";
		label cum_sum_hce_ltc="Cumulative MDRO in quarter: HCE Longterm Care";
		label cum_sum_hce_no="Cumulative MDRO in quarter: HCE None";
		label cum_sum_hce_ltach="Cumulative MDRO in quarter: HCE Longterm Acute Care";
		label cum_sum_hce_surg="Cumulative MDRO in quarter: HCE Surgery/Invasive Procedure";
		label cum_sum_hce_unk="Cumulative MDRO in quarter: HCE Unknown";
		label cum_sum_hce_miss="Cumulative MDRO in quarter: HCE Missing";
		label cum_sum_travel_y="Cumulative MDRO in quarter: History of travel";
		label cum_sum_travel_n="Cumulative MDRO in quarter: No history of travel";
		label cum_sum_travel_u="Cumulative MDRO in quarter: Unknown history of travel";
		label cum_sum_travel_m="Cumulative MDRO in quarter: Missing history of travel";


run;


/*Now create percentages of cumulative counts as we move through each quarter of our timeframe*/
proc sql;
create table qtr_percent_equity as
select
*,


cum_mdro_rural/(cum_mdro_NONrural+ cum_mdro_rural )as pct_mdro_rural "Cumulative Percent MDRO in Quarter: Rural" format percent10.1,
cum_mdro_NONrural/(cum_mdro_NONrural + cum_mdro_rural )as pct_mdro_NONrural "Cumulative Percent MDRO in Quarter: Non rural" format percent10.1,

	cum_mdro_svi_HI / (cum_mdro_svi_HI + cum_mdro_svi_LO) as pct_mdro_sviHI "Cumulative Percent MDRO in Quarter: HIGH SVI" format percent10.1,
	cum_mdro_svi_LO / (cum_mdro_svi_HI + cum_mdro_svi_LO) as pct_mdro_sviLO "Cumulative Percent MDRO in Quarter: LOW SVI" format percent10.1,

cum_sum_hosp_y/(cum_sum_hosp_y +cum_sum_hosp_n+cum_sum_hosp_unkmiss)as pct_sum_hosp_y "Cumulative Percent MDRO in Quarter: Hospitalized" format percent10.1,
cum_sum_hosp_n/(cum_sum_hosp_y +cum_sum_hosp_n+cum_sum_hosp_unkmiss)as pct_sum_hosp_n "Cumulative Percent MDRO in Quarter: Not hospitalized" format percent10.1,
cum_sum_hosp_unkmiss/(cum_sum_hosp_y +cum_sum_hosp_n+cum_sum_hosp_unkmiss)as pct_sum_hosp_unkmiss "Cumulative Percent MDRO in Quarter: Unknown hospitalization status" format percent10.1,
cum_sum_hce_acute/(cum_sum_hce_acute+cum_sum_hce_ltc+cum_sum_hce_no+cum_sum_hce_ltach+cum_sum_hce_surg+cum_sum_hce_unk+cum_sum_hce_miss)as pct_sum_hce_acute "Cumulative Percent MDRO in Quarter: HCE Acute Care" format percent10.1,
cum_sum_hce_ltc/(cum_sum_hce_acute+cum_sum_hce_ltc+cum_sum_hce_no+cum_sum_hce_ltach+cum_sum_hce_surg+cum_sum_hce_unk+cum_sum_hce_miss)as pct_sum_hce_ltc "Cumulative Percent MDRO in Quarter: HCE Longterm Care" format percent10.1,
cum_sum_hce_no/(cum_sum_hce_acute+cum_sum_hce_ltc+cum_sum_hce_no+cum_sum_hce_ltach+cum_sum_hce_surg+cum_sum_hce_unk+cum_sum_hce_miss)as pct_sum_hce_no "Cumulative Percent MDRO in Quarter: HCE None" format percent10.1,
cum_sum_hce_ltach/(cum_sum_hce_acute+cum_sum_hce_ltc+cum_sum_hce_no+cum_sum_hce_ltach+cum_sum_hce_surg+cum_sum_hce_unk+cum_sum_hce_miss)as pct_sum_hce_ltach "Cumulative Percent MDRO in Quarter: HCE Longterm Acute Care" format percent10.1,
cum_sum_hce_surg/(cum_sum_hce_acute+cum_sum_hce_ltc+cum_sum_hce_no+cum_sum_hce_ltach+cum_sum_hce_surg+cum_sum_hce_unk+cum_sum_hce_miss)as pct_sum_cum_sum_hce_surg "Cumulative Percent MDRO in Quarter: HCE Surgery/Invasive Procedure" format percent10.1,
cum_sum_hce_unk/(cum_sum_hce_acute+cum_sum_hce_ltc+cum_sum_hce_no+cum_sum_hce_ltach+cum_sum_hce_surg+cum_sum_hce_unk+cum_sum_hce_miss)as pct_sum_cum_sum_hce_unk "Cumulative Percent MDRO in Quarter: HCE Unknown" format percent10.1,
cum_sum_hce_miss/(cum_sum_hce_acute+cum_sum_hce_ltc+cum_sum_hce_no+cum_sum_hce_ltach+cum_sum_hce_surg+cum_sum_hce_unk+cum_sum_hce_miss)as pct_sum_cum_sum_hce_miss "Cumulative Percent MDRO in Quarter: HCE Missing" format percent10.1,
cum_sum_travel_y/(cum_sum_travel_y+cum_sum_travel_n+cum_sum_travel_u+cum_sum_travel_m)as pct_sum_cum_sum_travel_y "Cumulative Percent MDRO in Quarter: History of travel" format percent10.1,
cum_sum_travel_n/(cum_sum_travel_y+cum_sum_travel_n+cum_sum_travel_u+cum_sum_travel_m)as pct_sum_cum_sum_travel_n "Cumulative Percent MDRO in Quarter: No history of travel" format percent10.1,
cum_sum_travel_u/(cum_sum_travel_y+cum_sum_travel_n+cum_sum_travel_u+cum_sum_travel_m)as pct_sum_cum_sum_travel_u "Cumulative Percent MDRO in Quarter: Unknown history of travel" format percent10.1,
cum_sum_travel_m/(cum_sum_travel_y+cum_sum_travel_n+cum_sum_travel_u+cum_sum_travel_m)as pct_sum_cum_sum_travel_m "Cumulative Percent MDRO in Quarter: Missing history of travel" format percent10.1



from equity_combine_cum
;
quit;


/*Now tables for race and mechanism*/
proc sql;
create table records as
select *,

	case
			when (RACE1 = 'Other' or RACE2 ne '' or RACE3 ne '' or RACE4 ne '' or RACE5 ne '' or RACE6 ne '')  then "Other"
			when RACE1='Asian' then 'Asian or Native Hawaiian or Pacific Islander'
			when RACE1='Native Hawaiian or Pacific Islander' then 'Asian or Native Hawaiian or Pacific Islander'
			else RACE1

		end as race_new

from SASdata.recordssas
	where  EVENT_DATE >= "01jan2024"d and  EVENT_DATE <= "&qtr_dte"d
;


quit;



proc sql;
create table disease_sum as
select *,

/*add date variables into parent dataset*/
	intnx("qtr", (EVENT_DATE), 0, "end") as testreportqtr "Quarter Ending Date" format=date11.,
	intnx("qtr", (symptom_onset_date), 0, "end") as testreportqtr_symptom "Quarter Ending Date for symptom onset" format=date11.,
	intnx("month", (EVENT_DATE), 0, "end") as testreportmonth "Month Ending Date" format=date11.,

	(EVENT_DATE) as most_recent_case 


from records

;
/*create sum of all case counts by county*/
create table county_sum as
select
	
	owning_jd 'County of residence',
	sum (case when type in ('CRE') then 1 else 0 end) as CP_CRE "CP-CRE",
	sum (case when type in ('CAURIS') then 1 else 0 end) as c_auris "C. auris"

from records
	group by owning_jd
	order by  CP_CRE desc
;
quit;


proc sql;
create table disease_counts_qtr as /*we'll use this for coding yearly counts and cumulative counts*/
select

	intnx("qtr", (EVENT_DATE), 0, "end") as testreportqtr "Quarter Ending Date" format=date11.,
	
	sum (case when type in ('CRE') then 1 else 0 end) as CP_CRE "CP-CRE in Quarter",
	sum (case when type in ('CAURIS') then 1 else 0 end) as c_auris "C. auris in Quarter",

	/*MDRO tot*/
	SUM (CASE WHEN TYPE IN ('CRE','CAURIS') then 1 else 0 end) as mdro_count "MDRO in Quarter"


from records
group by testreportqtr
;

create table disease_counts_class as /*we'll use this for coding yearly counts and cumulative counts*/
select

	testreportqtr "Quarter Ending Date" format=date11.,
	CP_CRE,
	c_auris,
	mdro_count


from disease_counts_qtr
group by CP_CRE, c_auris
		order by testreportqtr
;
quit;

/*Cumulative counts for hard coding percentages (or manually creating percentages in outputs)*/
data disease_counts_qtr_cum;
set disease_counts_qtr;

	cum_CP_CRE + CP_CRE;
	label cum_CP_CRE = 'Cumulative CRE by Quarter';

	cum_CAURIS + c_auris;
	label cum_CAURIS = 'Cumulative C. auris by Quarter';

	cum_mdro_count + mdro_count;
	label cum_mdro_count = 'Cumulative MDRO by Quarter';


run;
/*Race*/
proc freq data=records; tables race_new / norow nocol nopercent;run;
proc sql;
create table disease_counts_qtr_race as
select

	intnx("qtr", (EVENT_DATE), 0, "end") as testreportqtr "Quarter Ending Date" format=date11.,

/*MDRO by race*/
	sum (case when race_new in ('White') then 1 else 0 end) as MDRO_w "MDRO in Quarter, Race: White",	
	sum (case when race_new in ('Black or African American') then 1 else 0 end) as MDRO_b "MDRO in Quarter, Race: Black or African American",
	sum (case when race_new in ('Asian or Native Hawaiian or Pacific Islander') then 1 else 0 end) as MDRO_a "MDRO in Quarter, Race: Asian/NH/PI",
	sum (case when race_new in ('Other') then 1 else 0 end) as MDRO_oth "MDRO in Quarter, Race: Other",
	sum (case when race_new in ('Unknown') then 1 else 0 end) as MDRO_unk "MDRO in Quarter, Race: Unknown",
	sum (case when race_new in ('American Indian Alaskan Native') then 1 else 0 end) as MDRO_aian "MDRO in Quarter, Race: American Indian Alaskan Native",
	sum (case when race_new in (' ') then 1 else 0 end) as MDRO_miss "MDRO in Quarter, Race: Missing"

from records
group by testreportqtr
;
/*Ethnicity*/
create table disease_counts_qtr_eth as
select

	intnx("qtr", (EVENT_DATE), 0, "end") as testreportqtr "Quarter Ending Date" format=date11.,

	/*MDRO by Ethnicity*/
	sum (case when Hispanic in ('Yes') then 1 else 0 end) as MDRO_hisp "MDRO in Quarter: Hispanic",
	sum (case when Hispanic in ('No') then 1 else 0 end) as MDRO_nohisp "MDRO in Quarter: Not Hispanic",
	sum (case when Hispanic in ('Unknown') then 1 else 0 end) as MDRO_unkhisp "MDRO in Quarter: Unknown Hispanic",
	sum (case when Hispanic in (' ') then 1 else 0 end) as MDRO_misshisp "MDRO in Quarter: Missing Hispanic"

from records
group by testreportqtr 
;
/*Gender*/
create table disease_counts_qtr_gender as
select

	intnx("qtr", (EVENT_DATE), 0, "end") as testreportqtr "Quarter Ending Date" format=date11.,

	/*CRE by Gender*/
	sum (case when Gender in ('Male') then 1 else 0 end) as MDRO_male "MDRO in Quarter: Male",
	sum (case when Gender in ('Female') then 1 else 0 end) as MDRO_female "MDRO in Quarter: Female",
	sum (case when Gender in (' ') then 1 else 0 end) as MDRO_sexmiss "MDRO in Quarter: Missing"

from records
group by testreportqtr 
;
/*Age group*/
create table disease_counts_qtr_age as
select

	intnx("qtr", (EVENT_DATE), 0, "end") as testreportqtr "Quarter Ending Date" format=date11.,


	/*MDRO by Age Group*/
	/*sum(case when 0 LE age LT 5 then 1 else 0 end) as MDRO_04 label='MDRO in Quarter: Age 0-4',
	sum(case when 5 LE age LT 18 then 1 else 0 end) as MDRO_0517 label='MDRO in Quarter: Age 5-17',
	*/
	/*New age group pediatric <18*/
	sum(case when 0 LE age LT 18 then 1 else 0 end) as MDRO_0017 label='MDRO in Quarter: Pediatric 0-17',
	sum(case when 18 LE age LT 25 then 1 else 0 end) as MDRO_1824 label='MDRO in Quarter: Age 18-24',
	sum(case when 25 LE age LT 50 then 1 else 0 end) as MDRO_2549 label='MDRO in Quarter: Age 25-49',
	sum(case when 50 LE age LT 65 then 1 else 0 end) as MDRO_5064 label='MDRO in Quarter: Age 50-64',
	sum(case when age GE 65 then 1 else 0 end) as MDRO_65 label='MDRO in Quarter: Age 65+'


from records

group by testreportqtr 
;

/*Mechanism (CRE only)*/
create table disease_counts_cre_mech as
select

	intnx("qtr", (EVENT_DATE), 0, "end") as testreportqtr "Quarter Ending Date" format=date11.,
	sum (case when mechanism in ('KPC') then 1 else 0 end) as mech_KPC "Mechanism: KPC",
	sum (case when mechanism in ('NDM') then 1 else 0 end) as mech_NDM "Mechanism: NDM",
	sum (case when mechanism in ('OXA-48') then 1 else 0 end) as mech_OXA48 "Mechanism: OXA-48",
	sum (case when mechanism in ('Other') then 1 else 0 end) as mech_Oth "Mechanism: Other",
	sum (case when mechanism in ('IMP') then 1 else 0 end) as mech_IMP "Mechanism: IMP",
	sum (case when mechanism in ('VIM') then 1 else 0 end) as mech_VIM "Mechanism: VIM",
	sum (case when mechanism in ('Missing' ,'') then 1 else 0 end) as mech_miss "Mechanism: Missing"

from records
group by testreportqtr
;

quit;
/*Merge all datasets and confine to dates we want to look at by qtr*/

data mech_race_combine;
merge disease_counts_qtr_cum disease_counts_qtr_race disease_counts_qtr_eth disease_counts_qtr_gender disease_counts_qtr_age disease_counts_cre_mech;
	by testreportqtr;
	where testreportqtr <= "&qtr_dte."d; *<----- set date parameters here, it can mess up cumulative counts if you do it later on;
run;

/*make all of our cumulative values*/
data combine_cum_demo;
set mech_race_combine;

	cum_CRE+CP_CRE;
	cum_c_auris+c_auris;
	/*cum_GAS+GAS*/

	cum_MDRO_w+MDRO_w;
	cum_MDRO_b+MDRO_b;
	cum_MDRO_a+MDRO_a;
	cum_MDRO_nhpi+MDRO_nhpi;
	cum_MDRO_oth+MDRO_oth;
	cum_MDRO_unk+MDRO_unk;
	cum_MDRO_aian+MDRO_aian;
	cum_MDRO_miss+MDRO_miss;

	cum_MDRO_hisp+MDRO_hisp;
	cum_MDRO_nohisp+MDRO_nohisp;
	cum_MDRO_unkhisp+MDRO_unkhisp;
	cum_MDRO_misshisp+MDRO_misshisp;
	
	cum_MDRO_male+MDRO_male;
	cum_MDRO_female+MDRO_female;
	cum_MDRO_sexmiss+MDRO_sexmiss;
	
	cum_MDRO_04+MDRO_04;
	/*cum_MDRO_0517+MDRO_0517; *add pediatric*/
	cum_MDRO_0017+MDRO_0017;
	cum_MDRO_1824+MDRO_1824;
	cum_MDRO_2549+MDRO_2549;
	cum_MDRO_5064+MDRO_5064;
	cum_MDRO_65+MDRO_65;

	cum_mech_KPC + mech_KPC;
	cum_mech_NDM + mech_NDM;
	cum_mech_OXA48 + mech_OXA48;
	cum_mech_Oth + mech_Oth;
	cum_mech_IMP + mech_IMP;
	cum_mech_VIM + mech_VIM;
	cum_mech_miss + mech_miss;

	
		label cum_CRE= "Cumulative CRE";
		label cum_c_auris= "Cumulative C.auris";
		
		label cum_MDRO_w= "Cumulative MDRO in Quarter, Race: White";
		label cum_MDRO_b= "Cumulative MDRO in Quarter, Race: Black or African American";
		label cum_MDRO_a= "Cumulative MDRO in Quarter, Race: Asian";
		label cum_MDRO_oth= "Cumulative MDRO in Quarter, Race: Other";
		label cum_MDRO_unk= "Cumulative MDRO in Quarter, Race: Unknown";
		label cum_MDRO_aian= "Cumulative MDRO in Quarter, Race: American Indian Alaskan Native";
		label cum_MDRO_miss= "Cumulative MDRO in Quarter, Race: Missing";

		label cum_MDRO_hisp= "Cumulative MDRO in Quarter: Hispanic";
		label cum_MDRO_nohisp= "Cumulative MDRO in Quarter: Not Hispanic";
		label cum_MDRO_unkhisp= "Cumulative MDRO in Quarter: Unknown Hispanic";
		label cum_MDRO_misshisp= "Cumulative MDRO in Quarter: Missing Hispanic";
		
		label cum_MDRO_male= "Cumulative MDRO in Quarter: Male";
		label cum_MDRO_female= "Cumulative MDRO in Quarter: Female";
		label cum_MDRO_sexmiss= "Cumulative MDRO in Quarter: Missing";

		label cum_MDRO_04= "Cumulative MDRO in Quarter: Age 0-4";
		/*label cum_MDRO_0517= "Cumulative MDRO in Quarter: Age 5-17";*/ *add pediatric;
		label cum_MDRO_0017= "Cumulative MDRO in Quarter: Pediatric 0-17";
		label cum_MDRO_1824= "Cumulative MDRO in Quarter: Age 18-24";
		label cum_MDRO_2549= "Cumulative MDRO in Quarter: Age 25-49";
		label cum_MDRO_5064= "Cumulative MDRO in Quarter: Age 50-64";
		label cum_MDRO_65= "Cumulative MDRO in Quarter: Age 65+";

		label cum_mech_KPC= "Cumulative Mechanism: KPC";
		label cum_mech_NDM= "Cumulative Mechanism: NDM";
		label cum_mech_OXA48= "Cumulative Mechanism: OXA-48";
		label cum_mech_Oth= "Cumulative Mechanism: Other";
		label cum_mech_IMP= "Cumulative Mechanism: IMP";
		label cum_mech_VIM= "Cumulative Mechanism: VIM";
		label cum_mech_miss= "Cumulative Mechanism: Missing";
		
run;

/*Now we have individual tables AND a combined table of values for basic demographics and health equity questions*/


/*Data steps for plots for health equity/ risk factor graphs*/


/*Create additional data sets for plotting equity variables*/

proc sql;
create table equity_plots as
select *,


	intnx("qtr", (EVENT_DATE), 0, "end") as testreportqtr "Quarter Ending Date" format=date11.,
	intnx("qtr", (symptom_onset_date), 0, "end") as testreportqtr_symptom "Quarter Ending Date for symptom onset" format=date11.,
	intnx("month", (EVENT_DATE), 0, "end") as testreportmonth "Month Ending Date" format=date11.,

	(EVENT_DATE) as most_recent_case

from analysis

;
quit;

data equity_plots;

length label_trav $12.;
length label_HCE $12.;
length label_hosp $12.;
length rurality $12.;

set equity_plots;

	Label_trav = travel;
	if EVENT_DATE < "01dec&year_dte."d then
  		Label_trav = " ";

	Label_hce = healthcare_experience;
	if EVENT_DATE < "01dec&year_dte."d then
  		Label_hce = " ";

	Label_hosp = hospitalized_new;
	if EVENT_DATE < "01dec&year_dte."d then
  		Label_hosp= " ";


	Label_hceexp = hce_plot;
	if EVENT_DATE <"01dec&year_dte."d then
		Label_hceexp = " ";

	/*Rurality
			1=urban
			2=suburban
			0=rural
	*/
	rurality=.;

	if density in (1,2) then rurality= "Not Rural";
	if density in (0) then rurality= "Rural";

run;



/*Healthcare experience is wild. Just make HCE its own graph*/
data equity_labels_hce;
set equity_combine_cum (keep= testreportqtr cum_sum_hce_acute cum_sum_hce_ltach cum_sum_hce_ltc cum_sum_hce_miss cum_sum_hce_no cum_sum_hce_surg cum_sum_hce_unk);


label cum_sum_hce_acute = "Acute Care Hospital"; 


	label cum_sum_hce_ltach = "LTACH";
	label cum_sum_hce_ltc = "LTCF"; 
	label cum_sum_hce_no = "None"; 
	label cum_sum_hce_surg = "Surgery/Hemodialysis";
	label cum_sum_hce_unk = "Unknown";
	label cum_sum_hce_miss = "Missing";


where testreportqtr in ("&qtr_dte"d);
run;

proc transpose data=equity_labels_hce out=transpose_labels;

  /*BY hce_plot;   This variable will become the new row identifier */

  var cum_sum_hce_acute cum_sum_hce_ltach cum_sum_hce_ltc cum_sum_hce_miss cum_sum_hce_no cum_sum_hce_surg cum_sum_hce_unk; /* These columns will be transposed into rows */

run;




/*separate label for health equity density labels*/
data hlth_equity_density_month_2;
set hlth_equity_density_month;

	
length label_rural $12.;
length label_nonrural $12.;


	Label_rural= "Rural";
	if 	testreportmonth < "01dec&year_dte."d then
  		Label_rural = " ";

	Label_nonrural= "Non-rural";
	if 	testreportmonth < "01dec&year_dte."d then
  		Label_nonrural = " ";

run;


/*Some demographic plot label recodes*/
data plots;
length label_eth $12.;
length label_eth_2 $12.;
length label_mech $12.;
length trav_mech $16.;

	set disease_sum;

	most_recent = max(EVENT_DATE);


	Label_class = Type;
	if most_recent < "01dec&year_dte."d then
  		Label_class = " ";

	Label_gender = Gender;
	if most_recent < "01dec&year_dte."d then
  		Label_gender = " ";

	Label_race = Race1;
	if most_recent < "01dec&year_dte."d then
  		Label_race = " ";

	Label_eth = Hispanic;
	if Hispanic = "Yes" then 
		Label_eth = "Hispanic";
	if Hispanic = "No" then
		Label_eth = "Non-Hispanic";

		label_eth_2=label_eth;
			if most_recent < "01dec&year_dte."d then
  			Label_eth_2 = " ";

	Label_agegrp = age_group;
	if most_recent <"01dec&year_dte."d then
		label_agegrp = " ";

	label_mech = mechanism;
	if mechanism = ''  then label_mech = "Missing";

	trav_mech = travel;
	if travel = ''  then trav_mech = "Missing";


run;

proc freq data=plots;tables travel trav_mech;run;

/*Always take a look at the tables we're creating*/
/*For our table creation, it is easiest to make a table that looks like this:

Variable | Count in Quarter | Percent(or IR) in Quarter
_________|__________________|____________________
Var name |       ###        |        %%%%        
Var name |       ###        |        %%%%        
Var name |       ###        |        %%%%        
Var name |       ###        |        %%%%        
Var name |       ###        |        %%%%        
...

This makes our tables uniform in WIDTH for a template so we're not messing around with column widths to fit depending on the text.

To do this we'll transpose into one big table and use excel to make them look better or match them up with an excel doc template. 
It's a bit messy but it works for what we're doing here.
*/

data transpose_prep;
set equity_combine_cum (drop =  mdro_rural  mdro_NONrural mdro_rural_IR mdro_NONrural_IR mdro_svi_HI mdro_svi_LO
								sum_hosp_y sum_hosp_n sum_hosp_unkmiss sum_hce_acute sum_hce_ltc sum_hce_no sum_hce_ltach mdro_sviHI_IR
								sum_hce_surg sum_hce_unk sum_hce_miss sum_travel_y sum_travel_n sum_travel_u sum_travel_m mdro_sviLO_IR);
run;

proc transpose data=transpose_prep out=equity_transpose;
    id testreportqtr;
	format &qtr_end_transpose 10.0;

run;


data transpose_prep_pcts;
set qtr_percent_equity (drop =  mdro_rural  mdro_NONrural sum_hosp_y sum_hosp_n sum_hosp_unkmiss sum_hce_acute sum_hce_ltc sum_hce_no sum_hce_ltach sum_hce_surg sum_hce_unk mdro_svi_LO mdro_svi_HI
								sum_hce_miss sum_travel_y sum_travel_n sum_travel_u sum_travel_m  cum_mdro_rural cum_mdro_NONrural mdro_NONrural_IR 
								mdro_rural_IR cum_sum_hosp_y cum_sum_hosp_n cum_sum_hosp_unkmiss cum_sum_hce_acute cum_sum_hce_ltc cum_sum_hce_no cum_sum_hce_ltach cum_sum_hce_surg cum_sum_hce_unk cum_sum_hce_miss 
								cum_sum_travel_y cum_sum_travel_n cum_sum_travel_u cum_sum_travel_m cum_mdro_svi_LO cum_mdro_svi_HI mdro_sviHI_IR mdro_sviLO_IR);

run;

proc transpose data=transpose_prep_pcts out=equity_transpose_pcts;
    id testreportqtr;
	format &qtr_end_transpose percent10.2;

run;

proc sql;
create table transpose_equity_counts as
select 

	_LABEL_ as risk_factor 'Risk Factor',
	&qtr_end_transpose as &qtr_num "&qtr_num. Count"

from equity_transpose;

create table transpose_equity_pcts as
select

	_LABEL_ as risk_factor 'Risk Factor',
	&qtr_end_transpose as &qtr_num "&qtr_num. Percent"


from equity_transpose_pcts 
;
quit;
/*Separated out IR quarterly code for specific edits as necessary, should run without touching unless updates are needed to denominators, values, etc.*/
%INCLUDE "T:\HAI\Code library\Epi curve example\SAS Codes\Reports\MDRO_IR_quarterly.sas";

/*Transpose IR*/
proc transpose data=combine_qtr_IR out=demo_transpose_IR;
    id testreportqtr;
	format &qtr_end_transpose 10.3;

run;

/*Transpose case counts*/
proc transpose data=combine_cum_demo out=demo_transpose; 
	id testreportqtr ;
		

run;

data demo_transpose_2;
set demo_transpose;
	if _NAME_ in ('CP_CRE',
'c_auris',
'mdro_count',
'cum_CP_CRE',
'cum_CAURIS',
'cum_mdro_count'/*,
'MDRO_w',
'MDRO_b',
'MDRO_a',
'MDRO_nhpi',
'MDRO_oth',
'MDRO_unk',
'MDRO_aian',
'MDRO_miss',
'MDRO_hisp',
'MDRO_nohisp',
'MDRO_unkhisp',
'MDRO_misshisp',
'MDRO_male',
'MDRO_female',
'MDRO_sexmiss',
'MDRO_04',
'MDRO_0517',
'MDRO_1824',
'MDRO_2549',
'MDRO_5064',
'MDRO_65'*/
) then delete;
run;
proc print data=demo_transpose_2;run;

/*Create a fun lil macro to create CRE Mechanism percentages:
		basically this takes the cumulative total of CRE and uses it as the denominator to calculate the percentage.
		pretty niche use case but it's helpful here and you can use different column names to create different percentages based on the disease without re-writing a bunch of shit up top
*/
proc sql noprint;
 select cum_mdro_count into :tot_cre

	from combine_cum_demo
 where testreportqtr in ("&qtr_dte"D);

quit;
%put &tot_cre;

proc sql;
create table demo_transpose_final as
select 

	_LABEL_ as risk_factor 'Demographic Classification',
	&qtr_end_transpose as &qtr_num "&qtr_num. Count",
	case when _LABEL_  like '%Cumulative Mechanism%' then (&qtr_end_transpose / &tot_cre) else . end as mech_pct format percent10.0 /*put your constant of  CRE/cases here if applicable, looking for a better way to do this piece....*/

from demo_transpose_2;

create table demo_transpose_IR_final as
select

	_LABEL_ as demographic 'Demographic Classification',
	&qtr_end_transpose as &qtr_num "&qtr_num. IR/100k",
	/*add CI*/

	case when &qtr_end_transpose not in (0) then (STDERR(&qtr_end_transpose)) else . end as std_err "Standard error", /*Display 0 values as missing/. so they don't confuse you on the table*/
	(&qtr_end_transpose + (1.96*(calculated std_err))) as uCL "Upper confidence limit" format 10.2,
	(&qtr_end_transpose - (1.96*(calculated std_err))) as lCL "Lower confidence limit" format 10.2

from demo_transpose_IR 
;
/*Don't need standard error beyond this point*/
	alter table demo_transpose_IR_final
	drop std_err;

quit;




proc print data=demo_transpose_final noobs label;run;

proc print data=demo_transpose_IR_final noobs label;run;



/*Export transposed tables to create template tables here. No need to save datasets at this point*/

title; footnote;
/*Set your output pathway here*/
ods excel file="C:\Users\mhoskins1\Desktop\Work Files\&disease._Tables_&sysdate..xlsx";*<----- Named a generic overwriteable name so we can continue to reproduce and autopopulate a template;


title justify=left height=10pt font='Helvetica' "&year_dte. Demo Case counts/IRs through &qtr_num.";
ods excel options (sheet_interval = "none" sheet_name = "demo tables" embedded_titles='Yes');
/*transposed tables-demographics*/
proc print data=demo_transpose_final noobs label;run;
proc print data=demo_transpose_IR_final noobs label;run;

title justify=left height=10pt font='Helvetica' "&year_dte. Risk Factor Case counts/Percents through &qtr_num.";
ods excel options (sheet_interval = "now" sheet_name = "equity tables" embedded_titles='Yes');
/*transposed tables-equity*/
proc print data=transpose_equity_counts noobs label;run;
proc print data=transpose_equity_pcts noobs label;run;

title justify=left height=10pt font='Helvetica' "&year_dte. Risk Factor Case counts/IRs through &qtr_num.";
ods excel options (sheet_interval = "now" sheet_name = "svi density" embedded_titles='Yes');
/*transposed IR tables for svi and density*/
proc print data=equRace_transp_final noobs label;run;
proc print data=equIR_transp_final noobs label;run;

ods excel options (sheet_interval="now" sheet_name = "statsig" embedded_titles = 'Yes');

run;
ods excel close;


/*Last thing:*/
/*Autorun the bar graph macro*/
%include "T:\HAI\Code library\Epi curve example\SAS Codes\Reports\MDRO_quarterly report_bar graph macro.sas";



/*Fin!*/
