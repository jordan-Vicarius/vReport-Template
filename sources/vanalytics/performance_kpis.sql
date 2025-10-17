-- Performance KPIs
-- Key performance indicators for security operations
WITH mitigation_performance AS (
    SELECT 
        AVG(mtv.mitigation_time_hours) as avg_mitigation_hours,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY mtv.mitigation_time_hours) as median_mitigation_hours,
        PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY mtv.mitigation_time_hours) as p95_mitigation_hours,
        COUNT(*) as total_mitigations
    FROM mitigation_time_view mtv
    WHERE mtv.mitigation_time_hours IS NOT NULL
        AND mtv.mitigated_at_milli IS NOT NULL
),
sla_compliance AS (
    SELECT 
        COUNT(CASE WHEN mtv.mitigation_time_hours <= 24 THEN 1 END) as within_24h,
        COUNT(CASE WHEN mtv.mitigation_time_hours <= 72 THEN 1 END) as within_72h,
        COUNT(CASE WHEN mtv.mitigation_time_hours <= 168 THEN 1 END) as within_1week,
        COUNT(*) as total_cases
    FROM mitigation_time_view mtv
    WHERE mtv.mitigation_time_hours IS NOT NULL
        AND mtv.mitigated_at_milli IS NOT NULL
),
vulnerability_metrics AS (
    SELECT 
        COUNT(DISTINCT av.endpoint_id) as total_endpoints,
        COUNT(av.cve) as total_vulnerabilities,
        ROUND((COUNT(av.cve) * 1.0 / COUNT(DISTINCT av.endpoint_id))::numeric, 2) as vuln_density,
        AVG(av.vulnerability_v3_base_score) as avg_cvss_score
    FROM activevulnerabilities av
    JOIN endpoints e ON av.endpoint_id = e.endpoint_id
    WHERE e.alive = true
),
detection_metrics AS (
    SELECT 
        COUNT(CASE WHEN iv.event_type = 'DetectedActive' THEN 1 END) as total_detections,
        COUNT(DISTINCT DATE(iv.h_created_at)) as days_with_detections,
        ROUND((COUNT(CASE WHEN iv.event_type = 'DetectedActive' THEN 1 END) * 1.0 / 
              COUNT(DISTINCT DATE(iv.h_created_at)))::numeric, 2) as avg_detections_per_day
    FROM incident_view iv
    WHERE iv.h_created_at >= CURRENT_DATE - INTERVAL '30 days'
)
SELECT 
    'Mean Time to Remediate (Hours)' as kpi_name,
    ROUND(mp.avg_mitigation_hours::numeric, 2) as current_value,
    24.0 as benchmark_value,
    CASE 
        WHEN mp.avg_mitigation_hours <= 24 THEN 'Meeting SLA'
        WHEN mp.avg_mitigation_hours <= 72 THEN 'At Risk'
        ELSE 'Missing SLA'
    END as status
FROM mitigation_performance mp
UNION ALL
SELECT 
    'Median Time to Remediate (Hours)' as kpi_name,
    ROUND(mp.median_mitigation_hours::numeric, 2) as current_value,
    12.0 as benchmark_value,
    CASE 
        WHEN mp.median_mitigation_hours <= 12 THEN 'Meeting SLA'
        WHEN mp.median_mitigation_hours <= 24 THEN 'At Risk'
        ELSE 'Missing SLA'
    END as status
FROM mitigation_performance mp
UNION ALL
SELECT 
    'Critical SLA Compliance (%)' as kpi_name,
    ROUND((sc.within_24h * 100.0 / NULLIF(sc.total_cases, 0))::numeric, 2) as current_value,
    95.0 as benchmark_value,
    CASE 
        WHEN (sc.within_24h * 100.0 / NULLIF(sc.total_cases, 0)) >= 95 THEN 'Meeting SLA'
        WHEN (sc.within_24h * 100.0 / NULLIF(sc.total_cases, 0)) >= 80 THEN 'At Risk'
        ELSE 'Missing SLA'
    END as status
FROM sla_compliance sc
UNION ALL
SELECT 
    'High SLA Compliance (%)' as kpi_name,
    ROUND((sc.within_72h * 100.0 / NULLIF(sc.total_cases, 0))::numeric, 2) as current_value,
    90.0 as benchmark_value,
    CASE 
        WHEN (sc.within_72h * 100.0 / NULLIF(sc.total_cases, 0)) >= 90 THEN 'Meeting SLA'
        WHEN (sc.within_72h * 100.0 / NULLIF(sc.total_cases, 0)) >= 75 THEN 'At Risk'
        ELSE 'Missing SLA'
    END as status
FROM sla_compliance sc
UNION ALL
SELECT 
    'Vulnerability Density' as kpi_name,
    vm.vuln_density as current_value,
    2.0 as benchmark_value,
    CASE 
        WHEN vm.vuln_density <= 2.0 THEN 'Meeting Target'
        WHEN vm.vuln_density <= 5.0 THEN 'At Risk'
        ELSE 'Exceeding Target'
    END as status
FROM vulnerability_metrics vm
UNION ALL
SELECT 
    'Average CVSS Score' as kpi_name,
    ROUND(vm.avg_cvss_score::numeric, 2) as current_value,
    5.0 as benchmark_value,
    CASE 
        WHEN vm.avg_cvss_score <= 5.0 THEN 'Low Risk'
        WHEN vm.avg_cvss_score <= 7.0 THEN 'Medium Risk'
        ELSE 'High Risk'
    END as status
FROM vulnerability_metrics vm;
