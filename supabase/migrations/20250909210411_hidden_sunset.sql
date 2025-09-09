/*
  # Populate ESG Data from Screenshots

  1. New Data
    - Sectors: Gouvernance, Social
    - Subsectors: Leadership et responsabilité, Conduite des affaires et Éthique des affaires, etc.
    - Standards: ISO 26000, CSRD, GRI, ODD, ISO 14001, ISO 45001, etc.
    - Issues: Politique et charte, Transparence et anti-corruption, etc.
    - Criteria: Various criteria for each issue
    - Indicators: Comprehensive set of ESG indicators

  2. Relationships
    - Link sectors to subsectors
    - Link subsectors to standards
    - Link standards to issues
    - Link issues to criteria
    - Link criteria to indicators

  3. Data Structure
    - All data extracted from the provided screenshots
    - Proper hierarchical relationships maintained
*/

-- Insert Sectors
INSERT INTO sectors (name) VALUES 
('Gouvernance'),
('Social')
ON CONFLICT (name) DO NOTHING;

-- Insert Subsectors
INSERT INTO subsectors (name, sector_name) VALUES 
('Leadership et responsabilité', 'Gouvernance'),
('Conduite des affaires et Éthique des affaires', 'Gouvernance'),
('Parties prenantes et matérialité', 'Gouvernance'),
('Organisation et stratégie DD', 'Gouvernance'),
('Emplois et main d''œuvre', 'Social'),
('Formation, carrière et éducation', 'Social'),
('Droits humains, diligence et conformité', 'Social')
ON CONFLICT (name) DO NOTHING;

-- Insert Standards
INSERT INTO standards (code, name) VALUES 
('ISO26000', 'ISO 26000'),
('CSRD', 'CSRD'),
('GRI', 'GRI'),
('ODD', 'ODD'),
('ISO14001', 'ISO 14001'),
('ISO45001', 'ISO 45001')
ON CONFLICT (code) DO NOTHING;

-- Insert Issues
INSERT INTO issues (code, name) VALUES 
('POLITIQUE_CHARTE', 'Politique et charte'),
('TRANSPARENCE_ANTICORRUPTION', 'Transparence et anti-corruption'),
('PARTIES_PRENANTES_DIALOGUE', 'Parties prenantes (attentes, dialogue)'),
('ENJEUX_MATERIALITES', 'Enjeu et matérialités (G1)'),
('ORGANISATION_STRUCTURE_DD', 'Organisation et structure DD'),
('IRO_G1', 'IRO (G1)'),
('STRATEGIE_DD_ROADMAP', 'Stratégie DD, road map et planification des actions'),
('PERSONNEL_ENTREPRISE', 'Personnel de l''entreprise, emploi, dialogue social et liberté d''association (S1)'),
('EMPLOIS_MAIN_OEUVRE', 'Emplois et main d''œuvre'),
('FORMATION_CARRIERE', 'Formation, carrière et éducation'),
('POLITIQUE_DROITS_HUMAINS', 'Politique des droits humains'),
('CONSENTEMENT_ECLAIRE', 'consentement éclairé'),
('INCIDENTS_DROITS_HOMME', 'Incidents en matière de droits de l''Homme'),
('CONTINUITE_ACTIVITE', 'Continuité d''activité (S2)'),
('TRAVAIL_DECENT_PENIBILITE', 'Travail décent et pénibilité'),
('REMUNERATION_NEGOCIATION', 'Rémunération et négociation collective'),
('MESURE_COLLECTE_DONNEES', 'Mesure et collecte des données'),
('PLAINTES_RECLAMATIONS', 'Plaintes et réclamations')
ON CONFLICT (code) DO NOTHING;

-- Insert Criteria
INSERT INTO criteria (code, name) VALUES 
-- Gouvernance - Politique et charte
('FEMME_COMITE_DIRECTION', 'Femme dans le comité de Direction'),
('ACTIONS_IDENTIFICATION_NON_CONFORMITES', 'Actions d''identification des non-conformités'),
('ACTIONS_IDENTIFICATION_NON_CONFORMITES_SOCIO', 'Actions d''identification des non-conformités socio-économiques'),
('TOTAL_DIAGNOSTICS_NON_CONFORMITES', 'Total des diagnostics menés pour détecter les non-conformités'),
('SITES_AUDIT_INTERNE_DD', 'Sites ayant effectué un audit interne DD'),
('PART_SITES_AUDIT_INTERNE_DD', 'Part des sites ayant effectué un audit interne DD'),
('SITES_CERTIFIES_ISO_9001', 'Sites certifiés ISO 9001'),
('PART_SITES_CERTIFIES_ISO_9001', 'Part des sites certifiés ISO 9001'),
('SITES_CERTIFIES_ISO_14001', 'Sites certifiés ISO 14001'),
('PART_SITES_CERTIFIES_ISO_14001', 'Part des sites certifiés ISO 14001'),
('SITES_CERTIFIES_ISO_45001', 'Sites certifiés ISO 45001'),
('PART_SITES_CERTIFIES_ISO_45001', 'Part des sites certifiés ISO 45001'),

-- Gouvernance - Transparence et anti-corruption
('CONFLITS_INTERET_DECLARES', 'Conflits d''intérêt déclarés'),
('NOMBRE_CONDAMNATIONS_ANTICORRUPTION', 'Nombre de condamnations pour violation des lois anti-corruption durant la période de reporting'),
('MONTANT_AMENDES_ANTICORRUPTION', 'Montant total des amendes pour violation des lois anti-corruption durant la période de reporting'),
('CONSULTATIONS_DIALOGUES_PARTIES_PRENANTES', 'Nombre total de consultations / dialogues formels avec parties prenantes'),
('TAUX_PARTICIPATION_PARTIES_PRENANTES', 'Taux de participation des parties prenantes invitées'),
('PART_RECOMMANDATIONS_INTEGREES', 'Part des recommandations / attentes intégrées dans la stratégie'),
('NOMBRE_PROJETS_COCONSTRUITS', 'Nombre de projets ou actions co-construits avec parties prenantes'),
('NOMBRE_CONFLITS_LITIGES', 'Nombre de conflits ou litiges avec parties prenantes'),

-- Gouvernance - Enjeux et matérialités
('PART_ENJEUX_INTEGRES_OBJECTIFS', 'Part d''enjeux intégrés aux objectifs stratégiques'),
('TAUX_REALISATION_REUNIONS_DURABILITE', 'Taux de réalisation des réunions du comité de durabilité'),
('PART_DECISIONS_CRITERES_ESG', 'Part des décisions stratégiques impliquant des critères ESG'),
('TAUX_MISE_OEUVRE_ACTIONS_IRO', 'Taux de mise en œuvre des actions faces aux IRO'),
('TAUX_ACCES_OPPORTUNITES_MARCHES', 'Taux d''accès à de nouvelles opportunités de marchés verts'),
('PART_OBJECTIFS_ODD_ALIGNES', 'Part des objectifs DD de l''entreprise alignés avec les ODD pertinents'),
('TAUX_RESPECT_CALENDRIER_ACTIONS_DD', 'Taux de respect du calendrier de mise en œuvre des actions DD'),
('TAUX_ATTEINTE_OBJECTIFS_DD', 'Taux d''atteinte des objectifs DD'),
('TAUX_VERIFICATION_DONNEES', 'Taux de vérification des données collectées'),
('TAUX_ERREURS_DONNEES', 'Taux d''erreurs détectées sur les données collectées'),
('POURCENTAGE_SITES_COLLECTE', 'Pourcentage de sites / filiales couverts par la collecte des données'),
('POURCENTAGE_POSTES_COLLECTE', 'Pourcentage des postes / processus concernés par la collecte des données'),
('ACCESSIBILITE_DONNEES_PARTIES_PRENANTES', 'Accessibilité des données aux parties prenantes internes'),
('TAUX_MISE_JOUR_DONNEES', 'Taux de mise à jour des données'),
('PLAINTES_RECUES_CLIENTS', 'Plaintes reçues des clients'),
('TAUX_TRAITEMENT_PLAINTES', 'Taux de traitement des plaintes'),
('TAUX_SATISFACTION_PLAIGNANTS', 'Taux de satisfaction des plaignants'),
('PROPORTION_PLAINTES_COMPENSEES', 'Proportion des plaintes compensées'),
('NOMBRE_AMENDES_SANCTIONS', 'Nombre d''amendes ou sanctions reçues'),
('MONTANT_AMENDES_PAYEES', 'Montant total des amendes payées'),
('NOMBRE_PROCEDURES_COURS', 'Nombre de procédures en cours'),
('TAUX_MISE_OEUVRE_MESURES_CORRECTIVES', 'Taux de mise en œuvre des mesures correctives après sanction'),
('TAUX_FOURNISSEURS_DUE_DILIGENCE', 'Taux de fournisseurs évalués à une due diligence'),
('NOMBRE_CONTROLES_INTERNES', 'Nombre de contrôles internes réalisés'),
('TAUX_CORRECTION_NON_CONFORMITES', 'Taux de correction des non-conformités'),
('BUDGET_PILOTAGE_DD', 'Budget alloué au pilotage DD'),

