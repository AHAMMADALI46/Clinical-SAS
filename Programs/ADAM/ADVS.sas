********************************************************************
Filename: ADVS

Author: Ali

Date: 26jun2023

SAS: SAS 9.4 (TS2M0)

Platform: Windows 11

Project/Study: 

Description: <TO DEVELOP THE ADAE DATASETS>

Input: SDTM.VS, ADAM.ADSL

Output: ADAM.ADVS DATASET

Macros used: <No macros used>

-------------------------------------------------------------------------------

MODIFICATION HISTORY:

<DD-MON-YYYY>, <Firstname Lastname>

<Description>

***************************************************************************/;
/* Bringing the raw datasets*/
libname raw 'E:\Ali_Clinical\RAW';
libname sdtm 'E:\Ali_Clinical\SAS BA BE_course\SDTM';
libname ADAM 'E:\Ali_Clinical\SAS BA BE_course\ADAM';

*******COPY ALL THE VARIABLES FROM SDTM.VS, ADAM.ADVS********;
proc sql noprint;
create table vs1 as
select * from sdtm.vs
order by usubjid;
quit;


proc sql noprint;
create table adsl as
select * from adam.adsl
order by usubjid;
quit;

data vs2;
merge adsl(in=a) vs1(in=b);
by usubjid;
if a and b;
run;

data vs3;
set vs2;
AVISIT=visit;
AVISITN=visitnum;
ATPT=vstpt;
ATPTN=VSTPTNUM;

PARAM=strip(VSTEST)||" ("||strip(VSSTRESU)||")";
PARAMCD=vstestcd;

if paramcd="HEIGHT"  then paramn=1;
else if paramcd="WEIGHT" then paramn=2;
else if paramcd="BMI" then paramn=3;
else if paramcd="SYSBP" then paramn=4;
else if paramcd="DIABP" then paramn=5;
else if paramcd="TEMP" then paramn=6;
else if paramcd="PULSE" then paramn=7;
run;

Proc sort data=vs3 out=vs3_;
by usubjid paramn param avisitn avisit atptn atpt vsdtc;
run;

data vs4;
set vs3_;
by usubjid paramn param avisitn avisit atptn atpt vsdtc;
retain base;

AVAL=VSSTRESN;
AVALC=put(VSSTRESN, $14.);
AVALU=VSSTRESU;

if first.paramn then do;
base=.;
end;

if atpt="0" then do;
BASE=aval;
ABLFL="Y";
end;

if base >. and aval ne . then do;
CHG=aval-base;
PCHG=(aval-base)/base*100;

SHIFT1=base;
end;

IF AVISIT="PERIOD-1" THEN DO;
TRTP=TRT01P; 
TRTPN=TRT01PN;
TRTA=TRT01A;
TRTAN=TRT01AN;
END;

IF AVISIT="PERIOD-2" THEN DO;
TRTP=TRT02P; 
TRTPN=TRT02PN;
TRTA=TRT02A;
TRTAN=TRT02AN;
END;
/*2018-02-11T02:00:00*/

IF LENGTH (VSDTC)>=10 THEN ADT=INPUT (SUBSTR(VSDTC,1,10),YYMMDD10.);
IF LENGTH (VSDTC)>=19 THEN ADTM=INPUT (VSDTC,??IS8601DT.);
FORMAT ADTM DATETIME16.;

IF AVAL NE . THEN ANL01FL="Y";

IF AVISITN IN ( 0 1 ) THEN  DO; APERIODC='Period 01';APERIOD=1;END;
IF AVISITN GE 2  THEN  DO; APERIODC='Period 02';APERIOD=2;END;

run;


data adam.advs;
set vs4;
run;








