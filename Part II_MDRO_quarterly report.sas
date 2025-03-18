/*Part II: import data sets and create tables/plots datasets*/

/*Reset Macros in case running separately*/
options compress=yes;
options nofmterr;
title;footnote;
/*Health Equity Cleaning, New Variables*/


data analysis;
set SASdata.healthequitySAS;

	length healthcare_experience $72.;
	length travel $8.;
	length hospitalized_new $7.;
	length screening_event $26.;

	/*i.travel*/
	travel= "Missing";
	if recent_travel in ("Yes") or RECENT_TRAVEL in ("YES") or RECENT_TRAVEL in ("Yes") then travel="Yes";
	if recent_travel in ("No") or RECENT_TRAVEL in ("NO") or RECENT_TRAVEL in ("No") then travel="No";
	if recent_travel in ("Unknown") or RECENT_TRAVEL in ("UNKNOWN") or RECENT_TRAVEL in ("Unknown") then travel="Unknown";



	/*iii. hospitalization status*/
	hospitalized_new= "Unknown/Missing";
	if HOSPITALIZED in ("Yes") or HCE_HOSPITAL_NAME_0 not in ("") then hospitalized_new="Yes";
	if HOSPITALIZED in ("No")  then hospitalized_new="No";

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
	

	if (find (REASON_FOR_TESTING,'Colonization screening')>0) or (find (REASON_FOR_TESTING,'Screening in community')>0)
		then screening_event='Yes';

	if  (find (REASON_FOR_TESTING,'Part of clinical care')>0)
		then screening_event='No';

	if REASON_FOR_TESTING in (' ') 
		then screening_event='Mising/Unknown';



	where type in ("CRE", "CAURIS");

run;




/*End cleaning; begin tables*/

/*Health Equity Tables*/
proc sql;
create table hlth_equity_trav as
select

		intnx("qtr", (EVENT_DATE), 0, "end") as testreportqtr "Quarter Ending Date" format=date11.,

	/*MDRO travel*/
	sum (case when type in ('CRE','CAURIS') and travel in ('Yes') then 1 else 0 end) as sum_travel_y "MDRO in Quarter, Travel: Yes",
	sum (case when type in ('CRE','CAURIS') and travel in ('No') then 1 else 0 end) as sum_travel_n "MDRO in Quarter, Travel: No",
	sum (case when type in ('CRE','CAURIS') and travel in ('Unknown') then 1 else 0 end) as sum_travel_u "MDRO in Quarter, Travel: Unknown",
	sum (case when type in ('CRE','CAURIS') and travel in ('Missing') then 1 else 0 end) as sum_travel_m "MDRO in Quarter, Travel: Missing"


from analysis
	group by testreportqtr 
