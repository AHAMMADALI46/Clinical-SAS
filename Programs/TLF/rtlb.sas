********************************************************************
Filename: Table 14.4.1 Shift Table from Baseline to Period02 end (Safety Population)

Author: Ali

Date: 07jul2023

SAS: SAS 9.4 (TS2M0)

Platform: Windows 11

Project/Study: 

Description: <TO DEVELOP THE ADAE DATASETS>

Input: ADAM.ADLB

Output: rtlb1

Macros used: <No macros used>
%mpageof, %mtitlet, %_run_toc
-------------------------------------------------------------------------------

MODIFICATION HISTORY:

<DD-MON-YYYY>, <Firstname Lastname>

<Description>

***************************************************************************/;
/* Bringing the raw datasets*/

libname raw 'E:\Ali_Clinical\RAW';
libname sdtm 'E:\Ali_Clinical\SAS BA BE_course\SDTM';
libname ADAM 'E:\Ali_Clinical\SAS BA BE_course\ADAM';

%include "E:\Ali_Clinical\SAS BA BE_course\MACROS\_run_toc.sas";
%include "E:\Ali_Clinical\SAS BA BE_course\MACROS\mpageof.sas";
%include "E:\Ali_Clinical\SAS BA BE_course\MACROS\mtitlet.sas";



data adsl;
set adam.adsl;
if saffl="Y";
run;

data demog_1;
set adsl;
output;
trt01a="ALL";
output;
run;


data demog_2;
set demog_1;

if index(trt01a, "TEST")>0 then do; trt="TES"; ord=1; end;
if index(trt01a, "REFE")>0 then do; trt="REF"; ord=2; end;
if index(trt01a, "ALL")>0 then do; trt="ALL"; ord=3; end;

keep usubjid  trt ord sex race sexn racen;
if ord ne .;
run;

data demog_11;
set adsl;
output;
trt02a="ALL";
output;
run;


data demog_22;
set demog_11;

if index(trt02a, "TEST")>0 then do; trt="TES"; ord=1; end;
if index(trt02a, "REFE")>0 then do; trt="REF"; ord=2; end;
if index(trt02a, "ALL")>0 then do; trt="ALL"; ord=3; end;

keep usubjid  trt ord sex race sexn racen;
if ord ne .;
run;

data demog_3;
set demog_2 demog_22;
run;

proc sort data=demog_3 nodupkey; by usubjid trt; run;

/*BIG N or Total Counts*/
Proc sql noprint;
create table xx as
select trt, count(distinct usubjid) into: n1 - :n3 from demog_3
group by ord, trt
order by ord;
quit;

%put &n3;

/*ADLB*/

data lb1;
set adam.adlb;
if saffl="Y";
basecat1=SHIFT1;
avalcat1=lbnrind;

keep usubjid parcat1 paramn param basecat1 avalcat1 avisitn avisit ablfl;
run;

Proc sort; by usubjid paramn param; run;

data lb2;
set lb1;
by usubjid paramn param;
if last.paramn;
if parcat1 in ("BIOCHEMISTRY" "HEAMATOLOGY");
run;

/*Counts*/
proc freq data=lb2 noprint;
tables parcat1*paramn*param*basecat1*avalcat1/out=count;
run;

data lb3;
set count;
length var $100.;
if count=. then var="0";
else if count=&n3 then var=put(count, 3.)||'(100%)';
else var=put(count, 3.)||"("||put(count/&n3*100, 4.1)||")";
run;

Proc sort; by parcat1 paramn param basecat1 avalcat1; run;

/*transpose*/

Proc transpose data=lb3 out=final;
by parcat1 paramn param basecat1;
id avalcat1;
var var;
run;

data final1;
set final;
if low=" " then low="  0";
if high=" " then high="  0";
if normal=" " then normal="  0"; run;

/*proc report*/
%mtitlet (progid=rtlb1);
ods escapechar="^";
proc report data=final1 nowd headline headskip split="|" missing
style ={outputwidth=100%} spacing=1 wrap
style (header) ={just=c};
column parcat1 paramn param basecat1
("^S={borderbottomcolor=black borderbottomwidth=2}Treatment Period 02 end|(N=&n3)"
low normal high );

define parcat1/ORDER "Parameter category"
style (header) ={just=left cellwidth=10%}
style (column) ={just=left cellwidth=10%};

define paramn/order noprint;
define param/ORDER "Parameter (Unit)"
style (header) ={just=left cellwidth=20%}
style (column) ={just=left cellwidth=20%};
define basecat1/display "Baseline"
style (header) ={just=left cellwidth=10%}
style (column) ={just=left cellwidth=10%};

define low/display "LOW"
style (header) ={just=left cellwidth=10%}
style (column) ={just=left cellwidth=10%};

define normal/display "NORMAL"
style (header) ={just=left cellwidth=10%}
style (column) ={just=left cellwidth=10%};

define high/display "HIGH"
style (header) ={just=left cellwidth=10%}
style (column) ={just=left cellwidth=10%};


compute before PARAMN;
line '';
endcomp;
run;
ods _all_ close;
%mpageof;
