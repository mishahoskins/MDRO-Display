/*Part III: import data sets and create maps: NOT USED IN FINAL OUTPUT AS OF MARCH 01, 2025*/

/*Reset Macros in case running separately*/
options compress=yes;
options nofmterr;
title;footnote;

data records;
set SASdata.recordssas;
run;




/*Project map West-East (SAS flips it for some reason) using gproject with "degrees"*/
proc gproject data=maps.counties out=counties_projected degrees;
id county;
run;


/*Reassign counties their FIPS # with no leading 0's*/
data counties_numeric;
set records;

if owning_jd= "Alamance County" then county =1;
if owning_jd="Alexander County " then county=3;
if owning_jd="Alleghany County " then county=5;
if owning_jd="Anson County " then county=7;
if owning_jd="Ashe County " then county=9;
if owning_jd="Avery County " then county=11;
if owning_jd="Beaufort County " then county=13;
if owning_jd="Bertie County " then county=15;
if owning_jd="Bladen County " then county=17;
if owning_jd="Brunswick County " then county=19;
if owning_jd="Buncombe County " then county=21;
if owning_jd="Burke County " then county=23;
if owning_jd="Cabarrus County " then county=25;
if owning_jd="Caldwell County " then county=27;
if owning_jd="Camden County " then county=29;
if owning_jd="Carteret County " then county=31;
if owning_jd="Caswell County " then county=33;
if owning_jd="Catawba County " then county=35;
if owning_jd="Chatham County " then county=37;
if owning_jd="Cherokee County " then county=39;
if owning_jd="Chowan County " then county=41;
if owning_jd="Clay County " then county=43;
if owning_jd="Cleveland County " then county=45;
if owning_jd="Columbus County " then county=47;
if owning_jd="Craven County " then county=49;
if owning_jd="Cumberland County " then county=51;
if owning_jd="Currituck County " then county=53;
if owning_jd="Dare County " then county=55;
if owning_jd="Davidson County " then county=57;
if owning_jd="Davie County " then county=59;
if owning_jd="Duplin County " then county=61;
if owning_jd="Durham County " then county=63;
if owning_jd="Edgecombe County " then county=65;
if owning_jd="Forsyth County " then county=67;
if owning_jd="Franklin County " then county=69;
if owning_jd="Gaston County " then county=71;
if owning_jd="Gates County " then county=73;
if owning_jd="Graham County " then county=75;
if owning_jd="Granville County " then county=77;
if owning_jd="Greene County " then county=79;
if owning_jd="Guilford County " then county=81;
if owning_jd="Halifax County " then county=83;
if owning_jd="Harnett County " then county=85;
if owning_jd="Haywood County " then county=87;
if owning_jd="Henderson County " then county=89;
if owning_jd="Hertford County " then county=91;
if owning_jd="Hoke County " then county=93;
if owning_jd="Hyde County " then county=95;
if owning_jd="Iredell County " then county=97;
if owning_jd="Jackson County " then county=99;
if owning_jd="Johnston County " then county=101;
if owning_jd="Jones County " then county=103;
if owning_jd="Lee County " then county=105;
if owning_jd="Lenoir County " then county=107;
if owning_jd="Lincoln County " then county=109;
if owning_jd="McDowell County " then county=111;
if owning_jd="Macon County " then county=113;
if owning_jd="Madison County " then county=115;
if owning_jd="Martin County " then county=117;
if owning_jd="Mecklenburg County " then county=119;
if owning_jd="Mitchell County " then county=121;
if owning_jd="Montgomery County " then county=123;
if owning_jd="Moore County " then county=125;
if owning_jd="Nash County " then county=127;
if owning_jd="New Hanover County " then county=129;
if owning_jd="Northampton County " then county=131;
if owning_jd="Onslow County " then county=133;
if owning_jd="Orange County " then county=135;
if owning_jd="Pamlico County " then county=137;
if owning_jd="Pasquotank County " then county=139;
if owning_jd="Pender County " then county=141;
if owning_jd="Perquimans County " then county=143;
if owning_jd="Person County " then county=145;
if owning_jd="Pitt County " then county=147;
if owning_jd="Polk County " then county=149;
if owning_jd="Randolph County " then county=151;
if owning_jd="Richmond County " then county=153;
if owning_jd="Robeson County " then county=155;
if owning_jd="Rockingham County " then county=157;
if owning_jd="Rowan County " then county=159;
if owning_jd="Rutherford County " then county=161;
if owning_jd="Sampson County " then county=163;
if owning_jd="Scotland County " then county=165;
if owning_jd="Stanly County " then county=167;
if owning_jd="Stokes County " then county=169;
if owning_jd="Surry County " then county=171;
if owning_jd="Swain County " then county=173;
if owning_jd="Transylvania County " then county=175;
if owning_jd="Tyrrell County " then county=177;
if owning_jd="Union County " then county=179;
if owning_jd="Vance County " then county=181;
if owning_jd="Wake County " then county=183;
if owning_jd="Warren County " then county=185;
if owning_jd="Washington County " then county=187;
if owning_jd="Watauga County " then county=189;
if owning_jd="Wayne County " then county=191;
if owning_jd="Wilkes County " then county=193;
if owning_jd="Wilson County " then county=195;
if owning_jd="Yadkin County " then county=197;
if owning_jd="Yancey County " then county=199;


run;

/*Create count for each numeric county*/
proc sql;
create table map_counts as
select

	county,
	owning_jd,
	sum (case when type in ('CRE') then 1 else 0 end) as tot_cre,
	sum (case when type in ('CAURIS') then 1 else 0 end) as tot_cauris,
	sum (case when type in ('CAURIS' , 'CRE') then 1 else 0 end) as tot_mdro


from counties_numeric
group by county 
;
quit;

/*Add state variable*/
data map_counts;
set map_counts;

	state=37;

run;

/*Create buckets: adjust as necessary but make sure to update values in labels below*/
data map_counts_final;
set map_counts;

	if tot_cre <=5 then case_display=1;
	if 10=> tot_cre > 5 then case_display=2;
	if 10 < tot_cre then case_display=3;


	if tot_cauris < 1 then case_display_cauris=1;
	if tot_cauris => 1 then case_display_cauris=2;


run;
/*Format buckets*/
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



/*Save SAS sets*/

data SASdata.map_counts_final ;
set map_counts_final;
run;

data SASdata.counties_projected ;
set counties_projected;
run;

data SASdata.case_display ;
set case_display;
run;

data SASdata.case_display_cauris ;
set case_display_cauris;
run;
/*Test run your maps*/


/*Maps*/
/*Colors and legend*/
pattern1 value=solid color='CX90B0D9'; ****Very light greenish blue****;
pattern2 value=solid color='CXE5C5C2'; ****Pale yellowish pink****;
pattern3 value=solid color='CX99615C'; ****Dark yellowish pink****;


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
	choro case_display/ discrete midpoints = 1 2 3 legend=legend1  cdefault=CX90B0D9 /* areas with no data are also green */;
	where State= 37;
	label case_display = "Total MDRO Detected";
	
	run;

quit;

 /*Map C. auris only*/
/*Colors and legend*/
pattern1 value=solid color='CX90B0D9'; ****Very light greenish blue****;
pattern2 value=solid color='CX99615C'; ****Dark yellowish pink****;


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
	choro case_display_cauris/ discrete midpoints = 1 2 legend=legend2  cdefault=CX90B0D9 /* areas with no data are also green */;
	where State= 37;
	label case_display_cauris = "Total C. auris Detected";
	
	run;

quit;