;
/*healthcare experience is a bit more complex. We want to search across all experiences, so an individual could be in a LTCF but diagnosed in an acute care setting. The result would be grouping in each, ie. people can fall into more than
one bucket for healthcare experience.*/
create table hlth_equity_HCE as
select

		intnx("qtr", (EVENT_DATE), 0, "end") as testreportqtr "Quarter Ending Date" format=date11.,

	/*MDRO healthcare experience*/
	sum (case when hce in ('Acute Care Hospitalization', 'ACUTE_HOSP') then 1 else 0 end) +
	sum (case when hce_0 in ('Acute Care Hospitalization', 'ACUTE_HOSP') then 1 else 0 end) +
	sum (case when hce_1 in ('Acute Care Hospitalization', 'ACUTE_HOSP') then 1 else 0 end) +
	sum (case when hce_2 in ('Acute Care Hospitalization', 'ACUTE_HOSP') then 1 else 0 end) +
	sum (case when hce_3 in ('Acute Care Hospitalization', 'ACUTE_HOSP') then 1 else 0 end) +
	sum (case when hce_4 in ('Acute Care Hospitalization', 'ACUTE_HOSP') then 1 else 0 end) +
	sum (case when hce_5 in ('Acute Care Hospitalization', 'ACUTE_HOSP') then 1 else 0 end) +
	sum (case when hce_6 in ('Acute Care Hospitalization', 'ACUTE_HOSP') then 1 else 0 end) 
		as sum_hce_acute "MDRO in Quarter, HCE: Acute Care Hospital",

	sum (case when hce in ('Long term care facility - resident (e.g. nursing home, rest home, rehab)', 'LTC') then 1 else 0 end) +
	sum (case when hce_0 in ('Long term care facility - resident (e.g. nursing home, rest home, rehab)', 'LTC') then 1 else 0 end) +
	sum (case when hce_1 in ('Long term care facility - resident (e.g. nursing home, rest home, rehab)', 'LTC') then 1 else 0 end) +
	sum (case when hce_2 in ('Long term care facility - resident (e.g. nursing home, rest home, rehab)', 'LTC') then 1 else 0 end) +
	sum (case when hce_3 in ('Long term care facility - resident (e.g. nursing home, rest home, rehab)', 'LTC') then 1 else 0 end) +
	sum (case when hce_4 in ('Long term care facility - resident (e.g. nursing home, rest home, rehab)', 'LTC') then 1 else 0 end) +
	sum (case when hce_5 in ('Long term care facility - resident (e.g. nursing home, rest home, rehab)', 'LTC') then 1 else 0 end) +
	sum (case when hce_6 in ('Long term care facility - resident (e.g. nursing home, rest home, rehab)', 'LTC') then 1 else 0 end) 
		as sum_hce_ltc "MDRO in Quarter, HCE: Long term care facility",


	sum (case when hce in ('No', 'None') then 1 else 0 end) +
	sum (case when hce_0 in ('No', 'None') then 1 else 0 end) +
	sum (case when hce_1 in ('No', 'None') then 1 else 0 end) +
	sum (case when hce_2 in ('No', 'None') then 1 else 0 end) +
	sum (case when hce_3 in ('No', 'None') then 1 else 0 end) +
	sum (case when hce_4 in ('No', 'None') then 1 else 0 end) +
	sum (case when hce_5 in ('No', 'None') then 1 else 0 end) +
	sum (case when hce_6 in ('No', 'None') then 1 else 0 end) 
		as sum_hce_no "MDRO in Quarter, HCE: None",

	sum (case when hce in ('Long term acute care hospital (LTACH)', 'LTACH') then 1 else 0 end) +
	sum (case when hce_0 in ('Long term acute care hospital (LTACH)', 'LTACH') then 1 else 0 end) +
	sum (case when hce_1 in ('Long term acute care hospital (LTACH)', 'LTACH') then 1 else 0 end) +
	sum (case when hce_2 in ('Long term acute care hospital (LTACH)', 'LTACH') then 1 else 0 end) +
	sum (case when hce_3 in ('Long term acute care hospital (LTACH)', 'LTACH') then 1 else 0 end) +
	sum (case when hce_4 in ('Long term acute care hospital (LTACH)', 'LTACH') then 1 else 0 end) +
	sum (case when hce_5 in ('Long term acute care hospital (LTACH)', 'LTACH') then 1 else 0 end) +
	sum (case when hce_6 in ('Long term acute care hospital (LTACH)', 'LTACH') then 1 else 0 end) 
		as sum_hce_ltach "MDRO in Quarter, HCE: Long Term Acute Care Hospital",

	sum (case when hce in ('Surgery (besides oral surgery), obstetrical or invasive procedure', 'Hemodialysis', 'Complex medical devices (e.g. duodenoscopes)', 'HEMODIALYSIS' ,'OTHER_SURGERY') then 1 else 0 end) + 
	sum (case when hce_0 in ('Surgery (besides oral surgery), obstetrical or invasive procedure', 'Hemodialysis', 'Complex medical devices (e.g. duodenoscopes)', 'HEMODIALYSIS' ,'OTHER_SURGERY') then 1 else 0 end) + 
	sum (case when hce_1 in ('Surgery (besides oral surgery), obstetrical or invasive procedure', 'Hemodialysis', 'Complex medical devices (e.g. duodenoscopes)', 'HEMODIALYSIS' ,'OTHER_SURGERY') then 1 else 0 end) + 
	sum (case when hce_2 in ('Surgery (besides oral surgery), obstetrical or invasive procedure', 'Hemodialysis', 'Complex medical devices (e.g. duodenoscopes)', 'HEMODIALYSIS' ,'OTHER_SURGERY') then 1 else 0 end) + 
	sum (case when hce_3 in ('Surgery (besides oral surgery), obstetrical or invasive procedure', 'Hemodialysis', 'Complex medical devices (e.g. duodenoscopes)', 'HEMODIALYSIS' ,'OTHER_SURGERY') then 1 else 0 end) + 
	sum (case when hce_4 in ('Surgery (besides oral surgery), obstetrical or invasive procedure', 'Hemodialysis', 'Complex medical devices (e.g. duodenoscopes)', 'HEMODIALYSIS' ,'OTHER_SURGERY') then 1 else 0 end) + 
	sum (case when hce_5 in ('Surgery (besides oral surgery), obstetrical or invasive procedure', 'Hemodialysis', 'Complex medical devices (e.g. duodenoscopes)', 'HEMODIALYSIS' ,'OTHER_SURGERY') then 1 else 0 end) + 
	sum (case when hce_6 in ('Surgery (besides oral surgery), obstetrical or invasive procedure', 'Hemodialysis', 'Complex medical devices (e.g. duodenoscopes)', 'HEMODIALYSIS' ,'OTHER_SURGERY') then 1 else 0 end) 
		as sum_hce_surg "MDRO in Quarter, HCE: Surgery, Hemodialysis, other procedure(s)",

	sum (case when hce in ('Unknown') then 1 else 0 end) +
	sum (case when hce_0 in ('Unknown') then 1 else 0 end) +
	sum (case when hce_1 in ('Unknown') then 1 else 0 end) +
	sum (case when hce_2 in ('Unknown') then 1 else 0 end) +
	sum (case when hce_3 in ('Unknown') then 1 else 0 end) +
	sum (case when hce_4 in ('Unknown') then 1 else 0 end) +
	sum (case when hce_5 in ('Unknown') then 1 else 0 end) +
	sum (case when hce_6 in ('Unknown') then 1 else 0 end) 
		as sum_hce_unk "MDRO in Quarter, HCE: Unknown",

	sum (case when hce in ('Missing') then 1 else 0 end) +
	sum (case when hce_0 in ('Missing') then 1 else 0 end) +
	sum (case when hce_1 in ('Missing') then 1 else 0 end) +
	sum (case when hce_2 in ('Missing') then 1 else 0 end) +
	sum (case when hce_3 in ('Missing') then 1 else 0 end) +
	sum (case when hce_4 in ('Missing') then 1 else 0 end) +
	sum (case when hce_5 in ('Missing') then 1 else 0 end) +
	sum (case when hce_6 in ('Missing') then 1 else 0 end) 
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




from work.analysis

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

from work.analysis

where EVENT_DATE < "&qtr_dte."d
	group by testreportqtr
;

create table hlth_equity_screen as
select

		intnx("qtr", (EVENT_DATE), 0, "end") as testreportqtr "Quarter Ending Date" format=date11.,

	/*IR per 100k population*/
	sum (case when screening_event in ('Yes') then 1 else 0 end) as screenevnt_y "MDRO ID'd in screening",
	sum (case when screening_event in ('No') then 1 else 0 end) as screenevnt_n "MDRO ID'd in clinical care",
	sum (case when screening_event in ('Mising/Unknown') then 1 else 0 end) as screenevnt_miss "MDRO ID manner unknown/missing"

from work.analysis

where EVENT_DATE < "&qtr_dte."d
	group by testreportqtr
;
quit;

