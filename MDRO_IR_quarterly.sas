
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


/*Now for statistical significance*/
proc sql noprint;
/*Assign values*/
/*SVI*/
/*black*/
	select 
		svihigh_ir_black 
			into :black_svi_ir_h from svi_ir_race;
	select
		svilow_ir_black
			into :black_svi_ir_l from svi_ir_race;

/*white*/
	select 
		svihigh_ir_white 
			into :white_svi_ir_h from svi_ir_race;
	select
		svilow_ir_white
			into :white_svi_ir_l from svi_ir_race;

/*Asian*/
	select 
		svihigh_ir_asian
			into :asian_svi_ir_h from svi_ir_race;
	select
		svilow_ir_asian
			into :asian_svi_ir_l from svi_ir_race;

/*Other*/
	select 
		svihigh_ir_oth 
			into :other_svi_ir_h from svi_ir_race;
	select
		svilow_ir_oth
			into :other_svi_ir_l from svi_ir_race;

/*Rurality*/
/*black*/
	select 
		rural_ir_black 
			into :black_ir_rural from svi_ir_race;
	select
		nonrural_ir_black
			into :black_ir_nonrural from svi_ir_race;

/*white*/
	select 
		rural_ir_white 
			into :white_ir_rural from svi_ir_race;
	select
		nonrural_ir_white
			into :white_ir_nonrural from svi_ir_race;

/*Asian*/
	select 
		rural_ir_asian
			into :asian_ir_rural from svi_ir_race;
	select
		nonrural_ir_asian
			into :asian_ir_nonrural from svi_ir_race;

/*Other*/
	select 
		rural_ir_oth
			into :other_ir_rural from svi_ir_race;
	select
		nonrural_ir_oth
			into :other_ir_nonrural from svi_ir_race;


quit;



/*let statements for IR race values*/

/*SVI*/
%let black_svi_ir_h = &black_svi_ir_h;
%let black_svi_ir_l = &black_svi_ir_l;

%let white_svi_ir_h = &white_svi_ir_h;
%let white_svi_ir_l = &white_svi_ir_l;

%let asian_svi_ir_h = &asian_svi_ir_h;
%let asian_svi_ir_l = &asian_svi_ir_l;

%let other_svi_ir_h = &other_svi_ir_h;
%let other_svi_ir_l = &other_svi_ir_l;
/*Rural*/
%let rural_ir_black = &black_ir_rural;
%let nonrural_ir_black = &black_ir_nonrural;

%let rural_ir_white = &white_ir_rural;
%let nonrural_ir_white = &white_ir_nonrural;

%let rural_ir_asian = &asian_ir_rural;
%let nonrural_ir_asian = &asian_ir_nonrural;

%let rural_ir_oth = &other_ir_rural;
%let nonrural_ir_oth = &other_ir_nonrural;


/*For gneral SVI/Rurality ttest*/
proc sql;
create table equity_sig_rural as
select

	case when risk_factor in ("Cumulative MDRO in quarter: Rural IR" , "Cumulative MDRO in quarter: Non-rural IR")
		then risk_factor else '' end as rural_factor ,

	case when calculated rural_factor not in ('')  then Q4 else . end as IR_rural format 10.2

from transpose_equity_pcts
	having rural_factor not in ('')
;

create table equity_sig_svi as
select 

	case when risk_factor in ("Cumulative MDRO in quarter: SVI greater than or equal to 0.80 IR" , "Cumulative MDRO in quarter: SVI less than 0.80 IR")
		then risk_factor else '' end as svi_factor ,

	case when calculated svi_factor not in ('') then Q4 else . end as IR_svi format 10.2

from transpose_equity_pcts
	having svi_factor not in ('')
;
quit;
/*flip density variables for easier reference category*/
data prep;
set analysis;

	density_2=.;
	if density in (1) then density_2=0;
	if density in (0) then density_2=1;


	race_pval = Race1;
	if Race1 in ('Black or African American') then race_pval = 'Black';

run;

proc freq data=prep; tables density density_2 /norow nocol nopercent;run;


data analysis_2;
	set prep;

	ir_race_svi = .;
	ir_race_density = .;

