use ispic_production;
load data infile "/var/www/Ispick/current/db/people2014/people" into table people fields terminated by ',';
load data infile "/var/www/Ispick/current/db/people2014/people_titles" into table people_titles fields terminated by ',';
load data infile "/var/www/Ispick/current/db/people2014/titles" into table titles fields terminated by ',';
load data infile "/var/www/Ispick/current/db/people2014/people_keywords" into table people_keywords fields terminated by ',';
load data infile "/var/www/Ispick/current/db/people2014/keywords" into table keywords fields terminated by ',';