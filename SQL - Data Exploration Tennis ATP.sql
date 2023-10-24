/* 
ATP Player rankings in 2010s Data Exploration

Skills used: Aggregate functions, Windows functions, converting data types, CTE's, Temp tables, creating views
*/


---------------------------------------------------------------------------
-----glance at the data from ATP_players and ATP_Rankings_in 2010's--------
---------------------------------------------------------------------------

SELECT *
FROM atp_players

SELECT *
FROM atp_rankings_10s
ORDER BY ranking_date desc



---------------------------------------------------------------------------
--top 10 players with the highest average ranking over the entire period?--
---------------------------------------------------------------------------

SELECT TOP (10)
	CONCAT(playerID.name_first, ' ', playerID.name_last) AS full_name,
	AVG(rank) AS average_rank
FROM atp_players AS playerID
JOIN atp_rankings_10s AS rankings
ON playerID.player_id = rankings.player_id
GROUP BY CONCAT(playerID.name_first, ' ', playerID.name_last)
HAVING COUNT(DISTINCT YEAR(rankings.ranking_date)) = 10
ORDER BY AVG(rank) 

	
---------------------------------------------------------------------------
----------Show players which had the average ranking inside TOP 10---------
---------------------------------------------------------------------------

SELECT CONCAT(playerID.name_first, ' ', playerID.name_last) AS full_name,
       AVG(rank) AS average_rank
FROM atp_players AS playerID
JOIN atp_rankings_10s AS rankings
ON playerID.player_id = rankings.player_id
GROUP BY CONCAT(playerID.name_first, ' ', playerID.name_last)
HAVING AVG(rank) < 10

	
---------------------------------------------------------------------------
----------List all the names of no. 1. players during the period-----------
---------------------------------------------------------------------------

SELECT 
	CONCAT(playerID.name_first, ' ', playerID.name_last) AS full_name
FROM atp_players AS playerID
JOIN atp_rankings_10s AS rankings
ON playerID.player_id = rankings.player_id
WHERE rank = 1
GROUP BY 	
	CONCAT(playerID.name_first, ' ', playerID.name_last)

	
----------------------------------------------------------------------------
--------------Analysis of top ranked players during the period--------------
----------------------------------------------------------------------------

-- since only 4 players were no.1 during that time, lets see if anybody besides them was top 3 during the period
-- showing when anybody else was top 3 and which rank were they

SELECT 
	rankings.rank,
	CONCAT(playerID.name_first, ' ', playerID.name_last) AS full_name
FROM atp_players AS playerID
JOIN atp_rankings_10s AS rankings
ON playerID.player_id = rankings.player_id
WHERE CONCAT(playerID.name_first, ' ', playerID.name_last) NOT IN ('Novak Djokovic', 'Rafael Nadal', 'Roger Federer', 'Andy Murray')
	AND rankings.rank < 4
GROUP BY 
	rankings.rank,
	CONCAT(playerID.name_first, ' ', playerID.name_last)

	
----------------------------------------------------------------------------
-----------Showing when each of the no1 players were ranked first-----------
----------------------------------------------------------------------------

-- showing when Andy Murray was first
-- to check for data of Djokovic, Federer, Nadal, just change the data inside the WHERE clause

SELECT rankings.ranking_date,
	rankings.rank,
	CONCAT(playerID.name_first, ' ', playerID.name_last) AS full_name,
	rankings.points
FROM atp_players AS playerID
JOIN atp_rankings_10s AS rankings
ON playerID.player_id = rankings.player_id
WHERE CONCAT(playerID.name_first, ' ', playerID.name_last) = 'Andy Murray' 
	AND rankings.rank = 1
ORDER BY ranking_date

	
----------------------------------------------------------------------------
-----------Showing the MAX and MIN points of each no.1 player---------------
----------------------------------------------------------------------------

SELECT
    rankings.rank AS ranking,
	CONCAT(playerID.name_first, ' ', playerID.name_last) AS full_name,
    MAX(rankings.points) AS max_points,
    MIN(rankings.points) AS min_points
FROM atp_players AS playerID
JOIN atp_rankings_10s AS rankings
ON playerID.player_id = rankings.player_id
WHERE rankings.rank = 1 
GROUP BY rankings.rank, CONCAT(playerID.name_first, ' ', playerID.name_last);


----------------------------------------------------------------------------
--------------------------Ranking dates analysis----------------------------
----------------------------------------------------------------------------

-- converting ranking_date into desired DATE format

UPDATE atp_rankings_10s
SET ranking_date = FORMAT(CAST(ranking_date AS date), 'yyyy-MM-dd')


-- displaying the first and last ranking update

SELECT MIN(ranking_date) AS first_ranking_date,
	   MAX(ranking_date) AS last_ranking_date
FROM atp_rankings_10s


-- days observed (days betwenn first and last rank update)

SELECT DATEDIFF(DAY, MIN(ranking_date), MAX(ranking_date)) AS days_observed
FROM atp_rankings_10s


----------------------------------------------------------------------------
------------------------------Days ranked no.1------------------------------
----------------------------------------------------------------------------

