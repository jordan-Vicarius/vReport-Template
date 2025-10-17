-- CMMC Vulnerability Remediation Tracking
-- Maps to CMMC controls: RA.L2-3.11.3, CA.L2-3.12.1e, CM.L2-3.4.2e
SELECT 
    av.vulid,
    av.cve,
    av.vulnerability_v3_base_score,
    av.asset,
    av.endpoint_id,
    e.endpoint_name,
    -- CMMC Priority Scoring
    CASE 
        WHEN av.vulnerability_v3_base_score >= 9.0 THEN 'Critical - Immediate Action Required'
        WHEN av.vulnerability_v3_base_score >= 7.0 THEN 'High - Remediate within 7 days'
        WHEN av.vulnerability_v3_base_score >= 4.0 THEN 'Medium - Remediate within 30 days'
        ELSE 'Low - Remediate within 90 days'
    END as cmmc_priority,
    -- KEV (Known Exploited Vulnerabilities) flag for CMMC
    CASE 
        WHEN kev.cve_id IS NOT NULL THEN 'Yes - CISA KEV Listed'
        ELSE 'No'
    END as kev_status,
    -- Patch availability
    CASE 
        WHEN p.patch_id IS NOT NULL THEN 'Available'
        ELSE 'Not Available'
    END as patch_status,
    p.patch_name,
    p.data_lancamento as patch_release_date,
    -- Days since vulnerability discovered

    -- CMMC Control Mapping
    CASE 
        WHEN av.vulnerability_v3_base_score >= 7.0 THEN 'RA.L2-3.11.2, RA.L2-3.11.3, CA.L2-3.12.1'
        WHEN av.vulnerability_v3_base_score >= 4.0 THEN 'RA.L2-3.11.2, RA.L2-3.11.3'
        ELSE 'RA.L2-3.11.2'
    END as mapped_cmmc_controls,
    CURRENT_DATE as last_assessed
FROM activevulnerabilities av
LEFT JOIN endpoints e ON av.endpoint_id = e.endpoint_id
LEFT JOIN patches p ON av.patchid = p.patch_id
LEFT JOIN kevdata kev ON av.cve = kev.cve_id
WHERE av.vulnerability_v3_base_score IS NOT NULL
ORDER BY 
    av.vulnerability_v3_base_score DESC, 
    CASE WHEN kev.cve_id IS NOT NULL THEN 0 ELSE 1 END