/*Race by County Denominator file creation

Mikhail Hoskins -- 01/25/2025

SUMLEV				STATE				AGEGRP			WA_MALE	WA_FEMALE	BA_MALE	BA_FEMALE	IA_MALE	IA_FEMALE						
Geographic level	North Carolina		0=Total			White alone			Black/A.A. alone	American Indain/Alaska Native alone

AA_MALE	AA_FEMALE	NA_MALE	NA_FEMALE								TOM_MALE	TOM_FEMALE
Asian alone			Native Hawaiian/Pacific Islander alone			Two or more races


*/


/*NCEDSS folder: Census data */
proc import
datafile = "&ncedssdata./census_race_county_2023.xlsx"
out=census_race_county
dbms=xlsx replace;
sheet= "analysis";
getnames=yes;

run;

proc print data=census_race_county;run;

/*Assign rural and high SVI counties a binary variable to categorize them in our summary counts*/
data census_svi_rural;
set census_race_county;

	/*Rurality
			1=nonrural
			0=rural
	*/
	density=.;

	if CTYNAME=  "Alamance County"
	or CTYNAME=  "Brunswick County"
	or CTYNAME=  "Buncombe County"
	or CTYNAME=  "Burke County"
	or CTYNAME=  "Caldwell County"
	or CTYNAME=  "Catawba County"
	or CTYNAME=  "Chatham County"
	or CTYNAME=  "Cumberland County"
	or CTYNAME=  "Davidson County"
	or CTYNAME=  "Davie County"
	or CTYNAME=  "Durham County"
	or CTYNAME=  "Edgecombe County"
	or CTYNAME=  "Forsyth County"
	or CTYNAME=  "Guilford County"
	or CTYNAME=  "Haywood County"
	or CTYNAME=  "Henderson County"
	or CTYNAME=  "Hoke County"
	or CTYNAME=  "Iredell County"
	or CTYNAME=  "Johnston County"
	or CTYNAME=  "Mecklenburg County"
	or CTYNAME=  "Nash County"
	or CTYNAME=  "New Hanover County"
	or CTYNAME=  "Onslow County"
	or CTYNAME=  "Orange County"
	or CTYNAME=  "Pitt County"
	or CTYNAME=  "Stokes County"
	or CTYNAME=  "Union County"
	or CTYNAME=  "Wake County"
	or CTYNAME=  "Wayne County"

	then density=1;

	else density=0;

	/*SVI
		1= GE than 0.80
		0= LT than 0.80
	*/
		svi=.;

	if CTYNAME= 'Lenoir County'
	or CTYNAME= 'Robeson County'
	or CTYNAME= 'Scotland County'
	or CTYNAME= 'Greene County'
	or CTYNAME= 'Halifax County'
	or CTYNAME= 'Warren County'
	or CTYNAME= 'Richmond County'
	or CTYNAME= 'Vance County'
	or CTYNAME= 'Bertie County'
	or CTYNAME= 'Sampson County'
	or CTYNAME= 'Anson County'
	or CTYNAME= 'Wayne County'
	or CTYNAME= 'Edgecombe County'
	or CTYNAME= 'Wilson County'
	or CTYNAME= 'Duplin County'
	or CTYNAME= 'Columbus County'
	or CTYNAME= 'Hertford County'
	or CTYNAME= 'Cumberland County'
	or CTYNAME= 'Swain County'
	or CTYNAME= 'Hyde County'

	then svi=1;

	else svi=0;

run;

proc print data=census_svi_rural;run;


proc sql;
create table race_county_svi as
select

	svi "1 = SVI greater than or equal to 0.80",
	sum (WA_MALE +  WA_FEMALE)  as svi_white_pop,
	sum (BA_MALE +  BA_FEMALE)  as svi_blackaa_pop,
	sum (IA_MALE +  IA_FEMALE)  as svi_aian_pop,
	sum (AA_MALE +  AA_FEMALE)  as svi_asian_pop,
	sum (NA_MALE +  NA_FEMALE)  as svi_nhpi_pop,
	sum (TOM_MALE +  TOM_FEMALE)  as svi_oth_pop



from census_svi_rural
	group by svi

;

create table race_county_rurality as
select

	density "0=Rural population",
	sum (WA_MALE +  WA_FEMALE)  as den_white_pop,
	sum (BA_MALE +  BA_FEMALE)  as den_blackaa_pop,
	sum (IA_MALE +  IA_FEMALE)  as den_aian_pop,
	sum (AA_MALE +  AA_FEMALE)  as den_asian_pop,
	sum (NA_MALE +  NA_FEMALE)  as den_nhpi_pop,
	sum (TOM_MALE +  TOM_FEMALE)  as den_oth_pop

from census_svi_rural
	group by density
;	

create table race_county as
select

	CTYNAME "County Name",
	sum (WA_MALE +  WA_FEMALE)  as white_pop,
	sum (BA_MALE +  BA_FEMALE)  as blackaa_pop,
	sum (IA_MALE +  IA_FEMALE)  as aian_pop,
	sum (AA_MALE +  AA_FEMALE)  as asian_pop,
	sum (NA_MALE +  NA_FEMALE)  as nhpi_pop,
	sum (TOM_MALE +  TOM_FEMALE)  as oth_pop

from census_svi_rural
	group by CTYNAME
;

quit;

proc print data=race_county_svi noobs label;run;
proc print data=race_county_rurality noobs label;run;
proc print data=race_county noobs label;run;