/*SVI*/
if race_pval in ('Black') and svi in (1) then ir_race_svi = &black_svi_ir_h;
if race_pval in ('Black') and svi in (0) then ir_race_svi = &black_svi_ir_l;

if race_pval in ('White') and svi in (1) then ir_race_svi = &white_svi_ir_h;
if race_pval in ('White') and svi in (0) then ir_race_svi = &white_svi_ir_l;

if race_pval in ('Asian') and svi in (1) then ir_race_svi = &asian_svi_ir_h;
if race_pval in ('Asian') and svi in (0) then ir_race_svi = &asian_svi_ir_l;

if race_pval in ('Other') and svi in (1) then ir_race_svi = &other_svi_ir_h;
if race_pval in ('Other') and svi in (0) then ir_race_svi = &other_svi_ir_l;

/*Density*/
if race_pval in ('Black') and density in (1) then ir_race_density = &black_ir_rural;
if race_pval in ('Black') and density in (0) then ir_race_density = &black_ir_nonrural;

if race_pval in ('White') and density_2 in (1) then ir_race_density = &white_ir_rural;
if race_pval in ('White') and density_2 in (0) then ir_race_density = &white_ir_nonrural;

if race_pval in ('Asian') and density_2 in (1) then ir_race_density = &asian_ir_rural;
if race_pval in ('Asian') and density_2 in (0) then ir_race_density = &asian_ir_nonrural;

if race_pval in ('Other') and density_2 in (1) then ir_race_density = &other_ir_rural;
if race_pval in ('Other') and density_2 in (0) then ir_race_density = &other_ir_nonrural;


run;


data analysis_2;
	set analysis_2 (keep = race_pval svi ir_race_svi ir_race_density density_2 OWNING_JD);

		if race_pval in ("Unknown", "American Indian Alaskan Native", "Asian") then delete; /*Delete for SVI*/

run;

/*No race categories with just one outcome*/
proc freq data=analysis_2; tables race_pval*svi race_pval*density_2/nocol nopercent;run;
proc print data=analysis_2;run;

proc sort data=analysis_2;
	by race_pval;
run;




/*SVI*/
proc import
datafile = "&ncedssdata./svi_counties_values.xlsx"
out=svi_raw
dbms=xlsx replace;
getnames=yes;

run;

proc sort data=svi_raw; by county;run;
proc print data=test_l;where race_pval in ('Other');run;

data svi_raw;
set svi_raw;

	population_ctny = input(census_pop, comma9.);
run;
PROC SQL;
create table test_l as
    SELECT 
        a.*, 

        b.svi as svi_raw,
		population_ctny
    FROM 
        analysis_2 AS a
    LEFT JOIN 
        svi_raw AS b
    ON 
        a.owning_jd = b.county;
QUIT;

%macro ttest_by_race;
    /* Define the three race categories */
    %let races = White Black Other;

    /* Loop over each race and process */
    %do i = 1 %to %sysfunc(countw(&races, %str( )));
        %let race = %scan(&races, &i, %str( ));

        /* Capture t-test results for each race group */
        	ods output TTests=ttest_svi_&race;  /* Store results in a separate dataset */
			title "Grouped by &race, SVI";
        proc ttest data=test_l;
            class svi;  /* Defines the grouping variable: risk_group */
            var svi_raw;    /* The outcome variable: incidence rate */
            where race_pval = "&race";  /* Filter by Race1 variable */
        run;
        ods output close;  /* Close ODS output */

        /* Filter for the pooled result and rename the row */
        data pooled_svi_result_&race; length Method $32.;
            set ttest_svi_&race;
            where Method = 'Pooled';  /* Keep only the pooled results */
            /* Rename the row to 'Pooled t-test' */
            if Method = 'Pooled' then Method = "&race SVI Pooled t-test";
        run;

%
		        ods output TTests=ttest_density_&race;  /* Store results in a separate dataset */
				title "Grouped by &race, Pop. Density";
        proc ttest data=test_l;
            class density_2;  /* Defines the grouping variable: risk_group */
            var population_ctny;    /* The outcome variable: incidence rate */
            where race_pval = "&race";  /* Filter by Race1 variable */
        run;
        ods output close;  /* Close ODS output */

        /* Filter for the pooled result and rename the row */
        data pooled_density_result_&race; length Method $32.;
            set ttest_density_&race;
            where Method = 'Pooled';  /* Keep only the pooled results */
            /* Rename the row to 'Pooled t-test' */
            if Method = 'Pooled' then Method = "&race Density Pooled t-test";
        run;
    %end;
