# Executive Risk Dashboard
## Continuous Threat Exposure Management

**Reporting Period:** Last 30 Days  
**Report Generated:** Current Date  
**Organization:** Vulnerability Management System

---

## Executive Summary

```sql critical_vulns_count
SELECT COUNT(CASE WHEN av.vulnerability_v3_base_score >= 9.0 THEN 1 END) as count
FROM "vanalytics"."active_vulnerabilities" av
JOIN "vanalytics"."endpoints" e ON av.endpoint_id = e.endpoint_id;
```

```sql high_vulns
SELECT COUNT(CASE WHEN av.vulnerability_v3_base_score >= 7.0 AND av.vulnerability_v3_base_score < 9.0 THEN 1 END) as count
FROM "vanalytics"."active_vulnerabilities" av
JOIN "vanalytics"."endpoints" e ON av.endpoint_id = e.endpoint_id;
```

```sql total_vulns
SELECT COUNT(*) as count
FROM "vanalytics"."active_vulnerabilities" av
JOIN "vanalytics"."endpoints" e ON av.endpoint_id = e.endpoint_id;
```

```sql active_endpoints
SELECT COUNT(*) as count
FROM "vanalytics"."endpoints" e
```

<BigValue
    data={critical_vulns_count}
    title="Critical Vulnerabilities"
    value=count
/>

<BigValue
    data={high_vulns}
    title="High Vulnerabilities"
    value=count
/>

<BigValue
    data={total_vulns}
    title="Total Vulnerabilities"
    value=count
/>

<BigValue
    data={active_endpoints}
    title="Active Endpoints"
    value=count
/>

---

## Risk Overview

### Vulnerability Risk Assessment

**Total Vulnerabilities:** {total_vulns[0]?.count || 0}  
**Critical Vulnerabilities:** {critical_vulns[0]?.count || 0}  
**High Vulnerabilities:** {high_vulns[0]?.count || 0}

```sql vulnerability_distribution
SELECT 
    'Critical' as severity,
    COUNT(CASE WHEN av.vulnerability_v3_base_score >= 9.0 THEN 1 END) as count,
    1 as sort_order
FROM "vanalytics"."active_vulnerabilities" av
JOIN "vanalytics"."endpoints" e ON av.endpoint_id = e.endpoint_id
WHERE e.alive = true
UNION ALL
SELECT 
    'High' as severity,
    COUNT(CASE WHEN av.vulnerability_v3_base_score >= 7.0 AND av.vulnerability_v3_base_score < 9.0 THEN 1 END) as count,
    2 as sort_order
FROM "vanalytics"."active_vulnerabilities" av
JOIN "vanalytics"."endpoints" e ON av.endpoint_id = e.endpoint_id
WHERE e.alive = true
UNION ALL
SELECT 
    'Medium' as severity,
    COUNT(CASE WHEN av.vulnerability_v3_base_score >= 4.0 AND av.vulnerability_v3_base_score < 7.0 THEN 1 END) as count,
    3 as sort_order
FROM "vanalytics"."active_vulnerabilities" av
JOIN "vanalytics"."endpoints" e ON av.endpoint_id = e.endpoint_id
WHERE e.alive = true
UNION ALL
SELECT 
    'Low' as severity,
    COUNT(CASE WHEN av.vulnerability_v3_base_score < 4.0 THEN 1 END) as count,
    4 as sort_order
FROM "vanalytics"."active_vulnerabilities" av
JOIN "vanalytics"."endpoints" e ON av.endpoint_id = e.endpoint_id
WHERE e.alive = true
ORDER BY sort_order;
```

<BarChart
    data={vulnerability_distribution}
    title="Vulnerability Distribution by Severity"
    x=severity
    y=count
    sort=false
/>

---

## Top Critical Exposures

### Vulnerabilities Requiring Immediate Action

