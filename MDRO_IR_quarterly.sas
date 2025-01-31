
/*Demographic Incidence Rates for MDRO Quarterly Report:

As long as the cumulative data points stay the same we can use this and adjust denominator or age adjustments as necessary.


*/


/*Now create IF of cumulative counts as we move through each quarter of our timeframe*/
proc sql;
create table combine_qtr_IR as
select

	testreportqtr,

/*IR Race*/
	((cum_CRE_w / &white_pop) * 100000) as IR_cum_CRE_w "Cumulative IR CRE in Quarter, Race: White" format=10.2 ,
	((cum_CRE_b / &blackaa_pop) * 100000)  as IR_cum_CRE_b "Cumulative IR CRE in Quarter, Race: Black or African American" format=10.2,
	((cum_CRE_a / &asian_pop) * 100000)  as IR_cum_CRE_a "Cumulative IR CRE in Quarter, Race: Asian" format=10.2,
	((cum_CRE_nhpi / &napi_pop) * 100000)  as IR_cum_CRE_nhpi "Cumulative IR CRE in Quarter, Race: Native Hawaiian or Pacific Islander" format=10.2,
	((cum_CRE_oth / &other_race_pop) * 100000)  as IR_cum_CRE_oth "Cumulative IR CRE in Quarter, Race: Other" format=10.2,
	((cum_CRE_unk / &state_pop) * 100000)  as IR_cum_CRE_unk "Cumulative IR CRE in Quarter, Race: Unknown" format=10.2,
	((cum_CRE_aian / &aian_pop) * 100000)  as IR_cum_CRE_aian "Cumulative IR CRE in Quarter, Race: American Indian Alaskan Native" format=10.2,
	((cum_CRE_miss / &state_pop) * 100000)  as IR_cum_CRE_miss "Cumulative IR CRE in Quarter, Race: Missing" format=10.2,

	((cum_c_auris_w / &white_pop) * 100000)  as IR_cum_c_auris_w "Cumulative IR C. auris in Quarter, Race: White" format=10.2,
	((cum_c_auris_b / &blackaa_pop) * 100000)  as IR_cum_c_auris_b "Cumulative IR C. auris in Quarter, Race: Black or African American" format=10.2,
	((cum_c_auris_a / &asian_pop) * 100000)  as IR_cum_c_auris_a "Cumulative IR C. auris in Quarter, Race: Asian" format=10.2,
	((cum_c_auris_nhpi / &napi_pop) * 100000)  as IR_cum_c_auris_nhpi "Cumulative IR C. auris in Quarter, Race: Native Hawaiian or Pacific Islander" format=10.2,
	((cum_c_auris_oth / &other_race_pop) * 100000)  as IR_cum_c_auris_oth "Cumulative IR C. auris in Quarter, Race: Other" format=10.2,
	((cum_c_auris_unk / &state_pop) * 100000)  as IR_cum_c_auris_unk "Cumulative IR C. auris in Quarter, Race: Unknown" format=10.2,
	((cum_c_auris_aian / &aian_pop) * 100000)  as IR_cum_c_auris_aian "Cumulative IR C. auris in Quarter, Race: American Indian Alaskan Native" format=10.2,
	((cum_c_auris_miss /  &state_pop) * 100000)  as IR_cum_c_auris_miss "Cumulative IR C. auris in Quarter, Race: Missing" format=10.2,

/*IR Hispanic ethnicity*/
	((cum_CP_CRE_hisp / &hisp_yes) * 100000) as IR_cum_CP_CRE_hisp "Cumulative IR CRE in Quarter: Hispanic" format=10.2,
	((cum_CP_CRE_nohisp / &hisp_no) * 100000) as IR_cum_CP_CRE_nohisp "Cumulative IR CRE in Quarter: Not Hispanic" format=10.2,
	((cum_CP_CRE_unkhisp / &state_pop) * 100000) as IR_cum_CP_CRE_unkhisp "Cumulative IR CRE in Quarter: Unknown Hispanic" format=10.2,
	((cum_CP_CRE_misshisp / &state_pop) * 100000) as IR_cum_CP_CRE_misshisp "Cumulative IR CRE in Quarter: Missing Hispanic" format=10.2,

	((cum_c_auris_hisp / &hisp_yes) * 100000) as IR_cum_c_auris_hisp "Cumulative IR C. auris in Quarter: Hispanic" format=10.2,
	((cum_c_auris_nohisp / &hisp_no) * 100000) as IR_cum_c_auris_nohisp "Cumulative IR C. auris in Quarter: Not Hispanic" format=10.2,
	((cum_c_auris_unkhisp / &state_pop) * 100000) as IR_cum_c_auris_unkhisp "Cumulative IR C. auris in Quarter: Unknown Hispanic" format=10.2,
	((cum_c_auris_mishisp / &state_pop) * 100000) as IR_cum_c_auris_mishisp "Cumulative IR C. auris in Quarter: Missing Hispanic" format=10.2,

