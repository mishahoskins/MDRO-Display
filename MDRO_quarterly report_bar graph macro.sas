
/*MDRO Quarterly report bar graph macro*/

options compress=yes;
options nofmterr;
title;footnote;

/*Second part (macro "bar_mdro_2" is the SVI/Density graphs by race, these are slightly more involved since they're panel displays. Still not too bad and provide
some grouping aspect to our SVI and rurality displays by race. two prep steps below. HCE graph is stand alone until I have time to fix the macro. */
/*But first SVI/Density IR prep*/

/*Part I: This is a little wonky but we're going to create a SVI and Density identifier where 1=high SVI or Rural, 0=low SVI or Non-rural and 
.= not the right category (ie. SVI in the rural case and vice versa). The gist is we can use our 'dummy' variable as a grouping point for SVI and Density. 
Is there an easier way? Maybe.*/

proc sql;
create table graphs_data_density as
select
	
	_LABEL_,
	ir_val ,

	case when _LABEL_ in 

			("Rural residency IR, Race: White",
			"Rural residency IR, Race: Black/African American",
			"Rural residency IR, Race: American Indian/Alaska Native",
			"Rural residency IR, Race: Asian",
			"Rural residency IR, Race: Other/Two or More Races")

			then 1 	 					/*Pick out our RURAL labels and assign them 1, 0 if they're rural vs non-rural*/

	when (find(_LABEL_, "Risk")>0) then . /*If the label is SVI related we'll mark it missing so the graph doesn't display the value*/

		else 0 end as rural_id,

				/*Same thing but in reverse for SVI*/

	case when _LABEL_ in 

			("Risk Index Greater than or equal to 0.80 IR, Race: White",
			"Risk Index Greater than or equal to 0.80 IR, Race: Black/African American",
			"Risk Index Greater than or equal to 0.80 IR, Race: American India/ Alaska Native",
			"Risk Index Greater than or equal to 0.80 IR, Race: Asian",
			"Risk Index Greater than or equal to 0.80 IR, Race: Other/Two or More Races")


			then 1 

	 when (find(_LABEL_, "Rural")>0) then . 

		else 0 end as sviHI_id,

/*CI's*/
	case when ir_val not in (0) then (STDERR(ir_val)) else . end as std_err "Standard error", /*Display 0 values as missing/. so they don't confuse you on the table*/
	(ir_val + (1.96*(calculated std_err))) as uCL "Upper confidence limit" format 10.2,
	(ir_val - (1.96*(calculated std_err))) as lCL "Lower confidence limit" format 10.2



from equIR_transp_final
;
quit;

proc print data=equIR_transp_final; run;


/*Part II: re-label everything to be much more simple in the graph display*/

proc format;
value rural_id
	0='Non-Rural Residency'
	1='Rural Residency';

value sviHI_id
	0='Low Risk Index Areas'
	1='High Risk Index Areas';

value $ _LABEL_


			"Risk Index Greater than or equal to 0.80 IR" = "High Risk Index Areas"
			"Risk Index Less than 0.80 IR" = "Low Risk Index Areas"

			"Risk Index Greater than or equal to 0.80 IR, Race: White" = "White"
			"Risk Index Greater than or equal to 0.80 IR, Race: Black/African American" = "Black/AA"
			"Risk Index Greater than or equal to 0.80 IR, Race: American India/ Alaska Native" = "AI/AN"
			"Risk Index Greater than or equal to 0.80 IR, Race: Asian" = "Asian"
			"Risk Index Greater than or equal to 0.80 IR, Race: Other/Two or More Races"  = "Other"

			"Risk Index < 0.80 IR, Race: White" = "White"
			"Risk Index < 0.80 IR, Race: Black/African American" = "Black/AA"
			"Risk Index < 0.80 IR, Race: American Indian/Alaska Native" = "AI/AN"
			"Risk Index < 0.80 IR, Race: Asian" = "Asian"
			"Risk Index < 0.80 IR, Race: Other/Two or More Races"  = "Other"

			"Rural residency IR, Race: White" = "White"
			"Rural residency IR, Race: Black/African American" = "Black/AA"
			"Rural residency IR, Race: American Indian/Alaska Native" = "AI/AN"
			"Rural residency IR, Race: Asian" = "Asian"
			"Rural residency IR, Race: Other/Two or More Races" = "Other"

			"Non-Rural residency IR, Race: White" = "White"
			"Non-Rural residency IR, Race: Black/African American" = "Black/AA"
			"Non-Rural residency IR, Race: American Indian/Alaska Native" = "AI/AN"
			"Non-Rural residency IR, Race: Asian" = "Asian"
			"Non-Rural residency IR, Race: Other/Two or More Races" = "Other";

	
run;

proc print data=graphs_data_density noobs;run;

