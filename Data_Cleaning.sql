-- Data Cleaning in MySQL
-- Data: jobs.csv

select * from jobs;

-- First we are cheking if there are any duplicates in our table using Window function and CTE
select *, row_number() over(partition by `Job Title`, `Company Name`, `Job Type`, `Experience Required`,
`Posted Date`, `Application Deadline`, `Job Portal`, `Number of Applicants`, `Education Requirement`, `Skills Required`, `Remote/Onsite`)
as num
from jobs;

with duplicates as
(select *, row_number() over(partition by `Job Title`, `Company Name`, `Job Type`, `Experience Required`,
`Posted Date`, `Application Deadline`, `Job Portal`, `Number of Applicants`, `Education Requirement`, `Skills Required`, `Remote/Onsite`)
as num
from jobs
)
select * from duplicates
where num>1;

-- If we found duplicates, we are going to create staging table, insert all data from original table with additional column 'num' and delete duplicates.
-- We want to keep original table with raw data in case something happens.
create table jobs1
like jobs;

alter table jobs1
add column num int;

insert jobs1
select *, row_number() over(partition by `Job Title`, `Company Name`, `Job Type`, `Experience Required`,
`Posted Date`, `Application Deadline`, `Job Portal`, `Number of Applicants`, `Education Requirement`, `Skills Required`, `Remote/Onsite`)
as num
from jobs;

delete from jobs1
where num>1;

select distinct `Job Title` from jobs1;
-- There were multiple values that belong to the same job title, so we grouped them by one name.
select distinct `Job Title` from jobs1
where `Job Title` like '%Data Analyst%';

update jobs1
set `Job Title`='Data Analyst'
where `Job Title` like '%Data Analyst%';

select distinct `Job Title` from jobs1
where `Job Title` like '%Data Scien%';

update jobs1
set `Job Title`='Data Scientist'
where `Job Title` like '%Data Scien%';

select distinct `Job Title` from jobs1
where `Job Title` like '%Data Engineer%';

update jobs1
set `Job Title`='Data Engineer'
where `Job Title` like '%Data Engineer%';

select distinct `Job Title` from jobs1
where `Job Title` like '%Computer%';

update jobs1
set `Job Title`='Computer Scientist'
where `Job Title` like '%Computer%';

select distinct `Job Title` from jobs1
where `Job Title` like '%Learning Engineer%';

update jobs1
set `Job Title`='Machine Learning Engineer'
where `Job Title` like '%Learning Engineer%';

select distinct `Job Title` from jobs1
where `Job Title` like '%Learning Scientist%';

update jobs1
set `Job Title`='Machine Learning Scientist'
where `Job Title` like '%Learning Scientist%';

update jobs1
set `Job Title`='Computational Scientist'
where `Job Title` like '%Computational%';

select * from jobs1;

-- Removing whitespaces
update jobs1
set `Company Name`=trim(`Company Name`);

update jobs1
set `Job Location`=trim(`Job Location`);

-- Replacing empty cells with NULL
update jobs1
set `Job Type`=null where `Job Type`='';

select `Experience Required` from jobs1;

-- There were some empty cells so we replaced them to 'None'. 
update jobs1
set `Experience Required`='None'
where `Experience Required`='';

-- Updating and coverting date values
select `Posted Date`, str_to_date(`Posted Date`,'%d/%m/%Y') from jobs1;

update jobs1
set `Posted Date` = str_to_date(`Posted Date`,'%m/%d/%Y');
-- If it doesn't work, we have to change empty values to NULL.
update jobs1
set `Posted Date`=null where `Posted Date`='';

update jobs1
set `Posted Date` = str_to_date(`Posted Date`,'%m/%d/%Y');

select `Application Deadline`, str_to_date(`Application Deadline`,'%m/%d/%Y') from jobs1;

update jobs1
set `Application Deadline`=null where `Application Deadline`='';

update jobs1
set `Application Deadline` = str_to_date(`Application Deadline`,'%m/%d/%Y');

-- Changeing data type from text to date
alter table jobs1
modify column `Posted Date` date;

alter table jobs1
modify column `Application Deadline` date;

select * from jobs1;
-- Everything looks good except there were some mistakes in typing so we standardize them.
select distinct `Job Portal` from jobs1;

update jobs1
set `Job Portal`='Naukri.com' where `Job Portal`='Naukricom';

select distinct `Skills Required` from jobs1;

update jobs1
set `Skills Required` = 'C++' where `Skills Required`='C+';

update jobs1
set `Skills Required` = 'Python' where `Skills Required` like 'P%';

update jobs1
set `Skills Required` = 'UI/UX' where `Skills Required`='UI-UX';

-- Removing columns we don't need
alter table jobs1
drop column num;

select * from jobs1;
