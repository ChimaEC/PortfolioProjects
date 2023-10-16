select *
from PortfolioProject..CovidDeaths
order by 3,4

--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1, 2



--Looking at the Total Cases vs Total Deaths
--Shows likelihood of Dying if you contact covid in Nigeria

select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 AS DeathPercent
from PortfolioProject..CovidDeaths
where location ='Nigeria'
order by 1, 2



--Looking at the Total cases vs Population
--Shows the percentage of the population infected by Covid

select location, date, population, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location = 'Nigeria'
order by 1, 2


--Looking at Countries with Highest Infection rate compared to Population

select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location = 'Nigeria'
Group by location, population
order by PercentPopulationInfected desc


--Showing Countries with the highest death count

select location, MAX(CONVERT(INT, total_deaths)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location = ''
where continent is not null
-- This is because there are some locations which where given as continent and the continent , 'NULL'.
-- So in order to avoid this continent enlisting as location we add in the previous 'Where' condition.
Group by location
order by TotalDeathCount desc



--Now by Continent

--Shows the Continent with Highest Death Count

select continent, MAX(CONVERT(INT, total_deaths)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not Null
Group by continent
Order by TotalDeathCount desc



--Global Numbers

Select Sum(new_cases)as TotalCases, SUM(CONVERT(int, new_deaths))as TotalDeaths, (sum(convert(int, new_deaths))/sum(new_cases))*100 as DeathPercent
from PortfolioProject..CovidDeaths
Where continent is not Null
--Group by date
order by 1, 2



--Looking at Total Population vs Vaccinations


--USE CTE

with PopvsVac (Conitnent, location, Date, Population, New_Vaccinations, TotalVaccinationsPerLocation)
as
(
Select D.continent, D.location, D.date, D.population, V.new_vaccinations,
		SUM(CONVERT(INT, V.new_vaccinations)) OVER (Partition by D.location Order by D.location, D.date) as TotalVaccinationsPerLocation
 from PortfolioProject..CovidDeaths D
Join PortfolioProject..CovidVaccinations V
	on (D.location = V.location) and (D.date = V.date)
where D.continent is not NULL
--order by 2,3
)
Select *, (TotalVaccinationsPerLocation/Population)*100 as PercentPopulationVaccinated
from PopvsVac



--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
TotalVaccinationsPerLocation numeric
)

Insert into #PercentPopulationVaccinated
Select D.continent, D.location, D.date, D.population, V.new_vaccinations,
		SUM(CONVERT(INT, V.new_vaccinations)) OVER (Partition by D.location Order by D.location, D.date) as TotalVaccinationsPerLocation
from PortfolioProject..CovidDeaths D
Join PortfolioProject..CovidVaccinations V
	on (D.location = V.location) and (D.date = V.date)
where D.continent is not NULL
--order by 2,3


Select *, (TotalVaccinationsPerLocation/Population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated



--Creating view to store data for later Visualization


Create View PercentPopulationVaccinated as
Select D.continent, D.location, D.date, D.population, V.new_vaccinations,
		SUM(CONVERT(INT, V.new_vaccinations)) OVER (Partition by D.location Order by D.location, D.date) as TotalVaccinationsPerLocation
from PortfolioProject..CovidDeaths D
Join PortfolioProject..CovidVaccinations V
	on (D.location = V.location) and (D.date = V.date)
where D.continent is not NULL
--order by 2,3

Select *
From PercentPopulationVaccinated