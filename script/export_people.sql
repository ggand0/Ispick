use ispic_development;
select * from people into outfile "/Users/pentiumx/Projects/Ispick/db/people2014/people" fields terminated by ',';
select * from people_titles into outfile "/Users/pentiumx/Projects/Ispick/db/people2014/people_titles" fields terminated by ',';
select * from people_keywords into outfile "/Users/pentiumx/Projects/Ispick/db/people2014/people_keywords" fields terminated by ',';
select * from titles into outfile "/Users/pentiumx/Projects/Ispick/db/people2014/titles" fields terminated by ',';
select * from keywords into outfile "/Users/pentiumx/Projects/Ispick/db/people2014/keywords" fields terminated by ',';