USE portfolio_project; 
GO

SELECT *
 FROM portfolio_project.dbo.Covid_deaths
 WHERE continent IS NOT NULL
 ORDER BY 3,4
 ; 

 --SELECT *
 --FROM portfolio_project.dbo.Covid_vaccination
 --ORDER BY 3,4
 ; 

 SELECT 
	Location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
 FROM portfolio_project.dbo.Covid_deaths
 ORDER BY 1,2

 -- Looking at Total Cases vs Total Deaths 
 -- Shows likelyhood of dying if you contract Covid in Spain

  SELECT 
	Location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 AS death_percentage
 FROM portfolio_project.dbo.Covid_deaths
 WHERE location = 'Spain'
 ORDER BY 1,2

 -- Looking at Total Cases vs Population
 -- Shows what percentage of population got COvid

 SELECT 
	Location, 
	date, 
	population,
	total_cases, 
	(total_cases/population)*100 AS percent_population_infected
 FROM portfolio_project.dbo.Covid_deaths
 WHERE location = 'Spain'
 ORDER BY 1,2


 -- Looking at countries with highest infection rate compared to population
 
 SELECT 
	location, 
	population, 
	MAX(total_cases) AS highest_infection_count,
	MAX((total_cases/population))*100 AS percent_population_infected
 FROM portfolio_project.dbo.Covid_deaths
 GROUP BY 
	location, 
	population 
 ORDER BY 
	percent_population_infected DESC

--Showing countries with highest death count per population 

 SELECT 
	location, 
	MAX(cast(Total_deaths as int)) AS total_death_count
 FROM portfolio_project.dbo.Covid_deaths
 WHERE continent IS NOT NULL
 GROUP BY 
	location 
 ORDER BY 
	total_death_count DESC


--Let's break things down by continent 

SELECT 
	location, 
	MAX(cast(Total_deaths as int)) AS total_death_count
 FROM portfolio_project.dbo.Covid_deaths
 WHERE continent IS NULL
	AND location <> 'Upper middle income'
	AND location <> 'High income'
	AND location <> 'Lower middle income'
	AND location <> 'Low income'
 GROUP BY 
	location
 ORDER BY 
	total_death_count DESC



-- Showing continents with the highest death count per population

 SELECT 
	continent, 
	MAX(cast(Total_deaths as int)) AS total_death_count
 FROM portfolio_project.dbo.Covid_deaths
 WHERE continent IS NOT NULL
 GROUP BY 
	continent 
 ORDER BY 
	total_death_count DESC

-- Global numbers 

 SELECT 
	date, 
	SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths AS int)) as total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
 FROM portfolio_project.dbo.Covid_deaths
-- WHERE location = 'Spain'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

 SELECT 
	SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths AS int)) as total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
 FROM portfolio_project.dbo.Covid_deaths
-- WHERE location = 'Spain'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- Looking at total population vs vaccinations 

SELECT 
	dea.continent,
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(bigint,vac.new_vaccinations)) 
		OVER (
		Partition by dea.location
		ORDER BY dea.location, dea.date 
		) AS rolling_people_vaccinated
FROM portfolio_project..Covid_deaths as dea
	JOIN portfolio_project..Covid_vaccination as vac
	ON dea.location = vac.location 
	AND dea.date = vac.date 
WHERE dea.continent is not null 
ORDER BY 2,3



WITH PopvsVac (continent,location,date, population, new_vaccinations, rolling_people_vaccinated)
AS 
(SELECT 
	dea.continent,
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(bigint,vac.new_vaccinations)) 
		OVER (
		Partition by dea.location
		ORDER BY dea.location, dea.date 
		) AS rolling_people_vaccinated
FROM portfolio_project..Covid_deaths as dea
	JOIN portfolio_project..Covid_vaccination as vac
	ON dea.location = vac.location 
	AND dea.date = vac.date 
WHERE dea.continent is not null 
--ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated/ population)*100
FROM PopvsVac

-- TEMP TABLE 

DROP TABLE if exists #percent_population_vaccinated
Create Table #percent_population_vaccinated
(
continent nvarchar(255), 
location nvarchar (255), 
date datetime, 
population numeric,
new_vaccinations numeric, 
rolling_people_vaccinated numeric)

Insert Into #percent_population_vaccinated
	SELECT 
	dea.continent,
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(bigint,vac.new_vaccinations)) 
		OVER (
		Partition by dea.location
		ORDER BY dea.location, dea.date 
		) AS rolling_people_vaccinated
FROM portfolio_project..Covid_deaths as dea
	JOIN portfolio_project..Covid_vaccination as vac
	ON dea.location = vac.location 
	AND dea.date = vac.date 
WHERE dea.continent is not null 
--ORDER BY 2,3

SELECT *, (rolling_people_vaccinated/ population) *100
FROM #percent_population_vaccinated



-- Creating View to store data for later visualizations 

Create View percent_population_vaccinated AS
SELECT 
	dea.continent,
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(bigint,vac.new_vaccinations)) 
		OVER (
		Partition by dea.location
		ORDER BY dea.location, dea.date 
		) AS rolling_people_vaccinated
FROM portfolio_project..Covid_deaths as dea
	JOIN portfolio_project..Covid_vaccination as vac
	ON dea.location = vac.location 
	AND dea.date = vac.date 
WHERE dea.continent is not null 
--ORDER BY 2,3

CREATE VIEW Total_death_count_per_location AS
 SELECT 
	location, 
	MAX(cast(Total_deaths as int)) AS total_death_count
 FROM portfolio_project.dbo.Covid_deaths
 WHERE continent IS NOT NULL
 GROUP BY 
	location 
 --ORDER BY 
	--total_death_count DESC

CREATE VIEW Total_death_count_per_continent AS
 SELECT 
	continent, 
	MAX(cast(Total_deaths as int)) AS total_death_count
 FROM portfolio_project.dbo.Covid_deaths
 WHERE continent IS NOT NULL
 GROUP BY 
	continent 


