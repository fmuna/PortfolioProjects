select * 
from Covid_Deaths

select * 
from Covid_Vaccinations

--Select Data that we are going to be using 
select location, date, total_cases, new_cases, total_deaths, population
from Covid_Deaths
order by 1,2

--Looking at total cases vs total Deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Covid_Deaths
where location like 'India'
order by 1,2


--Looking at Total cases vs Population
select location, date, population, total_cases,  (total_cases/population)*100 as InfectionPercentage
from Covid_Deaths
where location like '%states%'
order by 1,2

--Looking at countries with highest Infecion rate compared to the population
select location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as InfectionPercentage
from PortfolioProject..Covid_Deaths
group by location, population
order by InfectionPercentage desc

--Showing Countries with highest Death count per population
select location, Max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..Covid_Deaths
Where continent is Null
group by location
order by TotalDeathCount desc

--Showing Continent with highest death counts
select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..Covid_Deaths
Where continent is not Null
group by continent
order by TotalDeathCount desc

--Global Numbers
select date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..Covid_Deaths
where continent is not null
group by date
order by 1,2

select SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..Covid_Deaths
where continent is not null
--group by date
order by 1,2

--Looking at Total Population VS Vaccination
--Join the death and vaccine table together
select d.continent, d.location, d.date, d.population, v.new_vaccinations 
from PortfolioProject..Covid_Deaths d
join PortfolioProject..Covid_Vaccinations v
on d.location = v.location
and d.date= v.date
where d.continent is not null
order by 1,2,3
 
--Calculating the vaccinations
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CONVERT(int, v.new_vaccinations)) over (partition by d.location order by d.date) as RollingPeopleVaccinated
from PortfolioProject..Covid_Deaths d
join PortfolioProject..Covid_Vaccinations v
on d.location = v.location
and d.date= v.date
where d.continent is not null and d.location like 'Albania'
order by 2,3

--CTE
With PopVSVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CONVERT(int, v.new_vaccinations)) over (partition by d.location order by d.date) as RollingPeopleVaccinated
from PortfolioProject..Covid_Deaths d
join PortfolioProject..Covid_Vaccinations v
on d.location = v.location
and d.date= v.date
where d.continent is not Null
)
select *, (RollingPeopleVaccinated/Population)*100
From PopVSVac
Go
--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_Vaccinations numeric, RollingPeopleVaccinated numeric)
Insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CONVERT(int, v.new_vaccinations)) over (partition by d.location order by d.date) as RollingPeopleVaccinated
from PortfolioProject..Covid_Deaths d
join PortfolioProject..Covid_Vaccinations v
on d.location = v.location
and d.date= v.date
where d.continent is not Null

select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--View
Create View PercentPeopleVaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CONVERT(int, v.new_vaccinations)) over (partition by d.location order by d.date) as RollingPeopleVaccinated
from PortfolioProject..Covid_Deaths d
join PortfolioProject..Covid_Vaccinations v
on d.location = v.location
and d.date= v.date
where d.continent is not Null

select * from PercentPeopleVaccinated