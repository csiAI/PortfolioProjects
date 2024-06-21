-- World Life Expectancy Project (Data Cleaning)

SELECT * 
FROM world_life_expectancy.world_life_expectancy
;

-- Let's identify if there are duplicates. Each row should have a distinct year per country. 

SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy.world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT( CONCAT(Country, Year)) > 1
;

-- We identified 3 duplicates by counting the concatenation of country+year, which should be unique. We are going to identify which Row_IDs are affected by the duplicates in order to remove those rows.

SELECT *
FROM (
SELECT Row_ID, 
		CONCAT(Country, Year),
        ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS	 Row_Num
FROM world_life_expectancy
) AS Row_table
WHERE Row_Num > 1
;

-- We have now identified the Row_IDs affected by the duplicates. Let's now delete those duplicate rows.

DELETE FROM world_life_expectancy
WHERE Row_ID IN (
SELECT Row_ID
FROM (
SELECT Row_ID, 
		CONCAT(Country, Year),
        ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS	 Row_Num
FROM world_life_expectancy
) AS Row_table
WHERE Row_Num > 1)
;

-- Let's handle the missing data from Status column.

SELECT *
FROM world_life_expectancy
WHERE Status = ''
;

-- There are a few blank status. Let's see how the rest of rows are populated.

SELECT DISTINCT(Status)
FROM world_life_expectancy
WHERE Status <> ''
;

SELECT DISTINCT(Country)
FROM world_life_expectancy
WHERE Status = 'Developing'
;

-- Let's update the data by doing a self join. This way we can ask SQL to populate the data where there are blank spaces (t1) and overwrite where there already is a populated field with 'Developing' (t2).

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing'
;

-- Let's now populate the blank fields with 'Developed'.

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed'
;

-- let's now look at life expectancy. There is missing data.

SELECT *
FROM world_life_expectancy
WHERE `Life expectancy` = ''
;

-- Let's populate the field by averaging the previous and following years.

SELECT Country, Year, `Life expectancy`
FROM world_life_expectancy
;

-- Let's do a self join to populate those blank fields. We are creating two joins so that we can have the previous and following year's life expectancy in the same row. We can then average them and populate the blank field.

SELECT t1.Country, t1.Year, t1.`Life expectancy`, t2.Country, t2.Year, t2.`Life expectancy`, t3.Country, t3.Year, t3.`Life expectancy`
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year	= t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year	= t3.Year + 1
WHERE t1.`Life expectancy` = ''
;

-- Let's now add the average aggregate function.

SELECT t1.Country, t1.Year, t1.`Life expectancy`, t2.Country, t2.Year, t2.`Life expectancy`, t3.Country, t3.Year, t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`) / 2,1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year	= t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year	= t3.Year + 1
WHERE t1.`Life expectancy` = ''
;

UPDATE 
	world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year	= t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year	= t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`) / 2,1)
WHERE t1.`Life expectancy` = ''
;