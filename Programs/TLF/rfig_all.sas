********************************************************************
Filename: rldemo

Author: Ali

Date: 11 aug 2023

SAS: SAS 9.4 (TS2M0)

-------------------------------------------------------------------------------

MODIFICATION HISTORY:

<DD-MON-YYYY>, <Firstname Lastname>

<Description>

***************************************************************************/;
ods rtf file ="E:\Ali_Clinical\SAS BA BE_course\OUTPUT\Figure\dummy1.rtf" style=styles.test;


proc format;
   value agefmt
   20-30 = "20 (*ESC*){unicode '2264'x} 30"
   31-40 = "31 (*ESC*){unicode '2264'x} 40"
   41-50 = "41 (*ESC*){unicode '2264'x} 50"
   51-60 = "51 (*ESC*){unicode '2264'x} 60"
   61-70 = "61 (*ESC*){unicode '2264'x} 70"
   ;
run;

proc sgplot data=sashelp.heart noautolegend;
   title1 "Cholesterol Level by Age Range";
   styleattrs datacolors=(red green purple orange cyan) ;
   vbox cholesterol / category=AgeAtStart group=AgeAtStart;
   *format AgeAtStart agefmt.;
run;


libname raw 'E:\Ali_Clinical\RAW';
libname sdtm 'E:\Ali_Clinical\SAS BA BE_course\SDTM';
libname ADAM 'E:\Ali_Clinical\SAS BA BE_course\ADAM';


%macro _RTFSTYLE_;

proc template;
 define style styles.test;
     parent=styles.rtf;
    replace fonts /
     'BatchFixedFont' = ("Courier New",9pt)
     'TitleFont2' = ("Courier New",9pt)
     'TitleFont' = ("Courier New",9pt)
     'StrongFont' = ("Courier New",9pt)
     'EmphasisFont' = ("Courier New",9pt)
     'FixedEmphasisFont' = ("Courier New",9pt)
     'FixedStrongFont' = ("Courier New",9pt)
     'FixedHeadingFont' = ("Courier New",9pt)
     'FixedFont' = ("Courier New",9pt)
     'headingEmphasisFont' = ("Courier New",9pt)
     'headingFont' = ("Courier New",9pt)
     'docFont' = ("Courier New",9pt);
      replace table from output /
      cellpadding = 0pt
      cellspacing = 0pt
	    borderwidth = 0.50pt
      background=white
      frame=void;
	 replace color_list	/
     'link' = black
     'bgH' = white
     'fg' = black
     'bg' = white;

	 replace Body from Document /
      bottommargin = 1.00in
      topmargin = 1.00in
      rightmargin = 1.00in
      leftmargin = 1.00in; 
   end;
run;

%MEND _RTFSTYLE_;
%_RTFSTYLE_;

data adlb;
set adam.adlb;
if paramcd eq "CREAT";

if age ne . and age le 65 then agegr1="<=65";
if age ne . and age gt 65 then agegr1=">65";

keep usubjid aval agegr1 age;
run;

data lb2;
set adlb;
label cholesterol ="Creatinine (umol/L)";
by usubjid;

cholesterol=aval;
AgeAtStart=agegr1;
run;




title1 j=l "AIRIS PHARMA Private Limited.";
title2 j=l "Protocol: 043-1810";
title3 j=c "Table 16.1.1  Creatinine (umol/L) Level by Age Range (Safety Population)";

options orientation=landscape;
ods escapechar='^';
ods rtf file ="E:\Ali_Clinical\SAS BA BE_course\OUTPUT\Figure\16_1_1.rtf" style=styles.test;

proc sgplot data=lb2 noautolegend;
   styleattrs datacolors=(red green purple orange cyan)
    ;
   vbox cholesterol / category=AgeAtStart group=AgeAtStart;
   *format AgeAtStart agefmt.;
run;

ODS _all_ close; 

*******************2nd Figure**************************;



/*Example :01*/

data vs;
set adam.advs;
if PARAM in ("SYSTOLIC BLOOD PRESSURE (mmHg)"
"DIASTOLIC BLOOD PRESSURE (mmHg)") ;
keep usubjid PARAM aval avisit ;
run;
proc sort nodupkey;by usubjid  avisit  PARAM ;run;

proc transpose data=vs out=vs1;
by usubjid avisit ;
id param;
var aval;
run;

data vs2;
set vs1;
diastolic=input(DIASTOLIC_BLOOD_PRESSURE__mmHg_, best.);
systolic=input(SYSTOLIC_BLOOD_PRESSURE__mmHg_, best.);
run;


title1 j=l "AIRIS PHARMA Private Limited.";
title2 j=l "Protocol: 043-1810";
title3 j=c "Table 16.1.2  Distribution of Blood Pressure";

options orientation=landscape;
ods escapechar='^';
ods rtf file ="E:\Ali_Clinical\SAS BA BE_course\OUTPUT\Figure\16_1_2.rtf" style=styles.test;

proc sgplot data=vs2;
   histogram diastolic / fillattrs=graphdata1 transparency=0.7 binstart=40 binwidth=10;
   density diastolic / lineattrs=graphdata1;
   histogram systolic / fillattrs=graphdata2 transparency=0.5 binstart=40 binwidth=10;
   density systolic / lineattrs=graphdata2;
   keylegend / location=inside position=topright border across=2;
   yaxis grid;
   xaxis display=(nolabel) ;
run;

ods _all_ close;

**********************3rd Figure**********************;


data adlb;
set adam.adlb;
value=aval;
test=paramcd;
drug=trta;
if paramcd in ("CHOL" "ALT") and trta ne '';
keep value test drug;
run;


title1 j=l "AIRIS PHARMA Private Limited.";
title2 j=l "Protocol: 043-1810";
title3 j=c "Table 16.1.3  Distribution of Maximum Liver Function Test Values by Treatment (safety population)";

options orientation=landscape;
ods escapechar='^';
ods rtf file ="E:\Ali_Clinical\SAS BA BE_course\OUTPUT\Figure\16_1_3.rtf" style=styles.test;




proc sgplot data=adlb;
   vbox value / category=test group=drug;
   xaxis label="Treatment";
   keylegend / title="Drug Type";
run; 

ods _all_ close;

***************************4TH FIGURE***********************;


proc template;
  define style styles.mystyle;
  parent=styles.default;
    style GraphData1 from GraphData1 /
          contrastcolor=orange linestyle=1;
    style GraphData2 from GraphData2 /
          contrastcolor=purple linestyle=1;
  end;
run;

ods listing close;
ods html file='test.html' path='.' style=styles.mystyle;

ods graphics on / reset imagename='linestyle' imagefmt=gif width=600px height=400px border=off;

proc sgplot data=sashelp.class;
  reg x=weight y=height / group=sex degree=3;
  reg x=weight y=height / lineattrs=(color=blue pattern=dash) 
                          markerattrs=(color=black symbol=circlefilled);
run;

%include "E:\Ali_Clinical\SAS BA BE_course\MACROS\_run_toc.sas";
%include "E:\Ali_Clinical\SAS BA BE_course\MACROS\mpageof.sas";
%include "E:\Ali_Clinical\SAS BA BE_course\MACROS\mtitlet.sas";

ods html close;
ods listing;

%mtitlet (progid=rfg1);


proc sgplot data=adam.adsl;
  reg x=weight y=height / group=sex degree=3;
  reg x=weight y=height / lineattrs=(color=blue pattern=dash) 
                          markerattrs=(color=black symbol=circlefilled);
run;

ods html close;
ods listing;

ods _all_ close;

%mpageof;

