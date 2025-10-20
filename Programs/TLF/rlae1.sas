********************************************************************
Filename: Listing 16.2.1.1 Adverse Events

Author: Ali

Date: 25jun2023

SAS: SAS 9.4 (TS2M0)

Platform: Windows 11

Project/Study: 

Description: <TO DEVELOP THE ADAE DATASETS>

Input: ADAM.ADSL

Output: rlae1

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


data ae;
set adam.adae;

if index(trta, "TEST")>0 then do; trt1="Test"; END;
if index(trta, "REFE")>0 then do; trt1="Reference"; END;

aeseqc=compress(put(aeseq, best.));

spa=strip(aeterm)||"/"||strip(aebodsys)||"/"||strip(aedecod);

keep trt1 usubjid aeseqc spa aestdtc aeendtc aesev aeser aeacn aerel aeout;

if trt1 ne ' ';
run;


ods escapchar="^";

%mtitlet (progid=rlae1);

proc report data=Ae nowd headline headskip split="|" missing

style ={outputwidth=100%} spacing=1 wrap
style (header)={just=left};

column trt1 usubjid aeseqc spa aestdtc aeendtc aesev aeser aeacn aerel aeout;

define trt1/display "Treatment" style(column)={just=left cellwidth=4%};
define usubjid/display "Subj.|No." style(column)={just=left cellwidth=9%};

define aeseqc/display "AE|No." style(column)={just=left cellwidth=3%};
define spa/display "Adverse Event/Primary System Organ Class/|Preffered term" style(column)={just=left cellwidth=25%};
define aestdtc/display "Start|Date/Time" style(column)={just=left cellwidth=9%};
define aeendtc/display "End|Date/Time" style(column)={just=left cellwidth=9%};
define aesev/display "Severity" style(column)={just=left cellwidth=8%};
define aeser/display "Serious|Event" style(column)={just=left cellwidth=5%};
define aeacn/display "Action taken" style(column)={just=left cellwidth=8%};
define aerel/display "Relationship to|Study Drug" style(column)={just=left cellwidth=9%};
define aeout/display "Outcome" style(column)={just=left cellwidth=7%};

compute before usubjid;
line ' ';
endcomp;

run;

ods _all_ close;

%mpageof;



