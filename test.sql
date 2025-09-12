-- Julia conducted a  days of learning SQL contest. The start date of the contest was March 01, 2016 and the end date was March 15, 2016.

-- Write a query to print total number of unique hackers who made at least  submission each day (starting on the first day of the contest), and find the hacker_id and name of the hacker who made maximum number of submissions each day. If more than one such hacker has a maximum number of submissions, print the lowest hacker_id. The query should print this information 
-- for each day of the contest, sorted by the date.


WITH daily_submissions AS (
    SELECT 
        submission_date,
        hacker_id,
        COUNT(submission_id) AS submission_count
    FROM Submissions
    GROUP BY submission_date, hacker_id
),

-- 1. Find hackers who submitted on ALL days up to that date
active_hackers AS (
    SELECT 
        ds.submission_date,
        COUNT(DISTINCT ds.hacker_id) AS total_unique_hackers
    FROM daily_submissions ds
    WHERE NOT EXISTS (
        SELECT 1
        FROM (
            SELECT DISTINCT submission_date
            FROM Submissions s2
            WHERE s2.submission_date <= ds.submission_date
        ) d
        WHERE NOT EXISTS (
            SELECT 1
            FROM Submissions s3
            WHERE s3.hacker_id = ds.hacker_id
              AND s3.submission_date = d.submission_date
        )
    )
    GROUP BY ds.submission_date
),

-- 2. Find hacker(s) with max submissions per day
max_submissions AS (
    SELECT 
        ds.submission_date,
        ds.hacker_id,
        ds.submission_count,
        RANK() OVER (
            PARTITION BY ds.submission_date 
            ORDER BY ds.submission_count DESC, ds.hacker_id ASC
        ) AS rnk
    FROM daily_submissions ds
)

SELECT 
    a.submission_date,
    a.total_unique_hackers,
    ms.hacker_id,
    h.name
FROM active_hackers a
JOIN max_submissions ms 
      ON a.submission_date = ms.submission_date AND ms.rnk = 1
JOIN Hackers h 
      ON h.hacker_id = ms.hacker_id
ORDER BY a.submission_date;




-- Query the two cities in STATION with the shortest and
--  longest CITY names, as well as their respective lengths (i.e.: number of characters in the name). If there is more than one smallest or largest city, choose the one that comes first when ordered alphabetically. 
-- The STATION table is described as follows:
SELECT TOP 1 CITY, LEN(CITY) AS NAME_LENGTH
FROM STATION
ORDER BY LEN(CITY) ASC, CITY ASC

UNION

SELECT TOP 1 CITY, LEN(CITY) AS NAME_LENGTH
FROM STATION
ORDER BY LEN(CITY) DESC, CITY ASC;


-- Query the list of CITY names starting with
--  vowels (i.e., a, e, i, o, or u) from STATION.
--  Your result cannot contain duplicates.

select distinct city
 from station
 where city like '[aeiou]%'
 order by city


--- In oralce postgresql
SELECT DISTINCT CITY
FROM STATION
WHERE CITY REGEXP '^[aeiou]'
ORDER BY CITY;


-- Julia asked her students to create some coding challenges. Write a query to print the hacker_id, name, and the total number of challenges created by each student.
--  Sort your results by the total number of challenges in descending order. If more than one student created the same number of challenges, then sort the result by hacker_id. If more than one student 
-- created the same number of challenges and the count is less than the maximum number of challenges created, then exclude those students from the result.

with total_c as(
Select h.hacker_id,
h.name,
count(challenge_id) as total_challenge
from hackers h
join challenges c
on h.hacker_id=c.hacker_id
group by h.hacker_id,h.name
),
countsfreq as(
select total_challenge,count(*) as freq
from total_c 
group by total_challenge
),
max_count as(
select max(total_challenge)as max_chal
    from total_c
)
select cc.hacker_id,cc.name,cc.total_challenge
from  total_c cc
JOIN countsfreq f ON cc.total_challenge = f.total_challenge
JOIN max_count m ON 1=1
WHERE cc.total_challenge = m.max_chal
   OR f.freq = 1
ORDER BY cc.total_challenge DESC, cc.hacker_id ASC;



