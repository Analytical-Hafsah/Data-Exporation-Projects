/*
Covid-19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM PortfolioProjects.dbo.CovidDeaths
WHERE continent IS NOT NULL  
ORDER BY 3,4


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects.dbo.CovidDeaths
WHERE continent IS NOT NULL  
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Nigeria

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProjects.dbo.CovidDeaths
WHERE location = 'Nigeria'
AND continent IS NOT NULL 
ORDER BY 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT Location, date, Population, total_cases,  (total_cases/population)*100 AS Population_Infected_Percentage
FROM PortfolioProjects.dbo.CovidDeaths
--WHERE location = 'Nigeria'
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS Highest_Infection_Count,  MAX((total_cases/population))*100 AS Population_Infected_Population
FROM PortfolioProjects.dbo.CovidDeaths
--WHERE location = 'Nigeria'
GROUP BY Location, Population
ORDER BY Population_Infected_Population DESC


-- Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(Total_deaths AS INT)) AS Total_Death_Count
FROM PortfolioProjects.dbo.CovidDeaths
--WHERE location = 'Nigeria'
WHERE continent IS NOT NULL 
GROUP BY Location
ORDER BY Total_Death_Count DESC




-- Showing contintents with the highest death count per population

SELECT continent, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProjects.dbo.CovidDeaths
--WHERE location = 'Nigeria'
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount desc



-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(CONVERT(INT, new_deaths)) AS total_deaths, SUM(CONVERT(INT,new_deaths))/SUM(New_Cases)*100 AS Death_Percentage
FROM PortfolioProjects.dbo.CovidDeaths
--WHERE location = 'Nigeria'
WHERE continent IS NOT NULL 
--GROUP BY date
ORDER BY 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.Location ORDER BY D.location, D.Date) AS People_Vaccinated
--(People_Vaccinated/population)*100
FROM PortfolioProjects.dbo.CovidDeaths D
JOIN PortfolioProjects.dbo.CovidVaccinations V
	ON D.location = V.location
	AND D.date = V.date
WHERE D.continent IS NOT NULL 
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopulationvsVaccinations (Continent, Location, Date, Population, New_Vaccinations, People_Vaccinated)
AS
(
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(CONVERT(INT,V.new_vaccinations)) OVER (Partition by D.Location Order by D.location, D.Date) AS People_Vaccinated
--, (People_Vaccinated/population)*100
FROM PortfolioProjects.dbo.CovidDeaths D
JOIN PortfolioProjects.dbo.CovidVaccinations V
	On D.location = V.location
	AND D.date = V.date
WHERE D.continent IS NOT NULL   
)
SELECT *, (People_Vaccinated/Population)*100
FROM PopulationvsVaccinations



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF exists #Population_Vaccinated_Percentage 
CREATE TABLE #Population_Vaccinated_Percentage
(
Continent NVARCHAR(300),
Location NVARCHAR(300),
Date datetime,
Population NUMERIC,
New_vaccinations NUMERIC,
People_Vaccinated NUMERIC
)

INSERT INTO #Population_Vaccinated_Percentage
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(CONVERT(INT,V.new_vaccinations)) OVER (Partition by D.Location Order by D.location, D.Date) AS People_Vaccinated
--, (People_Vaccinated/population)*100
FROM PortfolioProjects.dbo.CovidDeaths D
JOIN PortfolioProjects.dbo.CovidVaccinations V
	ON D.location = V.location
	AND D.date = V.date
--WHERE D.continent IS NOT NULL  
--ORDER BY 2,3

SELECT *, (People_Vaccinated/Population)*100
FROM #Population_Vaccinated_Percentage




-- Creating View to store data for later visualizations

CREATE VIEW Population_Vaccinated_Percentage AS
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(CONVERT(INT,V.new_vaccinations)) OVER (Partition by D.Location Order by D.location, D.Date) AS People_Vaccinated
--, (People_Vaccinated/population)*100
FROM PortfolioProjects.dbo.CovidDeaths D
JOIN PortfolioProjects.dbo.CovidVaccinations V
	ON D.location = V.location
	AND D.date = V.date
WHERE D.continent IS NOT NULL 
