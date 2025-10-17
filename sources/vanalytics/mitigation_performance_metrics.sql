-- Mitigation Performance Metrics
-- Detailed performance analysis including time-to-mitigate calculations
SELECT 
    mtv.endpoint_id,
    mtv.endpoint_hash,
    mtv.cve,
    mtv.patch_id,
    mtv.vulnerability_summary,
    mtv.cvss,
    mtv.vulnerability_v3_base_score,
    mtv.vulnerability_v3_exploitability_level,
    mtv.threat_level_id,
    mtv.detected_event_type,
    mtv.mitigated_event_type,
    mtv.mitigated_event_detected_at,
    mtv.mitigated_at_milli,
    mtv.mitigation_time_hours,
    -- Endpoint information
    e.endpoint_name,
    e.operating_system_name,
    -- Group information
    egv.groupname,
    -- Severity classification
    CASE 
        WHEN mtv.vulnerability_v3_base_score >= 9.0 THEN 'Critical'
        WHEN mtv.vulnerability_v3_base_score >= 7.0 THEN 'High'
        WHEN mtv.vulnerability_v3_base_score >= 4.0 THEN 'Medium'
        WHEN mtv.vulnerability_v3_base_score > 0 THEN 'Low'
        ELSE 'Unknown'
    END as severity_class,
    -- Performance categories
    CASE 
        WHEN mtv.mitigation_time_hours <= 24 THEN 'Within 24h'
        WHEN mtv.mitigation_time_hours <= 72 THEN 'Within 72h'
        WHEN mtv.mitigation_time_hours <= 168 THEN 'Within 1 week'
        WHEN mtv.mitigation_time_hours <= 720 THEN 'Within 1 month'
        ELSE 'Over 1 month'
    END as mitigation_sla_category
FROM mitigation_time_view mtv
LEFT JOIN endpoints e ON mtv.endpoint_id = e.endpoint_id
LEFT JOIN endpoint_groups_view egv ON mtv.endpoint_id = egv.endpoint_id
WHERE mtv.mitigation_time_hours IS NOT NULL
    AND mtv.mitigated_at_milli IS NOT NULL
ORDER BY mtv.mitigation_time_hours ASC;
