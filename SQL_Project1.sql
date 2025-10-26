create database Netflix_Data;
use Netflix_Data;
select * from netflix;

-- 1. Count the number of Movies vs TV Shows
select type,count(*) as Total_numbers from netflix group by 1;

-- 2. Find the most common rating for movies and TV shows
 WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rn
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rn = 1;

-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix
WHERE release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix
select country, count(type) as total_content from netflix group by country order by total_content desc limit 5; 

-- 5. Identify the longest movie
SELECT 
    *
FROM netflix
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC;

-- 6. Find content added in the last 5 years
SELECT *
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;

-- 7. List all TV shows with more than 5 seasons
SELECT *
FROM netflix
WHERE 
    type = 'TV Show'
    AND duration LIKE '%Season%' AND duration >5;

-- 8. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !
SELECT 
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id) / 
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India') * 100,
        2
    ) AS avg_release
FROM netflix
WHERE FIND_IN_SET('India', country) > 0   -- handle multiple countries per row
GROUP BY release_year
ORDER BY avg_release DESC
LIMIT 5;

-- 9. List all movies that are documentaries
SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries';

-- 10. Find all content without a director
SELECT * FROM netflix
WHERE director IS NULL;

-- 11. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT *
FROM netflix
WHERE 
    cast LIKE '%Salman Khan%'
    AND release_year > YEAR(CURDATE()) - 10
    AND type = 'Movie';

/*
Question 12:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/
SELECT 
    CASE
        WHEN LOWER(description) LIKE '%kill%' 
             OR LOWER(description) LIKE '%violence%' THEN 'Bad'
        ELSE 'Good'
    END AS content_category,
    COUNT(*) AS total_content
FROM netflix
GROUP BY content_category;
