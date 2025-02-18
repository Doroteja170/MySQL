-- In this project I analyzed Formula 1 data for the 2024 season in MySQL, focusing on data cleaning, processing, and extracting insights.
-- Data: https://www.kaggle.com/datasets/rohanrao/formula-1-world-championship-1950-2020

-- Data Formating
update drivers
set FirstName=concat(FirstName,' ',LastName);
alter table drivers drop column LastName;
alter table drivers rename column FirstName to FullName;

select date, str_to_date(date,'%m/%d/%Y') from races;
update races
set date=str_to_date(date,'%m/%d/%Y') ;
alter table races
modify column date date;

-- 2024 Constructors
select distinct(c.Constructor),c.nationality from results r
join races ra on r.raceId=ra.raceId
join constructors c on r.constructorId=c.constructorId
where ra.year=2024;

-- 2024 Drivers
select distinct(d.FullName),d.code,d.number,d.nationality,c.Constructor from results r
join races ra on r.raceId=ra.raceId
join drivers d on r.driverId=d.driverId
join constructors c on r.constructorId=c.constructorId
where ra.year=2024
order by c.Constructor;

-- Constructor Standings for 2024
select c.Constructor,cs.points,cs.wins from constructor_standings cs
join constructors c on cs.constructorId=c.constructorId
where cs.raceId=1144
order by cs.points desc;

-- Driver Standings for 2024
select  d.number,d.FullName,c.Constructor ,ds.points from driver_standings ds
join drivers d on ds.driverId=d.driverId
join results r on ds.raceId=r.raceId and d.driverId=r.driverId
join constructors c on r.constructorId=c.constructorId
where ds.raceId=1144
order by ds.points desc;

-- Mclaren points through Year
SELECT r.year, c.Constructor, max(cs.points) AS TotalPoints
FROM constructor_standings cs
JOIN constructors c ON cs.constructorId = c.constructorId
JOIN races r ON cs.raceId = r.raceId
WHERE c.Constructor = 'McLaren'
GROUP BY r.year, c.Constructor
ORDER BY r.year;

-- Ferrari points through Year
SELECT r.year, c.Constructor, max(cs.points) AS TotalPoints
FROM constructor_standings cs
JOIN constructors c ON cs.constructorId = c.constructorId
JOIN races r ON cs.raceId = r.raceId
WHERE c.Constructor = 'Ferrari'
GROUP BY r.year, c.Constructor
ORDER BY r.year;


-- Total Wins by Driver for 2024
select d.FullName,c.Constructor ,ds.wins from driver_standings ds
join drivers d on ds.driverId=d.driverId
join results r on ds.raceId=r.raceId and d.driverId=r.driverId
join constructors c on r.constructorId=c.constructorId
where ds.raceId=1144
order by ds.points desc;


-- Total Pole positions 2024
select d.FullName,count(case when q.position=1 then 1 end) as pole
from qualifying q
join races r on q.raceId=r.raceId
join drivers d on q.driverId=d.driverId
where r.year=2024
group by d.FullName
order by count(case when q.position=1 then 1 end) desc;

-- Top 20 Drivers with the most wins all time
select d.FullName,count(case when r.position=1 then 1 end) as wins from results r
join drivers d on r.driverId=d.driverId
group by d.FullName
order by count(case when r.position=1 then 1 end) desc
limit 20;

-- Fastest Laps in 2024 by Circuit
select re.fastestLapTime,c.name as Circuit,c.country,d.FullName from results re
join races r on re.raceId=r.raceId
join drivers d on re.driverId=d.driverId
join circuits c on r.circuitId=c.circuitId
where r.year=2024
AND re.fastestLapTime = (SELECT MIN(fastestLapTime)FROM results WHERE raceId = re.raceId and fastestLapTime not like '00:00.0')
order by r.date;


-- Max Verstappen Status
select d.FullName,r.position,s.status,c.name as Circuit from results r
join races ra on r.raceId=ra.raceId
join drivers d on r.driverId=d.driverId
join circuits c on ra.circuitId=c.circuitId
join status s on r.statusId=s.statusId
where d.FullName like 'Max Ver%' and ra.year=2024
order by ra.date;

-- Max Verstappen vs Lando Norris - Title Fight
select d.FullName,sum(re.points) as points,r.date
from results re
join races r on re.raceId=r.raceId
join drivers d on re.driverId=d.driverId
where r.year=2024 and (d.FullName like 'Lando Norris' or d.FullName like 'Max Ver%')
group by d.FullName,r.date
order by r.date,sum(re.points) desc;

-- Ferrari vs Mclaren vs Red Bull - Title Fight
select c.Constructor,sum(re.points) as points,r.date
from results re
join races r on re.raceId=r.raceId
join constructors c on re.constructorId=c.constructorId
where r.year=2024 and (c.Constructor='Ferrari' or c.Constructor='Red Bull' or c.Constructor='McLaren')
group by c.Constructor,r.date
order by r.date,sum(re.points) desc;


