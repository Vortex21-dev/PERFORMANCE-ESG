# Dashboard Troubleshooting Guide

## Overview

This guide provides comprehensive troubleshooting procedures for the Performance ESG dashboard system, addressing the three critical issues that were identified and resolved.

## Root Cause Analysis

### Issue 1: Incomplete Database View
**Problem**: The `dashboard_performance_view` materialized view was missing critical performance indicators due to incomplete JOIN operations and overly restrictive WHERE clauses.

**Root Causes**:
- Missing LEFT JOINs caused indicators without complete metadata to be excluded
- Complex nested queries for standards/issues/criteria relationships failed silently
- No fallback mechanism for indicators without historical data

**Impact**: Users saw incomplete dashboards with missing indicators, leading to inaccurate performance assessments.

### Issue 2: Missing Joins
**Problem**: Indicators were not properly linked to their corresponding processes, standards, issues, and criteria.

**Root Causes**:
- Array-based relationships in `processes.indicator_codes` not properly handled
- Complex many-to-many relationships through sector/subsector tables
- Missing NULL-safe operations in JOIN conditions

**Impact**: Indicators appeared without proper context (process names, ESG categories, etc.).

### Issue 3: Overly Restrictive Filtering
**Problem**: Current filters excluded valid indicators that should be displayed.

**Root Causes**:
- INNER JOINs instead of LEFT JOINs excluded indicators without complete data
- No handling for indicators with zero values or missing monthly data
- Strict validation rules prevented display of partially configured indicators

**Impact**: Dashboard showed fewer indicators than actually configured, hiding important tracking items.

## Solution Implementation

### 1. Enhanced Materialized View

The new `dashboard_performance_view` includes:

```sql
-- Comprehensive metadata joins with NULL safety
WITH indicator_metadata AS (
  SELECT DISTINCT
    i.code as indicator_code,
    i.name as indicator_name,
    -- ... complete metadata with fallbacks
  FROM indicators i
  CROSS JOIN processes p
  WHERE i.code = ANY(p.indicator_codes)
)
```

**Key Improvements**:
- Uses `CROSS JOIN` with `ANY()` to properly handle array relationships
- Includes comprehensive metadata from all related tables
- Provides fallback values for missing relationships
- Uses `COALESCE()` for NULL-safe operations

### 2. Robust Data Aggregation

```sql
monthly_aggregations AS (
  SELECT 
    -- NULL-safe monthly calculations
    COALESCE(SUM(CASE WHEN iv.month = 1 THEN iv.value END), 0) as janvier,
    -- ... other months
    
    -- Formula-based aggregation
    CASE 
      WHEN im.formule = 'somme' THEN COALESCE(SUM(iv.value), 0)
      WHEN im.formule = 'moyenne' THEN COALESCE(AVG(iv.value), 0)
      -- ... other formulas
    END as valeur_totale
  FROM indicator_values iv
  JOIN indicator_metadata im ON iv.indicator_code = im.indicator_code
)
```

**Key Improvements**:
- Handles different aggregation formulas (sum, average, max, min, last month)
- NULL-safe calculations prevent missing data
- Proper grouping ensures accurate aggregations

### 3. Comprehensive Indicator Coverage

```sql
-- Include ALL indicators, even those without values
UNION ALL
SELECT 
  -- ... metadata columns
  0 as janvier, 0 as fevrier, -- ... zero values for empty indicators
FROM organization_indicators oi
JOIN indicators i ON i.code = ANY(oi.indicator_codes)
WHERE NOT EXISTS (
  SELECT 1 FROM indicator_values iv 
  WHERE iv.indicator_code = i.code
  AND iv.year = EXTRACT(YEAR FROM CURRENT_DATE)
)
```

**Key Improvements**:
- UNION ALL ensures all configured indicators appear
- Zero values for indicators without data
- Maintains dashboard completeness

## Fallback Mechanisms

### 1. Fallback View
Created `dashboard_performance_view_fallback` with simplified structure:
- Basic indicator-process relationships only
- Minimal metadata requirements
- Guaranteed to work even with incomplete data

### 2. Error Handling in Frontend
```typescript
try {
  // Try main view
  const result = await supabase.from('dashboard_performance_view')...
} catch (mainViewError) {
  // Use fallback view
  const fallbackResult = await supabase.from('dashboard_performance_view_fallback')...
}
```

