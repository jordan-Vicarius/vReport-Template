-- Incident Events Query
-- Provides comprehensive incident data with group context and enhanced fields
SELECT 
    iv.create_at_nano,
    iv.endpoint_id,
    iv.endpoint_hash,
    iv.cve,
    iv.patch_id,
    iv.asset,
    iv.publisher,
    iv.product,
    iv.vulnerability_summary,
    iv.cvss,
    iv.vulnerability_v3_base_score,
    iv.vulnerability_v3_exploitability_level,
    iv.threat_level_id,
    iv.event_type,
    iv.sensitivity_level_name,
    iv.created_at,
    iv.updated_at,
    iv.created_at_milli,
    iv.updated_at_milli,
    iv.mitigated_event_detected_at,
    iv.h_created_at,
    iv.h_updated_at,
    -- Add group context if available
    egv.groupname
FROM incident_view iv
LEFT JOIN endpoint_groups_view egv ON iv.endpoint_id = egv.endpoint_id
ORDER BY iv.h_created_at DESC;