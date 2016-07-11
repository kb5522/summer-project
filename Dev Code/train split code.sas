data Team4.custinfotrain Team4.custinfovalid other;
	merge Team4.cust_info_2
		  Team4.cust_train (in=train)
		  Team4.cust_valid (in=valid);
	by Cust_ID;
	if train=1 and valid=0 then output Team4.custinfotrain;
	else if train=0 and valid=1 then output Team4.custinfovalid;
	else output other;
run;
