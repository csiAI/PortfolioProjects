-- World Life Expectancy Project (Exploratory Data Analysis)

-- Let's look into how life expectancy has evolved over the years 2007-2022 by country.

SELECT Country, 
MIN(`Life expectancy`), 
MAX(`Life expectancy`),
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),1) AS Life_Increase_Over_15_Years
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0 AND MAX(`Life expectancy`) <> 0
ORDER BY Life_Increase_Over_15_Years DESC
;

-- Let's look at the world average life expectancy broken down by year.

SELECT Year, ROUND(AVG(`Life expectancy`),1) AS Life_Expectancy
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
GROUP BY Year
ORDER BY Year
;

-- Let's analyze whether there is a correlation between GDP and life expectancy.

SELECT Country, ROUND(AVG(GDP),1) AS GDP, ROUND(AVG(`Life expectancy`),1) AS Life_Expectancy
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Expectancy > 0
AND GDP > 0
ORDER BY GDP ASC
;

-- There seems to be a positive correlation between life expectancy and GDP - the higher the GDP, the higher life expectancy. 
-- Let's break down countries by GDP. Let's look at high GDP (over 1500) countries and low GDP (under 1500) and their life expectancies.

SELECT 
	SUM(CASE 
		WHEN GDP >= 1500 THEN 1 
        ELSE 0
	END) High_GDP_Count,
    ROUND(AVG(CASE 
		WHEN GDP >= 1500 THEN `Life expectancy` 
        ELSE NULL -- it's important not to use 0s, otherwise they will be averaged.
	END),1) High_GDP_Life_Expectancy,
    SUM(CASE 
		WHEN GDP <= 1500 THEN 1 
        ELSE 0
	END) Low_GDP_Count,
    ROUND(AVG(CASE 
		WHEN GDP <= 1500 THEN `Life expectancy` 
        ELSE NULL END),1) Low_GDP_Life_Expectancy
FROM world_life_expectancy
;

-- The results show that there is a 10 year gap in life expectancy between rich and poor counties.
-- Let's count the number of developed and developing countries and compare their average life expectancies.


SELECT Status, COUNT(DISTINCT Country), ROUND(AVG(`Life expectancy`),1)
FROM world_life_expectancy
GROUP BY Status
;

-- let's break down BMI (Body Mass Indez) by Country.

SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Expectancy, ROUND(AVG(BMI),1) AS BMI
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Expectancy > 0
AND BMI > 0
ORDER BY BMI DESC
;

-- Let's look into adult mortality across countries by using rolling total to add up adult mortatilty over the years.

SELECT 
	Country,
    Year,
    `Life expectancy`,
    `Adult Mortality`,
    SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) AS Rollin_Total
    FROM world_life_expectancy
;
