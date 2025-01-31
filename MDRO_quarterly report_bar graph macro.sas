
/*MDRO Quarterly report macro*/

/*Reset Macros in case running separately*/
options compress=yes;
options nofmterr;
title;footnote;

/*Wrote this into a macro because lazy. No need to repeat the same sgplot 9+ times

Format guide: Arial font, 10pt size, and bold axes labels.

*/


%macro bar_mdro (group=, set=, title=);
ods graphics /noborder;

proc sgplot data=SASdata.&set noborder noautolegend;
	vbar &group / barwidth=.5 group=&group nooutline;

	xaxis label = &title 
		valueattrs= (family="Arial" size=10)
		labelattrs= (family="Arial" weight= bold size=10); 
	yaxis label = 'Number of cases'
		valueattrs= (family="Arial" size=10)
		labelattrs= (family="Arial" weight=bold size=10);

		where testreportqtr <= '01jan2024'd and type ~= 'STRA';
		styleattrs datacolors= (vligb mogb ligb dagb pab grb libgr);	/*From: http://ftp.sas.com/techsup/download/graph/color_list.pdf
																				page 8 for greenscale colors used. Can use other 
																				scales/combinations but consitency would be beneficial*/


run;
title;


%mend bar_mdro;
 



/*Second part are the SVI/Density graphs by race, these are a little tricky so left them out of the macro and just stuck them in the output*/
/*But first SVI/Density IR prep*/

/*Part I: This is a little wonky but we're going to create a SVI and Density identifier where 1=high SVI or Rural, 0=low SVI or Non-rural and 
.= not the right category. The gist is we can use our 'dummy' variable as a grouping point for SVI and Density. Is there an easier way? Maybe.*/
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

			then 1 	 

	when (find(_LABEL_, "SVI")>0) then . 

		else 0 end as rural_id,


	case when _LABEL_ in 

			("SVI Greater than or equal to 0.80 IR, Race: White",
			"SVI Greater than or equal to 0.80 IR, Race: Black/African American",
			"SVI Greater than or equal to 0.80 IR, Race: American India/ Alaska Native",
			"SVI Greater than or equal to 0.80 IR, Race: Asian",
			"SVI Greater than or equal to 0.80 IR, Race: Other/Two or More Races")


			then 1 

	 when (find(_LABEL_, "Rural")>0) then . 

		else 0 end as sviHI_id






from equIR_transp_final
;

quit;


/*Part II: re-label everything to be much more simple*/
proc format;
value rural_id
	0='Non-Rural Residency'
	1='Rural Residency';

value sviHI_id
	0='SVI < 0.8'
	1='SVI > 0.8';

value $ _LABEL_

			"SVI Greater than or equal to 0.80 IR, Race: White" = "White"
			"SVI Greater than or equal to 0.80 IR, Race: Black/African American" = "Black/AA"
			"SVI Greater than or equal to 0.80 IR, Race: American India/ Alaska Native" = "AI/AN"
			"SVI Greater than or equal to 0.80 IR, Race: Asian" = "Asian"
			"SVI Greater than or equal to 0.80 IR, Race: Other/Two or More Races"  = "Other"

			"SVI < 0.80 IR, Race: White" = "White"
			"SVI < 0.80 IR, Race: Black/African American" = "Black/AA"
			"SVI < 0.80 IR, Race: American Indian/Alaska Native" = "AI/AN"
			"SVI < 0.80 IR, Race: Asian" = "Asian"
			"SVI < 0.80 IR, Race: Other/Two or More Races"  = "Other"

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

;
	
run;


ods graphics /noborder;


proc freq data=equity_plots; tables rurality /norow nocol nopercent;run;
proc contents data=equity_plots order=varnum;run;

title; footnote;
/*Set your output pathway here*/
ods excel file="C:\Users\mhoskins1\Desktop\Work Files\MDRO_Graphs.xlsx";*<----- Named a generic overwriteable name so we can continue to reproduce and autopopulate a template;

ods excel options (sheet_interval = "none" sheet_name = "graphs" embedded_titles='Yes');
/*Demographic Plots*/
%bar_mdro(set=disease_sum, group=type, title="Classification");
%bar_mdro(set=plots, group=gender, title="Gender");
%bar_mdro(set=plots, group=race1, title="Race");
%bar_mdro(set=plots, group=hispanic, title="Hispanic Ethnicity");
%bar_mdro(set=plots, group=age_group, title="Age Group");

/*Equity Plots*/
%bar_mdro(set=equity_plots, group=travel, title="History of Travel");
%bar_mdro(set=equity_plots, group=hospitalized_new, title="Hospitalization Status");
%bar_mdro(set=equity_plots, group=hce_plot, title="Healthcare Experience");
%bar_mdro(set=equity_plots, group=screening_event, title="MDRO Identified in Screening");


/*SVI/Density incidence rate by race*/
/*Part III from above: Write out each panel graph subgrouping SVI high vs. low and Density rural vs. non-rural by race*/
proc sgpanel data=graphs_data_density noautolegend;

panelby rural_id  / uniscale = row novarname ;
format rural_id rural_id. _LABEL_ $_LABEL_.;

vbarparm category=_LABEL_ response=ir_val / groupdisplay=cluster 		
    group=rural_id nooutline;
	
	colaxis label="Race" valueattrs= (family="Arial"  size=10)
		valueattrs= (family="Arial" size=10)
		labelattrs= (family="Arial" weight=bold size=10);

  	rowaxis label="IR/100K" valueattrs= (family="Arial"  size=10) 		
		valueattrs= (family="Arial" size=10)
		labelattrs= (family="Arial" weight=bold size=10);;

	styleattrs datacolors= (vligb mogb) ;
	
	where rural_id not in (.);
run;




proc sgpanel data=graphs_data_density noautolegend;

panelby sviHI_id  / uniscale = row novarname ;
format sviHI_id sviHI_id. _LABEL_ $_LABEL_.;

vbarparm category=_LABEL_ response=ir_val / groupdisplay=cluster 
    group=sviHI_id nooutline;
	
	colaxis label="Race" valueattrs= (family="Arial" size=10)
		valueattrs= (family="Arial" size=10)
		labelattrs= (family="Arial" weight=bold size=10);

  	rowaxis label="IR/100K" valueattrs= (family="Arial" size=10)
		valueattrs= (family="Arial" size=10)
		labelattrs= (family="Arial" weight=bold size=10);

	styleattrs datacolors= (vligb mogb) ;

	where sviHI_id not in (.) ;
run;

ods excel close;





proc print data=final_combined_mechanism noobs label;run;


proc print data=final_combined_race noobs label;run;
proc print data=final_combined_eth noobs label;run;
proc print data=final_combined_gender noobs label;run;
proc print data=final_combined_age noobs label;run;

proc contents data=;run;

proc univariate data=combine_qtr_ir ;
    var points;
    histogram points;
run;
















