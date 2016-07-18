proc contents data=team4.transaction_train varnum;
run;

proc contents data=team4.cust_medical_train varnum;
run;

/*records that have more than one record with the same date and customer_id*/
proc sql;
create table int.trans_dups as
select * from team4.transaction_train
group by date, cust_id, cov_id having count(*) > 1;
quit;

proc sql;
create table int.med_dups as 
select * from team4.cust_medical_train
group by date, cust_id, cov_id having count(*) > 1;
quit;

/*count duplicates - cust medical train - 292*/
proc sql;
select count(*) from
(select date, cust_id, cov_id, count(*) as count from team4.cust_medical_train
group by 1, 2, 3 having count(*) > 1
 )as foo;
quit;

/*count duplicates - cust transactions - 292*/
proc sql;
select count(*) from
(select date, cust_id, cov_id, count(*) as count from team4.cust_medical_train
group by 1, 2, 3 having count(*) > 1
 )as foo;
quit;


/*join duplicate tables - this works but duplicates other fields*/
/*proc sql;*/
/*create table duplicates as */
/*select m.*, t.*  from med_dups m*/
/*join*/
/*trans_dups t*/
/*on m.cust_id = t.cust_id and*/
/*m.date = t.date and */
/*m.cov_id = t.cov_id;*/
/*quit;*/

/*create and id field for the join*/
data team4.med_dups_id;
	set med_dups;
	ID=_n_;
run;

data team4.trans_dups_id;
	set trans_dups;
	ID=_n_;
run;

/*join duplicate tables based on ID*/
proc sql;
create table team4.med_trans_dups as 
select m.*, t.*  from team4.med_dups_id m
join
team4.trans_dups_id t
on m.id = t.id;
quit;



proc sql;
create table team4.med_trans_dups as 
select m.*, t.*  from team4.med_dups_id m
join
team4.trans_dups_id t
on m.id = t.id;
quit;

/*create a working dataset*/
data int.transaction_train;
	set team4.transaction_train;
run;

data int.cust_medical_train;
	set team4.cust_medical_train;
run;

data int.duplicates;
	set team4.med_trans_dups;
run;

/*delete duplicate values from working dataset*/
proc sql;
delete from int.transaction_train t
where exists (select 1 from int.duplicates d where 
			t.cust_id =d.cust_id and 
			t.date = d.date and 
			t.cov_id = d.cov_id);
quit;

proc sql;
delete from int.cust_medical_train m
where exists (select 1 from int.duplicates d where 
				m.cust_id =d.cust_id and 
				m.date = d.date and 
				m.cov_id = d.cov_id);
quit;

/*join cust_medical train and transaction_train 265,205 expected obs*/
proc sql;
create table int.med_trans_ as 
select m.*, t.*  from int.cust_medical_train m
join
int.transaction_train t
on m.cust_id = t.cust_id and
	m.date=t.date and
	m.cov_id=t.cov_id;
quit;

data int.duplicates;
	set int.duplicates;
	drop ID;
run;

/*union takes too long*/
/*proc sql;*/
/*select * from med_trans*/
/*UNION ALL */
/*select * from duplicates;*/
/*quit;*/

/*concatenate datasets - expected obs 265,999*/
data team4.med_trans;
	set int.med_trans_ int.duplicates;
run;

/*count of null medical values, count of null medical with transaction reward, count of transaction reward all equal 42,889*/
proc sql;
select count(*) from team4.med_trans
	where total IS NULL and transaction = 'RE';
quit;

/*check for duplicate claims*/
proc sql;
select count(*) from
(select cust_id, cov_id, transaction, count(*) as count from team4.med_trans
group by 1, 2, 3 having count(*) > 1
 )as foo;
quit;