data equity_combine;
merge hlth_equity_density_qt hlth_equity_hosp hlth_equity_HCE hlth_equity_trav hlth_equity_screen
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

	cum_sum_screenevnt_y+screenevnt_y;
	cum_sum_screenevnt_n+screenevnt_n;
	cum_sum_screenevnt_miss+screenevnt_miss;


		
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

		label cum_sum_screenevnt_y="Cumulative MDRO ID'd in screening";
		label cum_sum_screenevnt_n="Cumulative MDRO ID'd in clinical care";
		label cum_sum_screenevnt_miss="Cumulative MDRO ID manner missing/unknown";





run;
/*Now create percentages of cumulative counts as we move through each quarter of our timeframe*/
proc sql;
create table qtr_percent_equity as
select
*,
	testreportqtr,



cum_mdro_rural/(cum_mdro_NONrural+ cum_mdro_rural )as pct_mdro_rural "Cumulative Percent MDRO in Quarter: Rural"format percent10.1,
cum_mdro_NONrural/(cum_mdro_NONrural + cum_mdro_rural )as pct_mdro_NONrural "Cumulative Percent MDRO in Quarter: Non rural"format percent10.1,

	cum_mdro_svi_HI / (cum_mdro_svi_HI + cum_mdro_svi_LO) as pct_mdro_sviHI "Cumulative Percent MDRO in Quarter: HIGH SVI" format percent10.1,
	cum_mdro_svi_LO / (cum_mdro_svi_HI + cum_mdro_svi_LO) as pct_mdro_sviLO "Cumulative Percent MDRO in Quarter: LOW SVI" format percent10.1,

cum_sum_hosp_y/(cum_sum_hosp_y +cum_sum_hosp_n+cum_sum_hosp_unkmiss)as pct_sum_hosp_y "Cumulative Percent MDRO in Quarter: Hospitalized"format percent10.1,
cum_sum_hosp_n/(cum_sum_hosp_y +cum_sum_hosp_n+cum_sum_hosp_unkmiss)as pct_sum_hosp_n "Cumulative Percent MDRO in Quarter: Not hospitalized"format percent10.1,
cum_sum_hosp_unkmiss/(cum_sum_hosp_y +cum_sum_hosp_n+cum_sum_hosp_unkmiss)as pct_sum_hosp_unkmiss "Cumulative Percent MDRO in Quarter: Unknown hospitalization status"format percent10.1,
cum_sum_hce_acute/(cum_sum_hce_acute+cum_sum_hce_ltc+cum_sum_hce_no+cum_sum_hce_ltach+cum_sum_hce_surg+cum_sum_hce_unk+cum_sum_hce_miss)as pct_sum_hce_acute "Cumulative Percent MDRO in Quarter: HCE Acute Care"format percent10.1,
cum_sum_hce_ltc/(cum_sum_hce_acute+cum_sum_hce_ltc+cum_sum_hce_no+cum_sum_hce_ltach+cum_sum_hce_surg+cum_sum_hce_unk+cum_sum_hce_miss)as pct_sum_hce_ltc "Cumulative Percent MDRO in Quarter: HCE Longterm Care"format percent10.1,
cum_sum_hce_no/(cum_sum_hce_acute+cum_sum_hce_ltc+cum_sum_hce_no+cum_sum_hce_ltach+cum_sum_hce_surg+cum_sum_hce_unk+cum_sum_hce_miss)as pct_sum_hce_no "Cumulative Percent MDRO in Quarter: HCE None"format percent10.1,
cum_sum_hce_ltach/(cum_sum_hce_acute+cum_sum_hce_ltc+cum_sum_hce_no+cum_sum_hce_ltach+cum_sum_hce_surg+cum_sum_hce_unk+cum_sum_hce_miss)as pct_sum_hce_ltach "Cumulative Percent MDRO in Quarter: HCE Longterm Acute Care"format percent10.1,
cum_sum_hce_surg/(cum_sum_hce_acute+cum_sum_hce_ltc+cum_sum_hce_no+cum_sum_hce_ltach+cum_sum_hce_surg+cum_sum_hce_unk+cum_sum_hce_miss)as pct_sum_cum_sum_hce_surg "Cumulative Percent MDRO in Quarter: HCE Surgery/Invasive Procedure"format percent10.1,
cum_sum_hce_unk/(cum_sum_hce_acute+cum_sum_hce_ltc+cum_sum_hce_no+cum_sum_hce_ltach+cum_sum_hce_surg+cum_sum_hce_unk+cum_sum_hce_miss)as pct_sum_cum_sum_hce_unk "Cumulative Percent MDRO in Quarter: HCE Unknown"format percent10.1,
cum_sum_hce_miss/(cum_sum_hce_acute+cum_sum_hce_ltc+cum_sum_hce_no+cum_sum_hce_ltach+cum_sum_hce_surg+cum_sum_hce_unk+cum_sum_hce_miss)as pct_sum_cum_sum_hce_miss "Cumulative Percent MDRO in Quarter: HCE Missing"format percent10.1,
cum_sum_travel_y/(cum_sum_travel_y+cum_sum_travel_n+cum_sum_travel_u+cum_sum_travel_m)as pct_sum_cum_sum_travel_y "Cumulative Percent MDRO in Quarter: History of travel"format percent10.1,
cum_sum_travel_n/(cum_sum_travel_y+cum_sum_travel_n+cum_sum_travel_u+cum_sum_travel_m)as pct_sum_cum_sum_travel_n "Cumulative Percent MDRO in Quarter: No history of travel"format percent10.1,
cum_sum_travel_u/(cum_sum_travel_y+cum_sum_travel_n+cum_sum_travel_u+cum_sum_travel_m)as pct_sum_cum_sum_travel_u "Cumulative Percent MDRO in Quarter: Unknown history of travel"format percent10.1,
cum_sum_travel_m/(cum_sum_travel_y+cum_sum_travel_n+cum_sum_travel_u+cum_sum_travel_m)as pct_sum_cum_sum_travel_m "Cumulative Percent MDRO in Quarter: Missing history of travel"format percent10.1,
cum_sum_screenevnt_y/(cum_sum_screenevnt_y+cum_sum_screenevnt_n+cum_sum_screenevnt_miss)as pct_sum_screen_y "Cumulative Percent MDRO in Quarter: ID'd in screening" format percent10.1,
cum_sum_screenevnt_n/(cum_sum_screenevnt_y+cum_sum_screenevnt_n+cum_sum_screenevnt_miss)as pct_sum_screen_n "Cumulative Percent MDRO in Quarter: ID'd in clinical care" format percent10.1,
cum_sum_screenevnt_miss/(cum_sum_screenevnt_y+cum_sum_screenevnt_n+cum_sum_screenevnt_miss)as pct_sum_screen_miss "Cumulative Percent MDRO in Quarter: manner of ID unknown/missing" format percent10.1



