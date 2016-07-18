proc contents data=team4.fam_med_train varnum;
run;

/*create a test dataset*/
data test;
	set team4.fam_med_train(obs=20);
run;

/*convert training data to numeric*/
proc sql;
create table team4.fam_med_train2 as
select cust_id, input(MedF_HA, 8.) as MedF_HA,
				input(MedF_BP, 8.) as MedF_BP,
				input(MedF_Can, 8.) as MedF_Can,
				input(MedF_Diab, 8.) as MedF_Diab,
				input(MedF_Chol, 8.) as MedF_Chol,
				input(MedF_Arth, 8.) as MedF_Arth,
				input(MedF_Asth, 8.) as MedF_Asth,
				input(MedF_Gla, 8.) as MedF_Gla,
				input(MedF_Kid, 8.) as MedF_Kid,
				input(MedF_Leuk, 8.) as MedF_Leuk,
				input(MedF_Ment, 8.) as MedF_Ment,
				input(MedF_SE, 8.) as MedF_SE,
				input(MedF_SCA, 8.) as MedF_SCA,
				input(MedF_Str, 8.) as MedF_Str,
				input(MedF_TD, 8.) as MedF_TD,
				input(MedF_TB, 8.) as MedF_TB,
				input(MedF_Ul, 8.) as MedF_Ul,
				input(MedM_HA, 8.) as MedM_HA,
				input(MedM_BP, 8.) as MedM_BP,
				input(MedM_Can, 8.) as MedM_Can,
				input(MedM_Diab, 8.) as MedM_Diab,
				input(MedM_Chol, 8.) as MedM_Chol,
				input(MedM_Arth, 8.) as MedM_Arth,
				input(MedM_Asth, 8.) as MedM_Asth,
				input(MedM_Gla, 8.) as MedM_Gla,
				input(MedM_Kid, 8.) as MedM_Kid,
				input(MedM_Leuk, 8.) as MedM_Leuk,
				input(MedM_Ment, 8.) as MedM_Ment,
				input(MedM_SE, 8.) as MedM_SE,
				input(MedM_SCA, 8.) as MedM_SCA,
				input(MedM_Str, 8.) as MedM_Str,
				input(MedM_TD, 8.) as MedM_TD,
				input(MedM_TB, 8.) as MedM_TB,
				input(MedM_Ul, 8.) as MedM_Ul,
				Mother_Total, Father_Total, Total
	from team4.fam_med_train;
quit;

proc contents data=team4.fam_med_train2 varnum;
run;

/*check to see if new table has same # variables and count as old table*/
proc contents data=team4.fam_med_train varnum;
run;

/*convert validation table to numeric*/
proc sql;
create table team4.fam_med_valid2 as
select cust_id, input(MedF_HA, 8.) as MedF_HA,
				input(MedF_BP, 8.) as MedF_BP,
				input(MedF_Can, 8.) as MedF_Can,
				input(MedF_Diab, 8.) as MedF_Diab,
				input(MedF_Chol, 8.) as MedF_Chol,
				input(MedF_Arth, 8.) as MedF_Arth,
				input(MedF_Asth, 8.) as MedF_Asth,
				input(MedF_Gla, 8.) as MedF_Gla,
				input(MedF_Kid, 8.) as MedF_Kid,
				input(MedF_Leuk, 8.) as MedF_Leuk,
				input(MedF_Ment, 8.) as MedF_Ment,
				input(MedF_SE, 8.) as MedF_SE,
				input(MedF_SCA, 8.) as MedF_SCA,
				input(MedF_Str, 8.) as MedF_Str,
				input(MedF_TD, 8.) as MedF_TD,
				input(MedF_TB, 8.) as MedF_TB,
				input(MedF_Ul, 8.) as MedF_Ul,
				input(MedM_HA, 8.) as MedM_HA,
				input(MedM_BP, 8.) as MedM_BP,
				input(MedM_Can, 8.) as MedM_Can,
				input(MedM_Diab, 8.) as MedM_Diab,
				input(MedM_Chol, 8.) as MedM_Chol,
				input(MedM_Arth, 8.) as MedM_Arth,
				input(MedM_Asth, 8.) as MedM_Asth,
				input(MedM_Gla, 8.) as MedM_Gla,
				input(MedM_Kid, 8.) as MedM_Kid,
				input(MedM_Leuk, 8.) as MedM_Leuk,
				input(MedM_Ment, 8.) as MedM_Ment,
				input(MedM_SE, 8.) as MedM_SE,
				input(MedM_SCA, 8.) as MedM_SCA,
				input(MedM_Str, 8.) as MedM_Str,
				input(MedM_TD, 8.) as MedM_TD,
				input(MedM_TB, 8.) as MedM_TB,
				input(MedM_Ul, 8.) as MedM_Ul,
				Mother_Total, Father_Total, Total
	from team4.fam_med_valid;
