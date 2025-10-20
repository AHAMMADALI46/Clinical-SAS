********************************************************************
Filename: Table 14.1.3 Subject Demographics -Sex and Race  (Safety Population)

Author: Ali

Date: 04jul2023

SAS: SAS 9.4 (TS2M0)

Platform: Windows 11

Project/Study: 

Description: <TO DEVELOP THE ADAE DATASETS>

Input: ADAM.ADSL

Output: rtdemo3

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

%put &n1 &n2 &n3;

*********sex counts*******;
proc freq data= demog_3 noprint;
tables sex*trt/out=gender (drop=percent);
run;

data gender_;
set gender;
length cat stat $52.;

cat="Gender";
if sex="M" then do; stat="Male"; sort=1; end;
if sex="F" then do; stat="Female"; sort=2; end;

run;

proc sort; by cat sort; run;

proc transpose data=gender_ out=gen_t;
by cat sort stat;
id trt;
var count;
run;

**********Race counts******;
proc freq data= demog_3 noprint;
tables race*trt/out=race (drop=percent);
run;

data race_;
set race;
length cat stat $52.;

cat="Race";
if race="ASIAN" then do; stat="Asian"; sort=1; end;
if race="OTHER" then do; stat="Other"; sort=2; end;

run;

proc sort; by cat sort; run;

proc transpose data=race_ out=race_t;
by cat sort stat;
id trt;
var count;
run;

/*percentages*/

data final;
set gen_t race_t;

length test refe allp $10.;

if tes=. then test="0";
else if tes= &n1 then test=put(tes,  3.)||'(100%)';
else test=put(tes, 3.)||"("||put(tes/&n1*100, 4.1)||")";

if ref=. then refe="0";
else if ref= &n1 then refe=put(ref,  3.)||'(100%)';
else refe=put(ref, 3.)||"("||put(ref/&n1*100, 4.1)||")";

if all=. then allp="0";
else if all= &n1 then allp=put(all,  3.)||'(100%)';
else allp=put(all, 3.)||"("||put(all/&n1*100, 4.1)||")";

run;

/*proc report*/
%mtitlet (progid=rtdemo3);
ods escapechar="^";
proc report data=final nowd headline headskip split="|" missing
style ={outputwidth=100%} spacing=1 wrap
style (header) ={just=c};


column cat sort stat ('^S={borderbottomcolor=black borderbottomwidth=2}Treatment' test refe )allp;

define cat/group "Category"
style (header) ={just=left cellwidth=10%}
style (column) ={just=left cellwidth=10%};

define sort/order noprint;
define stat/display "Statistic"
style (header) ={just=left cellwidth=10%}
style (column) ={just=left cellwidth=10%};


define test/display "Test|(N=&n1)"
style (header) ={just=c cellwidth=10%}
style (column) ={just=c cellwidth=10%};

define refe/display "Reference|(N=&n2)"
style (header) ={just=c cellwidth=10%}
style (column) ={just=c cellwidth=10%};

define allp/display "Overall|(N=&n3)"
style (header) ={just=c cellwidth=10%}
style (column) ={just=c cellwidth=10%};

compute before cat;
line ' ';
endcomp;

run;
ods _all_ close;
%mpageof;
