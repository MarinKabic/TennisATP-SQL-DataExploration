# TennisATP-SQL-DataExploration

In the recent months/years, after more than a decade, the players at the top spots of ATP Rankings have started to change. The male tennis division was dominated for over a decade by: Novak Djokovic, Roger Federer and Rafael Nadal. Out of the mentioned players, only Novak Djokovic is actively playing and holding the top ranks. Roger Federer has retired in 2021. Rafael Nadals recent playing years were mostly injury driven and as of 25.10.2023. Nadal is ranked 242 having played only 4 matches in 2023. That being said, we can say the 2020's mark the end of an era, an era which was dominated by The Big Three.

So in this project, we will analyze ATP Players and their rankings in the 2010's (2010-2019). 

Since the observed decade has mostly been dominated by The Big Three, this project will mostly focus on players who were at the top of ATP rankings.



## Data Resources:
All the data that is analyzed is from https://github.com/JeffSackmann/tennis_atp published by: https://github.com/JeffSackmann
Datasets used: 
> „atp_rankings_10s.csv“ and „atp_players.csv“ to analyze player rankings over the period

> from „atp_matches_2010.csv“ to  „atp_matches_2019.csv“ to analyze the data about played matches, finals, surface

## Tools used for data analysis:
Python – for combining all the 10 atp_matches_201x. csv files into one consolidated dataset

MS SQL Server – for all the data analysis steps (cleaning if needed & analysis)

## Data Analysis:
For the main part of the analysis, i decided to analyze the data to give me the following insights:

**Some questions that this project provide an answer to:**

• 1. Which players were ranked 1st in the observed period?

      Hypothesis: N. Djokovic, R. Federer, R. Nadal & A. Murray were the only players ranked 1st in the observed period
      
• 2. Who was ranked 1st the longest?

      Hypothesis: N. Djokovic was ranked 1st the longest
      
• 3. Who has won the most matches and most tournaments?

      Hypothesis: N. Djokovic won the most matches and tournaments   
      
• 4. Who was the best player per surface?

      Hypothesis: R. Nadal was the best player on Clay while N. Djokovic was on other surfaces
      
• 5. Who were the players with the best serving?

      Hypothesis: Ivo Karlovic was among the players with best serves


For all the insights delivered by this project see Deliverables at the end

Firstly, let's see which players were ranked 1st over the observed years:

**Table 1: Players ranked 1st**

