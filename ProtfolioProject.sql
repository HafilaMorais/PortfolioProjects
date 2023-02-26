SELECT *
FROM Portfolioproject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM Portfolioproject..CovidVaccinations
--ORDER BY 3,4
  

 --Select data we are going to be using

 SELECT location,date,total_cases, new_cases, total_deaths, population
 FROM Portfolioproject..CovidDeaths
 ORDER BY 1, 2

 --LOOKING AT TOTAL CASES VS TOTAL DEATHS
 --shows the likelihood of dying if you contract covid in your country

 SELECT location,date,total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
 FROM Portfolioproject..CovidDeaths
 Where location like '%states%'
 ORDER BY 1, 2

 --Looking at Total cases vs Population
 --shows what % of the population was affected by COVID

 SELECT location,date,total_cases, population, total_deaths, (total_cases/population)*100 AS PercentPopulationInfected
 FROM Portfolioproject..CovidDeaths
 Where location like '%states%'
 ORDER BY 1, 2

 --Looking at countries with highes infection rate compared to population

 SELECT location,population, MAX(new_cases) as HighestInfectionCount, Max((total_cases/population))*100 AS PercentPopulationInfected
 FROM Portfolioproject..CovidDeaths
-- Where location like '%states%'
Where continent is not null
 Group by location, population
 ORDER BY PercentPopulationInfected desc

 --Showing Countries with Highes Death Count per population

 SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount
 FROM Portfolioproject..CovidDeaths
 Where continent is not null
 Group by location
 ORDER BY TotaldeathCount desc

 --Lets Break things by continent (correct version)

 --Showing Countries with Highes Death Count per population  (correct version)


 SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount
 FROM Portfolioproject..CovidDeaths
 Where continent is null
 Group by location
 ORDER BY TotaldeathCount desc

 --Showing Countries with Highes Death Count per population  (Alex's version)

 SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
 FROM Portfolioproject..CovidDeaths
 Where continent is not null
 Group by continent
 ORDER BY TotaldeathCount desc

  --GLOBAL NUMBERS

 SELECT sum(new_cases) as total_cases, Sum(cast (new_deaths as int)) as total_deaths, Sum(cast (new_deaths as int))/sum(new_cases)*100 as DeathPercentage
 FROM Portfolioproject..CovidDeaths
-- Where location like '%states%'
 Where continent is not null
 --Group by date
 ORDER BY 1, 2


 --Looking at total population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast (vac.new_vaccinations as int)) over (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccinations vac
 ON dea.location = vac.location 
 and dea.date = vac.date
 Where dea.continent is not null
 Order by 2,3

 --Using CTE to get total population vs Vaccination


 With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
 As (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast (vac.new_vaccinations as int)) over (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccinations vac
 ON dea.location = vac.location 
 and dea.date = vac.date
 Where dea.continent is not null
-- Order by 2,3
 )
 Select *,  (RollingPeopleVaccinated/population) *100
 from PopvsVac
 --Where location like '%states%'
 --Group by location

 --Using Temp table to get total population vs Vaccination

Drop Table  if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
 (Continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric, 
 new_vaccinations numeric,
 Rollingpeoplevaccinated numeric
 )

 Insert into #PercentPopulationVaccinated

 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast (vac.new_vaccinations as int)) over (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccinations vac
 ON dea.location = vac.location 
 and dea.date = vac.date
 Where dea.continent is not null

 Select *,  (RollingPeopleVaccinated/population) *100
 from #PercentPopulationVaccinated
 Where location like '%states%'

 --Creating Views to store data for later visuvalizations

 Create View PercentPopulationVaccinated as 
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast (vac.new_vaccinations as int)) over (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccinations vac
 ON dea.location = vac.location 
 and dea.date = vac.date
 Where dea.continent is not null