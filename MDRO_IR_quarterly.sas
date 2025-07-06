
/*Demographic Incidence Rates for MDRO Quarterly Report:

As long as the cumulative data points stay the same we can use this and adjust denominator or age adjustments as necessary.


*/

proc print data=combine_cum_demo;run;
/*Now create IF of cumulative counts as we move through each quarter of our timeframe*/
proc sql;
create table combine_qtr_IR as
select

	testreportqtr,
/*MDRO Specific*/
	((cum_CRE /&state_pop) *100000) as IR_cum_CRE "Cumulative IR CRE in Quarter" format=10.2,
	((cum_c_auris /&state_pop) *100000) as IR_cum_Cauris "Cumulative IR C.auris in Quarter" format=10.2,

/*IR Race*/
	((cum_MDRO_w / &white_pop) * 100000) as IR_cum_MDRO_w "Cumulative IR MDRO in Quarter, Race: White" format=10.2 ,
	((cum_MDRO_b / &blackaa_pop) * 100000)  as IR_cum_MDRO_b "Cumulative IR MDRO in Quarter, Race: Black or African American" format=10.2,
	((cum_MDRO_a / &asian_pop) * 100000)  as IR_cum_MDRO_a "Cumulative IR MDRO in Quarter, Race: Asian" format=10.2,
	((cum_MDRO_nhpi / &napi_pop) * 100000)  as IR_cum_MDRO_nhpi "Cumulative IR MDRO in Quarter, Race: Native Hawaiian or Pacific Islander" format=10.2,
	((cum_MDRO_oth / &other_race_pop) * 100000)  as IR_cum_MDRO_oth "Cumulative IR MDRO in Quarter, Race: Other" format=10.2,
	((cum_MDRO_unk / &state_pop) * 100000)  as IR_cum_MDRO_unk "Cumulative IR MDRO in Quarter, Race: Unknown" format=10.2,
	((cum_MDRO_aian / &aian_pop) * 100000)  as IR_cum_MDRO_aian "Cumulative IR MDRO in Quarter, Race: American Indian Alaskan Native" format=10.2,
	((cum_MDRO_miss / &state_pop) * 100000)  as IR_cum_MDRO_miss "Cumulative IR MDRO in Quarter, Race: Missing" format=10.2,

/*IR Hispanic ethnicity*/
	((cum_MDRO_hisp / &hisp_yes) * 100000) as IR_cum_MDRO_hisp "Cumulative IR CRE in Quarter: Hispanic" format=10.2,
	((cum_MDRO_nohisp / &hisp_no) * 100000) as IR_cum_MDRO_nohisp "Cumulative IR CRE in Quarter: Not Hispanic" format=10.2,
	((cum_MDRO_unkhisp / &state_pop) * 100000) as IR_cum_MDRO_unkhisp "Cumulative IR CRE in Quarter: Unknown Hispanic" format=10.2,
	((cum_MDRO_misshisp / &state_pop) * 100000) as IR_cum_MDRO_misshisp "Cumulative IR CRE in Quarter: Missing Hispanic" format=10.2,


/*IR Gender*/
	((cum_MDRO_male / &male_pop) * 100000) as IR_cum_MDRO_male "Cumulative IR CRE in Quarter: Male" format=10.2,
	((cum_MDRO_female / &female_pop) * 100000) as IR_cum_MDRO_female "Cumulative IR CRE in Quarter: Female" format=10.2,
	((cum_MDRO_sexmiss / &state_pop) * 100000) as IR_cum_MDRO_sexmiss "Cumulative IR CRE in Quarter: Missing" format=10.2,


/*IR Age*/
	((cum_MDRO_04 / &age_04) * 100000) as IR_MDROE_04 "Cumulative IR CRE in Quarter: Age 0-4" format=10.2,
	((cum_MDRO_0517 / &age_0517) * 100000) as IR_cMDRO_0517 "Cumulative IR CRE in Quarter: Age 5-17" format=10.2,
	((cum_MDRO_1824 / &age_1824) * 100000) as IR_MDRO_1824 "Cumulative IR CRE in Quarter: Age 18-24" format=10.2,
	((cum_MDRO_2549 / &age_2549) * 100000) as IR_MDRO_2549 "Cumulative IR CRE in Quarter: Age 25-49" format=10.2,
	((cum_MDRO_5064 / &age_5064) * 100000) as IR_MDRO_5064 "Cumulative IR CRE in Quarter: Age 50-64" format=10.2,
	((cum_MDRO_65 / &age_65) * 100000) as IR_MDRO_65 "Cumulative IR CRE in Quarter: Age 65+" format=10.2


