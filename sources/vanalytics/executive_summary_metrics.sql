-- Executive Summary Metrics
-- Key high-level metrics for executive dashboard
WITH vulnerability_counts AS (
    SELECT 
        COUNT(CASE WHEN av.vulnerability_v3_base_score >= 9.0 THEN 1 END) as critical_vulns,
        COUNT(CASE WHEN av.vulnerability_v3_base_score >= 7.0 AND av.vulnerability_v3_base_score < 9.0 THEN 1 END) as high_vulns,
        COUNT(CASE WHEN av.vulnerability_v3_base_score >= 4.0 AND av.vulnerability_v3_base_score < 7.0 THEN 1 END) as medium_vulns,
        COUNT(CASE WHEN av.vulnerability_v3_base_score > 0 AND av.vulnerability_v3_base_score < 4.0 THEN 1 END) as low_vulns,
        COUNT(*) as total_vulns
    FROM activevulnerabilities av
    JOIN endpoints e ON av.endpoint_id = e.endpoint_id
    WHERE e.alive = true
),
endpoint_counts AS (
    SELECT 
        COUNT(*) as total_endpoints,
        COUNT(CASE WHEN e.alive = true THEN 1 END) as active_endpoints,
        COUNT(CASE WHEN e.alive = false THEN 1 END) as inactive_endpoints
    FROM endpoints e
),
mitigation_metrics AS (
    SELECT 
        COUNT(CASE WHEN iv.event_type = 'DetectedActive' THEN 1 END) as detected_count,
        COUNT(CASE WHEN iv.event_type = 'MitigatedVulnerability' THEN 1 END) as mitigated_count,
        AVG(CASE WHEN mtv.mitigation_time_hours IS NOT NULL THEN mtv.mitigation_time_hours END) as avg_mitigation_hours
    FROM incident_view iv
    LEFT JOIN mitigation_time_view mtv ON iv.cve = mtv.cve AND iv.endpoint_id = mtv.endpoint_id
    WHERE iv.h_created_at >= CURRENT_DATE - INTERVAL '30 days'
),
kev_exposure AS (
    SELECT 
        COUNT(DISTINCT av.cve) as kev_vulnerabilities,
        COUNT(DISTINCT av.endpoint_id) as kev_affected_endpoints
    FROM activevulnerabilities av
    JOIN kevdata k ON av.cve = k.cve_id
    JOIN endpoints e ON av.endpoint_id = e.endpoint_id
    WHERE e.alive = true
)
SELECT 
    'Critical Vulnerabilities' as metric_name,
    vc.critical_vulns as metric_value,
    'count' as metric_type
FROM vulnerability_counts vc
UNION ALL
SELECT 
    'High Vulnerabilities' as metric_name,
    vc.high_vulns as metric_value,
    'count' as metric_type
FROM vulnerability_counts vc
UNION ALL
SELECT 
    'Total Vulnerabilities' as metric_name,
    vc.total_vulns as metric_value,
    'count' as metric_type
FROM vulnerability_counts vc
UNION ALL
SELECT 
    'Active Endpoints' as metric_name,
    ec.active_endpoints as metric_value,
    'count' as metric_type
FROM endpoint_counts ec
UNION ALL
SELECT 
    'Vulnerabilities Detected (30d)' as metric_name,
    mm.detected_count as metric_value,
    'count' as metric_type
FROM mitigation_metrics mm
UNION ALL
SELECT 
    'Vulnerabilities Mitigated (30d)' as metric_name,
    mm.mitigated_count as metric_value,
    'count' as metric_type
FROM mitigation_metrics mm
UNION ALL
SELECT 
    'Avg Mitigation Time (Hours)' as metric_name,
    ROUND(mm.avg_mitigation_hours, 2) as metric_value,
    'hours' as metric_type
FROM mitigation_metrics mm
UNION ALL
SELECT 
    'KEV Vulnerabilities' as metric_name,
    ke.kev_vulnerabilities as metric_value,
    'count' as metric_type
FROM kev_exposure ke;
