/*group by customer ID, sum medical, average tobacco, caffeine, alcohol*/
/*if medical > 1 set to 1*/

/*create test data*/
data int.unique_med50;
	set team4.med_trans (obs= 50);
run;

/*proc sql;*/
/*select gender, drug, avg(hr) as Average_HR*/
/*from clean.patients where gender in ('M', 'F') and drug in ('A', 'B', 'C', 'D')*/
/*group by gender, drug;*/
/*quit;*/

/*create a table with unique medical records*/
proc sql;
create table team4.unique_cust_medical as 
select cust_id, avg(tobacco_num) as avg_tobacco, avg(caffeine_num) as avg_caffeine, avg(alcohol_num) as avg_alcohol, max(tobacco_num) as max_tobacco, max(caffeine_num) as max_caffeine, max(alcohol_num) as max_alcohol,  sum(Med_HA)as Med_HA, sum(Med_BP)as Med_BP, sum(Med_Can) as Med_Can,
		sum(med_diab) as Med_Diab, sum(med_chol)as Med_Chol, sum(med_arth) as Med_Arth, sum(med_Asth)as Med_Asth, sum(med_gla)as Med_Gla, sum(med_kid)as Med_Kid, sum(med_leuk)as Med_Leuk, 
		sum(med_ment) as Med_Ment, sum(med_SE)as Med_SE, sum(med_SCA) as Med_SCA,sum(med_str) as Med_Str, sum(Med_td) as Med_td, sum(med_tb) as Med_tb, sum(med_ul)as Med_Ul from team4.med_trans where total IS NOT NULL
group by cust_id;
quit;

/*test data*/
data int.unique50;
	set team4.unique_cust_medical (obs=50);
run;

/*convert summed Yes disease values back to 1*/
data team4.unique_cust_medical;
	set team4.unique_cust_medical;
	array M {*} med:;
		do i=1 to dim(M);
			if M{i} > 1 then M{i} = 1;
		end;
	drop i;
run;

/*join unique_cust_medical and fam_med_train2*/
proc sql;
create table team4.unique_cust_fam_med as 
select m.*, t.*  from team4.unique_cust_medical m
join
team4.fam_med_train2 t
on m.cust_id = t.cust_id;
quit;

/*join med_tot2 to unique_cust_fam_med*/
proc sql;
create table team4.unique_cust_fam_med as 
select m.*, t.* from team4.unique_cust_fam_med m
join
team4.med_tot2 t
on m.cust_id = t.cust_id;
quit;

/*compare frequency of disease - No effect or father vs mother on HA, Chol, BP*/
proc freq data=team4.unique_cust_fam_med;
    tables medM_HA*Med_HA MedF_HA*Med_HA MedT_HA*Med_HA/
           plots(only)=freqplot(scale=percent);
run;

proc freq data=team4.unique_cust_fam_med;
    tables medM_ment*Med_ment MedF_ment*Med_ment MedT_ment*Med_ment/
           plots(only)=freqplot(scale=percent);
run;

/*look at odds ratio - mental health 1.13 seizures - 0.54*/
/*ods select relativerisks; */
title;
proc freq data=team4.unique_cust_fam_med;
    tables (MedF_HA)*Med_HA
          / chisq nocol nopercent 
            relrisk;
/*    title 'Associations with Heart Attack';*/
run;


/*if you slice by age, who is more likely to die from health related causes?*/

/*instead of age: the difference in time between initiating the coverage and claiming it*/

/*predict other types of death? criminal activity*/



