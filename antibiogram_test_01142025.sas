/*Antibiogram SAS Code Practice*/


libname antibio "C:\Users\mhoskins1\Desktop\Work Files\antibiogram";
libname archive "C:\Users\mhoskins1\Desktop\Work Files\NHSN\2019-2024 Archive data"; /*2019-2024 data*/


data antibio_raw;
set archive.linelisting_antibiogram;

run;


proc contents data=antibio_raw;run;

proc freq data=antibio_raw order=freq; tables bedsize /norow nocol nopercent nocum;run;
/*Antibiogram Macro to replicate this equation:
		%S= (susceptible isolates / total isolates) x 100
*/

/*Step 1: Create a table of the 10-12 most common Pathogens identified*/
data antibio_path;
set antibio_raw;

format pathogen_2 $32.;
format med_class $12.;
pathogen_2= ' ';

if pathogen in ('EC') then pathogen_2 = 'Escherichia coli';
if pathogen in ('ENTFS') then pathogen_2 = 'Enterococcus faecalis';
if pathogen in ('PA') then pathogen_2 = 'Pseudomonas aeruginosa';
if pathogen in ('KP') then pathogen_2 = 'Klebsiella pneumoniae';
if pathogen in ('SA') then pathogen_2 = 'Staphylococcus aureus';
if pathogen in ('SE') then pathogen_2 = 'Staphylococcus epidermidis';
if pathogen in ('CA') then pathogen_2 = 'Candida albicans';
if pathogen in ('PM') then pathogen_2 = 'Proteus mirabilis';
if pathogen in ('ENTFM') then pathogen_2 = 'Enterococcus faecium';
if pathogen in ('CG') then pathogen_2 = 'Candida glabrata';
if pathogen in ('ENCCX') then pathogen_2 = 'Enterobacter cloacae complex';
if pathogen in ('BF') then pathogen_2 = 'Bacteroides fragilis';


run;	

proc sql;
create table pathogen_tot as
select
	sum (case when med_class in ('AMOX') then . else . end) as dummy "Disease Reported",

	sum (case when pathogen_2 in ('Escherichia coli') then 1 else 0 end) as EC "Escherichia coli",
	sum (case when pathogen_2 in ('Klebsiella pneumoniae') then 1 else 0 end) as KP "Klebsiella pneumoniae",
	sum (case when pathogen_2 in ('Candida albicans') then 1 else 0 end) as CA "Candida albicans",
	sum (case when pathogen_2 in ('Candida glabrata') then 1 else 0 end) as CG "Candida glabrata",
	sum (case when pathogen_2 in ('Enterobacter cloacae complex') then 1 else 0 end) as CNCCX "Enterobacter cloacae complex",
	sum (case when pathogen_2 in ('Pseudomonas aeruginosa') then 1 else 0 end) as PA "Pseudomonas aeruginosa",
	sum (case when pathogen_2 in ('Staphylococcus aureus') then 1 else 0 end) as SA "Staphylococcus aureus",
	sum (case when pathogen_2 in ('Staphylococcus epidermidis') then 1 else 0 end) as SE "Staphylococcus epidermidis",
	sum (case when pathogen_2 in ('Enterococcus faecalis') then 1 else 0 end) as BF "Enterococcus faecalis",
	sum (case when pathogen_2 in ('Enterococcus faecium') then 1 else 0 end) as ENTFM "Enterococcus faecium"



/*
	sum (case when pathogen_2 in ('Bacteroides fragilis') then 1 else 0 end) as BF "Bacteroides fragilis",
	sum (case when pathogen_2 in ('Candida glabrata') then 1 else 0 end) as CG "Bacteroides fragilis",
	sum (case when pathogen_2 in ('Proteus mirabilis') then 1 else 0 end) as PM "Proteus mirabilis",
*/


from antibio_path 
where pathogen_2 not in (' ')

;
quit;

proc print data=pathogen_tot noobs label;run;

/*Step 2: This macro takes each treatment variable and creates a table that shows the % susceptible for each of the 10-12 most common Pathogens. Remember 30+ pathogens must be isolated to create an antibiogram*/

