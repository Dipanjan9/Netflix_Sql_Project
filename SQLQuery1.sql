select * from dbo.netflix

select distinct(type) from dbo.netflix


-- 15 Business Problems & Solutions

--1. Count the number of Movies vs TV Shows

select type, count(*) as num from dbo.netflix
group by type
order by num desc

-- 2. Find the most common rating for movies and TV shows

select type ,rating from
(	select type, rating, count(*) as counts,
	rank() over(partition by type order by count(*) desc ) as ranks
	from dbo.netflix
	group by type, rating
) as p

where ranks = 1;

--3. List all movies released in a specific year (e.g., 2020)

select title from dbo.netflix
where type = 'Movie' and release_year = 2020

--4. Find the top 5 countries with the most content on Netflix

select top 5 country from dbo.netflix
group by country
having country is not null
order by count(*) desc

-- 5. Identify the longest movie

select top 1 title from dbo.netflix
where type = 'Movie'
order by CAST(LEFT(duration, CHARINDEX(' ', duration + ' ') - 1) AS INT)


-- 6. Find content added in the last 5 years

select title from dbo.netflix
where year(getdate()) - year(convert(date, date_added)) = 5;


--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select type, title, director from dbo.netflix
where director = 'Rajiv Chilaka'

-- 8. List all TV shows with more than 5 seasons

select title, CAST(LEFT(duration, CHARINDEX(' ', duration + ' ') - 1) AS INT) as num_of_seasons from dbo.netflix
where type = 'TV Show' and CAST(LEFT(duration, CHARINDEX(' ', duration + ' ') - 1) AS INT)>5
order by num_of_seasons desc

-- 9. Count the number of content items in each genre

select listed_in, count(*) as num from dbo.netflix
group by listed_in
order by num desc

-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !

select  p.year_added, 
    p.num AS total_added, 
    n.num AS india_added, 
	round(CAST(n.num AS FLOAT) / CAST(p.num AS FLOAT) * 100, 2) AS india_percentage from
(

select  year(convert(date, date_added)) as year_added, count(*) as num from dbo.netflix
group by  year(convert(date, date_added))

) as p

join 
(
select country, year(convert(date, date_added)) as year_added, count(*) as num from dbo.netflix
where country = 'India'
group by country,year(convert(date, date_added))
)
as n on p.year_added = n.year_added
order by india_percentage desc

--year(convert(date, date_added)) as year_added
-- num/count(show_id) 

-- 11. List all movies that are documentaries

SELECT * from dbo.netflix
WHERE listed_in LIKE '%Documentaries'

-- 12. Find all content without a director

SELECT * from dbo.netflix
WHERE director is null


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT title 
FROM (
    SELECT 
        title, 
        YEAR(CONVERT(DATE, date_added)) AS year_released 
    FROM dbo.netflix
    WHERE title LIKE '%Salman Khan%'
) AS p
WHERE year_released BETWEEN YEAR(GETDATE()) - 10 AND YEAR(GETDATE());

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select top 10 cast_member, count(*) as num from
(
SELECT 
    title, 
    TRIM(value) AS cast_member 
FROM 
    dbo.netflix
CROSS APPLY 
    STRING_SPLIT(cast, ',') 
WHERE 
    country = 'India'
) as p
group by cast_member
order by num desc


/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/

select category, type, count(*) as num from 
(
select *,

case
when description like '%kill%' then 'Bad'
when description like '%violence%' then 'Bad'
else 'Good'
end as category

from dbo.netflix
) as p
group by category,type
order by type 






