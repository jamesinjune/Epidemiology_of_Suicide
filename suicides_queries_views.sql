SELECT TOP 200 *
FROM SQLSuicideRates.dbo.SuicidesPopulation
;


SELECT TOP 200 *
FROM SQLSuicideRates.dbo.HappinessIndex
;




/* Suicide rates by country */

-- Suicide count in countries
SELECT country,
	   year,
	   SUM(population) AS population_no,
	   SUM(suicides) AS suicides_no
FROM SQLSuicideRates..SuicidesPopulation
GROUP BY country,
		 year
ORDER BY suicides_no DESC
;

-- Suicide rates (per 100,000) in countries by age groups, gender
SELECT country,
	   sex,
	   age,
	   year,
	   population,
	   suicides,
	   (suicides / population) * 100000 AS suicide_rate
FROM SQLSuicideRates..SuicidesPopulation
ORDER BY suicide_rate DESC
;


-- Age-standardized suicide rates by country
WITH country_stats AS
		(SELECT country,
			    year,
			    age,
			    SUM(population) AS population_no,
		        SUM(suicides) AS suicides_no,
				AVG(weights) AS weights
		 FROM SQLSuicideRates..SuicidesPopulation
		 GROUP BY country, year, age),
	 crude_rates AS
	    (SELECT country,
			    year,
			    age,
				population_no,
				suicides_no,
			    (suicides_no / population_no) * 100000 AS suicide_rate,
				weights
		 FROM country_stats),
	 standardized_by_age AS
	    (SELECT country,
			    year,
			    age,
				population_no,
				suicides_no,
			    suicide_rate * weights AS standardized_rate_per_age
		 FROM crude_rates)
SELECT country, 
	   year, 
	   SUM(population_no) AS population_no,
	   SUM(suicides_no) AS suicides_no,
	   SUM(standardized_rate_per_age) AS standardized_rate
FROM standardized_by_age
GROUP BY country, year
ORDER BY standardized_rate DESC
;




-- Age-standardized suicide rates by sex
WITH country_stats AS
		(SELECT country,
				year,
				sex,
				age,
				population,
				suicides,
				(suicides / population) * 100000 AS suicide_rate,
				weights
		 FROM SQLSuicideRates..SuicidesPopulation),
	 standardized_by_age AS(
		 SELECT country,
				year,
				sex,
				age,
				population,
				suicides,
				suicide_rate * weights AS standardized_rate_per_age
		 FROM country_stats)
SELECT country, 
	   year,
	   sex,
	   SUM(population) AS population_no,
	   SUM(suicides) AS suicides_no,
	   SUM(standardized_rate_per_age) AS standardized_rate
FROM standardized_by_age
GROUP BY country, sex, year
ORDER BY standardized_rate DESC
;




-- Suicide rates in countries by year, separated by age group
WITH country_stats AS
	(SELECT country,
			year,
			age,
		    SUM(population) AS population_no, 
		    SUM(suicides) AS suicides_no
	 FROM SQLSuicideRates..SuicidesPopulation
	 GROUP BY country, 
			  year, 
			  age
	)
SELECT country,
	   year,
	   age,
	   population_no,
	   suicides_no,
	   (suicides_no / population_no) * 100000 AS suicide_rate
FROM country_stats
ORDER BY suicide_rate DESC
;


-- Global suicide rates by year (per 100,000), age-standardized
WITH global_stats AS
		(SELECT year,
				age,
				SUM(population) AS global_population, 
				SUM(suicides) AS global_suicides,
				AVG(weights) AS weights
		 FROM SQLSuicideRates..SuicidesPopulation
		 GROUP BY year, age),
	 crude_rates AS
		(SELECT year,
				global_population,
				(global_suicides / global_population) * 100000 AS suicide_rate,
				weights
		 FROM global_stats),
	 standardized_by_age AS
		(SELECT year,
				global_population,
				suicide_rate * weights AS standardized_rate_per_age
		 FROM crude_rates)
SELECT 'Global' AS location,
	   year,
	   SUM(global_population) AS global_population,
	   SUM(standardized_rate_per_age) AS standardized_rate
FROM standardized_by_age
GROUP BY year
ORDER BY year
;



