SELECT * 
From PortfolioProject..CovidDeaths
Where continent is not null 
Order by 3,4

--SELECT * 
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select Data that we are going to be using

Select Location, date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
Where continent is not null 
Order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the chances of dying when contracting Covid in your country

Select Location, date,total_cases,total_deaths,(Total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Cape%' and continent is not null
Order by 1,2

-- Looking at Total Cases vs Total Population
-- Shows what percentage of population got covid

Select Location, date,total_cases,Population,(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 

Order by 1,2


--Looking at countries with highest infection rate compared to population

Select Location,Population,MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location,Population
Order by PercentPopulationInfected DESC

-- Showing Countries with the Highest Death Count per Population

Select Location,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
Order by TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

Select location,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
Group by location
Order by TotalDeathCount desc

-- GLOBAL NUMBERS 

Select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases) * 100 as DeathPrcentage
--total_deaths,(Total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%' 
where continent is not null
--Group by date 
Order by 1,2

--Looking at Total Population vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingVaccinatedPeople
--,(RollingVaccinatedPeople
FROM PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE

With PopVsVac (Continent,Location,Date,Population,New_Vaccinations,RollingVaccinatedPeople)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingVaccinatedPeople
--,(RollingVaccinatedPeople*100
FROM PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select * , (RollingVaccinatedPeople/Population)*100
From PopVsVac

--Temp Table
DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinatedPeople numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingVaccinatedPeople
--,(RollingVaccinatedPeople*100
FROM PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select * , (RollingVaccinatedPeople/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingVaccinatedPeople
--,(RollingVaccinatedPeople*100
FROM PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated