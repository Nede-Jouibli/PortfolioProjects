/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

select * 
from PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Explore some data
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

--Total Cases VS Total Deaths
-- Shows likelihood of dying if you got covid in Tunisia
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
Where location= 'Tunisia'
Order by 1,2

-- Total cases VS Population

-- Shows percentage of Tunisians that got covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as InfectedPouplationPercentage 
From PortfolioProject..CovidDeaths
Where location= 'Tunisia'
Order by 1,2

--Looking at countries with highest infection rate

Select Location, Population, MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100 as MaxInfectedPouplationPercentage
From PortfolioProject..CovidDeaths
Group by Location, Population
Order by MaxInfectedPouplationPercentage desc

-- Shows countries with highest deaths per population

Select Location,MAX(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, Population
Order by HighestDeathCount desc

-- By continent

-- Show continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by HighestDeathCount desc

-- Global

-- Shows death percentage per date
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by date
Order by 1,2

-- Death percentage across the world

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null 
Order by 1,2

-- Total Population VS Vaccinations

Select dea.continent, dea.location, dea.population, dea.date, dea.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingNumberOfVaccinatedPeople
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- How many people in a certain country are vaccinated

-- Uce CTE

With PopvsVac(Continent, Location, Date, Population, new_vaccinations, RollingNumberOfVaccinatedPeople)
as 
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingNumberOfVaccinatedPeople
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
)
Select * , (RollingNumberOfVaccinatedPeople/population)*100
from PopvsVac

-- TEMP Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingNumberOfVaccinatedPeople numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingNumberOfVaccinatedPeople
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null

Select * , (RollingNumberOfVaccinatedPeople/population)*100
from #PercentPopulationVaccinated


-- Create views to store for data visualization

--  Percent of Vaccinated Population View
create view PercentPopulationVaccinated as
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingNumberOfVaccinatedPeople
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null

Select * 
From PercentPopulationVaccinated