-- Global suicide rates by year, sex, age-standardized
WITH global_stats AS
		(SELECT year,
				sex,
				age,
				SUM(population) AS population_no,
				SUM(suicides) AS suicides_no,
				AVG(weights) AS weights
		 FROM SQLSuicideRates..SuicidesPopulation
		 GROUP BY year, sex, age),
	 crude_rates AS
		(SELECT year,
				sex,
				age,
				population_no,
				(suicides_no / population_no) * 100000 AS suicide_rate,
				weights
		 FROM global_stats),
	 standardized_by_age AS
		(SELECT year,
				sex,
				population_no,
				suicide_rate * weights AS standardized_rate_per_age
		 FROM crude_rates)
SELECT 'Global' AS location,
	   year,
	   sex,
	   SUM(population_no) AS population_no,
	   SUM(standardized_rate_per_age) AS standardized_rate
FROM standardized_by_age
GROUP BY year, sex
;


-- Global suicide rates by year, age
WITH global_stats AS
	(SELECT year, 
			age,
		    SUM(population) AS global_population, 
		    SUM(suicides) AS global_suicides
	 FROM SQLSuicideRates..SuicidesPopulation
	 GROUP BY year, age
	)
SELECT 'Global' AS location,
	   year,
	   age,
	   global_population,
	   global_suicides,
	   (global_suicides / global_population) * 100000 AS suicide_rate
FROM global_stats
ORDER BY year
;


-- Global suicide rates by age and sex
WITH global_stats AS
	(SELECT year, 
			age,
			sex,
		    SUM(population) AS global_population, 
		    SUM(suicides) AS global_suicides
	 FROM SQLSuicideRates..SuicidesPopulation
	 GROUP BY year, age, sex
	)
SELECT 'Global' AS location,
	   year,
	   age,
	   sex,
	   global_population,
	   global_suicides,
	   (global_suicides / global_population) * 100000 AS suicide_rate
FROM global_stats
ORDER BY year


-- Suicide rates in countries by year, female, age-standardized
WITH country_stats AS
		(SELECT country,
				year,
				sex,
				SUM(population) AS population_no, 
				SUM(suicides) AS suicides_no,
				AVG(weights) AS weights
		 FROM SQLSuicideRates..SuicidesPopulation
		 WHERE sex = 'female'
		 GROUP BY country, 
				  year, 
				  sex),
	 crude_rates AS
		(SELECT country,
				year,
				sex,
				population_no,
				suicides_no,
				(suicides_no / population_no) * 100000 AS suicide_rate,
				weights
		 FROM country_stats),
	 standardized_by_age AS
		(SELECT country,
				year,
				sex,
				population_no,
				suicides_no,
				suicide_rate * weights AS standardized_rate_per_age
		 FROM crude_rates)
SELECT country,
	   year,
	   sex,
	   SUM(population_no) AS population_no,
	   SUM(suicides_no) AS suicides_no,
	   SUM(standardized_rate_per_age) AS standardized_rate
FROM standardized_by_age
GROUP BY country, year, sex
ORDER BY standardized_rate DESC
;




-- Cumulative suicides by countries, yearly
WITH country_stats AS
	(SELECT country, 
			year, 
			SUM(suicides) AS suicides_no, 
			SUM(population) AS population_no
	 FROM SQLSuicideRates..SuicidesPopulation
	 GROUP BY country, 
			  year
	)
SELECT country,
	   year, 
	   SUM(suicides_no) OVER (PARTITION BY country ORDER BY year) AS cumulative_suicides_by_country, 
	   population_no
FROM country_stats
;








/* Country-specific data */

-- Overall suicides by country yearly

--CREATE PROCEDURE country_suicide_rates
ALTER PROCEDURE country_suicide_rates
@country nvarchar(255)
AS
WITH country_stats AS
	(SELECT country,
			year,
			SUM(population) AS population_no,
			SUM(suicides) AS suicides_no
	 FROM SQLSuicideRates..SuicidesPopulation
	 WHERE country = @country
	 GROUP BY country,
			  year)
SELECT country,
	   year,
	   population_no,
	   suicides_no,
	   (suicides_no / population_no) * 100000 AS suicide_rate
FROM country_stats
;


EXEC country_suicide_rates @country = 'Canada'
;
EXEC country_suicide_rates @country = 'Japan'
;






/* Happiness Index */


SELECT TOP 200 *
FROM SQLSuicideRates.dbo.HappinessIndex
;



SELECT country,
	   year,
	   Life_Ladder,
	   Log_GDP_per_capita,
	   Social_support,
	   Healthy_life_expectancy_at_birth,
	   Freedom_to_make_life_choices,
	   Generosity,
	   Perceptions_of_corruption,
	   Positive_affect,
	   Negative_affect
FROM SQLSuicideRates..HappinessIndex
ORDER BY Life_Ladder DESC
;


