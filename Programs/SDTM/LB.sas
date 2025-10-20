********************************************************************
Filename: LB

Author: Ali

Date: 08jun2023

SAS: SAS 9.4 (TS2M0)

Platform: Windows 11

Project/Study: 

Description: <TO DEVELOP THE LB DATASETS>

Input: DEMOG_RAW, EXPOSURE_RAW,

Output SDTM DM DATASET

Macros used: <No macros used>

-------------------------------------------------------------------------------

MODIFICATION HISTORY:

<DD-MON-YYYY>, <Firstname Lastname>

<Description>

***************************************************************************/;

/* Bringing the raw datasets*/
libname raw 'E:\Ali_Clinical\RAW';
libname sdtm 'E:\Ali_Clinical\SAS BA BE_course\SDTM';

DATA LB1;
SET RAW.LAB_RAW;

STUDYID= STRIP (STUDYID);
*INFORM TO CDM************;

DOMAIN="LB";
SUBJID=STRIP (SUBJID);
SITEID = STRIP (SITE);
USUBJID= STUDYID||"-"||SITEID||"-"||SUBJID;

LBTESTCD = UPCASE (STRIP (TESTCD));
LBTEST = PROPCASE (STRIP (TEST));
LBCAT =STRIP (CAT);

LBORRES = STRIP (VAL);
LBORRESU =STRIP (UNIT);
LBORNRLO = STRIP (LO);
LBORNRHI = STRIP (UP);

LBSTRESC = STRIP (STD_VAL);

LBSTRESU = STRIP (STD_UNIT);
LBSTNRLO = STRIP (STD_LO);
LBSTNRHI = STRIP (STD_UP);
LBSTRESN = INPUT (N_STD_VAL,BEST.);
LBSTNRC  = STRIP (C_STD_VAL);
LBNRIND = STRIP (INDI);


IF VISIT="SCREENING" THEN VISITNUM=0;
ELSE IF VISIT="PERIOD-1" THEN VISITNUM=1;
ELSE IF VISIT="PERIOD-2" THEN VISITNUM=2;

IF VISIT="SCREENING"  AND LBORRES NE '' THEN LBBLFL="Y";
LBFAST="Y";
LBDTC=put (DATE,IS8601DA.);
LBDTCN= INPUT (LBDTC,IS8601DA.);
RUN;

DATA DM1;
SET SDTM.DM;
RFSTDTN = DATEPART (INPUT (RFSTDTC,IS8601DT.));
FORMAT RFSTDTN DATE9.;

KEEP USUBJID RFSTDTC RFSTDTN;
RUN;

PROC SORT DATA=DM1;BY USUBJID;RUN;
PROC SORT DATA=LB1;BY USUBJID;RUN;

DATA DM_LB;
MERGE DM1 (IN=A) LB1 (IN=B);
BY USUBJID;
IF A AND B;
RUN;



DATA DM_LB2;
SET DM_LB;

IF LBDTCN > . AND RFSTDTN > . THEN DO;

IF LBDTCN >= RFSTDTN THEN LBDY=LBDTCN-RFSTDTN +1;
ELSE IF LBDTCN < RFSTDTN THEN LBDY=LBDTCN-RFSTDTN;
END;
RUN;
PROC SORT ;
BY STUDYID USUBJID LBTESTCD VISITNUM ;
RUN;



DATA DM_LB3;
SET DM_LB2;
BY STUDYID USUBJID LBTESTCD VISITNUM;
IF FIRST.USUBJID THEN LBSEQ=1;
ELSE LBSEQ+1;
RUN;



DATA FINAL;
SET DM_LB3;
KEEP
STUDYID DOMAIN USUBJID LBSEQ LBTESTCD LBTEST LBCAT LBORRES LBORRESU LBORNRLO
LBORNRHI LBSTRESC LBSTRESN LBSTRESU LBSTNRLO LBSTNRHI LBSTNRC LBNRIND LBBLFL LBFAST VISITNUM
VISIT LBDTC LBDY
;
RUN;

Proc Sql;
Create table Final1 as
select
STUDYID " Study Identifier "                                 Length= 8 ,
DOMAIN " Domain Abbreviation "                               Length= 2 ,
USUBJID " Unique Subject Identifier "                        Length= 50 ,
LBSEQ " Sequence Number "                                    Length= 8 ,
LBTESTCD " Lab test or Examination  Short Name "             Length= 100 ,
LBTEST " Lab test or Examination  Name "                     Length= 100 ,
LBCAT " Category for Lab test "                              Length= 100 ,
LBORRES " Result or Finding in Original Units "              Length= 50 ,
LBORRESU " Original Units "                                  Length= 25 ,
LBORNRLO " Reference Range Lower Limit in Orig Unit "        Length= 12 ,
LBORNRHI " Reference Range Upper Limit in Orig Unit "        Length= 12 ,
LBSTRESC " Character Result/Finding in Std Format "          Length= 40 ,
LBSTRESN " Numeric Result/Finding in Standard Units "        Length= 8 ,
LBSTRESU " Standard Units "                                  Length= 25 ,
LBSTNRLO " Reference Range Lower Limit-Std Units "           Length= 25 ,
LBSTNRHI " Reference Range Upper Limit-Std Units "           Length= 25 ,
LBSTNRC " Reference Range for Char Rslt-Std Units "          Length= 25 ,
LBNRIND " Reference Range Indicator "                        Length= 25 ,
LBBLFL " Baseline Flag "                                     Length= 20 ,
LBFAST " Fasting Status "                                    Length= 20 ,
VISITNUM " Visit Number "                                    Length= 8 ,
VISIT " Visit Name "                                         Length= 50 ,
LBDTC " Date/Time of Specimen Collection "                   Length= 20 ,
LBDY " Study Day of Specimen Collection "                    Length= 8
From Final;
quit;

Data SDTM.LB(label="Laboratory Test Results ");
Set Final1;
run;

LIBNAME XPT XPORT "E:\Ali_Clinical\SAS BA BE_course\SDTM XPT\LB.XPT";

DATA XPT.LB;
SET SDTM.LB;
RUN;