from equity_combine_cum
;
quit;



/*Now tables for race, eth, gender, and age*/


data records;
set SASdata.recordssas;

run;


proc sql;
create table disease_sum as
select *,


	intnx("qtr", (EVENT_DATE), 0, "end") as testreportqtr "Quarter Ending Date" format=date11.,
	intnx("qtr", (symptom_onset_date), 0, "end") as testreportqtr_symptom "Quarter Ending Date for symptom onset" format=date11.,
	intnx("month", (EVENT_DATE), 0, "end") as testreportmonth "Month Ending Date" format=date11.,

	(EVENT_DATE) as most_recent_case 


from records

;



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
	sum (case when type in ('CAURIS') then 1 else 0 end) as c_auris "C. auris in Quarter"


from records
group by testreportqtr
;


create table disease_counts_class as /*we'll use this for coding yearly counts and cumulative counts*/
select

	testreportqtr "Quarter Ending Date" format=date11.,
	CP_CRE,
	c_auris


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


run;
/*Race*/
proc sql;
create table disease_counts_qtr_race as
select

	intnx("qtr", (EVENT_DATE), 0, "end") as testreportqtr "Quarter Ending Date" format=date11.,

/*CRE by race*/
	sum (case when type in ('CRE') and RACE1 in ('White') then 1 else 0 end) as CRE_w "CRE in Quarter, Race: White",
	/*calculated CRE_w / 183 as pct_CRE_w "Percent of cumulative total CRE, Race: White" format percent10.2,*/

	sum (case when type in ('CRE') and RACE1 in ('Black or African American') then 1 else 0 end) as CRE_b "CRE in Quarter, Race: Black or African American",
	sum (case when type in ('CRE') and RACE1 in ('Asian') then 1 else 0 end) as CRE_a "CRE in Quarter, Race: Asian",
	sum (case when type in ('CRE') and RACE1 in ('Native Hawaiian or Pacific Islander') then 1 else 0 end) as CRE_nhpi "CRE in Quarter, Race: Native Hawaiian or Pacific Islander",
	sum (case when type in ('CRE') and RACE1 in ('Other') then 1 else 0 end) as CRE_oth "CRE in Quarter, Race: Other",
	sum (case when type in ('CRE') and RACE1 in ('Unknown') then 1 else 0 end) as CRE_unk "CRE in Quarter, Race: Unknown",
	sum (case when type in ('CRE') and RACE1 in ('American Indian Alaskan Native') then 1 else 0 end) as CRE_aian "CRE in Quarter, Race: American Indian Alaskan Native",
	sum (case when type in ('CRE') and RACE1 in (' ') then 1 else 0 end) as CRE_miss "CRE in Quarter, Race: Missing",

/*C. auris by race*/
	sum (case when type in ('CAURIS') and RACE1 in ('White') then 1 else 0 end) as c_auris_w "C. auris in Quarter, Race: White",
	sum (case when type in ('CAURIS') and RACE1 in ('Black or African American') then 1 else 0 end) as c_auris_b "C. auris in Quarter, Race: Black or African American",
	sum (case when type in ('CAURIS') and RACE1 in ('Asian') then 1 else 0 end) as c_auris_a "C. auris in Quarter, Race: Asian",
	sum (case when type in ('CAURIS') and RACE1 in ('Native Hawaiian or Pacific Islander') then 1 else 0 end) as c_auris_nhpi "C. auris in Quarter, Race: Native Hawaiian or Pacific Islander",
	sum (case when type in ('CAURIS') and RACE1 in ('Other') then 1 else 0 end) as c_auris_oth "C. auris in Quarter, Race: Other",
	sum (case when type in ('CAURIS') and RACE1 in ('Unknown') then 1 else 0 end) as c_auris_unk "C. auris in Quarter, Race: Unknown",
	sum (case when type in ('CAURIS') and RACE1 in ('American Indian Alaskan Native') then 1 else 0 end) as c_auris_aian "C. auris in Quarter, Race: American Indian Alaskan Native",
	sum (case when type in ('CAURIS') and RACE1 in (' ') then 1 else 0 end) as c_auris_miss "C. auris in Quarter, Race: Missing"

from records
group by testreportqtr
;

/*Ethnicity*/
create table disease_counts_qtr_eth as
select

	intnx("qtr", (EVENT_DATE), 0, "end") as testreportqtr "Quarter Ending Date" format=date11.,

	/*CRE by Ethnicity*/
	sum (case when type in ('CRE') and Hispanic in ('Yes') then 1 else 0 end) as CP_CRE_hisp "CRE in Quarter: Hispanic",
	sum (case when type in ('CRE') and Hispanic in ('No') then 1 else 0 end) as CP_CRE_nohisp "CRE in Quarter: Not Hispanic",
	sum (case when type in ('CRE') and Hispanic in ('Unknown') then 1 else 0 end) as CP_CRE_unkhisp "CRE in Quarter: Unknown Hispanic",
	sum (case when type in ('CRE') and Hispanic in (' ') then 1 else 0 end) as CP_CRE_misshisp "CRE in Quarter: Missing Hispanic",

	/*C. auris by Ethnicity*/
	sum (case when type in ('CAURIS') and Hispanic in ('Yes') then 1 else 0 end) as c_auris_hisp "C. auris in Quarter: Hispanic",
	sum (case when type in ('CAURIS') and Hispanic in ('No') then 1 else 0 end) as c_auris_nohisp "C. auris in Quarter: Not Hispanic",
	sum (case when type in ('CAURIS') and Hispanic in ('Unknown') then 1 else 0 end) as c_auris_unkhisp "C. auris in Quarter: Unknown Hispanic",
	sum (case when type in ('CAURIS') and Hispanic in (' ') then 1 else 0 end) as c_auris_mishisp "C. auris in Quarter: Missing Hispanic"

