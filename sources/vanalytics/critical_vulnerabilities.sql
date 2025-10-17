-- Critical Vulnerabilities Requiring Immediate Action
-- Top critical vulnerabilities with threat intelligence and SLA status
SELECT 
    av.cve,
    av.vulnerability_summary,
    av.vulnerability_v3_base_score as cvss_score,
    av.product_name,
    av.asset,
    e.endpoint_name,
    egv.groupname,
    -- Days since discovery
    (CURRENT_DATE - av.created_at::date) as days_open,
    -- SLA Status
    CASE 
        WHEN av.vulnerability_v3_base_score >= 9.0 AND (CURRENT_DATE - av.created_at::date) > 1 
            THEN 'Overdue'
        WHEN av.vulnerability_v3_base_score >= 9.0 AND (CURRENT_DATE - av.created_at::date) <= 1 
            THEN 'On Track'
        WHEN av.vulnerability_v3_base_score >= 7.0 AND (CURRENT_DATE - av.created_at::date) > 30 
            THEN 'Overdue'
        ELSE 'On Track'
    END as sla_status,
    -- Threat intelligence
    ve.exploits_count,
    ve.public_exploit_found,
    ve.in_kev,
    ve.epss_score,
    ve.reported_exploited,
    -- KEV information
    kev.required_action,
    kev.due_date,
    -- Patch information
    av.patch_name,
    av.patch_release_date
FROM activevulnerabilities av
JOIN endpoints e ON av.endpoint_id = e.endpoint_id
LEFT JOIN endpoint_groups_view egv ON av.endpoint_id = egv.endpoint_id
LEFT JOIN vulncheck_exploits ve ON av.cve = ve.cve_id
LEFT JOIN kevdata kev ON av.cve = kev.cve_id
WHERE e.alive = true 
    AND av.vulnerability_v3_base_score >= 7.0
ORDER BY 
    av.vulnerability_v3_base_score DESC, 
    days_open DESC,
    ve.epss_score DESC NULLS LAST
LIMIT 20;
