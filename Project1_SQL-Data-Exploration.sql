/*
Data Analyst Portfolio Project 1: SQL Data Exploration

Hi, my name is Jd. 
This project intends to highlight the basic, intermediate and advanced SQL queries I learned
in the Data Analyst Bootcamp of Alex Freberg aka Alex The Analyst. Skills used are as follows:
Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views and Converting Data Types.

Covid data were downloaded from https://ourworldindata.org/covid-deaths as a .csv file.

However, to showcase queries involving joins, the .csv data set were intentionally
broken into 2 other separate excel files ie. coviddeaths and covidvaccinations.

These data were then imported via the Import Wizard.

Thank you!
*/

-- Database creation and accessing the database itself
create database PortfolioProject
use portfolioproject


-- Basic SQL queries --

-- counting the distint iso codes
select count(distinct(iso_code)) as NumberOfIsoCodes
from coviddeaths
order by iso_code asc


-- using the % wildcard to retrieve data from the Philippines
select *
from coviddeaths
where location like 'philipp%'


-- figuring out population in the Philippines, Norway and India
select distinct(location), population
from coviddeaths
where location in ('philippines', 'norway', 'india')


-- selecting all columns from coviddeaths table and ordering by location and date (in terms of year)
select *
from coviddeaths
where continent is not null
order by location asc, date_format(date,'%y') asc


-- selecting data we're going to start with
select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
where continent is not null
order by location asc, date_format(date,'%y') asc


-- Total Deaths vs Total Cases
-- shows likelihood of dying if you contract covid in the Philippines
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
where location like 'philipp%' and continent is not null
order by location asc, date_format(date,'%y') asc


-- Total Cases vs Population
-- shows what percentage of population are infected with Covid in the Philippines
select location, date, population, total_cases, (total_cases/population)*100 as InfectedPopulationPercentage
from coviddeaths
where location like 'philipp%'
order by location asc, date_format(date,'%y') asc


-- Highest infection rate compared to population (of each location)
select location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as HighestInfectedPopulationPercentage
from coviddeaths
group by location, population
order by HighestInfectedPopulationPercentage desc


-- Top 10 Countries with the highest death count
-- retrieved data checks with the top 10 list of worldometer
-- kindly visit https://www.worldometers.info/coronavirus/countries-where-coronavirus-has-spread/
select location, max(convert(total_deaths,decimal)) as TotalDeathsPerCountry
from coviddeaths
-- the following where statement filters out continents that are tallied in the location column so as not to skew data
where continent is not null and location is not null 
      and location <> 'africa' and location <> 'asia' and location <> 'europe' 
      and location <> 'north america' and location <> 'oceania' and location <> 'south america'
      and location <> 'high income' and location <> 'european union'
group by location
order by totaldeathspercountry desc
limit 10


-- Total death counts across each continent
-- made use of union because for some reason Asia is not listed in the location
-- union is safe to use as it does not permit duplicates 
-- cross-check results at https://www.worldometers.info/coronavirus/
select continent,max(convert(total_deaths,decimal)) as TotalDeathsPerContinent
from coviddeaths
-- the following where statement filters such that only data across continents are considered
where continent in ('asia', 'north america', 'antartica', 'south america', 'africa', 'europe', 'oceania')
union 
select location, max(convert(total_deaths,decimal)) as TotalDeathsPerContinent
from coviddeaths
where location in ('asia', 'north america', 'antartica', 'south america', 'africa', 'europe', 'oceania')
group by location
order by totaldeathspercontinent desc



-- Global Numbers

-- generating global death percentage each day
select date, sum(new_cases) as GlobalTotalCasesThisDay, sum(convert(new_deaths,decimal)) as GlobalTotalDeathsThisDay, 
	   (sum(convert(new_deaths,decimal))/sum(new_cases))*100 as GlobalDeathPercentageThisDay
from coviddeaths
-- the following where statement filters out continents that are tallied in the location column so as not to skew data
where continent is not null and location is not null
      and location <> 'africa' and location <> 'asia' and location <> 'europe' 
      and location <> 'north america' and location <> 'oceania' and location <> 'south america'
      and location <> 'high income' and location <> 'european union'
group by date
order by date_format(date, '%y') asc


-- generating overall global death percentage to date
select sum(new_cases) as OverallGlobalTotalCases, sum(convert(new_deaths,decimal)) as OverallGlobalTotalDeaths, 
	   (sum(convert(new_deaths,decimal))/sum(new_cases))*100 as OverallGlobalDeathPercentage
