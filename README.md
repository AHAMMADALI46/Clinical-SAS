# Clinical-SAS
/*Clinical SAS*/
Options Validvarname=upcase nofmterr missing='';
Data demo;
set raw.demowide (Drop=Studyid);
run;

Data demo1 (keep=studyid domain usubjid country subjid siteid brthdtc age ageu sex_ Race_);
set demo(where=(Tpcode ne ' '));
studyid=study;
domain="dm";
usubjid=catx("-", study, stdysite, patien);
subjid=patient;
siteid=stdysite;
brthdtc=strip(Put(datepart(birthd), Iso8601DA.));
sex_=first(sex);
if index(Race, "other")>0 then Race_="other";
else if race /* Cut*/



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
Data exp (keep=usubjid rfxstdtc);
set raw. stdymedw;
where stint="single dose period";
usubjid=Catx("-" study, stdysite, patient);
if startdtp="MI" then rfxstdtc=Put(startdt, IS8601DT.);
else if startdtp="DY" then rfxstdtc=Put(datepart(startdt), IS8601DA.);
run;

Data exp1 (keep=usubjid rfxendtc);
set raw. stdymedw (where=(stopdtp="DY"));
usubjid=Catx("-" study, stdysite, patient);
if stopdtp="DY" then rfxendtc=Put(datepart(stopdt), IS8601DT.);
run;

%sort (Exp1, usubjid);
Data exp2;
set exp1;
if last.usubjid;
by usubjid;
run;

/*Merge Exp, Exp2 to Dthfl*/

