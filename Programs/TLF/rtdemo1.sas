********************************************************************
Filename: Table 14.1.1 Subject Demographics - Age (Safety Population)

Author: Ali

Date: 03jul2023

SAS: SAS 9.4 (TS2M0)

Platform: Windows 11

Project/Study: 

Description: <TO DEVELOP THE ADAE DATASETS>

Input: ADAM.ADSL

Output: rtdemo1

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

keep usubjid age trt ord;
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

keep usubjid age trt ord;
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

/*Statistics*/

Proc summary data=demog_3 nway;
class trt;
var age;
output out=dm_1 n=n_ mean=mean_ median=median_ std=std_ min=min_ max=max_;
run;

data dm_2;
set dm_1;
n=compress(put(n_,3.));
mean=compress(put(mean_, 4.1));
median=compress(put(median_, 4.1));
std=compress(put(std_, 5.2));
min=compress(put(min_, 3.));
max=compress(put(max_, 3.));
run;

/*transpose*/
proc transpose data=dm_2 out=dm_3;
id trt;
var n mean median std min max;
run;

data dm_4;
set dm_3;
length stat $100.;

if _NAME_="n" then do; stat="N"; od=1; end;
if _NAME_="mean" then do; stat="Mean"; od=2; end;
if _NAME_="median" then do; stat="Median"; od=3; end;
if _NAME_="std" then do; stat="SD"; od=4; end;
if _NAME_="min" then do; stat="Minimum"; od=5; end;
if _NAME_="max" then do; stat="Maximum"; od=6; end;

cat="Age(years)";
run;

/*Proc report*/


%mtitlet (progid=rtdemo1);
ods escapechar="^";
proc report data=dm_4 nowd headline headskip split="|" missing
style ={outputwidth=100%} spacing=1 wrap
style (header) ={just=c};


column cat od stat ('^S={borderbottomcolor=black borderbottomwidth=2}Treatment' tes ref )all;

define cat/group "Category"
style (header) ={just=left cellwidth=10%}
style (column) ={just=left cellwidth=10%};

define od/order noprint;
define stat/display "Statistic"
style (header) ={just=left cellwidth=10%}
style (column) ={just=left cellwidth=10%};


define tes/display "Test|(N=&n1)"
style (header) ={just=c cellwidth=10%}
style (column) ={just=c cellwidth=10%};

define ref/display "Reference|(N=&n2)"
style (header) ={just=c cellwidth=10%}
style (column) ={just=c cellwidth=10%};
define all/display "All|(N=&n3)"
style (header) ={just=c cellwidth=10%}
style (column) ={just=c cellwidth=10%};
;run;
ods _all_ close;
%mpageof;
