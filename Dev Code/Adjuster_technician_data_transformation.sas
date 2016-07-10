
* total observations 107460;
* there are 12876 that are not zips;
* which sum to 67 different cities/towns in the dataset;
* 53730 is the number of distinc claims;
* count of each non numericc value;
title "Number of observations that are not Zip codes";
proc sql;
	select count(*), adj_zip from team4.Adjuster_technician 
	 where not prxmatch('/\d{5}/', adj_zip)
	 group by adj_zip;
run;

proc format;
	value $role 'T'='Technician'
				'A'='Adjuster';
run;

* create a dataset that is needed... dropping claim_info since we are splitting it
into 2 columns : role and empl_id; 
data adj_test_format; *(drop=claim_info);
* renaming the cov_id to claim_id for clarity adj_test;
	set team4.Adjuster_technician    (rename=(claim_info=empl_id));
	length City $ 24 State $ 24 raw_zip $ 18;
	format role $role.;
	* create role and get the first char from claim info;
	role = substr(empl_id,1,1);
	* making permanent labels for the dataset;
	label cov_id = " Claim ID "
			adj_zip = " Original Address Info "
			role = " Employee's Role "
			empl_id = " Full Employee ID "
			raw_zip = " Available Zip Codes ";
	
	test_var = input(adj_zip, 8.);
	if(test_var = .) then do;
	* many have value of California in the zip code;
		if adj_zip='California'
			then do;
				State = "California";
				City = " ";
			end;
		* loop though all of the cities until find the needed one;
		if adj_zip in ("Los Angeles", "Sacramento","San Diego","Emeryville","Berkeley","Burbank","Anaheim","Fresno","Pasadena" ,"Bakersfield","North Hollywood","San Francisco","Claremont","Lakewood","San Marino","Sheridan","Joseph", "Seneca", "Seaside","Hamburger", "Ridgeview","Ontario", "Gaston","Newport", "Junction City","Monroe")
							then do;
								State="California"; 
								city = adj_zip;
							end;
		else if adj_zip in ("Portland","Beaverton","Blachly","Eugene","Tigard","Salem","Grants Pass","Pendleton","Bend","Klamath Falls","Chiloquin","Hillsboro","Port Orford", "Gresham", "Pilot Rock","North Powder","Silverton","Mosier","Ashland","Mitchell","Medford","Lebanon","Albany","Cottage Grove", "Condon")
							then do;
								State="Oregon"; 
								city = adj_zip;
							end;
		else if adj_zip in ( "Spokane","Bellevue","Seattle","Tumwater")
							then do;
								State="Washington"; 
								city = adj_zip;
							end;
		else if adj_zip in ( "Honolulu","Mililani","Waipahu") 
							then  do;
								State="Hawaii"; 
								city = adj_zip;
							end;
		else if adj_zip in ( "Kodiak","Tununak","Eagle River") 
							then do;
								State="Alaska"; 
								city = adj_zip;
							end;
		else if adj_zip in ( "Las Vegas","Henderson","Goshute")  
							then do;
								State="Nevada"; 
								city = adj_zip;
							end;
		else if adj_zip in ( "Mohave Valley") 
							then do;
								State="Arizona"; 
								city = adj_zip;
							end;
		
	end;
	else do;
	* get the state and city from zip;
		State=zipnamel(adj_zip);
		citystate=zipcity(adj_zip);
    	city=scan(citystate,1,',');
		raw_zip = adj_zip;
	end;
	drop test_var citystate;
run;

proc print data=adj_test_format (obs=10009) label;
	var cov_id empl_id role city state raw_zip adj_zip;
run;

* find how many observations per wrong zip code  /\d{5}/;
/*proc sql;
    create table work.wrong_zip1 as 	 
	select adj_zip, count(*) as Count  from adj_test_format 
	where not prxmatch('/\d{5}/', adj_zip)
	 group by adj_zip
	order by Count desc;
run; */
