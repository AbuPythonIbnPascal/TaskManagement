Select *
From  CovidDeaths
Where continent is not null 
order by 3,4


-- Show main data

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths for New Zealand

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%Zealand%'
and continent is not null 
order by 1,2


-- Total Cases vs Population


Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
Where continent is not null 
Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select CovD.continent, CovD.location, CovD.date, CovD.population, Vac.new_vaccinations,
SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by CovD.Location Order by CovD.location, CovD.Date) as RollingPeopleVaccinated
From CovidDeaths CovD
Join CovidVaccinations Vac
	On CovD.location = Vac.location
	and CovD.date = Vac.date
where CovD.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PplVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select CovD.continent, CovD.location, CovD.date, CovD.population, Vac.new_vaccinations
, SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by CovD.Location Order by CovD.location, CovD.Date) as RollingPeopleVaccinated
From CovidDeaths CovD
Join CovidVaccinations Vac
	On CovD.location = Vac.location
	and CovD.date = Vac.date
where CovD.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PplVac 



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select CovD.continent, CovD.location, CovD.date, CovD.population, Vac.new_vaccinations
, SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by CovD.Location Order by CovD.location, CovD.Date) as RollingPeopleVaccinated
From CovidDeaths CovD
Join CovidVaccinations Vac
	On CovD.location = Vac.location
	and CovD.date = Vac.date
where CovD.continent is not null 

--Display Temp. table

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
