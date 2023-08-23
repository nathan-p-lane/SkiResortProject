Select *
FROM SkiProject.dbo.ResortInfo;

Alter Table SkiProject.dbo.ResortInfo
Alter Column Price_USD money; -- I forgot to change the nvarchar data type for Price_USD when importing data

/* 
Total number of ski resorts and average price of different ski resorts?
*/
Select COUNT(*) as 'Total', AVG(Price_USD) as 'Avg Price'
From SkiProject.dbo.ResortInfo;

Select COUNT(*) as 'Total', AVG(Price_USD) as 'Avg Price Child Friendly'
From SkiProject.dbo.ResortInfo
Where Child_Friendly = '1';

Select COUNT(*) as 'Total', AVG(Price_USD) as 'Avg Price Resorts w/ Park'
From SkiProject.dbo.ResortInfo
Where Snowparks = '1';

Select COUNT(*) as 'Total', AVG(Price_USD) as 'Avg Price Nightskiing Resorts'
From SkiProject.dbo.ResortInfo
Where Nightskiing = '1';

Select COUNT(*) as 'Total', AVG(Price_USD) as 'Avg Price Summer Skiing Resorts'
From SkiProject.dbo.ResortInfo
Where Summer_skiing = '1';

/*
What are the countries with the most ski resorts?
*/
-- Replace the first null value of continent, which is just All the resorts combined
-- Due to the ROLLUP modifier, the outputted table has an extra row that represents the grand total for each group combination
-- Country's value is null at aggregate total, replace with '/'
Select COALESCE(Continent, 'All resorts') as Continent, 
	COALESCE(Country, '/') as Country, 
	COUNT(*) as Total, 
	AVG(Price_USD) as AvgPrice
From SkiProject.dbo.ResortInfo
Group by Continent, Country WITH ROLLUP
Order by Continent, Country;

/*
Where are the best resorts for beginners? For Intermediate? For experts?
*/
Select Continent, Country, Resorts, Beginner_slopes
From SkiProject.dbo.ResortInfo
Order by Beginner_slopes DESC;

Select Continent, Country, Resorts, Intermediate_slopes
From SkiProject.dbo.ResortInfo
Order by Intermediate_slopes DESC;

Select Continent, Country, Resorts, Difficult_slopes
From SkiProject.dbo.ResortInfo
Order by Difficult_slopes DESC;

/*
Which resorts have the highest peak? Which resorts have the largest elevation change?
*/
-- Peak Rank
WITH peak_rank AS (
    SELECT 
        Continent, 
        Country, 
        Resorts, 
        [Highest_point],
        RANK() OVER (PARTITION BY Continent ORDER BY [Highest_point] DESC) AS highest_point_continent_rank,
        RANK() OVER (ORDER BY [Highest_point] DESC) AS highest_point_world_rank
    FROM SkiProject.dbo.ResortInfo
)
SELECT * 
FROM peak_rank
WHERE highest_point_continent_rank <= 5;

-- Elevation Rank
WITH elevation_rank AS (
    SELECT 
        Continent, 
        Country, 
        Resorts, 
        ([Highest_point] - [Lowest_point]) AS elevation,
        RANK() OVER (PARTITION BY Continent ORDER BY ([Highest_point] - [Lowest_point]) DESC) AS elevation_continent_rank,
        RANK() OVER (ORDER BY ([Highest_point] - [Lowest_point]) DESC) AS elevation_world_rank
    FROM SkiProject.dbo.ResortInfo
)
SELECT * 
FROM elevation_rank
WHERE elevation_continent_rank <= 5;