from records
group by testreportqtr 
;
/*Gender*/
create table disease_counts_qtr_gender as
select

	intnx("qtr", (EVENT_DATE), 0, "end") as testreportqtr "Quarter Ending Date" format=date11.,

	/*CRE by Gender*/
	sum (case when type in ('CRE') and Gender in ('Male') then 1 else 0 end) as CP_CRE_male "CRE in Quarter: Male",
	sum (case when type in ('CRE') and Gender in ('Female') then 1 else 0 end) as CP_CRE_female "CRE in Quarter: Female",
	sum (case when type in ('CRE') and Gender in (' ') then 1 else 0 end) as CP_CRE_sexmiss "CRE in Quarter: Missing",

	/*C. auris by Gender*/
	sum (case when type in ('CAURIS') and Gender in ('Male') then 1 else 0 end) as c_auris_male "C. auris in Quarter: Male",
	sum (case when type in ('CAURIS') and Gender in ('Female') then 1 else 0 end) as c_auris_female "C. auris in Quarter: Female",
	sum (case when type in ('CAURIS') and Gender in (' ') then 1 else 0 end) as c_auris_sexmiss "C. auris in Quarter: Missing Gender"

from records
group by testreportqtr 
;
/*Age group*/
create table disease_counts_qtr_age as
select

	intnx("qtr", (EVENT_DATE), 0, "end") as testreportqtr "Quarter Ending Date" format=date11.,


	/*CRE by Age Group*/
	sum(case when type in ('CRE') and 0 LE age LT 5 then 1 else 0 end) as CRE_04 label='CRE in Quarter: Age 0-4',
	sum(case when type in ('CRE') and 5 LE age LT 18 then 1 else 0 end) as CRE_0517 label='CRE in Quarter: Age 5-17',
	sum(case when type in ('CRE') and 18 LE age LT 25 then 1 else 0 end) as CRE_1824 label='CRE in Quarter: Age 18-24',
	sum(case when type in ('CRE') and 25 LE age LT 50 then 1 else 0 end) as CRE_2549 label='CRE in Quarter: Age 25-49',
	sum(case when type in ('CRE') and 50 LE age LT 65 then 1 else 0 end) as CRE_5064 label='CRE in Quarter: Age 50-64',
	sum(case when type in ('CRE') and age GE 65 then 1 else 0 end) as CRE_65 label='CRE in Quarter: Age 65+',

	/*C. auris by Age Group*/
	sum(case when type in ('CAURIS') and 0 LE age LT 5 then 1 else 0 end) as CAURIS_04 label='C. auris in Quarter: Age 0-4',
	sum(case when type in ('CAURIS') and 5 LE age LT 18 then 1 else 0 end) as CAURIS_0517 label='C. auris in Quarter: Age 5-17',
	sum(case when type in ('CAURIS') and 18 LE age LT 25 then 1 else 0 end) as CAURIS_1824 label='C. auris in Quarter: Age 18-24',
	sum(case when type in ('CAURIS') and 25 LE age LT 50 then 1 else 0 end) as CAURIS_2549 label='C. auris in Quarter: Age 25-49',
	sum(case when type in ('CAURIS') and 50 LE age LT 65 then 1 else 0 end) as CAURIS_5064 label='C. auris in Quarter: Age 50-64',
	sum(case when type in ('CAURIS') and age GE 65 then 1 else 0 end) as CAURIS_65 label='C. auris in Quarter: Age 65+'
from records

group by testreportqtr 
;



quit;

/*Merge all datasets and confine to dates we want to look at by qtr*/

data test_combine;
merge disease_counts_qtr_cum disease_counts_qtr_race disease_counts_qtr_eth disease_counts_qtr_gender disease_counts_qtr_age;
	by testreportqtr;
	where testreportqtr <= "&qtr_dte."d; *<----- set date parameters here, it can mess up cumulative counts if you do it later on;
run;


