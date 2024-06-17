SELECT *
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

-- total popu vs vaccination

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccionations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, 
dea.location, 
dea.date,
dea.population,
NULLIF(vac.new_vaccinations,0) AS New_Vaccinations,
NULLIF(SUM(new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date),0) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

ALTER TABLE CovidVaccinations
ALTER COLUMN new_vaccinations float

-- temp table

Drop Table if exists #PercentPopulationVaccinated
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
SELECT dea.continent, 
dea.location, 
dea.date,
dea.population,
NULLIF(vac.new_vaccinations,0) AS New_Vaccinations,
NULLIF(SUM(new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date),0) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, 
dea.location, 
dea.date,
dea.population,
NULLIF(vac.new_vaccinations,0) AS New_Vaccinations,
NULLIF(SUM(new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date),0) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
