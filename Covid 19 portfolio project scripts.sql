--SELECT * FROM Portfolio_Project..CovidVaccinations;

-- Select data that we are going to be using
-- 

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM Portfolio_Project..CovidDeaths
order by 1,2

-- Total cases vs total deaths
-- shows the likelihood of dying by covid in United States
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM Portfolio_Project..CovidDeaths
WHERE location like '%states'
order by 1,2

-- Looking at the total cases vs population
-- shows % of population who contracted covid

SELECT Location, date, total_cases, population, (total_cases/population) * 100 AS PercentageOfPopulationInfected
FROM Portfolio_Project..CovidDeaths
WHERE location like '%states'
order by 1,2

-- Countries with highest infection %

SELECT Location, population, Max(total_cases) AS HighestCount, MAX(total_cases/population) * 100 AS Highest_Percentage
FROM Portfolio_Project..CovidDeaths
GROUP BY population, location
order by Highest_Percentage desc

-- Shows countries with highest death count 

SELECT Location, Max(cast(total_deaths as int)) AS HighestCount
FROM Portfolio_Project..CovidDeaths
where continent is not null
GROUP BY location
order by HighestCount desc

--Shows continents with highest death count 
 
SELECT continent, Max(cast(total_deaths as int)) AS HighestCount
FROM Portfolio_Project..CovidDeaths
WHere continent is not null 
GROUP BY continent
order by HighestCount desc


-- GLOBAL NUMBERS

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths
,SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM Portfolio_Project..CovidDeaths
where continent is not null
--group by date
order by 1,2


-- TEMP TABLE

with popvsvac  (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated) 
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

-- Accesing data from temp table

SELECT *, (RollingPeopleVaccinated/Population) * 100 
FROM popvsvac

-- TEMP TABLE 2

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent Varchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population) * 100 
FROM #PercentPopulationVaccinated


-- Creating view to store data for visualizations
DROP VIEW PercentPopulationVaccinated;

Create View PercentPopulationVaccinated as

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT * FROM PercentPopulationVaccinated