quit;

/*check for same number of variables and observations in new vs old table*/
proc contents data=team4.fam_med_valid2 varnum;
run;

proc contents data=team4.fam_med_valid varnum;
run;

/*create a histogram for total with bin size = 1*/
ods select histogram;
title 'Distribution of Total Number of Diseases in Family History';
proc univariate data=team4.fam_med_train2 noprint;
    var Total;
    histogram Total / endpoints= 0 to 11 by 1;
run;

/*calculate frequency stats*/
proc freq data=team4.fam_med_train2;
	tables Total; 
run;

/*descriptive stats*/
proc means data=team4.fam_med_train2 maxdec=3;
	var Total;
run;

/*create a histogram for mother_total with bin size = 1*/
ods select histogram;
title "Distribution of Total Number of Diseases in Mother's Family History";
proc univariate data=team4.fam_med_train2 noprint;
    var Mother_Total;
    histogram Mother_Total / endpoints= 0 to 7 by 1;
run;

/*calculate frequency stats*/
proc freq data=team4.fam_med_train2;
	tables Mother_Total; 
run;

/*descriptive stats*/
proc means data=team4.fam_med_train2 maxdec=3;
	var Mother_Total;
run;

/*create a histogram for mother_total with bin size = 1*/
ods select histogram;
title "Distribution of Total Number of Diseases in Father's Family History";
proc univariate data=team4.fam_med_train2 noprint;
    var Father_Total;
    histogram Father_Total / endpoints= 0 to 7 by 1;
run;

/*calculate frequency stats*/
proc freq data=team4.fam_med_train2;
	tables Father_Total; 
run;

/*descriptive stats*/
proc means data=team4.fam_med_train2 maxdec=3;
	var Father_Total;
run;

/*isolate numeric variables*/
data fm_var;
	set team4.fam_med_train2;
	drop cust_id;
run;

/*compare frequency to common med history - 29% Cholesterol*/
proc freq data=fm_var;
	tables MedF_Chol MedM_Chol;
run;

/*~48,000 cases with at least one family history of cholesterol and ~8,000 cases with both*/
proc sql;
select count(cust_id) from team4.fam_med_train2 where MedM_Chol = 1 and MedF_Chol=1;
select count(cust_id) from team4.fam_med_train2 where MedM_Chol = 1 or MedF_Chol=1;
quit;

/*compare frequency to common med history - 22% High Blood Pressure*/
proc freq data=fm_var;
	tables MedF_BP MedM_BP;
run;

/*~38,000 cases with at least one family history of cholesterol and ~4,500 cases with both*/
proc sql;
select count(cust_id) from team4.fam_med_train2 where MedM_BP = 1 and MedF_BP=1;
select count(cust_id) from team4.fam_med_train2 where MedM_BP = 1 or MedF_BP=1;
quit;

/*create test data*/
data fm_test;
	set fm_test (obs=10);
run;

/*create a medical total dataset with the total number diseases from both mother and father*/
data team4.med_tot;
	set team4.fam_med_train2;
	array mother {*} MedM:;
	array father {*} MedF:;
		do i = 1 to dim(mother);
			mother{i}+father{i};
		end;
	drop i MedF:;
run;
/*rename data*/
data team4.med_tot2;
	set team4.med_tot;
	rename MedM_HA = MedT_HA MedM_BP=MedT_BP MedM_Can=MedT_Can MedM_Diab=MedT_Diab MedM_Chol=MedT_Chol MedM_Arth=MedT_Arth MedM_Gla = MedT_Gla MedM_Kid=MedT_Kid MedM_Leuk =MedT_Leuk MedM_Ment=MedT_Ment MedM_SE= MedT_SE MedM_SCA=MedT_SCA
			MedM_Str=MedT_Str MedM_TD = MedT_TD MedM_TB= MedT_TB MedM_Ul=MedT_Ul;
run;
/*create temp dataset sorting most diseases to least*/
proc sort data=team4.med_tot
			out=med_tot;
	by descending total;
run;

/*look at partial output*/
proc print data=med_tot (obs=100);
run;

proc contents data=med_tot varnum;
run;
	
/*look at frequency tables for all disease*/
proc freq data=team4.med_tot;
	tables _ALL_ / nocum;
run;

/*export a .csv file*/
ods csv file= 'C:\SummerPracticum\CopyData\fam_med.csv';
 proc print data = team4.fam_med_train2 noobs;
 run;
 ods csv close;

/* All diseases have an almost identical split between mother's history and father's history*/
/* these were probably calculated with the rand function*/





	

				




