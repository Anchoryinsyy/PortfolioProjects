
Select *
From syy..CovidDeaths
order by 3,4

--Select *
--From syy..CovidVaccination
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population 
From syy..CovidDeaths
order by 1,2


-- looking at Total Cases vs Total Deaths
-- Shows likelihood og dying if you contract covid in your country

Select Location, date, total_cases, total_deaths,convert(decimal(15,3),(convert(decimal(15,3),total_deaths)/convert(decimal(15,3),total_cases)))*100 as DeathPercentage
From syy..CovidDeaths
Where location like '%states%'
order by 1,2


-- looking at Total Cases vs population
-- Shows what percentage of population got Covid

Select Location, date, total_cases, population,convert(decimal(15,3),(convert(decimal(15,3),total_cases)/population))*100 as PercentageofPopulationinfected
From syy..CovidDeaths
Where location like '%states%'
order by 1,2



--Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(convert(decimal(15,6),(convert(decimal(15,6),total_cases)/population)))*100 as PercentageofPopulationinfected
From syy..CovidDeaths
--Where location like '%states%'
Group by Location,population
order by PercentageofPopulationinfected desc

---Showing Countries with Highest Death Count per Populaltion

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From syy..CovidDeaths
Where continent is not null --Get rid of cases where location is representing a continent
Group by Location
order by TotalDeathCount desc



-- break things by continent 
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From syy..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--From syy..CovidDeaths
--Where continent is null 
--Group by location
--order by TotalDeathCount desc

---Showing continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)/population) as TotalDeathCount
From syy..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

---Global Numbers
---numbers across the world
Select date, SUM(cast(new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as DeathPercentage
From syy..CovidDeaths
where continent is not null
Group By date
order by 1,2

Select SUM(cast(new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as DeathPercentage
From syy..CovidDeaths
where continent is not null
order by 1,2


---turn to vaccination table

---Looking at Total Population vs Vaccination
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
From syy..CovidDeaths dea
Join syy..CovidVaccination vac
	On dea.Location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.Date) as RollingPeopleVaccinated
From syy..CovidDeaths dea
Join syy..CovidVaccination vac
	On dea.Location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--mutate a new column
---two options: CTE or Temp Table

--1) CTE

With PopvsVac (Continent,Location,Date,Population,New_Vaccinations, RollingPeoplVaccinated)
as 
(
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.Date) as RollingPeopleVaccinated
From syy..CovidDeaths dea
Join syy..CovidVaccination vac
	On dea.Location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
)
