/*
This part of the project consists of two parts:
1. Analysis of matches played (matches played/won, finals played/won)
2. Deeper analysis consisting of: analysis of aces and players with most aces
                                : analysis of Top Players data (The Big Three + Andy Murray) per surface played

We will create a table where we will summarize all the data needed for further analysis.
Columns in the new table will be as follows: Player ID, Player Name, Matches Played, Matches Won, Matches Lost, 
                                             Finals Played, Finals Won, Total Aces
*/

-- Before creating a new table, lets see the players that played the most matches

WITH PlayerMatches AS 
(
    SELECT player_name,
	       player_id 
    FROM 
	(
        SELECT winner_name AS player_name,
		       winner_id AS player_id 
		FROM ATP_Matches
        UNION ALL
        SELECT loser_name AS player_name, 
		       loser_id AS player_id
		FROM ATP_Matches
    ) AS CombinedData
)
SELECT player_id,
       player_name,
	   COUNT(*) AS MatchesPlayed
FROM PlayerMatches 
GROUP BY player_id,player_name
ORDER BY MatchesPlayed DESC;



---------------------------------------------------------------------------
----------------------------Creating a new table---------------------------
---------------------------------------------------------------------------
-- to start, Player ID, Player Name and Matches played will be inserted into the table

CREATE TABLE ATP_Matches_Summary
(
Player_Id numeric,
Player_Name nvarchar(255),
Matches_Played numeric
)
INSERT INTO ATP_Matches_Summary
	SELECT player_id, 
		   player_name,
		   COUNT(player_name)
	FROM 
	(
		  SELECT winner_name AS player_name,
				 winner_id AS player_id 
		  FROM ATP_Matches
		  UNION ALL
		  SELECT loser_name AS player_name, 
				 loser_id AS player_id
		  FROM ATP_Matches
	) AS hehe
	GROUP BY player_id, 
			 player_name
	ORDER BY COUNT(player_name) DESC



---------------------------------------------------------------------------
-------------------------------Matches Won---------------------------------
---------------------------------------------------------------------------

ALTER TABLE ATP_Matches_Summary
ADD Matches_Won numeric

UPDATE ATP_Matches_Summary
SET Matches_Won = 
(
	SELECT COUNT(winner_name)
	FROM ATP_Matches
	WHERE winner_name = ATP_Matches_Summary.Player_Name
)



---------------------------------------------------------------------------
-------------------------------Matches Lost--------------------------------
---------------------------------------------------------------------------

ALTER TABLE ATP_Matches_Summary
ADD Matches_Lost numeric

UPDATE ATP_Matches_Summary
SET Matches_Lost = 
(
	SELECT COUNT(loser_name)
	FROM ATP_Matches
	WHERE loser_name = ATP_Matches_Summary.Player_Name
)



---------------------------------------------------------------------------
-------------------------------Finals Played-------------------------------
---------------------------------------------------------------------------

ALTER TABLE ATP_Matches_Summary
ADD Finals_Played numeric

UPDATE ATP_Matches_Summary
SET Finals_Played = 
(
	SELECT COUNT(player_name)
	FROM 
	(
		  SELECT winner_name AS player_name,
				 winner_id AS player_id 
		  FROM ATP_Matches
		  WHERE round = 'F'
		  UNION ALL
		  SELECT loser_name AS player_name, 
				 loser_id AS player_id
		  FROM ATP_Matches
		  WHERE round = 'F'
	) AS hehe
	WHERE player_name = ATP_Matches_Summary.Player_Name
)



---------------------------------------------------------------------------
-------------------------------Finals Won----------------------------------
---------------------------------------------------------------------------

ALTER TABLE ATP_Matches_Summary
ADD Finals_Won numeric

UPDATE ATP_Matches_Summary
SET Finals_Won =
(
	SELECT COUNT(winner_name)
	FROM ATP_Matches
	WHERE round = 'F'
	AND winner_name = ATP_Matches_Summary.Player_Name
	GROUP BY winner_name
)



---------------------------------------------------------------------------
-------------------------------Total aces----------------------------------
---------------------------------------------------------------------------

ALTER Table ATP_Matches_Summary
ADD Total_Aces numeric

UPDATE ATP_Matches_Summary
SET Total_Aces =
(
SELECT SUM(ace)
FROM
(
	SELECT winner_name AS player_name,
		   w_ace AS ace
	FROM ATP_Matches
	UNION ALL
	SELECT loser_name AS player_name,
		   l_ace AS ace
	FROM ATP_Matches
) AS s
WHERE s.player_name = ATP_Matches_Summary.Player_Name
)



---------------------------------------------------------------------------
--------------DEEPER ANALYSIS OF ACES AND PLAYERS WITH MOST ACES-----------
---------------------------------------------------------------------------

/*
The following part will analyze: 
players with most average aces per match,
their height 
*/

---------------------------------------------------------------------------
----------------------Total Aces and AVG Aces per match--------------------
---------------------------------------------------------------------------

DROP TABLE IF EXISTS ATP_Aces
CREATE TABLE ATP_Aces
(
Player_Id numeric,
Player_Name nvarchar(255),
Matches_Played numeric,
Total_Aces numeric,
AVG_Aces float
)
INSERT INTO ATP_Aces
	SELECT player_id,
		   player_name,
		   COUNT(player_name) AS matches_played,
		   SUM(ace) AS total_aces,
		   ROUND((SUM(ace)/COUNT(player_name)), 2) AS avg_aces_per_match
	FROM
	(
		SELECT winner_id AS player_id,
			   winner_name AS player_name,
			   w_ace AS ace
		FROM ATP_Matches
		UNION ALL
		SELECT loser_id AS player_id,
			   loser_name AS player_name,
			   l_ace AS ace
		FROM ATP_Matches
	) AS s
	GROUP BY s.player_id,
			 s.player_name
	HAVING COUNT(player_name) > 100
	ORDER BY avg_aces_per_match DESC



