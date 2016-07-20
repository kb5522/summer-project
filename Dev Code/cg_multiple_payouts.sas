
/**********
Further analysis of customers with multiple payouts on the same coverage
**********/

proc sql;
select cust_id, cov_id, count(*) as count from team4.customer
where transaction = 'RE'
group by 1, 2
having count(*) > 1
order by count desc;
quit;

proc sql;
create table investigate_reward as
select t.cust_id, t.cov_id, t.date, t.type, t.transaction, t.reward_a from
(select cust_id, cov_id, count(*) as count from team4.customer
where transaction = 'RE'
group by 1, 2
having count(*) > 1) as customers, team4.customer t
where customers.cust_id = t.cust_id
and customers.cov_id = t.cov_id
order by 1, 2, 3;
quit;

proc means data=investigate_reward sum;
var reward_a;
run;

/*Total payouts = 534,850,000 --BOOM!*/


/*if we want to assume the first payment is valid, and the rest are fraud (some had 3)*/
data sum_reward;
set investigate_reward;
where transaction='RE';
by cust_id;
if not first.cust_id then do;
	total_fraud + reward_a;
	end;
run;

proc means data=sum_reward max;
var total_fraud;
run;

/*Total payouts = 296,450,000*/ 
