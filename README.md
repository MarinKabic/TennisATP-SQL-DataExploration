# TennisATP-SQL-DataExploration
This projects is focused on data exploration in **MS SQL Server** on the ATP rankings and matches data from 2010's(2010-2019).

Also, **Python** was used for combining 10 csv files into 1, see > ATP_Matches_Files.ipynb

The dataset that is analyzed is on https://github.com/JeffSackmann/tennis_atp from https://github.com/JeffSackmann 

The data exploration part consists of 2 parts:
1. SQL - Data Exploration Tennis ATP.sql >  Analyzing player rankings over the observed period
                                            (files used: „atp_rankings_10s.csv“ and „atp_players.csv“)
2. SQL - Matches analysis Tennis ATP.sql >  Analyzing data about: matches, finals, and some deeper analysis regarding: aces and matches played per surface
                                            (files used: > from „atp_matches_2010.csv“ to „atp_matches_2019.csv“)


## Deliverables
This project will analyze ATP Rankings and matches in 2010-2019.
Some of the insights that the analysis will provide:

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

