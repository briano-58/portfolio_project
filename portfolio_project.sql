select*
from portfolio_project..CovidDeaths
where continent is not null
order by 3, 4 ;

--select*
--from portfolio_project..CovidVaccination
--order by 3, 4 

--select the data that we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from portfolio_project..CovidDeaths
order by 1, 2 

--looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid 19in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 death_percentage
from portfolio_project..CovidDeaths
where location like '%states%' 
order by 1, 2 ;

--looking at the total cases vs population
select location, date, population, total_cases, (total_cases/population)*100 as death_percentage
from portfolio_project..CovidDeaths
where location like '%states%' 
where continent is not null
order by 1, 2 ;

--looking at countries with the highest infection rate compared to the population

select location, population, 
	max(total_cases) as HighestInfectionCount,
	max((total_cases/population))*100 as PercentPopulationInfection
from portfolio_project..CovidDeaths
--where location like '%states%' 
Group by location, population
order by PercentPopulationInfection desc;

--showing coutries with the highest death count per population
select location, 
	population, 
	max(cast(total_deaths as int)) as TotalDeathCount,
	max((total_deaths/population))*100 as PercentPopulationDeath
from portfolio_project..CovidDeaths
where continent is not null 
Group by location, population
order by TotalDeathCount desc;

--lets break things down by ontinent
select continent, 
	max(cast(total_deaths as int)) as TotalDeathCount,
	max((total_deaths/population))*100 as PercentPopulationDeath
from portfolio_project..CovidDeaths
where continent is not null 
Group by continent
order by TotalDeathCount desc;

--global numbers
select --date, 
			sum(new_cases) as total_cases,
			sum(cast(new_deaths as int)) as total_deaths,
			(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from portfolio_project..CovidDeaths
where continent is not null
--group by date
order by 1,2;

--total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) OVER 
	(partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolio_project..CovidDeaths dea
join portfolio_project..CovidVaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3;

--using CTE (Common table EXpession)
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) OVER 
	(partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolio_project..CovidDeaths dea
join portfolio_project..CovidVaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
) 
select*, (RollingPeopleVaccinated/population)*100
from PopvsVac;
 
--temp table
Drop Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric, 
new_vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into	#PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) OVER 
	(partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolio_project..CovidDeaths dea
join portfolio_project..CovidVaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
select*, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated;

--creating view to store data for latervisualizations