SELECT country,
	   year,
	   Life_Ladder,
	   Log_GDP_per_capita,
	   Social_support,
	   Healthy_life_expectancy_at_birth,
	   Freedom_to_make_life_choices,
	   Generosity,
	   Perceptions_of_corruption,
	   Positive_affect,
	   Negative_affect
FROM SQLSuicideRates..HappinessIndex
ORDER BY Freedom_to_make_life_choices DESC
;





/* Joining Suicide Rates and Happiness Index */


-- Age-standardized suicide rates and Happiness Index by country by year, non-sex non-age specific

WITH country_stats AS
		(SELECT country,
			    year,
			    age,
			    SUM(population) AS population_no,
		        SUM(suicides) AS suicides_no,
				AVG(weights) AS weights
		 FROM SQLSuicideRates..SuicidesPopulation
		 GROUP BY country, year, age),
	 crude_rates AS
	    (SELECT country,
			    year,
			    age,
				population_no,
			    (suicides_no / population_no) * 100000 AS suicide_rate,
				weights
		 FROM country_stats),
	 standardized_by_age AS
	    (SELECT country,
			    year,
			    age,
				population_no,
			    suicide_rate * weights AS standardized_rate_per_age
		 FROM crude_rates),
	 standardized_rates_summed AS
		(SELECT country,
				year,
				SUM(population_no) AS population_no,
				SUM(standardized_rate_per_age) AS standardized_rate
		 FROM standardized_by_age
		 GROUP BY country, year)
SELECT suicides.country,
	   suicides.year,
	   population_no,
	   standardized_rate,
	   Life_Ladder,
	   Log_GDP_per_capita,
	   Social_support,
	   Healthy_life_expectancy_at_birth,
	   Freedom_to_make_life_choices,
	   Generosity,
	   Perceptions_of_corruption,
	   Positive_affect,
	   Negative_affect
FROM standardized_rates_summed suicides
INNER JOIN SQLSuicideRates..HappinessIndex happiness
		ON suicides.country = happiness.country
	   AND suicides.year = happiness.year
;



-- Age-standardized suicide rates and Happiness Index by country by year by sex
WITH country_stats AS
		(SELECT country,
				year,
				sex,
				SUM(population) AS population_no,
				SUM(suicides) AS suicides_no,
				AVG(weights) AS weights
		FROM SQLSuicideRates..SuicidesPopulation
		GROUP BY country, year, sex),
	 crude_rates AS
	    (SELECT country,
			    year,
			    sex,
				population_no,
			    (suicides_no / population_no) * 100000 AS suicide_rate,
				weights
		 FROM country_stats),
	 standardized_by_age AS
		(SELECT country,
			    year,
			    sex,
				population_no,
			    suicide_rate * weights AS standardized_rate_per_sex
		 FROM crude_rates),
	 standardized_rates_summed AS
		(SELECT country,
				year,
				sex,
				SUM(population_no) AS population_no,
				SUM(standardized_rate_per_sex) AS standardized_rate
		 FROM standardized_by_age
		 GROUP BY country, year, sex)
SELECT suicides.country,
	   suicides.year,
	   sex,
	   population_no,
	   standardized_rate,
	   Life_Ladder,
	   Log_GDP_per_capita,
	   Social_support,
	   Healthy_life_expectancy_at_birth,
	   Freedom_to_make_life_choices,
	   Generosity,
	   Perceptions_of_corruption,
	   Positive_affect,
	   Negative_affect
FROM standardized_rates_summed suicides
INNER JOIN SQLSuicideRates..HappinessIndex happiness
		ON suicides.country = happiness.country
	   AND suicides.year = happiness.year
ORDER BY Life_Ladder DESC
;


-- Suicide rates and Happiness Index by country by year by age, non-sex specific
WITH country_stats AS
	(SELECT country,
			year,
			age,
			SUM(population) AS population_no,
			SUM(suicides) AS suicides_no
	 FROM SQLSuicideRates..SuicidesPopulation
	 GROUP BY country, 
			  year,
			  age)
SELECT suicides.country,
	   suicides.year,
	   age,
	   population_no,
	   suicides_no,
	   (suicides_no / population_no) * 100000 AS suicide_rate,
	   Life_Ladder,
	   Log_GDP_per_capita,
	   Social_support,
	   Healthy_life_expectancy_at_birth,
	   Freedom_to_make_life_choices,
	   Generosity,
	   Perceptions_of_corruption,
	   Positive_affect,
	   Negative_affect
