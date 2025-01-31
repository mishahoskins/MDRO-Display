/*Multi-drug resistant organism quarterly report and health equity report*/

/*Purpose: To create a quarterly metric survielling the state of MDROs in North Carolina along demographic and risk factor criteria*/

/*Author: M. Hoskins 10/01/2024 
		Most recent edits:  11/18/2024 <---- add a line for each time we make major edits!
							12/20/2024 


Instructions:

Background: This code uses MACROS, cleaning steps, SAS generated mapping, and SQL tables to create the following:
				i.	Various table outputs of carbapenm resistant enterbacterales and c. auris infections reported in NC and reported to the CDC (reportable conditions in N.c.)
					See https://epi.dph.ncdhhs.gov/cd/hai/docs/MDRO-Flyer_4.28.20.pdf for more information.
				ii.	Maps of MDRO incidence cumulatively through the most recent quarter of investigation by NC county. 
				iii.Visualization of selected tables in graph form.
				iv. Outputs in traditional .xlsx files for appropriate distrubtion or VBA/Power BI/Microsoft Office visualization creation.
				--//--
				This code serves as the framework for the Quarterly MDRO report and Annual Health Equity report

Accesses needed:

	i.		T or shared drive.
	ii.		Z drive (for denormalized tables).
	iii.	NCEDSS access for addtional CRE/cauris outputs.


Step 1:

	Run macros here. These serve primarily as pathways and date basis for the remainder of the report. 

Step 2: 
	
	Run cleaning steps (Parts I & II). These are modeled directly after the denormalized table creation for our interactive dashboard found here: https://epi.dph.ncdhhs.gov/cd/figures.html
	**IMPORTANT** Double check all numbers to ensure they align. If they do not reach out to the dashboard creation team to check if they have updated any creation or classifcation steps that we
				  need to mirror. CRE and C. auris numbers should match 1:1. 

	Part II is table creation. All tables are output here: T:\HAI\Code library\Epi curve example\SASData in the event you need specific tables for alternate analyses (see CRE screen analysis for example).

Step 3: 
	
	Maps! There are minimal edits necessary here. Although a table map in R, Power BI, or Excel may look "cleaner" these require minimal manipulation. 

Step 4: 

	Excel table outputs. These will facilitate (hopefully) easy creation of the quarterly MDRO report.


You should be able to run this code all the way through from this step alone. 

Instructions simplified:

	1. Update Macros in this code.
	2. Hit run and go get a coffee. 

Contact info:

Mikhail Hoskins : mikhail.hoskins@dhhs.nc.gov : 984-279-9535

*/





/*MACROS*/
/*Need correct denormalized table(s)*/
options compress=yes;
options nofmterr;
title;footnote;

/*Macros -- Don't update these*/
libname denorm '\\10.19.201.242\denormal\20250101'; /*This can be updated as needed to produce most recent counts; M. Hilton provides a new extract monthly*/
libname SASdata 'T:\HAI\Code library\Epi curve example\SASData'; /*SAS datasets location*/
%let ncedssdata = T:\HAI\Code library\Epi curve example/ncedss extracts;*<----- Pathway to NCEDSS extracts for additional data (do not need to update);

/*Macros -- Update these*/
%let qtr_dte = 31dec2023; *<------ Set the end date of the quarter you want to look at end dates for each quarter are: Q1-MARCH31 Q2-JUNE30 Q3-SEPTEMBER30 Q4-DECEMBER31. Format as DDMMMYYYY;
%put &qtr_dte;
%let qtr_num = Q4; *<----- Set the quarter number (Q1, Q2, Q3, or Q4);
%put &qtr_num;
%let year_dte = 2023;*<----- Set the year;
%put &year_dte;

%let qtr_end_transpose = _31_Dec_2023; *<----- write the quarter end date in the format _DD_Mmm_YYYY for the transpose code, it will save a step later on;
%put &qtr_end_transpose;