WITH RankedData AS (
    SELECT
        CONCAT(playerID.name_first, ' ', playerID.name_last) AS full_name,
        ranking_date,
        rank,
		DATEDIFF(DAY, ranking_date, LEAD(ranking_date) OVER(ORDER BY ranking_date)) AS days_no_1
    FROM atp_players AS playerID
    JOIN atp_rankings_10s AS rankings
    ON playerID.player_id = rankings.player_id
    WHERE rank = 1
)
SELECT
    full_name,
    SUM(days_no_1) AS days_ranked_1st
FROM RankedData
GROUP BY full_name
ORDER BY SUM(days_no_1) DESC;



	

-- ATP rankings are cosindered to be weekly rankings due to them being updated weekly (at the end of the week) when the tournaments end
-- the only exceptions are when there are no tournamets during the week
-- the below analysis will display:
-- 1. the count of rank updates, 
-- 2. the number of weeks observed
-- 3. determine what were the dates when ATP rankings weren't updated weekly?


----------------------------------------------------------------------------
--------------------------Count of rank updates-----------------------------
----------------------------------------------------------------------------

SELECT COUNT(DISTINCT(ranking_date)) number_of_rank_updates
FROM atp_rankings_10s


----------------------------------------------------------------------------
----------------Determining the number of weeks observed--------------------
----------------------------------------------------------------------------

SELECT DATEDIFF(WEEK,MIN(ranking_date), MAX(ranking_date)) weeks_observed
FROM atp_rankings_10s


----------------------------------------------------------------------------
---------------Dates when rankings weren't updated weekly-------------------
----------------------------------------------------------------------------

-- using CTE
----------------------------------------------------------------------------
WITH CTE AS 
(
    SELECT ROW_NUMBER() OVER (ORDER BY ranking_date) AS row_number, 
	       ranking_date
    FROM atp_rankings_10s
)
SELECT CTE1.ranking_date AS currentdate, 
       CTE2.ranking_date AS next_date
FROM CTE AS CTE1
JOIN CTE AS CTE2 
ON CTE1.row_number = CTE2.row_number - 1
WHERE DATEDIFF(DAY, CTE1.ranking_date, CTE2.ranking_date) > 7



-- using Temp Tables
----------------------------------------------------------------------------
CREATE TABLE #temp_table 
(
	row_number int,
	ranking_date date,
)			   		 

INSERT INTO #temp_table
    SELECT ROW_NUMBER() OVER (ORDER BY ranking_date) AS row_number, 
	       ranking_date
    FROM atp_rankings_10s

SELECT t1.ranking_date AS currentdate, 
       t2.ranking_date AS next_date
FROM #temp_table AS t1
JOIN #temp_table AS t2
ON t1.row_number = t2.row_number - 1
WHERE DATEDIFF(DAY, t1.ranking_date, t2.ranking_date) > 7






-----------------------------------------------------------------------------
--------------------Players & ranking dates analysis-------------------------
-----------------------------------------------------------------------------


-----------------------------------------------------------------------------
----------Showing the data about a player when he became no.1 rank-----------
-----------------------------------------------------------------------------

-- the following query will show the date when a player became 1st, their previous rank, and the previous ranking date

WITH CTE AS
(
	SELECT
		rankings.rank AS rank,
		CONCAT(playerID.name_first, ' ', playerID.name_last) AS full_name,
		rankings.ranking_date AS ranking_date,
		LAG(rankings.rank) OVER (PARTITION BY CONCAT(playerID.name_first, ' ', playerID.name_last) ORDER BY rankings.ranking_date) AS prev_rank,
		LAG(rankings.ranking_date) OVER (PARTITION BY CONCAT(playerID.name_first, ' ', playerID.name_last) ORDER BY rankings.ranking_date) AS prev_rank_date
	FROM atp_players AS playerID
	JOIN atp_rankings_10s AS rankings
	ON playerID.player_id = rankings.player_id
)
SELECT rank,
       full_name,
	   ranking_date,
	   prev_rank,
	   prev_rank_date
FROM CTE
WHERE rank = 1
AND prev_rank <> 1
ORDER BY ranking_date


-----------------------------------------------------------------------------
--how many weekly rankings did each of the no 1. ranked player stay at no.1--
-----------------------------------------------------------------------------

SELECT 
	CONCAT(playerID.name_first, ' ', playerID.name_last) AS full_name,
	SUM(CASE 
		WHEN rankings.rank = 1 
		THEN 1
		ELSE 0
		END
	    ) AS weekly_ranks_as_no1
FROM atp_players AS playerID
JOIN atp_rankings_10s AS rankings
ON playerID.player_id = rankings.player_id
WHERE rankings.rank = 1
GROUP BY CONCAT(playerID.name_first, ' ', playerID.name_last)
ORDER BY weekly_ranks_as_no1 DESC


--------------------------------------------------------------------------------------------------------------
---how many weekly rankings did the rest of players(besides Djokovic, Federer, Murray, Nadal) stay at top 3---
--------------------------------------------------------------------------------------------------------------