FROM country_stats suicides
INNER JOIN SQLSuicideRates..HappinessIndex happiness
		ON suicides.country = happiness.country
	   AND suicides.year = happiness.year
;

-- Suicide rates and Happiness Index by country, year, age-separated sex-separated
SELECT suicides.country,
	   suicides.year,
	   sex,
	   age,
	   population,
	   suicides,
	   (suicides / population) * 100000 AS suicide_rate,
	   Life_Ladder,
	   Log_GDP_per_capita,
	   Social_support,
	   Healthy_life_expectancy_at_birth,
	   Freedom_to_make_life_choices,
	   Generosity,
	   Perceptions_of_corruption,
	   Positive_affect,
	   Negative_affect
FROM SQLSuicideRates..SuicidesPopulation suicides
INNER JOIN SQLSuicideRates..HappinessIndex happiness
		ON suicides.country = happiness.country
	   AND suicides.year = happiness.year
ORDER BY Life_Ladder DESC
;






/* Creating Views */

-- Suicide Rates

CREATE VIEW suicide_countries
AS
WITH country_stats AS
		(SELECT country,
			    year,
			    age,
			    SUM(population) AS population_no,
		        SUM(suicides) AS suicides_no,
				AVG(weights) AS weights
		 FROM SQLSuicideRates..SuicidesPopulation
		 GROUP BY country, year, age),
	 crude_rates AS
	    (SELECT country,
			    year,
			    age,
				population_no,
				suicides_no,
			    (suicides_no / population_no) * 100000 AS suicide_rate,
				weights
		 FROM country_stats),
	 standardized_by_age AS
	    (SELECT country,
			    year,
			    age,
				population_no,
				suicides_no,
			    suicide_rate * weights AS standardized_rate_per_age
		 FROM crude_rates),
	 standardized_rates_summed AS
		(SELECT country,
				year,
				SUM(population_no) AS population_no,
				SUM(suicides_no) AS suicides_no,
				SUM(standardized_rate_per_age) AS standardized_rate
		 FROM standardized_by_age
		 GROUP BY country, year)
SELECT suicides.country,
	   suicides.year,
	   population_no,
	   suicides_no,
	   standardized_rate
FROM standardized_rates_summed suicides
INNER JOIN SQLSuicideRates..HappinessIndex happiness
		ON suicides.country = happiness.country
	   AND suicides.year = happiness.year
;


CREATE VIEW suicide_sex
AS
WITH country_stats AS
		(SELECT country,
				year,
				sex,
				age,
				population,
				suicides,
				(suicides / population) * 100000 AS suicide_rate,
				weights
		 FROM SQLSuicideRates..SuicidesPopulation),
	 standardized_by_age AS(
		 SELECT country,
				year,
				sex,
				population,
				suicides,
				suicide_rate * weights AS standardized_rate_per_age
		 FROM country_stats),
	 standardized_rates_summed AS
		(SELECT country,
				year,
				sex,
				SUM(population) AS population_no,
				SUM(suicides) AS suicides_no,
				SUM(standardized_rate_per_age) AS standardized_rate
		 FROM standardized_by_age
		 GROUP BY country, year, sex)
SELECT suicides.country,
	   suicides.year,
	   sex,
	   population_no,
	   suicides_no,
	   standardized_rate
FROM standardized_rates_summed suicides
INNER JOIN SQLSuicideRates..HappinessIndex happiness
		ON suicides.country = happiness.country
	   AND suicides.year = happiness.year
;



CREATE VIEW suicide_age
AS
WITH country_stats AS
	(SELECT country,
			year,
			age,
			SUM(population) AS population_no,
			SUM(suicides) AS suicides_no
	 FROM SQLSuicideRates..SuicidesPopulation
	 GROUP BY country, 
			  year,
			  age)
SELECT suicides.country,
	   suicides.year,
	   age,
	   population_no,
	   suicides_no,
	   (suicides_no / population_no) * 100000 AS suicide_rate
FROM country_stats suicides
INNER JOIN SQLSuicideRates..HappinessIndex happiness
		ON suicides.country = happiness.country
	   AND suicides.year = happiness.year
;


CREATE VIEW suicide_sex_age
AS
SELECT suicides.country,
	   suicides.year,
	   sex,
	   age,
	   population,
	   suicides,
	   (suicides / population) * 100000 AS suicide_rate
FROM SQLSuicideRates..SuicidesPopulation suicides
INNER JOIN SQLSuicideRates..HappinessIndex happiness
		ON suicides.country = happiness.country
	   AND suicides.year = happiness.year
;



