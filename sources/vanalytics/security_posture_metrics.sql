-- Security Posture Metrics
-- Key security posture indicators based on available data
WITH patch_compliance AS (
    SELECT 
        COUNT(DISTINCT av.endpoint_id) as total_endpoints,
        COUNT(DISTINCT CASE WHEN av.patch_name IS NOT NULL THEN av.endpoint_id END) as patched_endpoints,
        ROUND(
            (COUNT(DISTINCT CASE WHEN av.patch_name IS NOT NULL THEN av.endpoint_id END) * 100.0 / 
             NULLIF(COUNT(DISTINCT av.endpoint_id), 0))::numeric, 2
        ) as patch_compliance_rate
    FROM activevulnerabilities av
    JOIN endpoints e ON av.endpoint_id = e.endpoint_id
    WHERE e.alive = true
),
vulnerability_density AS (
    SELECT 
        COUNT(DISTINCT av.endpoint_id) as total_endpoints,
        COUNT(av.cve) as total_vulnerabilities,
        ROUND((COUNT(av.cve) * 1.0 / NULLIF(COUNT(DISTINCT av.endpoint_id), 0))::numeric, 2) as vuln_density
    FROM activevulnerabilities av
    JOIN endpoints e ON av.endpoint_id = e.endpoint_id
    WHERE e.alive = true
),
severity_distribution AS (
    SELECT 
        COUNT(CASE WHEN av.vulnerability_v3_base_score >= 9.0 THEN 1 END) as critical_count,
        COUNT(CASE WHEN av.vulnerability_v3_base_score >= 7.0 AND av.vulnerability_v3_base_score < 9.0 THEN 1 END) as high_count,
        COUNT(CASE WHEN av.vulnerability_v3_base_score >= 4.0 AND av.vulnerability_v3_base_score < 7.0 THEN 1 END) as medium_count,
        COUNT(CASE WHEN av.vulnerability_v3_base_score > 0 AND av.vulnerability_v3_base_score < 4.0 THEN 1 END) as low_count,
        COUNT(*) as total_count
    FROM activevulnerabilities av
    JOIN endpoints e ON av.endpoint_id = e.endpoint_id
    WHERE e.alive = true
),
kev_compliance AS (
    SELECT 
        COUNT(DISTINCT k.cve_id) as total_kev,
        COUNT(DISTINCT CASE WHEN av.cve IS NULL THEN k.cve_id END) as remediated_kev,
        ROUND(
            (COUNT(DISTINCT CASE WHEN av.cve IS NULL THEN k.cve_id END) * 100.0 / 
             NULLIF(COUNT(DISTINCT k.cve_id), 0))::numeric, 2
        ) as kev_compliance_rate
    FROM kevdata k
    LEFT JOIN activevulnerabilities av ON k.cve_id = av.cve
    JOIN endpoints e ON av.endpoint_id = e.endpoint_id
    WHERE e.alive = true OR av.cve IS NULL
)
SELECT 
    'Patch Compliance Rate (%)' as metric_name,
    COALESCE(pc.patch_compliance_rate, 0) as current_value,
    95.0 as target_value,
    CASE 
        WHEN COALESCE(pc.patch_compliance_rate, 0) >= 95.0 THEN 'On Track'
        ELSE 'Behind'
    END as status
FROM patch_compliance pc
UNION ALL
SELECT 
    'Vulnerability Density' as metric_name,
    COALESCE(vd.vuln_density, 0) as current_value,
    2.0 as target_value,
    CASE 
        WHEN COALESCE(vd.vuln_density, 0) <= 2.0 THEN 'On Track'
        ELSE 'Behind'
    END as status
FROM vulnerability_density vd
UNION ALL
SELECT 
    'Critical Vulnerabilities' as metric_name,
    sd.critical_count as current_value,
    0 as target_value,
    CASE 
        WHEN sd.critical_count = 0 THEN 'On Track'
        ELSE 'Behind'
    END as status
FROM severity_distribution sd
UNION ALL
SELECT 
    'KEV Compliance Rate (%)' as metric_name,
    COALESCE(kc.kev_compliance_rate, 0) as current_value,
    100.0 as target_value,
    CASE 
        WHEN COALESCE(kc.kev_compliance_rate, 0) >= 100.0 THEN 'On Track'
        ELSE 'Behind'
    END as status
FROM kev_compliance kc;
