-- 1. Day 1, Day 7, and Day 30 Retention Rate & Churn
WITH user_cohorts AS (
    SELECT 
        user_id,
        MIN(DATE(event_timestamp)) AS install_date
    FROM game_events
    GROUP BY user_id
),
user_activity AS (
    SELECT DISTINCT
        g.user_id,
        u.install_date,
        CAST(JULIANDAY(DATE(g.event_timestamp)) - JULIANDAY(u.install_date) AS INT) AS day_number
    FROM game_events g
    JOIN user_cohorts u ON g.user_id = u.user_id
)
SELECT 
    COUNT(DISTINCT CASE WHEN day_number = 0 THEN user_id END) AS total_installs,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN day_number = 1 THEN user_id END) / COUNT(DISTINCT CASE WHEN day_number = 0 THEN user_id END), 2) AS d1_retention_pct,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN day_number = 7 THEN user_id END) / COUNT(DISTINCT CASE WHEN day_number = 0 THEN user_id END), 2) AS d7_retention_pct,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN day_number = 30 THEN user_id END) / COUNT(DISTINCT CASE WHEN day_number = 0 THEN user_id END), 2) AS d30_retention_pct,
    ROUND(100.0 - (100.0 * COUNT(DISTINCT CASE WHEN day_number = 7 THEN user_id END) / COUNT(DISTINCT CASE WHEN day_number = 0 THEN user_id END)), 2) AS d7_churn_pct
FROM user_activity;

-- 2. Weekly Player Cohorts Retention Table
WITH user_cohorts AS (
    SELECT 
        user_id,
        STRFTIME('%Y-%W', MIN(event_timestamp)) AS cohort_week,
        MIN(DATE(event_timestamp)) AS install_date
    FROM game_events
    GROUP BY user_id
),
cohort_activity AS (
    SELECT DISTINCT
        u.cohort_week,
        g.user_id,
        CAST(JULIANDAY(DATE(g.event_timestamp)) - JULIANDAY(u.install_date) AS INT) AS day_number
    FROM game_events g
    JOIN user_cohorts u ON g.user_id = u.user_id
)
SELECT 
    cohort_week,
    COUNT(DISTINCT CASE WHEN day_number = 0 THEN user_id END) AS cohort_size,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN day_number = 1 THEN user_id END) / COUNT(DISTINCT CASE WHEN day_number = 0 THEN user_id END), 2) AS day_1_pct,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN day_number = 7 THEN user_id END) / COUNT(DISTINCT CASE WHEN day_number = 0 THEN user_id END), 2) AS day_7_pct,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN day_number = 30 THEN user_id END) / COUNT(DISTINCT CASE WHEN day_number = 0 THEN user_id END), 2) AS day_30_pct
FROM cohort_activity
GROUP BY cohort_week
ORDER BY cohort_week;