/*make all of our cumulative values*/
data combine_cum_demo;
set test_combine;

	cum_CRE_w+CRE_w;
	cum_CRE_b+CRE_b;
	cum_CRE_a+CRE_a;
	cum_CRE_nhpi+CRE_nhpi;
	cum_CRE_oth+CRE_oth;
	cum_CRE_unk+CRE_unk;
	cum_CRE_aian+CRE_aian;
	cum_CRE_miss+CRE_miss;
	cum_c_auris_w+c_auris_w;
	cum_c_auris_b+c_auris_b;
	cum_c_auris_a+c_auris_a;
	cum_c_auris_nhpi+c_auris_nhpi;
	cum_c_auris_oth+c_auris_oth;
	cum_c_auris_unk+c_auris_unk;
	cum_c_auris_aian+c_auris_aian;
	cum_c_auris_miss+c_auris_miss;
	cum_CP_CRE_hisp+CP_CRE_hisp;
	cum_CP_CRE_nohisp+CP_CRE_nohisp;
	cum_CP_CRE_unkhisp+CP_CRE_unkhisp;
	cum_CP_CRE_misshisp+CP_CRE_misshisp;
	cum_c_auris_hisp+c_auris_hisp;
	cum_c_auris_nohisp+c_auris_nohisp;
	cum_c_auris_unkhisp+c_auris_unkhisp;
	cum_c_auris_mishisp+c_auris_mishisp;
	cum_CP_CRE_male+CP_CRE_male;
	cum_CP_CRE_female+CP_CRE_female;
	cum_CP_CRE_sexmiss+CP_CRE_sexmiss;
	cum_c_auris_male+c_auris_male;
	cum_c_auris_female+c_auris_female;
	cum_c_auris_sexmiss+c_auris_sexmiss;
	cum_CRE_04+CRE_04;
	cum_CRE_0517+CRE_0517;
	cum_CRE_1824+CRE_1824;
	cum_CRE_2549+CRE_2549;
	cum_CRE_5064+CRE_5064;
	cum_CRE_65+CRE_65;
	cum_CAURIS_04+CAURIS_04;
	cum_CAURIS_0517+CAURIS_0517;
	cum_CAURIS_1824+CAURIS_1824;
	cum_CAURIS_2549+CAURIS_2549;
	cum_CAURIS_5064+CAURIS_5064;
	cum_CAURIS_65+CAURIS_65;

		label cum_CRE_w="Cumulative CRE in Quarter, Race: White";
		label cum_CRE_b="Cumulative CRE in Quarter, Race: Black or African American";
		label cum_CRE_a="Cumulative CRE in Quarter, Race: Asian";
		label cum_CRE_nhpi="Cumulative CRE in Quarter, Race: Native Hawaiian or Pacific Islander";
		label cum_CRE_oth="Cumulative CRE in Quarter, Race: Other";
		label cum_CRE_unk="Cumulative CRE in Quarter, Race: Unknown";
		label cum_CRE_aian="Cumulative CRE in Quarter, Race: American Indian Alaskan Native";
		label cum_CRE_miss="Cumulative CRE in Quarter, Race: Missing";
		label cum_c_auris_w="Cumulative C. auris in Quarter, Race: White";
		label cum_c_auris_b="Cumulative C. auris in Quarter, Race: Black or African American";
		label cum_c_auris_a="Cumulative C. auris in Quarter, Race: Asian";
		label cum_c_auris_nhpi="Cumulative C. auris in Quarter, Race: Native Hawaiian or Pacific Islander";
		label cum_c_auris_oth="Cumulative C. auris in Quarter, Race: Other";
		label cum_c_auris_unk="Cumulative C. auris in Quarter, Race: Unknown";
		label cum_c_auris_aian="Cumulative C. auris in Quarter, Race: American Indian Alaskan Native";
		label cum_c_auris_miss="Cumulative C. auris in Quarter, Race: Missing";
		label cum_CP_CRE_hisp="Cumulative CRE in Quarter: Hispanic";
		label cum_CP_CRE_nohisp="Cumulative CRE in Quarter: Not Hispanic";
		label cum_CP_CRE_unkhisp="Cumulative CRE in Quarter: Unknown Hispanic";
		label cum_CP_CRE_misshisp="Cumulative CRE in Quarter: Missing Hispanic";
		label cum_c_auris_hisp="Cumulative C. auris in Quarter: Hispanic";
		label cum_c_auris_nohisp="Cumulative C. auris in Quarter: Not Hispanic";
		label cum_c_auris_unkhisp="Cumulative C. auris in Quarter: Unknown Hispanic";
		label cum_c_auris_mishisp="Cumulative C. auris in Quarter: Missing Hispanic";
		label cum_CP_CRE_male="Cumulative CRE in Quarter: Male";
		label cum_CP_CRE_female="Cumulative CRE in Quarter: Female";
		label cum_CP_CRE_sexmiss="Cumulative CRE in Quarter: Missing";
		label cum_c_auris_male="Cumulative C. auris in Quarter: Male";
		label cum_c_auris_female="Cumulative C. auris in Quarter: Female";
		label cum_c_auris_sexmiss="Cumulative C. auris in Quarter: Missing Gender";
		label cum_CRE_04="Cumulative CRE in Quarter: Age 0-4";
		label cum_CRE_0517="Cumulative CRE in Quarter: Age 5-17";
		label cum_CRE_1824="Cumulative CRE in Quarter: Age 18-24";
		label cum_CRE_2549="Cumulative CRE in Quarter: Age 25-49";
		label cum_CRE_5064="Cumulative CRE in Quarter: Age 50-64";
		label cum_CRE_65="Cumulative CRE in Quarter: Age 65+";
		label cum_CAURIS_04="Cumulative C. auris in Quarter: Age 0-4";
		label cum_CAURIS_0517="Cumulative C. auris in Quarter: Age 5-17";
		label cum_CAURIS_1824="Cumulative C. auris in Quarter: Age 18-24";
		label cum_CAURIS_2549="Cumulative C. auris in Quarter: Age 25-49";
		label cum_CAURIS_5064="Cumulative C. auris in Quarter: Age 50-64";
		label cum_CAURIS_65="Cumulative C. auris in Quarter: Age 65+";



run;


