/* 
BUSINESS ANALYSIS and REPORTING
Student Name: TRANG BUI
Student ID: W0753523
*/

/*
1. Write a query to display the top 10 hotspots for coronavirus (COVID – 19) cases in the USA by County showing confirmed cases, 
population and the median age. Create the appropriate chart and format properly with Chart Title and Axis Title. 
Also comment on the chart in MS Word file
*/
/*EXPLANATION
For visualization purpose, I decided to calculate portion of confirmed cases out of state population, and the remain portion which has no confirmation of virus
*/
select top 10 t.Admin2 CountyName, ConfirmedCases, zct.CountyPop CountyPopulation, avg(zcs.MedianAge) CountyAvgMedianAge,
	(cast(ConfirmedCases as float)*100/zct.CountyPop) as Pct_ConfirmedCasesOutofPopulation,
	(100-(cast(ConfirmedCases as float)*100/zct.CountyPop)) as pct_NoConfirm_Population
from [dbo].[ZipCounty] zct
inner join [dbo].[ZipCensus] zcs on zct.ZipCode=zcs.zcta5
inner join [dbo].[time_series_covid_19_confirmed_US] t on zct.CountyFIPS=t.FIPS
group by t.Admin2, ConfirmedCases, zct.CountyPop
order by ConfirmedCases desc;

/*
2. Write a query to display male and female deaths by Country who have never visited Wuhan and have been asymptomatic (showing no symptoms). 
Order Deaths in descending order. Create a stacked bar chart. Also comment on the chart in MS Word file.
*/
select Country, 
	count(CASE WHEN Gender = 'Male'   THEN 1 END) as Male,
	count(CASE WHEN Gender = 'FeMale' THEN 1 END) as Female, 
	count(CASE WHEN Gender NOT IN ('Male','FeMale') THEN 1 END) as Unknow_Gender, 
	count(*) as Total_Deaths
from dbo.COVID19_line_list_data cv
where death=1 and visiting_Wuhan=0 and symptom is null
group by country
order by Total_Deaths desc;


/*
 3. Write a query showing an age distribution chart among cases of COVI9-19 patients. Group by categories below. 
 What % group of the population has highest admission. Order from highest to lowest. 
 o Baby Boomers (Roughly 50+ years old) 
 o Generation X (Roughly 35 – 50 years old) 
 o Millennials, or Generation Y (18 – 34 years old) 
 o Generation Z, or generation (17 & younger)  
 Draw appropriate graph/chart in excel. Also comment on the chart in MS Word file. 
 */

select Age_Group, Number_of_Patients, cast(Number_of_Patients as float)/(sum(Number_of_Patients) over()) * 100 as pct_Patients
 from (
select case when age>50 then 'Baby Boomers'
		when age between 35 and 50 then 'Generation X'
		when age between 18 and 34 then 'Generation Y'
		when age <=17 then 'Generation Z'
		end as Age_Group,
		count(*) Number_of_Patients
from dbo.COVID19_line_list_data
group by case when age>50 then 'Baby Boomers'
		when age between 35 and 50 then 'Generation X'
		when age between 18 and 34 then 'Generation Y'
		when age <=17 then 'Generation Z'
		end
		) pt
order by Number_of_Patients desc;

/*
4. Does Family Income impact COVID 19 cases? We want to see if any correlation is present does higher income county show less cases, 
more cases or equally distributed cases? 
What about foreign-born residents do they have higher, lower or equally distributed cases of COVID 19 compared to Born in US residents? 
Foreign Born VS Born in USA. Depict a chart showing both these scenarios and provide a trendline. 
You can choose to create one query or two separate queries and combine the results in Excel. 
Comment on the distribution here
*/
--4a. We want to see if any correlation is present does higher income county show less cases, more cases or equally distributed cases? 
select zc.County, t.ConfirmedCases, avg(zc.MedianEarnings) CountyAvgMedianEarnings
from dbo.time_series_covid_19_confirmed_US t
inner join dbo.ZipCensus zc on t.FIPS=zc.Fipco
group by zc.County, t.ConfirmedCases
order by CountyAvgMedianEarnings desc;
--4b. What about foreign-born residents do they have higher, lower or equally distributed cases of COVID 19 compared to Born in US residents? 
/* EXPLANATION
I cannot find out information of place of Birth of Patients which are confirmed  cases. 
Therefore, I assume that "COVID19_line_list_data.country" is the place of born. 
This means that a patient was born in USA, the country field value is "USA", other values are foreign born.
COVID19_line_list_data.location contents information of both country name and state names, it is not mapped to county. However, I used it as group by condition
*/
select 	count(case when country = 'USA' then 1 end) as Nb_Cases_USABorn
		,count(case when country <> 'USA' then 1 end) as Nb_Cases_ForeignBorn
from COVID19_line_list_data

