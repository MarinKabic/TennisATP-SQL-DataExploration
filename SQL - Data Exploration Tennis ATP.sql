-- ATP Player rankings in 2010s Data Exploration

/* 
To Improve readability, we will create a new Table where we will join all the data from both tables
and we will join First_Name and Last_Name into one column named 'Player_Name'
*/

---------------------------------------------------------------------------
------Creating a table where data from both tables will be joined----------
---------------------------------------------------------------------------

CREATE TABLE ATP_Ranks
(
Ranking_date date,
Player_Rank numeric,
Player_Name nvarchar(255),
Points numeric,
Hand nvarchar(255),
DOB numeric,
IOC nvarchar(255),
Height numeric,
Player_id numeric
)

INSERT INTO ATP_Ranks
SELECT r.ranking_date,
       r.rank,
       CONCAT(p.name_first, ' ', p.name_last) AS full_name,
       r.points,
       p.hand,
       p.dob,
       p.ioc,
       p.height,
       p.player_id 
FROM atp_players AS p
JOIN atp_rankings_10s AS r
ON p.player_id = r.player_id
ORDER BY r.ranking_date

-- view the new table
SELECT *
FROM ATP_Ranks


	
---------------------------------------------------------------------------
----------List all the names of no. 1. players during the period-----------
---------------------------------------------------------------------------

SELECT Player_Name
FROM ATP_Ranks
WHERE Player_Rank = 1
GROUP BY Player_Name



----------------------------------------------------------------------------
--------------------------------Days observed-------------------------------
----------------------------------------------------------------------------

SELECT DATEDIFF(DAY, MIN(Ranking_date), MAX(Ranking_date)) AS days_observed
FROM ATP_Ranks

----------------------------------------------------------------------------
-------------------Who has spent the most days at rank 1?-------------------
----------------------------------------------------------------------------

WITH RankData AS 
(
    SELECT
        Player_Name,
        Ranking_date,
        Player_Rank,
	DATEDIFF(DAY, Ranking_date, LEAD(Ranking_date) OVER(ORDER BY Ranking_date)) AS days_diff
    FROM ATP_Ranks
    WHERE Player_Rank = 1
)
SELECT
    Player_Name,
    SUM(days_diff) AS Days_ranked_1st
FROM RankData
GROUP BY Player_Name
ORDER BY SUM(days_diff) DESC;



----------------------------------------------------------------------------
--------------Analysis of top ranked players during the period--------------
----------------------------------------------------------------------------

----------------------------------------------------------------------------
------------------MAX and MIN points of each no.1 player--------------------
----------------------------------------------------------------------------

SELECT Player_Rank,
       Player_Name,
       MAX(Points) AS max_points,
       MIN(Points) AS min_points
FROM ATP_Ranks
WHERE Player_Rank = 1 
GROUP BY Player_Rank,
         Player_Name


	
----------------------------------------------------------------------------
-------------------AVG yearly rank of each no.1 player----------------------
----------------------------------------------------------------------------

SELECT Player_Name,
       YEAR(Ranking_date) AS Ranking_Year,
       AVG(Player_Rank) AS Average_Yearly_Rank
FROM ATP_Ranks
WHERE Player_Name IN ('Novak Djokovic', 'Roger Federer', 'Rafael Nadal', 'Andy Murray')
GROUP BY Player_Name,
       YEAR(Ranking_date)
ORDER BY Player_Name



----------------------------------------------------------------------------
--What were the first and last dates that every player ranked as number 1?--
----------------------------------------------------------------------------

SELECT
    Player_Name,
    MIN(Ranking_date) AS first_date,
    MAX(Ranking_date) AS last_date
FROM ATP_Ranks
WHERE Player_Rank = 1
GROUP BY Player_Name



---------------------------------------------------------------------------
---------------------Other top ranked players analysis---------------------
---------------------------------------------------------------------------
-- since only 4 players were no.1 during that time, lets see if anybody besides them was top 3 during the period

-- lets see all the other players who were ranked top 3 besides the mentioned 4 players 

SELECT 
	Player_Rank,
	Player_Name
FROM ATP_Ranks
WHERE Player_Name NOT IN ('Novak Djokovic', 'Rafael Nadal', 'Roger Federer', 'Andy Murray')
      AND Player_Rank <= 3
GROUP BY 
	Player_Rank,
	Player_Name


	
---------------------------------------------------------------------------
--top 10 players with the highest average ranking over the entire period?--
---------------------------------------------------------------------------

-- Only players who were ranked for all the 10 years observed will be considered

WITH Top10 AS
(
	SELECT Player_Name,
	       AVG(Player_Rank) AS Average_Rank,
	       DENSE_RANK() OVER(ORDER BY AVG(Player_Rank)) AS cte_rank
	FROM ATP_Ranks
	GROUP BY Player_Name
	HAVING COUNT(DISTINCT YEAR(Ranking_date)) = 10
)
SELECT Player_Name,
       Average_Rank
FROM Top10 
WHERE cte_rank <= 10

	

---------------------------------------------------------------------------
----------Show players which had the average ranking inside TOP 10---------
---------------------------------------------------------------------------

SELECT Player_Name,
       AVG(Player_Rank) AS Average_Rank
FROM ATP_Ranks
GROUP BY Player_Name
HAVING AVG(Player_Rank) < 10



----------------------------------------------------------------------------
--------------------------Ranking dates analysis----------------------------
----------------------------------------------------------------------------

-- converting ranking_date into desired DATE format
	
UPDATE atp_rankings_10s
SET ranking_date = FORMAT(CAST(ranking_date AS date), 'yyyy-MM-dd')
-- atp_rankings_10s table wont be used, therefore the above query is for demonstration purposes only