he total score of a hacker is the sum of their maximum scores for all of the challenges. Write a query to print the hacker_id, name,
 and total score of the hackers ordered by the descending score. If more than one hacker achieved
 the same total score, then sort the result by ascending hacker_id. Exclude all hackers with a total score of  from your result.


 with test1 as (
select hacker_id,challenge_id,max(score) as max_score
    from submissions
    group by hacker_id,challenge_id
),
test2 as(
select hacker_id, sum(max_score) as total_score
from test1
group by hacker_id)

select h.hacker_id,h.name, t.total_score
 from hackers h
 join test2 t
 on h.hacker_id=t.hacker_id
 where t.total_score >0
 order by t.total_score desc,h.hacker_id asc




 Query the Western Longitude (LONG_W) for the largest Northern Latitude (LAT_N) in STATION that is less than . Round your answer to  decimal places.

 SELECT ROUND(LONG_W, 4)
FROM STATION
WHERE LAT_N = (
    SELECT MAX(LAT_N)
    FROM STATION
    WHERE LAT_N < 137.2345
);



A median is defined as a number separating the higher half of 
a data set from the lower half. Query the median of the Northern Latitudes (LAT_N) from STATION and round your answer to  decimal places.


SELECT ROUND(AVG(middle.LAT_N), 4) 
FROM ( SELECT LAT_N, ROW_NUMBER() OVER (ORDER BY LAT_N) AS rn,
      COUNT(*) OVER () AS total_count 
      FROM STATION ) AS middle 
      WHERE rn IN (FLOOR((total_count + 1) / 2), CEIL((total_count + 1) / 2));



    --   ##CEIL
    --   "CEIL," or its function counterpart, ceil(), is a mathematical and programming term that refers to a function
    --    that rounds a number up to the smallest integer that is greater than or equal to it. For example, CEIL(3.14) 
    --    results in 4, and CEIL(-3.14) results in -3.


--symetri 

    select distinct a.x, a.y
from Functions a
where a.x <= a.y
  and (select count(*) from Functions where x = a.y and y = a.x)
        >= case when a.x = a.y then 2 else 1 end
order by a.x;




    select c1.contest_id,hacker_id,name,
    sum(s.total_submissions) as total_submission,
    sum(s.total_accepted_submissions) total_accepted_submissions,
    sum(v.total_views) total_views,
    sum(v.total_unique_views) total_unique_views
    from contests c1
    join
    colleges  c2
    on c1.contest_id=c2.contest_id
    join challenges c3
    on c3.college_id=c2.college_id
    join view_stats v
    on c3.challenge_id=v.challenge_id
    join submission_stats s
   on v.challenge_id=s.challenge_id
    group by c1.contest_id,hacker_id,name
    having sum(ifnull(s.total_submissions,0))
  +sum(ifnull(s.total_accepted_submissions ,0))
+sum(ifnull(v.total_views,0))
+sum(ifnull(v.total_unique_views,0))!=0
    order by
    c1.contest_id asc;


select c.contest_id, c.hacker_id, c.name, sum(s.total_submissions) as total_submissions,
 sum(s.total_accepted_submissions) as total_accepted_submissions, sum(v.total_views) as total_views,
  sum(v.total_unique_views) as total_unique_views 
  from contests c JOIN colleges cl on c.contest_id = cl.contest_id
   JOIN challenges ch on cl.college_id = ch.college_id 
   LEFT JOIN (Select challenge_Id, sum(total_views) as total_views, sum(total_unique_views) as total_unique_views 
   from view_stats group by challenge_Id) v on 
   ch.challenge_id = v.challenge_id LEFT JOIN 
   (Select challenge_id,sum(total_submissions) as total_submissions, sum(total_accepted_submissions) as total_accepted_submissions 
   from submission_stats group by challenge_Id)s on ch.challenge_id = s.challenge_id group by c.contest_id, c.hacker_id, c.name 
Having sum(s.total_submissions) >0 OR sum(s.total_accepted_submissions) > 0 OR sum(v.total_views) > 0 OR sum(v.total_unique_views) > 0 order by c.contest_id