### 3. Basic Data Transformation
Final fallback transforms raw `indicator_values` data:
- Groups by indicator and process
- Calculates basic monthly aggregations
- Provides minimal but functional dashboard

## Monitoring and Alerting

### 1. Health Check Functions
- `check_dashboard_view_health()`: Basic view status
- `check_dashboard_comprehensive_health()`: Detailed analysis
- `validate_dashboard_data_integrity()`: Data quality tests

### 2. Automated Recovery
- `auto_recover_dashboard_view()`: Attempts automatic repair
- `maintain_dashboard_performance()`: Scheduled maintenance
- Trigger-based refresh on data changes

### 3. Monitoring Dashboard
- Real-time health indicators
- Performance metrics tracking
- Automated alerting for issues

## Testing Strategy

### 1. Data Integrity Tests
```sql
-- Test 1: Indicator Coverage
SELECT COUNT(*) FROM organization_indicators oi
JOIN indicators i ON i.code = ANY(oi.indicator_codes)
WHERE oi.organization_name = 'TestOrg';

-- Should equal:
SELECT COUNT(DISTINCT indicator_code) 
FROM dashboard_performance_view 
WHERE organization_name = 'TestOrg';
```

### 2. Performance Tests
- Load testing with 10,000+ indicators
- Query performance under concurrent access
- Memory usage during view refresh

### 3. Edge Case Tests
- Organizations with no data
- Indicators with only partial monthly data
- Complex organizational hierarchies
- Missing metadata relationships

## Troubleshooting Procedures

### Problem: Dashboard Shows No Data

**Diagnosis Steps**:
1. Check `DashboardHealthIndicator` status
2. Run comprehensive diagnostics
3. Validate organization configuration

**Solutions**:
1. Force refresh materialized view
2. Check indicator configuration in `organization_indicators`
3. Verify data exists in `indicator_values`
4. Use fallback view if main view fails

### Problem: Missing Indicators

**Diagnosis Steps**:
1. Check indicator coverage metrics
2. Validate process-indicator relationships
3. Review organization ESG configuration

**Solutions**:
1. Update `processes.indicator_codes` arrays
2. Refresh organization indicators configuration
3. Re-run ESG setup process if needed

### Problem: Incorrect Calculations

**Diagnosis Steps**:
1. Check formula configuration in `indicators.formule`
2. Validate monthly data in `indicator_values`
3. Review target values and previous year data

**Solutions**:
1. Correct formula settings
2. Recalculate aggregations
3. Update target value logic

### Problem: Performance Issues

**Diagnosis Steps**:
1. Check materialized view size
2. Monitor query execution time
3. Review index usage

**Solutions**:
1. Refresh materialized view during off-peak hours
2. Add missing indexes
3. Consider view partitioning for large datasets

## Maintenance Procedures

### Daily
- Automated health checks
- Performance monitoring
- Error log review

### Weekly
- Comprehensive data validation
- View refresh optimization
- User feedback review

### Monthly
- Full system diagnostics
- Performance tuning
- Capacity planning review

## Recovery Procedures

### Automatic Recovery
1. Trigger-based view refresh on data changes
2. Automated error detection and logging
3. Self-healing mechanisms for common issues

### Manual Recovery
1. Force refresh via diagnostics panel
2. Recreate view with simplified structure
3. Restore from backup if needed

### Emergency Procedures
1. Switch to fallback view immediately
2. Transform raw data in frontend
3. Notify users of limited functionality

## Performance Optimization

### Database Level
- Optimized indexes on frequently queried columns
- Materialized view for complex calculations
- Efficient aggregation queries

### Application Level
- Lazy loading of dashboard data
- Client-side caching with smart invalidation
- Progressive data loading for large datasets

### Monitoring Level
- Real-time performance metrics
- Automated alerting for slow queries
- Capacity planning based on usage patterns

## Security Considerations

### Data Access
- Row Level Security (RLS) on all views
- Organization-based data isolation
- Audit logging for all operations

### Error Handling
- No sensitive data in error messages
- Secure logging of diagnostic information
- Controlled access to recovery functions

### Monitoring
- Secure storage of monitoring data
- Access controls on diagnostic functions
- Privacy-compliant logging practices

This comprehensive solution ensures the dashboard system is robust, maintainable, and provides reliable performance data to all users while handling edge cases gracefully.