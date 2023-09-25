SELECT * FROM data1;
SELECT * FROM data2;

SELECT COUNT (*) FROM data1;
SELECT COUNT (*) FROM data2;

--Data from specific state (Maharashtra, Kerala)

SELECT * FROM Data1 WHERE STATE in ('Maharashtra','Kerala')

---Total Population of India: 

SELECT SUM (Population) FROM Data2

--------Average growth:

SELECT AVG (Growth)*100 Avg_Growth 
FROM Data1

-----Avg Growth by State:

SELECT State, AVG (Growth)*100 Avg_Growth FROM Data1 GROUP BY State;

----------Average of sex ratio:

SELECT State, ROUND(AVG([SexRatio]),0) Avg_sexratio 
FROM Data1 GROUP BY State Order by Avg_sexratio DESC;

--Average Literacy rate >90:

SELECT State,ROUND(AVG (Literacy),0) Avg_Literacy FROM Data1
GROUP BY State HAVING ROUND(AVG (Literacy),0)> 90 ORDER BY Avg_Literacy DESC 


--Top 3 state with highest growth%: 


SELECT top 3 State, AVG (Growth)*100 Avg_Growth From Data1 GROUP BY State ORDER BY Avg_Growth DESC;

--Bottom 3 states with lowest sex ratio:

SELECT top 3 State, ROUND(AVG([SexRatio]),0) Avg_sexratio FROM Data1 GROUP BY State ORDER BY Avg_sexratio ASC;

--top and bottom 3 states with sex ratio:

DROP TABLE IF EXISTS #bottomstates 
CREATE TABLE #BottomStates
(State Nvarchar(255),
bottomstates float 
)
INSERT INTO #bottomStates
SELECT State, ROUND(AVG([SexRatio]),0) Avg_sexratio FROM Data1 Group by State Order by Avg_sexratio DESC;


-----Union

SELECT * FROM(
SELECT top 3 * FROM #bottomStates order by bottomstates ASC) a
union
SELECT * FROM(
SELECT top 3* FROM #topstates order by topstates DESC) b;


--States starting with "a" and "b"

SELECT Distinct State FROM data1 where lower(state) like'a%' or lower(state) like 'b%'

--Startiing with"a" and ending with "m"

SELECT Distinct State FROM data1 where lower(state) like'a%' AND lower(state) like '%m'


---joining both table

SELECT a.District,a.State,a.[SexRatio],b.population from data1 a inner join data2 b on a.district=b.District

--total males and females


SELECT d.state,
 SUM(d.males) AS total_males,
 SUM(d.females) AS total_females
FROM (
SELECT c.district,
 c.state,
 ROUND(c.population / (c.sexratio + 1), 0) AS males,
 ROUND(c.population * c.sexratio / (c.sexratio + 1), 0) AS females
FROM (
SELECT a.district,
 a.state,
 a.sexratio,
 b.population
 FROM Data1 AS a
 INNER JOIN Data2 AS b ON a.district = b.district
) AS c
) AS d
GROUP BY d.state;

--- total literate rate

SELECT District,State, Literacy,
SELECT a.district, a.state


SELECT a.District,a.State,a.Literacy Literacy_ratio,b.population from data1 a inner join data2 b on a.district=b.District

SELECT c.state,
SUM(literate_people) AS total_literate_population,
 SUM(illiterate_people) AS total_illiterate_population
FROM (
  SELECT d.district,
d.state,
ROUND(d.literate_people, 0) AS literate_people,
ROUND(d.illiterate_people, 0) AS illiterate_people
  FROM (
 SELECT a.district,
 a.state,
 a.literacy / 100 AS literacy_ratio,
b.population,
(a.literacy / 100 * b.population) AS literate_people,
((1 - a.literacy / 100) * b.population) AS illiterate_people
 FROM Data1 a
INNER JOIN Data2 b ON a.district = b.district
  ) AS d) AS c
GROUP BY c.state;


--- Population in previous census

SELECT 
 SUM(previous_census_population) AS previous_census_population,
 SUM(current_census_population) AS current_census_population
FROM (
SELECT 
e.state,
SUM(e.previous_census_population) AS previous_census_population,
SUM(e.current_census_population) AS current_census_population
FROM (SELECT d.district, d.state, ROUND(d.population / (1 + d.growth), 0) AS previous_census_population, 
  d.population AS current_census_population
FROM (
SELECT a.district, a.state, a.growth, b.population 
FROM Data1 a 
INNER JOIN Data2 b ON a.district = b.district) AS d) AS e 
  GROUP BY e.state
) AS m;


------------Top 3 Districts from each state with highest literacy ratio:

SELECT a.* FROM
(SELECT District,State,Literacy,rank() over(partition by State order by Literacy desc) rank from Data1) a

WHERE a.rank in (1,2,3) Order by State
