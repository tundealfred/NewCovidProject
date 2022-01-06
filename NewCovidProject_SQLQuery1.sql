SELECT *
FROM NewCovidProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4


--SELECT *
--FROM NewCovidProject..CovidVaccinations
--ORDER BY 3,4

-- SELECT DATA THAT WE ARE GOING TO BE USING

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM NewCovidProject..CovidDeaths
ORDER BY 1,2


-- LOOKING AT TOTAL CASES vs TOTAL DEATHS

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS Percent_of_Death
FROM NewCovidProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS Percent_of_Death
FROM NewCovidProject..CovidDeaths
WHERE location = 'United Kingdom'
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS Percent_of_Death
FROM NewCovidProject..CovidDeaths
WHERE location = 'Nigeria'
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS Percent_of_Death
FROM NewCovidProject..CovidDeaths
-- WHERE location = 'Nigeria'
ORDER BY 1,2


-- LOOKING AT TOTAL CASES vs POPULATION :  Percent of Population that got Covid

SELECT location, date, population, total_cases, (total_cases / population)*100 AS Percent_of_PopulationInfected
FROM NewCovidProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2

SELECT location, date, population, total_cases, (total_cases / population)*100 AS Percent_of_PopulationInfected
FROM NewCovidProject..CovidDeaths
WHERE location = 'United Kingdom'
ORDER BY 1,2

SELECT location, date, population, total_cases, (total_cases / population)*100 AS Percent_of_PopulationInfected
FROM NewCovidProject..CovidDeaths
WHERE location = 'Nigeria'
ORDER BY 1,2

SELECT location, date, population, total_cases, (total_cases / population)*100 AS Percent_of_PopulationInfected
FROM NewCovidProject..CovidDeaths
-- WHERE location = 'Nigeria'
ORDER BY 1,2


-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, population, MAX(total_cases) AS Higest_InfectionCount,  Max((total_cases / population))*100 AS Percent_of_PopulationInfected
FROM NewCovidProject..CovidDeaths
-- WHERE location = 'United States'
GROUP BY location, population
ORDER BY 1,2

SELECT location, population, MAX(total_cases) AS Higest_InfectionCount,  Max((total_cases / population))*100 AS Percent_of_PopulationInfected
FROM NewCovidProject..CovidDeaths
-- WHERE location = 'United States'
GROUP BY location, population
ORDER BY Percent_of_PopulationInfected desc


-- COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM NewCovidProject..CovidDeaths
-- WHERE location = 'United States'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


-- LET BREAK DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM NewCovidProject..CovidDeaths
-- WHERE location = 'United States'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM NewCovidProject..CovidDeaths
-- WHERE location = 'United States'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc


-- SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM NewCovidProject..CovidDeaths
-- WHERE location = 'United States'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT SUM(new_cases) as Total_cases, SUM(CAST(new_deaths as int)) as Total_deaths, 
SUM(cast(new_deaths as int)) / SUM(new_cases)*100 AS Percent_of_Death
FROM NewCovidProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

SELECT date, SUM(new_cases) as Total_cases, SUM(CAST(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 AS Percent_of_Death
FROM NewCovidProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- LOOKING AT TOTAL POPULATION vs VACCINATIONS

SELECT *
FROM NewCovidProject..CovidDeaths dea
JOIN NewCovidProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM NewCovidProject..CovidDeaths dea
JOIN NewCovidProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

With PopvsVac (continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM NewCovidProject..CovidDeaths dea
JOIN NewCovidProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated02
Create Table #PercentPopulationVaccinated02
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
);
Insert into #PercentPopulationVaccinated02
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM NewCovidProject..CovidDeaths dea
JOIN NewCovidProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated02


-- CREATING VIEW TO STORE DATA FOR VISUALIZATION

Create View PercentPopulationVaccinated02 as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM NewCovidProject..CovidDeaths dea
JOIN NewCovidProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

Select *
From PercentPopulationVaccinated02