![image](https://github.com/MarinKabic/TennisATP-SQL-DataExploration/assets/131856660/e6bf946e-a89b-4a7e-b429-cd257003c35f)


As shown above, we can see that Novak Djokovic, Roger Federer, Rafael Nadal as well as Andy Murray were top ranked during the observed period. After seeing that there were four players ranked 1st, let’s see who was ranked 1st the most.

**Table 2: Days spent at rank 1**

![image](https://github.com/MarinKabic/TennisATP-SQL-DataExploration/assets/131856660/671ff002-e754-4d27-952f-4f6b84bcb4ee)

This table shows that Novak Djokovic was top ranked for the longest in the observed period. What is also noticeable is the fact that he was top ranked for 819 days more than the 2nd best (Rafael Nadal), which is more than 2 years difference spent at the top spot. Moreover, Rafael Nadal has also spent close to 800 days more at the top rank in comparison to Roger Federer (329). The top ranked players list concludes with Andy Murray who has spent 287 days at the top spot.
That being said, I claim that  Novak Djokovic also won the most matches and most finals/tournaments of all the no. 1 ranked players, so let's see who has played and won the most matches and who has won the most tournaments:

**Table 3: Players sorted by Matches played**

![image](https://github.com/MarinKabic/TennisATP-SQL-DataExploration/assets/131856660/c6f85608-ac28-4199-8a68-e59a98302633)

**Table 4: Players sorted by Finals Won**

![image](https://github.com/MarinKabic/TennisATP-SQL-DataExploration/assets/131856660/1c799240-f389-4d0b-88fa-f6ed4179424e)

As previously stated, Novak Djokovic has won the most matches and he has also won the most Tournaments, winning 13 more trophies than Rafael Nadal. 
Another thing that is also noticeable is Andy Murray, by Total matches played he is not even in top 5 players, but by Tournaments won he is 4th, winning 32 tournaments, which has also led to him being the 4th most succesfull player in the observed period.
After analyzing all the important details about rank and match data, let's see the points deviation for each player who was ranked first:  

**Table 5: Points analysis for top ranked players**

![image](https://github.com/MarinKabic/TennisATP-SQL-DataExploration/assets/131856660/db700455-b385-4a43-9df6-63f9cd5b9fb7)

The table shows that points for the top ranked players range from 7645 to up to 16950, with 16950 being a truly outstanding point tally with the average points for the top ranked player being 12107. The highest point tally was achieved by Novak Djokovic, beneath him, the highest point tally was achieved by Rafael Nadal with 14580 points, more than 2000 points lower than Novak. The lowest points that players had while being top ranked were between 7645 and 8670.
Lastly, I wanted to see who is the best player per surface played (out of the four analyzed players).
During the observed period, matches were played on the following surfaces: Hardcourt (~17k matches), Clay (~9k matches), Grass (~3k matches), Carpet (66 matches). Since only 66 (less than 0.01% of total) matches were played on Carpet and nobody of the top players played on that court, we will not dive into analyzing matches played on Carpet.

**Table 6: Best players per surface**

![image](https://github.com/MarinKabic/TennisATP-SQL-DataExploration/assets/131856660/7159794c-e1ef-4866-991a-98599a4d7139)

We can see that the highest win percentage per surface played is achieved by Rafael Nadal while playing on Clay with over 90% win rate. Other than that, we can see that Novak Djokovic also dominates in this field, having the highest win rate on Hard court as well as in Grass. 
Deeper analysis:
After analyzing player data about matches played and rankings during the period, I also wanted to know the following:
1. Were there any players besides the top ranked players that had an average rating inside TOP 10 during the observed period?
2. Who were the players which had the most aces?

**Table 7: Players with AVG ranking inside TOP 10**

![image](https://github.com/MarinKabic/TennisATP-SQL-DataExploration/assets/131856660/0e537523-5e05-4845-b0eb-60202c784cf5)

As shown above, we can conclude that only The Big Three had an average ranking inside TOP 10. Even though Novak Djokovic spent more than 5 years top ranked, his average ranking is 2.62, which just shows that every player has some setbacks, but nevertheless, he was the most consistent player of the observed period. Noticeably, not even Andy Murray had an average ranking inside TOP 10. To see why is that so, let's firstly see his average rankings per year: 

**Table 8: Andy Murray AVG yearly rank**

![image](https://github.com/MarinKabic/TennisATP-SQL-DataExploration/assets/131856660/64a2674c-4f26-43ef-b6c3-9fabc7d60cae)

This table clearly shows that Andy Murray suffered a major setback in 2018 and 2019 where his average rank was below 200. Why is that so? Sadly, in late 2017., Andy Murray suffered a hip injury while being ranked 1st and he had multiple hip surgeries which has kept him out of action for most of 2018 and 2019. Andy Murray played only 30 matches during these 2 years (compared to 115+ matches by each of The Big Three)
Lastly, I wanted to know who are the players with most aces during the 2010s (having played above 50 matches). More precisely, I believe that Ivo Karlovic is among the TOP 3 players with most average aces during the observed period. Besides that, I want to see the height of all the players that lead the Total Aces charts.

**Table 9: Players with highest AVG aces per match**

![image](https://github.com/MarinKabic/TennisATP-SQL-DataExploration/assets/131856660/4e4cb528-b575-4503-916c-a67845ce7f5f)

Surprisingly, Ivo Karlovic is the player with most average aces per match! On the other hand, the only player who had more aces during the observed period is John Isner who had close to 3000 aces more than Ivo Karlovic, while also having played about 200 matches more than Ivo Karlovic. Nevertheless, John Isner is the second player by average aces per match having only ~2 aces less per match. 
In conclusion, both Ivo Karlovic and John Isner were players with the most destructive serves during the 2010’s.
Another thing worth mentioning are the heights of players with most aces per match. To get an even better perception of the connection between player height and total aces, let’s see the height range distribution among the TOP 20 ranked player by average aces per match.

**Table 10: Height range distribution among players with most AVG aces**

![image](https://github.com/MarinKabic/TennisATP-SQL-DataExploration/assets/131856660/bec263de-cd48-4c69-96df-215770811cb5)


To conclude, both of the top players (Ivo Karlovic and John Isner) are above 200 cm tall and most of the players with the highest aces rankings are above 190, with the shortest players on the list being 180+. We can conclude that higher players have an advantage(which may or may not come on for payment) when it comes to serving in Tennis. 

## Summary:

To summarize, the 2010’s were an era dominated by Novak Djokovic, Rafael Nadal, Roger Federer and Andy Murray respectively, with Novak Djokovic being at the top the longest, winning most matches, most tournaments, while also having the highest point tally and being the most successful player at Hard Court and on Grass. The only segments worth mentioning where Novak Djokovic wasn’t the best was on the Clay surface where Rafael Nadal was the best and in regards of total aces and average aces per match where Ivo Karlovic and John Isner were the best by a mile.
With Novak Djokovic being the only consistently active player as of 25.10.2023, Roger Federer being retired for almost 2 years, Rafael Nadal being mostly inactive due to ongoing injury crysis and Andy Murray being ranked 40th, we can say that 2020’s mark the beginning of a new era in Male tennis division, an era where new faces and new ATP leaders are yet to be established.





## Deliverables

**SQL - Data Exploration Tennis ATP.sql**
-	List all the names of no. 1. players during the period
     - Days spent at rank 1
-	Analysis of top ranked players during the period
     - MAX and MIN points of each no.1 player
     - AVG yearly rank of each no.1 player
     - First and last dates that every player ranked as number 1?
-    Other top ranked players analysis
     - All the players that were ranked top 3 (besides The Big Three + Andy Murray)
     - Top 10 players with the highest average ranking over the entire period
     - Players which had the average ranking inside TOP 10
-    Ranking dates analysis
     - First and last ranking update
     - Count of rank updates
     - Number of weeks observed
     - Dates when rankings weren't updated weekly
-    Players & ranking dates analysis
     - Data about a player when he became no.1 rank
     - How many weekly rankings did the rest of players(besides Djokovic, Federer, Murray, Nadal) stay at top 3
     - How many weeks did any player spend at any given position?
-	Average, Min, Max Points, Percentiles
-	Creating Views

**SQL - Matches analysis Tennis ATP.sql**
-	Match data analysis
     - Matches played, matches won, matches lost
     - Finals played, finals won
-    Total aces analysis
     - Total aces, AVG aces per match
     - Height analysis and defining height ranges of players with best aces data
     - Height range of TOP 20 players with most AVG aces
-    Surface analysis (for the top 4 players)
     - Matches played per surface, matches won per surface
     - Win percentage
     - Best player per surface (player with highest Win percentage) 