```sql critical_vulns
-- Top critical vulnerabilities with asset count
SELECT 
        av.cve,
        av.vulnerability_v3_base_score,
        av.sensitivity_level_name,
        av.product_name,
        COUNT(DISTINCT av.asset) as Affected_Assets, -- Count distinct assets per CVE
        av.vulnerability_summary
    FROM "vanalytics"."active_vulnerabilities" av
    WHERE av.vulnerability_v3_base_score >= 7.0
    GROUP BY 
        av.cve, 
        av.vulnerability_v3_base_score, 
        av.sensitivity_level_name, 
        av.product_name,
        av.vulnerability_summary
	ORDER By 
		av.vulnerability_v3_base_score DESC,
		affected_assets DESC,
		av.cve DESC
	limit 50;
```

<DataTable
    data={critical_vulns}
    title="Critical Vulnerabilities Requiring Immediate Action"
    sortable=true>
    <Column id=cve/>
    <Column id=vulnerability_v3_base_score contentType=colorscale colorScale={['#6db678','#ebbb38','#ce5050']}/>
    <Column id=product_name/>
    <Column id=Affected_Assets contentType=colorscale colorScale={['#6db678','#ebbb38','#ce5050']}/>
</DataTable>

---
## Top Asset Exposures

### Assets Requiring Immediate Action

```sql critical_vulns_asset
-- Top critical assets with cve count
SELECT 
    av.asset,
    COUNT(DISTINCT CASE WHEN av.vulnerability_v3_base_score >= 9.0 THEN av.cve END) AS Critical_CVE_Count,
    COUNT(DISTINCT CASE WHEN av.vulnerability_v3_base_score >= 7.0 AND av.vulnerability_v3_base_score < 9.0 THEN av.cve END) AS High_CVE_Count
FROM "vanalytics"."active_vulnerabilities" av
WHERE av.vulnerability_v3_base_score >= 7.0
GROUP BY 
    av.asset
ORDER BY 
    Critical_CVE_Count DESC,
    High_CVE_Count DESC,
    av.asset ASC
limit 20;
```

<DataTable
    data={critical_vulns_asset}
    title="Top critical assets with cve count"
    sortable=true>
    <Column id=asset/>
    <Column id=Critical_CVE_Count contentType=colorscale colorScale={['#6db678','#ebbb38','#ce5050']}/>
    <Column id=High_CVE_Count contentType=colorscale colorScale={['#6db678','#ebbb38','#ce5050']}/>
</DataTable>

---

## Security Posture Maturity

### Key Security Posture Metrics

```sql posture_metrics
-- Security posture metrics
SELECT 
    'Patch Compliance Rate (%)' as metric_name,
    ROUND(
        ((COUNT(DISTINCT CASE WHEN av.patch_name IS NOT NULL THEN av.endpoint_id END) * 100.0 / 
         COUNT(DISTINCT av.endpoint_id))::numeric), 2
    ) as current_value,
    95.0 as target_value
FROM "vanalytics"."active_vulnerabilities" av
JOIN endpoints e ON av.endpoint_id = e.endpoint_id

UNION ALL
SELECT 
    'Vulnerability Density' as metric_name,
    ROUND((COUNT(av.cve) * 1.0 / COUNT(DISTINCT av.endpoint_id))::numeric, 2) as current_value,
    2.0 as target_value
FROM "vanalytics"."active_vulnerabilities" av
JOIN endpoints e ON av.endpoint_id = e.endpoint_id;
```

<DataTable
    data={posture_metrics}
    title="Security Posture Metrics"
/>

<BarChart
    data={posture_metrics}
    title="Security Posture Status"
    x=metric_name
    type=grouped
/>

### Interpreting Security Posture Metrics

**Patch Compliance Rate**
- **Definition**: The percentage of endpoints that have available patches applied for their vulnerabilities
- **Calculation**: (Endpoints with patches applied ÷ Total endpoints) × 100
- **Target**: 95% or higher indicates mature patch management
- **Interpretation**: 
  - **90-100**: Excellent - Strong patch management program
  - **80-89**: Good - Minor gaps in patching process
  - **70-79**: Fair - Significant patching delays or gaps
  - **Under 70%**: Poor - Critical patch management issues requiring immediate attention