/*IR Gender*/
	((cum_CP_CRE_male / &male_pop) * 100000) as IR_cum_CP_CRE_male "Cumulative IR CRE in Quarter: Male" format=10.2,
	((cum_CP_CRE_female / &female_pop) * 100000) as IR_cum_CP_CRE_female "Cumulative IR CRE in Quarter: Female" format=10.2,
	((cum_CP_CRE_sexmiss / &state_pop) * 100000) as IR_cum_CP_CRE_sexmiss "Cumulative IR CRE in Quarter: Missing" format=10.2,
	((cum_c_auris_male / &male_pop) * 100000) as IR_cum_c_auris_male "Cumulative IR C. auris in Quarter: Male" format=10.2,
	((cum_c_auris_female / &female_pop) * 100000) as IR_cum_c_auris_female "Cumulative IR C. auris in Quarter: Female" format=10.2,
	((cum_c_auris_sexmiss / &state_pop) * 100000) as IR_cum_c_auris_sexmiss "Cumulative IR C. auris in Quarter: Missing Gender" format=10.2,

/*IR Age*/
	((cum_CRE_04 / &age_04) * 100000) as IR_cum_CRE_04 "Cumulative IR CRE in Quarter: Age 0-4" format=10.2,
	((cum_CRE_0517 / &age_0517) * 100000) as IR_cum_CRE_0517 "Cumulative IR CRE in Quarter: Age 5-17" format=10.2,
	((cum_CRE_1824 / &age_1824) * 100000) as IR_cum_CRE_1824 "Cumulative IR CRE in Quarter: Age 18-24" format=10.2,
	((cum_CRE_2549 / &age_2549) * 100000) as IR_cum_CRE_2549 "Cumulative IR CRE in Quarter: Age 25-49" format=10.2,
	((cum_CRE_5064 / &age_5064) * 100000) as IR_cum_CRE_5064 "Cumulative IR CRE in Quarter: Age 50-64" format=10.2,
	((cum_CRE_65 / &age_65) * 100000) as IR_cum_CRE_65 "Cumulative IR CRE in Quarter: Age 65+" format=10.2,
	((cum_CAURIS_04 / &age_04) * 100000) as IR_cum_CAURIS_04 "Cumulative IR C. auris in Quarter: Age 0-4" format=10.2,
	((cum_CAURIS_0517 / &age_0517) * 100000) as IR_cum_CAURIS_0517 "Cumulative IR C. auris in Quarter: Age 5-17" format=10.2,
	((cum_CAURIS_1824 / &age_1824) * 100000) as IR_cum_CAURIS_1824 "Cumulative IR C. auris in Quarter: Age 18-24" format=10.2,
	((cum_CAURIS_2549 / &age_2549) * 100000) as IR_cum_CAURIS_2549 "Cumulative IR C. auris in Quarter: Age 25-49" format=10.2,
	((cum_CAURIS_5064 / &age_5064) * 100000) as IR_cum_CAURIS_5064 "Cumulative IR C. auris in Quarter: Age 50-64"  format=10.2,
	((cum_CAURIS_65 / &age_65) * 100000) as IR_cum_CAURIS_65 "Cumulative IR C. auris in Quarter: Age 65+"  format=10.2



from combine_cum_demo
	where testreportqtr <= "&qtr_dte."d
	group by testreportqtr

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


	/*High SVI*/
	sum (case when svi in (1) and race1 in ('White') then 1 else 0 end) as svi_hi_wht "SVI High: White",
	sum (case when svi in (1) and race1 in ('Black or African American') then 1 else 0 end) as svi_hi_blk "SVI High: Black or African American",
	sum (case when svi in (1) and race1 in ('Other') then 1 else 0 end) as svi_hi_oth "SVI High: Other",
	sum (case when svi in (1) and race1 in ('Unknown') then 1 else 0 end) as svi_hi_unk "SVI High: Unknown",
	sum (case when svi in (1) and race1 in ('Asian') then 1 else 0 end) as svi_hi_asian "SVI High: Asian",
	sum (case when svi in (1) and race1 in ('American Indian Alaskan Native') then 1 else 0 end) as svi_hi_aian "SVI High: American Indian Alaskan Native",
	sum (case when svi in (1) and race1 in (' ') then 1 else 0 end) as svi_hi_miss "SVI High: Missing",

	/*High SVI*/
	sum (case when svi in (0) and race1 in ('White') then 1 else 0 end) as svi_lo_wht "SVI Low: White",
	sum (case when svi in (0) and race1 in ('Black or African American') then 1 else 0 end) as svi_lo_blk "SVI Low: Black or African American",
	sum (case when svi in (0) and race1 in ('Other') then 1 else 0 end) as svi_lo_oth "SVI Low: Other",
	sum (case when svi in (0) and race1 in ('Unknown') then 1 else 0 end) as svi_lo_unk "SVI Low: Unknown",
	sum (case when svi in (0) and race1 in ('Asian') then 1 else 0 end) as svi_lo_asian "SVI Low: Asian",
	sum (case when svi in (0) and race1 in ('American Indian Alaskan Native') then 1 else 0 end) as svi_lo_aian "SVI Low: American Indian Alaskan Native",
	sum (case when svi in (0) and race1 in (' ') then 1 else 0 end) as svi_lo_miss "SVI Low: Missing"