/*Now create percentages of cumulative counts as we move through each quarter of our timeframe*/
proc sql;
create table combine_qtr_percent as
select

	testreportqtr,
	cum_CRE_w / cum_CP_CRE as pct_cum_CRE_w "Cumulative Percent CRE in Quarter, Race: White" format percent10.1 ,
	cum_CRE_b / cum_CP_CRE as pct_cum_CRE_b "Cumulative Percent CRE in Quarter, Race: Black or African American" format percent10.1 ,
	cum_CRE_a / cum_CP_CRE as pct_cum_CRE_a "Cumulative Percent CRE in Quarter, Race: Asian" format percent10.1 ,
	cum_CRE_nhpi / cum_CP_CRE as pct_cum_CRE_nhpi "Cumulative Percent CRE in Quarter, Race: Native Hawaiian or Pacific Islander" format percent10.1 ,
	cum_CRE_oth / cum_CP_CRE as pct_cum_CRE_oth "Cumulative Percent CRE in Quarter, Race: Other" format percent10.1 ,
	cum_CRE_unk / cum_CP_CRE as pct_cum_CRE_unk "Cumulative Percent CRE in Quarter, Race: Unknown" format percent10.1 ,
	cum_CRE_aian / cum_CP_CRE as pct_cum_CRE_aian "Cumulative Percent CRE in Quarter, Race: American Indian Alaskan Native" format percent10.1 ,
	cum_CRE_miss / cum_CP_CRE as pct_cum_CRE_miss "Cumulative Percent CRE in Quarter, Race: Missing" format percent10.1 ,
	cum_c_auris_w / cum_CAURIS as pct_cum_c_auris_w "Cumulative Percent C. auris in Quarter, Race: White" format percent10.1 ,
	cum_c_auris_b / cum_CAURIS as pct_cum_c_auris_b "Cumulative Percent C. auris in Quarter, Race: Black or African American" format percent10.1 ,
	cum_c_auris_a / cum_CAURIS as pct_cum_c_auris_a "Cumulative Percent C. auris in Quarter, Race: Asian" format percent10.1 ,
	cum_c_auris_nhpi / cum_CAURIS as pct_cum_c_auris_nhpi "Cumulative Percent C. auris in Quarter, Race: Native Hawaiian or Pacific Islander" format percent10.1 ,
	cum_c_auris_oth / cum_CAURIS as pct_cum_c_auris_oth "Cumulative Percent C. auris in Quarter, Race: Other" format percent10.1 ,
	cum_c_auris_unk / cum_CAURIS as pct_cum_c_auris_unk "Cumulative Percent C. auris in Quarter, Race: Unknown" format percent10.1 ,
	cum_c_auris_aian / cum_CAURIS as pct_cum_c_auris_aian "Cumulative Percent C. auris in Quarter, Race: American Indian Alaskan Native" format percent10.1 ,
	cum_c_auris_miss / cum_CAURIS as pct_cum_c_auris_miss "Cumulative Percent C. auris in Quarter, Race: Missing" format percent10.1 ,
	cum_CP_CRE_hisp / cum_CP_CRE as pct_cum_CP_CRE_hisp "Cumulative Percent CRE in Quarter: Hispanic" format percent10.1 ,
	cum_CP_CRE_nohisp / cum_CP_CRE as pct_cum_CP_CRE_nohisp "Cumulative Percent CRE in Quarter: Not Hispanic" format percent10.1 ,
	cum_CP_CRE_unkhisp / cum_CP_CRE as pct_cum_CP_CRE_unkhisp "Cumulative Percent CRE in Quarter: Unknown Hispanic" format percent10.1 ,
	cum_CP_CRE_misshisp / cum_CP_CRE as pct_cum_CP_CRE_misshisp "Cumulative Percent CRE in Quarter: Missing Hispanic" format percent10.1 ,
	cum_c_auris_hisp / cum_CAURIS as pct_cum_c_auris_hisp "Cumulative Percent C. auris in Quarter: Hispanic" format percent10.1 ,
	cum_c_auris_nohisp / cum_CAURIS as pct_cum_c_auris_nohisp "Cumulative Percent C. auris in Quarter: Not Hispanic" format percent10.1 ,
	cum_c_auris_unkhisp / cum_CAURIS as pct_cum_c_auris_unkhisp "Cumulative Percent C. auris in Quarter: Unknown Hispanic" format percent10.1 ,
	cum_c_auris_mishisp / cum_CAURIS as pct_cum_c_auris_mishisp "Cumulative Percent C. auris in Quarter: Missing Hispanic" format percent10.1 ,
	cum_CP_CRE_male / cum_CP_CRE as pct_cum_CP_CRE_male "Cumulative Percent CRE in Quarter: Male" format percent10.1 ,
	cum_CP_CRE_female / cum_CP_CRE as pct_cum_CP_CRE_female "Cumulative Percent CRE in Quarter: Female" format percent10.1 ,
	cum_CP_CRE_sexmiss / cum_CP_CRE as pct_cum_CP_CRE_sexmiss "Cumulative Percent CRE in Quarter: Missing" format percent10.1 ,
	cum_c_auris_male / cum_CAURIS as pct_cum_c_auris_male "Cumulative Percent C. auris in Quarter: Male" format percent10.1 ,
	cum_c_auris_female / cum_CAURIS as pct_cum_c_auris_female "Cumulative Percent C. auris in Quarter: Female" format percent10.1 ,
	cum_c_auris_sexmiss / cum_CAURIS as pct_cum_c_auris_sexmiss "Cumulative Percent C. auris in Quarter: Missing Gender" format percent10.1 ,
	cum_CRE_04 / cum_CP_CRE as pct_cum_CRE_04 "Cumulative Percent CRE in Quarter: Age 0-4" format percent10.1 ,
	cum_CRE_0517 / cum_CP_CRE as pct_cum_CRE_0517 "Cumulative Percent CRE in Quarter: Age 5-17" format percent10.1 ,
	cum_CRE_1824 / cum_CP_CRE as pct_cum_CRE_1824 "Cumulative Percent CRE in Quarter: Age 18-24" format percent10.1 ,
	cum_CRE_2549 / cum_CP_CRE as pct_cum_CRE_2549 "Cumulative Percent CRE in Quarter: Age 25-49" format percent10.1 ,
	cum_CRE_5064 / cum_CP_CRE as pct_cum_CRE_5064 "Cumulative Percent CRE in Quarter: Age 50-64" format percent10.1 ,
	cum_CRE_65 / cum_CP_CRE as pct_cum_CRE_65 "Cumulative Percent CRE in Quarter: Age 65+" format percent10.1 ,
	cum_CAURIS_04 / cum_CAURIS as pct_cum_CAURIS_04 "Cumulative Percent C. auris in Quarter: Age 0-4" format percent10.1 ,
	cum_CAURIS_0517 / cum_CAURIS as pct_cum_CAURIS_0517 "Cumulative Percent C. auris in Quarter: Age 5-17" format percent10.1 ,
	cum_CAURIS_1824 / cum_CAURIS as pct_cum_CAURIS_1824 "Cumulative Percent C. auris in Quarter: Age 18-24" format percent10.1 ,
	cum_CAURIS_2549 / cum_CAURIS as pct_cum_CAURIS_2549 "Cumulative Percent C. auris in Quarter: Age 25-49" format percent10.1 ,
	cum_CAURIS_5064 / cum_CAURIS as pct_cum_CAURIS_5064 "Cumulative Percent C. auris in Quarter: Age 50-64" format percent10.1 ,
	cum_CAURIS_65 / cum_CAURIS as pct_cum_CAURIS_65 "Cumulative Percent C. auris in Quarter: Age 65+" format percent10.1 



