********************************************************************
Filename: Table 14.3.1 Summary of Changes in Vital Signs from Baseline to Final Visit (Safety Population)

Author: Ali

Date: 05jul2023

SAS: SAS 9.4 (TS2M0)

Platform: Windows 11

Project/Study: 

Description: <TO DEVELOP THE ADAE DATASETS>

Input: ADAM.ADVS

Output: rlvs

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

%put &n1 &n2 ;

/*Pulse Aval counts*/
Proc sort data=adam.advs out=vs 
(keep=usubjid paramn param avisitn avisit atptn atpt aval chg trtan trta);
by usubjid paramn param avisitn atptn;
where aval ne " " and paramn not in (1,2,3) and Saffl="Y"
and avisit ne "screening" and paramn eq 7;
run;

data vs1;
set vs;
avaln=input(aval, best.);
if index(trta, "TEST")>0 then do; trt="TES"; ord=1; end;
if index(trta, "REFE")>0 then do; trt="REF"; ord=2; end;
run;

proc summary data=vs1 nway;
class paramn param avisitn avisit atptn atpt trt;
var avaln;
output out=vs2 n=n_ mean=mean_ median=median_ std=std_ min=min_ max=max_;
run;

data vs3;
set vs2;
n=compress(put(n_,3.));
mean=compress(put(mean_, 4.1));
median=compress(put(median_, 4.1));
std=compress(put(std_, 5.2));
min=compress(put(min_, 3.));
max=compress(put(max_, 3.));
run;

proc transpose data=vs3 out=vs4;
by paramn param avisitn avisit atptn atpt;
id trt;
var n mean median std min max;
run;

data vs5;
set vs4;
length stat $100.;

if _NAME_="n" then do; stat="N"; od=1; end;
if _NAME_="mean" then do; stat="Mean"; od=2; end;
if _NAME_="median" then do; stat="Median"; od=3; end;
if _NAME_="std" then do; stat="SD"; od=4; end;
if _NAME_="min" then do; stat="Minimum"; od=5; end;
if _NAME_="max" then do; stat="Maximum"; od=6; end;

run;


**********Chg stats***********;

proc summary data=vs1 nway;
where atpt ne '0';
class paramn param avisitn avisit atptn atpt trt;
var avaln;
output out=vs22 n=n_ mean=mean_ median=median_ std=std_ min=min_ max=max_;
run;

data vs33;
set vs22;
n=compress(put(n_,3.));
mean=compress(put(mean_, 4.1));
median=compress(put(median_, 4.1));
std=compress(put(std_, 5.2));
min=compress(put(min_, 3.));
max=compress(put(max_, 3.));
run;

proc transpose data=vs33 out=vs44;
by paramn param avisitn avisit atptn atpt;
id trt;
var n mean median std min max;
run;

data vs55;
set vs44;
length stat $100.;

if _NAME_="n" then do; stat="N"; od=1; end;
if _NAME_="mean" then do; stat="Mean"; od=2; end;
if _NAME_="median" then do; stat="Median"; od=3; end;
if _NAME_="std" then do; stat="SD"; od=4; end;
if _NAME_="min" then do; stat="Minimum"; od=5; end;
if _NAME_="max" then do; stat="Maximum"; od=6; end;

rename ref=refc tes=tesc;
run;

Proc sort data=vs5; by paramn param avisitn avisit atptn atpt od stat; run;
Proc sort data=vs55; by paramn param avisitn avisit atptn atpt od stat; run;

data final;
length atpt $20.;
merge vs5 vs55;
by paramn param avisitn avisit atptn atpt od stat;

if atpt="0" then atpt="Baseline";
if atpt="2" then atpt="2H";
if atpt="8" then atpt="8H";
if atpt="Check-ou" then atpt="Check-out";
run;

/*Proc report*/


%mtitlet (progid=rtvs1);
ods escapechar="^";
proc report data=final nowd headline headskip split="|" missing
style ={outputwidth=100%} spacing=1 wrap
style (header) ={just=c};

column paramn param avisitn avisit atptn atpt od stat
("Test|(N=&n1)" "---------------------------------------------" tes tesc)
("Reference|(N=&n2)" "----------------------------------------" ref refc);

define paramn /order noprint;
define param /order "Parameter (Unit)"                     
style (header) ={just=left cellwidth=20%}
style (column) ={just=left cellwidth=20%};
define avisitn /order noprint;
define avisit /order "Visit"
style (header) ={just=left cellwidth=10%}
style (column) ={just=left cellwidth=10%};


define atptn /order noprint;
define atpt /order "Time point"
style (header) ={just=left cellwidth=10%}
style (column) ={just=left cellwidth=10%};


define od/order noprint;
define stat/display "Statistic"
style (header) ={just=left cellwidth=10%}
style (column) ={just=left cellwidth=10%};

define tes/display "Observed Value"
style (header) ={just=left cellwidth=10%}
style (column) ={just=left cellwidth=10%};
define tesc/display "Change from Baseline"
style (header) ={just=left cellwidth=15%}
style (column) ={just=left cellwidth=15%};


define ref/display "Observed Value"
style (header) ={just=left cellwidth=10%}
style (column) ={just=left cellwidth=10%};
define refc/display "Change from Baseline"
style (header) ={just=left cellwidth=13%}
style (column) ={just=left cellwidth=13%};
compute before atptn;
line '';
endcomp;

run;
ods _all_ close;
%mpageof;
