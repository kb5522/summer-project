proc contents data=team4.cust_medical_train varnum;
run;

proc print data=team4.cust_medical_train (obs=50);
run;

/*records that have more than one record with the same date and customer_id*/
proc sql;
select * from team4.cust_medical_train
group by date, cust_id having count(*) > 1;
quit;


proc sql;
select * from team4.customer_medical
group by date, cust_id having count(*) > 1;
quit;

/*count the number of records that are duplicate - 308*/
proc sql;
select count(*) from
(select date, cust_id, count(*) as count from team4.cust_medical_train
group by 1, 2 having count(*) > 1
 )as foo;
quit;

/*count the number of records that are duplicate - 386*/
proc sql;
select count(*) from
(select date, cust_id, count(*) as count from team4.customer_medical
group by 1, 2 having count(*) > 1
 )as foo;
quit;

/*records that have more than 1 cust_id, date, cov_id*/
proc sql;
select * from team4.cust_medical_train
group by date, cust_id, cov_id having count(*) > 1;
quit; 

/*count the number of records that are duplicate - 308*/
proc sql;
select count(*) from
(select date, cust_id, count(*) as count from team4.cust_medical_train
group by 1, 2 having count(*) > 1
 )as foo;
quit;

/*count the number of records that are duplicate - 292 records*/
proc sql;
select count(*) from
(select date, cust_id, cov_id, count(*) as count from team4.cust_medical_train
group by 1, 2, 3 having count(*) > 1
 )as foo;
quit;

data med_20;
	set team4.cust_medical_train (obs=20);
	drop 
run;


/*group by cust_id sum of conditions*/
/*if > 1 then set to 1*/