%macro antibio_all_2 (abx=);

proc sql;
create table antibio_calc_1_&abx as
select

	/*eventtype,*/
	pathogen_2 'Pathogen Isolated',
	sum (case when  &abx in ('S', 'S-DD') then 1 else 0 end) as path_&abx._SUSC_ "Pathogen + &abx Susceptible",
	sum (case when  &abx not in (' ','N') then 1 else 0 end) as path_&abx._iso_ "Pathogen + &abx Isolated Total",
	
		calculated path_&abx._SUSC_  / calculated path_&abx._iso_ as pct_susc_&abx "Percent Susceptible &abx" format percent10.1


from antibio_path
where pathogen_2 not in (' ')
	group by pathogen_2
	
	having calculated path_&abx._iso_  GE 30
;
create table antibio_calc_1a_&abx as
select 
	
	pathogen_2,
	pct_susc_&abx
	
	from antibio_calc_1_&abx
;

quit;

/*This piece transposes from columns for each treatment to columns for each pathogen*/
proc transpose data=antibio_calc_1a_&abx out=antibio_calc_2_&abx;
*by pct_susc_&abx;
id pathogen_2;

run;

*proc print data=antibio_calc_2_&abx noobsrun;

%mend antibio_all_2;


/*Run ALL treatments*/
%antibio_all_2(abx=AMOX);
%antibio_all_2(abx=AMP);
%antibio_all_2(abx=AMPSUL);
%antibio_all_2(abx=AMXCLV);
%antibio_all_2(abx=ANID);
%antibio_all_2(abx=AZT);
%antibio_all_2(abx=CASPO);
%antibio_all_2(abx=CEFAZ);
%antibio_all_2(abx=CEFEP);
%antibio_all_2(abx=CEFOT);
%antibio_all_2(abx=CEFOX);
%antibio_all_2(abx=CEFTAR);
%antibio_all_2(abx=CEFTAVI);
%antibio_all_2(abx=CEFTAZ);
%antibio_all_2(abx=CEFTOTAZ);
%antibio_all_2(abx=CEFTRX);
%antibio_all_2(abx=CEFUR);
%antibio_all_2(abx=CHLOR);
%antibio_all_2(abx=CIPRO);
%antibio_all_2(abx=CLIND);
%antibio_all_2(abx=COL);
%antibio_all_2(abx=CTET);
%antibio_all_2(abx=DAPTO);
%antibio_all_2(abx=DORI);
%antibio_all_2(abx=DOXY);
%antibio_all_2(abx=ERTA);
%antibio_all_2(abx=ERYTH);
%antibio_all_2(abx=FLUCO);
%antibio_all_2(abx=FLUCY);
%antibio_all_2(abx=GENT);
%antibio_all_2(abx=GENTHL);
%antibio_all_2(abx=IMI);
%antibio_all_2(abx=IMIREL);
%antibio_all_2(abx=ITRA);
%antibio_all_2(abx=LEVO);
%antibio_all_2(abx=LNZ);
%antibio_all_2(abx=MERO);
%antibio_all_2(abx=MERVAB);
%antibio_all_2(abx=METH);
%antibio_all_2(abx=MICA);
%antibio_all_2(abx=MINO);
%antibio_all_2(abx=MOXI);
%antibio_all_2(abx=OX);
%antibio_all_2(abx=PB);
%antibio_all_2(abx=PENG);
%antibio_all_2(abx=PIP);
%antibio_all_2(abx=PIPTAZ);
%antibio_all_2(abx=QUIDAL);
%antibio_all_2(abx=RIF);
%antibio_all_2(abx=STREPHL);
%antibio_all_2(abx=TETRA);
%antibio_all_2(abx=TICLAV);
%antibio_all_2(abx=TIG);
%antibio_all_2(abx=TMZ);
%antibio_all_2(abx=TOBRA);
%antibio_all_2(abx=VANC);
%antibio_all_2(abx=VORI);
%antibio_all_2(abx=AZITH);
%antibio_all_2(abx=CEPH);
%antibio_all_2(abx=CLARTH);
%antibio_all_2(abx=GATI);
%antibio_all_2(abx=METRO);
%antibio_all_2(abx=OFLOX);

