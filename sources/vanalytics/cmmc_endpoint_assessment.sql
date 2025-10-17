-- CMMC Endpoint Security Assessment
-- Maps to CMMC controls: CM.L2-3.4.1, CM.L2-3.4.2, CA.L2-3.12.1
SELECT 
    e.endpoint_name,
    e.operating_system_name,
    COUNT(av.vulid) as total_vulnerabilities,
    COUNT(CASE WHEN av.vulnerability_v3_base_score >= 9.0 THEN 1 END) as critical_count,
    COUNT(CASE WHEN av.vulnerability_v3_base_score >= 7.0 AND av.vulnerability_v3_base_score < 9.0 THEN 1 END) as high_count,
    COUNT(CASE WHEN av.vulnerability_v3_base_score >= 4.0 AND av.vulnerability_v3_base_score < 7.0 THEN 1 END) as medium_count,
    COUNT(CASE WHEN av.vulnerability_v3_base_score > 0 AND av.vulnerability_v3_base_score < 4.0 THEN 1 END) as low_count,
    MAX(av.vulnerability_v3_base_score) as max_cvss_score,
    -- Security baseline compliance
    CASE 
        WHEN COUNT(CASE WHEN av.vulnerability_v3_base_score>= 9.0 THEN 1 END) = 0 THEN 'Compliant'
        WHEN COUNT(CASE WHEN av.vulnerability_v3_base_score >= 9.0 THEN 1 END) <= 2 THEN 'Attention Required'
        ELSE 'Non-Compliant'
    END as baseline_compliance,
    -- Asset classification for CMMC
    CASE 
        WHEN av.sensitivity_level_name = 'High' THEN 'CUI Processing'
        WHEN av.sensitivity_level_name = 'Medium' THEN 'FCI Processing'
        ELSE 'Standard'
    END as cmmc_asset_class,
    e.lastcontactdate,
    CURRENT_DATE as assessment_date
FROM endpoints e
LEFT JOIN assets a ON e.endpoint_id = a.asset_id
LEFT JOIN operating_system os ON a.so_hash = os.hash
LEFT JOIN activevulnerabilities av ON e.endpoint_id = av.endpoint_id
GROUP BY 
    e.endpoint_id, e.endpoint_name, e.operating_system_name, av.sensitivity_level_name, e.lastcontactdate
ORDER BY 
    critical_count DESC, high_count DESC, max_cvss_score DESC