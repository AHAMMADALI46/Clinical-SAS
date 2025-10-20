********************************************************************
Filename: DM

Author: Ali

Date: 08jun2023

SAS: SAS 9.4 (TS2M0)

Platform: Windows 11

Project/Study: 

Description: <TO DEVELOP THE DM DATASETS>

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

/*DM Mapping*/
DATA DM1;
SET RAW.DEMOG_RAW;
STUDYID=STRIP(STUDY);
DOMAIN="DM";
SUBJID=STRIP(SUBJID);
SITEID=STRIP(SITE);
USUBJID=STUDYID||"-"||SITEID||"-"||SUBJID;

RFSTDTC=PUT(ENRDT, IS8601DA.)||"T"||PUT(ENRTM, TOD8.);
RFENDTC=PUT(CMPDT_, IS8601DA.)||"T"||PUT(CMPTM_, TOD8.);

RFICDTC=PUT(infdt, IS8601DA.)||"T"||PUT(inftm, TOD8.);
RFPENDTC=PUT(CMPDT_, IS8601DA.)||"T"||PUT(CMPTM_, TOD8.);

DTHDTC=" ";
DTHFL=" ";

INVNAM= STRIP(inv);
INVID= STRIP(INVID1);
AGE=AGEUN;
IF AGE NE . THEN AGEU='YEARS';
RACE=UPCASE(STRIP(ETH));
RUN;

PROC SQL NOPRINT;
CREATE TABLE DM2 AS
SELECT *,
CASE
WHEN UPCASE(GEN) IN ("FEMALE") THEN 'F'
WHEN UPCASE(GEN) IN ("MALE") THEN 'M'
ELSE ' ' END AS SEX FROM DM1;
QUIT;


/*EXTRACT DATA FROM EXPOSURE*/

DATA EX1;
SET RAW.EXPOSURE_RAW;
STUDYID=STRIP(STUDY);
SUBJID=STRIP(SUBJID);
SITEID=STRIP(SITE);
USUBJID=STUDYID||"-"||SITEID||"-"||SUBJID;
IF VISIT='Period-1';
DSDTN=INPUT(DSDT, MMDDYY10.);

RFXSTDTC=PUT(DSDTN, IS8601DA.)||"T"||PUT(DSDTM, TOD8.);
KEEP USUBJID RFXSTDTC TRT;
RUN;

DATA EX2;
SET RAW.EXPOSURE_RAW;
STUDYID=STRIP(STUDY);
SUBJID=STRIP(SUBJID);
SITEID=STRIP(SITE);
USUBJID=STUDYID||"-"||SITEID||"-"||SUBJID;
IF VISIT='Period-2';
DSDTN=INPUT(DSDT, MMDDYY10.);

RFXENDTC=PUT(DSDTN, IS8601DA.)||"T"||PUT(DSDTM, TOD8.);
TRT1=TRT;
KEEP USUBJID RFXENDTC TRT1;
RUN;

/*MERGE EX1 EX2*/
PROC SORT DATA=EX1; BY USUBJID; RUN;
PROC SORT DATA=EX2; BY USUBJID; RUN;

DATA EX3;
MERGE EX1(IN=A) EX2(IN=B);
BY USUBJID;
IF A OR B;
IF RFXENDTC EQ " " THEN RFXENDTC=RFXSTDTC;
RUN;

PROC SORT DATA=EX3; BY USUBJID; RUN;
PROC SORT DATA=DM2; BY USUBJID; RUN;

DATA DM3;
MERGE DM2 (IN=A) EX3(IN=B);
BY USUBJID;
IF A;
RUN;

/* MERGE DM3 WITH RAW.RND*/

PROC SORT DATA=DM3; BY SUBJID; RUN;
PROC SORT DATA=RAW.RND OUT=RND; BY SUBJID; RUN;

DATA DM4;
MERGE DM3(IN=A) RND (IN=B);
BY SUBJID;
IF A;
RUN;

DATA DM5;
SET DM4;
ARMCD=ARMDP;
ARM=ARMP;
IF TRT="REF" AND TRT1="TEST" THEN DO; ACTARMCD="R-T"; ACTARM="REFE-TEST"; END;
IF TRT="TEST" AND TRT1="REF" THEN DO; ACTARMCD="T-R"; ACTARM="TEST-REFE"; END;
COUNTRY="IND";
KEEP 
STUDYID
DOMAIN
USUBJID
SUBJID
SITEID
RFSTDTC
RFENDTC
RFXSTDTC
RFXENDTC
RFICDTC
RFPENDTC
DTHDTC
DTHFL
INVNAM
AGE
AGEU
SEX
RACE
ARMCD
ARM
ACTARMCD
ACTARM
COUNTRY
ETHOT
INVID
;
RUN;

/*APPLYING ATTRIBUTES*/
PROC SQL NOPRINT;
CREATE TABLE FINAL AS
SELECT
STUDYID"Study Identifier" LENGTH=	8,
DOMAIN"Domain Abbreviation" LENGTH=	2,
USUBJID"Unique Subject Identifier" LENGTH=	50,
SUBJID"Subject Identifier for the Study" LENGTH=	50,
SITEID"Study Site Identifier" LENGTH=	20,
RFSTDTC"Subject Reference Start Date/Time" LENGTH=	25,
RFENDTC"Subject Reference End Date/Time" LENGTH=	25,
RFXSTDTC"Date/Time of First Study Treatment" LENGTH=	25,
RFXENDTC"Date/Time of Last Study Treatment" LENGTH=	25,
RFICDTC"Date/Time of Informed Consent" LENGTH=	25,
RFPENDTC"Date/Time of End of Participation" LENGTH=	25,
DTHDTC"Date/Time of Death" LENGTH=	25,
DTHFL"Subject Death Flag" LENGTH=	2,
INVNAM"Investigator Name" LENGTH=	100,
AGE "Age" LENGTH=	8,
AGEU"Age Units" LENGTH=	6,
SEX"Sex" LENGTH=	2,
RACE"Race" LENGTH=	100,
ARMCD"Planned Arm Code" LENGTH=	100,
ARM"Description of Planned Arm" LENGTH=	200,
ACTARMCD"Actual Arm Code" LENGTH=	100,
ACTARM"Description of Actual Arm" LENGTH=	200,
COUNTRY"Country" LENGTH=	50,	
INVID"Investigator" LENGTH=	9
FROM DM5;
QUIT;


DATA SDTM.DM (LABEL="Demographics");
SET FINAL;
RUN;

libname xpt xport "E:\Ali_Clinical\SAS BA BE_course\SDTM XPT\DM.XPT";

data xpt.dm;
set sdtm.dm;
run;





















