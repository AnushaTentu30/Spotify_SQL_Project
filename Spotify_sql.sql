-- Advacned SQL Project -- Spotify Datasets

Create database Spotify_db;

-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

SELECT * FROM Spotify;

-- EDA

SELECT COUNT(*) FROM spotify;

SELECT COUNT(DISTINCT artist) FROM spotify;

SELECT COUNT(DISTINCT album) FROM spotify;

SELECT DISTINCT album_TYPE FROM spotify;

SELECT MAX(duration_min) as max_duration FROM spotify;
SELECT MIN(duration_min) as min_duration FROM spotify;

SELECT * FROM spotify
WHERE duration_min = 0;

DELETE FROM spotify
WHERE duration_min = 0;

SELECT DISTINCT channel FROM spotify;

SELECT DISTINCT most_played_on FROM spotify;

/*
-- ---------------------------------------
-- Data Analysis - Easy Category
-- ---------------------------------------

1. Retrieve the names of all tracks that have more than 1 billion streams.
2. List all albums along with their respective artists.
3. Get the total number of comments for tracks where `licensed = TRUE`.
4. Find all tracks that belong to the album type `single`.
5. Count the total number of tracks by each artist.
*/


-- 1. Retrieve the names of all tracks that have more than 1 billion streams.

SELECT 
	* 
FROM spotify
WHERE stream > 1000000000;

-- 2. List all albums along with their respective artists.

SELECT
	DISTINCT album,
	artist
FROM Spotify
ORDER BY 1;

-- 3. Get the total number of comments for tracks where `licensed = TRUE`.

SELECT
	SUM(comments) as total_comments
FROM spotify
WHERE licensed = 'TRUE';

-- 4. Find all tracks that belong to the album type `single`.


SELECT *
FROM Spotify
WHERE
  album_type = 'single';

-- 5. Count the total number of tracks by each artist.

SELECT
	artist,
	count(track) as total_tracks
FROM Spotify
GROUP BY 1
ORDER BY 2;


/*
-- ---------------------------------------
-- Medium Level
-- ---------------------------------------

6. Calculate the average danceability of tracks in each album.
7. Find the top 5 tracks with the highest energy values.
8. List all tracks along with their views and likes where `official_video = TRUE`.
9. For each album, calculate the total views of all associated tracks.
10. Retrieve the track names that have been streamed on Spotify more than YouTube.
*/


-- 6. Calculate the average danceability of tracks in each album.

SELECT 
	album,
	avg(danceability) as avg_dancebility
FROM spotify
GROUP BY 1
ORDER BY 2 desc;

-- 7. Find the top 5 tracks with the highest energy values.

SELECT
	track,
	MAX(energy) as max_emergy
FROM Spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 8. List all tracks along with their views and likes where `official_video = TRUE`.

SELECT
	track,
	SUM(views) as total_views,
	SUM(likes) as total_likes
FROM Spotify
WHERE Official_video = 'TRUE'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 9. For each album, calculate the total views of all associated tracks.

SELECT
	track,
	album,
	SUM(views) as total_views
FROM Spotify
GROUP BY 1,2
ORDER BY 3 DESC;

-- 10. Retrieve the track names that have been streamed on Spotify more than on YouTube.

SELECT * FROM
(SELECT 
	track,
	--most_played_on
	COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END),0) as streamd_on_youtube,
	COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END),0) as streamed_on_spotify
	FROM Spotify
GROUP BY 1
) as t1
WHERE 
	streamed_on_spotify > streamd_on_youtube
	AND
	streamd_on_youtube <> 0


/*
-- ---------------------------------------
-- Advanced Level
-- ---------------------------------------

11. Find the top 3 most-viewed tracks for each artist using window functions.
12. Write a query to find tracks where the liveness score is above the average.
13. Use a `WITH` clause to calculate the difference between the highest and lowest energy values for tracks in each album.
14. Find tracks where the energy-to-liveness ratio is greater than 1.2.
15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
*/

-- 11. Find the top 3 most-viewed tracks for each artist using window functions.

With ranking_artist
AS(
SELECT 
	track,
	artist,
	SUM(views) as total_views,
	DENSE_RANK() OVER( PARTITION BY artist ORDER BY SUM(views) DESC) AS DN_RANK
FROM Spotify
GROUP BY 1,2
ORDER BY 1,3 DESC
) 
SELECT * FROM ranking_artist
WHERE DN_RANK <= 3;

-- 12. Write a query to find tracks where the liveness score is above the average.

SELECT
	track,
	liveness
FROM spotify
WHERE
	liveness > (select avg(liveness) from spotify);

-- [select avg(liveness) as averaged from spotify =0.1936__]

-- 13. Use a `WITH` clause to calculate the difference between the highest and lowest energy values for tracks in each album.

WITH energy_table
as(SELECT 
	album,
	MAX(energy) as highest_energy_value,
	MIN(energy) as lowest_energy_value
FROM Spotify
group by 1
)
  SELECT
  	album,
 	highest_energy_value - lowest_energy_value as energy_diff
  FROM energy_table
ORDER BY 2 DESC;

-- 14. Find tracks where the energy-to-liveness ratio is greater than 1.2.

SELECT track,
	   energy,
	   liveness,
       (energy/liveness) AS energy_liveness_ratio
FROM spotify
WHERE (energy/liveness) > 1.2;

-- 15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

SELECT track,
       views,
       likes,
       ROW_NUMBER() OVER (ORDER BY views) AS view_rank,
       SUM(likes) OVER (ORDER BY views) AS cumulative_likes
FROM Spotify;

-- QUERY OPTIMIZATION

EXPLAIN ANALYZE -- et 2.561 ms pt 0.183 ms

SELECT
	artist,
	track,
	views
FROM Spotify
WHERE artist = 'Gorillz'
	  AND
	  most_played_on = 'Youtube'
ORDER BY stream DESC LIMIT 5;


CREATE INDEX artist_index on spotify(artist);

-- END OF PROJECT
	






