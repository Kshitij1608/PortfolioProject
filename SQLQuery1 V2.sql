Select *
 From PortfolioProject..CovidDeaths
 Where Continent is not null
 order by 3,4

 --Select *
 --From PortfolioProject..CovidVaccinations
 --order by 3,4

 --Select Data that we are going to be using

 Select Location, Date, total_cases, new_cases, total_deaths, population
 From PortfolioProject..CovidDeaths
 Where Continent is not null
 order by 1,2


 -- Looking at the Total cases vs Total deaths
 -- Shows Liklihood of dying if you contract covid in your country
 Select Location, Date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
 From PortfolioProject..CovidDeaths
 Where location like '%canada%'
 and Continent is not null
 order by 1,2

 -- Looking at Total cases vs Population
 -- Shows what % of population got covid

 Select Location, Date, population, total_cases, (Total_cases/population)*100 as PercentPopulationInfect
 From PortfolioProject..CovidDeaths
 --Where location like '%canada%'
 order by 1,2

-- Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((Total_cases/population))*100 as PercentPopulationInfect
 From PortfolioProject..CovidDeaths
 --Where location like '%canada%'
 Group by location, population
 order by PercentPopulationInfect desc

 -- Showing countries with highest death count per population

 Select Location, Max(cast(Total_deaths as int )) as TotalDeathCount
 From PortfolioProject..CovidDeaths
 --Where location like '%canada%'
 Where Continent is not null
 Group by location
 order by TotalDeathCount desc


 -- LET'S BREAK THINGS DOWN BY CONTINENT

 Select continent, Max(cast(Total_deaths as int )) as TotalDeathCount
 From PortfolioProject..CovidDeaths
 --Where location like '%canada%'
 Where Continent is not null
 Group by continent
 order by TotalDeathCount desc


 -- Showing the continents with highest death counts per population

 Select location, Max(cast(Total_deaths as int )) as TotalDeathCount
 From PortfolioProject..CovidDeaths
 --Where location like '%canada%'
 Where Continent is null
 Group by location
 order by TotalDeathCount desc




-- Global numbers

 Select  SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(new_cases)*100 as DeathPercentage
 From PortfolioProject..CovidDeaths
 -- Where location like '%canada%'
 where Continent is not null
 --Group by date
 order by 1,2


 -- looking at total population vs vaccinations

 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
  from PortfolioProject..CovidDeaths dea
  join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , Sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
  from PortfolioProject..CovidDeaths dea
  join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac



-- TEMP Table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , Sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
  from PortfolioProject..CovidDeaths dea
  join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating virew to store data for later visualizations

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated