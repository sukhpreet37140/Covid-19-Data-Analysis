
--select * from [sql Project]..CovidDeaths

--select * from [sql Project]..CovidVaccinations

--calling location, date and other columns Covid Deaths Dataset
select location, date, total_cases, total_deaths, population from [sql Project]..CovidDeaths order by location, date

--relation between total deaths and total death percentage especially for India
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage from [sql Project]..CovidDeaths 
where location like '%india%' and continent is not null
order by location, date

--relation between total cases and percentage of population infected with covid-19 
select location, date, total_cases, total_deaths, (total_cases/population)*100 as populationPercentage from [sql Project]..CovidDeaths 
where location like '%india%' and continent is not null
order by location, date

--Highest infection proportion countrywise
select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population)*100) as populationPercentageaffected 
from [sql Project]..CovidDeaths 
--WHERE location like '%india%' and continent is not null
group by location, population
order by populationPercentageaffected desc, highest_infection_count desc


--Average infection proportion countrywise
select location, population, avg(total_cases) as average_infection_count, avg((total_cases/population)*100) as averagepopulationPercentageaffected 
from [sql Project]..CovidDeaths 
--WHERE location like '%india%'
where continent is not null
group by location, population
order by averagepopulationPercentageaffected desc, average_infection_count desc

--order cases by maximum number
select location, MAX(cast(total_cases as int)) as total_cases, MAX(cast(total_deaths as int)) as total_deaths 
from [sql Project]..CovidDeaths 
--WHERE location like '%india%'
where continent is not null
group by location
order by 3 desc

--continent wise maximum number of cases
select continent, MAX(cast(total_cases as int)) as total_cases, MAX(cast(total_deaths as int)) as total_deaths 
from [sql Project]..CovidDeaths 
--WHERE location like '%india%'
WHERE CONTINENT IS not NULL
group by continent
order by 3 desc

--order total number of cases and deaths in the world date wise 
select date, SUM(cast(total_cases as int)) as total_cases, SUM(cast(total_deaths as int)) as total_deaths 
from [sql Project]..CovidDeaths 
--WHERE location like '%india%'
--WHERE CONTINENT IS not NULL
group by date
order by date 

--covid vaccinations and covid deaths datasets
select dea.location, dea.date, dea.population, dea.total_cases, cast(vac.total_vaccinations as int) as total_vaccinations 
from [sql Project]..CovidVaccinations vac 
join [sql Project]..CovidDeaths dea on 
	dea.date = vac.date and
	dea.location = vac.location
where dea.continent is not null
order by 1, 2


--talk about covid new vaccinations
with popvsvac(continent, location, date, population, new_vaccinations, rollingpeoplevaccinated) as (

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over 
(partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from [sql Project]..CovidDeaths as dea
join [sql Project]..CovidVaccinations as vac on 
	dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--group by dea.date
--order by 1, 2
)
select *, (rollingpeoplevaccinated/population)*100 as fractionpeoplevaccinated from popvsvac