%let caurisfile = cauris_risk history_2023; *<----- C. auris file name (whatever you save it as);
%put caurisfile;
%let CREfile = GCDCCRELineListbySpecimenCollectionDate_20241011093744; *<----- CRE file name (whatever you save it as);
%put CREfile;

%let outputpath = C:\Users\mhoskins1\Desktop\Work Files;
%put &outputpath;



/*IR denominator values for populations: 2023 Census Data found here:
T:\Surveillance\CDB Reports\Population Files

Should only need to update these once per year.

*/

/*State pop.*/
%let state_pop = 10835491;
/*Gender*/
%let male_pop =5538969;
%let female_pop =5296522;
/*Race pop.*/
%let white_pop = 7564526;
%let blackaa_pop = 2392417;
%let asian_pop = 399358;
%let napi_pop = 16677; /*Native Hawaiian/Pacific Islander in CDC census*/
%let other_race_pop = 289706; /*Two or more races in Census track data*/
%let aian_pop = 172807;
/*Age pop.*/
%let age_04 = 609770;
%let age_0517 = 1690945;
%let age_1824 = 990587;
%let age_2549 = 3408095;
%let age_5064 = 2037593;
%let age_65 = 1751094;
/*Hispanic*/
%let hisp_yes = 1238421;
%let hisp_no = 9597070;


/*Rurality Pop.*/
%let ruraltotalpop = 3591696;
%let nonruralpop = 7243795;/*Urban + Suburban counties = 'Non-rural' from here: https://www.oldnorthstatepolitics.com/p/blog-page_5.html*/

/*SVI populations:
If the Social Vulnerability Index (SVI) is over 0.80 we classify the county as "Vulnerable"

CDC Link: https://svi.cdc.gov/map/
		~and~
Description of EDRC (Economically Disadvantaged Rural Communities) : https://files.nc.gov/dps/documents/2022-08/BRIC2022-SVImap.pdf?VersionId=DuyqrHwlGqToM1aqh1k2_uZRsItM7fqn */

%let svihighpop = 1198340;
%let svilowpop = 9637151;




/*Population denominators for SVI and density by race 2023. File here: T:\HAI\Code library\Epi curve example\ncedss extracts derived from CDC census tracks*/
	/*SVI*/
%let svihighwhite = 608066;
%let svihighblack = 451531;
%let svihighaian = 78087;
%let svihighasian = 17640;
%let svihighnhpi = 3232; 
%let svihighother = 39784; /*Two or more races in Census track data*/

%let svilowwhite = 6956460;
%let svilowblack = 1940886;
%let svilowaian = 94720;
%let svilowasian = 381718;
%let svilownhpi = 13445; 
%let svilowother = 249922; /*Two or more races in Census track data*/

	/*Density*/
%let ruralwhite = 2649026;
%let ruralblack = 694424;
%let ruralaian = 100159;
%let ruralasian = 56704;
%let ruralnhpi = 5265; 
%let ruralother = 86118; /*Two or more races in Census track data*/

%let nonruralwhite = 4915500;
%let nonruralblack = 1697993;
%let nonruralaian = 72648;
%let nonruralasian = 342654;
%let nonruralnhpi = 11412;
%let nonruralother = 203588; /*Two or more races in Census track data*/



/*Run other codes to create outputs*/
%INCLUDE "T:\HAI\Code library\Epi curve example\SAS Codes\Part I_MDRO_quarterly report.sas";
%INCLUDE "T:\HAI\Code library\Epi curve example\SAS Codes\Part II_MDRO_quarterly report.sas";/*Incidence rate code embedded in Part II*/
%INCLUDE "T:\HAI\Code library\Epi curve example\SAS Codes\Part III_MDRO_quarterly report.sas";
%INCLUDE "T:\HAI\Code library\Epi curve example\SAS Codes\Part IV_MDRO_quarterly report.sas";

