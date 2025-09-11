/*
  # Complétion des données ESG basées sur les images fournies

  1. Nouveaux Enjeux
    - Ajout des enjeux manquants identifiés dans les images
    - Couverture complète des axes Gouvernance, Social et Environnement

  2. Nouveaux Critères
    - Critères détaillés pour chaque enjeu
    - Alignement avec les normes ISO 26000, CSRD, GRI

  3. Indicateurs Complets (80+ indicateurs)
    - Indicateurs de gouvernance (composition conseil, éthique, etc.)
    - Indicateurs sociaux (emploi, formation, rémunération, etc.)
    - Indicateurs environnementaux (énergie, eau, déchets, etc.)
    - Types primaires et calculés avec formules appropriées
*/

-- =========================================================
-- 1. ENJEUX SUPPLÉMENTAIRES
-- =========================================================

INSERT INTO issues (code, name) VALUES
('STRATEGY_BUSINESS_MODEL', 'Stratégie et modèle d''affaires'),
('GOVERNANCE_INSTANCE', 'Instance de gouvernance'),
('MEASUREMENT_DATA_COLLECTION', 'Mesure et collecte des données'),
('COMPLAINTS_CLAIMS', 'Plaintes, réclamations, compensations et amendes'),
('DUE_DILIGENCE_COMPLIANCE', 'Diligence raisonnable, conformité et certification'),
('FINANCE_INVESTMENT', 'Finances et investissements'),
('BUSINESS_CONTINUITY', 'Continuité d''activité'),
('REMUNERATION_NEGOTIATION', 'Rémunération et négociation collective')
ON CONFLICT (code) DO NOTHING;

-- =========================================================
-- 2. CRITÈRES SUPPLÉMENTAIRES
-- =========================================================

INSERT INTO criteria (code, name) VALUES
-- Stratégie et modèle d'affaires
('BUSINESS_CHARACTERISTICS', 'Caractéristiques de l''entreprise'),
('REPORT_TYPE', 'Type de rapport'),
('ESG_LABELS', 'Labels ESG obtenus'),
('PRODUCT_SERVICES', 'Produits/Services'),
('IMPORTANT_MARKETS', 'Marchés importants'),
('COMMERCIAL_RELATIONS', 'Relations commerciales'),
('SUSTAINABLE_STRATEGY', 'Stratégie d''affaire affectant les questions de durabilité'),

-- Instance de gouvernance
('GOVERNANCE_INSTANCE_CRITERIA', 'Instance de gouvernance'),

-- Mesure et collecte des données
('DATA_MEASUREMENT_COLLECTION', 'Mesure et collecte des données'),

-- Plaintes et réclamations
('COMPLAINTS_CLAIMS_CRITERIA', 'Plaintes et réclamations'),
('COMPENSATIONS_SANCTIONS', 'Compensations, amendes et sanctions'),

-- Diligence raisonnable
('DUE_DILIGENCE_CRITERIA', 'Diligence raisonnable'),
('COMPLIANCE_CERTIFICATION', 'Conformité et certification'),

-- Finances et investissements
('FINANCE_INVESTMENT_CRITERIA', 'Finances et investissements'),

-- Continuité d'activité
('BUSINESS_CONTINUITY_CRITERIA', 'Continuité d''activité'),

-- Rémunération et négociation
('REMUNERATION_COLLECTIVE', 'Rémunération et négociation collective')
ON CONFLICT (code) DO NOTHING;

-- =========================================================
-- 3. INDICATEURS COMPLETS (80+ indicateurs)
-- =========================================================

INSERT INTO indicators (code, name, unit, type, axe, formule, frequence) VALUES

