import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  BarChart3, 
  Download, 
  Filter, 
  Search, 
  Calendar,
  TrendingUp,
  TrendingDown,
  Target,
  AlertCircle,
  CheckCircle,
  Loader2,
  RefreshCw,
  Eye,
  FileText,
  Table
} from 'lucide-react';
import { supabase } from '../../lib/supabase';
import { useAuthStore } from '../../store/authStore';
import { useSearchParams } from 'react-router-dom';
import toast from 'react-hot-toast';
import jsPDF from 'jspdf';
import 'jspdf-autotable';

// Extend jsPDF type to include autoTable
declare module 'jspdf' {
  interface jsPDF {
    autoTable: (options: any) => jsPDF;
  }
}

interface DashboardData {
  organization_name: string;
  process_code: string;
  indicator_code: string;
  year: number;
  axe: string;
  enjeux: string;
  normes: string;
  criteres: string;
  processus: string;
  indicateur: string;
  unite: string;
  frequence: string;
  type: string;
  formule: string;
  janvier: number;
  fevrier: number;
  mars: number;
  avril: number;
  mai: number;
  juin: number;
  juillet: number;
  aout: number;
  septembre: number;
  octobre: number;
  novembre: number;
  decembre: number;
  valeur_cible: number;
  variation: number;
  performance: number;
  valeur_moyenne: number;
  last_updated: string;
}

interface FilterState {
  year: number;
  axe: string;
  processus: string;
  search: string;
}

