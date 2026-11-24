-- 1. Daily Active Users (DAU)
SELECT 
    DATE(event_timestamp) AS activity_date,
    COUNT(DISTINCT user_id) AS dau
FROM game_events
GROUP BY DATE(event_timestamp)
ORDER BY activity_date;

-- 2. Weekly Active Users (WAU)
SELECT 
    STRFTIME('%Y-%W', event_timestamp) AS activity_week,
    COUNT(DISTINCT user_id) AS wau
FROM game_events
GROUP BY STRFTIME('%Y-%W', event_timestamp)
ORDER BY activity_week;

-- 3. Monthly Active Users (MAU)
SELECT 
    STRFTIME('%Y-%m', event_timestamp) AS activity_month,
    COUNT(DISTINCT user_id) AS mau
FROM game_events
GROUP BY STRFTIME('%Y-%m', event_timestamp)
ORDER BY activity_month;

-- 4. New vs. Returning Players per Day
WITH user_first_seen AS (
    SELECT 
        user_id,
        MIN(DATE(event_timestamp)) AS install_date
    FROM game_events
    GROUP BY user_id
)
SELECT 
    DATE(g.event_timestamp) AS activity_date,
    COUNT(DISTINCT CASE WHEN DATE(g.event_timestamp) = u.install_date THEN g.user_id END) AS new_players,
    COUNT(DISTINCT CASE WHEN DATE(g.event_timestamp) > u.install_date THEN g.user_id END) AS returning_players
FROM game_events g
JOIN user_first_seen u ON g.user_id = u.user_id
GROUP BY DATE(g.event_timestamp)
ORDER BY activity_date;

-- 5. Average Session Duration, Revenue per Player (ARPU), & Paying-User %
SELECT 
    ROUND(AVG(session_duration_sec) / 60.0, 2) AS avg_session_minutes,
    COUNT(DISTINCT user_id) AS total_players,
    COUNT(DISTINCT CASE WHEN revenue > 0 THEN user_id END) AS paying_players,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN revenue > 0 THEN user_id END) / COUNT(DISTINCT user_id), 2) AS paying_user_pct,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(revenue) / COUNT(DISTINCT user_id), 2) AS arpu
FROM game_events;