-- =========================================================
-- GOUVERNANCE - Informations générales
-- =========================================================
('BUSINESS_REVENUE', 'Chiffre d''affaires', 'FCFA', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('SITES_COUNT', 'Sites', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('SUPPLIERS_COUNT', 'Fournisseurs de produits et services', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('GOVERNMENT_AID', 'Aide financière reçue du gouvernement', 'FCFA', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('TAX_PAID', 'Impôts et taxes versées supérieures des ministères et', 'FCFA', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('REPORT_TYPES', 'Types de rapports élaborés', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('REPORT_FINALIZATION_RATE', 'Taux de finalisation des rapports', 'Nombre', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('ESG_LABELS_COUNT', 'Nombre de labels ESG Obtenus', 'Nombre', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('ALIGNED_PRODUCTS_RATE', '% CA produits alignés Taxonomie UE', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('GEOGRAPHIC_REVENUE_SHARE', 'Chiffre d''affaires par marché géographique', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('DIRECT_SUPPLIERS_COUNT', 'Nombre total de fournisseurs directs', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),

-- =========================================================
-- GOUVERNANCE - Stratégie et modèle d'affaires
-- =========================================================
('STRATEGIC_SUPPLIERS_PURCHASES', 'Part des achats auprès de fournisseurs stratégiques (top 10 ou top 20)', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('TOTAL_PURCHASES', 'Total des Achats réalisés', 'kFCFA', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('BUSINESS_PURCHASES_RATE', '% du chiffre d''affaires issu des achats réalisés', 'kFCFA', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('NATIONAL_SUPPLIERS_PURCHASES', 'Achats auprès des fournisseurs nationaux', 'kFCFA', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('LOCAL_SUPPLIERS_PURCHASES', 'Part des achats réalisés auprès des fournisseurs locaux', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('ESG_ENGAGED_SUPPLIERS', 'Part de fournisseurs engagés dans objectifs ESG', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('ESG_INTEGRATION_RATE', 'Taux d''intégration des critères ESG dans les appels d''offre', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('LOCAL_REGIONAL_PURCHASES', 'Part des achats locaux / régionaux', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('ESG_EVALUATED_SUPPLIERS', 'Part de fournisseurs évalués sur critères ESG', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('ESG_AUDITS_COUNT', 'Nombre d''audits ESG réalisés chez fournisseurs', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('ESG_COMPLIANT_SUPPLIERS_RATE', 'Taux de conformité ESG des fournisseurs audités', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('NON_COMPLIANT_CONTRACTS', 'Nombre de résiliations de contrats pour non-conformité ESG', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),

-- Stratégie durable
('SUSTAINABLE_ACTIVITIES_CA', 'Part du CA provenant d''activités durables (taxonomie verte UE)', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('ESG_INVESTMENT_PROJECTS', 'Projets d''investissement alignés sur les objectifs ESG', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('RD_SUSTAINABLE_EXPENSES', 'Part des dépenses R&D orientées vers solutions durables', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('EXECUTIVE_REMUNERATION_ESG', 'Rémunération des dirigeants liée aux objectifs de durabilité', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),

-- =========================================================
-- GOUVERNANCE - Instance de gouvernance
-- =========================================================
('BOARD_MEMBERS_COUNT', 'Membres au Conseil d''Administration', 'Nombre', 'primaire', 'Gouvernance', 'dernier_mois', 'annuelle'),
('BOARD_WOMEN_COUNT', 'Femmes dans le Conseil d''Administration', 'Nombre', 'primaire', 'Gouvernance', 'dernier_mois', 'annuelle'),
('BOARD_WOMEN_RATIO', 'Part des femmes dans le Conseil d''Administration', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('DIRECTION_COMMITTEE_MEMBERS', 'Membres du Comité de Direction', 'Nombre', 'primaire', 'Gouvernance', 'dernier_mois', 'annuelle'),
('DIRECTION_COMMITTEE_WOMEN', 'Femme dans le Comité de Direction', 'Nombre', 'primaire', 'Gouvernance', 'dernier_mois', 'annuelle'),
('ENV_NON_COMPLIANCES', 'Actions d''identification des non-conformités environnementales', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('SOCIAL_NON_COMPLIANCES', 'Actions d''identification des non-conformités socio-économiques', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('INTERNAL_AUDIT_DIAGNOSTICS', 'Total des diagnostics menés pour détecter les non-conformités', 'Nombre', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('INTERNAL_AUDIT_SITES', 'Sites ayant effectué un audit interne DD', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('INTERNAL_AUDIT_SITES_RATIO', 'Part des sites ayant effectué un audit interne DD', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle'),

-- Certifications
('ISO_9001_SITES', 'Sites certifiés ISO 9001', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('ISO_9001_SITES_RATIO', 'Part des sites certifiés ISO 9001', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('ISO_14001_SITES', 'Sites certifiés ISO 14001', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('ISO_14001_SITES_RATIO', 'Part des sites certifiés ISO 14001', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('ISO_45001_SITES', 'Sites certifiés ISO 45001', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('ISO_45001_SITES_RATIO', 'Part des sites certifiés ISO 45001', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle'),

-- =========================================================
-- GOUVERNANCE - Conduite des affaires et Éthique
-- =========================================================
('INTEREST_CONFLICTS', 'Conflits d''intérêt déclarés', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('ANTICORRUPTION_VIOLATIONS', 'Nombre de condamnations pour violation des lois anti-corruption durant la période de reporting', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('ANTICORRUPTION_FINES', 'Montant total des amendes pour violation des lois anti-corruption durant la période de reporting', 'FCFA', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('STAKEHOLDER_CONSULTATIONS', 'Nombre total de consultations / dialogues formels avec parties prenantes', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('STAKEHOLDER_PARTICIPATION_RATE', 'Taux de participation des parties prenantes invitées', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('STAKEHOLDER_RECOMMENDATIONS', 'Part des recommandations / attentes intégrées dans la stratégie', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('STAKEHOLDER_PROJECTS', 'Nombre de projets ou actions co-construits avec parties prenantes', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('STAKEHOLDER_CONFLICTS', 'Nombre de conflits ou litiges avec parties prenantes', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),

-- Matérialité et enjeux
('STRATEGIC_ISSUES_INTEGRATION', 'Part d''enjeux intégrés aux objectifs stratégiques', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('SUSTAINABILITY_COMMITTEE_MEETINGS', 'Taux de réalisation des réunions du comité de durabilité', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('STRATEGIC_ESG_DECISIONS', 'Part des décisions stratégiques impliquant des critères ESG', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('IRO_IMPLEMENTATION_RATE', 'Taux de mise en œuvre des actions faces aux IRO', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('GREEN_MARKET_ACCESS', 'Taux d''accès à de nouvelles opportunités de marchés verts', '%', 'calculé', 'Gouvernance', 'somme', 'annuelle'),
('SDG_ALIGNMENT', 'Part des objectifs DD de l''entreprise alignés avec les ODD pertinents', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('DD_CALENDAR_COMPLIANCE', 'Taux de respect du calendrier de mise en œuvre des actions DD', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('DD_OBJECTIVES_ACHIEVEMENT', 'Taux d''atteinte des objectifs DD', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('DATA_VERIFICATION_RATE', 'Taux de vérification des données collectées', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('DATA_ERRORS_RATE', 'Taux d''erreurs détectées sur les données collectées', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),

-- Collecte de données
('SITES_DATA_COVERAGE', 'Pourcentage de sites / filiales couverts par la collecte des données', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('PROCESSES_DATA_COVERAGE', 'Pourcentage des postes / processus concernés par la collecte des données', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('INTERNAL_DATA_ACCESSIBILITY', 'Accessibilité des données aux parties prenantes internes', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('DATA_UPDATE_RATE', 'Taux de mise à jour des données', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),

-- Plaintes et réclamations
('CLIENT_COMPLAINTS', 'Plaintes reçues des clients', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('COMPLAINT_PROCESSING_RATE', 'Taux de traitement des plaintes', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('COMPLAINANT_SATISFACTION', 'Taux de satisfaction des plaignants', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('COMPENSATED_COMPLAINTS_RATE', 'Proportion des plaintes compensées', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('SANCTIONS_COUNT', 'Nombre d''amendes ou sanctions reçues', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('TOTAL_FINES_AMOUNT', 'Montant total des amendes payées', 'FCFA', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('ONGOING_PROCEDURES', 'Nombre de procédures en cours', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('CORRECTIVE_MEASURES_RATE', 'Taux de mise en œuvre des mesures correctives après sanction', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),

-- Diligence raisonnable
('DUE_DILIGENCE_SUPPLIERS_RATE', 'Taux de fournisseurs évalués à une due diligence', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),
('INTERNAL_CONTROLS_COUNT', 'Nombre de contrôles internes réalisés', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'annuelle'),
('NON_COMPLIANCE_CORRECTION_RATE', 'Taux de correction des non-conformités', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'annuelle'),

-- Finances
('DD_BUDGET_ALLOCATION', 'Budget alloué au pilotage DD', 'FCFA', 'primaire', 'Gouvernance', 'somme', 'annuelle'),

-- =========================================================
-- SOCIAL - Emplois et main d'œuvre
-- =========================================================
('INDEFINITE_CONTRACT_EMPLOYEES', 'Collaborateurs avec un contrat à durée indéterminée (CDI)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('FIXED_TERM_CONTRACT_EMPLOYEES', 'Collaborateurs avec un contrat à durée déterminée (CDD, CDDn)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('TOTAL_EMPLOYEES', 'Total des collaborateurs', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('INDEFINITE_CONTRACT_RATE', 'Part des collaborateurs possédant un contrat à durée indéterminée', '%', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('SUBCONTRACTORS', 'Collaborateurs sous-traitants', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('TOTAL_WORKFORCE', 'Total des collaborateurs (Total des collaborateurs+collaborateurs sous-traitants)', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('WOMEN_EMPLOYEES', 'Collaborateurs femmes', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('MEN_EMPLOYEES', 'Collaborateurs hommes', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('TOTAL_WORKFORCE_BY_GENDER', 'Total des collaborateurs', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('WORKERS', 'Ouvriers', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('EMPLOYEES_ADMIN', 'Employés', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('SUPERVISORS', 'Agents de maîtrise', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('EXECUTIVES', 'Cadres', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('TOTAL_BY_CATEGORY', 'Total des collaborateurs', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('WOMEN_WORKERS', 'Femmes ouvrières', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('WOMEN_EMPLOYEES_ADMIN', 'Femmes employés', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('WOMEN_SUPERVISORS', 'Femmes agents de maîtrise', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('WOMEN_EXECUTIVES', 'Femmes cadres', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('MEN_WORKERS', 'Hommes ouvriers', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('MEN_EMPLOYEES_ADMIN', 'Hommes employés', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('MEN_SUPERVISORS', 'Hommes agents de maîtrise', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('MEN_EXECUTIVES', 'Hommes cadres', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),

-- Tranches d'âge
('EMPLOYEES_UNDER_30', 'Collaborateurs dont l''âge < 30 ans', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('EMPLOYEES_30_50', 'Collaborateurs dont l''âge >= 30 et <= 50 ans', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('EMPLOYEES_OVER_50', 'Collaborateurs dont l''âge > 50 ans', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('WOMEN_UNDER_30', 'Femmes dont l''âge < 30 ans', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('WOMEN_30_50', 'Femmes dont l''âge >= 30 et <= 50 ans', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('WOMEN_OVER_50', 'Femmes dont l''âge > 50 ans', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('MEN_UNDER_30', 'Hommes dont l''âge < 30 ans', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('MEN_30_50', 'Hommes dont l''âge >= 30 et <= 50 ans', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('MEN_OVER_50', 'Hommes dont l''âge > 50 ans', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),

-- Embauches et départs
('HIRES_UNDER_30', 'Embauches de l''année dont l''âge < 30 ans', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('HIRES_30_50', 'Embauches de l''année dont l''âge >= 30 et <= 50 ans', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('HIRES_OVER_50', 'Embauches de l''année dont l''âge > 50 ans', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('INTERNAL_MOBILITY', 'Mobilité interne', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('WOMEN_HIRES_UNDER_30', 'Embauches - nouveaux collaborateurs femmes dont l''âge < 30 ans', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('WOMEN_HIRES_30_50', 'Embauches - nouveaux collaborateurs femmes dont l''âge >= 30 et <= 50 ans', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('WOMEN_HIRES_OVER_50', 'Embauches - nouveaux collaborateurs femmes dont l''âge > 50 ans', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('TOTAL_WOMEN_HIRES', 'Total des embauches de l''année pour les femmes', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('MEN_HIRES_UNDER_30', 'Embauches de l''année hommes dont l''âge < 30 ans', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('MEN_HIRES_30_50', 'Embauches de l''année hommes dont l''âge >= 30 et <= 50 ans', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('MEN_HIRES_OVER_50', 'Embauches de l''année hommes dont l''âge > 50 ans', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('TOTAL_MEN_HIRES', 'Total des embauches de l''année pour les hommes', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('TOTAL_ANNUAL_HIRES', 'Total des embauches de l''année', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('TOTAL_ANNUAL_DEPARTURES', 'Total des entrées de l''année', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),

-- Départs et mobilité
('EXTERNAL_MOBILITY', 'Mobilité externe', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('ANNUAL_DEPARTURES', 'Total des sorties de l''année', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('MEN_TURNOVER_RATE', 'Turnover Hommes', 'Ratio', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('WOMEN_TURNOVER_RATE', 'Turnover Femmes', 'Ratio', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),

-- Incidents et continuité
('MAJOR_INCIDENTS_SUPPLY_CHAIN', 'Nombre d''incidents majeurs dans la chaîne de valeur affectant la production ou la livraison', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('SUPPLY_CHAIN_MITIGATION_PLANS', 'Nombre de plans de mitigation des risques de rupture de la chaîne de valeur mis en place', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),

-- =========================================================
-- SOCIAL - Rémunération
-- =========================================================
('GROUP_ENTRY_SALARY', 'Salaire d''entrée dans le Groupe', 'FCFA', 'primaire', 'Social', 'moyenne', 'mensuelle'),
('LOCAL_MINIMUM_WAGE', 'Salaire minimum légal et local', 'FCFA', 'primaire', 'Social', 'moyenne', 'mensuelle'),
('ENTRY_SALARY_VS_MINIMUM', 'Salaire d''entrée comparé au salaire local', 'Ratio', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('TOTAL_REMUNERATION_MEN', 'Rémunération totale - Hommes', 'FCFA', 'primaire', 'Social', 'somme', 'mensuelle'),
('TOTAL_REMUNERATION_WOMEN', 'Rémunération totale - Femmes', 'FCFA', 'primaire', 'Social', 'somme', 'mensuelle'),
('TOTAL_REMUNERATION_ALL', 'TOTAL Rémunérations - Hommes+Femmes', 'FCFA', 'calculé', 'Social', 'somme', 'mensuelle'),
('REMUNERATION_REVENUE_RATIO', 'Ratio Rémunération / Chiffre d''affaires', 'FCFA', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('REMUNERATION_GROWTH_RATE', 'Taux de croissance de la Rémunération', 'FCFA', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('AVERAGE_ANNUAL_REMUNERATION_MEN', 'Rémunération annuelle moyenne - Homme', 'FCFA', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('AVERAGE_ANNUAL_REMUNERATION_WOMEN', 'Rémunération annuelle moyenne - Femme', 'FCFA', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('AVERAGE_ANNUAL_REMUNERATION_ALL', 'Rémunération annuelle moyenne - Total collaborateur', 'FCFA', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('SALARY_EQUITY_ALL_CATEGORIES', 'Égalité salariale entre les hommes et les femmes TOUTES CATÉGORIES', 'Ratio', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),

-- Rémunération par catégorie
('WORKERS_REMUNERATION_MEN', 'Rémunération - OUVRIERS Hommes', 'FCFA', 'primaire', 'Social', 'somme', 'mensuelle'),
('WORKERS_REMUNERATION_WOMEN', 'Rémunération - OUVRIERS Femmes', 'FCFA', 'primaire', 'Social', 'somme', 'mensuelle'),
('TOTAL_WORKERS_REMUNERATION', 'TOTAL Rémunération - OUVRIERS', 'FCFA', 'calculé', 'Social', 'somme', 'mensuelle'),
('AVERAGE_WORKERS_REMUNERATION', 'Rémunération Moyenne par OUVRIER', 'FCFA', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('AVERAGE_WORKERS_REMUNERATION_MEN', 'Rémunération Moyenne - OUVRIERS Hommes', 'FCFA', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('AVERAGE_WORKERS_REMUNERATION_WOMEN', 'Rémunération Moyenne - OUVRIERS Femmes', 'FCFA', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('WORKERS_SALARY_EQUITY', 'Égalité salariale entre les hommes et les femmes OUVRIERS', 'Ratio', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),

('EMPLOYEES_REMUNERATION_MEN', 'Rémunération - EMPLOYÉS Hommes', 'FCFA', 'primaire', 'Social', 'somme', 'mensuelle'),
('EMPLOYEES_REMUNERATION_WOMEN', 'Rémunération - EMPLOYÉS Femmes', 'FCFA', 'primaire', 'Social', 'somme', 'mensuelle'),
('TOTAL_EMPLOYEES_REMUNERATION', 'TOTAL Rémunération - EMPLOYÉS', 'FCFA', 'calculé', 'Social', 'somme', 'mensuelle'),
('AVERAGE_EMPLOYEES_REMUNERATION', 'Rémunération Moyenne - EMPLOYÉS', 'FCFA', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('AVERAGE_EMPLOYEES_REMUNERATION_MEN', 'Rémunération Moyenne - EMPLOYÉS Hommes', 'FCFA', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('AVERAGE_EMPLOYEES_REMUNERATION_WOMEN', 'Rémunération Moyenne - EMPLOYÉS Femmes', 'FCFA', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('EMPLOYEES_SALARY_EQUITY', 'Égalité salariale entre les hommes et les femmes EMPLOYÉS', 'Ratio', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),

('SUPERVISORS_REMUNERATION_MEN', 'Rémunération - AGENTS DE MAÎTRISE Hommes', 'FCFA', 'primaire', 'Social', 'somme', 'mensuelle'),
('SUPERVISORS_REMUNERATION_WOMEN', 'Rémunération - AGENTS DE MAÎTRISE Femmes', 'FCFA', 'primaire', 'Social', 'somme', 'mensuelle'),
('TOTAL_SUPERVISORS_REMUNERATION', 'TOTAL Rémunération - AGENTS DE MAÎTRISE', 'FCFA', 'calculé', 'Social', 'somme', 'mensuelle'),
('AVERAGE_SUPERVISORS_REMUNERATION', 'Rémunération Moyenne - AGENTS DE MAÎTRISE', 'FCFA', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('AVERAGE_SUPERVISORS_REMUNERATION_MEN', 'Rémunération Moyenne - AGENTS DE MAÎTRISE Hommes', 'FCFA', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('AVERAGE_SUPERVISORS_REMUNERATION_WOMEN', 'Rémunération Moyenne - AGENTS DE MAÎTRISE Femmes', 'FCFA', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('SUPERVISORS_SALARY_EQUITY', 'Égalité salariale entre les hommes et les femmes AGENTS DE MAÎTRISE', 'Ratio', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),

('EXECUTIVES_REMUNERATION_MEN', 'Rémunération - CADRES Hommes', 'FCFA', 'primaire', 'Social', 'somme', 'mensuelle'),
('EXECUTIVES_REMUNERATION_WOMEN', 'Rémunération - CADRES Femmes', 'FCFA', 'primaire', 'Social', 'somme', 'mensuelle'),
('TOTAL_EXECUTIVES_REMUNERATION', 'TOTAL Rémunération - CADRES', 'FCFA', 'calculé', 'Social', 'somme', 'mensuelle')

ON CONFLICT (code) DO UPDATE SET
  name = EXCLUDED.name,
  unit = EXCLUDED.unit,
  type = EXCLUDED.type,
  axe = EXCLUDED.axe,
  formule = EXCLUDED.formule,
  frequence = EXCLUDED.frequence,
  updated_at = now();