-- Social - Personnel de l'entreprise
('COLLABORATEURS_CDI', 'Collaborateurs avec un contrat à durée indéterminée (CDI)'),
('COLLABORATEURS_CDD', 'Collaborateurs avec un contrat à durée déterminée (CDD, CDDi)'),
('TOTAL_COLLABORATEURS', 'Total des collaborateurs'),
('PART_COLLABORATEURS_CDI', 'Part des collaborateurs possédant un contrat à durée indéterminée'),
('COLLABORATEURS_SOUS_TRAITANTS', 'Collaborateurs sous-traitants'),
('TOTAL_COLLABORATEURS_SOUS_TRAITANTS', 'Total des collaborateurs (Total des collaborateurs+collaborateurs sous-traitants)'),
('COLLABORATEURS_FEMMES', 'Collaborateurs femmes'),
('COLLABORATEURS_HOMMES', 'Collaborateurs hommes'),
('OUVRIERS', 'Ouvriers'),
('EMPLOYES', 'Employés'),
('AGENTS_MAITRISE', 'Agents de maîtrise'),
('CADRES', 'Cadres'),
('FEMMES_OUVRIERES', 'Femmes ouvrières'),
('FEMMES_EMPLOYEES', 'Femmes employés'),
('FEMMES_AGENTS_MAITRISE', 'Femmes agents de maîtrise'),
('FEMMES_CADRES', 'Femmes cadres'),
('HOMMES_OUVRIERS', 'Hommes ouvriers'),
('HOMMES_EMPLOYES', 'Hommes employés'),
('HOMMES_AGENTS_MAITRISE', 'Hommes agents de maîtrise'),
('HOMMES_CADRES', 'Hommes cadres'),
('COLLABORATEURS_AGE_30', 'Collaborateurs dont l''âge ≤ 30 ans'),
('COLLABORATEURS_AGE_30_50', 'Collaborateurs dont l''âge >= 30 et <= 50 ans'),
('COLLABORATEURS_AGE_50_PLUS', 'Collaborateurs dont l''âge > 50 ans'),
('FEMMES_AGE_30', 'Femmes dont l''âge ≤ 30 ans'),
('FEMMES_AGE_30_50', 'Femmes dont l''âge >= 30 et <= 50 ans'),
('FEMMES_AGE_50_PLUS', 'Femmes dont l''âge > 50 ans'),
('HOMMES_AGE_30', 'Hommes dont l''âge ≤ 30 ans'),
('HOMMES_AGE_30_50', 'Hommes dont l''âge >= 30 et <= 50 ans'),
('HOMMES_AGE_50_PLUS', 'Hommes dont l''âge > 50 ans'),
('EMBAUCHES_ANNEE_30', 'Embauches de l''année dont l''âge ≤ 30 ans'),
('EMBAUCHES_ANNEE_30_50', 'Embauches de l''année dont l''âge >= 30 et <= 50 ans'),
('EMBAUCHES_ANNEE_50_PLUS', 'Embauches de l''année dont l''âge > 50 ans'),
('MOBILITE_INTERNE', 'Mobilité interne'),
('EMBAUCHES_FEMMES_30', 'Embauches de l''année femmes dont l''âge ≤ 30 ans'),
('EMBAUCHES_FEMMES_30_50', 'Embauches de l''année femmes dont l''âge >= 30 et <= 50 ans'),
('EMBAUCHES_FEMMES_50_PLUS', 'Embauches de l''année femmes dont l''âge > 50 ans'),
('TOTAL_EMBAUCHES_FEMMES', 'Total des embauches de l''année pour les femmes'),
('EMBAUCHES_HOMMES_30', 'Embauches de l''année hommes dont l''âge ≤ 30 ans'),
('EMBAUCHES_HOMMES_30_50', 'Embauches de l''année hommes dont l''âge >= 30 et <= 50 ans'),
('EMBAUCHES_HOMMES_50_PLUS', 'Embauches de l''année hommes dont l''âge > 50 ans'),
('TOTAL_EMBAUCHES_HOMMES', 'Total des embauches de l''année pour les hommes'),
('TOTAL_EMBAUCHES_ANNEE', 'Total des embauches de l''année'),
('TOTAL_ENTREES_ANNEE', 'Total des entrées de l''année'),
('DEMISSIONS_OUVRIERS', 'Démissions ouvrières'),
('DEMISSIONS_EMPLOYES', 'Démissions employés'),
('DEMISSIONS_AGENTS_MAITRISE', 'Démissions agents de maîtrise'),
('DEMISSIONS_CADRES', 'Démissions cadres'),
('TOTAL_DEMISSIONS', 'Total des démissions'),
('RETRAITE_ANTICIPEE', 'Retraite (anticipée, raison médicale, date normale)'),
('DEPARTS_NEGOCIES', 'Départs négociés'),
('LICENCIEMENTS_ECONOMIQUES', 'Licenciements (économiques, faute grave,...)'),
('ABANDON_POSTES', 'Abandon de postes'),
('DEPARTS_FIN_CONTRAT_CDD', 'Départs liés à une fin de contrat CDD'),
('DECES', 'Décès'),
('TOTAL_DEPARTS_ANNEE', 'Total des départs de l''année'),
('TOTAL_DEPART_HOMMES', 'Total départ collaborateurs hommes'),
('TOTAL_DEPART_FEMMES', 'Total départ collaborateurs femmes'),
('MOBILITE_EXTERNE', 'Mobilité externe'),
('TOTAL_SORTIES_ANNEE', 'Total des sorties de l''année'),
('TURNOVER_HOMMES', 'Turnover Hommes'),
('TURNOVER_FEMMES', 'Turnover Femmes'),
('INCIDENTS_MAJEURS_CHAINE_VALEUR', 'Nombre d''incidents majeurs dans la chaîne de valeur affectant la production ou la livraison'),
('PLANS_MITIGATION_RUPTURE', 'Nombre de plans de mitigation des risques de rupture de la chaîne de valeur mis en place'),
('SALAIRE_ENTREE_GROUPE', 'Salaire d''entrée dans le Groupe'),
('SALAIRE_MINIMUM_LEGAL', 'Salaire minimum légal et local'),
('SALAIRE_ENTREE_VS_LOCAL', 'Salaire d''entrée comparé au salaire local'),
('REMUNERATION_TOTALE_HOMMES', 'Rémunération totale - Hommes'),
('REMUNERATION_TOTALE_FEMMES', 'Rémunération totale - Femmes'),
('TOTAL_REMUNERATIONS_HF', 'TOTAL Rémunérations - Hommes+Femmes'),
('RATIO_REMUNERATION_CHIFFRE_AFFAIRES', 'Ratio Rémunération / Chiffre d''affaires'),
('TAUX_CROISSANCE_REMUNERATION', 'Taux de croissance de la Rémunération'),
('REMUNERATION_MOYENNE_HOMME', 'Rémunération annuelle moyenne - Homme'),
('REMUNERATION_MOYENNE_FEMME', 'Rémunération annuelle moyenne - Femme'),
('REMUNERATION_MOYENNE_TOTAL', 'Rémunération annuelle moyenne - Total collaborateur'),
('EGALITE_SALARIALE_HF_TOUTES_CATEGORIES', 'Égalité salariale entre les hommes et les femmes TOUTES CATÉGORIES'),
('REMUNERATION_OUVRIERS_HOMMES', 'Rémunération - OUVRIERS Hommes'),
('REMUNERATION_OUVRIERS_FEMMES', 'Rémunération - OUVRIERS Femmes'),
('TOTAL_REMUNERATION_OUVRIERS', 'TOTAL Rémunération - OUVRIERS'),
('REMUNERATION_MOYENNE_OUVRIER', 'Rémunération Moyenne par OUVRIER'),
('REMUNERATION_MOYENNE_OUVRIERS_HOMMES', 'Rémunération Moyenne - OUVRIERS Hommes'),
('REMUNERATION_MOYENNE_OUVRIERS_FEMMES', 'Rémunération Moyenne - OUVRIERS Femmes'),
('EGALITE_SALARIALE_HF_OUVRIERS', 'Égalité salariale entre les hommes et les femmes OUVRIERS'),
('REMUNERATION_EMPLOYES_HOMMES', 'Rémunération - EMPLOYÉS Hommes'),
('REMUNERATION_EMPLOYES_FEMMES', 'Rémunération - EMPLOYÉS Femmes'),
('TOTAL_REMUNERATION_EMPLOYES', 'TOTAL Rémunération - EMPLOYÉS'),
('REMUNERATION_MOYENNE_EMPLOYES', 'Rémunération Moyenne - EMPLOYÉS'),
('REMUNERATION_MOYENNE_EMPLOYES_HOMMES', 'Rémunération Moyenne - EMPLOYÉS Hommes'),
('REMUNERATION_MOYENNE_EMPLOYES_FEMMES', 'Rémunération Moyenne - EMPLOYÉS Femmes'),
('EGALITE_SALARIALE_HF_EMPLOYES', 'Égalité salariale entre les hommes et les femmes EMPLOYÉS'),
('REMUNERATION_AGENTS_MAITRISE_HOMMES', 'Rémunération - AGENTS DE MAÎTRISE Hommes'),
('REMUNERATION_AGENTS_MAITRISE_FEMMES', 'Rémunération - AGENTS DE MAÎTRISE Femmes'),
('TOTAL_REMUNERATION_AGENTS_MAITRISE', 'TOTAL Rémunération - AGENTS DE MAÎTRISE'),
('REMUNERATION_MOYENNE_AGENTS_MAITRISE', 'Rémunération Moyenne - AGENTS DE MAÎTRISE'),
('REMUNERATION_MOYENNE_AGENTS_MAITRISE_HOMMES', 'Rémunération Moyenne - AGENTS DE MAÎTRISE Hommes'),
('REMUNERATION_MOYENNE_AGENTS_MAITRISE_FEMMES', 'Rémunération Moyenne - AGENTS DE MAÎTRISE Femmes'),
('EGALITE_SALARIALE_HF_AGENTS_MAITRISE', 'Égalité salariale entre les hommes et les femmes AGENTS DE MAÎTRISE'),
('REMUNERATION_CADRES_HOMMES', 'Rémunération - CADRES Hommes'),
('REMUNERATION_CADRES_FEMMES', 'Rémunération - CADRES Femmes'),
('TOTAL_REMUNERATION_CADRES', 'TOTAL Rémunération - CADRES'),
('REMUNERATION_MOYENNE_CADRES', 'Rémunération Moyenne - CADRES'),
('REMUNERATION_MOYENNE_CADRES_HOMMES', 'Rémunération Moyenne - CADRES Hommes'),
('REMUNERATION_MOYENNE_CADRES_FEMMES', 'Rémunération Moyenne - CADRES Femmes'),
('EGALITE_SALARIALE_HF_CADRES', 'Égalité salariale entre les hommes et les femmes CADRES'),
('COLLABORATEURS_CONVENTIONS_COLLECTIVES', 'Collaborateurs couverts par des conventions collectives'),
('PART_SALARIES_POSTES_PENIBLES', 'Part des salariés exposés à des postes pénibles'),
('MESURES_PREVENTION_PENIBILITE', 'Nombre de mesures de prévention de la pénibilité mises en place'),
('PART_POSTES_ERGONOMIE', 'Part des postes bénéficiant d''ergonomie ou d''adaptation pour la santé'),
('HEURES_FORMATION_OUVRIERS', 'Heures de formation - ouvriers'),
('HEURES_FORMATION_EMPLOYES', 'Heures de formation - employés'),
('HEURES_FORMATION_AGENTS_MAITRISE', 'Heures de formation - agents de maîtrise'),
('HEURES_FORMATION_CADRES', 'Heures de formation - cadres'),
('TOTAL_HEURES_FORMATION', 'Total des heures de formation'),
('MOYENNE_HEURES_FORMATION', 'Moyenne des heures de formation'),
('HEURES_FORMATION_FEMMES', 'Heures de formation - collaborateurs femmes'),
('HEURES_FORMATION_HOMMES', 'Heures de formation - collaborateurs hommes'),
('MOYENNE_HEURES_FORMATION_FEMMES', 'Moyenne des heures de formation collaborateurs femmes'),
('MOYENNE_HEURES_FORMATION_HOMMES', 'Moyenne des heures de formation collaborateurs hommes'),
('MASSE_SALARIALE_FORMATION', 'Masse salariale durant la période de reporting'),
('DEPENSES_FORMATION', 'Dépenses de formation'),
('PART_MASSE_SALARIALE_FORMATION', 'Part de la masse salariale consacrée à la formation'),
('COLLABORATEURS_FORMES', 'Collaborateurs formés'),
('COLLABORATEURS_FEMMES_FORMEES', 'Collaborateurs femme formées'),
('COLLABORATEURS_HOMMES_FORMES', 'Collaborateurs Hommes formés'),
('POURCENTAGE_COLLABORATEURS_FORMES', 'Pourcentage des collaborateurs formés'),
('COLLABORATEURS_EXAMEN_PERFORMANCE', 'Collaborateurs ayant fait l''objet d''un examen de leur performance durant l''année'),
('PART_COLLABORATEURS_EXAMEN_PERFORMANCE', 'Part des Collaborateurs ayant fait l''objet d''un examen de leur performance durant l''année'),
('PART_COLLABORATEURS_FORMES_POLITIQUES', 'Part des collaborateurs formés aux politiques ou procédures en matière de droits de l''Homme'),
('NOMBRE_CONTRATS_CONSENTEMENT', 'Nombre de contrats, formulaires ou procédures incluant le consentement éclairé'),
('PROCESSUS_INFORMATION_CLAIRE', '% de processus intégrant une information claire et compréhensible pour les parties prenantes'),
('MECANISMES_RETRAIT_CONSENTEMENT', 'Nombre de mécanismes de retrait du consentement disponibles et leur accessibilité'),
('INCIDENTS_TRAVAIL_FORCE', 'Incidents remontés concernant le travail forcé'),
('SITES_PRODUCTION_SURVEILLES', 'Sites de production surveillés par des actions mises en place contre le travail forcé'),
('PART_SITES_PRODUCTION_SURVEILLES', 'Part des sites de production surveillés par des actions de lutte contre le travail forcé'),
('CAS_PROBLEMES_DROITS_HOMME', 'Cas identifiés de problèmes graves et incidents en matière de droits de l''Homme'),
('COLLABORATEURS_FORMES_DROITS_HOMME', 'Collaborateurs formés aux politiques ou procédures en matière de droits de l''Homme'),
('CADRES_AGENTS_MAITRISE_COMMUNAUTE', 'Cadres et agents de maîtrise recrutés dans la communauté locale'),
('FEMMES_POSTES_ENCADREMENT', 'Femmes dans les postes d''encadrement')
ON CONFLICT (code) DO NOTHING;

