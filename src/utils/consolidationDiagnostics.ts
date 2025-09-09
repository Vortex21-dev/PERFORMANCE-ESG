import { supabase } from '../lib/supabase';

export interface ConsolidationDiagnostic {
  step: string;
  status: 'pass' | 'fail' | 'warning';
  details: string;
  recommendation?: string;
}

export interface SiteDataDiagnostic {
  site_name: string;
  organization_name: string;
  business_line_name?: string;
  subsidiary_name?: string;
  has_raw_data: boolean;
  has_validated_data: boolean;
  appears_in_consolidated: boolean;
  hierarchy_complete: boolean;
  issues: string[];
}

/**
 * Comprehensive diagnostic for site data consolidation
 */
export async function diagnoseSiteConsolidation(
  siteName: string,
  organizationName: string
): Promise<{
  diagnostics: ConsolidationDiagnostic[];
  siteInfo: SiteDataDiagnostic | null;
  recommendations: string[];
}> {
  const diagnostics: ConsolidationDiagnostic[] = [];
  const recommendations: string[] = [];
  let siteInfo: SiteDataDiagnostic | null = null;

  try {
    // Step 1: Verify site exists and hierarchy
    const { data: siteData, error: siteError } = await supabase
      .from('sites')
      .select('name, organization_name, business_line_name, subsidiary_name')
      .eq('name', siteName)
      .eq('organization_name', organizationName)
      .single();

    if (siteError || !siteData) {
      diagnostics.push({
        step: 'Site Existence Check',
        status: 'fail',
        details: `Site "${siteName}" not found in organization "${organizationName}"`,
        recommendation: 'Verify site name and organization assignment'
      });
      return { diagnostics, siteInfo: null, recommendations: ['Site not found - check site configuration'] };
    }

    diagnostics.push({
      step: 'Site Existence Check',
      status: 'pass',
      details: `Site "${siteName}" found with hierarchy: ${siteData.business_line_name || 'No BL'} > ${siteData.subsidiary_name || 'No Sub'}`
    });

    // Step 2: Check for raw indicator data
    const { data: rawData, error: rawError } = await supabase
      .from('indicator_values')
      .select('id, status, value, year, month')
      .eq('organization_name', organizationName)
      .eq('site_name', siteName)
      .not('value', 'is', null);

    const hasRawData = !rawError && rawData && rawData.length > 0;
    const validatedData = rawData?.filter(d => d.status === 'validated') || [];
    const hasValidatedData = validatedData.length > 0;

    diagnostics.push({
      step: 'Raw Data Check',
      status: hasRawData ? 'pass' : 'fail',
      details: `Found ${rawData?.length || 0} indicator values, ${validatedData.length} validated`,
      recommendation: !hasRawData ? 'Add indicator data for this site' : undefined
    });

    // Step 3: Check consolidated data presence
    const { data: consolidatedData, error: consolidatedError } = await supabase
      .from('site_indicator_values_consolidated')
      .select('id, value_consolidated, sites_count')
      .eq('organization_name', organizationName)
      .or(`site_name.eq.${siteName},site_name.is.null`);

    const appearsInConsolidated = !consolidatedError && consolidatedData && consolidatedData.length > 0;

    diagnostics.push({
      step: 'Consolidated Data Check',
      status: appearsInConsolidated ? 'pass' : 'fail',
      details: `Found ${consolidatedData?.length || 0} consolidated records for site`,
      recommendation: !appearsInConsolidated ? 'Refresh consolidation views or check consolidation logic' : undefined
    });

    // Step 4: Check hierarchy completeness
    const hierarchyComplete = !!(siteData.business_line_name && siteData.subsidiary_name);
    
    diagnostics.push({
      step: 'Hierarchy Completeness',
      status: hierarchyComplete ? 'pass' : 'warning',
      details: `Business Line: ${siteData.business_line_name || 'Missing'}, Subsidiary: ${siteData.subsidiary_name || 'Missing'}`,
      recommendation: !hierarchyComplete ? 'Complete site hierarchy assignment' : undefined
    });

    // Step 5: Check consolidation view health
    const { data: viewHealth, error: viewError } = await supabase
      .from('dashboard_performance_view')
      .select('organization_name')
      .eq('organization_name', organizationName)
      .limit(1);

    diagnostics.push({
      step: 'Consolidation View Health',
      status: !viewError && viewHealth ? 'pass' : 'fail',
      details: viewError ? `View error: ${viewError.message}` : 'Consolidation view accessible',
      recommendation: viewError ? 'Refresh materialized views' : undefined
    });

    // Compile site info
    siteInfo = {
      site_name: siteName,
      organization_name: organizationName,
      business_line_name: siteData.business_line_name,
      subsidiary_name: siteData.subsidiary_name,
      has_raw_data: hasRawData,
      has_validated_data: hasValidatedData,
      appears_in_consolidated: appearsInConsolidated,
      hierarchy_complete: hierarchyComplete,
      issues: diagnostics.filter(d => d.status === 'fail').map(d => d.details)
    };

    // Generate recommendations
    if (!hasValidatedData) {
      recommendations.push('Ensure site data is validated before consolidation');
    }
    if (!appearsInConsolidated) {
      recommendations.push('Refresh consolidation views and check aggregation logic');
    }
    if (!hierarchyComplete) {
      recommendations.push('Complete site hierarchy assignment (business line and subsidiary)');
    }

    return { diagnostics, siteInfo, recommendations };

  } catch (error) {
    console.error('Error in consolidation diagnosis:', error);
    diagnostics.push({
      step: 'Diagnostic Process',
      status: 'fail',
      details: `Diagnostic failed: ${error.message}`,
      recommendation: 'Check database connectivity and permissions'
    });
    
    return { diagnostics, siteInfo: null, recommendations: ['Diagnostic process failed'] };
  }
}

