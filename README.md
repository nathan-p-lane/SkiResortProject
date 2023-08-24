# On Choosing a Ski Resort

## Insights
- EU outcompetes all continents with 360 resorts, compared to North America's 98. 
- America has the highest average day-pass price for skiing.
- France, by far, has the most beginner and intermediate terrain (km). 
- The Rocky Mountains in the US cater most to expert-level skiers, while resorts in EU mainly cater to skiers of all levels.
- Resorts with the highest peaks and largest elevation changes are located in EU and North America. Specifically, resorts in Switzerland and Colorado. Oceania ranks lowest. 



## About the Project
Even after my 5th year here in Colorado, I’m still skiing as much as I can. We’re a little spoiled here with some of the best terrain in the country just 2 hours east on I-70! But with that said, I’ve always had the drive to see what the rest of the world has to offer when it comes to skiing. There are a multitude of factors to consider: continent, prices, season, elevation, and more. This project aims to help anybody select their next ski resort anywhere on Earth based on their own preferences. 

The dataset is provided by Maven Analytics. Our ‘Resorts’ table consists of 499 records and 25 columns. It covers details like location, total slopes, total lifts, day pass price, months of operation, and more.

## Project Strategy
Tools used: Excel, SQL.

Steps taken for this project:
1. Data Cleaning
1. Exploratory Data Analysis

## Data Cleaning
To maintain the integrity of the dataset before running any analysis, I checked for any duplicate records. All 499 observations were unique, so there were still 499 resorts total. In the raw data, I removed symbols such as ‘?’ and other special characters in the Resort’s Name column using the substitute, trim, and clean functions. 

Additionally, using Sort and Filter, I discovered 27 records under the Season field that were ‘Unknown’. To fix this, I incorporated the IF function to replace ‘Unknown’ with assumed months of operation, say December to April. I ensured that these 27 records were not based out of the southern hemisphere, otherwise, this time frame would be false. Lastly, I multiplied the day-pass prices, which are in Euro, by the most recent exchange rate to convert the field to USD. All cleaning procedures were completed in new columns. 

## Exploratory Data Analysis
### **1. What’s the total number and average price of all resorts? Which countries have the most ski resorts?**

There are 499 resorts included in this dataset. The average price of a day ticket for all these resorts is $53.11 (I wish it was still this cheap). I also categorized the 499 resorts based on the services they offer below, with their average day-pass price:
- Child-friendly: 495 @ $53.13/day
- Snow Parks: 378 @ $56.01/day
- Nightskiing: 204 @ $52.81/day
- Summer Skiing: 29 @ $65.10/day

```
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
```

In Europe, Austria reigns supreme at 89 followed by Switzerland at 59 resorts. Across the pond, the United States sits at 78 resorts which are over Canada’s 20. In summary, here are the number of hills in each continent:
- European Resorts: 360
- North America Resorts: 98
- Asia Resorts: 24
- Oceania Resorts: 10
- South America: 7

Lastly, North America has the highest average day ticket price when compared to its competitors.

```
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

```

### **2. Where are the best resorts for beginners? Intermediate? Experts?**

France boasts the most beginner resorts by far, with multiple resorts there having more than 300 km of beginner slopes. With so much skiable terrain in France, this makes sense. The same holds for intermediate slopes in France; they have the most. However, when it comes to where the experts may want to be, they may find comfort in the United States. Big Sky Resort has 126 km of difficult hills, and Snowmass has 111 km. And now, I really want to take a trip to Big Sky.

```
Select Continent, Country, Resorts, Beginner_slopes
From SkiProject.dbo.ResortInfo
Order by Beginner_slopes DESC;

Select Continent, Country, Resorts, Intermediate_slopes
From SkiProject.dbo.ResortInfo
Order by Intermediate_slopes DESC;

Select Continent, Country, Resorts, Difficult_slopes
From SkiProject.dbo.ResortInfo
Order by Difficult_slopes DESC;
```

### **3. Which resorts have the highest peaks? What about the largest elevation change?**

To answer these questions, I assigned ranks to each resort, identifying the top 5 resorts based on mountain peak and elevation change within each continent using a window function. Breckenridge, CO comes in first for the highest peak at 3,914 m. In general, most of the resorts with high peaks and large elevation changes are located in North America and Europe. Namely, Switzerland in EU and the Colorado Rockies in the US. 

```
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
```
