/*Part IV: import data sets and outputs*/

/*Reset Macros in case running separately*/
options compress=yes;
options nofmterr;
title;footnote;

data final_combined_mechanism;
set SASdata.final_combined_mechanism;
run;

data final_combined_gender ;
set SASdata.final_combined_gender ;
run;

data final_combined_race ;
set SASdata.final_combined_race ;
run;

data final_combined_eth ;
set SASdata.final_combined_eth ;
run;

data final_combined_age ;
set SASdata.final_combined_age ;
run;

data county_sum ;
set SASdata.county_sum ;
run;

data disease_sum;
set SASdata.disease_sum;
run;

data counties_projected;
set SASdata.counties_projected;
run;

data map_counts_final;
set SASdata.map_counts_final;
run;

data case_display;
set SASdata.case_display;
run;

data case_display_cauris;
set SASdata.case_display_cauris;
run;

data equity_final_pcts;
set SASdata.equity_final_pcts;
run;

data hlth_equity_density_month_2;
set SASdata.hlth_equity_density_month_2;
run;

data plots;
set SASdata.plots;
run;

data plots;
set plots;

format testreportmonth Monname3. ; /*Just need the month for easier to read graphs*/


run;

data equity_plots;
set SASdata.equity_plots;
run;

data equity_plots;
set equity_plots;

format testreportmonth Monname3. ; /*Just need the month for easier to read graphs*/


run;

/*Format buckets for maps*/
proc format;
	value case_display
	
	1= "0-5 Cases"
	2= "6-10 Cases"
	3= "11+ Cases"
;
	value case_display_cauris


	1= "No C. auris cases"
	2= "1+ C. auris cases"
;
run;

/*OUTPUT THROUGH ODS FOR DISTRIBUTION AND/OR MAKING A REPORT*/
/*TABLE OUTPUT*/
title; footnote;
/*Set your output pathway here*/
ods excel file="C:\Users\mhoskins1\Desktop\Work Files\MDRO_Quarterly_Report_&sysdate..xlsx";


/*Tables*/
title justify=left height=10pt font='Helvetica' "&year_dte. Case counts by quarter, mechanism";
ods excel options (sheet_interval = "now" frozen_headers="1" sheet_name = "mdro mech" embedded_titles='Yes');
proc print data=final_combined_mechanism noobs label;run;

title justify=left height=10pt font='Helvetica' "&year_dte. Case counts through &qtr_num., race (%)";
ods excel options (sheet_interval = "now" frozen_headers="1" sheet_name = "mdro race" embedded_titles='Yes');
proc print data=final_combined_race noobs label;where  testreportqtr in ("&qtr_dte"d);run;

title justify=left height=10pt font='Helvetica' "&year_dte. Case counts through &qtr_num., ethnicity (%)";
ods excel options (sheet_interval = "now" frozen_headers="1" sheet_name = "mdro eth" embedded_titles='Yes');
proc print data=final_combined_eth noobs label;where  testreportqtr in ("&qtr_dte"d);run;

title justify=left height=10pt font='Helvetica' "&year_dte. Case counts through &qtr_num., gender (%)";
ods excel options (sheet_interval = "now" frozen_headers="1" sheet_name = "mdro gender" embedded_titles='Yes');
proc print data=final_combined_gender noobs label;where  testreportqtr in ("&qtr_dte"d);run;

title justify=left height=10pt font='Helvetica' "&year_dte. Case counts through &qtr_num., age (%)";
ods excel options (sheet_interval = "now" frozen_headers="1" sheet_name = "mdro age" embedded_titles='Yes');
proc print data=final_combined_age noobs label;where  testreportqtr in ("&qtr_dte"d); run;

title justify=left height=10pt font='Helvetica' "&year_dte. Case counts by county";
ods excel options (sheet_interval = "now" frozen_headers="1" sheet_name = "mdro county" embedded_titles='Yes');
proc print data=county_sum noobs label;run;

/*Epi curves*/

title;
ods graphics / noborder;
ods excel options (sheet_interval = "none" sheet_name = "MDRO Epi Curves" embedded_titles='No');
/*Quarterly curve*/

proc sgplot data=disease_sum noborder;
	vbar testreportqtr / barwidth=.5 group=type nooutline;
	xaxis label = 'Quarter of symptom onset';
	yaxis label = 'Number of cases';
	*title "MDRO case counts by quarter, &year_dte. ";
	keylegend / title='Disease' noborder position=bottomright;
		where testreportqtr <= '01jan2024'd and type ~= 'STRA';
		styleattrs datacolors= (lightred lightblue);
	*footnote j=left "Generated on &sysdate";