from combine_cum_demo
	where testreportqtr <= "&qtr_dte."d
	order by testreportqtr

;
quit;



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
set disease_sum;


length label_eth $12.;
length label_eth_2 $12.;

	if type in ("STRA") then delete;

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


run;





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
								sum_hce_surg sum_hce_unk sum_hce_miss sum_travel_y sum_travel_n sum_travel_u sum_travel_m screenevnt_y 
								mdro_sviLO_IR screenevnt_n screenevnt_miss);
run;

proc transpose data=transpose_prep out=equity_transpose;
    id testreportqtr;
	format &qtr_end_transpose 10.0;

run;


data transpose_prep_pcts;
set qtr_percent_equity (drop =  mdro_rural  mdro_NONrural sum_hosp_y sum_hosp_n sum_hosp_unkmiss sum_hce_acute sum_hce_ltc sum_hce_no sum_hce_ltach sum_hce_surg sum_hce_unk mdro_svi_LO mdro_svi_HI
								sum_hce_miss sum_travel_y sum_travel_n sum_travel_u sum_travel_m screenevnt_y screenevnt_n screenevnt_miss cum_mdro_rural cum_mdro_NONrural mdro_NONrural_IR 
								mdro_rural_IR cum_sum_hosp_y cum_sum_hosp_n cum_sum_hosp_unkmiss cum_sum_hce_acute cum_sum_hce_ltc cum_sum_hce_no cum_sum_hce_ltach cum_sum_hce_surg cum_sum_hce_unk cum_sum_hce_miss 
								cum_sum_travel_y cum_sum_travel_n cum_sum_travel_u cum_sum_travel_m cum_sum_screenevnt_y cum_sum_screenevnt_n cum_sum_screenevnt_miss cum_mdro_svi_LO cum_mdro_svi_HI mdro_sviHI_IR mdro_sviLO_IR);

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

%INCLUDE "T:\HAI\Code library\Epi curve example\SAS Codes\MDRO_IR_quarterly.sas";


proc transpose data=combine_qtr_IR out=demo_transpose_IR;
    id testreportqtr;
	format &qtr_end_transpose 10.3;

run;

data transpose_prep_demo;
set combine_cum_demo (drop = CP_CRE c_auris cum_CP_CRE cum_CAURIS CRE_w CRE_b CRE_a CRE_nhpi CRE_oth CRE_unk CRE_aian CRE_miss c_auris_w c_auris_b c_auris_a c_auris_nhpi
							 c_auris_oth c_auris_unk c_auris_aian c_auris_miss CP_CRE_hisp CP_CRE_nohisp CP_CRE_unkhisp CP_CRE_misshisp c_auris_hisp c_auris_nohisp c_auris_unkhisp
							 c_auris_mishisp CP_CRE_male CP_CRE_female CP_CRE_sexmiss c_auris_male CRE_2549 CRE_5064 c_auris_female c_auris_sexmiss CRE_04 CRE_0517 CRE_1824
							 CRE_65 CAURIS_04 CAURIS_0517 CAURIS_1824 CAURIS_2549 CAURIS_5064 CAURIS_65);
run;

proc transpose data=transpose_prep_demo out=demo_transpose;
	id testreportqtr;

run;


proc sql;
create table demo_transpose_final as
select 

	_LABEL_ as risk_factor 'Demographic Classification',
	&qtr_end_transpose as &qtr_num "&qtr_num. Count"

from demo_transpose;


create table demo_transpose_IR_final as
select

	_LABEL_ as demographic 'Demographic Classification',
	&qtr_end_transpose as &qtr_num "&qtr_num. IR/100k"


from demo_transpose_IR 
;
quit;

/*Export transposed tables to create template tables here. No need to save datasets at this point*/

title; footnote;
/*Set your output pathway here*/
ods excel file="C:\Users\mhoskins1\Desktop\Work Files\MDRO_Tables.xlsx";*<----- Named a generic overwriteable name so we can continue to reproduce and autopopulate a template;


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

ods excel close;


/*Export tables as data sets for next steps*/
data SASdata.final_combined_mechanism;
set final_combined_mechanism;
run;

data SASdata.final_combined_race;
set final_combined_race;
run;

data SASdata.final_combined_eth;
set final_combined_eth;
run;

data SASdata.final_combined_gender;
set final_combined_gender;
run;

data SASdata.final_combined_age;
set final_combined_age;
run;

/*Equity*/
data SASdata.equity_final_pcts;
set equity_final_pcts;
run;


/*Totals*/

data SASdata.disease_sum;
set disease_sum;
run;

data SASdata.county_sum;
set county_sum;
run;

/*Plots*/

/*Demographic*/
data SASdata.plots ;
set plots;
run;

data SASdata.equity_plots;
set equity_plots;
run;

/*Equity*/

data SASdata.equity_final_pcts ;
set equity_final_pcts;
run;

data SASdata.hlth_equity_density_month_2 ;
set hlth_equity_density_month_2;
run;



/*Last thing:*/
/*Autorun the bar graph macro*/
%include "T:\HAI\Code library\Epi curve example\SAS Codes\MDRO_quarterly report_bar graph macro.sas";



/*Done!*/


