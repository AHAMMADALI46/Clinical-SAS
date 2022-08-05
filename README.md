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

/*Merge RFP to Demo_Arm*/
%Sort (Demo_Arm, Usubjid);
%sort (RFP,Usubjid);

Data Repend;
merge Demo_Arm(In=A) Rfp;
by usubjid;
if A;
run;

/*to derive dthdtc and dthfl extract Raw. Death*/
Data dth (Keep=Usubjid dthdtc);
set raw.death;
usubjid=Catx("-" study, stdysite, patient);
dthdtc=Put(datepart(Deathdt), IS8601DA.);
run;
/*Remove duplicates*/
proc sort data=dth nodubkey out=dthdt;
by usubjid;
run;

/*merge DTHDT to RFPEND*/
Data Repend_Dth;
merge Repend(In=A) DTHDT;
by usubjid;
if A;
run;

Data dthfl (Rename=(Sex_=Sex Race_=Race); 
set repend_dth;
if dthdtc NE ' ' then dthfl="Y";
else "N ";
Invid=" ";
Invnam=" ";
run;

/* To Derive RFXSTDTC RFXENDTC EXTRACT STUDYMEDW DATA*/