run;
title;

/*Monthly curve*/
proc sgplot data=disease_sum noborder;
	vbar testreportmonth / barwidth=.5 group=type nooutline;
	xaxis label = 'Month of symptom onset';
	yaxis label = 'Number of cases';
	*title "MDRO case counts by month, &year_dte. ";
	keylegend / title='Disease' noborder position=bottomright;
		where testreportqtr <= '01jan2024'd and type ~= 'STRA';
		styleattrs datacolors= (lightblue lightred);

	*footnote j=left "Generated on &sysdate";
run;
title;


ods excel options (sheet_interval = "now" sheet_name = "MDRO Maps" embedded_titles='Yes');

/*Maps*/
/*Colors and legend*/
pattern1 value=solid color='CXB2D7D2'; ****lightgreen8****;
pattern2 value=solid color='CXFCEDEE'; ****palered11****;
pattern3 value=solid color='CXDE363C'; ****red2****;


legend1 label =(f="albany amt/bold" position=top j=c h=12pt "Case Count (CRE)")
 value=(f="albany amt" h=10pt c=black tick=3)
 across=1
 position=(right middle) 
 offset=(-2,3)
 space=1
 mode=reserve
 shape=bar(.15in,.15in)
 ;

 /*Map all MDRO*/
title "North Carolina CP-CRE Cases by County &year_dte."; /* add year macro */
proc gmap map=counties_projected data=map_counts_final all;
format case_display case_display.;
	id county;
	choro case_display/ discrete midpoints = 1 2 3 legend=legend1  cdefault=CXB2D7D2 /* areas with no data are also green */;
	where State= 37;
	label case_display = "Total MDRO Detected";
	
	run;

quit;

 /*Map C. auris only*/
/*Colors and legend*/
pattern1 value=solid color='CXB2D7D2'; ****lightgreen8****;
pattern2 value=solid color='CXDE363C'; ****red2****;


legend2 label =(f="albany amt/bold" position=top j=c h=12pt "Case Count (C. auris)")
 value=(f="albany amt" h=10pt c=black tick=3)
 across=1
 position=(right middle) 
 offset=(-2,3)
 space=1
 mode=reserve
 shape=bar(.15in,.15in)
 ;


title "North Carolina Candida auris Cases by County &year_dte."; /* add year macro */
proc gmap map=counties_projected data=map_counts_final all;
format case_display_cauris case_display_cauris.;
	id county;
	choro case_display_cauris/ discrete midpoints = 1 2 legend=legend2  cdefault=CXB2D7D2 /* areas with no data are also green */;
	where State= 37;
	label case_display_cauris = "Total C. auris Detected";
	
	run;

quit;

ods excel options (sheet_interval = "now" sheet_name = "Demo Epi Curves" embedded_titles='Yes');
/*Monthly curves*/

/*MDRO Class*/
ods graphics / noborder;
proc sgplot data=plots noautolegend noborder;

	vline testreportmonth / group=type  lineattrs= (thickness=4) ;
	xaxis label = 'Month of symptom onset' ;
	yaxis label = 'Number of cases' values= (0 to 60 by 20);

	keylegend / title="MDRO Class" location=inside position=topleft noborder across=1;
		where testreportqtr <= '01jan2024'd;

	*footnote height=.8 j=left "Generated on &sysdate";
run;
title;

/*Gender*/
proc sgplot data=plots noautolegend noborder;

	vline testreportmonth / group=gender lineattrs= (thickness=4);
	xaxis label = 'Month of symptom onset' ;
	yaxis label = 'Number of cases' values= (0 to 60 by 20);

	keylegend / title="Gender" location=inside position=topleft noborder across=1;
		where testreportqtr <= '01jan2024'd;

	*footnote height=.8 j=left "Generated on &sysdate";
run;
title;

/*Race*/
proc sgplot data=plots noautolegend noborder;

	vline testreportmonth / group=Race1 lineattrs= (thickness=4);
	xaxis label = 'Month of symptom onset';
	yaxis label = 'Number of cases' values= (0 to 40 by 10);

	keylegend / title="Race" location=inside position=topleft noborder across=1;
		where testreportqtr <= '01jan2024'd;

	*footnote height=.8 j=left "Generated on &sysdate";