-- Total Laps Completed by Driver in 2024
select d.FullName,sum(r.laps)as Total_Laps from results r
join races ra on r.raceId=ra.raceId
join drivers d on r.driverId=d.driverId
where ra.year=2024
group by d.FullName
order by sum(r.laps) desc;

-- Sprint Wins in 2024
select d.FullName, count(case when s.position=1 then 1 end)as sprint_wins from sprint_results s
join races r on s.raceId=r.raceId
join drivers d on s.driverId=d.driverId
where r.year=2024
group by d.FullName
order by count(case when s.position=1 then 1 end) desc;

-- Total Sprint Wins
with cte as(
select d.FullName as FullName, count(case when s.position=1 then 1 end)as sprint_wins from sprint_results s
join races r on s.raceId=r.raceId
join drivers d on s.driverId=d.driverId
group by d.FullName
)
select FullName, sprint_wins from cte
where sprint_wins>0
order by sprint_wins desc;

-- Fastest Pit Stop in 2024
select d.FullName,c.Constructor,ra.name,p.duration from results r
join races ra on  r.raceId=ra.raceId
join drivers d on r.driverId=d.driverId
join constructors c on r.constructorId=c.constructorId
join pit_stops p on r.raceId=p.raceId and r.driverId=p.driverId
where ra.year=2024 and p.duration=(select min(duration) from pit_stops where raceId=r.raceId and duration >0.1)
order by ra.date;

-- Top 20 drivers with the most wins by circuit
WITH RankedWins AS (
    SELECT  
        d.FullName FullName,  
        COUNT(CASE WHEN r.position = 1 THEN 1 END) AS Wins,  
        c.name AS Circuit,  
        ROW_NUMBER() OVER (PARTITION BY c.name ORDER BY COUNT(CASE WHEN r.position = 1 THEN 1 END) DESC) AS `Rank`  
    FROM results r  
    JOIN drivers d ON r.driverId = d.driverId  
    JOIN races ra ON r.raceId = ra.raceId  
    JOIN circuits c ON ra.circuitId = c.circuitId  
    GROUP BY d.FullName, c.name  
)  
SELECT FullName, Wins, Circuit  
FROM RankedWins  
WHERE `Rank` = 1  
ORDER BY Wins DESC
limit 20;

-- Q1 Eliminations by driver in 2024
select d.FullName, c.Constructor,count(case when (q.position=20 or q.position=19 
or q.position=18 or q.position=17 or q.position=16) then 1 end) as Q1_Eliminations from qualifying q
join races r on q.raceId=r.raceId
join drivers d on q.driverId=d.driverId
join constructors c on q.constructorId=c.constructorId
where r.year=2024
group by d.FullName,c.Constructor
order by count(case when (q.position=20 or q.position=19 
or q.position=18 or q.position=17 or q.position=16) then 1 end) desc;

-- Constructors Total Wins - All Time
select c.Constructor,count(case when position=1 then 1 end)as Total_Wins from constructor_standings cs
join constructors c on cs.constructorId=c.constructorId
group by c.Constructor
order by count(case when position=1 then 1 end) desc;

-- Total Podiums by Driver in 2024
select d.FullName,c.Constructor, count(case when (r.position=1 or r.position=2 or r.position=3) then 1 end)as podiums from results r
join drivers d on r.driverId=d.driverId
join constructors c on r.constructorId=c.constructorId
join races ra on r.raceId=ra.raceId
where ra.year=2024
group by d.FullName,c.Constructor
order by count(case when (r.position=1 or r.position=2 or r.position=3) then 1 end) desc;

-- 2024 Constructor points through Years
SELECT r.year, c.Constructor, max(cs.points) AS TotalPoints
FROM constructor_standings cs
JOIN constructors c ON cs.constructorId = c.constructorId
JOIN races r ON cs.raceId = r.raceId
where c.Constructor in (select distinct(c.Constructor) from results r
join races ra on r.raceId=ra.raceId
join constructors c on r.constructorId=c.constructorId
where ra.year=2024)
GROUP BY r.year, c.Constructor
ORDER BY r.year,c.Constructor;

-- Constructor Points Scored through Month in 2024
select c.Constructor,sum(re.points) as points,r.date
from results re
join races r on re.raceId=r.raceId
join constructors c on re.constructorId=c.constructorId
where r.year=2024
group by c.Constructor,r.date
order by r.date,sum(re.points) desc;

-- Driver Points through Month in 2024
select d.FullName,c.Constructor,sum(re.points) as points,r.date from results re
join races r on re.raceId=r.raceId
join drivers d on re.driverId=d.driverId
join constructors c on re.constructorId=c.constructorId
where r.year=2024 
group by d.FullName,r.date,c.Constructor
order by r.date,sum(re.points) desc;

-- 2024 Circuits
select c.name,c.location,c.country,r.name from races r
join circuits c on r.circuitId=c.circuitId
where r.year=2024;
