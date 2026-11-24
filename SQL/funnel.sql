-- 1. Player Onboarding & Monetization Funnel (Install -> Tutorial -> First Game -> Purchase)
WITH funnel_counts AS (
    SELECT 
        COUNT(DISTINCT CASE WHEN event_name = 'install' THEN user_id END) AS installs,
        COUNT(DISTINCT CASE WHEN event_name = 'tutorial_complete' THEN user_id END) AS tutorial_completed,
        COUNT(DISTINCT CASE WHEN event_name = 'first_game' THEN user_id END) AS first_game_played,
        COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN user_id END) AS purchasers
    FROM game_events
)
SELECT 
    installs,
    tutorial_completed,
    ROUND(100.0 * tutorial_completed / installs, 2) AS install_to_tutorial_pct,
    first_game_played,
    ROUND(100.0 * first_game_played / tutorial_completed, 2) AS tutorial_to_game_pct,
    purchasers,
    ROUND(100.0 * purchasers / first_game_played, 2) AS game_to_purchase_pct,
    ROUND(100.0 * purchasers / installs, 2) AS overall_conversion_pct
FROM funnel_counts;

-- 2. Funnel Breakdown by A/B Test Group
SELECT 
    ab_group,
    COUNT(DISTINCT CASE WHEN event_name = 'install' THEN user_id END) AS installs,
    COUNT(DISTINCT CASE WHEN event_name = 'tutorial_complete' THEN user_id END) AS tutorial_completed,
    COUNT(DISTINCT CASE WHEN event_name = 'first_game' THEN user_id END) AS first_game_played,
    COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN user_id END) AS purchasers,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN user_id END) / COUNT(DISTINCT CASE WHEN event_name = 'install' THEN user_id END), 2) AS overall_conversion_pct
FROM game_events
GROUP BY ab_group;