run;
title;

/*Ethnicity*/
proc sgplot data=plots noautolegend noborder ;

	vline testreportmonth / group=Hispanic  lineattrs= (thickness=4);
	xaxis label = 'Month of symptom onset';
	yaxis label = 'Number of cases' values= (0 to 40 by 10);

	keylegend / title="Hispanic Ethnicity" location=inside position=topleft noborder across=1;
		where testreportqtr <= '01jan2024'd;

	*footnote height=.8 j=left "Generated on &sysdate";
run;
title;

/*Age*/
proc sgplot data=plots noautolegend noborder;

	vline testreportmonth / group=age_group  lineattrs= (thickness=4);
	xaxis label = 'Month of symptom onset';
	yaxis label = 'Number of cases' values= (0 to 40 by 10);

	keylegend / title="Age Group" location=inside position=topleft noborder across=1;
		where testreportqtr <= '01jan2024'd;

	*footnote height=.8 j=left "Generated on &sysdate";
run;
title;

ods excel options (sheet_interval = "now" sheet_name = "Risk Tables" embedded_titles='Yes');

title justify=left height=10pt font='Helvetica' "&year_dte. Case counts by quarter, travel, hospitalization, healthcare exp., and rurality (%)";


proc print data=equity_final_pcts noobs label;run;


title;footnote;
ods excel options (sheet_interval = "now" sheet_name = "Risk Epi Curves" embedded_titles='Yes');

/*Health Equity Plots*/
/*Travel*/
proc sgplot data=equity_plots noautolegend noborder ;

	vline testreportmonth / group=travel lineattrs= (thickness=4);
	xaxis label = 'Month of symptom onset';
	yaxis label = 'Number of cases' values= (0 to 40 by 10);

	keylegend / title="History of Travel" location=inside position=topleft noborder across=1;
		where DATE_FOR_REPORTING <= '01jan2024'd;

	*footnote height=.8 j=left "Generated on &sysdate";
run;
title;

/*Hospitalizations*/
proc sgplot data=equity_plots noautolegend noborder ;

	vline testreportmonth / group=hospitalized_new   lineattrs= (thickness=4) ;
	xaxis label = 'Month of symptom onset';
	yaxis label = 'Number of cases' values= (0 to 40 by 10);

	keylegend / title="Hospitalization Status" location=inside position=topleft noborder across=1;
		where DATE_FOR_REPORTING <= '01jan2024'd;

	*footnote height=.8 j=left "Generated on &sysdate";
run;
title;

/*Healthcare Experience*/
proc sgplot data=equity_plots noautolegend noborder;

	vline testreportmonth / group=hce_plot lineattrs= (thickness=4);
	xaxis label = 'Month of symptom onset';
	yaxis label = 'Number of cases' values= (0 to 20 by 5);

	keylegend / title="Healthcare Experience" location=inside position=topleft noborder across=1;
		where DATE_FOR_REPORTING <= '01jan2024'd and hce_plot not in ('Missing', 'Unknown', 'Surgery/Hemodialysis/Other Surg.', 'None') ;

	*footnote height=.8 j=left "Generated on &sysdate";
run;
title;

/*Rural IR*/
proc sgplot  data=hlth_equity_density_month_2 noborder noautolegend;
*title 'Monthly Incidence Rate / 100,000 population Among Rural and Urban Counties (N.C.)';
	styleattrs datacontrastcolors=(darkblue darkred);

	series x=testreportmonth y=mdro_NONrural_IR / lineattrs=(thickness=4) ;
	series x=testreportmonth y=mdro_rural_IR / lineattrs=(thickness=4) ;
	*series x=testreportweek y=four_week_moving_avg_suburban;

		keylegend / title="Residcency of Case" location=inside position=topleft noborder across=1;

	yaxis label="Incidence Rate / 100k";
	xaxis label="Month of Reporting";

run;
title;

/*Healthcare Experience*/
proc sgplot data=equity_plots noautolegend noborder;

	vline testreportmonth / group=screening_event lineattrs= (thickness=4);
	xaxis label = 'Month of symptom onset';
	yaxis label = 'Number of cases' values= (0 to 40 by 10);

	keylegend / title="MDRO Identified in screening" location=inside position=topleft noborder across=1;
		where DATE_FOR_REPORTING <= '01jan2024'd ;

	*footnote height=.8 j=left "Generated on &sysdate";
run;
title;


ods excel close;


/*fin*/
