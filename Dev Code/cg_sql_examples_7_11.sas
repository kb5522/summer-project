/*join example*/
proc sql;
create table testjoin as
select t.* from team4.transaction_summary_data t
join
newproj.cust_train n
on t.cust_id = n.cust_id;
quit;

proc print data=testjoin(obs=10);
run;

/*exploring with sql*/

proc sql;
create table team4.duplicate_national as
select t.* from 
(select nationalID, count(distinct cust_id) from team4.customer_info
group by 1
having count(distinct cust_id) > 1) as foo, team4.customer_info t
where foo.nationalID = t.nationalID;
quit;

proc sql;
create table team4.duplicate_national as
select nationalID, count(distinct cust_id) as count from team4.customer_info
group by 1
having count(distinct cust_id) > 1
order by count desc;
quit;

/****************
proc sql outobs=10;
select t2.* from
(select t.cust_id, foo.nationalID from 
(select nationalID, count(distinct cust_id) from team4.customer_info
group by 1
having count(distinct cust_id) > 1) as foo, team4.customer_info t
where foo.nationalID = t.nationalID) as foo2, team4.customer_transactions t2
where foo2.cust_id = t2.cust_id
and t2.transaction = 'RE';
quit;
***************/


proc sql;
select count(*) from newproj.cust_train;
quit;

proc sql;
select count(*) from team4.customer_info;
quit;
