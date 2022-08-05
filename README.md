# Clinical-SAS
Clinical SAS
/*To derive Rfpendtc extract conclus raw data*/
data rfp (keep=Usubjid Rfpendtc rfendtc);
set raw.conclus;
where stint="Final evaluation" and termdt Ne .;
usubjid=Catx("-" study, stdysite, patient);
rfpendtc=put(datepart(termdt), ISO8601DA.);
rfendtc=rfependtc;
run;

/* To Derive RFXSTDTC RFXENDTC EXTRACT STUDYMEDW DATA*/
