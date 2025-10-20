********************************************************************
Filename: DM

Author: Ali

Date: 11jun2023

SAS: SAS 9.4 (TS2M0)

Platform: Windows 11

Project/Study: 

Description: <TO DEVELOP THE SUPPDM DATASETS>

Input: DEMOG_RAW, EXPOSURE_RAW,

Output SDTM SUPPDM DATASET

Macros used: <No macros used>

-------------------------------------------------------------------------------

MODIFICATION HISTORY:

<DD-MON-YYYY>, <Firstname Lastname>

<Description>

***************************************************************************/;

/*SUPPDM CREATION*/
data suppdm;
set DM5;

if ETHOT ne ' ' then do;
RDOMAIN='DM';
IDVAR=' ';
IDVARVAL=' ';
QNAM='RACEOTH';
QLABEL='RACE, OTHER';
QVAL=STRIP(ETHOT);
QORIG='CRF';
QEVAL=INVNAM;
END;
KEEP 
STUDYID
RDOMAIN
USUBJID
IDVAR
IDVARVAL
QNAM
QLABEL
QVAL
QORIG
QEVAL
;
RUN;

/*APPLYING ATTRIBUTES*/

PROC SQL NOPRINT;
CREATE TABLE FIN_SUPPDM AS
SELECT

STUDYID"Study Identifier" LENGTH=	8	,
RDOMAIN "Related Domain Abbreviation
" LENGTH=	2,
USUBJID"Unique Subject Identifier" LENGTH=	50,
IDVAR"Identifying Variable" LENGTH=	8,
IDVARVAL"Identifying Variable Value" LENGTH=	40,
QNAM"Qualifier Variable Name" LENGTH=	8,
QLABEL"Qualifier Variable Label" LENGTH=	40	,
QVAL"Data Value" LENGTH=	200	,
QORIG"Origin" LENGTH=	20	,
QEVAL"Evaluator" LENGTH=	40	
FROM SUPPDM
WHERE QVAL NE ' ';
QUIT;

DATA SDTM.SUPPDM (LABEL="SUPPLEMENTAL Demographics");
SET FIN_SUPPDM;
RUN;

libname xpt xport "E:\Ali_Clinical\SAS BA BE_course\SDTM XPT\SUPPDM.XPT";

data xpt.SUPPdm;
set sdtm.SUPPdm;
run;