%mend;

/* Run the macro to process all races */
%ttest_by_race;

/* Combine the results from all races into a single dataset */
data final_results ;
length variable $32.;
    set 
        pooled_svi_result_White
        pooled_svi_result_Black
        pooled_svi_result_Other

		pooled_density_result_White
        pooled_density_result_Black
        pooled_density_result_Other



;
run;
/* Create a report with the combined t-test results */
title;
proc report data=final_results nowd;
    column method ProbT Variances  DF;
    define method / display 'Statistic';  /* Display the statistic name */
    define variances / display 'Variances'; /* Display the t-statistic */
    define ProbT / display 'P-value'; /* Display the p-value */
    define DF / display 'Degrees of Freedom'; /* Display the degrees of freedom */
run;

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*																   |				    |																									 */
/*-----------------------------------------------------------------|LOGISTIC REGRESSION"|----------------------------------------------------------------------------------------------------*/
/*																   |				    |																									 */
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/* Split data into two datasets : 70%- analysis 30%- validation */
Proc Surveyselect data=test_l out=split seed= 1234 samprate=.7 outall;
Run;


data analysis_logistic validation;
set split;
	if selected = 1 then output analysis_logistic;
	else output validation;


run;

proc sql;
create table analysis_logistic as
select *,

	log(population_ctny) as log_population

	from analysis_logistic
;
quit;


proc sort data= analysis_logistic;
	by  svi_raw;

run;

proc print data= analysis_logistic noobs;run;


%macro normal(input=, vars=, output=);

ods output TestsForNormality = Normal;
proc univariate data = &input normal;
var &vars;
run;
ods output close;

data &output;length Status $24.;
set Normal ( where = (Test = 'Shapiro-Wilk'));
if pValue > 0.05 then Status ="Normal";
else Status = "Non-normal";
drop TestLab Stat pType pSign;
run;
%mend;

%normal(input=analysis_logistic, vars=svi_raw population_ctny log_population , output=Normality);

proc print data=normality noobs label;run;

/*Fit a normal curve to these and view*/
proc sgplot data=analysis_logistic;

	histogram log_population / ;
    density log_population /  type=normal;
run;

proc sgplot data=analysis_logistic;

	histogram population_ctny / ;
    density population_ctny /  type=normal;
run;

proc sgplot data=analysis_logistic;

	histogram svi_raw / ;
    density svi_raw /  type=normal;
run;



/*Not exactly normal... model anyway. We don't need normality to run logistic regression (it'd be nice though)*/
ods graphics on / noborder ; 
title;

/* Logistic Model*/
/*1. Probability of SVI = 1 based on population size increasing*/
proc logistic data=analysis_logistic plots=EFFECT plots=ROC;
model svi (event='1') = population_ctny / outroc = rocout;
	oddsratio population_ctny;
	output out=estimated_svi predicted=estprob l=lower95 u=upper95; 
run;

/*2. Probability of SVI = 1 based on LOG population size increasing*/
proc logistic data=analysis_logistic plots=EFFECT plots=ROC;
model svi (event='1') = log_population / outroc = rocout;
	oddsratio log_population;
	output out=estimated_svi predicted=estprob l=lower95 u=upper95; 
run;



/*3. Probability of 'Rural' classification based on SVI score increasing*/
proc logistic data=analysis_logistic plots=EFFECT plots=ROC;
model density_2 (event='1') = svi_raw / outroc = rocout;
	oddsratio svi_raw;
	output out=estimated_rural predicted=estprob l=lower95 u=upper95;
run;



/*Quick interpretation; if you have an elevated SVI, higher probably of living in a rural county. BUT if you live in a high-risk county (over 0.8 SVI) it doesn't necessarily mean you're rural*/
proc print data=estimated_svi noobs label;run;
proc print data=estimated_rural noobs label;run;




