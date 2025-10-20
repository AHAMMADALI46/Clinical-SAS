********************************************************************
Filename: EX

Author: Ali

Date: 11jun2023

SAS: SAS 9.4 (TS2M0)

Platform: Windows 11

Project/Study: 

Description: <TO DEVELOP THE EX DATASETS>

Input: DEMOG_RAW, EXPOSURE_RAW,

Output SDTM EX DATASET

Macros used: <No macros used>

-------------------------------------------------------------------------------

MODIFICATION HISTORY:

<DD-MON-YYYY>, <Firstname Lastname>

<Description>

***************************************************************************/;

/* Bringing the raw datasets*/
libname raw 'E:\Ali_Clinical\RAW';
libname sdtm 'E:\Ali_Clinical\SAS BA BE_course\SDTM';

/*DM Mapping*/
DATA EX1;
SET RAW.EXPOSURE_RAW;
STUDYID=STRIP(STUDY);
DOMAIN="EX";
SUBJID=STRIP(SUBJID);
SITEID=STRIP(SITE);
USUBJID=STUDYID||"-"||SITEID||"-"||SUBJID;

EXTRT=STRIP(TRT);

EXDOSE=INPUT(SUBSTR(STRIP(DOSE), 1,2), BEST.);
EXDOSTXT=STRIP(DOSEN);
EXDOSU=LOWCASE(SUBSTR(STRIP(DOSE),3));

EXDOSFRM=UPCASE(STRIP(DOSTP));
EXDOSFRQ=UPCASE(STRIP(freq));
EXROUTE=UPCASE(STRIP(route));

EXFAST=SUBSTR(UPCASE(STRIP(fast)),1,1);

EPOCH="TREATMENT";
RUN;

/*DURATION CALCULATION*/

DATA EX2;
SET EX1;
DSDTN=INPUT(DSDT, MMDDYY10.);

EXSTDTC=PUT(DSDTN, IS8601DA.)||"T"||PUT(DSDTM, TOD8.);
EXENDTC=PUT(DSDTN, IS8601DA.)||"T"||PUT(DSDTM, TOD8.);

EXSTDTN=DATEPART(INPUT(EXSTDTC, IS8601DT.));
EXENDTN=DATEPART(INPUT(EXENDTC, IS8601DT.));

FORMAT EXSTDTN DATE9.;
FORMAT EXENDTN DATE9.;
RUN;

DATA DM1;
SET SDTM.DM;
RFSTDTN=DATEPART(INPUT(RFSTDTC, IS8601DT.));
FORMAT RFSTDTN DATE9.;
KEEP USUBJID RFSTDTN RFSTDTC; 
RUN;

/*MERGING DM1 EX2*/

PROC SORT DATA=EX2; BY USUBJID; RUN;
PROC SORT DATA=DM1; BY USUBJID; RUN;

DATA DM_EX;
MERGE DM1(IN=A) EX2(IN=B);
BY USUBJID;
IF A AND B;
RUN;

DATA DM_EX1;
SET DM_EX;

IF EXSTDTN > . AND RFSTDTN > . THEN DO;

IF EXSTDTN >= RFSTDTN THEN EXSTDY= EXSTDTN-RFSTDTN+1;
ELSE IF EXSTDTN < RFSTDTN THEN EXSTDY=EXSTDTN-RFSTDTN; END;


IF EXENDTN > . AND RFSTDTN > . THEN DO;

IF EXENDTN >= RFSTDTN THEN EXENDY= EXENDTN-RFSTDTN+1;
ELSE IF EXENDTN < RFSTDTN THEN EXENDY=EXENDTN-RFSTDTN; END;

EXDUR1=EXENDY-EXSTDY+1;

EXDUR=COMPRESS("P"||PUT(EXDUR1, BEST.)||"D");
RUN;

PROC SORT DATA=DM_EX1; BY STUDYID USUBJID EXTRT EXSTDTC; RUN;

DATA DM_EX2;
SET DM_EX1;
BY STUDYID USUBJID EXTRT EXSTDTC;
IF FIRST.USUBJID THEN EXSEQ=1;
ELSE EXSEQ+1;
RUN;

DATA DM_EX3;
SET DM_EX2;
KEEP STUDYID
DOMAIN
USUBJID
EXSEQ
EXTRT
EXDOSE
EXDOSTXT
EXDOSU
EXDOSFRM
EXDOSFRQ
EXROUTE
EXFAST
EPOCH
EXSTDTC
EXENDTC
EXSTDY
EXENDY
EXDUR
; RUN;

proc sql;
create table EX_FINAL as
select 
STUDYID       "Study Identifier"               Length=8,
DOMAIN        "Domain Abbreviation"            Length=2,
USUBJID       "Unique Subject Identifier"      Length=50,
EXSEQ         "Sequence Number"                Length=8,
EXTRT         "Name of Treatment"              Length=200,
EXDOSE        "Dose"                           Length=8,
EXDOSU        "Dose Units"                     Length=40,
EXDOSFRM      "Dose Form"                      Length=50,
EXDOSFRQ      "Dosing Frequency per Interval"  Length=50,
EXROUTE       "Route of Administration"        Length=40,
EXFAST        "Fasting Status"                 Length=2,
EXSTDTC       "Start Date/Time of Treatment"   Length=25,
EXENDTC       "End Date/Time of Treatment"     Length=25,
EXSTDY       "Study Day of Start of Treatment" Length=8,
EXENDY       "Study Day of end of Treatment"   Length=8,
EXDUR        "Duration of Treatment"           Length=8
from DM_EX3;
quit;


DATA SDTM.EX (LABEL="Exposure");
SET EX_FINAL ;
RUN;

LIBNAME XPT XPORT "E:\Ali_Clinical\SAS BA BE_course\SDTM XPT\EX.XPT";

DATA XPT.EX;
SET SDTM.EX;
RUN;