-- Insert Indicators
INSERT INTO indicators (code, name, unit, type, axe, formule, frequence) VALUES 
-- Gouvernance indicators
('IND_FEMME_COMITE_DIRECTION', 'Nombre de femme dans comité de Direction (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('IND_ACTIONS_IDENTIFICATION_NC', 'Audits, Évaluations, Inspections, effectués pour déterminer les non-conformités concernant les travailleurs et la chaîne de valeurs', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),
('IND_ACTIONS_IDENTIFICATION_NC_SOCIO', 'Audits, Évaluations, Inspections, effectués pour déterminer les non-conformités concernant les travailleurs et la chaîne de valeurs', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),
('IND_TOTAL_DIAGNOSTICS_NC', 'Total des Diagnostics menés pour détecter les non-conformités environnementales et des diagnostics menés pour détecter les non-conformités socio-économiques', 'Nombre', 'calculé', 'Gouvernance', 'somme', 'mensuelle'),
('IND_SITES_AUDIT_INTERNE_DD', 'Sites ayant effectué un auto-diagnostic RSE', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),
('IND_PART_SITES_AUDIT_INTERNE', 'Total des Sites ayant effectué un auto-diagnostic RSE / Total des Sites de production', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('IND_SITES_CERTIFIES_ISO_9001', 'Sites certifiés ISO 9001', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),
('IND_PART_SITES_ISO_9001', 'Total des Sites certifiés ISO 9001/ Total des Sites de production', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('IND_SITES_CERTIFIES_ISO_14001', 'Sites certifiés ISO 14001', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),
('IND_PART_SITES_ISO_14001', 'Sites certifiés ISO 14001/ Total des sites de production', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),
('IND_SITES_CERTIFIES_ISO_45001', 'Sites certifiés ISO 45001', 'Nombre', 'primaire', 'Gouvernance', 'somme', 'mensuelle'),
('IND_PART_SITES_ISO_45001', 'Sites certifiés ISO 45001/ Total des sites de production', '%', 'calculé', 'Gouvernance', 'dernier_mois', 'mensuelle'),

-- Social indicators
('IND_COLLABORATEURS_CDI', 'Collaborateurs à la fin d''année ayant un contrat de travail à durée indéterminée, pour un travail à temps plein ou à temps partiel', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('IND_COLLABORATEURS_CDD', 'Collaborateurs à la fin d''année ayant un contrat de travail, pour un travail à temps plein ou à temps partiel, au grand fin à l''expiration d''une période déterminée ou à l''achèvement d''une tâche spécifique', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('IND_TOTAL_COLLABORATEURS', 'Total des collaborateurs (CDI + CDD + CDDi)', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('IND_PART_COLLABORATEURS_CDI', 'Total des collaborateurs avec un contrat de travail à durée indéterminée / Total des collaborateurs', '%', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('IND_COLLABORATEURS_SOUS_TRAITANTS', 'Personnes qui effectuent un travail régulier sur place mais non considérées comme collaborateurs de SIPCA en vertu de la législation ou de la pratique nationale (contrat de travail)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('IND_TOTAL_COLLAB_SOUS_TRAITANTS', 'Total des collaborateurs + collaborateurs Sous-traitants', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('IND_COLLABORATEURS_FEMMES', 'Employées femmes quel que soit leur contrat de travail (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('IND_COLLABORATEURS_HOMMES', 'Employées hommes quel que soit leur contrat de travail (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('IND_OUVRIERS', 'Total des ouvriers et main-d''œuvre dans la production (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('IND_EMPLOYES', 'Fonctions administratives et techniciens (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('IND_AGENTS_MAITRISE', 'Agents de maîtrise (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('IND_CADRES', 'Cadres (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('IND_FEMMES_OUVRIERES', 'Femmes ouvrières (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('IND_FEMMES_EMPLOYEES', 'Femmes employés administratifs et techniciens (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('IND_FEMMES_AGENTS_MAITRISE', 'Femmes agents de maîtrise (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('IND_FEMMES_CADRES', 'Femmes cadres (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('IND_HOMMES_OUVRIERS', 'Hommes ouvriers', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('IND_HOMMES_EMPLOYES', 'Hommes employés administratifs et techniciens', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('IND_HOMMES_AGENTS_MAITRISE', 'Hommes agents de maîtrise', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('IND_HOMMES_CADRES', 'Hommes cadres', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('IND_COLLAB_AGE_30', 'Employés âge inférieur à 30 ans (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('IND_COLLAB_AGE_30_50', 'Employés âge supérieur ou égal à 30 ans et inférieur ou égal à 50 ans (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('IND_COLLAB_AGE_50_PLUS', 'Employés âge supérieur à 50 ans (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('IND_FEMMES_AGE_30', 'Femmes âge inférieur à 30 ans (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('IND_FEMMES_AGE_30_50', 'Femmes âge supérieur ou égal à 30 ans et inférieur ou égal à 50 ans (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('IND_FEMMES_AGE_50_PLUS', 'Femmes âge supérieur à 50 ans (CDI, CDD, CDDi)', 'Nombre', 'primaire', 'Social', 'dernier_mois', 'mensuelle'),
('IND_HOMMES_AGE_30', 'Hommes dont l''âge ≤ 30 ans', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('IND_HOMMES_AGE_30_50', 'Hommes dont l''âge >= 30 et ≤50 ans', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('IND_HOMMES_AGE_50_PLUS', 'Hommes dont l''âge > 50 ans', 'Nombre', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('IND_EMBAUCHES_AGE_30', 'Embauches - nouveaux collaborateurs dont l''âge ≤ 30 ans (possédant un contrat CDI ou CDD) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_EMBAUCHES_AGE_30_50', 'Embauches - nouveaux collaborateurs dont l''âge >= 30 et ≤ 50 ans (possédant un contrat CDI ou CDD) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_EMBAUCHES_AGE_50_PLUS', 'Embauches - nouveaux collaborateurs dont l''âge > 50 ans (possédant un contrat CDI ou CDD) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_MOBILITE_INTERNE', 'Dérivée d''un autre site ou d''une autre filiale pour raison de Mobilité interne', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_EMBAUCHES_FEMMES_30', 'Embauches - nouveaux collaborateurs femmes dont l''âge ≤ 30 ans (possédant un contrat CDI ou CDD) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_EMBAUCHES_FEMMES_30_50', 'Embauches - nouveaux collaborateurs femmes ayant un âge >= 30 et ≤ 50 ans (possédant un contrat CDI ou CDD) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_EMBAUCHES_FEMMES_50_PLUS', 'Embauches - nouveaux collaborateurs femmes dont l''âge > 50 ans (possédant un contrat CDI ou CDD) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_TOTAL_EMBAUCHES_FEMMES', 'Total des embauches de l''année femmes par classe d''âge', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('IND_EMBAUCHES_HOMMES_30', 'Embauches - nouveaux collaborateurs hommes dont l''âge ≤ 30 ans (possédant un contrat CDI ou CDD) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('IND_EMBAUCHES_HOMMES_30_50', 'Embauches - nouveaux collaborateurs hommes ayant un âge >= 30 et ≤ 50 ans (possédant un contrat CDI ou CDD) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('IND_EMBAUCHES_HOMMES_50_PLUS', 'Embauches - nouveaux collaborateurs hommes dont l''âge > 50 ans (possédant un contrat CDI ou CDD) qui rejoignent le groupe pour la première fois au cours de l''année de reporting', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('IND_TOTAL_EMBAUCHES_HOMMES', 'Total des embauches de l''année hommes par classe d''âge', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('IND_TOTAL_EMBAUCHES_ANNEE', 'Embauches de l''année hommes et femmes', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('IND_TOTAL_ENTREES_ANNEE', 'Total des entrées + Total des embauches + mobilité interne', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('IND_DEMISSIONS_OUVRIERS', 'Démissions ouvrières', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_DEMISSIONS_EMPLOYES', 'Démissions employés administratifs et techniciens', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_DEMISSIONS_AGENTS_MAITRISE', 'Démissions agents de maîtrise', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_DEMISSIONS_CADRES', 'Démissions cadres', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_TOTAL_DEMISSIONS', 'Total des démissions', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('IND_RETRAITE_ANTICIPEE', 'Départs par raison de Retraite (anticipée, raison médicale, date normale)', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_DEPARTS_NEGOCIES', 'Départs par raison de Départs négociés', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_LICENCIEMENTS_ECONOMIQUES', 'Départs par raison de Licenciements économiques ou fautes', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_ABANDON_POSTES', 'Départs par raison d''Abandon de postes', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_DEPARTS_FIN_CDD', 'Départs liés à une fin de contrat CDD', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_DECES', 'Départs pour raison de Décès', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_TOTAL_DEPARTS_ANNEE', 'Total des départs de l''année', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('IND_TOTAL_DEPART_HOMMES', 'Nombres d''hommes en CDI/CDD ayant quitté leur emploi, volontairement ou non durant l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_TOTAL_DEPART_FEMMES', 'Nombres de femmes en CDI/CDD ayant quitté leur emploi, volontairement ou non durant l''année de reporting', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_MOBILITE_EXTERNE', 'Départs pour raison de Mobilités sur un autre site ou filiales', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_TOTAL_SORTIES_ANNEE', 'Total des sorties + Total des départs de l''année + Mobilité externe', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('IND_TURNOVER_HOMMES', 'Total des Employées hommes ayant quitté l''organisation au cours de l''année / Total des employées hommes', 'Ratio', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('IND_TURNOVER_FEMMES', 'Total des Employées femmes ayant quitté l''organisation au cours de l''année / Total des employées femmes', 'Ratio', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('IND_INCIDENTS_MAJEURS_CHAINE', 'Nombre d''incidents majeurs dans la chaîne de valeur affectant la production ou la livraison', 'Nbre', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_PLANS_MITIGATION_RUPTURE', 'Nombre de plans de mitigation des risques de rupture de la chaîne de valeur mis en place', 'Nbre', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_SALAIRE_ENTREE_GROUPE', 'Salaire d''embauche le plus bas dans le Groupe SIPCA (annuel)', 'FCFA', 'primaire', 'Social', 'moyenne', 'mensuelle'),
('IND_SALAIRE_MINIMUM_LEGAL', 'Salaire moyen local selon la réglementation (annuel)', 'FCFA', 'primaire', 'Social', 'moyenne', 'mensuelle'),
('IND_SALAIRE_ENTREE_VS_LOCAL', 'Ratio du salaire d''entrée standard par pays, par rapport au salaire minimum local selon la réglementation (annuel)', 'Ratio', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('IND_REMUNERATION_TOTALE_HOMMES', 'Total annuel de la rémunération versée aux hommes', 'FCFA', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_REMUNERATION_TOTALE_FEMMES', 'Total annuel de la rémunération versée aux femmes', 'FCFA', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_TOTAL_REMUNERATIONS_HF', 'Total annuel de la rémunération versée aux hommes et aux femmes', 'FCFA', 'calculé', 'Social', 'somme', 'mensuelle'),
('IND_RATIO_REMUNERATION_CA', 'Total Rémunération annuelle Hommes + Femmes / 1000 / Chiffre d''affaires', 'FCFA', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('IND_TAUX_CROISSANCE_REMUNERATION', 'Taux de croissance de la Rémunération', 'FCFA', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('IND_REMUNERATION_MOYENNE_HOMME', 'Rémunération annuelle moyenne par homme', 'FCFA', 'calculé', 'Social', 'moyenne', 'mensuelle'),
('IND_REMUNERATION_MOYENNE_FEMME', 'Rémunération annuelle moyenne par femme', 'FCFA', 'calculé', 'Social', 'moyenne', 'mensuelle'),
('IND_REMUNERATION_MOYENNE_TOTAL', 'Rémunération annuelle moyenne par collaborateur', 'FCFA', 'calculé', 'Social', 'moyenne', 'mensuelle'),
('IND_EGALITE_SALARIALE_HF_TOUTES', 'Ratio entre la rémunération annuelle moyenne des femmes et la rémunération annuelle moyenne des femmes', 'Ratio', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('IND_HEURES_FORMATION_OUVRIERS', 'Total des heures de formation internes et externes des ouvriers', 'Heures', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_HEURES_FORMATION_EMPLOYES', 'Total des heures de formation internes et externes des employés', 'Heures', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_HEURES_FORMATION_AGENTS', 'Total des heures de formation internes et externes des agents de maîtrise', 'Heures', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_HEURES_FORMATION_CADRES', 'Total des heures de formation internes et externes des cadres', 'Heures', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_TOTAL_HEURES_FORMATION', 'Total des heures de formation pour toutes les catégories', 'Heures', 'calculé', 'Social', 'somme', 'mensuelle'),
('IND_MOYENNE_HEURES_FORMATION', 'Total des heures de formation pour toutes les catégories / Total des collaborateurs', 'Heures', 'calculé', 'Social', 'moyenne', 'mensuelle'),
('IND_HEURES_FORMATION_FEMMES', 'Sessions de formation internes et externes pour les femmes', 'Heures', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_HEURES_FORMATION_HOMMES', 'Total des heures de formation des collaborateurs - Total des heures de formation femmes', 'Heures', 'calculé', 'Social', 'somme', 'mensuelle'),
('IND_MOYENNE_HEURES_FEMMES', 'Total des heures de formation pour les femmes / Total des Employées femmes', 'Heures', 'calculé', 'Social', 'moyenne', 'mensuelle'),
('IND_MOYENNE_HEURES_HOMMES', 'Total des heures de formation pour les hommes / Total des Employées hommes', 'Heures', 'calculé', 'Social', 'moyenne', 'mensuelle'),
('IND_MASSE_SALARIALE_FORMATION', 'Salaire + charges sociales + avantages salariaux + coûts de formation', 'FCFA', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_DEPENSES_FORMATION', 'Budget alloué à la formation (prestataires externes, coûts d''organisation de la formation, déplacements dans le cadre de la formation...)', 'FCFA', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_PART_MASSE_SALARIALE_FORMATION', 'Total des Dépenses affectées pour la formation / Total de la Masse salariale * 100', '%', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('IND_COLLABORATEURS_FORMES', 'Nombre de collaborateurs formés', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_COLLABORATEURS_FEMMES_FORMEES', 'Nombre de femmes formées', 'Nombre', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_COLLABORATEURS_HOMMES_FORMES', 'Collaborateurs formés - collaborateurs femmes formées', 'Nombre', 'calculé', 'Social', 'somme', 'mensuelle'),
('IND_POURCENTAGE_COLLABORATEURS_FORMES', 'Collaborateurs formés / Total des Collaborateurs', '%', 'calculé', 'Social', 'dernier_mois', 'mensuelle'),
('IND_COLLABORATEURS_EXAMEN_PERFORMANCE', 'Nombre de collaborateurs ayant fait l''objet d''un examen de leur performance de de leur évolution de carrière durant l''année', '%', 'primaire', 'Social', 'somme', 'mensuelle'),
('IND_PART_COLLABORATEURS_EXAMEN', 'Total des Collaborateurs ayant fait l''objet d''un examen de leur performance et de leur évolution de carrière durant l''année / Total des Collaborateurs * 100', '%', 'calculé', 'Social', 'dernier_mois', 'mensuelle')
ON CONFLICT (code) DO NOTHING;

-- Link subsectors to standards
INSERT INTO subsector_standards (subsector_name, standard_codes) VALUES 
('Leadership et responsabilité', ARRAY['ISO26000', 'CSRD', 'GRI']),
('Conduite des affaires et Éthique des affaires', ARRAY['ISO26000', 'CSRD', 'GRI']),
('Parties prenantes et matérialité', ARRAY['ISO26000', 'CSRD', 'GRI']),
('Organisation et stratégie DD', ARRAY['ISO26000', 'CSRD', 'GRI']),
('Emplois et main d''œuvre', ARRAY['ISO26000', 'ODD', 'CSRD', 'GRI', 'ISO14001']),
('Formation, carrière et éducation', ARRAY['ISO26000', 'ODD', 'CSRD', 'GRI', 'ISO14001']),
('Droits humains, diligence et conformité', ARRAY['ISO26000', 'ODD', 'CSRD', 'GRI'])
ON CONFLICT (subsector_name) DO UPDATE SET standard_codes = EXCLUDED.standard_codes;

-- Link subsectors to issues
INSERT INTO subsector_standards_issues (subsector_name, standard_name, issue_codes) VALUES 
('Leadership et responsabilité', 'ISO 26000', ARRAY['POLITIQUE_CHARTE']),
('Leadership et responsabilité', 'CSRD', ARRAY['POLITIQUE_CHARTE']),
('Leadership et responsabilité', 'GRI', ARRAY['POLITIQUE_CHARTE']),
('Conduite des affaires et Éthique des affaires', 'ISO 26000', ARRAY['TRANSPARENCE_ANTICORRUPTION']),
('Conduite des affaires et Éthique des affaires', 'CSRD', ARRAY['TRANSPARENCE_ANTICORRUPTION']),
('Conduite des affaires et Éthique des affaires', 'GRI', ARRAY['TRANSPARENCE_ANTICORRUPTION']),
('Parties prenantes et matérialité', 'ISO 26000', ARRAY['PARTIES_PRENANTES_DIALOGUE']),
('Parties prenantes et matérialité', 'CSRD', ARRAY['PARTIES_PRENANTES_DIALOGUE']),
('Parties prenantes et matérialité', 'GRI', ARRAY['PARTIES_PRENANTES_DIALOGUE', 'ENJEUX_MATERIALITES']),
('Organisation et stratégie DD', 'ISO 26000', ARRAY['ORGANISATION_STRUCTURE_DD', 'IRO_G1', 'STRATEGIE_DD_ROADMAP']),
('Organisation et stratégie DD', 'CSRD', ARRAY['ORGANISATION_STRUCTURE_DD', 'IRO_G1', 'STRATEGIE_DD_ROADMAP']),
('Organisation et stratégie DD', 'GRI', ARRAY['ORGANISATION_STRUCTURE_DD', 'IRO_G1', 'STRATEGIE_DD_ROADMAP']),
('Emplois et main d''œuvre', 'ISO 26000', ARRAY['PERSONNEL_ENTREPRISE', 'EMPLOIS_MAIN_OEUVRE', 'CONTINUITE_ACTIVITE']),
('Emplois et main d''œuvre', 'ODD', ARRAY['PERSONNEL_ENTREPRISE', 'EMPLOIS_MAIN_OEUVRE']),
('Emplois et main d''œuvre', 'CSRD', ARRAY['PERSONNEL_ENTREPRISE', 'EMPLOIS_MAIN_OEUVRE']),
('Emplois et main d''œuvre', 'GRI', ARRAY['PERSONNEL_ENTREPRISE', 'EMPLOIS_MAIN_OEUVRE']),
('Emplois et main d''œuvre', 'ISO 14001', ARRAY['EMPLOIS_MAIN_OEUVRE']),
('Formation, carrière et éducation', 'ISO 26000', ARRAY['FORMATION_CARRIERE']),
('Formation, carrière et éducation', 'ODD', ARRAY['FORMATION_CARRIERE']),
('Formation, carrière et éducation', 'CSRD', ARRAY['FORMATION_CARRIERE']),
('Formation, carrière et éducation', 'GRI', ARRAY['FORMATION_CARRIERE']),
('Formation, carrière et éducation', 'ISO 14001', ARRAY['FORMATION_CARRIERE']),
('Droits humains, diligence et conformité', 'ISO 26000', ARRAY['POLITIQUE_DROITS_HUMAINS', 'CONSENTEMENT_ECLAIRE', 'INCIDENTS_DROITS_HOMME']),
('Droits humains, diligence et conformité', 'ODD', ARRAY['POLITIQUE_DROITS_HUMAINS', 'CONSENTEMENT_ECLAIRE', 'INCIDENTS_DROITS_HOMME']),
('Droits humains, diligence et conformité', 'CSRD', ARRAY['POLITIQUE_DROITS_HUMAINS', 'CONSENTEMENT_ECLAIRE', 'INCIDENTS_DROITS_HOMME']),
('Droits humains, diligence et conformité', 'GRI', ARRAY['POLITIQUE_DROITS_HUMAINS', 'CONSENTEMENT_ECLAIRE', 'INCIDENTS_DROITS_HOMME'])
ON CONFLICT (subsector_name, standard_name) DO UPDATE SET issue_codes = EXCLUDED.issue_codes;

-- Link issues to criteria
INSERT INTO subsector_standards_issues_criteria (subsector_name, standard_name, issue_name, criteria_codes) VALUES 
-- Leadership et responsabilité - Politique et charte
('Leadership et responsabilité', 'ISO 26000', 'Politique et charte', ARRAY[
  'FEMME_COMITE_DIRECTION', 'ACTIONS_IDENTIFICATION_NON_CONFORMITES', 'ACTIONS_IDENTIFICATION_NON_CONFORMITES_SOCIO',
  'TOTAL_DIAGNOSTICS_NON_CONFORMITES', 'SITES_AUDIT_INTERNE_DD', 'PART_SITES_AUDIT_INTERNE_DD',
  'SITES_CERTIFIES_ISO_9001', 'PART_SITES_CERTIFIES_ISO_9001', 'SITES_CERTIFIES_ISO_14001', 'PART_SITES_CERTIFIES_ISO_14001',
  'SITES_CERTIFIES_ISO_45001', 'PART_SITES_CERTIFIES_ISO_45001'
]),
('Leadership et responsabilité', 'CSRD', 'Politique et charte', ARRAY[
  'FEMME_COMITE_DIRECTION', 'ACTIONS_IDENTIFICATION_NON_CONFORMITES', 'ACTIONS_IDENTIFICATION_NON_CONFORMITES_SOCIO',
  'TOTAL_DIAGNOSTICS_NON_CONFORMITES', 'SITES_AUDIT_INTERNE_DD', 'PART_SITES_AUDIT_INTERNE_DD',
  'SITES_CERTIFIES_ISO_9001', 'PART_SITES_CERTIFIES_ISO_9001', 'SITES_CERTIFIES_ISO_14001', 'PART_SITES_CERTIFIES_ISO_14001',
  'SITES_CERTIFIES_ISO_45001', 'PART_SITES_CERTIFIES_ISO_45001'
]),
('Leadership et responsabilité', 'GRI', 'Politique et charte', ARRAY[
  'FEMME_COMITE_DIRECTION', 'ACTIONS_IDENTIFICATION_NON_CONFORMITES', 'ACTIONS_IDENTIFICATION_NON_CONFORMITES_SOCIO',
  'TOTAL_DIAGNOSTICS_NON_CONFORMITES', 'SITES_AUDIT_INTERNE_DD', 'PART_SITES_AUDIT_INTERNE_DD',
  'SITES_CERTIFIES_ISO_9001', 'PART_SITES_CERTIFIES_ISO_9001', 'SITES_CERTIFIES_ISO_14001', 'PART_SITES_CERTIFIES_ISO_14001',
  'SITES_CERTIFIES_ISO_45001', 'PART_SITES_CERTIFIES_ISO_45001'
]),

-- Conduite des affaires - Transparence et anti-corruption
('Conduite des affaires et Éthique des affaires', 'ISO 26000', 'Transparence et anti-corruption', ARRAY[
  'CONFLITS_INTERET_DECLARES', 'NOMBRE_CONDAMNATIONS_ANTICORRUPTION', 'MONTANT_AMENDES_ANTICORRUPTION'
]),
('Conduite des affaires et Éthique des affaires', 'CSRD', 'Transparence et anti-corruption', ARRAY[
  'CONFLITS_INTERET_DECLARES', 'NOMBRE_CONDAMNATIONS_ANTICORRUPTION', 'MONTANT_AMENDES_ANTICORRUPTION'
]),
('Conduite des affaires et Éthique des affaires', 'GRI', 'Transparence et anti-corruption', ARRAY[
  'CONFLITS_INTERET_DECLARES', 'NOMBRE_CONDAMNATIONS_ANTICORRUPTION', 'MONTANT_AMENDES_ANTICORRUPTION'
]),

-- Parties prenantes - Dialogue
('Parties prenantes et matérialité', 'ISO 26000', 'Parties prenantes (attentes, dialogue)', ARRAY[
  'CONSULTATIONS_DIALOGUES_PARTIES_PRENANTES', 'TAUX_PARTICIPATION_PARTIES_PRENANTES', 
  'PART_RECOMMANDATIONS_INTEGREES', 'NOMBRE_PROJETS_COCONSTRUITS', 'NOMBRE_CONFLITS_LITIGES'
]),
('Parties prenantes et matérialité', 'CSRD', 'Parties prenantes (attentes, dialogue)', ARRAY[
  'CONSULTATIONS_DIALOGUES_PARTIES_PRENANTES', 'TAUX_PARTICIPATION_PARTIES_PRENANTES', 
  'PART_RECOMMANDATIONS_INTEGREES', 'NOMBRE_PROJETS_COCONSTRUITS', 'NOMBRE_CONFLITS_LITIGES'
]),
('Parties prenantes et matérialité', 'GRI', 'Parties prenantes (attentes, dialogue)', ARRAY[
  'CONSULTATIONS_DIALOGUES_PARTIES_PRENANTES', 'TAUX_PARTICIPATION_PARTIES_PRENANTES', 
  'PART_RECOMMANDATIONS_INTEGREES', 'NOMBRE_PROJETS_COCONSTRUITS', 'NOMBRE_CONFLITS_LITIGES'
]),

-- Parties prenantes - Enjeux et matérialités
('Parties prenantes et matérialité', 'GRI', 'Enjeu et matérialités (G1)', ARRAY[
  'PART_ENJEUX_INTEGRES_OBJECTIFS'
]),

-- Organisation et stratégie DD
('Organisation et stratégie DD', 'ISO 26000', 'Organisation et structure DD', ARRAY[
  'TAUX_REALISATION_REUNIONS_DURABILITE', 'PART_DECISIONS_CRITERES_ESG'
]),
('Organisation et stratégie DD', 'CSRD', 'Organisation et structure DD', ARRAY[
  'TAUX_REALISATION_REUNIONS_DURABILITE', 'PART_DECISIONS_CRITERES_ESG'
]),
('Organisation et stratégie DD', 'GRI', 'Organisation et structure DD', ARRAY[
  'TAUX_REALISATION_REUNIONS_DURABILITE', 'PART_DECISIONS_CRITERES_ESG'
]),

('Organisation et stratégie DD', 'ISO 26000', 'IRO (G1)', ARRAY[
  'TAUX_MISE_OEUVRE_ACTIONS_IRO', 'TAUX_ACCES_OPPORTUNITES_MARCHES'
]),
('Organisation et stratégie DD', 'CSRD', 'IRO (G1)', ARRAY[
  'TAUX_MISE_OEUVRE_ACTIONS_IRO', 'TAUX_ACCES_OPPORTUNITES_MARCHES'
]),
('Organisation et stratégie DD', 'GRI', 'IRO (G1)', ARRAY[
  'TAUX_MISE_OEUVRE_ACTIONS_IRO', 'TAUX_ACCES_OPPORTUNITES_MARCHES'
]),

('Organisation et stratégie DD', 'ISO 26000', 'Stratégie DD, road map et planification des actions', ARRAY[
  'PART_OBJECTIFS_ODD_ALIGNES', 'TAUX_RESPECT_CALENDRIER_ACTIONS_DD', 'TAUX_ATTEINTE_OBJECTIFS_DD'
]),
('Organisation et stratégie DD', 'CSRD', 'Stratégie DD, road map et planification des actions', ARRAY[
  'PART_OBJECTIFS_ODD_ALIGNES', 'TAUX_RESPECT_CALENDRIER_ACTIONS_DD', 'TAUX_ATTEINTE_OBJECTIFS_DD'
]),
('Organisation et stratégie DD', 'GRI', 'Stratégie DD, road map et planification des actions', ARRAY[
  'PART_OBJECTIFS_ODD_ALIGNES', 'TAUX_RESPECT_CALENDRIER_ACTIONS_DD', 'TAUX_ATTEINTE_OBJECTIFS_DD'
]),

-- Mesure et collecte des données
('Organisation et stratégie DD', 'ISO 26000', 'Mesure et collecte des données', ARRAY[
  'TAUX_VERIFICATION_DONNEES', 'TAUX_ERREURS_DONNEES', 'POURCENTAGE_SITES_COLLECTE',
  'POURCENTAGE_POSTES_COLLECTE', 'ACCESSIBILITE_DONNEES_PARTIES_PRENANTES', 'TAUX_MISE_JOUR_DONNEES'
]),
('Organisation et stratégie DD', 'CSRD', 'Mesure et collecte des données', ARRAY[
  'TAUX_VERIFICATION_DONNEES', 'TAUX_ERREURS_DONNEES', 'POURCENTAGE_SITES_COLLECTE',
  'POURCENTAGE_POSTES_COLLECTE', 'ACCESSIBILITE_DONNEES_PARTIES_PRENANTES', 'TAUX_MISE_JOUR_DONNEES'
]),
('Organisation et stratégie DD', 'GRI', 'Mesure et collecte des données', ARRAY[
  'TAUX_VERIFICATION_DONNEES', 'TAUX_ERREURS_DONNEES', 'POURCENTAGE_SITES_COLLECTE',
  'POURCENTAGE_POSTES_COLLECTE', 'ACCESSIBILITE_DONNEES_PARTIES_PRENANTES', 'TAUX_MISE_JOUR_DONNEES'
]),

-- Plaintes et réclamations
('Organisation et stratégie DD', 'ISO 26000', 'Plaintes et réclamations', ARRAY[
  'PLAINTES_RECUES_CLIENTS', 'TAUX_TRAITEMENT_PLAINTES', 'TAUX_SATISFACTION_PLAIGNANTS',
  'PROPORTION_PLAINTES_COMPENSEES', 'NOMBRE_AMENDES_SANCTIONS', 'MONTANT_AMENDES_PAYEES',
  'NOMBRE_PROCEDURES_COURS', 'TAUX_MISE_OEUVRE_MESURES_CORRECTIVES', 'TAUX_FOURNISSEURS_DUE_DILIGENCE',
  'NOMBRE_CONTROLES_INTERNES', 'TAUX_CORRECTION_NON_CONFORMITES', 'BUDGET_PILOTAGE_DD'
]),
('Organisation et stratégie DD', 'CSRD', 'Plaintes et réclamations', ARRAY[
  'PLAINTES_RECUES_CLIENTS', 'TAUX_TRAITEMENT_PLAINTES', 'TAUX_SATISFACTION_PLAIGNANTS',
  'PROPORTION_PLAINTES_COMPENSEES', 'NOMBRE_AMENDES_SANCTIONS', 'MONTANT_AMENDES_PAYEES',
  'NOMBRE_PROCEDURES_COURS', 'TAUX_MISE_OEUVRE_MESURES_CORRECTIVES', 'TAUX_FOURNISSEURS_DUE_DILIGENCE',
  'NOMBRE_CONTROLES_INTERNES', 'TAUX_CORRECTION_NON_CONFORMITES', 'BUDGET_PILOTAGE_DD'
]),
('Organisation et stratégie DD', 'GRI', 'Plaintes et réclamations', ARRAY[
  'PLAINTES_RECUES_CLIENTS', 'TAUX_TRAITEMENT_PLAINTES', 'TAUX_SATISFACTION_PLAIGNANTS',
  'PROPORTION_PLAINTES_COMPENSEES', 'NOMBRE_AMENDES_SANCTIONS', 'MONTANT_AMENDES_PAYEES',
  'NOMBRE_PROCEDURES_COURS', 'TAUX_MISE_OEUVRE_MESURES_CORRECTIVES', 'TAUX_FOURNISSEURS_DUE_DILIGENCE',
  'NOMBRE_CONTROLES_INTERNES', 'TAUX_CORRECTION_NON_CONFORMITES', 'BUDGET_PILOTAGE_DD'
]),

-- Emplois et main d'œuvre
('Emplois et main d''œuvre', 'ISO 26000', 'Personnel de l''entreprise, emploi, dialogue social et liberté d''association (S1)', ARRAY[
  'COLLABORATEURS_CDI', 'COLLABORATEURS_CDD', 'TOTAL_COLLABORATEURS', 'PART_COLLABORATEURS_CDI',
  'COLLABORATEURS_SOUS_TRAITANTS', 'TOTAL_COLLABORATEURS_SOUS_TRAITANTS', 'COLLABORATEURS_FEMMES', 'COLLABORATEURS_HOMMES',
  'OUVRIERS', 'EMPLOYES', 'AGENTS_MAITRISE', 'CADRES', 'FEMMES_OUVRIERES', 'FEMMES_EMPLOYEES',
  'FEMMES_AGENTS_MAITRISE', 'FEMMES_CADRES', 'HOMMES_OUVRIERS', 'HOMMES_EMPLOYES', 'HOMMES_AGENTS_MAITRISE', 'HOMMES_CADRES',
  'COLLABORATEURS_AGE_30', 'COLLABORATEURS_AGE_30_50', 'COLLABORATEURS_AGE_50_PLUS',
  'FEMMES_AGE_30', 'FEMMES_AGE_30_50', 'FEMMES_AGE_50_PLUS',
  'HOMMES_AGE_30', 'HOMMES_AGE_30_50', 'HOMMES_AGE_50_PLUS',
  'EMBAUCHES_AGE_30', 'EMBAUCHES_AGE_30_50', 'EMBAUCHES_AGE_50_PLUS', 'MOBILITE_INTERNE',
  'EMBAUCHES_FEMMES_30', 'EMBAUCHES_FEMMES_30_50', 'EMBAUCHES_FEMMES_50_PLUS', 'TOTAL_EMBAUCHES_FEMMES',
  'EMBAUCHES_HOMMES_30', 'EMBAUCHES_HOMMES_30_50', 'EMBAUCHES_HOMMES_50_PLUS', 'TOTAL_EMBAUCHES_HOMMES',
  'TOTAL_EMBAUCHES_ANNEE', 'TOTAL_ENTREES_ANNEE', 'DEMISSIONS_OUVRIERS', 'DEMISSIONS_EMPLOYES',
  'DEMISSIONS_AGENTS_MAITRISE', 'DEMISSIONS_CADRES', 'TOTAL_DEMISSIONS', 'RETRAITE_ANTICIPEE',
  'DEPARTS_NEGOCIES', 'LICENCIEMENTS_ECONOMIQUES', 'ABANDON_POSTES', 'DEPARTS_FIN_CONTRAT_CDD',
  'DECES', 'TOTAL_DEPARTS_ANNEE', 'TOTAL_DEPART_HOMMES', 'TOTAL_DEPART_FEMMES',
  'MOBILITE_EXTERNE', 'TOTAL_SORTIES_ANNEE', 'TURNOVER_HOMMES', 'TURNOVER_FEMMES'
]),

('Emplois et main d''œuvre', 'ODD', 'Personnel de l''entreprise, emploi, dialogue social et liberté d''association (S1)', ARRAY[
  'COLLABORATEURS_CDI', 'COLLABORATEURS_CDD', 'TOTAL_COLLABORATEURS', 'PART_COLLABORATEURS_CDI',
  'COLLABORATEURS_SOUS_TRAITANTS', 'TOTAL_COLLABORATEURS_SOUS_TRAITANTS', 'COLLABORATEURS_FEMMES', 'COLLABORATEURS_HOMMES'
]),

('Emplois et main d''œuvre', 'CSRD', 'Personnel de l''entreprise, emploi, dialogue social et liberté d''association (S1)', ARRAY[
  'COLLABORATEURS_CDI', 'COLLABORATEURS_CDD', 'TOTAL_COLLABORATEURS', 'PART_COLLABORATEURS_CDI',
  'COLLABORATEURS_SOUS_TRAITANTS', 'TOTAL_COLLABORATEURS_SOUS_TRAITANTS', 'COLLABORATEURS_FEMMES', 'COLLABORATEURS_HOMMES'
]),

('Emplois et main d''œuvre', 'GRI', 'Personnel de l''entreprise, emploi, dialogue social et liberté d''association (S1)', ARRAY[
  'COLLABORATEURS_CDI', 'COLLABORATEURS_CDD', 'TOTAL_COLLABORATEURS', 'PART_COLLABORATEURS_CDI',
  'COLLABORATEURS_SOUS_TRAITANTS', 'TOTAL_COLLABORATEURS_SOUS_TRAITANTS', 'COLLABORATEURS_FEMMES', 'COLLABORATEURS_HOMMES'
]),

('Emplois et main d''œuvre', 'ISO 14001', 'Emplois et main d''œuvre', ARRAY[
  'COLLABORATEURS_CDI', 'COLLABORATEURS_CDD', 'TOTAL_COLLABORATEURS'
]),

('Emplois et main d''œuvre', 'ISO 26000', 'Continuité d''activité (S2)', ARRAY[
  'INCIDENTS_MAJEURS_CHAINE_VALEUR', 'PLANS_MITIGATION_RUPTURE'
]),

('Emplois et main d''œuvre', 'ISO 26000', 'Rémunération et négociation collective', ARRAY[
  'SALAIRE_ENTREE_GROUPE', 'SALAIRE_MINIMUM_LEGAL', 'SALAIRE_ENTREE_VS_LOCAL',
  'REMUNERATION_TOTALE_HOMMES', 'REMUNERATION_TOTALE_FEMMES', 'TOTAL_REMUNERATIONS_HF',
  'RATIO_REMUNERATION_CA', 'TAUX_CROISSANCE_REMUNERATION', 'REMUNERATION_MOYENNE_HOMME',
  'REMUNERATION_MOYENNE_FEMME', 'REMUNERATION_MOYENNE_TOTAL', 'EGALITE_SALARIALE_HF_TOUTES_CATEGORIES'
]),

('Emplois et main d''œuvre', 'ISO 26000', 'Travail décent et pénibilité', ARRAY[
  'COLLABORATEURS_CONVENTIONS_COLLECTIVES', 'PART_SALARIES_POSTES_PENIBLES', 'MESURES_PREVENTION_PENIBILITE', 'PART_POSTES_ERGONOMIE'
]),

-- Formation, carrière et éducation
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', ARRAY[
  'HEURES_FORMATION_OUVRIERS', 'HEURES_FORMATION_EMPLOYES', 'HEURES_FORMATION_AGENTS_MAITRISE',
  'HEURES_FORMATION_CADRES', 'TOTAL_HEURES_FORMATION', 'MOYENNE_HEURES_FORMATION',
  'HEURES_FORMATION_FEMMES', 'HEURES_FORMATION_HOMMES', 'MOYENNE_HEURES_FEMMES', 'MOYENNE_HEURES_HOMMES',
  'MASSE_SALARIALE_FORMATION', 'DEPENSES_FORMATION', 'PART_MASSE_SALARIALE_FORMATION',
  'COLLABORATEURS_FORMES', 'COLLABORATEURS_FEMMES_FORMEES', 'COLLABORATEURS_HOMMES_FORMES',
  'POURCENTAGE_COLLABORATEURS_FORMES', 'COLLABORATEURS_EXAMEN_PERFORMANCE', 'PART_COLLABORATEURS_EXAMEN'
]),

('Formation, carrière et éducation', 'ODD', 'Formation, carrière et éducation', ARRAY[
  'HEURES_FORMATION_OUVRIERS', 'HEURES_FORMATION_EMPLOYES', 'HEURES_FORMATION_AGENTS_MAITRISE',
  'HEURES_FORMATION_CADRES', 'TOTAL_HEURES_FORMATION', 'MOYENNE_HEURES_FORMATION'
]),

('Formation, carrière et éducation', 'CSRD', 'Formation, carrière et éducation', ARRAY[
  'HEURES_FORMATION_OUVRIERS', 'HEURES_FORMATION_EMPLOYES', 'HEURES_FORMATION_AGENTS_MAITRISE',
  'HEURES_FORMATION_CADRES', 'TOTAL_HEURES_FORMATION', 'MOYENNE_HEURES_FORMATION'
]),

('Formation, carrière et éducation', 'GRI', 'Formation, carrière et éducation', ARRAY[
  'HEURES_FORMATION_OUVRIERS', 'HEURES_FORMATION_EMPLOYES', 'HEURES_FORMATION_AGENTS_MAITRISE',
  'HEURES_FORMATION_CADRES', 'TOTAL_HEURES_FORMATION', 'MOYENNE_HEURES_FORMATION'
]),

('Formation, carrière et éducation', 'ISO 14001', 'Formation, carrière et éducation', ARRAY[
  'HEURES_FORMATION_OUVRIERS', 'HEURES_FORMATION_EMPLOYES', 'HEURES_FORMATION_AGENTS_MAITRISE',
  'HEURES_FORMATION_CADRES', 'TOTAL_HEURES_FORMATION', 'MOYENNE_HEURES_FORMATION'
]),

-- Droits humains
('Droits humains, diligence et conformité', 'ISO 26000', 'Politique des droits humains', ARRAY[
  'PART_COLLABORATEURS_FORMES_POLITIQUES'
]),
('Droits humains, diligence et conformité', 'ODD', 'Politique des droits humains', ARRAY[
  'PART_COLLABORATEURS_FORMES_POLITIQUES'
]),
('Droits humains, diligence et conformité', 'CSRD', 'Politique des droits humains', ARRAY[
  'PART_COLLABORATEURS_FORMES_POLITIQUES'
]),
('Droits humains, diligence et conformité', 'GRI', 'Politique des droits humains', ARRAY[
  'PART_COLLABORATEURS_FORMES_POLITIQUES'
]),

('Droits humains, diligence et conformité', 'ISO 26000', 'consentement éclairé', ARRAY[
  'NOMBRE_CONTRATS_CONSENTEMENT', 'PROCESSUS_INFORMATION_CLAIRE', 'MECANISMES_RETRAIT_CONSENTEMENT'
]),
('Droits humains, diligence et conformité', 'ODD', 'consentement éclairé', ARRAY[
  'NOMBRE_CONTRATS_CONSENTEMENT', 'PROCESSUS_INFORMATION_CLAIRE', 'MECANISMES_RETRAIT_CONSENTEMENT'
]),
('Droits humains, diligence et conformité', 'CSRD', 'consentement éclairé', ARRAY[
  'NOMBRE_CONTRATS_CONSENTEMENT', 'PROCESSUS_INFORMATION_CLAIRE', 'MECANISMES_RETRAIT_CONSENTEMENT'
]),
('Droits humains, diligence et conformité', 'GRI', 'consentement éclairé', ARRAY[
  'NOMBRE_CONTRATS_CONSENTEMENT', 'PROCESSUS_INFORMATION_CLAIRE', 'MECANISMES_RETRAIT_CONSENTEMENT'
]),

('Droits humains, diligence et conformité', 'ISO 26000', 'Incidents en matière de droits de l''Homme', ARRAY[
  'INCIDENTS_TRAVAIL_FORCE', 'SITES_PRODUCTION_SURVEILLES', 'PART_SITES_PRODUCTION_SURVEILLES',
  'CAS_PROBLEMES_DROITS_HOMME', 'COLLABORATEURS_FORMES_DROITS_HOMME', 'CADRES_AGENTS_MAITRISE_COMMUNAUTE', 'FEMMES_POSTES_ENCADREMENT'
]),
('Droits humains, diligence et conformité', 'ODD', 'Incidents en matière de droits de l''Homme', ARRAY[
  'INCIDENTS_TRAVAIL_FORCE', 'SITES_PRODUCTION_SURVEILLES', 'PART_SITES_PRODUCTION_SURVEILLES',
  'CAS_PROBLEMES_DROITS_HOMME', 'COLLABORATEURS_FORMES_DROITS_HOMME'
]),
('Droits humains, diligence et conformité', 'CSRD', 'Incidents en matière de droits de l''Homme', ARRAY[
  'INCIDENTS_TRAVAIL_FORCE', 'SITES_PRODUCTION_SURVEILLES', 'PART_SITES_PRODUCTION_SURVEILLES',
  'CAS_PROBLEMES_DROITS_HOMME', 'COLLABORATEURS_FORMES_DROITS_HOMME'
]),
('Droits humains, diligence et conformité', 'GRI', 'Incidents en matière de droits de l''Homme', ARRAY[
  'INCIDENTS_TRAVAIL_FORCE', 'SITES_PRODUCTION_SURVEILLES', 'PART_SITES_PRODUCTION_SURVEILLES',
  'CAS_PROBLEMES_DROITS_HOMME', 'COLLABORATEURS_FORMES_DROITS_HOMME'
])
ON CONFLICT (subsector_name, standard_name) DO UPDATE SET criteria_codes = EXCLUDED.criteria_codes;

-- Link criteria to indicators
INSERT INTO subsector_standards_issues_criteria_indicators (subsector_name, standard_name, issue_name, criteria_name, indicator_codes, unit) VALUES 
-- Gouvernance - Leadership et responsabilité
('Leadership et responsabilité', 'ISO 26000', 'Politique et charte', 'Femme dans le comité de Direction', ARRAY['IND_FEMME_COMITE_DIRECTION'], 'Nombre'),
('Leadership et responsabilité', 'ISO 26000', 'Politique et charte', 'Actions d''identification des non-conformités', ARRAY['IND_ACTIONS_IDENTIFICATION_NC'], 'Nombre'),
('Leadership et responsabilité', 'ISO 26000', 'Politique et charte', 'Actions d''identification des non-conformités socio-économiques', ARRAY['IND_ACTIONS_IDENTIFICATION_NC_SOCIO'], 'Nombre'),
('Leadership et responsabilité', 'ISO 26000', 'Politique et charte', 'Total des diagnostics menés pour détecter les non-conformités', ARRAY['IND_TOTAL_DIAGNOSTICS_NC'], 'Nombre'),
('Leadership et responsabilité', 'ISO 26000', 'Politique et charte', 'Sites ayant effectué un audit interne DD', ARRAY['IND_SITES_AUDIT_INTERNE_DD'], 'Nombre'),
('Leadership et responsabilité', 'ISO 26000', 'Politique et charte', 'Part des sites ayant effectué un audit interne DD', ARRAY['IND_PART_SITES_AUDIT_INTERNE'], '%'),
('Leadership et responsabilité', 'ISO 26000', 'Politique et charte', 'Sites certifiés ISO 9001', ARRAY['IND_SITES_CERTIFIES_ISO_9001'], 'Nombre'),
('Leadership et responsabilité', 'ISO 26000', 'Politique et charte', 'Part des sites certifiés ISO 9001', ARRAY['IND_PART_SITES_ISO_9001'], '%'),
('Leadership et responsabilité', 'ISO 26000', 'Politique et charte', 'Sites certifiés ISO 14001', ARRAY['IND_SITES_CERTIFIES_ISO_14001'], 'Nombre'),
('Leadership et responsabilité', 'ISO 26000', 'Politique et charte', 'Part des sites certifiés ISO 14001', ARRAY['IND_PART_SITES_ISO_14001'], '%'),
('Leadership et responsabilité', 'ISO 26000', 'Politique et charte', 'Sites certifiés ISO 45001', ARRAY['IND_SITES_CERTIFIES_ISO_45001'], 'Nombre'),
('Leadership et responsabilité', 'ISO 26000', 'Politique et charte', 'Part des sites certifiés ISO 45001', ARRAY['IND_PART_SITES_ISO_45001'], '%'),

-- Social - Emplois et main d'œuvre
('Emplois et main d''œuvre', 'ISO 26000', 'Personnel de l''entreprise, emploi, dialogue social et liberté d''association (S1)', 'Collaborateurs avec un contrat à durée indéterminée (CDI)', ARRAY['IND_COLLABORATEURS_CDI'], 'Nombre'),
('Emplois et main d''œuvre', 'ISO 26000', 'Personnel de l''entreprise, emploi, dialogue social et liberté d''association (S1)', 'Collaborateurs avec un contrat à durée déterminée (CDD, CDDi)', ARRAY['IND_COLLABORATEURS_CDD'], 'Nombre'),
('Emplois et main d''œuvre', 'ISO 26000', 'Personnel de l''entreprise, emploi, dialogue social et liberté d''association (S1)', 'Total des collaborateurs', ARRAY['IND_TOTAL_COLLABORATEURS'], 'Nombre'),
('Emplois et main d''œuvre', 'ISO 26000', 'Personnel de l''entreprise, emploi, dialogue social et liberté d''association (S1)', 'Part des collaborateurs possédant un contrat à durée indéterminée', ARRAY['IND_PART_COLLABORATEURS_CDI'], '%'),
('Emplois et main d''œuvre', 'ISO 26000', 'Personnel de l''entreprise, emploi, dialogue social et liberté d''association (S1)', 'Collaborateurs sous-traitants', ARRAY['IND_COLLABORATEURS_SOUS_TRAITANTS'], 'Nombre'),
('Emplois et main d''œuvre', 'ISO 26000', 'Personnel de l''entreprise, emploi, dialogue social et liberté d''association (S1)', 'Total des collaborateurs (Total des collaborateurs+collaborateurs sous-traitants)', ARRAY['IND_TOTAL_COLLAB_SOUS_TRAITANTS'], 'Nombre'),
('Emplois et main d''œuvre', 'ISO 26000', 'Personnel de l''entreprise, emploi, dialogue social et liberté d''association (S1)', 'Collaborateurs femmes', ARRAY['IND_COLLABORATEURS_FEMMES'], 'Nombre'),
('Emplois et main d''œuvre', 'ISO 26000', 'Personnel de l''entreprise, emploi, dialogue social et liberté d''association (S1)', 'Collaborateurs hommes', ARRAY['IND_COLLABORATEURS_HOMMES'], 'Nombre'),
('Emplois et main d''œuvre', 'ISO 26000', 'Personnel de l''entreprise, emploi, dialogue social et liberté d''association (S1)', 'Ouvriers', ARRAY['IND_OUVRIERS'], 'Nombre'),
('Emplois et main d''œuvre', 'ISO 26000', 'Personnel de l''entreprise, emploi, dialogue social et liberté d''association (S1)', 'Employés', ARRAY['IND_EMPLOYES'], 'Nombre'),
('Emplois et main d''œuvre', 'ISO 26000', 'Personnel de l''entreprise, emploi, dialogue social et liberté d''association (S1)', 'Agents de maîtrise', ARRAY['IND_AGENTS_MAITRISE'], 'Nombre'),
('Emplois et main d''œuvre', 'ISO 26000', 'Personnel de l''entreprise, emploi, dialogue social et liberté d''association (S1)', 'Cadres', ARRAY['IND_CADRES'], 'Nombre'),

-- Formation indicators
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Heures de formation - ouvriers', ARRAY['IND_HEURES_FORMATION_OUVRIERS'], 'Heures'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Heures de formation - employés', ARRAY['IND_HEURES_FORMATION_EMPLOYES'], 'Heures'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Heures de formation - agents de maîtrise', ARRAY['IND_HEURES_FORMATION_AGENTS'], 'Heures'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Heures de formation - cadres', ARRAY['IND_HEURES_FORMATION_CADRES'], 'Heures'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Total des heures de formation', ARRAY['IND_TOTAL_HEURES_FORMATION'], 'Heures'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Moyenne des heures de formation', ARRAY['IND_MOYENNE_HEURES_FORMATION'], 'Heures'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Heures de formation - collaborateurs femmes', ARRAY['IND_HEURES_FORMATION_FEMMES'], 'Heures'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Heures de formation - collaborateurs hommes', ARRAY['IND_HEURES_FORMATION_HOMMES'], 'Heures'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Moyenne des heures de formation collaborateurs femmes', ARRAY['IND_MOYENNE_HEURES_FEMMES'], 'Heures'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Moyenne des heures de formation collaborateurs hommes', ARRAY['IND_MOYENNE_HEURES_HOMMES'], 'Heures'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Masse salariale durant la période de reporting', ARRAY['IND_MASSE_SALARIALE_FORMATION'], 'FCFA'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Dépenses de formation', ARRAY['IND_DEPENSES_FORMATION'], 'FCFA'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Part de la masse salariale consacrée à la formation', ARRAY['IND_PART_MASSE_SALARIALE_FORMATION'], '%'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Collaborateurs formés', ARRAY['IND_COLLABORATEURS_FORMES'], 'Nombre'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Collaborateurs femme formées', ARRAY['IND_COLLABORATEURS_FEMMES_FORMEES'], 'Nombre'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Collaborateurs Hommes formés', ARRAY['IND_COLLABORATEURS_HOMMES_FORMES'], 'Nombre'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Pourcentage des collaborateurs formés', ARRAY['IND_POURCENTAGE_COLLABORATEURS_FORMES'], '%'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Collaborateurs ayant fait l''objet d''un examen de leur performance durant l''année', ARRAY['IND_COLLABORATEURS_EXAMEN_PERFORMANCE'], '%'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Part des Collaborateurs ayant fait l''objet d''un examen de leur performance durant l''année', ARRAY['IND_PART_COLLABORATEURS_EXAMEN'], '%')
ON CONFLICT (subsector_name, standard_name, issue_name, criteria_name) DO UPDATE SET indicator_codes = EXCLUDED.indicator_codes;

-- Create default processes for the new indicators
INSERT INTO processes (code, name, description, indicator_codes, organization_name) VALUES 
('PROC_GOUVERNANCE', 'Processus Gouvernance', 'Processus de gouvernance et leadership', ARRAY[
  'IND_FEMME_COMITE_DIRECTION', 'IND_ACTIONS_IDENTIFICATION_NC', 'IND_ACTIONS_IDENTIFICATION_NC_SOCIO',
  'IND_TOTAL_DIAGNOSTICS_NC', 'IND_SITES_AUDIT_INTERNE_DD', 'IND_PART_SITES_AUDIT_INTERNE',
  'IND_SITES_CERTIFIES_ISO_9001', 'IND_PART_SITES_ISO_9001', 'IND_SITES_CERTIFIES_ISO_14001', 'IND_PART_SITES_ISO_14001',
  'IND_SITES_CERTIFIES_ISO_45001', 'IND_PART_SITES_ISO_45001'
], 'TestFiliere'),
('PROC_EMPLOI_RH', 'Processus Emploi et RH', 'Processus de gestion des ressources humaines et emploi', ARRAY[
  'IND_COLLABORATEURS_CDI', 'IND_COLLABORATEURS_CDD', 'IND_TOTAL_COLLABORATEURS', 'IND_PART_COLLABORATEURS_CDI',
  'IND_COLLABORATEURS_SOUS_TRAITANTS', 'IND_TOTAL_COLLAB_SOUS_TRAITANTS', 'IND_COLLABORATEURS_FEMMES', 'IND_COLLABORATEURS_HOMMES',
  'IND_OUVRIERS', 'IND_EMPLOYES', 'IND_AGENTS_MAITRISE', 'IND_CADRES',
  'IND_FEMMES_OUVRIERES', 'IND_FEMMES_EMPLOYEES', 'IND_FEMMES_AGENTS_MAITRISE', 'IND_FEMMES_CADRES',
  'IND_HOMMES_OUVRIERS', 'IND_HOMMES_EMPLOYES', 'IND_HOMMES_AGENTS_MAITRISE', 'IND_HOMMES_CADRES',
  'IND_COLLAB_AGE_30', 'IND_COLLAB_AGE_30_50', 'IND_COLLAB_AGE_50_PLUS',
  'IND_FEMMES_AGE_30', 'IND_FEMMES_AGE_30_50', 'IND_FEMMES_AGE_50_PLUS',
  'IND_HOMMES_AGE_30', 'IND_HOMMES_AGE_30_50', 'IND_HOMMES_AGE_50_PLUS',
  'IND_EMBAUCHES_AGE_30', 'IND_EMBAUCHES_AGE_30_50', 'IND_EMBAUCHES_AGE_50_PLUS', 'IND_MOBILITE_INTERNE',
  'IND_EMBAUCHES_FEMMES_30', 'IND_EMBAUCHES_FEMMES_30_50', 'IND_EMBAUCHES_FEMMES_50_PLUS', 'IND_TOTAL_EMBAUCHES_FEMMES',
  'IND_EMBAUCHES_HOMMES_30', 'IND_EMBAUCHES_HOMMES_30_50', 'IND_EMBAUCHES_HOMMES_50_PLUS', 'IND_TOTAL_EMBAUCHES_HOMMES',
  'IND_TOTAL_EMBAUCHES_ANNEE', 'IND_TOTAL_ENTREES_ANNEE', 'IND_DEMISSIONS_OUVRIERS', 'IND_DEMISSIONS_EMPLOYES',
  'IND_DEMISSIONS_AGENTS_MAITRISE', 'IND_DEMISSIONS_CADRES', 'IND_TOTAL_DEMISSIONS', 'IND_RETRAITE_ANTICIPEE',
  'IND_DEPARTS_NEGOCIES', 'IND_LICENCIEMENTS_ECONOMIQUES', 'IND_ABANDON_POSTES', 'IND_DEPARTS_FIN_CDD',
  'IND_DECES', 'IND_TOTAL_DEPARTS_ANNEE', 'IND_TOTAL_DEPART_HOMMES', 'IND_TOTAL_DEPART_FEMMES',
  'IND_MOBILITE_EXTERNE', 'IND_TOTAL_SORTIES_ANNEE', 'IND_TURNOVER_HOMMES', 'IND_TURNOVER_FEMMES',
  'IND_INCIDENTS_MAJEURS_CHAINE', 'IND_PLANS_MITIGATION_RUPTURE', 'IND_SALAIRE_ENTREE_GROUPE',
  'IND_SALAIRE_MINIMUM_LEGAL', 'IND_SALAIRE_ENTREE_VS_LOCAL', 'IND_REMUNERATION_TOTALE_HOMMES',
  'IND_REMUNERATION_TOTALE_FEMMES', 'IND_TOTAL_REMUNERATIONS_HF', 'IND_RATIO_REMUNERATION_CA',
  'IND_TAUX_CROISSANCE_REMUNERATION', 'IND_REMUNERATION_MOYENNE_HOMME', 'IND_REMUNERATION_MOYENNE_FEMME',
  'IND_REMUNERATION_MOYENNE_TOTAL', 'IND_EGALITE_SALARIALE_HF_TOUTES'
], 'Ressources Humaines'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Heures de formation - ouvriers', ARRAY['IND_HEURES_FORMATION_OUVRIERS'], 'Heures'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Heures de formation - employés', ARRAY['IND_HEURES_FORMATION_EMPLOYES'], 'Heures'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Heures de formation - agents de maîtrise', ARRAY['IND_HEURES_FORMATION_AGENTS'], 'Heures'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Heures de formation - cadres', ARRAY['IND_HEURES_FORMATION_CADRES'], 'Heures'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Total des heures de formation', ARRAY['IND_TOTAL_HEURES_FORMATION'], 'Heures'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Moyenne des heures de formation', ARRAY['IND_MOYENNE_HEURES_FORMATION'], 'Heures'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Heures de formation - collaborateurs femmes', ARRAY['IND_HEURES_FORMATION_FEMMES'], 'Heures'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Heures de formation - collaborateurs hommes', ARRAY['IND_HEURES_FORMATION_HOMMES'], 'Heures'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Moyenne des heures de formation collaborateurs femmes', ARRAY['IND_MOYENNE_HEURES_FEMMES'], 'Heures'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Moyenne des heures de formation collaborateurs hommes', ARRAY['IND_MOYENNE_HEURES_HOMMES'], 'Heures'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Masse salariale durant la période de reporting', ARRAY['IND_MASSE_SALARIALE_FORMATION'], 'FCFA'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Dépenses de formation', ARRAY['IND_DEPENSES_FORMATION'], 'FCFA'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Part de la masse salariale consacrée à la formation', ARRAY['IND_PART_MASSE_SALARIALE_FORMATION'], '%'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Collaborateurs formés', ARRAY['IND_COLLABORATEURS_FORMES'], 'Nombre'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Collaborateurs femme formées', ARRAY['IND_COLLABORATEURS_FEMMES_FORMEES'], 'Nombre'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Collaborateurs Hommes formés', ARRAY['IND_COLLABORATEURS_HOMMES_FORMES'], 'Nombre'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Pourcentage des collaborateurs formés', ARRAY['IND_POURCENTAGE_COLLABORATEURS_FORMES'], '%'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Collaborateurs ayant fait l''objet d''un examen de leur performance durant l''année', ARRAY['IND_COLLABORATEURS_EXAMEN_PERFORMANCE'], '%'),
('Formation, carrière et éducation', 'ISO 26000', 'Formation, carrière et éducation', 'Part des Collaborateurs ayant fait l''objet d''un examen de leur performance durant l''année', ARRAY['IND_PART_COLLABORATEURS_EXAMEN'], '%')
ON CONFLICT (subsector_name, standard_name, issue_name, criteria_name) DO UPDATE SET indicator_codes = EXCLUDED.indicator_codes;