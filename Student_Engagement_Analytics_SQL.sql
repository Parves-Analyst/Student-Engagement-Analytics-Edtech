-- Database: edtech_engagement

CREATE DATABASE edtech_engagement;

-- Create Table --
CREATE TABLE student_engagement (
    userid_di TEXT,
    registered FLOAT,
    viewed FLOAT,
    explored FLOAT,
    certified FLOAT,
    start_time_di TEXT,
    last_event_di TEXT,
    nevents FLOAT,
    ndays_act FLOAT,
    nplay_video FLOAT,
    nchapters FLOAT
);

-- Check --
SELECT COUNT(*) FROM student_engagement;

-- 1️. How many users are registered vs not registered? --
SELECT registered, COUNT(*) AS user_count
FROM student_engagement
GROUP BY registered;

-- 2️. Average engagement metrics (events, days active, videos, chapters) by registered status --
SELECT 
  registered,
  AVG(nevents) AS avg_events,
  AVG(ndays_act) AS avg_days_active,
  AVG(nplay_video) AS avg_video_plays,
  AVG(nchapters) AS avg_chapters
FROM student_engagement
GROUP BY registered;

-- 3️. Certification rate among registered users --
SELECT 
  registered,
  ROUND(SUM(CASE WHEN certified = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS certification_rate
FROM student_engagement
GROUP BY registered;

-- 4️. Top 5 most active users (by number of events) --
SELECT userid_DI, nevents
FROM student_engagement
ORDER BY nevents DESC
LIMIT 5;

-- 5️. How many users were highly active (e.g. >50 events) but not certified? --
SELECT COUNT(*) AS high_active_not_certified
FROM student_engagement
WHERE nevents > 50 AND certified = 0;

-- 6️. Average engagement duration (in days) — based on registration --
SELECT 
  registered,
  ROUND(AVG(
    DATE_PART('day', 
      TO_TIMESTAMP(last_event_DI, 'DD-MM-YYYY') - TO_TIMESTAMP(start_time_DI, 'DD-MM-YYYY')
    )
  ), 2) AS avg_engagement_duration
FROM student_engagement
WHERE last_event_DI IS NOT NULL
GROUP BY registered;

-- 7️. Distribution of certification by level of activity (e.g., low, medium, high) --
SELECT 
  CASE 
    WHEN nevents < 10 THEN 'Low Activity'
    WHEN nevents BETWEEN 10 AND 50 THEN 'Medium Activity'
    ELSE 'High Activity'
  END AS activity_level,
  COUNT(*) AS total_users,
  SUM(certified) AS total_certified,
  ROUND(SUM(certified) * 100 / COUNT(*), 2) AS cert_rate
FROM student_engagement
GROUP BY activity_level;

-- 8️. Top 5 users with longest engagement duration --
SELECT 
  userid_DI,
  TO_DATE(last_event_DI, 'DD-MM-YYYY') - TO_DATE(start_time_DI, 'DD-MM-YYYY') AS engagement_days
FROM student_engagement
WHERE last_event_DI IS NOT NULL
ORDER BY engagement_days DESC
LIMIT 5;

-- 9️. Average video plays per certified vs non-certified users --
SELECT 
  certified,
  ROUND(AVG(nplay_video), 2) AS avg_video_plays
FROM student_engagement
GROUP BY certified;

-- 10. Correlation check idea: Do more videos watched = more likely to certify? --
SELECT 
  CASE 
    WHEN nplay_video = 0 THEN '0'
    WHEN nplay_video <= 5 THEN '1-5'
    WHEN nplay_video <= 20 THEN '6-20'
    ELSE '20+'
  END AS video_watch_band,
  COUNT(*) AS users,
  SUM(certified) AS certified_users,
  ROUND((SUM(certified)*100.0 / COUNT(*)), 2) AS cert_rate
FROM student_engagement
GROUP BY video_watch_band
ORDER BY cert_rate DESC;