SELECT 
	rankings.rank,
	CONCAT(playerID.name_first, ' ', playerID.name_last) AS full_name,
	SUM(CASE 
		WHEN rankings.rank < 4 
		THEN 1
		ELSE 0
		END
	    ) AS total_weeks_in_top3
FROM atp_players AS playerID
JOIN atp_rankings_10s AS rankings
ON playerID.player_id = rankings.player_id
WHERE CONCAT(playerID.name_first, ' ', playerID.name_last) NOT IN ('Novak Djokovic', 'Rafael Nadal', 'Roger Federer', 'Andy Murray')
AND rankings.rank < 4
GROUP BY 
	rankings.rank,
	CONCAT(playerID.name_first, ' ', playerID.name_last)
ORDER BY total_weeks_in_top3 DESC


----------------------------------------------------------------------------
--------How many weeks did any player spend at any given position?----------
----------------------------------------------------------------------------

-- i.e. how many weeks was Stan Wawrinka ranked 4th

SELECT 
	CONCAT(playerID.name_first, ' ', playerID.name_last) AS full_name,
	SUM(CASE 
		WHEN rankings.rank = 4
		THEN 1
		ELSE 0
		END
		) AS weekly_rank_4th
FROM atp_players AS playerID
JOIN atp_rankings_10s AS rankings
ON playerID.player_id = rankings.player_id
WHERE CONCAT(playerID.name_first, ' ', playerID.name_last) = 'Stan Wawrinka' 
AND rankings.rank = 4
GROUP BY CONCAT(playerID.name_first, ' ', playerID.name_last)


----------------------------------------------------------------------------
--What were the first and last dates that every player ranked as number 1?--
----------------------------------------------------------------------------

SELECT
    CONCAT(playerID.name_first, ' ', playerID.name_last) AS full_name,
    MIN(rankings.ranking_date) AS first_date,
    MAX(rankings.ranking_date) AS last_date
FROM atp_players AS playerID
JOIN atp_rankings_10s AS rankings ON playerID.player_id = rankings.player_id
WHERE rankings.rank = 1
GROUP BY CONCAT(playerID.name_first, ' ', playerID.name_last)


----------------------------------------------------
--------AVG, MIN, MAX POINTS, PERCENTILES-----------
----------------------------------------------------

-- Average, max, and min points that no.1 rank had

SELECT 
	AVG(rankings.points) AS avg_points_rank1,
	MAX(rankings.points) AS max_points_rank1,
	MIN(rankings.points) AS min_points_rank1
FROM atp_players AS playerID
JOIN atp_rankings_10s AS rankings
ON playerID.player_id = rankings.player_id
WHERE rank = 1


	
-- max, min points that every no.1 player had

SELECT 
	CONCAT(playerID.name_first, ' ', playerID.name_last) AS full_name,
	MAX(rankings.points) AS max_points_rank1,
	MIN(rankings.points) AS min_points_rank1
FROM atp_players AS playerID
JOIN atp_rankings_10s AS rankings
ON playerID.player_id = rankings.player_id
WHERE rank = 1
GROUP BY CONCAT(playerID.name_first, ' ', playerID.name_last)



-- max points of each player, the dates with max points, ordered by points descending

SELECT  CONCAT(playerID.name_first, ' ', playerID.name_last) AS full_name,
	    rankings.points,
		rankings.ranking_date
FROM atp_players AS playerID
JOIN atp_rankings_10s AS rankings
ON playerID.player_id = rankings.player_id
WHERE rankings.points =
	(
		SELECT MAX(points)
		FROM atp_rankings_10s
		WHERE player_id = rankings.player_id
		GROUP BY player_id
	)
ORDER BY rankings.points DESC



-- 99th percentile of points at the observed date

SELECT
    DISTINCT(rankings.ranking_date),
    PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rankings.points) OVER () AS percentile_99_points
FROM atp_players AS playerID
JOIN atp_rankings_10s AS rankings
ON playerID.player_id = rankings.player_id
WHERE
    ranking_date = '2010-01-04'



----------------------------------------------------
------------------CREATING VIEWS--------------------
----------------------------------------------------

CREATE VIEW No1_ranked_players AS
SELECT 
	CONCAT(playerID.name_first, ' ', playerID.name_last) AS full_name
FROM atp_players AS playerID
JOIN atp_rankings_10s AS rankings
ON playerID.player_id = rankings.player_id
WHERE rank = 1
GROUP BY 	
	CONCAT(playerID.name_first, ' ', playerID.name_last)



CREATE VIEW First_and_last_no1_date AS
SELECT
    CONCAT(playerID.name_first, ' ', playerID.name_last) AS full_name,
    MIN(rankings.ranking_date) AS first_date,
    MAX(rankings.ranking_date) AS last_date
FROM atp_players AS playerID
JOIN atp_rankings_10s AS rankings ON playerID.player_id = rankings.player_id
WHERE rankings.rank = 1
GROUP BY CONCAT(playerID.name_first, ' ', playerID.name_last)
