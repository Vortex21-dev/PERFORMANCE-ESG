import { supabase } from '../lib/supabase';
import toast from 'react-hot-toast';

export interface DashboardValidationResult {
  test_name: string;
  passed: boolean;
  details: string;
  recommendation: string;
}

export interface DashboardHealthSummary {
  organization_name: string;
  total_indicators: number;
  indicators_with_data: number;
  data_completeness_rate: number;
  last_data_update: string;
  view_status: 'excellent' | 'good' | 'fair' | 'poor';
  recommendations: string[];
}

/**
 * Validates dashboard data integrity for an organization
 */
export async function validateDashboardIntegrity(
  organizationName: string
): Promise<DashboardValidationResult[]> {
  try {
    const { data, error } = await supabase
      .rpc('validate_dashboard_data_integrity', { org_name: organizationName });

    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('Error validating dashboard integrity:', error);
    toast.error('Erreur lors de la validation de l\'intégrité des données');
    return [];
  }
}

/**
 * Gets comprehensive health status for an organization
 */
export async function getDashboardHealth(
  organizationName: string
): Promise<DashboardHealthSummary | null> {
  try {
    const { data, error } = await supabase
      .rpc('check_dashboard_comprehensive_health', { org_name: organizationName });

    if (error) throw error;
    return data?.[0] || null;
  } catch (error) {
    console.error('Error getting dashboard health:', error);
    toast.error('Erreur lors de la vérification de l\'état du tableau de bord');
    return null;
  }
}

/**
 * Attempts to recover dashboard view functionality
 */
export async function recoverDashboardView(): Promise<boolean> {
  try {
    const { data, error } = await supabase
      .rpc('auto_recover_dashboard_view');

    if (error) throw error;
    
    if (data) {
      toast.success('Tableau de bord récupéré avec succès');
      return true;
    } else {
      toast.warning('Récupération partielle - Certaines fonctionnalités peuvent être limitées');
      return false;
    }
  } catch (error) {
    console.error('Error recovering dashboard view:', error);
    toast.error('Erreur lors de la récupération du tableau de bord');
    return false;
  }
}

/**
 * Validates that all expected indicators are present in the dashboard
 */
export async function validateIndicatorCoverage(
  organizationName: string
): Promise<{
  configured: number;
  displayed: number;
  missing: string[];
  coverage_rate: number;
}> {
  try {
    // Get configured indicators
    const { data: configuredData, error: configError } = await supabase
      .from('organization_indicators')
      .select('indicator_codes')
      .eq('organization_name', organizationName)
      .single();

    if (configError) throw configError;

    const configuredCodes = configuredData?.indicator_codes || [];

    // Get indicators in dashboard
    const { data: dashboardData, error: dashboardError } = await supabase
      .from('dashboard_performance_view')
      .select('indicator_code')
      .eq('organization_name', organizationName);

    if (dashboardError) throw dashboardError;

    const displayedCodes = dashboardData?.map(d => d.indicator_code) || [];
    const uniqueDisplayed = [...new Set(displayedCodes)];
    
    // Find missing indicators
    const missing = configuredCodes.filter(code => !uniqueDisplayed.includes(code));
    
    const coverage_rate = configuredCodes.length > 0 
      ? (uniqueDisplayed.length / configuredCodes.length) * 100 
      : 100;

    return {
      configured: configuredCodes.length,
      displayed: uniqueDisplayed.length,
      missing,
      coverage_rate
    };
  } catch (error) {
    console.error('Error validating indicator coverage:', error);
    return {
      configured: 0,
      displayed: 0,
      missing: [],
      coverage_rate: 0
    };
  }
}

/**
 * Performs comprehensive dashboard diagnostics
 */
export async function runDashboardDiagnostics(
  organizationName: string
): Promise<{
  health: DashboardHealthSummary | null;
  validation: DashboardValidationResult[];
  coverage: Awaited<ReturnType<typeof validateIndicatorCoverage>>;
  overall_status: 'healthy' | 'warning' | 'critical';
}> {
  const [health, validation, coverage] = await Promise.all([
    getDashboardHealth(organizationName),
    validateDashboardIntegrity(organizationName),
    validateIndicatorCoverage(organizationName)
  ]);

  // Determine overall status
  let overall_status: 'healthy' | 'warning' | 'critical' = 'healthy';
  
  if (
    !health || 
    health.view_status === 'poor' || 
    coverage.coverage_rate < 50 ||
    validation.some(v => !v.passed && v.test_name === 'indicator_coverage')
  ) {
    overall_status = 'critical';
  } else if (
    health.view_status === 'fair' || 
    coverage.coverage_rate < 80 ||
    validation.some(v => !v.passed)
  ) {
    overall_status = 'warning';
  }

  return {
    health,
    validation,
    coverage,
    overall_status
  };
}

/**
 * Formats validation results for display
 */
export function formatValidationResults(
  results: DashboardValidationResult[]
): string[] {
  return results
    .filter(result => !result.passed)
    .map(result => `${result.test_name}: ${result.details} - ${result.recommendation}`);
}

/**
 * Gets user-friendly status message
 */
export function getStatusMessage(
  overall_status: 'healthy' | 'warning' | 'critical'
): { message: string; color: string; icon: string } {
  switch (overall_status) {
    case 'healthy':
      return {
        message: 'Tableau de bord opérationnel',
        color: 'text-green-600',
        icon: 'CheckCircle'
      };
    case 'warning':
      return {
        message: 'Problèmes mineurs détectés',
        color: 'text-yellow-600',
        icon: 'AlertTriangle'
      };
    case 'critical':
      return {
        message: 'Problèmes critiques nécessitant une attention',
        color: 'text-red-600',
        icon: 'XCircle'
      };
    default:
      return {
        message: 'État inconnu',
        color: 'text-gray-600',
        icon: 'HelpCircle'
      };
  }
}