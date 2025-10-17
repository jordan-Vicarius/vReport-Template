---
title: Welcome to vReports
---

<Details title='How to edit this page'>

  This page can be found in your project at `/pages/index.md`. Make a change to the markdown file and save it to see the change take effect in your browser.
</Details>

```sql ActiveVulns
SELECT
  "vanalytics"."mitigation_performance_view"."event_type" AS "event_type",
  SUM(
    CASE
      WHEN "vanalytics"."mitigation_performance_view"."event_type" = 'DetectedActive' THEN 1
      ELSE 0.0
    END
  ) AS "Active_CVE",
  SUM(
    CASE
      WHEN "vanalytics"."mitigation_performance_view"."event_type" = 'MitigatedVulnerability' THEN 1
      ELSE 0.0
    END
  ) AS "Mitigated_CVE"
FROM
  "vanalytics"."mitigation_performance_view"
GROUP BY
  "vanalytics"."mitigation_performance_view"."event_type"
ORDER BY
  "vanalytics"."mitigation_performance_view"."event_type" ASC
```

<BarChart
    data={ActiveVulns}
    title="Vulnerability Status Comparison"
    x=event_type
    y=Active_CVE
    y2=Mitigated_CVE
    type=grouped
/>

## What's Next?
- [Connect your data sources](settings)
- [View CMMC Vulnerability Assessment Dashboard](cmmc-vulnerability-assessment-dashboard)
- [View Executive Risk Dashboard](executive)
- Edit/add markdown files in the `pages` folder
- Deploy your project with [Evidence Cloud](https://evidence.dev/cloud)

## Get Support
- Message us on [Slack](https://slack.evidence.dev/)
- Read the [Docs](https://docs.evidence.dev/)
- Open an issue on [Github](https://github.com/evidence-dev/evidence)