/*Part III: Pull in source data for a year over year look*/
proc sql;
create table five_yr_graph as
select

	intnx("year", (EVENT_DATE), 0, "end") as reportyr "Year Ending Date" format=year4.,
	sum (case when type in ("&disease") then 1 else 0 end) as case_count "Cases in Year"

from SASdata.recordssas
	group by reportyr

;

quit;


/*create 3 week moving average for case comparison*/
data five_yr_graph;
set five_yr_graph;

label case_3_avg = "3-Year Case Average";
format case_3_avg 8.;
/*Average based on three year lag*/
case_3_avg=(case_count+lag(case_count)+lag2(case_count))/3;

run;

/*Wrote this into a macro because it seemed easier. Kind of a lot of settings though so not sure how much time it actually saves. No need to repeat the same sgplot 9+ times is the goal.

Format guide: Arial font, 10pt size, and bold axes labels. Order variables with 'unknown' and 'missing' as the last two where applicable.

*/
%macro line_MDRO;
proc sgplot data=five_yr_graph noborder noautolegend;

  series X=reportyr Y=case_count /  lineattrs=(thickness=3);/* Plot for the current year */
 /* series X=reportyr Y=case_3_avg /  lineattrs=(thickness=1 pattern=dashed color=red);*/ /*Plot for the current year */ /* Plot for the 5-year average */

	xaxis label = "Year"
		valueattrs= (family="Arial" size=10)
		labelattrs= (family="Arial" weight= bold size=10)
		values=('31dec2018'd to '31dec2024'd by year) valuesdisplay=('2018' '2019' '2020' '2021' '2022' '2023' '2024');

	yaxis label = "Number of &disease cases"
		valueattrs= (family="Arial" size=10)
		labelattrs= (family="Arial" weight=bold size=10)
		min=50 max=375;

		
		styleattrs datacolors= (vligb mogb ligb dagb pab grb libgr);	/*From: http://ftp.sas.com/techsup/download/graph/color_list.pdf
																				page 8 for greenscale colors used. Can use other 
																				scales/combinations but consitency would be beneficial*/

		    keylegend / title=" " location=inside position=topleft 
                across=1 noborder;

run;

proc print data=five_yr_graph noobs label;run;

%mend;

%macro bar_mdro (group=, set=, title=, order=);
ods graphics /noborder;

proc sgplot data=&set noborder noautolegend;
	vbar &group / barwidth=.5 group=&group nooutline limits=both;

	xaxis label = &title 
		valueattrs= (family="Arial" size=10)
		labelattrs= (family="Arial" weight= bold size=10)
			values=(&order); 

	yaxis label = 'Number of cases'
		valueattrs= (family="Arial" size=10)
		labelattrs= (family="Arial" weight=bold size=10);

		where testreportqtr <= '01jan2024'd and type ~= 'STRA';
		styleattrs datacolors= (vligb mogb ligb dagb pab grb libgr);	/*From: http://ftp.sas.com/techsup/download/graph/color_list.pdf
																				page 8 for greenscale colors used. Can use other 
																				scales/combinations but consitency would be beneficial*/

	where type in ("&disease");
run;
title;


%mend bar_mdro;
 


/*Macro for SVI and rurality, a little different since it's a panel graph.
Format guide: Arial font, 10pt size, and bold axes labels. Order variables 'yes', 'no', 'unknown', and 'missing' as the last two where applicable.*/

%macro bar_mdro_2 (group=, label=, order=);

proc sgpanel data=graphs_data_density noautolegend;

panelby &group  / uniscale = row novarname;
format &group &label _LABEL_ $_LABEL_.;

/*Using vbarparm we can categorize by label and add the confidence intervals (color=black) to give a nice visual*/
vbarparm category=_LABEL_ response=ir_val / limitlower=lCL limitupper=uCL limitattrs=(color=black) groupdisplay=cluster 
    group=&group nooutline;
	
	colaxis label="Race" valueattrs= (family="Arial" size=10)
		valueattrs= (family="Arial" size=10)
		labelattrs= (family="Arial" weight=bold size=10)
			values=(&order);

  	rowaxis label="IR/100K" valueattrs= (family="Arial" size=10)
		valueattrs= (family="Arial" size=10)
		labelattrs= (family="Arial" weight=bold size=10);

	styleattrs datacolors= (vligb mogb) ;

	where &group not in (.) ;
run;
%mend bar_mdro_2;


/*Macro for total IR/CIs but no panel*/
%macro bar_mdro_3 (order=, title=);
proc sgplot data=graphs_data_density noborder noautolegend;

	vbarparm category=_label_ response=ir_val/ barwidth=.5  nooutline 
	limitlower=lcl limitupper=ucl limitattrs=(color=black) groupdisplay=cluster group=_label_; /*Don't change the order of these commands, it will suppress the error bars because SAS can be a dummy sometimes*/
	

	xaxis label = &title
		valueattrs= (family="Arial" size=10)
		labelattrs= (family="Arial" weight= bold size=10)
			values=(&order);

	yaxis label = 'IR/100K'
		valueattrs= (family="Arial" size=10)
		labelattrs= (family="Arial" weight=bold size=10);

