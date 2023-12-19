
use PortifolioProject;

-- Research Questions
SELECT * 
FROM PortifolioProject..covidDeaths
WHERE continent is NOT NULL
ORDER BY 3;

-- COVID CASES
-- What's the total number of Covid caes Vs Covid deaths?
-- Shows the total number of comfirmed reported covid cases, and covid deaths in the US.

select location, date,population,total_cases, total_deaths, ( total_deaths/ cast(total_cases as float))*100 as deathsPerCases
from PortifolioProject..covidDeaths
where location != 'United States Virgin Islands'
AND location like ('%states%')
and total_cases is not null
order by 1,2;

-- Comfirmed reported Covid cases in the US?
-- Shows total comfirmed, and reported Covid cases in the US.

SELECT location, date, total_cases
FROM PortifolioProject..covidDeaths
WHERE total_cases is NOT NULL
AND location LIKE '%states%'
ORDER BY 1,2;

-- Covid cases per continent?
-- shows continents were covid cases were comfirmed and reported, ordered by the location with the most cases

SELECT continent, MAX(CAST(total_cases AS INT)) AS casesByLocation
FROM PortifolioProject..covidDeaths
WHERE continent is NOT NULL
AND total_cases is NOT NULL
GROUP BY continent
ORDER BY casesByLocation DESC;

-- Highest Covid cases per location?
-- shows locations were covid cases were comfirmed and reported, ordered by the locations with the most cases

SELECT location, MAX(CAST(total_cases AS INT)) AS casesByLocation
FROM PortifolioProject..covidDeaths
WHERE continent is NOT NULL
AND total_cases is NOT NULL
GROUP BY location
ORDER BY casesByLocation DESC;

-- Total number of new covid cases, new covid deaths, and Deathratein the entire world
SELECT SUM(new_cases) as totalCases, 
		SUM(CONVERT(INT, new_deaths)) AS totalDeaths, 
		(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 as deathRate
FROM PortifolioProject..covidDeaths
WHERE continent IS NOT NULL;

-- GLOBAL INFECTION RATE.
-- locations with most infected patients based on total reported cases and infected population

-- HIghest infections by location
SELECT location, MAX(CAST(total_cases AS INT)) AS Infected
FROM PortifolioProject..covidDeaths
WHERE continent is NOT NULL
AND total_cases is NOT NULL
GROUP BY location
ORDER BY Infected DESC;

-- Highest infections by continent
SELECT continent, MAX(CAST(total_cases AS INT)) AS mostInfected
	--MAX(total_cases/population) as infectedPopulation
FROM PortifolioProject..covidDeaths
WHERE continent is NOT NULL
AND total_cases is NOT NULL
GROUP BY continent
ORDER BY mostInfected DESC;



-- COVID DEATHS
-- Total Covid deaths in United States?

SELECT location, population, MAX(CONVERT(INT,total_deaths)/(population))*100 AS deathRate
FROM PortifolioProject..covidDeaths
WHERE total_deaths is NOT NULL
AND continent is NOT NULL
AND total_deaths IS NOT NULL
AND location = 'United States'
GROUP BY location, population
ORDER BY deathRate;

-- Highest covid deaths by location
SELECT location, MAX(CAST(total_deaths AS INT)) AS dead, 
(MAX(CAST(total_deaths AS INT))/population) * 100 AS deathRate
FROM PortifolioProject..covidDeaths
WHERE continent is NOT NULL
AND total_deaths is NOT NULL
GROUP BY location, population
ORDER BY deathRate DESC;

-- Highest covid deaths by continent
SELECT continent, MAX(CAST(total_deaths AS INT)) AS mostdeaths
	--MAX(total_cases/population) as infectedPopulation
FROM PortifolioProject..covidDeaths
WHERE continent is NOT NULL
AND total_deaths is NOT NULL
GROUP BY continent
ORDER BY mostdeaths DESC;

-- COVID VACCINES
-- shows both the CovidDeaths and CovidVaccines tables combined, displaying the total number of vaccinated individuals by location per continent

SELECT d.date, d.continent, d.location, d.population, v.total_vaccinations, v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS BIGINT))
OVER (partition by d.location ORDER BY d.location,d.date) AS administered_byLocation
FROM PortifolioProject..covidDeaths as d
JOIN PortifolioProject..covidVaccines as v
	ON d.date = v.date 
	AND d.location = v.location
WHERE d.continent IS NOT NULL
AND total_vaccinations IS NOT NULL

-- CREATING A TEMP TABLE
-- Shows a temp table

DROP TABLE IF EXISTS #vaccinatedPopulation 
CREATE TABLE #vaccinatedPopulation(
	date datetime,
	continent nvarchar (255),
	location nvarchar (255), 
	population numeric ,
	total_vaccinations nvarchar (255), 
	new_vaccinations numeric, 
	administered_byLocation numeric, 
	people_vaccinated numeric
)
INSERT INTO #vaccinatedPopulation
SELECT d.date, d.continent, d.location, d.population, v.total_vaccinations, v.new_vaccinations, people_vaccinated,
SUM(CAST(v.new_vaccinations AS numeric))
OVER (partition by d.location ORDER BY d.location,d.date) AS administered_byLocation
FROM PortifolioProject..covidDeaths as d
JOIN PortifolioProject..covidVaccines as v
	ON d.date = v.date 
	AND d.location = v.location
WHERE d.continent IS NOT NULL
AND total_vaccinations IS NOT NULL

select * , (administered_byLocation/population)*100 as administeredRate
from #vaccinatedPopulation
order by administeredRate;

-- OR

-- CREATING A CTE
-- vaccinations against population
-- Shows how many people were vaccinated by location

With vacPop(
date,continent,location, population, total_vaccinations, 
new_vaccinations, administered_byLocation, people_vaccinated
)
as (
SELECT d.date, d.continent, d.location, d.population, v.total_vaccinations, v.new_vaccinations, people_vaccinated,
SUM(CAST(v.new_vaccinations AS BIGINT))
OVER (partition by d.location ORDER BY d.location,d.date) AS administered_byLocation
FROM PortifolioProject..covidDeaths as d
JOIN PortifolioProject..covidVaccines as v
	ON d.date = v.date 
	AND d.location = v.location
WHERE d.continent IS NOT NULL
AND total_vaccinations IS NOT NULL

)

select * , (administered_byLocation/population)*100 as administeredRate
from vacPop

--CREATING A VIEW

CREATE VIEW VaccineAdministeredRate AS
SELECT d.date, d.continent, d.location, d.population, v.total_vaccinations, v.new_vaccinations, people_vaccinated,
SUM(CAST(v.new_vaccinations AS BIGINT))
OVER (partition by d.location ORDER BY d.location,d.date) AS administered_byLocation
FROM PortifolioProject..covidDeaths as d
JOIN PortifolioProject..covidVaccines as v
	ON d.date = v.date 
	AND d.location = v.location
WHERE d.continent IS NOT NULL
AND total_vaccinations IS NOT NULL

-- test view
select * from [dbo].[VaccineAdministeredRate]