/*
5. Currently in the news they are saying African Americans are dying at a higher rate. 
Use the data provided to support or refute this claim showing demographics among all ethnicities in US. 
Create the appropriate chart(s) and format properly with Chart Title and Axis Title. 
Also comment on the chart in MS Word file
*/
/*EXPLANATION
I couldn't find information of African Americans' deaths. So, I decided to summary number of deaths due to Covid-19 over the world in table COVID19_line_list_data where there is no data to decline to news
*/
select country, count(*) as number_of_death_by_country
from dbo.COVID19_line_list_data 
where death>0 
group by country
order by number_of_death_by_country desc;

select max(reporting_Date) as max_reporting_Dte,min(reporting_Date) as min_reporting_Dte 
from COVID19_line_list_data --2020-02-28
where year(reporting_Date) !=  1900

/*
6. How many confirmed cases were reported worldwide each week? 
Create the appropriate chart(s) and format properly with Chart Title and Axis Title. 
Also comment on the chart in MS Word file. 
*/
select datepart(year,reporting_date) year, datepart(wk,reporting_date) weekinyear, count(*) nbReportedCases
from dbo.COVID19_line_list_data
where datepart(year,reporting_date) != 1900
group by datepart(year,reporting_date), datepart(wk,reporting_date)
order by year, weekinyear;
-- date range of data
select min(reporting_date), max(reporting_date) from COVID19_line_list_data where datepart(year,reporting_date) != 1900;

/*
7. How many confirmed cases were reported country wide each day? 
Create the appropriate chart(s) for top 10 countries and format properly with Chart Title and Axis Title. 
Also comment on the chart in MS Word file. 
*/
--7a. How many confirmed cases were reported country wide each day? 
select country, reporting_date, count(1) nbReportedCases 
from dbo.COVID19_line_list_data
where datepart(year,reporting_date) != 1900
group by country, reporting_date
order by country, reporting_date;
--7b. Create the appropriate chart(s) for top 10 countries and format properly with Chart Title and Axis Title
with top10countries as
(
	select top 10 country, count(1) nbReportedCases 
	from dbo.COVID19_line_list_data
	where datepart(year,reporting_date) != 1900
	group by country
	order by nbReportedCases desc
)
select country, reporting_date, count(1) nbReportedCases 
from dbo.COVID19_line_list_data cv
where datepart(year,reporting_date) != 1900
		and exists (select 1 from top10countries t10 where t10.country = cv.country)
group by country, reporting_date
order by country, reporting_date;


/*
8. Find Top Ten Closest Zip Codes to the US Geographic Center (Latitude:39.80 and Longitude: -98.60 ) with COVID-19 confirmed cases. 
No Excel chart required here SQL only.
*/
-- use SRID=4326 to convert distance to metre
SELECT *
FROM sys.spatial_reference_systems
WHERE spatial_reference_id = 4326;

-- Find Top Ten Closest Zip Codes to the US Geographic Center (Latitude:39.80 and Longitude: -98.60 ) with COVID-19 confirmed cases
Select top 10 ZipCode, POName, CountyName, State,
	(select sum(ConfirmedCases) CountyConfirmedCases 
		from dbo.time_series_covid_19_confirmed_US t 
		where zc.CountyFIPS=t.FIPS) CountyConfirmedCase
from dbo.ZipCounty zc ---time_series_covid_19_confirmed_US
order by GEOGRAPHY::Point(39.80, -98.60, 4326).STDistance(GEOGRAPHY::Point(Latitude, Longitude, 4326));

/*
9. Find the difference (No. of days) between symptom_onset and reporting date. 
Then write another query to find No. of COVID-19 cases for each difference (No. of Days). 
No Excel chart required. SQL only.
*/
-- Find the difference (No. of days) between symptom_onset and reporting date. 
select datediff(day,symptom_onset,reporting_date) dayDiffSymptomReporting, count(*) ReportedCases
from dbo.COVID19_line_list_data
where datepart(year,reporting_date) != 1900
and datepart(year,symptom_onset) != 1900
group by datediff(day,symptom_onset,reporting_date)

/*
10. How many unique symptoms of COVID-19 are there in the data set (symptoms can be only ONE or combination of more than one as a single TEXT/STRING as given in the symptoms column). 
List down No. of cases by gender for each symptom type. Compare this result using suitable chart/graph in Excel. 
*/
--10a. How many unique symptoms of COVID-19 are there in the data set 
select  count(distinct trim(value)) as NumberOfUniqueSymptom
from dbo.covid19_line_list_data
	cross apply string_split(symptom, ',') s

--10b. List down No. of cases by gender for each symptom type. Compare this result using suitable chart/graph in Excel. 
select   trim(value) as symptom, 
	count(CASE WHEN Gender = 'Male'   THEN 1 END) as Male,
	count(CASE WHEN Gender = 'FeMale' THEN 1 END) as Female, 
	count(CASE WHEN Gender NOT IN ('Male','FeMale') THEN 1 END) as Unknow_Gender,
	count(*) TotalCasesBySymptom
from dbo.covid19_line_list_data
	cross apply string_split(symptom, ',') s
group by trim(value)
order by TotalCasesBySymptom desc;


