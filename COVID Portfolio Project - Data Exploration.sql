SELECT *
FROM PorfolioProject..CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--FROM PorfolioProject..CovidVaccinations
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PorfolioProject..CovidDeaths
where continent is not null
order by 1,2


SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PorfolioProject..CovidDeaths
where location like '%india%'
and continent is not null
order by 1,2



SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PorfolioProject..CovidDeaths
--where location like '%india%'
order by 1,2



SELECT location, population, MAX(total_cases) as HighestInfectedCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PorfolioProject..CovidDeaths
--where location like '%india%'
group by location, population
order by PercentPopulationInfected desc



SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount  
FROM PorfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by location
order by TotalDeathCount desc



SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount  
FROM PorfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount desc



SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PorfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
--group by date
order by 1,2


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as  RollingPeopleVaccinated
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as  RollingPeopleVaccinated
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
 )
 select *, (RollingPeopleVaccinated/population) * 100
 from PopvsVac


--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as  RollingPeopleVaccinated
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

select *, (RollingPeopleVaccinated/population) * 100
 from #PercentPopulationVaccinated



--creating view to store data for later visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as  RollingPeopleVaccinated
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

select *
from PercentPopulationVaccinated