from equity_race

;

create table svi_ir_race as
select

	/*SVI IR higher than (or equal to) 0.80*/

	(svi_hi_wht / &svihighwhite) *100000 as svihigh_ir_white "SVI Greater than or equal to 0.80 IR, Race: White"format=10.2,
	(svi_hi_blk / &svihighblack) *100000 as svihigh_ir_black "SVI Greater than or equal to 0.80 IR, Race: Black/African American"format=10.2,
	(svi_hi_aian / &svihighaian) *100000 as svihigh_ir_aian "SVI Greater than or equal to 0.80 IR, Race: American India/ Alaska Native"format=10.2,
	(svi_hi_asian / &svihighasian) *100000 as svihigh_ir_asian "SVI Greater than or equal to 0.80 IR, Race: Asian"format=10.2,
	(svi_hi_oth / &svihighother) *100000 as svihigh_ir_oth "SVI Greater than or equal to 0.80 IR, Race: Other/Two or More Races"format=10.2, /*Two or more races in census track data*/

	/*no state class for NATIVE HAWAIIAN/PACIFIC ISLANDER, other = 2 or more races in CDC census*/

	/*SVI IR lower than 0.80*/
	(svi_lo_wht / &svilowwhite) *100000 as svilow_ir_white "SVI < 0.80 IR, Race: White"format=10.2,
	(svi_lo_blk / &svilowblack) *100000 as svilow_ir_black "SVI < 0.80 IR, Race: Black/African American"format=10.2,
	(svi_lo_aian / &svilowaian) *100000 as svilow_ir_aian "SVI < 0.80 IR, Race: American Indian/Alaska Native"format=10.2,
	(svi_lo_asian / &svilowasian) *100000 as svilow_ir_asian  "SVI < 0.80 IR, Race: Asian"format=10.2,
	(svi_lo_oth / &svilowother) *100000 as svilow_ir_oth "SVI < 0.80 IR, Race: Other/Two or More Races"format=10.2, /*Two or more racs in census track data*/


	/*Rural population*/
	(mdro_rural_wht / &ruralwhite) *100000 as rural_ir_white "Rural residency IR, Race: White"format=10.2,
	(mdro_rural_blk / &ruralblack) *100000 as rural_ir_black "Rural residency IR, Race: Black/African American"format=10.2,
	(mdro_rural_aian / &ruralaian) *100000 as rural_ir_aian "Rural residency IR, Race: American Indian/Alaska Native"format=10.2,
	(mdro_rural_asian / &ruralasian) *100000 as rural_ir_asian "Rural residency IR, Race: Asian"format=10.2,
	(mdro_rural_oth / &ruralother) *100000 as rural_ir_oth "Rural residency IR, Race: Other/Two or More Races"format=10.2,

	/*Non-Rural population*/
	(mdro_nonrural_wht / &nonruralwhite) *100000 as nonrural_ir_white "Non-Rural residency IR, Race: White"format=10.2,
	(mdro_nonrural_blk / &nonruralblack) *100000 as nonrural_ir_black "Non-Rural residency IR, Race: Black/African American"format=10.2,
	(mdro_nonrural_aian / &nonruralaian) *100000 as nonrural_ir_aian "Non-Rural residency IR, Race: American Indian/Alaska Native"format=10.2,
	(mdro_nonrural_asian / &nonruralasian) *100000 as nonrural_ir_asian "Non-Rural residency IR, Race: Asian"format=10.2,
	(mdro_nonrural_oth / &nonruralother) *100000 as nonrural_ir_oth "Non-Rural residency IR, Race: Other/Two or More Races"format=10.2

	from equity_race_counts
;
quit;

proc print data=svi_ir_race;run;

/*Transpose for display*/
proc transpose data=equity_race_counts out=equity_race_transp;

run;
proc transpose data=svi_ir_race out=ir_race_transp;

run;

proc sql;
create table equRace_transp_final as
select
	
	_Label_ "Classification",
	Col1 as case_count "&qtr_num Count"

from equity_race_transp
;

create table equIR_transp_final as
select
	
	_Label_ "Classification",
	Col1 as ir_val "&qtr_num IR/100K"

from ir_race_transp
;
quit;