/*Now merge them together for one big table*/
data merge_antibio;
set 
antibio_calc_2_AMOX
antibio_calc_2_AMP
antibio_calc_2_AMPSUL
antibio_calc_2_AMXCLV
antibio_calc_2_ANID
antibio_calc_2_AZT
antibio_calc_2_CASPO
antibio_calc_2_CEFAZ
antibio_calc_2_CEFEP
antibio_calc_2_CEFOT
antibio_calc_2_CEFOX
antibio_calc_2_CEFTAR
antibio_calc_2_CEFTAVI
antibio_calc_2_CEFTAZ
antibio_calc_2_CEFTOTAZ
antibio_calc_2_CEFTRX
antibio_calc_2_CEFUR
antibio_calc_2_CHLOR
antibio_calc_2_CIPRO
antibio_calc_2_CLIND
antibio_calc_2_COL
antibio_calc_2_CTET
antibio_calc_2_DAPTO
antibio_calc_2_DORI
antibio_calc_2_DOXY
antibio_calc_2_ERTA
antibio_calc_2_ERYTH
antibio_calc_2_FLUCO
antibio_calc_2_FLUCY
antibio_calc_2_GENT
antibio_calc_2_GENTHL
antibio_calc_2_IMI
antibio_calc_2_IMIREL
antibio_calc_2_ITRA
antibio_calc_2_LEVO
antibio_calc_2_LNZ
antibio_calc_2_MERO
antibio_calc_2_MERVAB
antibio_calc_2_METH
antibio_calc_2_MICA
antibio_calc_2_MINO
antibio_calc_2_MOXI
antibio_calc_2_OX
antibio_calc_2_PB
antibio_calc_2_PIPTAZ
antibio_calc_2_QUIDAL
antibio_calc_2_RIF
antibio_calc_2_TETRA
antibio_calc_2_TIG
antibio_calc_2_TMZ
antibio_calc_2_TOBRA
antibio_calc_2_VANC
antibio_calc_2_VORI
;

run;

/*Clean up the final table with labels*/
proc sql;
create table merge_antibio_final as
select
	_LABEL_ 'Treatment Susceptible',
	Escherichia_coli 'Escherichia coli',
	Klebsiella_pneumoniae 'Klebsiella pneumoniae',
	Candida_albicans 'Candida albicans',
	Candida_glabrata 'Candida glabrata',
	Enterobacter_cloacae_complex 'Enterobacter cloacae complex',
	Pseudomonas_aeruginosa 'Pseudomonas aeruginosa',
	Staphylococcus_aureus 'Staphylococcus aureus',
	Staphylococcus_epidermidis 'Stpahylococcus epidermidis',
	Enterococcus_faecalis 'Enterococcus faecalis',
	Enterococcus_faecium 'Enterococcus faecium'

from merge_antibio
;

quit;


/*ODS export*/
title; footnote;
/*Set your output pathway here*/
ods excel file="C:\Users\mhoskins1\Desktop\Work Files\anitbiogram_2019 2024_test_&sysdate..xlsx" style=meadow;

ods excel options (sheet_interval = "none" sheet_name = "antibiogram" embedded_titles='Yes');
options missing='';
proc print data=pathogen_tot noobs label;run;
proc print data=merge_antibio_final noobs label;run;

ods excel close;


/*Messing around with Proc Report for funsies
proc report data=merge_antibio_final out=antibiogram_colors;

column _LABEL_ Escherichia_coli Klebsiella_pneumoniae Candida_albicans Candida_glabrata Enterobacter_cloacae_complex Pseudomonas_aeruginosa Staphylococcus_aureus Staphylococcus_epidermidis Enterococcus_faecalis Enterococcus_faecium ;

compute Escherichia_coli;

if Escherichia_coli > $30. then do;
call define (Escherichia_coli, "style", "style={background=pink}");
end;

endcomp;

run;

proc print data=antibiogram_colors;run;

*/

