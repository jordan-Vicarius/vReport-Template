SELECT *
FROM mitigation_performance_view mvp
JOIN endpoint_groups_view egv ON mvp.endpoint_id = egv.endpoint_id;