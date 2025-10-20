********************************************************************
Filename: AE

Author: Ali

Date: 08jun2023

SAS: SAS 9.4 (TS2M0)

Platform: Windows 11

Project/Study: 

Description: <TO DEVELOP THE AE DATASETS>

Input: AE_RAW

Output SDTM AE DATASET

Macros used: <No macros used>

-------------------------------------------------------------------------------

MODIFICATION HISTORY:

<DD-MON-YYYY>, <Firstname Lastname>

<Description>

***************************************************************************/;

/* Bringing the raw datasets*/
libname raw 'E:\Ali_Clinical\RAW';
libname sdtm 'E:\Ali_Clinical\SAS BA BE_course\SDTM';


DATA AE1;
SET RAW.AE_RAW;
STUDYID=STRIP(STUDY);
DOMAIN="AE";
SUBJID=STRIP(SUBJID);
SITEID=STRIP(SITE);
USUBJID=STUDYID||"-"||SITEID||"-"||SUBJID;

AETERM=STRIP(EVENT);
AELLT=STRIP(llt);
AELLTCD=INPUT(lltcd, BEST.);
AEDECOD=STRIP(DECOD);
AEPTCD=INPUT(ptcd, BEST.);
AEHLT=STRIP(hlt);
AEHLTCD=INPUT(hltcd, BEST.);
AEHLGT=STRIP(HLGT);
AEHLGTCD=INPUT(HLGTcd, BEST.);
AEBODSYS=STRIP(BODSYS);
AEBDSYCD=BDSYCD;
AESOC=STRIP(soc);
AESOCCD=INPUT(soccd, BEST.);

AESEV=UPCASE(STRIP(SEV));
AESER=SUBSTR(UPCASE(STRIP(SER)),1,1);

AEACN=UPCASE(STRIP(ACTT));
AEACNOTH=STRIP(COCN);

AEREL=STRIP(CAU);
AEOUT=UPCASE(STRIP(OUTCOME));

AECONTRT=SUBSTR(UPCASE(STRIP(COCN)),1,1);
RUN;

DATA DM1;
SET SDTM.DM;
RFSTDTN=DATEPART(INPUT(RFSTDTC, IS8601DT.));
KEEP USUBJID RFSTDTN RFSTDTC; 
RUN;

DATA AE2;
SET AE1;

AESTDTC=PUT(STDT, IS8601DA.)||"T"||PUT(STTM, TOD8.);
AEENDTC=PUT(STOPDT, IS8601DA.)||"T"||PUT(STOPTM, TOD8.);

AESTDTN=DATEPART(INPUT(AESTDTC, IS8601DT.));
AEENDTN=DATEPART(INPUT(AEENDTC, IS8601DT.));

RUN;

/*MERGE DM1 AE2*/
PROC SORT DATA=DM1; BY USUBJID; RUN;
PROC SORT DATA=AE2; BY USUBJID; RUN;

DATA DM_AE;
MERGE DM1(IN=A) AE2(IN=B);
BY USUBJID;
IF A AND B;
RUN;

DATA DM_AE1;
SET DM_AE;

IF AESTDTN > . AND RFSTDTN > . THEN DO;

IF AESTDTN >= RFSTDTN THEN AESTDY= AESTDTN-RFSTDTN+1;
ELSE IF AESTDTN < RFSTDTN THEN AESTDY=AESTDTN-RFSTDTN; END;


IF AEENDTN > . AND RFSTDTN > . THEN DO;

IF AEENDTN >= RFSTDTN THEN AEENDY= AEENDTN-RFSTDTN+1;
ELSE IF AEENDTN < RFSTDTN THEN AEENDY=AEENDTN-RFSTDTN; END;

AEDUR1=AEENDY-AESTDY+1;

AEDUR=COMPRESS("P"||PUT(AEDUR1, BEST.)||"D");
RUN;

PROC SORT DATA=DM_AE1; BY STUDYID USUBJID AEDECOD AESTDTC; RUN;

DATA DM_AE2;
SET DM_AE1;
BY STUDYID USUBJID AEDECOD AESTDTC;
IF FIRST.USUBJID THEN AESEQ=1;
ELSE AESEQ+1;
RUN;

DATA DM_AE3;
SET DM_AE2;
KEEP STUDYID
DOMAIN
USUBJID
AESEQ
AETERM
AELLT
AELLTCD
AEDECOD
AEPTCD
AEHLT
AEHLTCD
AEHLGT
AEHLGTCD
AEBODSYS
AEBDSYCD
AESOC
AESOCCD
AESEV
AESER
AEACN
AEACNOTH
AEREL
AEOUT
AECONTRT
AESTDTC
AEENDTC
AESTDY
AEENDY
AEDUR;
RUN;

PROC SQL;
CREATE TABLE FINAL_AE AS
SELECT
	STUDYID "Study Identifier" 						LENGTH=8,
	DOMAIN "Domain Abbreviation" 					LENGTH=2,
	USUBJID "Unique Subject Identifier" 			LENGTH=50,
	AESEQ "Sequence Number" 						LENGTH=8,
	AETERM "Reported Term for the Adverse Event" 	LENGTH=200,
	AELLT "Lowest Level Term" 						LENGTH=200,
	AELLTCD "Lowest Level Term Code" 				LENGTH=8,
	AEDECOD "Dictionary-Derived Term" 				LENGTH=200,
	AEPTCD "Preferred Term Code" 					LENGTH=8,
	AEHLT "High Level Term" 						LENGTH=200,
	AEHLTCD "High Level Term Code" 					LENGTH=8,
	AEHLGT "High Level Group Term" 					LENGTH=200,
	AEHLGTCD "High Level Group Term Code" 			LENGTH=8,
	AEBODSYS "Body System or Organ Class" 			LENGTH=200,
	AEBDSYCD "Body System or Organ Class Code" 		LENGTH=8,
	AESOC "Primary System Organ Class" 				LENGTH=200,
	AESOCCD "Primary System Organ Class Code" 		LENGTH=8,
	AESEV "Severity/Intensity" 						LENGTH=10,
	AESER "Serious Event"							LENGTH=2,
	AEACN "Action Taken with Study Treatment" 		LENGTH=16,
	AECONTRT "Concomitant or Additional Trtmnt Given" 					LENGTH=2,
	AEREL "Causality" 								LENGTH=20,
	AEOUT "Outcome of Adverse Event" 				LENGTH=40,
	AESTDTC "Start Date/Time of Adverse Event" 		LENGTH=20,
	AEENDTC "End Date/Time of Adverse Event" 		LENGTH=20,
	AESTDY "Study Day of Start of Adverse Event" 	LENGTH=8,
	AEENDY "Study Day of End of Adverse Event" 		LENGTH=8,
	AEDUR "Duration of Adverse Event" 				LENGTH=20
	FROM DM_AE3;
QUIT;



DATA SDTM.AE (LABEL="Adverse Events");
SET FINAL_AE;
RUN;



LIBNAME XPT XPORT "E:\Ali_Clinical\SAS BA BE_course\SDTM XPT\AE.XPT";


DATA XPT.AE;
SET SDTM.AE;
RUN;






