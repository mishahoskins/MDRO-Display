
/*MDRO Quarterly report macro*/

/*Reset Macros in case running separately*/
options compress=yes;
options nofmterr;
title;footnote;

/*Wrote this into a macro because lazy. No need to repeat the same sgplot 9+ times

Format guide: Arial font, 10pt size, and bold axes labels.

*/


%macro bar_mdro (group=, set=, title=, order=); /*Added display order so we have unknown, missing at the end of each display where applicable*/
ods graphics /noborder;

proc sgplot data=SASdata.&set noborder noautolegend;
	vbar &group / barwidth=.5 group=&group nooutline;

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

/*Macro for SVI and rurality, a little different since it's a panel graph*/
/*Added macro #2 2/5/2025*/
%macro bar_mdro_2 (group=, label=);

proc sgpanel data=graphs_data_density noautolegend;

panelby &group  / uniscale = row novarname ;
format &group &label _LABEL_ $_LABEL_.;

vbarparm category=_LABEL_ response=ir_val / groupdisplay=cluster 
    group=&group nooutline;
	
	colaxis label="Race" valueattrs= (family="Arial" size=10)
		valueattrs= (family="Arial" size=10)
		labelattrs= (family="Arial" weight=bold size=10);

  	rowaxis label="IR/100K" valueattrs= (family="Arial" size=10)
		valueattrs= (family="Arial" size=10)
		labelattrs= (family="Arial" weight=bold size=10);

	styleattrs datacolors= (vligb mogb) ;

	where &group not in (.) ;
run;
%mend bar_mdro_2;


ods graphics /noborder;



title; footnote;
/*Set your output pathway here*/
ods excel file="C:\Users\mhoskins1\Desktop\Work Files\MDRO_Graphs.xlsx";*<----- Named a generic overwriteable name so we can continue to reproduce and autopopulate a template;

ods excel options (sheet_interval = "none" sheet_name = "graphs" embedded_titles='Yes');
/*Demographic Plots*/
%bar_mdro(set=disease_sum, group=type, order="CRE" "CAURIS" , title="Classification");
/*%bar_mdro(set=plots, group=gender, order= , title="Gender");*/
%bar_mdro(set=plots, group=race1, order="American Indian Alaskan Native" "Asian" "Black or African American" "White" "Unknown", title="Race");
/*%bar_mdro(set=plots, group=hispanic, order= , title="Hispanic Ethnicity");*/
%bar_mdro(set=plots, group=age_group, order="0-04" "05-17" "18-24" "25-49" "50-64" "65+" , title="Age Group");

/*Equity Plots*/
%bar_mdro(set=equity_plots, group=travel, order="Yes" "No" "Unknown" "Missing", title="History of Travel");
%bar_mdro(set=equity_plots, group=hospitalized_new, order="Yes" "No" "Unknown", title="Hospitalization Status");
%bar_mdro(set=equity_plots, group=hce_plot, order="Acute Care Hospital" "LTACH" "LTCF" "None" "Surgery/Hemodialysis/Other Surg." "Unknown" "Missing", title="Healthcare Experience");

/*Rural and SVI Plots*/
%bar_mdro_2 (group=rural_id, label=rural_id.);
%bar_mdro_2 (group=sviHI_id, label=sviHI_id.);

ods excel close;

















