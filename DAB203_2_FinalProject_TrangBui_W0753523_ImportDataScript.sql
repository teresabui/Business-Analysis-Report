Use SQLBook

--  tables for storing csv files
drop table ztmp_COVID19_line_list_data;
create table ztmp_COVID19_line_list_data
(id varchar(255),case_in_country varchar(255),reporting_date varchar(255),field1 varchar(255),summary varchar(2550),location varchar(255),country varchar(255),
gender varchar(255),age varchar(255),symptom_onset varchar(255),If_onset_approximated varchar(255),hosp_visit_date varchar(255),exposure_start varchar(255),exposure_end varchar(255),
visiting_Wuhan varchar(255),from_Wuhan varchar(255),death varchar(255),recovered varchar(255),symptom varchar(255),source varchar(255),link varchar(2550),
field2 varchar(255), field3 varchar(255), field4 varchar(255), field5 varchar(255), field6 varchar(255), field7 varchar(255)
);

BULK INSERT ztmp_COVID19_line_list_data
FROM 'D:\BB\COVID19_line_list_data.csv'
WITH
(
    FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	FORMAT = 'CSV'
);

select * from ztmp_COVID19_line_list_data;

select * from ztmp_COVID19_line_list_data
where field1 is not null
or field2 is not null
or field3 is not null
or field4 is not null
or field5 is not null
or field6 is not null
or field7 is not null;

select max(len(summary)), max(len(link)) from ztmp_COVID19_line_list_data;

select * from ztmp_COVID19_line_list_data where reporting_date='Error';

-- fix data
update ztmp_COVID19_line_list_data
set reporting_date=replace(reporting_date,'NA',''),
symptom_onset=replace(symptom_onset,'NA',''),
If_onset_approximated=replace(If_onset_approximated,'NA',''),
hosp_visit_date=replace(hosp_visit_date,'NA',''),
exposure_start=replace(exposure_start,'NA',''),
exposure_end=replace(exposure_end,'NA',''),
visiting_Wuhan=replace(visiting_Wuhan,'NA',''),
from_Wuhan=replace(from_Wuhan,'NA',''),
age=replace(age,'NA','');

update ztmp_COVID19_line_list_data
set death='1' where death not in ('0','1') and death is not null;

update ztmp_COVID19_line_list_data
set recovered='1' where recovered not in ('0','1') and recovered is not null;

update ztmp_COVID19_line_list_data
set age=round(age,0);

drop table COVID19_line_list_data;
create table COVID19_line_list_data
(id int,case_in_country int,reporting_date date,summary varchar(450),location varchar(255),country varchar(255),
gender varchar(255),age int,symptom_onset varchar(255),If_onset_approximated bit,hosp_visit_date varchar(255),exposure_start varchar(255),exposure_end varchar(255),
visiting_Wuhan bit,from_Wuhan bit,death bit,recovered bit,symptom varchar(255),source varchar(255),link varchar(800)
);

INSERT INTO COVID19_line_list_data(id,case_in_country,reporting_date,summary,location,country,gender,age,symptom_onset,If_onset_approximated,hosp_visit_date,exposure_start,exposure_end,visiting_Wuhan,from_Wuhan,death,recovered,symptom,source,link)
select id,case_in_country,reporting_date,summary,location,country,gender,age,symptom_onset,If_onset_approximated,hosp_visit_date,exposure_start,exposure_end,visiting_Wuhan,from_Wuhan,death,recovered,symptom,source,link
from ztmp_COVID19_line_list_data;

select * from COVID19_line_list_data;


-------------------------
drop table ztmp_time_series_covid_19_confirmed_US;
create table ztmp_time_series_covid_19_confirmed_US
(UID varchar(255),iso2 varchar(255),iso3 varchar(255),code3 varchar(255),FIPS varchar(255),Admin2 varchar(255),Province_State varchar(255),Country_Region varchar(255),Lat varchar(255),Long_ varchar(255),Combined_Key varchar(255),ConfirmedCases varchar(255));

GO
BULK INSERT ztmp_time_series_covid_19_confirmed_US
FROM 'D:\BB\time_series_covid_19_confirmed_US_new.csv'
WITH
(
    FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	FORMAT = 'CSV'
);

select * from ztmp_time_series_covid_19_confirmed_US;

drop table time_series_covid_19_confirmed_US;
create table time_series_covid_19_confirmed_US
(UID int,iso2 varchar(255),iso3 varchar(255),code3 int,FIPS float,Admin2 varchar(255),Province_State varchar(255),Country_Region varchar(255),Lat float,Long_ float,Combined_Key varchar(255),ConfirmedCases int);
GO
insert into time_series_covid_19_confirmed_US
(UID,iso2,iso3,code3,FIPS,Admin2,Province_State,Country_Region,Lat,Long_,Combined_Key,ConfirmedCases)
select UID,iso2,iso3,code3,FIPS,Admin2,Province_State,Country_Region,Lat,Long_,Combined_Key,ConfirmedCases
from ztmp_time_series_covid_19_confirmed_US;
GO

select * from time_series_covid_19_confirmed_US;

--------------------
GO
sp_rename 'COVID19_line_list_data.symptom_onset', 'symptom_onset_tmp', 'COLUMN';
GO
alter table COVID19_line_list_data add symptom_onset date;

GO

update COVID19_line_list_data set symptom_onset=convert(date,symptom_onset_tmp);