styleattrs datacolors=(mogb vligb);
run;
%mend bar_mdro_3;

ods graphics /noborder;
title; footnote;
/*Set your output pathway here*/
ods excel file="C:\Users\mhoskins1\Desktop\Work Files\MDRO_Graphs.xlsx";*<----- Named a generic overwriteable name so we can continue to reproduce and autopopulate a template;

ods excel options (sheet_interval = "none" sheet_name = "graphs" embedded_titles='Yes');
/*Demographic Plots*/
/*%bar_mdro(set=disease_sum, group=type, order="CRE" "CAURIS" , title="Classification");*/
/*%bar_mdro(set=plots, group=gender, order="Male" "Female" , title="Gender");
%bar_mdro(set=plots, group=race1, order="American Indian Alaskan Native" "Asian" "Black or African American" "White" "Unknown", title="Race");
%bar_mdro(set=plots, group=label_eth, order="Hispanic" "Non-Hispanic" "Unknown", title="Hispanic Ethnicity");
%bar_mdro(set=plots, group=age_group, order="0-04" "05-17" "18-24" "25-49" "50-64" "65+" , title="Age Group");*/


%line_mdro;
%bar_mdro(set=plots, group=mechanism, order="KPC" "NDM" "OXA-48" "Other" "IMP" "VIM" "Missing", title="Mechanism");
/*Equity Plots*/
%bar_mdro(set=equity_plots, group=travel, order="Yes" "No" "Unknown" "Missing", title="History of Travel");
%bar_mdro(set=equity_plots, group=hospitalized_new, order="Yes" "No" "Unknown", title="Hospitalization Status");

proc sgplot data=transpose_labels noborder noautolegend;
	vbar _label_ / barwidth=.5 response=col1 nooutline stat=sum
		group=_label_ groupdisplay=cluster;

	xaxis label = "Healthcare Experience"
		valueattrs= (family="Arial" size=10)
		labelattrs= (family="Arial" weight= bold size=10)
			values=("Acute Care Hospital" "LTACH" "LTCF" "None" "Surgery/Hemodialysis" "Unknown");

	yaxis label = 'Number of cases'
		valueattrs= (family="Arial" size=10)
		labelattrs= (family="Arial" weight=bold size=10);

		*where testreportqtr <= '01jan2024'd and type ~= 'STRA';
		styleattrs datacolors= (vligb mogb ligb dagb pab grb libgr);


run;
title;

/*Rural and SVI Plots*/
/*Panel by race*/
%bar_mdro_2 (group=rural_id, order="White" "Black/AA" "AI/AN" "Other" , label=rural_id.);
%bar_mdro_2 (group=sviHI_id, order="White" "Black/AA" "Other" , label=sviHI_id.);

/*No panel; total IR/CIs*/
%bar_mdro_3 (title="Risk Index", order="Low Risk Index Areas" "High Risk Index Areas");
%bar_mdro_3 (title="Rural Residency", order="Rural residency IR" "Non-Rural residency IR");



ods excel close;



proc sql;
create table scatter as
select

	intnx("month", (EVENT_DATE), 0, "end") as report_month "Month" format=MONYY5.,
	sum (case when type not in ('') then 1 else 0 end) as events_month "Cases in month"

from SASdata.recordssas
	group by report_month	
;
quit;

proc print data=scatter;run;

proc reg data=scatter plots=none;
model events_month = report_month / rsquare;
output out=preds predicted=p_events;
/* Use ods to output the r-square value into a dataset */
ods output fitStatistics=fs;
run;
quit;

/* Transfer the r-square value to a macro variable named RSQ */
data _null_;
set fs;
where label2="Adj R-Sq";
call symputx("RSQ", put(nvalue2, percentn7.1));
run;


proc sgplot data=scatter noborder ;

  scatter X=report_month Y=events_month /  ;/* Plot for the current year */

  	reg X=report_month Y=events_month/; 


	xaxis label = "Year (Month)"
		valueattrs= (family="Arial" size=10)
		labelattrs= (family="Arial" weight= bold size=10)
		;

	yaxis label = "Number of &disease cases"
		valueattrs= (family="Arial" size=10)
		labelattrs= (family="Arial" weight=bold size=10);

		inset ("Adj. R-Square:" = "&RSQ") / position=bottomright;
		styleattrs datacolors= (vligb mogb ligb dagb pab grb libgr);	/*From: http://ftp.sas.com/techsup/download/graph/color_list.pdf
																				page 8 for greenscale colors used. Can use other 
																				scales/combinations but consitency would be beneficial*/



run;






