/* 
ATP Player rankings in 2010s Data Exploration

Skills used: Aggregate functions, Windows functions, converting data types, CTE's, Temp tables, creating views
*/


---------------------------------------------------------------------------
-----glance at the data from ATP_players and ATP_Rankings_in 2010's--------
---------------------------------------------------------------------------

SELECT *
FROM atp_players

SELECT DISTINCT(ranking_date)
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
--Which player held the highest ranking for the longest continuous period?--
----------------------------------------------------------------------------

SELECT TOP (1)
    CONCAT(playerID.name_first, ' ', playerID.name_last) AS full_name,
    MIN(CAST(ranking_date AS DATE)) AS start_date,
    MAX(CAST(ranking_date AS DATE)) AS end_date,
    DATEDIFF(DAY, MAX(CAST(ranking_date AS DATE)), MIN(CAST(ranking_date AS DATE))) + 1 AS Continuous_no_1
FROM atp_players AS playerID
JOIN atp_rankings_10s AS rankings ON playerID.player_id = rankings.player_id
WHERE rankings.rank = 1
GROUP BY playerID.player_id, CONCAT(playerID.name_first, ' ', playerID.name_last)
ORDER BY Continuous_no_1 DESC



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
WHERE CONCAT(playerID.name_first, ' ', playerID.name_last) <> 'Novak Djokovic' 
	AND CONCAT(playerID.name_first, ' ', playerID.name_last) <> 'Rafael Nadal' 
	AND CONCAT(playerID.name_first, ' ', playerID.name_last) <> 'Roger Federer' 
	AND CONCAT(playerID.name_first, ' ', playerID.name_last) <> 'Andy Murray' 
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
--------------------------Ranking dates analysis----------------------------
----------------------------------------------------------------------------

-- first we will need to convert ranking_date into DATE format

UPDATE atp_rankings_10s
SET ranking_date = CONVERT(DATE, ranking_date, 112)


-- displaying the first and last ranking update

SELECT MIN(ranking_date) AS first_ranking_date,
	   MAX(ranking_date) AS last_ranking_date
FROM atp_rankings_10s


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

WITH CTE AS (
    SELECT ROW_NUMBER() OVER (ORDER BY ranking_date) AS row_number, ranking_date
    FROM atp_rankings_10s
)
SELECT CTE1.ranking_date AS currentdate, CTE2.ranking_date AS next_date
FROM CTE AS CTE1
JOIN CTE AS CTE2 
ON CTE1.row_number = CTE2.row_number - 1
WHERE DATEDIFF(DAY, CTE1.ranking_date, CTE2.ranking_date) > 7



-----------------------------------------------------------------------------
--------------------Players & ranking dates analysis-------------------------
-----------------------------------------------------------------------------

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
WHERE CONCAT(playerID.name_first, ' ', playerID.name_last) <> 'Novak Djokovic' 
	AND CONCAT(playerID.name_first, ' ', playerID.name_last) <> 'Rafael Nadal' 
	AND CONCAT(playerID.name_first, ' ', playerID.name_last) <> 'Roger Federer' 
	AND CONCAT(playerID.name_first, ' ', playerID.name_last) <> 'Andy Murray' 
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
---------------AVG, MIN, MAX POINTS-----------------
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



-- max, min points that every no.1 rank had

SELECT 
	CONCAT(playerID.name_first, ' ', playerID.name_last) AS full_name,
	MAX(rankings.points) AS max_points_rank1,
	MIN(rankings.points) AS min_points_rank1
FROM atp_players AS playerID
JOIN atp_rankings_10s AS rankings
ON playerID.player_id = rankings.player_id
WHERE rank = 1
GROUP BY CONCAT(playerID.name_first, ' ', playerID.name_last)