-- displaying the first and last ranking update
	
SELECT MIN(Ranking_date) AS first_ranking_date,
       MAX(Ranking_date) AS last_ranking_date
FROM ATP_Ranks


	
-- ATP rankings are cosindered to be weekly rankings due to them being updated weekly (at the end of the week) when the tournaments end
-- the only exceptions are when there are no tournamets during the week
-- the below analysis will display:
-- 1. the count of rank updates, 
-- 2. the number of weeks observed
-- 3. determine what were the dates when ATP rankings weren't updated weekly?

----------------------------------------------------------------------------
--------------------------Count of rank updates-----------------------------
----------------------------------------------------------------------------

SELECT COUNT(DISTINCT(Ranking_date)) AS number_of_rank_updates
FROM ATP_Ranks



----------------------------------------------------------------------------
----------------Determining the number of weeks observed--------------------
----------------------------------------------------------------------------

SELECT DATEDIFF(WEEK, MIN(Ranking_date), MAX(Ranking_date)) AS weeks_observed
FROM ATP_Ranks



----------------------------------------------------------------------------
---------------Dates when rankings weren't updated weekly-------------------
----------------------------------------------------------------------------

-- using CTE
----------------------------------------------------------------------------
WITH CTE AS 
(
    SELECT ROW_NUMBER() OVER (ORDER BY Ranking_date) AS row_numb, 
	   ranking_date
    FROM ATP_Ranks
)
SELECT CTE1.ranking_date AS currentdate, 
       CTE2.ranking_date AS next_date
FROM CTE AS CTE1
JOIN CTE AS CTE2 
ON CTE1.row_numb = CTE2.row_numb - 1
WHERE DATEDIFF(DAY, CTE1.ranking_date, CTE2.ranking_date) > 7


-- using Temp Tables
----------------------------------------------------------------------------
CREATE TABLE #temp_table 
(
	row_numb int,
	ranking_date date,
)			   		 

INSERT INTO #temp_table
    SELECT ROW_NUMBER() OVER (ORDER BY Ranking_date) AS row_numb, 
	   Ranking_date
    FROM ATP_Ranks

SELECT t1.ranking_date AS currentdate, 
       t2.ranking_date AS next_date
FROM #temp_table AS t1
JOIN #temp_table AS t2
ON t1.row_numb = t2.row_numb - 1
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
		Player_Rank,
		Player_Name,
		Ranking_date,
		LAG(Player_Rank) OVER (PARTITION BY Player_Name ORDER BY Ranking_date) AS prev_rank,
		LAG(Ranking_date) OVER (PARTITION BY Player_Name ORDER BY Ranking_date) AS prev_rank_date
	FROM ATP_Ranks
)
SELECT Player_Rank,
       Player_Name,
       Ranking_date,
       prev_rank,
       prev_rank_date
FROM CTE
WHERE Player_Rank = 1
AND prev_rank <> 1
ORDER BY Ranking_date



--------------------------------------------------------------------------------------------------------------
---how many weekly rankings did the rest of players(besides Djokovic, Federer, Murray, Nadal) stay at top 3---
--------------------------------------------------------------------------------------------------------------

SELECT 
	Player_Rank,
	Player_Name,
	SUM(
	     CASE 
		WHEN Player_Rank <= 3 
		THEN 1
		ELSE 0
		END
	    ) AS total_weeks_in_top3
FROM ATP_Ranks
WHERE Player_Name NOT IN ('Novak Djokovic', 'Roger Federer', 'Andy Murray', 'Rafael Nadal')
AND Player_Rank <= 3 
GROUP BY 
	Player_Rank,
	Player_Name
ORDER BY total_weeks_in_top3 DESC


	
----------------------------------------------------------------------------
--------How many weeks did any player spend at any given position?----------
----------------------------------------------------------------------------

--i.e. how many weeks was Novak Djokovic ranked 4th

SELECT 
	Player_Name,
	SUM(
	     CASE 
		WHEN Player_Rank = 4
		THEN 1
		ELSE 0
		END
	    ) AS weekly_rank_4th
FROM ATP_Ranks
WHERE Player_Name = 'Novak Djokovic' 
AND Player_Rank = 4
GROUP BY Player_Name



----------------------------------------------------
--------AVG, MIN, MAX POINTS, PERCENTILES-----------
----------------------------------------------------

-- Average, max, and min points that no.1 rank had

SELECT 
	ROUND(AVG(Points), 2) AS avg_points_rank1,
	MAX(Points) AS max_points_rank1,
	MIN(Points) AS min_points_rank1
FROM ATP_Ranks
WHERE Player_Rank = 1



-- max, min points that every no.1 player had

SELECT 
	Player_Name,
	MAX(Points) AS max_points_rank1,
	MIN(Points) AS min_points_rank1
FROM ATP_Ranks
WHERE Player_Rank = 1
GROUP BY Player_Name



-- 99th percentile of points at the observed date

SELECT
    DISTINCT(Ranking_date),
    PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY Points) OVER () AS percentile_99_points
FROM ATP_Ranks
WHERE
    ranking_date = '2010-01-04'

	

----------------------------------------------------
------------------CREATING VIEWS--------------------
----------------------------------------------------

CREATE VIEW No1_ranked_players AS
SELECT Player_Name
FROM ATP_Ranks
WHERE Player_Rank = 1
GROUP BY Player_Name


CREATE VIEW FirstAndLast_no1_date AS
SELECT
    Player_Name,
    MIN(Ranking_date) AS first_date,
    MAX(Ranking_date) AS last_date
FROM ATP_Ranks
WHERE Player_Rank = 1
GROUP BY Player_Name