/**
 * Attempts to fix common consolidation issues
 */
export async function fixConsolidationIssues(
  siteName: string,
  organizationName: string
): Promise<{
  success: boolean;
  actions_taken: string[];
  remaining_issues: string[];
}> {
  const actionsTaken: string[] = [];
  const remainingIssues: string[] = [];

  try {
    // Action 1: Refresh materialized views
    try {
      await supabase.rpc('refresh_dashboard_performance_view');
      actionsTaken.push('Refreshed dashboard performance view');
    } catch (error) {
      remainingIssues.push(`Failed to refresh views: ${error.message}`);
    }

    // Action 2: Trigger consolidation update
    try {
      await supabase.rpc('trigger_consolidation_update');
      actionsTaken.push('Triggered consolidation update');
    } catch (error) {
      console.warn('Consolidation trigger not available:', error);
    }

    // Action 3: Update site hierarchy if incomplete
    const { data: siteData } = await supabase
      .from('sites')
      .select('business_line_name, subsidiary_name')
      .eq('name', siteName)
      .eq('organization_name', organizationName)
      .single();

    if (siteData && (!siteData.business_line_name || !siteData.subsidiary_name)) {
      // Try to auto-assign based on organization structure
      const { data: subsidiaries } = await supabase
        .from('subsidiaries')
        .select('name, business_line_name')
        .eq('organization_name', organizationName)
        .limit(1);

      if (subsidiaries && subsidiaries.length > 0) {
        const subsidiary = subsidiaries[0];
        await supabase
          .from('sites')
          .update({
            subsidiary_name: subsidiary.name,
            business_line_name: subsidiary.business_line_name
          })
          .eq('name', siteName)
          .eq('organization_name', organizationName);
        
        actionsTaken.push(`Auto-assigned site to subsidiary: ${subsidiary.name}`);
      }
    }

    // Action 4: Force consolidation recalculation
    try {
      const { data: indicatorValues } = await supabase
        .from('indicator_values')
        .select('id')
        .eq('organization_name', organizationName)
        .eq('site_name', siteName)
        .eq('status', 'validated')
        .limit(1);

      if (indicatorValues && indicatorValues.length > 0) {
        // Trigger consolidation by updating a record
        await supabase
          .from('indicator_values')
          .update({ updated_at: new Date().toISOString() })
          .eq('id', indicatorValues[0].id);
        
        actionsTaken.push('Triggered consolidation recalculation');
      }
    } catch (error) {
      remainingIssues.push(`Failed to trigger recalculation: ${error.message}`);
    }

    return {
      success: remainingIssues.length === 0,
      actions_taken: actionsTaken,
      remaining_issues: remainingIssues
    };

  } catch (error) {
    console.error('Error fixing consolidation issues:', error);
    return {
      success: false,
      actions_taken: actionsTaken,
      remaining_issues: [`Fix process failed: ${error.message}`]
    };
  }
}

/**
 * Validates that consolidation is working correctly
 */
export async function validateConsolidationWorking(
  organizationName: string
): Promise<{
  is_working: boolean;
  issues: string[];
  metrics: {
    total_sites: number;
    sites_with_data: number;
    sites_in_consolidated: number;
    consolidation_rate: number;
  };
}> {
  try {
    // Get all sites for organization
    const { data: sites } = await supabase
      .from('sites')
      .select('name')
      .eq('organization_name', organizationName);

    const totalSites = sites?.length || 0;

    // Get sites with validated data
    const { data: sitesWithData } = await supabase
      .from('indicator_values')
      .select('site_name')
      .eq('organization_name', organizationName)
      .eq('status', 'validated')
      .not('value', 'is', null);

    const uniqueSitesWithData = [...new Set(sitesWithData?.map(s => s.site_name))].length;

    // Get sites in consolidated view
    const { data: consolidatedSites } = await supabase
      .from('site_indicator_values_consolidated')
      .select('site_name')
      .eq('organization_name', organizationName);

    const uniqueConsolidatedSites = [...new Set(consolidatedSites?.map(s => s.site_name))].length;

    const consolidationRate = uniqueSitesWithData > 0 
      ? (uniqueConsolidatedSites / uniqueSitesWithData) * 100 
      : 0;

    const issues: string[] = [];
    
    if (consolidationRate < 100) {
      issues.push(`Only ${consolidationRate.toFixed(1)}% of sites with data appear in consolidated view`);
    }
    
    if (totalSites === 0) {
      issues.push('No sites configured for organization');
    }
    
    if (uniqueSitesWithData === 0) {
      issues.push('No sites have validated data');
    }

    return {
      is_working: issues.length === 0 && consolidationRate >= 95,
      issues,
      metrics: {
        total_sites: totalSites,
        sites_with_data: uniqueSitesWithData,
        sites_in_consolidated: uniqueConsolidatedSites,
        consolidation_rate: consolidationRate
      }
    };

  } catch (error) {
    console.error('Error validating consolidation:', error);
    return {
      is_working: false,
      issues: [`Validation failed: ${error.message}`],
      metrics: {
        total_sites: 0,
        sites_with_data: 0,
        sites_in_consolidated: 0,
        consolidation_rate: 0
      }
    };
  }
}