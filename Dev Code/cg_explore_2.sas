/******************/
/*are there multiple nationalID's?*/ /*YES--why? fraud?*/
proc sql;
select nationalID, count(distinct cust_id) as count from team4.customer_info
	group by 1
	having count(distinct cust_id) > 1
order by count desc;
quit;
/*******************/ 


proc print data=team4.customer_transactions (obs=10);run;

/*/*create table 'new_customer' to merge with (keep good vars)*/*/
/*data new_customer;*/
/*	set team4.customer_info;*/
/*	keep gender streetaddress city state zipcode birthday cctype nationalID vehicle bloodtype pounds feetinches cust_id race marriage;*/
/*	/*need to recode feetinches to inches*/*/
/*run;*/

/*create table of distinct cust_ids*/;
proc sort data=team4.customer_transactions out=distinct_cust_id nodupkey;
by cust_id;
run;

data distinct_cust_id;
set distinct_cust_id;
keep cust_id;
run;


/****/
*now create temp tables (pk=cust_id) to merge with final table. always check to see if no matches;
/***/

/*cov_id count*/
proc sql;
create table cov_id_counts as
select cust_id, count(distinct cov_id) as cov_id_count from team4.customer_transactions
group by 1;
quit;
proc print data=cov_id_counts (obs=10);run;


/*var =  income
-initial
-final
-difference*/

/*Initial income
-first we need to sort by cust_id, date*/
proc sort data=team4.customer_transactions out=sort_custid_date;
by cust_id date;
run;

data initial_income;
set sort_custid_date(keep=cust_id date income);
by cust_id date;
if first.date and first.cust_id then output;
rename income=initial_income;
run;

proc print data=initial_income(obs=10);run;

/*need to account for missing values (the final cov_limit is missing when there is a reward_a)
	--since the values are always missing when type = "RE" we will conditionally exclude them*/
data final_income;
set sort_custid_date(keep=cust_id date income transaction);
where transaction <> 'RE';
by cust_id date;
if last.date and last.cust_id then output;
rename income=final_income;
run;

proc print data=final_income(obs=10);run;

/*will calculate difference after merge*/



/*var = cov_limit
-initial
-final
-difference*/


data initial_covlimit;
set sort_custid_date(keep=cust_id date cov_limit);
by cust_id date;
if first.date and first.cust_id then output;
rename cov_limit=initial_cov_limit;
run;

proc print data=initial_covlimit(obs=10);run;

/*handling missing values the same as income -- exclude reward transactions*/
data final_covlimit;
set sort_custid_date(keep=cust_id date cov_limit transaction);
where transaction <> 'RE';
by cust_id date;
if last.date and last.cust_id then output;
rename cov_limit=final_cov_limit;
run;

proc print data=final_covlimit(obs=10);run;

/*will calculate difference after merge*/

/*determine intial difference between income and cov_limit*/
data initial_difference;
set sort_custid_date;
by cust_id date;
if first.date and first.cust_id then do;
	initial_difference = income - cov_limit;
	output;
	end;
keep cust_id income cov_limit initial_difference;
run;

proc print data=initial_difference(obs=10);run;

/*now lets make use of the reward_types*/

/*recode reward_r to reward_type(reason for type of death)*/
data new_trans;
format reward_type $50.;
set team4.customer_transactions;
if reward_r >= 100 and reward_r <=199 then reward_type = 'Accidental Death';
else if reward_r >= 200 and reward_r <=299 then reward_type = 'Criminal Acts';
else if reward_r >= 300 and reward_r <=499 then reward_type = 'Health Related Causes';
else if reward_r >= 500 and reward_r <=549 then reward_type = 'Dangerous Activity - Exclusion';
else if reward_r >= 550 and reward_r <=559 then reward_type = 'War - Exclusion';
else if reward_r >= 560 and reward_r <=569 then reward_type = 'Aviation - Exclusion';
else if reward_r >= 570 and reward_r <=579 then reward_type = 'Suicide - Exclusion';
run;

/*create reward exclusion (binary) var -- reward_e*/
data new_trans2;
set new_trans;
if reward_type in ('Dangerous Activity - Exclusion','War - Exclusion','Aviation - Exclusion','Suicide - Exclusion')
then reward_exclusion = 1;
else reward_exclusion = 0;
run;

data reward_trans;
set new_trans2;
where transaction='RE';
keep cust_id cov_id type date reward_a reward_exclusion reward_type;
rename date=reward_date reward_a=reward_amount type=policy_type_reward;
run;

/*there are cust_id's with more than 1 reward*/
proc sql;
select r.* from
(select cust_id, count(*) from reward_trans
group by 1
having count(*) > 1) as foo, reward_trans r
where foo.cust_id = r.cust_id
order by cust_id;
quit;

/*number of rewards and total_amount_rewarded*/
proc sql;
create table total_rewards as
select cust_id, count(*) as num_of_rewards, sum(reward_amount) as total_amount_rewarded
from reward_trans
group by 1;
quit;

proc sql;
select num_of_rewards, count(*) from total_rewards
group by 1;
quit;
/*
1 42276 
2 4638 
3 659 
*/



data all_reward_trans;
merge distinct_cust_id(in=incust) reward_trans(in=inrew);
by cust_id;
has_reward=inrew;
run;

/************/

/*now start merging*/
/*tables: distinct_cust_id, cov_id_counts.*, initial_income.initial_income, final_income.final_income,
			initial_covlimit.initial_covlimit, final_covlimit.final_covlimit, initial_difference.initial_difference*/

proc sql;
create table transaction_data as
select a1.*, a2.*, a3.initial_income, a4.final_income,
			a5.initial_cov_limit, a6.final_cov_limit, a7.initial_difference,
			a4.final_income-a3.initial_income as income_diff,
			a6.final_cov_limit-a5.initial_cov_limit as cov_limit_diff,
			a8.num_of_rewards, a8.total_amount_rewarded
from distinct_cust_id a1
join cov_id_counts a2
	on a1.cust_id = a2.cust_id
join initial_income a3
	on a1.cust_id = a3.cust_id
join final_income a4
	on a1.cust_id = a4.cust_id
join initial_covlimit a5
	on a1.cust_id = a5.cust_id
join final_covlimit a6
	on a1.cust_id = a6.cust_id
join initial_difference a7
	on a1.cust_id = a7.cust_id
left join total_rewards a8
	on a1.cust_id = a8.cust_id;
quit;

proc contents data=transaction_data;
run;

proc print data=transaction_data (obs=10);
var cust_id cov_id_count initial_income final_income income_diff 
	initial_cov_limit final_cov_limit cov_limit_diff initial_difference
	num_of_rewards total_amount_rewarded;
run;

data team4.transaction_summary_data;
set transaction_data;
run;

proc sql; 
select cust_id, count(*) from team4.customer_transactions
where transaction = 'RE'
group by 1
having count(*) > 1;
quit;
