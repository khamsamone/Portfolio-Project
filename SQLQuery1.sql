select * 
from CovideDeaths
order by 3,4

--select * from CovideVacinations
--order by 3,4

--- select data that we are going to be using 
Select location ,date ,total_cases , new_cases , total_deaths, Population 
FRom covideDeaths
order by 1,2

----looking at total cases vs total deaths
----Shows likelihood of dyin if you contract covid in your country

Select location ,date ,total_cases , total_deaths,
(total_deaths/total_cases)* 100 as DeathPercentage
FRom covideDeaths
where location like '%states%'
order by 1,2

---- looking at total cases vs population 
---- shows what percentage of population got covid

Select location ,date , population,total_cases ,
(total_cases/population)* 100 as DeathPercentage
FRom covideDeaths
where location like '%lao%'
order by 1,2

----looking at countries with highest infection rate compared to population
Select location  , population,max(total_cases) as highestInfectionCount ,
(total_cases/population)* 100 as PercentagePopulationInfected
FRom covideDeaths
---where location like '%lao%'
Group by location,population , total_cases
order by PercentagePopulationInfected desc

----- let's break things down by continent
---- showing countries with the highest death count per population 
Select location ,max(cast(total_deaths as int)) as totalDeathCount
FRom covideDeaths
---where location like '%lao%'
where continent is not null
Group by location,total_deaths
order by totalDeathCount desc

----- let's break things down by continent
 
Select continent ,max(cast(total_deaths as int)) as totalDeathCount
FRom covideDeaths
---where location like '%lao%'
where continent is not null
Group by continent
order by totalDeathCount desc


---showing the continent with highest death count per population

Select continent ,max(cast(total_deaths as int)) as totalDeathCount
FRom covideDeaths
---where location like '%lao%'
where continent is not null
Group by continent
order by totalDeathCount desc

----Global number ---- 
Select location,date,total_cases,total_deaths,(total_cases/total_deaths) * 100 as deathPercentage
from CovideDeaths 
where continent is not null and total_cases is not null 
order by 1,2

Select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths ,
sum(cast(new_deaths as int))/ sum(new_cases) * 100  as deathsPercentage
 ---total_cases,total_deaths,(total_cases/total_deaths) * 100 as deathPercentage
from CovideDeaths 
where continent is not null 
group by date
order by 1,2

---use table vaccination---
--- use cte
with PopVsVac (continent, location, date,population, new_vaccinations,RollingPeoplevaccinated) as
(
select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations )) over (partition by dea.location,dea.date) as RollingPeoplevaccinated
---(RollingPeoplevaccinated/population)*100
from [PortfolioCovide-Project] .. CovideVacinations vac
join [PortfolioCovide-Project] .. CovideDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date 
	where dea.continent is not null
--order by 2,3
)
select * ,(RollingPeoplevaccinated/population)* 100
from PopVsVac 


--- Temp table -------------------------

drop  table if exists #PercentPopulationVaccinate
create table #PercentPopulationVaccinate
(
continent nvarchar(225),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeoplevaccinated numeric
)
insert into #PercentPopulationVaccinate
select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations )) over (partition by dea.location,dea.date) as RollingPeoplevaccinated
---(RollingPeoplevaccinated/population)*100
from [PortfolioCovide-Project] .. CovideVacinations vac
join [PortfolioCovide-Project] .. CovideDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date 
	where dea.continent is not null

select * , (RollingPeopleVaccinated/population) * 100 
from #PercentPopulationVaccinate

-------- creating View to stored Data for later  visualization -------

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations )) over (partition by dea.location,dea.date) as RollingPeoplevaccinated
---(RollingPeoplevaccinated/population)*100
from [PortfolioCovide-Project] .. CovideVacinations vac
join [PortfolioCovide-Project] .. CovideDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date 
	where dea.continent is not null
	----order by 2,3