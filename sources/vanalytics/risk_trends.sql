-- Risk Trends Analysis
-- 90-day vulnerability and mitigation trends
WITH daily_metrics AS (
    SELECT 
        DATE(iv.h_created_at) as event_date,
        COUNT(CASE WHEN iv.event_type = 'DetectedActive' THEN 1 END) as detected_count,
        COUNT(CASE WHEN iv.event_type = 'MitigatedVulnerability' THEN 1 END) as mitigated_count,
        AVG(CASE WHEN mtv.mitigation_time_hours IS NOT NULL THEN mtv.mitigation_time_hours END) as avg_mitigation_hours
    FROM incident_view iv
    LEFT JOIN mitigation_time_view mtv ON iv.cve = mtv.cve AND iv.endpoint_id = mtv.endpoint_id
    WHERE iv.h_created_at >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY DATE(iv.h_created_at)
),
monthly_aggregates AS (
    SELECT 
        DATE_TRUNC('month', event_date) as period,
        SUM(detected_count) as total_detected,
        SUM(mitigated_count) as total_mitigated,
        AVG(avg_mitigation_hours) as avg_mitigation_hours,
        COUNT(DISTINCT event_date) as days_in_period
    FROM daily_metrics
    GROUP BY DATE_TRUNC('month', event_date)
),
current_vulnerabilities AS (
    SELECT 
        COUNT(CASE WHEN av.vulnerability_v3_base_score >= 9.0 THEN 1 END) as critical_vulns,
        COUNT(CASE WHEN av.vulnerability_v3_base_score >= 7.0 AND av.vulnerability_v3_base_score < 9.0 THEN 1 END) as high_vulns,
        COUNT(*) as total_vulns
    FROM activevulnerabilities av
    JOIN endpoints e ON av.endpoint_id = e.endpoint_id
    WHERE e.alive = true
)
SELECT 
    period,
    total_detected,
    total_mitigated,
    ROUND(avg_mitigation_hours, 2) as avg_mitigation_hours,
    ROUND(total_mitigated * 1.0 / NULLIF(total_detected, 0) * 100, 2) as mitigation_rate_pct
FROM monthly_aggregates
UNION ALL
SELECT 
    CURRENT_DATE as period,
    cv.critical_vulns + cv.high_vulns as total_detected,
    0 as total_mitigated,
    0 as avg_mitigation_hours,
    0 as mitigation_rate_pct
FROM current_vulnerabilities cv
ORDER BY period;