from coviddeaths
-- the following where statement filters out continents that are tallied in the location column so as not to skew data
where continent is not null and location is not null
      and location <> 'africa' and location <> 'asia' and location <> 'europe' 
      and location <> 'north america' and location <> 'oceania' and location <> 'south america'
      and location <> 'high income' and location <> 'european union'
-- group by date
-- order by date_format(date, '%y') asc


-- inner joining Covid Deaths table and Covid Vaccinations table on both location and date
select *
from coviddeaths as dea inner join covidvaccinations as vac
	on dea.location = vac.location and dea.date = vac.date
-- the following where statement filters out continents that are tallied in the location column so as not to skew data
where dea.continent is not null and dea.location is not null
      and dea.location <> 'africa' and dea.location <> 'asia' and dea.location <> 'europe' 
      and dea.location <> 'north america' and dea.location <> 'oceania' and dea.location <> 'south america'
      and dea.location <> 'high income' and dea.location <> 'european union'



-- New Vaccinations in a given day per country
-- shows the number of newly vaccinated people per country in a given day
select dea.location, dea.date, dea.population, vac.new_vaccinations as NumberOfPeopleVaccinatedThisDay
from coviddeaths as dea inner join covidvaccinations as vac
	on dea.location = vac.location and dea.date = vac.date
-- the following where statement filters out continents that are tallied in the location column so as not to skew data
where dea.continent is not null and dea.location is not null
      and dea.location <> 'africa' and dea.location <> 'asia' and dea.location <> 'europe' 
      and dea.location <> 'north america' and dea.location <> 'oceania' and dea.location <> 'south america'
      and dea.location <> 'high income' and dea.location <> 'european union'


-- performing the previous query (New Vaccinations in a given day per country) via CTE
with CTE_NumberOfPeopleVaccinatedThisDay as
(
select dea.location, dea.date, dea.population, vac.new_vaccinations as NumberOfPeopleVaccinatedThisDay
from coviddeaths as dea inner join covidvaccinations as vac
	on dea.location = vac.location and dea.date = vac.date
-- the following where statement filters out continents that are tallied in the location column so as not to skew data
where dea.continent is not null and dea.location is not null
      and dea.location <> 'africa' and dea.location <> 'asia' and dea.location <> 'europe' 
      and dea.location <> 'north america' and dea.location <> 'oceania' and dea.location <> 'south america'
      and dea.location <> 'high income' and dea.location <> 'european union'
)
select *
from CTE_NumberOfPeopleVaccinatedThisDay


-- performing the previous query (New Vaccinations in a given day per country) via CTE
drop temporary table if exists temp_NumberOfPeopleVaccinatedThisDay;
create temporary table temp_NumberOfPeopleVaccinatedThisDay
(
Location text,
Date text,
Population int,
NumberOfPeopleVaccinatedThisDay text
);
insert into temp_NumberOfPeopleVaccinatedThisDay
select dea.location, dea.date, dea.population, vac.new_vaccinations as NumberOfPeopleVaccinatedThisDay
from coviddeaths as dea inner join covidvaccinations as vac
	on dea.location = vac.location and dea.date = vac.date
-- the following where statement filters out continents that are tallied in the location column so as not to skew data
where dea.continent is not null and dea.location is not null
      and dea.location <> 'africa' and dea.location <> 'asia' and dea.location <> 'europe' 
      and dea.location <> 'north america' and dea.location <> 'oceania' and dea.location <> 'south america'
      and dea.location <> 'high income' and dea.location <> 'european union'
      

-- Creating View to store data for later visualizations
-- New Vaccinations in a given day per country
-- shows the number of newly vaccinated people per country in a given day
create view View_PeopleVaccinated as
select dea.location, dea.date, dea.population, vac.new_vaccinations as NumberOfPeopleVaccinatedThisDay
from coviddeaths as dea inner join covidvaccinations as vac
	on dea.location = vac.location and dea.date = vac.date
-- the following where statement filters out continents that are tallied in the location column so as not to skew data
where dea.continent is not null and dea.location is not null
      and dea.location <> 'africa' and dea.location <> 'asia' and dea.location <> 'europe' 
      and dea.location <> 'north america' and dea.location <> 'oceania' and dea.location <> 'south america'
      and dea.location <> 'high income' and dea.location <> 'european union'
      
      
-- we can now query off of this view_peoplevaccinated view
select *
from view_peoplevaccinated