from combine_cum_demo
	where testreportqtr <= "&qtr_dte."d
	order by testreportqtr

;
quit;

proc sql;
create table equity_race as
select *,

	case when density in (0) then 1 else 0 end as mdro_rural "MDRO Rural Residency in quarter",
	case when density in (1,2) then 1 else 0 end as mdro_NONrural "MDRO non-Rural Residency in quarter"

from analysis
	where event_date < "&qtr_dte."d 
;

create table equity_race_counts as
select

	/*Totals*/
	sum (case when mdro_rural in (1) then 1 else 0 end) as rural_sum "MDRO Rural Residency",
	sum (case when mdro_NONrural in (1) then 1 else 0 end) as nonrural_sum "MDRO Non-Rural Residency",
	/*Rurality residency by race*/
	sum (case when mdro_rural in (1) and race1 in ('White') then 1 else 0 end) as mdro_rural_wht "MDRO Rural Residency: White",
	sum (case when mdro_rural in (1) and race1 in ('Black or African American') then 1 else 0 end) as mdro_rural_blk "MDRO Rural Residency: Black or African American",
	sum (case when mdro_rural in (1) and race1 in ('Other') then 1 else 0 end) as mdro_rural_oth "MDRO Rural Residency: Other",
	sum (case when mdro_rural in (1) and race1 in ('Unknown') then 1 else 0 end) as mdro_rural_unk "MDRO Rural Residency: Unknown",
	sum (case when mdro_rural in (1) and race1 in ('Asian') then 1 else 0 end) as mdro_rural_asian "MDRO Rural Residency: Asian",
	sum (case when mdro_rural in (1) and race1 in ('American Indian Alaskan Native') then 1 else 0 end) as mdro_rural_aian "MDRO Rural Residency: American Indian Alaskan Native",
	sum (case when mdro_rural in (1) and race1 in (' ') then 1 else 0 end) as mdro_rural_miss "MDRO Rural Residency: Missing",

	/*Non-rural residency by race*/
	sum (case when mdro_NONrural in (1) and race1 in ('White') then 1 else 0 end) as mdro_nonrural_wht "MDRO Non-Rural Residency: White",
	sum (case when mdro_NONrural in (1) and race1 in ('Black or African American') then 1 else 0 end) as mdro_nonrural_blk "MDRO Non-Rural Residency: Black or African American",
	sum (case when mdro_NONrural in (1) and race1 in ('Other') then 1 else 0 end) as mdro_nonrural_oth "MDRO Non-Rural Residency: Other",
	sum (case when mdro_NONrural in (1) and race1 in ('Unknown') then 1 else 0 end) as mdro_nonrural_unk "MDRO Non-Rural Residency: Unknown",
	sum (case when mdro_NONrural in (1) and race1 in ('Asian') then 1 else 0 end) as mdro_nonrural_asian "MDRO Non-Rural Residency: Asian",
	sum (case when mdro_NONrural in (1) and race1 in ('American Indian Alaskan Native') then 1 else 0 end) as mdro_nonrural_aian "MDRO Non-Rural Residency: American Indian Alaskan Native",
	sum (case when mdro_NONrural in (1) and race1 in (' ') then 1 else 0 end) as mdro_nonrural_miss "MDRO Non-Rural Residency: Missing",

	/*Totals*/
	sum (case when svi in (1) then 1 else 0 end) as svi_hi_sum "Risk Index High",
	sum (case when svi in (0) then 1 else 0 end) as svi_lo_sum "Risk Index Low",
	/*High SVI*/
	sum (case when svi in (1) and race1 in ('White') then 1 else 0 end) as svi_hi_wht "Risk Index High: White",
	sum (case when svi in (1) and race1 in ('Black or African American') then 1 else 0 end) as svi_hi_blk "Risk Index High: Black or African American",
	sum (case when svi in (1) and race1 in ('Other') then 1 else 0 end) as svi_hi_oth "Risk Index High: Other",
	sum (case when svi in (1) and race1 in ('Unknown') then 1 else 0 end) as svi_hi_unk "Risk Index High: Unknown",
	sum (case when svi in (1) and race1 in ('Asian') then 1 else 0 end) as svi_hi_asian "Risk Index High: Asian",
	sum (case when svi in (1) and race1 in ('American Indian Alaskan Native') then 1 else 0 end) as svi_hi_aian "Risk Index High: American Indian Alaskan Native",
	sum (case when svi in (1) and race1 in (' ') then 1 else 0 end) as svi_hi_miss "Risk Index High: Missing",

	/*High SVI*/
	sum (case when svi in (0) and race1 in ('White') then 1 else 0 end) as svi_lo_wht "Risk Index Low: White",
	sum (case when svi in (0) and race1 in ('Black or African American') then 1 else 0 end) as svi_lo_blk "Risk Index Low: Black or African American",
	sum (case when svi in (0) and race1 in ('Other') then 1 else 0 end) as svi_lo_oth "Risk Index Low: Other",
	sum (case when svi in (0) and race1 in ('Unknown') then 1 else 0 end) as svi_lo_unk "Risk Index Low: Unknown",
	sum (case when svi in (0) and race1 in ('Asian') then 1 else 0 end) as svi_lo_asian "Risk Index Low: Asian",
	sum (case when svi in (0) and race1 in ('American Indian Alaskan Native') then 1 else 0 end) as svi_lo_aian "Risk Index Low: American Indian Alaskan Native",
	sum (case when svi in (0) and race1 in (' ') then 1 else 0 end) as svi_lo_miss "Risk Index Low: Missing"



