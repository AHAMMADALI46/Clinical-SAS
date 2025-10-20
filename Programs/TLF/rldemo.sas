********************************************************************
Filename: Listing 16.1.1.1 Subject Demographics

Author: Ali

Date: 25jun2023

SAS: SAS 9.4 (TS2M0)

Platform: Windows 11

Project/Study: 

Description: <TO DEVELOP THE ADAE DATASETS>

Input: ADAM.ADSL

Output: rldemo

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
subjn=input(substr(usubjid, 13), best.);

Keep subjn usubjid actarm age sex height weight bmi;
run;

proc sort; by subjn; run;

ods escapchar="^";

%mtitlet (progid=rldemo);

proc report data=Adsl nowd headline headskip split="|" missing

style ={outputwidth=100%} spacing=1 wrap
style (header)={just=left};

column subjn usubjid actarm age sex height weight bmi;

define subjn/order noprint;
define usubjid/display "Subject|Number" style(column)={just=left cellwidth=10%};

define actarm/display "Treatment|Sequence" style(column)={just=left cellwidth=10%};
define age/display "Age* (years)" style(column)={just=left cellwidth=10%};
define sex/display "Sex" style(column)={just=left cellwidth=10%};
define height/display "Height (cm)" style(column)={just=left cellwidth=10%};
define weight/display "Weight (kg)" style(column)={just=left cellwidth=10%};
define bmi/display "BMI (kg/m2)" style(column)={just=left cellwidth=10%};

run;

ods _all_ close;

%mpageof;