export const DashboardTab: React.FC = () => {
  const { profile, impersonatedOrganization } = useAuthStore();
  const [searchParams] = useSearchParams();
  const [dashboardData, setDashboardData] = useState<DashboardData[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [filters, setFilters] = useState<FilterState>({
    year: new Date().getFullYear(),
    axe: 'all',
    processus: 'all',
    search: ''
  });
  const [sortConfig, setSortConfig] = useState<{
    key: keyof DashboardData | null;
    direction: 'asc' | 'desc';
  }>({ key: null, direction: 'asc' });

  const currentOrganization = impersonatedOrganization || profile?.organization_name;
  const isContributor = profile?.role === 'contributor';
  const selectedSite = searchParams.get('site');

  const months = [
    'janvier', 'fevrier', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'aout', 'septembre', 'octobre', 'novembre', 'decembre'
  ];

  const monthLabels = [
    'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
    'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
  ];

  useEffect(() => {
    if (currentOrganization) {
      fetchDashboardData();
    }
  }, [currentOrganization, filters.year, selectedSite]);

  const fetchDashboardData = async () => {
    if (!currentOrganization) return;

    try {
      setLoading(true);
      
      // Try to refresh the materialized view, but don't fail if it doesn't work
      try {
        await supabase.rpc('refresh_dashboard_performance_view');
      } catch (refreshError) {
        console.warn('Could not refresh materialized view, using existing data:', refreshError);
      }
      
      // Try main view first, fallback to backup view if needed
      let data, error;
      
      // Build query with site filter if specified
      let query = supabase
        .from('dashboard_performance_view')
        .select('*')
        .eq('organization_name', currentOrganization)
        .eq('year', filters.year);
      
      if (selectedSite) {
        // Filter by site if specified
        query = query.or(`site_name.eq.${selectedSite},site_name.is.null`);
      }
      
      try {
        const result = await query
          .order('process_code', { ascending: true })
          .order('indicator_code', { ascending: true });
        
        data = result.data;
        error = result.error;
      } catch (mainViewError) {
        console.warn('Main dashboard view failed, using fallback:', mainViewError);
        
        // Use fallback view
        let fallbackQuery = supabase
          .from('dashboard_performance_view_fallback')
          .select('*')
          .eq('organization_name', currentOrganization)
          .eq('year', filters.year);
        
        if (selectedSite) {
          fallbackQuery = fallbackQuery.or(`site_name.eq.${selectedSite},site_name.is.null`);
        }
        
        const fallbackResult = await fallbackQuery
          .order('process_code', { ascending: true })
          .order('indicator_code', { ascending: true });
        
        data = fallbackResult.data;
        error = fallbackResult.error;
        
        if (!error) {
          toast.error('Utilisation de la vue de secours - Certaines données peuvent être limitées');
        }
      }

      if (error) throw error;
      setDashboardData(data || []);
    } catch (error) {
      console.error('Error fetching dashboard data:', error);
      
      // Final fallback: try to get basic indicator data
      try {
        let basicQuery = supabase
          .from('indicator_values')
          .select(`
            organization_name,
            process_code,
            indicator_code,
            year,
            month,
            value,
            site_name,
            indicators (name, unit, axe, type, formule, frequence),
            processes (name, description)
          `)
          .eq('organization_name', currentOrganization)
          .eq('year', filters.year);
        
        if (selectedSite) {
          basicQuery = basicQuery.eq('site_name', selectedSite);
        }
        
        const { data: basicData, error: basicError } = await basicQuery;
        
        if (!basicError && basicData) {
          // Transform basic data to match dashboard format
          const transformedData = transformBasicDataToDashboardFormat(basicData);
          setDashboardData(transformedData);
          toast.warning('Données de base chargées - Vue complète temporairement indisponible');
        } else {
          throw new Error('Toutes les sources de données ont échoué');
        }
      } catch (finalError) {
        console.error('All data sources failed:', finalError);
        toast.error('Erreur lors du chargement des données du tableau de bord');
        setDashboardData([]);
      }
    } finally {
      setLoading(false);
    }
  };

  // Helper function to transform basic data to dashboard format
  const transformBasicDataToDashboardFormat = (basicData: any[]) => {
    const grouped = basicData.reduce((acc, row) => {
      const key = `${row.organization_name}-${row.process_code}-${row.indicator_code}-${row.year}`;
      if (!acc[key]) {
        acc[key] = {
          organization_name: row.organization_name,
          process_code: row.process_code,
          indicator_code: row.indicator_code,
          year: row.year,
          axe: row.indicators?.axe || 'Non défini',
          enjeux: 'Données limitées',
          normes: 'Données limitées',
          criteres: 'Données limitées',
          processus: row.processes?.name || 'Processus inconnu',
          indicateur: row.indicators?.name || row.indicator_code,
          unite: row.indicators?.unit || '',
          frequence: row.indicators?.frequence || 'mensuelle',
          type: row.indicators?.type || 'primaire',
          formule: row.indicators?.formule || 'somme',
          janvier: 0, fevrier: 0, mars: 0, avril: 0,
          mai: 0, juin: 0, juillet: 0, aout: 0,
          septembre: 0, octobre: 0, novembre: 0, decembre: 0,
          valeur_totale: 0,
          valeur_precedente: 0,
          valeur_cible: 0,
          variation: 0,
          performance: 0,
          valeur_moyenne: 0,
          last_updated: new Date().toISOString()
        };
      }
      
      // Add monthly value
      const monthNames = [
        'janvier', 'fevrier', 'mars', 'avril', 'mai', 'juin',
        'juillet', 'aout', 'septembre', 'octobre', 'novembre', 'decembre'
      ];
      const monthName = monthNames[row.month - 1];
      if (monthName && row.value !== null) {
        acc[key][monthName] = row.value;
        acc[key].valeur_totale += row.value;
      }
      
      return acc;
    }, {});
    
    return Object.values(grouped);
  };

  const handleRefresh = async () => {
    setRefreshing(true);
    await fetchDashboardData();
    setRefreshing(false);
    toast.success('Données actualisées');
  };

  const handleSort = (key: keyof DashboardData) => {
    setSortConfig(prev => ({
      key,
      direction: prev.key === key && prev.direction === 'asc' ? 'desc' : 'asc'
    }));
  };

  const handleExport = async (format: 'excel' | 'pdf') => {
    try {
      if (format === 'pdf') {
        // Create PDF document with dashboard-like formatting
        const doc = new jsPDF('l', 'mm', 'a1'); // A1 landscape for all columns
        
        // Modern header design
        doc.setFillColor(59, 130, 246); // Modern blue background
        doc.rect(0, 0, doc.internal.pageSize.width, 60, 'F');
        
        // White title text
        doc.setFontSize(24);
        doc.setFont('helvetica', 'bold');
        doc.setTextColor(255, 255, 255); // White text
        doc.text(`Tableau de Bord Performance ESG`, 40, 30);
        
        // Organization name
        doc.setFontSize(18);
        doc.text(`${currentOrganization}`, 40, 45);
        
        // Year and date info (right aligned)
        const pageWidth = doc.internal.pageSize.width;
        doc.setFontSize(14);
        const yearText = `Année ${filters.year}`;
        const yearWidth = doc.getTextWidth(yearText);
        doc.text(yearText, pageWidth - yearWidth - 40, 30);
        
        const dateText = new Date().toLocaleDateString('fr-FR', {
          day: '2-digit',
          month: '2-digit', 
          year: 'numeric'
        });
        const dateWidth = doc.getTextWidth(dateText);
        doc.text(dateText, pageWidth - dateWidth - 40, 45);
        
        // Statistics cards section
        doc.setFillColor(248, 250, 252); // Very light blue-gray background
        doc.rect(0, 60, doc.internal.pageSize.width, 50, 'F');
        
        // Statistics
        doc.setFontSize(12);
        doc.setTextColor(71, 85, 105); // Slate gray text
        
        const totalIndicators = filteredAndSortedData.length;
        const avgPerformance = totalIndicators > 0 ? 
          (filteredAndSortedData.reduce((sum, row) => sum + (row.performance || 0), 0) / totalIndicators).toFixed(1) : '0';
        const objectifsAtteints = filteredAndSortedData.filter(row => (row.performance || 0) >= 100).length;
        const alertes = filteredAndSortedData.filter(row => (row.performance || 0) < 70).length;
        
        // Statistics boxes
        const statsY = 75;
        const statBoxWidth = 180;
        const statBoxHeight = 30;
        const statSpacing = 220;
        
        // Total Indicateurs
        doc.setFillColor(59, 130, 246); // Modern blue
        doc.roundedRect(40, statsY, statBoxWidth, statBoxHeight, 5, 5, 'F');
        doc.setTextColor(255, 255, 255);
        doc.setFontSize(10);
        doc.text('TOTAL INDICATEURS', 50, statsY + 10);
        doc.setFontSize(16);
        doc.setFont('helvetica', 'bold');
        doc.text(totalIndicators.toString(), 50, statsY + 22);
        
        // Performance Moyenne
        doc.setFillColor(34, 197, 94); // Modern green
        doc.roundedRect(40 + statSpacing, statsY, statBoxWidth, statBoxHeight, 5, 5, 'F');
        doc.setFontSize(10);
        doc.setFont('helvetica', 'normal');
        doc.text('PERFORMANCE MOYENNE', 50 + statSpacing, statsY + 10);
        doc.setFontSize(16);
        doc.setFont('helvetica', 'bold');
        doc.text(`${avgPerformance}%`, 50 + statSpacing, statsY + 22);
        
        // Objectifs Atteints
        doc.setFillColor(16, 185, 129); // Emerald
        doc.roundedRect(40 + statSpacing * 2, statsY, statBoxWidth, statBoxHeight, 5, 5, 'F');
        doc.setFontSize(10);
        doc.setFont('helvetica', 'normal');
        doc.text('OBJECTIFS ATTEINTS', 50 + statSpacing * 2, statsY + 10);
        doc.setFontSize(16);
        doc.setFont('helvetica', 'bold');
        doc.text(objectifsAtteints.toString(), 50 + statSpacing * 2, statsY + 22);
        
        // Alertes
        doc.setFillColor(239, 68, 68); // Modern red
        doc.roundedRect(40 + statSpacing * 3, statsY, statBoxWidth, statBoxHeight, 5, 5, 'F');
        doc.setFontSize(10);
        doc.setFont('helvetica', 'normal');
        doc.text('ALERTES', 50 + statSpacing * 3, statsY + 10);
        doc.setFontSize(16);
        doc.setFont('helvetica', 'bold');
        doc.text(alertes.toString(), 50 + statSpacing * 3, statsY + 22);
        
        // Add filter information if any are active
        doc.setFontSize(10);
        doc.setTextColor(107, 114, 128);
        let filterInfo = '';
        if (filters.axe !== 'all') filterInfo += `Axe: ${filters.axe} • `;
        if (filters.processus !== 'all') filterInfo += `Processus: ${filters.processus} • `;
        if (filters.search) filterInfo += `Recherche: "${filters.search}" • `;
        
        if (filterInfo) {
          doc.text(`🔍 Filtres: ${filterInfo.slice(0, -3)}`, 40, 120);
        }
        
        // Prepare data for table
        const tableData = filteredAndSortedData.map(row => [
          row.axe || '-',
          (row.enjeux || '-').substring(0, 45) + ((row.enjeux || '').length > 45 ? '...' : ''),
          (row.normes || '-').substring(0, 30) + ((row.normes || '').length > 30 ? '...' : ''),
          (row.criteres || '-').substring(0, 30) + ((row.criteres || '').length > 30 ? '...' : ''),
          row.process_code || '-',
          (row.processus || '-').substring(0, 35) + ((row.processus || '').length > 35 ? '...' : ''),
          (row.indicateur || '-').substring(0, 40) + ((row.indicateur || '').length > 40 ? '...' : ''),
          row.unite || '-',
          row.frequence || '-',
          row.type || '-',
          row.formule || '-',
          row.janvier ? row.janvier.toLocaleString('fr-FR') : '-',
          row.fevrier ? row.fevrier.toLocaleString('fr-FR') : '-',
          row.mars ? row.mars.toLocaleString('fr-FR') : '-',
          row.avril ? row.avril.toLocaleString('fr-FR') : '-',
          row.mai ? row.mai.toLocaleString('fr-FR') : '-',
          row.juin ? row.juin.toLocaleString('fr-FR') : '-',
          row.juillet ? row.juillet.toLocaleString('fr-FR') : '-',
          row.aout ? row.aout.toLocaleString('fr-FR') : '-',
          row.septembre ? row.septembre.toLocaleString('fr-FR') : '-',
          row.octobre ? row.octobre.toLocaleString('fr-FR') : '-',
          row.novembre ? row.novembre.toLocaleString('fr-FR') : '-',
          row.decembre ? row.decembre.toLocaleString('fr-FR') : '-',
          row.valeur_cible ? row.valeur_cible.toLocaleString('fr-FR') : '-',
          row.variation ? `${row.variation > 0 ? '+' : ''}${row.variation.toFixed(1)}%` : '-',
          row.performance ? `${row.performance.toFixed(1)}%` : '-'
        ]);
        
        // Add table
        doc.autoTable({
          head: [[
            'Axe', 'Enjeux', 'Normes', 'Critères', 'Code\nProcessus', 'Processus',
            'Indicateur', 'Unité', 'Fréquence', 'Type', 'Formule',
            'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
            'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
            'Cible', 'Variation', 'Performance'
          ]],
          body: tableData,
          startY: 130,
          styles: {
            fontSize: 8,
            cellPadding: 3,
            lineColor: [229, 231, 235],
            lineWidth: 0.2,
            textColor: [31, 41, 55],
            fontStyle: 'normal',
            valign: 'middle',
            halign: 'center'
          },
          headStyles: {
            fillColor: [59, 130, 246], // Matching header blue
            textColor: [255, 255, 255],
            fontStyle: 'bold',
            fontSize: 9,
            cellPadding: 4,
            halign: 'center',
            valign: 'middle',
            lineWidth: 0
          },
          alternateRowStyles: {
            fillColor: [248, 250, 252] // Very light blue-gray
          },
          bodyStyles: {
            fontSize: 8,
            cellPadding: 3,
            valign: 'middle',
            halign: 'center'
          },
          columnStyles: {
            0: { cellWidth: 35, halign: 'center', fillColor: [219, 234, 254], fontSize: 8, fontStyle: 'bold' }, // Axe
            1: { cellWidth: 60, fontSize: 7, overflow: 'linebreak', halign: 'left' }, // Enjeux
            2: { cellWidth: 45, fontSize: 7, overflow: 'linebreak', halign: 'left' }, // Normes
            3: { cellWidth: 45, fontSize: 7, overflow: 'linebreak', halign: 'left' }, // Critères
            4: { cellWidth: 30, halign: 'center', fontStyle: 'bold', fontSize: 7 }, // Code
            5: { cellWidth: 50, fontSize: 7, overflow: 'linebreak', halign: 'left' }, // Processus
            6: { cellWidth: 55, fontSize: 7, fontStyle: 'bold', overflow: 'linebreak', halign: 'left' }, // Indicateur
            7: { cellWidth: 25, halign: 'center', fontSize: 7 }, // Unité
            8: { cellWidth: 30, halign: 'center', fontSize: 7 }, // Fréquence
            9: { cellWidth: 25, halign: 'center', fontSize: 7 }, // Type
            10: { cellWidth: 25, halign: 'center', fontSize: 7 }, // Formule
            // Monthly columns with better formatting
            11: { cellWidth: 25, halign: 'right', fillColor: [240, 249, 255], fontSize: 7 }, // Janvier
            12: { cellWidth: 25, halign: 'right', fillColor: [240, 249, 255], fontSize: 7 }, // Février
            13: { cellWidth: 25, halign: 'right', fillColor: [240, 249, 255], fontSize: 7 }, // Mars
            14: { cellWidth: 25, halign: 'right', fillColor: [240, 249, 255], fontSize: 7 }, // Avril
            15: { cellWidth: 25, halign: 'right', fillColor: [240, 249, 255], fontSize: 7 }, // Mai
            16: { cellWidth: 25, halign: 'right', fillColor: [240, 249, 255], fontSize: 7 }, // Juin
            17: { cellWidth: 25, halign: 'right', fillColor: [240, 249, 255], fontSize: 7 }, // Juillet
            18: { cellWidth: 25, halign: 'right', fillColor: [240, 249, 255], fontSize: 7 }, // Août
            19: { cellWidth: 25, halign: 'right', fillColor: [240, 249, 255], fontSize: 7 }, // Septembre
            20: { cellWidth: 25, halign: 'right', fillColor: [240, 249, 255], fontSize: 7 }, // Octobre
            21: { cellWidth: 25, halign: 'right', fillColor: [240, 249, 255], fontSize: 7 }, // Novembre
            22: { cellWidth: 25, halign: 'right', fillColor: [240, 249, 255], fontSize: 7 }, // Décembre
            23: { cellWidth: 30, halign: 'right', fontStyle: 'bold', fontSize: 8, fillColor: [254, 249, 195] }, // Cible
            24: { cellWidth: 30, halign: 'center', fontStyle: 'bold', fontSize: 8 }, // Variation
            25: { cellWidth: 35, halign: 'center', fontStyle: 'bold', fontSize: 8 }  // Performance
          },
          margin: { top: 130, right: 20, bottom: 50, left: 20 },
          theme: 'grid',
          tableLineColor: [203, 213, 225],
          tableLineWidth: 0.2,
          tableWidth: 'auto',
          pageBreak: 'auto',
          showHead: 'everyPage',
          didDrawPage: (data) => {
            // Modern footer design
            const pageCount = doc.getNumberOfPages();
            
            // Footer background
            doc.setFillColor(248, 250, 252);
            doc.rect(0, doc.internal.pageSize.height - 40, doc.internal.pageSize.width, 40, 'F');
            
            // Footer line
            doc.setDrawColor(203, 213, 225);
            doc.setLineWidth(0.5);
            doc.line(20, doc.internal.pageSize.height - 40, doc.internal.pageSize.width - 20, doc.internal.pageSize.height - 40);
            
            // Page number (left)
            doc.setFontSize(10);
            doc.setTextColor(107, 114, 128);
            doc.setFont('helvetica', 'normal');
            doc.text(`Page ${data.pageNumber} / ${pageCount}`, 30, doc.internal.pageSize.height - 25);
            
            // Company name (center)
            const pageWidth = doc.internal.pageSize.width;
            doc.setFont('helvetica', 'bold');
            const textWidth = doc.getTextWidth(currentOrganization);
            doc.text(currentOrganization, (pageWidth - textWidth) / 2, doc.internal.pageSize.height - 25);
            
            // Generation date (right)
            doc.setFont('helvetica', 'normal');
            const dateText = `Généré le ${new Date().toLocaleDateString('fr-FR')} à ${new Date().toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })}`;
            const dateWidth = doc.getTextWidth(dateText);
            doc.text(dateText, pageWidth - dateWidth - 30, doc.internal.pageSize.height - 25);
          },
          didDrawCell: (data) => {
            // Enhanced color coding matching dashboard
            if (data.column.index === 25 && data.cell.raw !== '-') { // Performance column (index 25)
              const performance = parseFloat(data.cell.raw.replace('%', ''));
              if (performance >= 100) {
                data.cell.styles.fillColor = [220, 252, 231]; // Green-50
                data.cell.styles.textColor = [21, 128, 61]; // Green-700
                data.cell.styles.fontStyle = 'bold';
              } else if (performance >= 80) {
                data.cell.styles.fillColor = [254, 249, 195]; // Yellow-100
                data.cell.styles.textColor = [161, 98, 7]; // Yellow-700
                data.cell.styles.fontStyle = 'bold';
              } else if (performance < 80 && performance > 0) {
                data.cell.styles.fillColor = [254, 226, 226]; // Red-100
                data.cell.styles.textColor = [185, 28, 28]; // Red-700
                data.cell.styles.fontStyle = 'bold';
              }
            }
            
            // Enhanced variation cells
            if (data.column.index === 24 && data.cell.raw !== '-') { // Variation column (index 24)
              const variation = parseFloat(data.cell.raw.replace('%', '').replace('+', ''));
              if (variation > 0) {
                data.cell.styles.fillColor = [220, 252, 231];
                data.cell.styles.textColor = [21, 128, 61];
                data.cell.styles.fontStyle = 'bold';
              } else if (variation < 0) {
                data.cell.styles.fillColor = [254, 226, 226];
                data.cell.styles.textColor = [185, 28, 28];
                data.cell.styles.fontStyle = 'bold';
              }
            }
            
            // Enhanced ESG axes styling
            if (data.column.index === 0) { // Axe column
              if (data.cell.raw === 'Environnement') {
                data.cell.styles.fillColor = [220, 252, 231]; // Green
                data.cell.styles.textColor = [21, 128, 61];
                data.cell.styles.fontStyle = 'bold';
              } else if (data.cell.raw === 'Social') {
                data.cell.styles.fillColor = [219, 234, 254]; // Blue
                data.cell.styles.textColor = [29, 78, 216];
                data.cell.styles.fontStyle = 'bold';
              } else if (data.cell.raw === 'Gouvernance') {
                data.cell.styles.fillColor = [243, 232, 255]; // Purple
                data.cell.styles.textColor = [107, 33, 168];
                data.cell.styles.fontStyle = 'bold';
              }
            }
            
            // Style monthly data columns
            if (data.column.index >= 11 && data.column.index <= 22) { // Monthly columns
              if (data.cell.raw !== '-' && data.cell.raw !== '0') {
                data.cell.styles.fontStyle = 'bold';
                data.cell.styles.textColor = [31, 41, 55];
              } else {
                data.cell.styles.textColor = [156, 163, 175]; // Gray for empty values
              }
            }
            
            // Style target column
            if (data.column.index === 23 && data.cell.raw !== '-') { // Cible column
              data.cell.styles.fontStyle = 'bold';
              data.cell.styles.textColor = [59, 130, 246]; // Blue for targets
            }
          }
        });
        
        // Save PDF
        const fileName = `Tableau_de_Bord_Performance_ESG_${currentOrganization.replace(/\s+/g, '_')}_${filters.year}.pdf`;
        doc.save(fileName);
      } else {
        // Keep existing CSV export for Excel format
        const exportData = filteredAndSortedData.map(row => ({
          Axe: row.axe,
          Enjeux: row.enjeux,
          Normes: row.normes,
          Critères: row.criteres,
          'Code Processus': row.process_code,
          Processus: row.processus,
          Indicateur: row.indicateur,
          Unité: row.unite,
          Fréquence: row.frequence,
          Type: row.type,
          Formule: row.formule,
          Janvier: row.janvier,
          Février: row.fevrier,
          Mars: row.mars,
          Avril: row.avril,
          Mai: row.mai,
          Juin: row.juin,
          Juillet: row.juillet,
          Août: row.aout,
          Septembre: row.septembre,
          Octobre: row.octobre,
          Novembre: row.novembre,
          Décembre: row.decembre,
          'Valeur Cible': row.valeur_cible,
          'Variation (%)': row.variation,
          'Performance (%)': row.performance
        }));

        // Create CSV content
        const headers = Object.keys(exportData[0] || {});
        const csvContent = [
          headers.join(','),
          ...exportData.map(row => 
            headers.map(header => `"${row[header as keyof typeof row] || ''}"`).join(',')
          )
        ].join('\n');

        // Download file
        const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        const url = URL.createObjectURL(blob);
        link.setAttribute('href', url);
        link.setAttribute('download', `dashboard_performance_${currentOrganization}_${filters.year}.csv`);
        link.style.visibility = 'hidden';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
      }

      toast.success(`Export ${format.toUpperCase()} généré avec succès`);
    } catch (error) {
      console.error('Error exporting data:', error);
      toast.error(`Erreur lors de l'export ${format.toUpperCase()}`);
    }
  };

  // Filter and sort data
  const filteredAndSortedData = React.useMemo(() => {
    let filtered = dashboardData.filter(row => {
      const matchesAxe = filters.axe === 'all' || row.axe === filters.axe;
      const matchesProcessus = filters.processus === 'all' || row.processus === filters.processus;
      const matchesSearch = !filters.search || 
        row.indicateur.toLowerCase().includes(filters.search.toLowerCase()) ||
        row.process_code.toLowerCase().includes(filters.search.toLowerCase()) ||
        row.processus.toLowerCase().includes(filters.search.toLowerCase());
      
      return matchesAxe && matchesProcessus && matchesSearch;
    });

    if (sortConfig.key) {
      filtered.sort((a, b) => {
        const aVal = a[sortConfig.key!];
        const bVal = b[sortConfig.key!];
        
        if (aVal === null || aVal === undefined) return 1;
        if (bVal === null || bVal === undefined) return -1;
        
        if (typeof aVal === 'number' && typeof bVal === 'number') {
          return sortConfig.direction === 'asc' ? aVal - bVal : bVal - aVal;
        }
        
        const aStr = String(aVal).toLowerCase();
        const bStr = String(bVal).toLowerCase();
        
        if (sortConfig.direction === 'asc') {
          return aStr < bStr ? -1 : aStr > bStr ? 1 : 0;
        } else {
          return aStr > bStr ? -1 : aStr < bStr ? 1 : 0;
        }
      });
    }

    return filtered;
  }, [dashboardData, filters, sortConfig]);

  const getPerformanceColor = (performance: number | null) => {
    if (performance === null || performance === undefined) return 'text-gray-500';
    if (performance >= 90) return 'text-green-600';
    if (performance >= 70) return 'text-yellow-600';
    return 'text-red-600';
  };

  const getPerformanceIcon = (performance: number | null) => {
    if (performance === null || performance === undefined) return <AlertCircle className="h-4 w-4" />;
    if (performance >= 90) return <CheckCircle className="h-4 w-4" />;
    if (performance >= 70) return <Target className="h-4 w-4" />;
    return <AlertCircle className="h-4 w-4" />;
  };

  const getVariationDisplay = (variation: number | null) => {
    if (variation === null || variation === undefined) return '-';
    const sign = variation >= 0 ? '+' : '';
    return `${sign}${variation.toFixed(1)}%`;
  };

  const getVariationColor = (variation: number | null) => {
    if (variation === null || variation === undefined) return 'text-gray-500';
    if (variation > 0) return 'text-green-600';
    if (variation < 0) return 'text-red-600';
    return 'text-gray-500';
  };

  const getVariationIcon = (variation: number | null) => {
    if (variation === null || variation === undefined) return null;
    if (variation > 0) return <TrendingUp className="h-3 w-3" />;
    if (variation < 0) return <TrendingDown className="h-3 w-3" />;
    return null;
  };

  // Get unique values for filters
  const uniqueAxes = [...new Set(dashboardData.map(row => row.axe))].filter(Boolean);
  const uniqueProcessus = [...new Set(dashboardData.map(row => row.processus))].filter(Boolean);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="text-center"
        >
          <Loader2 className="h-12 w-12 animate-spin text-blue-600 mx-auto mb-4" />
          <p className="text-gray-600">Chargement du tableau de bord...</p>
        </motion.div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="bg-white rounded-xl shadow-sm border border-gray-200 p-6"
      >
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-3">
            <div className="p-3 rounded-lg bg-blue-500">
              <BarChart3 className="h-6 w-6 text-white" />
            </div>
            <div>
              <h2 className="text-2xl font-semibold text-gray-900">Tableau de Bord Performance</h2>
              <p className="text-gray-600">Vue d'ensemble des indicateurs ESG - {currentOrganization}</p>
            </div>
          </div>
          
          <div className="flex items-center gap-3">
            <button
              onClick={handleRefresh}
              disabled={refreshing}
              className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 transition-colors"
            >
              <RefreshCw className={`h-4 w-4 mr-2 ${refreshing ? 'animate-spin' : ''}`} />
              Actualiser
            </button>
            <button
              onClick={() => handleExport('pdf')}
              className="flex items-center px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
            >
              <Download className="h-4 w-4 mr-2" />
              Export PDF
            </button>
          </div>
        </div>

        {/* Filters */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              <Calendar className="h-4 w-4 inline mr-1" />
              Année
            </label>
            <select
              value={filters.year}
              onChange={(e) => setFilters(prev => ({ ...prev, year: parseInt(e.target.value) }))}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            >
              {Array.from({ length: 5 }, (_, i) => new Date().getFullYear() - 2 + i).map(year => (
                <option key={year} value={year}>{year}</option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              <Filter className="h-4 w-4 inline mr-1" />
              Axe ESG
            </label>
            <select
              value={filters.axe}
              onChange={(e) => setFilters(prev => ({ ...prev, axe: e.target.value }))}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="all">Tous les axes</option>
              {uniqueAxes.map(axe => (
                <option key={axe} value={axe}>{axe}</option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              <Filter className="h-4 w-4 inline mr-1" />
              Processus
            </label>
            <select
              value={filters.processus}
              onChange={(e) => setFilters(prev => ({ ...prev, processus: e.target.value }))}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="all">Tous les processus</option>
              {uniqueProcessus.map(processus => (
                <option key={processus} value={processus}>{processus}</option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              <Search className="h-4 w-4 inline mr-1" />
              Recherche
            </label>
            <input
              type="text"
              placeholder="Rechercher un indicateur..."
              value={filters.search}
              onChange={(e) => setFilters(prev => ({ ...prev, search: e.target.value }))}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
        </div>
      </motion.div>

      {/* Statistics Cards */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.1 }}
        className="grid grid-cols-1 md:grid-cols-4 gap-4"
      >
        {[
          {
            title: 'Total Indicateurs',
            value: filteredAndSortedData.length,
            icon: BarChart3,
            color: 'bg-blue-500'
          },
          {
            title: 'Performance Moyenne',
            value: `${(filteredAndSortedData.reduce((sum, row) => sum + (row.performance || 0), 0) / filteredAndSortedData.length || 0).toFixed(1)}%`,
            icon: Target,
            color: 'bg-green-500'
          },
          {
            title: 'Objectifs Atteints',
            value: filteredAndSortedData.filter(row => (row.performance || 0) >= 100).length,
            icon: CheckCircle,
            color: 'bg-emerald-500'
          },
          {
            title: 'Alertes',
            value: filteredAndSortedData.filter(row => (row.performance || 0) < 70).length,
            icon: AlertCircle,
            color: 'bg-red-500'
          }
        ].map((stat, index) => (
          <motion.div
            key={stat.title}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 + index * 0.05 }}
            className="bg-white rounded-xl shadow-sm border border-gray-200 p-6"
          >
            <div className="flex items-center">
              <div className={`p-3 rounded-lg ${stat.color}`}>
                <stat.icon className="h-6 w-6 text-white" />
              </div>
              <div className="ml-4">
                <h2 className="text-2xl font-semibold text-gray-900">
                  {selectedSite ? `Tableau de Bord - Site ${selectedSite}` : 'Tableau de Bord Performance'}
                </h2>
                <p className="text-gray-600">
                  {selectedSite 
                    ? `Indicateurs ESG du site ${selectedSite}` 
                    : `Vue d'ensemble des indicateurs ESG - ${currentOrganization}`
                  }
                </p>
              </div>
            </div>
          </motion.div>
        ))}
      </motion.div>

      {/* Dashboard Table */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2 }}
        className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden"
      >
        <div className="px-6 py-4 border-b border-gray-200 bg-gray-50">
          <div className="flex items-center justify-between">
            <h3 className="text-lg font-semibold text-gray-900">
              Données de Performance {filters.year}
            </h3>
            <div className="flex items-center gap-2 text-sm text-gray-600">
              <Table className="h-4 w-4" />
              {filteredAndSortedData.length} indicateurs
            </div>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                {[
                  { key: 'axe', label: 'Axe' },
                  { key: 'enjeux', label: 'Enjeux' },
                  { key: 'normes', label: 'Normes' },
                  { key: 'criteres', label: 'Critères' },
                  { key: 'process_code', label: 'Code Processus' },
                  { key: 'processus', label: 'Processus' },
                  { key: 'indicateur', label: 'Indicateur' },
                  { key: 'unite', label: 'Unité' },
                  { key: 'frequence', label: 'Fréquence' },
                  { key: 'type', label: 'Type' },
                  { key: 'formule', label: 'Formule' }
                ].map(({ key, label }) => (
                  <th
                    key={key}
                    onClick={() => handleSort(key as keyof DashboardData)}
                    className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-100 transition-colors"
                  >
                    <div className="flex items-center gap-1">
                      {label}
                      {sortConfig.key === key && (
                        sortConfig.direction === 'asc' ? 
                        <TrendingUp className="h-3 w-3" /> : 
                        <TrendingDown className="h-3 w-3" />
                      )}
                    </div>
                  </th>
                ))}
                
                {/* Monthly columns */}
                {monthLabels.map((month, index) => (
                  <th
                    key={month}
                    onClick={() => handleSort(months[index] as keyof DashboardData)}
                    className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-100 transition-colors"
                  >
                    {month}
                  </th>
                ))}
                
                {[
                  { key: 'valeur_cible', label: 'Cible' },
                  { key: 'variation', label: 'Variation' },
                  { key: 'performance', label: 'Performance' }
                ].map(({ key, label }) => (
                  <th
                    key={key}
                    onClick={() => handleSort(key as keyof DashboardData)}
                    className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-100 transition-colors"
                  >
                    <div className="flex items-center justify-center gap-1">
                      {label}
                      {sortConfig.key === key && (
                        sortConfig.direction === 'asc' ? 
                        <TrendingUp className="h-3 w-3" /> : 
                        <TrendingDown className="h-3 w-3" />
                      )}
                    </div>
                  </th>
                ))}
              </tr>
            </thead>
            
            <tbody className="bg-white divide-y divide-gray-200">
              <AnimatePresence>
                {filteredAndSortedData.map((row, index) => (
                  <motion.tr
                    key={`${row.process_code}-${row.indicator_code}`}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -20 }}
                    transition={{ delay: index * 0.02 }}
                    className="hover:bg-gray-50 transition-colors"
                  >
                    {/* Core columns */}
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                        row.axe === 'Environnement' ? 'bg-green-100 text-green-800' :
                        row.axe === 'Social' ? 'bg-blue-100 text-blue-800' :
                        row.axe === 'Gouvernance' ? 'bg-purple-100 text-purple-800' :
                        'bg-gray-100 text-gray-800'
                      }`}>
                        {row.axe}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-900 max-w-xs truncate" title={row.enjeux}>
                      {row.enjeux}
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-900 max-w-xs truncate" title={row.normes}>
                      {row.normes}
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-900 max-w-xs truncate" title={row.criteres}>
                      {row.criteres}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-mono text-gray-900">
                      {row.process_code}
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-900 max-w-xs" title={row.processus}>
                      <div className="font-medium truncate">{row.processus}</div>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-900 max-w-xs" title={row.indicateur}>
                      <div className="font-medium truncate">{row.indicateur}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{row.unite || '-'}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{row.frequence || '-'}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{row.type || '-'}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{row.formule || '-'}</td>
                    
                    {/* Monthly values */}
                    {months.map((month) => (
                      <td key={month} className="px-4 py-4 whitespace-nowrap text-sm text-center text-gray-900">
                        <span className={`font-medium ${
                          row[month as keyof DashboardData] ? 'text-gray-900' : 'text-gray-400'
                        }`}>
                          {row[month as keyof DashboardData] ? 
                            Number(row[month as keyof DashboardData]).toLocaleString() : 
                            '-'
                          }
                        </span>
                      </td>
                    ))}
                    
                    {/* Target, Variation, Performance */}
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-center text-gray-900">
                      {row.valeur_cible ? row.valeur_cible.toLocaleString() : '-'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-center">
                      <div className={`flex items-center justify-center gap-1 ${getVariationColor(row.variation)}`}>
                        {getVariationIcon(row.variation)}
                        <span className="font-medium">{getVariationDisplay(row.variation)}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-center">
                      <div className={`flex items-center justify-center gap-1 ${getPerformanceColor(row.performance)}`}>
                        {getPerformanceIcon(row.performance)}
                        <span className="font-bold">
                          {row.performance ? `${row.performance.toFixed(1)}%` : '-'}
                        </span>
                      </div>
                    </td>
                  </motion.tr>
                ))}
              </AnimatePresence>
            </tbody>
          </table>
        </div>

        {filteredAndSortedData.length === 0 && (
          <div className="text-center py-12">
            <FileText className="h-12 w-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">
              {selectedSite ? `Aucune donnée pour le site ${selectedSite}` : 'Aucune donnée trouvée'}
            </h3>
            <p className="text-gray-500">
              {selectedSite ? 
                `Aucune donnée disponible pour le site ${selectedSite} pour l'année ${filters.year}.` :
                filters.search ? 
                "Aucun indicateur ne correspond à votre recherche." :
                `Aucune donnée disponible pour l'année ${filters.year}.`
              }
            </p>
          </div>
        )}
      </motion.div>

      {/* Performance Summary */}
      {filteredAndSortedData.length > 0 && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="bg-white rounded-xl shadow-sm border border-gray-200 p-6"
        >
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Résumé de Performance</h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {['Environnement', 'Social', 'Gouvernance'].map(axe => {
              const axeData = filteredAndSortedData.filter(row => row.axe === axe);
              const avgPerformance = axeData.length > 0 ? 
                axeData.reduce((sum, row) => sum + (row.performance || 0), 0) / axeData.length : 0;
              
              return (
                <div key={axe} className="text-center">
                  <div className={`inline-flex items-center justify-center w-16 h-16 rounded-full mb-3 ${
                    axe === 'Environnement' ? 'bg-green-100' :
                    axe === 'Social' ? 'bg-blue-100' :
                    'bg-purple-100'
                  }`}>
                    <span className={`text-2xl ${
                      axe === 'Environnement' ? 'text-green-600' :
                      axe === 'Social' ? 'text-blue-600' :
                      'text-purple-600'
                    }`}>
                      {axe === 'Environnement' ? '🌱' : axe === 'Social' ? '👥' : '⚖️'}
                    </span>
                  </div>
                  <h4 className="font-semibold text-gray-900">{axe}</h4>
                  <p className="text-2xl font-bold text-gray-900 mt-1">
                    {avgPerformance.toFixed(1)}%
                  </p>
                  <p className="text-sm text-gray-600">{axeData.length} indicateurs</p>
                </div>
              );
            })}
          </div>
        </motion.div>
      )}

      {/* Read-only notice for contributors */}
      {isContributor && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="bg-blue-50 border border-blue-200 rounded-lg p-4"
        >
          <div className="flex items-center">
            <Eye className="h-5 w-5 text-blue-600 mr-2" />
            <span className="text-sm font-medium text-blue-800">
              Mode consultation - Vous visualisez les données de performance en lecture seule
            </span>
          </div>
        </motion.div>
      )}
    </div>
  );
};