**Vulnerability Density**
- **Definition**: Average number of vulnerabilities per endpoint across the environment
- **Calculation**: Total vulnerabilities ÷ Total active endpoints
- **Target**: 2.0 or lower indicates well-managed vulnerability landscape
- **Interpretation**:
  - **0-2.0**: Excellent - Well-controlled vulnerability environment
  - **2.1-5.0**: Good - Acceptable vulnerability levels with room for improvement
  - **5.1-10.0**: Fair - Elevated risk requiring focused remediation efforts
  - **Over 10.0**: Poor - High-risk environment requiring immediate security intervention

**Strategic Implications**:
- **High Patch Compliance + Low Vulnerability Density**: Mature security posture with effective vulnerability management
- **Low Patch Compliance + High Vulnerability Density**: Critical security gaps requiring immediate executive attention and resource allocation
- **Mixed Results**: Indicates inconsistent security practices across different asset groups or time periods

---

## Risk Trend Analysis

### 90-Day Risk Trajectory

```sql risk_trends
-- Simplified risk trends
SELECT
    CAST(iv.h_created_at AS DATE) AS event_date,
    COUNT(CASE WHEN iv.event_type = 'DetectedActive' THEN 1 END) AS detected_count,
    COUNT(CASE WHEN iv.event_type = 'MitigatedVulnerability' THEN 1 END) AS mitigated_count
FROM incidentevents iv
WHERE iv.h_created_at >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY CAST(iv.h_created_at AS DATE)
ORDER BY event_date DESC
LIMIT 30;
```

<LineChart
    data={risk_trends}
    title="Vulnerability Trends Over Time"
    x=event_date
    y=detected_count
    y2=mitigated_count
/>

### Key Performance Indicators

```sql performance_metrics
-- Simplified performance metrics
SELECT 
    'Mean Time to Remediate (Hours)' as kpi_name,
    ROUND(AVG(mtv.mitigation_time_hours)::numeric, 2) as current_value,
    24.0 as benchmark_value
FROM "vanalytics"."mitigation_time_view" mtv
WHERE mtv.mitigation_time_hours IS NOT NULL
UNION ALL
SELECT 
    'Vulnerability Density' as kpi_name,
    ROUND((COUNT(av.cve) * 1.0 / COUNT(DISTINCT av.endpoint_id))::numeric, 2) as current_value,
    2.0 as benchmark_value
FROM "vanalytics"."active_vulnerabilities" av
JOIN endpoints e ON av.endpoint_id = e.endpoint_id
WHERE e.alive = true;
```

<DataTable
    data={performance_metrics}
    title="Key Performance Indicators"
/>

<BarChart
    data={performance_metrics}
    title="Performance KPIs vs Benchmarks"
    x=kpi_name
    y=current_value
    y2=benchmark_value
/>

---

## Strategic Recommendations

### Priority Actions for Next Period

Based on the current vulnerability landscape, the following actions are recommended:

1. **Address Critical Vulnerabilities**
   - Focus on {critical_vulns[0]?.count || 0} critical vulnerabilities
   - Prioritize vulnerabilities with high CVSS scores requiring immediate attention
   - Target SLA compliance improvements

2. **Improve Mitigation Performance**
   - Focus on reducing time to remediation for critical vulnerabilities
   - Implement automated patching where possible
   - Monitor mitigation performance metrics

3. **Enhance Security Posture**
   - Improve patch compliance rates
   - Reduce vulnerability density per endpoint
   - Strengthen vulnerability monitoring and response

---

## Appendix: Methodology

**Vulnerability Scoring:** CVSS v3.1 + EPSS  
**Threat Intelligence:** CISA KEV + VulnCheck  
**Data Sources:** PostgreSQL vulnerability management database

### Data Sources
- Vulnerability Scanner: Integrated vulnerability scanner
- Asset Inventory: Endpoint management system
- Threat Intelligence: CISA KEV, VulnCheck, EPSS
- Incident Tracking: Custom incident management system

### Report Distribution
- **Frequency:** Monthly
- **Next Report:** Next Month
- **Contact:** Security Team

---

*This report contains confidential business information. Distribution limited to authorized personnel only.*