Select *
From ProtfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

--Select *
--From ProtfolioProject.dbo.CovidVaccinations
--order by 3,4

--Selecting the data
Select location, date, total_cases, new_cases, total_deaths, population
From ProtfolioProject.dbo.CovidDeaths
order by 1,2

--Total Cases vs Total Deaths 
-- Shows the probability of dying due to covid in USA
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
From ProtfolioProject.dbo.CovidDeaths
Where location like '%states%'
order by 1,2

--looking at total cases vs population in percentage
Select location, date, population, total_cases, (total_cases/population)* 100 as CasePercentage
From ProtfolioProject.dbo.CovidDeaths
--Where location like '%states%'
order by 1,2

--looking at countries with Highest Infection rate to population
Select location as Country, population, MAX(total_cases)as HighestInfectionCount, Max((total_cases/population))* 100 as PercentPopulationInfected
From ProtfolioProject.dbo.CovidDeaths
--Where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

-- Countires with Highest death count in population
Select location as Country, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProtfolioProject.dbo.CovidDeaths
where continent is not null
--Where location like '%states%'
group by location
order by TotalDeathCount desc

--calculation by continent
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProtfolioProject.dbo.CovidDeaths
where continent is null
--Where location like '%states%'
group by location
order by TotalDeathCount desc

--global numbers of new cases ,deaths and death percentage by date
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From ProtfolioProject.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
group by date
order by 1,2

--global total
Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From ProtfolioProject.dbo.CovidDeaths
Where continent is not null
order by 1,2


--total amount of people vs vaccination 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinated
From ProtfolioProject.dbo.CovidDeaths dea
join ProtfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date=vac.date
	Where dea.continent is not null
	order by 2,3

--CTE

With PopvsVac (continent, location, date, population, new_vaccinations, PeopleVaccinated )
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinated
From ProtfolioProject.dbo.CovidDeaths dea
join ProtfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date=vac.date
	Where dea.continent is not null
	--order by 2,3
)
Select*, (PeopleVaccinated/population) *100
From PopvsVac

--Temp table
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric,
)

Insert  #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinated
From ProtfolioProject.dbo.CovidDeaths dea
join ProtfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date=vac.date
	Where dea.continent is not null
	--order by 2,3
Select*, (PeopleVaccinated/population) *100
		From #PercentPopulationVaccinated

--creating views for data Visulazation

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinated
From ProtfolioProject.dbo.CovidDeaths dea
join ProtfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date=vac.date
	Where dea.continent is not null
	--order by 2,3