from equity_race

;
create table svi_ir_race as
select

	/*SVI/Risk index*/
	(svi_hi_sum / &svihighpop) *100000 as svihigh_ir "High Risk Index Areas" format=10.2,
	(svi_lo_sum / &svilowpop) *100000 as svilo_ir "Low Risk Index Areas" format=10.2,
	
	/*SVI IR higher than (or equal to) 0.80*/

	(svi_hi_wht / &svihighwhite) *100000 as svihigh_ir_white "Risk Index Greater than or equal to 0.80 IR, Race: White" format=10.2,
	(svi_hi_blk / &svihighblack) *100000 as svihigh_ir_black "Risk Index Greater than or equal to 0.80 IR, Race: Black/African American" format=10.2,
	(svi_hi_aian / &svihighaian) *100000 as svihigh_ir_aian "Risk Index Greater than or equal to 0.80 IR, Race: American India/ Alaska Native" format=10.2,
	(svi_hi_asian / &svihighasian) *100000 as svihigh_ir_asian "Risk Index Greater than or equal to 0.80 IR, Race: Asian" format=10.2,
	(svi_hi_oth / &svihighother) *100000 as svihigh_ir_oth "Risk Index Greater than or equal to 0.80 IR, Race: Other/Two or More Races" format=10.2, /*Two or more races in census track data*/

	/*no state class for NATIVE HAWAIIAN/PACIFIC ISLANDER, other = 2 or more races in CDC census*/

	/*SVI IR lower than 0.80*/
	(svi_lo_wht / &svilowwhite) *100000 as svilow_ir_white "Risk Index < 0.80 IR, Race: White" format=10.2,
	(svi_lo_blk / &svilowblack) *100000 as svilow_ir_black "Risk Index < 0.80 IR, Race: Black/African American" format=10.2,
	(svi_lo_aian / &svilowaian) *100000 as svilow_ir_aian "Risk Index < 0.80 IR, Race: American Indian/Alaska Native" format=10.2,
	(svi_lo_asian / &svilowasian) *100000 as svilow_ir_asian  "Risk Index < 0.80 IR, Race: Asian" format=10.2,
	(svi_lo_oth / &svilowother) *100000 as svilow_ir_oth "Risk Index < 0.80 IR, Race: Other/Two or More Races" format=10.2, /*Two or more races in census track data*/

	/*Rurality*/
	(rural_sum / &ruraltotalpop) *100000 as rural_ir "Rural residency IR" format=10.2,
	(nonrural_sum / &nonruralpop) *100000 as nonrural_ir "Non-Rural residency IR" format=10.2,


	/*Rural population*/
	(mdro_rural_wht / &ruralwhite) *100000 as rural_ir_white "Rural residency IR, Race: White" format=10.2,
	(mdro_rural_blk / &ruralblack) *100000 as rural_ir_black "Rural residency IR, Race: Black/African American" format=10.2,
	(mdro_rural_aian / &ruralaian) *100000 as rural_ir_aian "Rural residency IR, Race: American Indian/Alaska Native" format=10.2,
	(mdro_rural_asian / &ruralasian) *100000 as rural_ir_asian "Rural residency IR, Race: Asian" format=10.2,
	(mdro_rural_oth / &ruralother) *100000 as rural_ir_oth "Rural residency IR, Race: Other/Two or More Races" format=10.2,

	/*Non-Rural population*/
	(mdro_nonrural_wht / &nonruralwhite) *100000 as nonrural_ir_white "Non-Rural residency IR, Race: White" format=10.2,
	(mdro_nonrural_blk / &nonruralblack) *100000 as nonrural_ir_black "Non-Rural residency IR, Race: Black/African American" format=10.2,
	(mdro_nonrural_aian / &nonruralaian) *100000 as nonrural_ir_aian "Non-Rural residency IR, Race: American Indian/Alaska Native" format=10.2,
	(mdro_nonrural_asian / &nonruralasian) *100000 as nonrural_ir_asian "Non-Rural residency IR, Race: Asian" format=10.2,
	(mdro_nonrural_oth / &nonruralother) *100000 as nonrural_ir_oth "Non-Rural residency IR, Race: Other/Two or More Races" format=10.2

	from equity_race_counts
;
quit;

/*Transpose for display*/
/*Counts*/
proc transpose data=equity_race_counts out=equity_race_transp;

run;
/*IR*/
proc transpose data=svi_ir_race out=ir_race_transp;

run;

/*Finalize and get upper/lower limits: remember, you have to actually calculate these [value * 1.05/0.95 =/= 95% confidence limits].*/
/*Simplified table with counts*/
proc sql;
create table equRace_transp_final as
select
	
	_Label_ "Classification",
	Col1 as case_count "&qtr_num Count"

from equity_race_transp
;
/*IR's and CIs*/
create table equIR_transp_final as
select
	
	_Label_ "Classification",
	Col1 as ir_val "&qtr_num IR/100K",
		/*add CI*/
	case when Col1 not in (0) then (STDERR(ir_val)) else . end as std_err "Standard error", /*Display 0 values as missing/. so they don't confuse you on the table*/
	(ir_val + (1.96*(calculated std_err))) as uCL "Upper confidence limit" format 10.2,
	(ir_val - (1.96*(calculated std_err))) as lCL "Lower confidence limit" format 10.2

from ir_race_transp
;
/*Don't need standard error beyond this point*/
	alter table equIR_transp_final
	drop std_err;

quit;

proc print data=equIR_transp_final;run;







/*Statistical significance*/
/*We are going to use a binomial test in this situation: Is the proportion of [insert race] in a high SVI/rural location significantly different than a low SVI/urban location?*/
proc sql;
create table report_statsig as
select

	svi,
	density,
	RACE1 

from equity_race
;

quit;

proc freq data=report_statsig;
title 'SVI hi vs. low';
	tables svi/binomial(p=0.5 level='1') exact;
run;

/*Remember '0' = Rural*/
proc freq data=report_statsig;
title 'Rural vs. Non-rural res.';
	tables density/binomial(p=0.5 level='0');
run;

/*SVI by each race: does the proportion of each race differ significantly whether they are in a high or low SVI area?*/
proc freq data=report_statsig;
title 'Race= White';
	tables svi /binomial(p=0.5 level='1');
		where RACE1 in ('White');
run;
proc freq data=report_statsig;
title 'Race= Black or African American';
	tables svi /binomial(p=0.5 level='1');
		where RACE1 in ('Black or African American');
run;
proc freq data=report_statsig;
title 'Race= Other';
	tables svi /binomial(p=0.5 level='1');
		where RACE1 in ('Other');
run;
proc freq data=report_statsig;
title 'Race= Unknown';
	tables svi /binomial(p=0.5 level='1');
		where RACE1 in ('Unknown');
run;
proc freq data=report_statsig;
title 'Race= Asian';
	tables svi /binomial(p=0.5 level='1') exact;
		where RACE1 in ('Asian');
run;
proc freq data=report_statsig;
title 'Race= American Indian Alaska Native';
	tables svi /binomial(p=0.5 level='1');
		where RACE1 in ('American Indian Alaskan Native');
run;



/*Density by each race: does the proportion of each race differ significantly whether they are in a rural or nonrural area?*/
proc freq data=report_statsig;
title 'Race= White';
	tables density /binomial(p=0.5 level='0');/*level = '0' here because rural density = 0 and that is our measuring point*/
		where RACE1 in ('White');
run;

proc freq data=report_statsig;
title 'Race= Black or African American';
	tables density /binomial(p=0.5 level='0');
		where RACE1 in ('Black or African American');
run;

proc freq data=report_statsig;
title 'Race= Other';
	tables density /binomial(p=0.5 level='0');
		where RACE1 in ('Other');
run;
proc freq data=report_statsig;
title 'Race= Unknown';
	tables density /binomial(p=0.5 level='0');
		where RACE1 in ('Unknown');
run;

proc freq data=report_statsig;
title 'Race= Asian';
	tables density /binomial(p=0.5 level='0');
		where RACE1 in ('Asian');
run;

proc freq data=report_statsig;
title 'Race= American Indian Alaska Native';
	tables density /binomial(p=0.5 level='0');
		where RACE1 in ('American Indian Alaskan Native');
run;







