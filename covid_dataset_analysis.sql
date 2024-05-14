/*
Covid 19 Dataset Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
-- Retrieves all data from the CovidDeaths table where the continent is specified, ordered by the third and fourth columns.
Select *
From CovidDeaths
Where continent is not null 
order by 3,4;


-- Selects initial data from CovidDeaths for further analysis, ordering by location and date.
Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null 
order by 1,2;


-- Calculates the death percentage from total cases, showing the likelihood of dying from covid in specified locations.
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%Afghanistan%'
and continent is not null 
order by 1,2;


-- Shows the percentage of the population infected with Covid, providing insight into infection spread.
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
order by 1,2;


-- Identifies countries with the highest infection rate relative to their population, sorted by the highest rate.
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc;


-- Retrieves locations with the highest total death count from Covid, indicating severity of impact.
Select Location, MAX(Total_deaths) as TotalDeathCount
From CovidDeaths
#Where location '%Afghanistan%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc;



-- Aggregates data by continent to show which has the highest total death count, helping identify severely affected areas.
Select continent, MAX(Total_deaths) as TotalDeathCount
From CovidDeaths
#Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc;



-- Provides global statistics on new cases and deaths, calculating the death percentage from new cases.
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
#Where location like '%states%'
where continent is not null 
Group By date
order by 1,2;

-- Combines death and vaccination data to calculate the percentage of the population that has received at least one vaccine dose.
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated,
	(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;


-- Uses CTE to manage complex data manipulation, providing a clear structure for calculating vaccination coverage.
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated,
	(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;



-- Prepares a temporary table to hold calculated vaccination coverage, facilitating further analysis or reporting.
DROP Table if exists PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated (
	Continent VARCHAR(255),
	Location VARCHAR(255),
	Date DATETIME,
	Population NUMERIC,
	New_vaccinations NUMERIC,
	RollingPeopleVaccinated NUMERIC
);

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated,
	(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated;




-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated,
	(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null ;

