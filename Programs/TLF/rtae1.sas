********************************************************************
Filename: Table 14.2.1 Treatment Emergent Adverse Events by Treatment, 
System Organ Class and Preferred Term (Safety Population)

Author: Ali

Date: 04 Jul 2023

SAS: SAS 9.4 (TS2M0)

Platform: Windows XP

Project/Study: 

Description: 

Input: ADAM.ADAE

Output rtae1

Macros used: <No macros used>
%mpageof, %mtitlet, %_run_toc
-------------------------------------------------------------------------------

MODIFICATION HISTORY:

<DD-MON-YYYY>, <Firstname Lastname>

<Description>

***************************************************************************/;

libname raw 'E:\Ali_Clinical\RAW';
libname sdtm 'E:\Ali_Clinical\SAS BA BE_course\SDTM';
libname ADAM 'E:\Ali_Clinical\SAS BA BE_course\ADAM';

%include "E:\Ali_Clinical\SAS BA BE_course\MACROS\_run_toc.sas";
%include "E:\Ali_Clinical\SAS BA BE_course\MACROS\mpageof.sas";
%include "E:\Ali_Clinical\SAS BA BE_course\MACROS\mtitlet.sas";


data adsl;
set adam.adsl;
if SAFFL ="Y";
run;

data demog_1;
set adsl;
output;
run;
data demog_2;
set demog_1;

if index (trt01a,"TEST")>0 then do; trt="TES";ord=1;end;
if index (trt01a,"REFE")>0 then do; trt="REF";ord=2;end;
keep usubjid trt ord ;
if ord ne .;
run;


data demog_11;
set adsl;
output;
run;


data demog_22;
set demog_11;

if index (trt02a,"TEST")>0 then do; trt="TES";ord=1;end;
if index (trt02a,"REFE")>0 then do; trt="REF";ord=2;end;
keep usubjid age  trt ord sexn sex racen race ;
if ord ne .;
run;

data demog_3;
set demog_2 demog_22;
run;

proc sort;by ord;run;
proc sort nodupkey;by usubjid trt;run;

proc sql noprint;
select  count (distinct usubjid) into:n1 - :n2  from demog_3
group by ord
order by ord;
quit;
%put &n1 &n2 ;

******Adverse events*********;

DATA ADAE;
SET ADAM.ADAE;
IF TRTMFL ="Y" AND SAFFL="Y";
if index (TRTA,"TEST")>0 then do; trt="TES";ord=1;end;
if index (TRTA,"REFE")>0 then do; trt="REF";ord=2;end;

KEEP USUBJID AEBODSYS AEDECOD TRT ORD;
RUN;

PROC SQL;
CREATE TABLE ANY1 AS
SELECT TRT, COUNT (DISTINCT USUBJID) AS N,
" Number of Subjects with TEAEs" AS AEBODSYS LENGTH=200 FROM ADAE
GROUP BY TRT;

CREATE TABLE SOC AS
SELECT TRT, AEBODSYS,COUNT (DISTINCT USUBJID) AS N FROM ADAE
GROUP BY TRT,AEBODSYS;

CREATE TABLE PT AS
SELECT TRT, AEBODSYS,AEDECOD,COUNT (DISTINCT USUBJID) AS N FROM ADAE
GROUP BY TRT,AEBODSYS,AEDECOD;

QUIT;

DATA ALL;
SET ANY1 SOC PT;
RUN;

PROC SORT;BY AEBODSYS AEDECOD;RUN;

PROC TRANSPOSE DATA=ALL OUT=ALL_;
BY AEBODSYS AEDECOD;
ID TRT;
RUN;


data final;
set ALL_;
length test refe  $100.;
if tes=. then test="  0";
else if tes=&n1 then test=put (tes,3.)||'(100%)';
else  test=put (tes,3.)||" ("||put (tes/&n1*100,4.1)||")";

if ref=. then refe="  0";
else if ref=&n2 then refe=put (ref,3.)||'(100%)';
else  refe=put (ref,3.)||" ("||put (ref/&n2*100,4.1)||")";

IF AEDECOD EQ '' AND AEBODSYS NE '' THEN AEBODSYS1=AEBODSYS;
ELSE AEBODSYS1="  "||AEDECOD;
RUN;



%mtitlet (progid=rtae1);
ods escapechar="^";
proc report data=final nowd headline headskip split="|" missing
style ={outputwidth=100%} spacing=1 wrap
style (header) ={just=c};


column AEBODSYS AEDECOD AEBODSYS1 ('^S={borderbottomcolor=black borderbottomwidth=2}Treatment' 
test refe );

define AEBODSYS/order noprint;
define AEDECOD/order noprint;
define AEBODSYS1/group "
MedDRA® System Organ Class|  MedDRA® Preferred Term"
style (header) ={just=left cellwidth=15%}
style (column) ={just=left cellwidth=15%};


define test/display "Test|(N=&n1)"
style (header) ={just=c cellwidth=10%}
style (column) ={just=c cellwidth=10%};

define refe/display "Reference|(N=&n2)"
style (header) ={just=c cellwidth=10%}
style (column) ={just=c cellwidth=10%};

compute before AEBODSYS;
line '';
endcomp;
run;
ods _all_ close;
%mpageof;
