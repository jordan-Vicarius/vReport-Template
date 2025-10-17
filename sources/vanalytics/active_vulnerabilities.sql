-- Active Vulnerabilities Query
-- Current active vulnerabilities with threat intelligence and group context
SELECT 
    av.endpoint_id,
    av.endpoint_hash,
    av.cve,
    av.patchid,
    av.patch_name,
    av.patch_release_date,
    av.product_name,
    av.version,
    av.vulnerability_summary,
    av.vulnerability_v3_base_score,
    av.vulnerability_v3_exploitability_level,
    av.typecve,
    av.asset,
    av.sensitivity_level_name,
    av.created_at,
    av.updated_at,
    -- Endpoint information
    e.endpoint_name,
    e.operating_system_name,
    e.alive as endpoint_alive,
    -- Group information
    egv.groupname,
    -- Threat intelligence
    ve.exploits_count,
    ve.public_exploit_found,
    ve.commercial_exploit_found,
    ve.weaponized_exploit_found,
    ve.in_kev,
    ve.epss_score,
    ve.epss_percentile,
    ve.reported_exploited,
    ve.reported_exploited_by_ransomware,
    -- KEV information
    kev.vulnerability_name as kev_name,
    kev.required_action,
    kev.due_date,
    -- EPSS data
    epss.epss as epss_score_direct,
    epss.percentile as epss_percentile_direct
FROM activevulnerabilities av
LEFT JOIN endpoints e ON av.endpoint_id = e.endpoint_id
LEFT JOIN endpoint_groups_view egv ON av.endpoint_id = egv.endpoint_id
LEFT JOIN vulncheck_exploits ve ON av.cve = ve.cve_id
LEFT JOIN kevdata kev ON av.cve = kev.cve_id
LEFT JOIN epssdata epss ON av.cve = epss.cve
ORDER BY av.vulnerability_v3_base_score DESC, av.created_at DESC;
