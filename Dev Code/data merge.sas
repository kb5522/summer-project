/*Sorting for customer merges*/

proc sort data=Team4.Transaction_train;
	by Cust_ID;
run;

/*Making narrow customer dataset (timeseries)*/

data Team4.customer Team4.customer_nonmatch;
	merge Team4.custinfotrain (in=i)
		  Team4.transaction_train (in=t)
		  Team4.cust_medical_train (in=m)
		  Team4.fam_med_train (in=f);
	by cust_id;
	if i=1 and t=1 and m=1 and f=1 then output Team4.customer;
	else output Team4.customer_nonmatch;
run;

/*Making wide customer dataset (summary)*/

data Team4.customer_summary Team4.customer_summary_nonmatch;
	merge Team4.custinfotrain (in=i)
		  Team4.transaction_summary_train (in=t)
		  Team4.cust_medical_train (in=m)
		  Team4.fam_med_train (in=f);
	by cust_id;
	if i=1 and t=1 and m=1 and f=1 then output Team4.customer_summary;
	else output Team4.customer_summary_nonmatch;
run;

/*Making narrow employee dataset*/

proc sort data=Team4.Transaction_train;
	by Cov_id;
run;

proc sort data=Team4.adj_tech_training;
	by Cov_id;
run;

data Team4.employee Team4.employee_nonmatch;
	merge Team4.adj_tech_training (in=a)
		  Team4.Transaction_train (in=t);
	by Cov_id;
	if a=1 and t=1 then output Team4.employee;
	else output Team4.employee_nonmatch;
run;
