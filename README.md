# Spotify Advanced SQL Project and Query Optimization 
Project Category: Advanced
[Click Here to get Dataset](https://www.kaggle.com/datasets/sanjanchaudhari/spotify-dataset)

![Spotify Logo](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_logo.jpg)

## Overview
This project involves analyzing a Spotify dataset with various attributes about tracks, albums, and artists using **SQL**. It covers an end-to-end process of normalizing a denormalized dataset, performing SQL queries of varying complexity (easy, medium, and advanced), and optimizing query performance. The primary goals of the project are to practice advanced SQL skills and generate valuable insights from the dataset.

```sql
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
```
## Project Steps

### 1. Data Exploration
Before diving into SQL, it’s important to understand the dataset thoroughly. The dataset contains attributes such as:
- `Artist`: The performer of the track.
- `Track`: The name of the song.
- `Album`: The album to which the track belongs.
- `Album_type`: The type of album (e.g., single or album).
- Various metrics such as `danceability`, `energy`, `loudness`, `tempo`, and more.

### 4. Querying the Data
After the data is inserted, various SQL queries can be written to explore and analyze the data. Queries are categorized into **easy**, **medium**, and **advanced** levels to help progressively develop SQL proficiency.

#### Easy Queries
- Simple data retrieval, filtering, and basic aggregations.
  
#### Medium Queries
- More complex queries involving grouping, aggregation functions, and joins.
  
#### Advanced Queries
- Nested subqueries, window functions, CTEs, and performance optimization.

### 5. Query Optimization
In advanced stages, the focus shifts to improving query performance. Some optimization strategies include:
- **Indexing**: Adding indexes on frequently queried columns.
- **Query Execution Plan**: Using `EXPLAIN ANALYZE` to review and refine query performance.
  
---

## 15 Practice Questions

### Easy Level
1. **Retrieve the names of all tracks that have more than 1 billion streams.**
```sql
SELECT 
	* 
FROM spotify
WHERE stream > 1000000000;
```

2. **List all albums along with their respective artists.**
```sql
SELECT
	DISTINCT album,
	artist
FROM Spotify
ORDER BY 1;
```

3. **Get the total number of comments for tracks where `licensed = TRUE`.**
```sql
SELECT
	SUM(comments) as total_comments
FROM spotify
WHERE licensed = 'TRUE';
```

4. **Find all tracks that belong to the album type `single`.**
```sql
SELECT *
FROM Spotify
WHERE
  album_type = 'single';
```

5. **Count the total number of tracks by each artist.**
```sql
SELECT
	artist,
	count(track) as total_tracks
FROM Spotify
GROUP BY 1
ORDER BY 2;
```

### Medium Level
6. **Calculate the average danceability of tracks in each album.**
```sql
SELECT 
	album,
	avg(danceability) as avg_dancebility
FROM spotify
GROUP BY 1
ORDER BY 2 desc;
```

7.**Find the top 5 tracks with the highest energy values.**
```sql
SELECT
	track,
	MAX(energy) as max_emergy
FROM Spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

8. **List all tracks along with their views and likes where `official_video = TRUE`.**
```sql
SELECT
	track,
	SUM(views) as total_views,
	SUM(likes) as total_likes
FROM Spotify
WHERE Official_video = 'TRUE'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

9. **For each album, calculate the total views of all associated tracks.**
```sql
SELECT
	track,
	album,
	SUM(views) as total_views
FROM Spotify
GROUP BY 1,2
ORDER BY 3 DESC;
```

10. **Retrieve the track names that have been streamed on Spotify more than YouTube.**
```sql
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
```


### Advanced Level
11. **Find the top 3 most-viewed tracks for each artist using window functions.**
```sql
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
```

12. Write a query to find tracks where the liveness score is above the average.
```sql
SELECT
	track,
	liveness
FROM spotify
WHERE
	liveness > (select avg(liveness) from spotify);

-- [select avg(liveness) as averaged from spotify =0.1936__]
```

13. **Use a `WITH` clause to calculate the difference between the highest and lowest energy values for tracks in each album.**
```sql
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
```
   
14. **Find tracks where the energy-to-liveness ratio is greater than 1.2.**
```sql
SELECT track,
	   energy,
	   liveness,
       (energy/liveness) AS energy_liveness_ratio
FROM spotify
WHERE (energy/liveness) > 1.2;
```

15. **Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.**
```sql
SELECT track,
       views,
       likes,
       ROW_NUMBER() OVER (ORDER BY views) AS view_rank,
       SUM(likes) OVER (ORDER BY views) AS cumulative_likes
FROM Spotify;
```

Here’s an updated section for your **Spotify Advanced SQL Project and Query Optimization** README, focusing on the query optimization task you performed. You can include the specific screenshots and graphs as described.

---

## Query Optimization Technique 

```sql
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
```

```sql
CREATE INDEX artist_index on spotify(artist);
```
To improve query performance, we carried out the following optimization process:

- **Initial Query Performance Analysis Using `EXPLAIN`**
    - We began by analyzing the performance of a query using the `EXPLAIN` function.
    - The query retrieved tracks based on the `artist` column, and the performance metrics were as follows:
        - Execution time (E.T.): **39.33 ms**
        - Planning time (P.T.): **2.625 ms**
    - Below is the **screenshot** of the `EXPLAIN` result before optimization:
      ![EXPLAIN Before Index]![Spotify _before _index_explain](https://github.com/user-attachments/assets/2bc40e65-f0ea-4688-be54-dfbbd967a57c)

- **Index Creation on the `artist` Column**
    - To optimize the query performance, we created an index on the `artist` column. This ensures faster retrieval of rows where the artist is queried.
    - **SQL command** for creating the index:
      ```sql
      CREATE INDEX idx_artist ON spotify_tracks(artist);
      ```

- **Performance Analysis After Index Creation**
    - After creating the index, we ran the same query again and observed significant improvements in performance:
        - Execution time (E.T.): **2.561 ms**
        - Planning time (P.T.): **0.183 ms**
    - Below is the **screenshot** of the `EXPLAIN` result after index creation:
      ![EXPLAIN After Index]![Spotify explain after index view](https://github.com/user-attachments/assets/5df76086-f4aa-4419-a8e8-504b93774de0)

- **Graphical Performance Comparison**
    - A graph illustrating the comparison between the initial query execution time and the optimized query execution time after index creation.
    - **Graph view** shows the significant drop in both execution and planning times:
      ![Performance Graph]![Spotify-Graphical view](https://github.com/user-attachments/assets/1f4f203f-92cd-43e0-bd81-50c96b2004ce)
      ![Performance Graph]![Spotify-Graphical view 1](https://github.com/user-attachments/assets/228492c7-3bd6-421c-bca0-2acfb763eea2)
      ![Performance Graph]![Spotify graphical view-2](https://github.com/user-attachments/assets/afbd330d-8235-40a8-a9ac-3687af5843ae)


This optimization shows how indexing can drastically reduce query time, improving the overall performance of our database operations in the Spotify project.
---