---------------------------------------------------------------------------
--------------------------Height and Height ranges-------------------------
---------------------------------------------------------------------------

SELECT DISTINCT a.*,
       b.Height,
	   CASE WHEN b.Height <170 THEN '<170'
	        WHEN b.Height BETWEEN 170 AND 179 THEN '170-179'
			WHEN b.Height BETWEEN 180 AND 189 THEN '180-189'
			WHEN b.Height BETWEEN 190 AND 199 THEN '190-199'
			WHEN b.Height > 200 THEN '200+'
		END AS Height_ranges
FROM ATP_Aces AS a
LEFT OUTER JOIN ATP_Ranks AS b
ON a.Player_Id = b.Player_id
ORDER BY a.AVG_Aces DESC



---------------------------------------------------------------------------
-------------Height range of TOP 20 players with most AVG aces-------------
---------------------------------------------------------------------------

WITH CTE AS
(
	SELECT DISTINCT a.*,
		   b.Height,
		   CASE WHEN b.Height <170 THEN '<170'
				WHEN b.Height BETWEEN 170 AND 179 THEN '170-179'
				WHEN b.Height BETWEEN 180 AND 189 THEN '180-189'
				WHEN b.Height BETWEEN 190 AND 199 THEN '190-199'
				WHEN b.Height > 200 THEN '200+'
			END AS Height_ranges
	FROM ATP_Aces AS a
	LEFT OUTER JOIN ATP_Ranks AS b
	ON a.Player_Id = b.Player_id
),
CTE2 AS
(
	SELECT Height_ranges,
		   DENSE_RANK() OVER(ORDER BY AVG_Aces DESC) AS Ace_rank
	FROM CTE
)
SELECT Height_ranges,
       COUNT(Height_ranges)
FROM CTE2
WHERE Ace_rank <= 20
GROUP BY Height_ranges





---------------------------------------------------------------------------
-----------------------------SURFACE ANALYSIS------------------------------
---------------------------------------------------------------------------

/* 
The following part will dive into analysis of matches per surface played
for Novak Djokovic, Roger Federer, Rafael Nadal, Andy Murray
*/

-- let's start with analyzing the amount matches played per surface by the top 4 players

WITH PlayerMatches AS 
(
    SELECT player_name,
	       player_id,
		   surface
    FROM 
	(
        SELECT winner_name AS player_name,
		       winner_id AS player_id,
			   surface
		FROM ATP_Matches
        UNION ALL
        SELECT loser_name AS player_name, 
		       loser_id AS player_id,
			   surface
		FROM ATP_Matches
    ) AS CombinedData
)
SELECT player_id,
       player_name,
	   surface,
	   COUNT(*) AS MatchesPlayed
FROM PlayerMatches 
WHERE player_name IN ('Novak Djokovic', 'Roger Federer', 'Andy Murray', 'Rafael Nadal')
GROUP BY player_id,player_name, surface
ORDER BY MatchesPlayed DESC;


---------------------------------------------------------------------------
------------------CREATING A TABLE FOR SURFACE ANALYSIS--------------------
---------------------------------------------------------------------------

-- firstly, Player ID, Player Name, Surface, and Matches Played will be inserted into the table

CREATE TABLE ATP_Surface
(
Player_Id numeric,
Player_Name nvarchar(255),
Surface nvarchar(255),
Matches_Played numeric
)
INSERT INTO ATP_Surface
	SELECT player_id, 
		   player_name,
		   surface,
		   COUNT(player_name)
    FROM 
	(
        SELECT winner_name AS player_name,
		       winner_id AS player_id,
			   surface
		FROM ATP_Matches
        UNION ALL
        SELECT loser_name AS player_name, 
		       loser_id AS player_id,
			   surface
		FROM ATP_Matches
    ) AS CombinedData
	WHERE player_name IN ('Novak Djokovic', 'Roger Federer', 'Andy Murray', 'Rafael Nadal')
	GROUP BY player_id, 
			 player_name,
			 surface



---------------------------------------------------------------------------
-------------------------------Matches Won---------------------------------
---------------------------------------------------------------------------

ALTER TABLE ATP_Surface
ADD Matches_Won numeric

UPDATE ATP_Surface
SET Matches_Won = 
(
	SELECT COUNT(winner_name)
	FROM ATP_Matches
	WHERE winner_name = ATP_Surface.Player_Name
	AND Surface = ATP_Surface.Surface
	AND winner_name IN ('Novak Djokovic', 'Roger Federer', 'Andy Murray', 'Rafael Nadal')
)



---------------------------------------------------------------------------
-----------------------------Win Percentage--------------------------------
---------------------------------------------------------------------------

ALTER TABLE ATP_Surface
ADD Win_Percentage float

UPDATE ATP_Surface
SET Win_Percentage = ROUND((100*CAST(Matches_Won AS float))/(CAST(Matches_Played AS FLOAT)),2)
FROM ATP_Surface



---------------------------------------------------------------------------
-------------------------Best Player per surface---------------------------
---------------------------------------------------------------------------

WITH CTE AS
(
	SELECT Player_Id,
		   Player_Name,
		   Surface,
		   Matches_Played,
		   Matches_Won, 
		   Win_Percentage,
		   DENSE_RANK() OVER(PARTITION BY Surface ORDER BY Win_Percentage DESC) AS Surface_Win_Rank
	FROM ATP_Surface
)
SELECT Player_Name,
       Surface,		   
	   Matches_Played,
	   Matches_Won,
	   Win_Percentage 
FROM CTE 
WHERE Surface_Win_Rank = 1
ORDER BY Matches_Played DESC
