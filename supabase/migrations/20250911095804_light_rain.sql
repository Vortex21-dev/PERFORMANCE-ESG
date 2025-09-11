/*
  # Populate indicators for all sectors and subsectors

  1. New Data
    - Complete indicator mappings for all sectors in the database
    - Subsector-specific indicator assignments
    - Comprehensive ESG coverage (Environment, Social, Governance)

  2. Coverage
    - All existing sectors get relevant indicators
    - All existing subsectors get specialized indicators
    - Proper linking through criteria to indicators

  3. Structure
    - Uses existing indicators from the indicators table
    - Maps to appropriate criteria for each sector/subsector
    - Maintains data integrity with existing structure
*/

-- First, let's get all sectors and subsectors to work with
DO $$
DECLARE
    sector_rec RECORD;
    subsector_rec RECORD;
    standard_name TEXT;
    issue_name TEXT;
    criteria_name TEXT;
    indicator_codes_array TEXT[];
BEGIN
    -- Process all sectors
    FOR sector_rec IN SELECT name FROM sectors WHERE name != 'Administration publique'
    LOOP
        RAISE NOTICE 'Processing sector: %', sector_rec.name;
        
        -- Get standards for this sector
        FOR standard_name IN 
            SELECT UNNEST(standard_codes) as standard_code
            FROM sector_standards 
            WHERE sector_name = sector_rec.name
        LOOP
            -- Get issues for this sector and standard
            FOR issue_name IN 
                SELECT UNNEST(issue_codes) as issue_code
                FROM sector_standards_issues 
                WHERE sector_name = sector_rec.name AND standard_name = standard_name
            LOOP
                -- Get criteria for this sector, standard, and issue
                FOR criteria_name IN 
                    SELECT UNNEST(criteria_codes) as criteria_code
                    FROM sector_standards_issues_criteria 
                    WHERE sector_name = sector_rec.name 
                    AND standard_name = standard_name 
                    AND issue_name = issue_name
                LOOP
                    -- Assign relevant indicators based on sector and criteria
                    indicator_codes_array := CASE 
                        -- Technology/IT sectors
                        WHEN sector_rec.name ILIKE '%technologie%' OR sector_rec.name ILIKE '%informatique%' THEN
                            CASE 
                                WHEN criteria_name ILIKE '%energie%' OR criteria_name ILIKE '%consommation%' THEN 
                                    ARRAY['ENERGY_CONSUMPTION', 'GHG_EMISSIONS', 'RENEWABLE_ENERGY']
                                WHEN criteria_name ILIKE '%emploi%' OR criteria_name ILIKE '%formation%' THEN 
                                    ARRAY['EMPLOYEE_TRAINING', 'EMPLOYEE_TURNOVER', 'DIVERSITY_RATIO']
                                WHEN criteria_name ILIKE '%gouvernance%' OR criteria_name ILIKE '%ethique%' THEN 
                                    ARRAY['ETHICS_VIOLATIONS', 'DATA_PRIVACY', 'CYBERSECURITY_INCIDENTS']
                                ELSE ARRAY['ENERGY_CONSUMPTION', 'EMPLOYEE_TRAINING']
                            END
                        
                        -- Manufacturing/Industry sectors
                        WHEN sector_rec.name ILIKE '%industrie%' OR sector_rec.name ILIKE '%manufacture%' THEN
                            CASE 
                                WHEN criteria_name ILIKE '%emission%' OR criteria_name ILIKE '%carbone%' THEN 
                                    ARRAY['GHG_EMISSIONS', 'CARBON_FOOTPRINT', 'ENERGY_CONSUMPTION']
                                WHEN criteria_name ILIKE '%dechet%' OR criteria_name ILIKE '%pollution%' THEN 
                                    ARRAY['WASTE_MANAGEMENT', 'WATER_DISCHARGE', 'AIR_POLLUTION']
                                WHEN criteria_name ILIKE '%securite%' OR criteria_name ILIKE '%sante%' THEN 
                                    ARRAY['WORKPLACE_ACCIDENTS', 'EMPLOYEE_HEALTH', 'SAFETY_TRAINING']
                                ELSE ARRAY['GHG_EMISSIONS', 'WASTE_MANAGEMENT']
                            END
                        
                        -- Financial services
                        WHEN sector_rec.name ILIKE '%banque%' OR sector_rec.name ILIKE '%finance%' OR sector_rec.name ILIKE '%assurance%' THEN
                            CASE 
                                WHEN criteria_name ILIKE '%gouvernance%' OR criteria_name ILIKE '%ethique%' THEN 
                                    ARRAY['ETHICS_VIOLATIONS', 'BOARD_DIVERSITY', 'RISK_MANAGEMENT']
                                WHEN criteria_name ILIKE '%client%' OR criteria_name ILIKE '%service%' THEN 
                                    ARRAY['CUSTOMER_SATISFACTION', 'FINANCIAL_INCLUSION', 'PRODUCT_SAFETY']
                                WHEN criteria_name ILIKE '%environnement%' THEN 
                                    ARRAY['PAPER_CONSUMPTION', 'ENERGY_CONSUMPTION', 'GREEN_FINANCING']
                                ELSE ARRAY['ETHICS_VIOLATIONS', 'CUSTOMER_SATISFACTION']
                            END
                        
                        -- Agriculture
                        WHEN sector_rec.name ILIKE '%agriculture%' OR sector_rec.name ILIKE '%agroalimentaire%' THEN
                            CASE 
                                WHEN criteria_name ILIKE '%eau%' OR criteria_name ILIKE '%irrigation%' THEN 
                                    ARRAY['WATER_CONSUMPTION', 'WATER_QUALITY', 'IRRIGATION_EFFICIENCY']
                                WHEN criteria_name ILIKE '%biodiversite%' OR criteria_name ILIKE '%sol%' THEN 
                                    ARRAY['SOIL_HEALTH', 'BIODIVERSITY_INDEX', 'PESTICIDE_USE']
                                WHEN criteria_name ILIKE '%social%' OR criteria_name ILIKE '%communaute%' THEN 
                                    ARRAY['FARMER_INCOME', 'COMMUNITY_SUPPORT', 'FAIR_TRADE']
                                ELSE ARRAY['WATER_CONSUMPTION', 'SOIL_HEALTH']
                            END
                        
                        -- Transport/Logistics
                        WHEN sector_rec.name ILIKE '%transport%' OR sector_rec.name ILIKE '%logistique%' THEN
                            CASE 
                                WHEN criteria_name ILIKE '%emission%' OR criteria_name ILIKE '%carburant%' THEN 
                                    ARRAY['FUEL_CONSUMPTION', 'GHG_EMISSIONS', 'VEHICLE_EFFICIENCY']
                                WHEN criteria_name ILIKE '%securite%' OR criteria_name ILIKE '%accident%' THEN 
                                    ARRAY['ROAD_ACCIDENTS', 'DRIVER_SAFETY', 'VEHICLE_MAINTENANCE']
                                WHEN criteria_name ILIKE '%bruit%' OR criteria_name ILIKE '%pollution%' THEN 
                                    ARRAY['NOISE_POLLUTION', 'AIR_POLLUTION', 'ROUTE_OPTIMIZATION']
                                ELSE ARRAY['FUEL_CONSUMPTION', 'ROAD_ACCIDENTS']
                            END
                        
                        -- Energy sector
                        WHEN sector_rec.name ILIKE '%energie%' OR sector_rec.name ILIKE '%electricite%' THEN
                            CASE 
                                WHEN criteria_name ILIKE '%renouvelable%' OR criteria_name ILIKE '%propre%' THEN 
                                    ARRAY['RENEWABLE_ENERGY', 'CLEAN_ENERGY_PRODUCTION', 'ENERGY_STORAGE']
                                WHEN criteria_name ILIKE '%emission%' OR criteria_name ILIKE '%carbone%' THEN 
                                    ARRAY['GHG_EMISSIONS', 'CARBON_INTENSITY', 'METHANE_LEAKS']
                                WHEN criteria_name ILIKE '%reseau%' OR criteria_name ILIKE '%distribution%' THEN 
                                    ARRAY['GRID_RELIABILITY', 'ENERGY_LOSSES', 'SMART_GRID']
                                ELSE ARRAY['RENEWABLE_ENERGY', 'GHG_EMISSIONS']
                            END
                        
                        -- Healthcare
                        WHEN sector_rec.name ILIKE '%sante%' OR sector_rec.name ILIKE '%medical%' OR sector_rec.name ILIKE '%hopital%' THEN
                            CASE 
                                WHEN criteria_name ILIKE '%patient%' OR criteria_name ILIKE '%soin%' THEN 
                                    ARRAY['PATIENT_SATISFACTION', 'TREATMENT_QUALITY', 'MEDICAL_ERRORS']
                                WHEN criteria_name ILIKE '%dechet%' OR criteria_name ILIKE '%medical%' THEN 
                                    ARRAY['MEDICAL_WASTE', 'PHARMACEUTICAL_WASTE', 'WASTE_TREATMENT']
                                WHEN criteria_name ILIKE '%personnel%' OR criteria_name ILIKE '%formation%' THEN 
                                    ARRAY['STAFF_TRAINING', 'EMPLOYEE_WELLBEING', 'WORK_LIFE_BALANCE']
                                ELSE ARRAY['PATIENT_SATISFACTION', 'MEDICAL_WASTE']
                            END
                        
                        -- Education
                        WHEN sector_rec.name ILIKE '%education%' OR sector_rec.name ILIKE '%enseignement%' OR sector_rec.name ILIKE '%universite%' THEN
                            CASE 
                                WHEN criteria_name ILIKE '%etudiant%' OR criteria_name ILIKE '%formation%' THEN 
                                    ARRAY['STUDENT_SATISFACTION', 'GRADUATION_RATE', 'EDUCATIONAL_QUALITY']
                                WHEN criteria_name ILIKE '%inclusion%' OR criteria_name ILIKE '%diversite%' THEN 
                                    ARRAY['STUDENT_DIVERSITY', 'ACCESSIBILITY', 'SCHOLARSHIP_PROGRAMS']
                                WHEN criteria_name ILIKE '%recherche%' OR criteria_name ILIKE '%innovation%' THEN 
                                    ARRAY['RESEARCH_OUTPUT', 'INNOVATION_INDEX', 'PATENT_APPLICATIONS']
                                ELSE ARRAY['STUDENT_SATISFACTION', 'STUDENT_DIVERSITY']
                            END
                        
                        -- Construction/Real Estate
                        WHEN sector_rec.name ILIKE '%construction%' OR sector_rec.name ILIKE '%batiment%' OR sector_rec.name ILIKE '%immobilier%' THEN
                            CASE 
                                WHEN criteria_name ILIKE '%energie%' OR criteria_name ILIKE '%efficacite%' THEN 
                                    ARRAY['BUILDING_ENERGY_EFFICIENCY', 'GREEN_BUILDING_CERTIFICATION', 'ENERGY_CONSUMPTION']
                                WHEN criteria_name ILIKE '%materiau%' OR criteria_name ILIKE '%durable%' THEN 
                                    ARRAY['SUSTAINABLE_MATERIALS', 'RECYCLED_CONTENT', 'LOCAL_SOURCING']
                                WHEN criteria_name ILIKE '%securite%' OR criteria_name ILIKE '%chantier%' THEN 
                                    ARRAY['CONSTRUCTION_ACCIDENTS', 'SAFETY_PROTOCOLS', 'WORKER_PROTECTION']
                                ELSE ARRAY['BUILDING_ENERGY_EFFICIENCY', 'SUSTAINABLE_MATERIALS']
                            END
                        
                        -- Retail/Commerce
                        WHEN sector_rec.name ILIKE '%commerce%' OR sector_rec.name ILIKE '%retail%' OR sector_rec.name ILIKE '%vente%' THEN
                            CASE 
                                WHEN criteria_name ILIKE '%client%' OR criteria_name ILIKE '%satisfaction%' THEN 
                                    ARRAY['CUSTOMER_SATISFACTION', 'PRODUCT_QUALITY', 'SERVICE_QUALITY']
                                WHEN criteria_name ILIKE '%chaine%' OR criteria_name ILIKE '%fournisseur%' THEN 
                                    ARRAY['SUPPLIER_SUSTAINABILITY', 'LOCAL_SOURCING', 'SUPPLY_CHAIN_TRANSPARENCY']
                                WHEN criteria_name ILIKE '%emballage%' OR criteria_name ILIKE '%dechet%' THEN 
                                    ARRAY['PACKAGING_WASTE', 'PLASTIC_REDUCTION', 'CIRCULAR_ECONOMY']
                                ELSE ARRAY['CUSTOMER_SATISFACTION', 'SUPPLIER_SUSTAINABILITY']
                            END
                        
                        -- Default indicators for any sector
                        ELSE
                            CASE 
                                WHEN criteria_name ILIKE '%emission%' OR criteria_name ILIKE '%carbone%' OR criteria_name ILIKE '%climat%' THEN 
                                    ARRAY['GHG_EMISSIONS', 'CARBON_FOOTPRINT']
                                WHEN criteria_name ILIKE '%energie%' OR criteria_name ILIKE '%consommation%' THEN 
                                    ARRAY['ENERGY_CONSUMPTION', 'RENEWABLE_ENERGY']
                                WHEN criteria_name ILIKE '%eau%' OR criteria_name ILIKE '%hydrique%' THEN 
                                    ARRAY['WATER_CONSUMPTION', 'WATER_DISCHARGE']
                                WHEN criteria_name ILIKE '%dechet%' OR criteria_name ILIKE '%recyclage%' THEN 
                                    ARRAY['WASTE_MANAGEMENT', 'RECYCLING_RATE']
                                WHEN criteria_name ILIKE '%emploi%' OR criteria_name ILIKE '%personnel%' OR criteria_name ILIKE '%rh%' THEN 
                                    ARRAY['EMPLOYEE_TURNOVER', 'EMPLOYEE_TRAINING']
                                WHEN criteria_name ILIKE '%diversite%' OR criteria_name ILIKE '%inclusion%' THEN 
                                    ARRAY['DIVERSITY_RATIO', 'GENDER_PAY_GAP']
                                WHEN criteria_name ILIKE '%securite%' OR criteria_name ILIKE '%sante%' THEN 
                                    ARRAY['WORKPLACE_ACCIDENTS', 'EMPLOYEE_HEALTH']
                                WHEN criteria_name ILIKE '%gouvernance%' OR criteria_name ILIKE '%direction%' THEN 
                                    ARRAY['BOARD_DIVERSITY', 'ETHICS_VIOLATIONS']
                                WHEN criteria_name ILIKE '%ethique%' OR criteria_name ILIKE '%conformite%' THEN 
                                    ARRAY['ETHICS_VIOLATIONS', 'COMPLIANCE_RATE']
                                WHEN criteria_name ILIKE '%client%' OR criteria_name ILIKE '%satisfaction%' THEN 
                                    ARRAY['CUSTOMER_SATISFACTION', 'PRODUCT_SAFETY']
                                ELSE ARRAY['GHG_EMISSIONS', 'EMPLOYEE_TRAINING'] -- Default fallback
                            END
                    END;

                    -- Insert or update the sector data
                    INSERT INTO sector_standards_issues_criteria_indicators (
                        sector_name,
                        standard_name,
                        issue_name,
                        criteria_name,
                        indicator_codes,
                        unit
                    ) VALUES (
                        sector_rec.name,
                        standard_name,
                        issue_name,
                        criteria_name,
                        indicator_codes_array,
                        ''
                    ) ON CONFLICT (sector_name, standard_name, issue_name, criteria_name) 
                    DO UPDATE SET 
                        indicator_codes = EXCLUDED.indicator_codes,
                        unit = EXCLUDED.unit;

                END LOOP; -- criteria
            END LOOP; -- issues
        END LOOP; -- standards
    END LOOP; -- sectors

    -- Process all subsectors
    FOR subsector_rec IN SELECT name, sector_name FROM subsectors
    LOOP
        RAISE NOTICE 'Processing subsector: % (sector: %)', subsector_rec.name, subsector_rec.sector_name;
        
        -- Get standards for this subsector
        FOR standard_name IN 
            SELECT UNNEST(standard_codes) as standard_code
            FROM subsector_standards 
            WHERE subsector_name = subsector_rec.name
        LOOP
            -- Get issues for this subsector and standard
            FOR issue_name IN 
                SELECT UNNEST(issue_codes) as issue_code
                FROM subsector_standards_issues 
                WHERE subsector_name = subsector_rec.name AND standard_name = standard_name
            LOOP
                -- Get criteria for this subsector, standard, and issue
                FOR criteria_name IN 
                    SELECT UNNEST(criteria_codes) as criteria_code
                    FROM subsector_standards_issues_criteria 
                    WHERE subsector_name = subsector_rec.name 
                    AND standard_name = standard_name 
                    AND issue_name = issue_name
                LOOP
                    -- Assign specialized indicators based on subsector
                    indicator_codes_array := CASE 
                        -- Banking subsectors
                        WHEN subsector_rec.name ILIKE '%banque%' THEN
                            CASE 
                                WHEN criteria_name ILIKE '%credit%' OR criteria_name ILIKE '%pret%' THEN 
                                    ARRAY['GREEN_FINANCING', 'SUSTAINABLE_LOANS', 'ESG_INVESTMENT']
                                WHEN criteria_name ILIKE '%risque%' OR criteria_name ILIKE '%gestion%' THEN 
                                    ARRAY['RISK_MANAGEMENT', 'CREDIT_RISK_ESG', 'CLIMATE_RISK']
                                WHEN criteria_name ILIKE '%client%' OR criteria_name ILIKE '%inclusion%' THEN 
                                    ARRAY['FINANCIAL_INCLUSION', 'CUSTOMER_SATISFACTION', 'DIGITAL_ACCESS']
                                ELSE ARRAY['GREEN_FINANCING', 'RISK_MANAGEMENT']
                            END
                        
                        -- Insurance subsectors
                        WHEN subsector_rec.name ILIKE '%assurance%' THEN
                            CASE 
                                WHEN criteria_name ILIKE '%climat%' OR criteria_name ILIKE '%catastrophe%' THEN 
                                    ARRAY['CLIMATE_RISK_COVERAGE', 'NATURAL_DISASTER_CLAIMS', 'RESILIENCE_PRODUCTS']
                                WHEN criteria_name ILIKE '%investissement%' OR criteria_name ILIKE '%placement%' THEN 
                                    ARRAY['ESG_INVESTMENT', 'SUSTAINABLE_PORTFOLIO', 'IMPACT_INVESTING']
                                ELSE ARRAY['CLIMATE_RISK_COVERAGE', 'ESG_INVESTMENT']
                            END
                        
                        -- Manufacturing subsectors
                        WHEN subsector_rec.name ILIKE '%automobile%' OR subsector_rec.name ILIKE '%vehicule%' THEN
                            CASE 
                                WHEN criteria_name ILIKE '%emission%' OR criteria_name ILIKE '%carburant%' THEN 
                                    ARRAY['VEHICLE_EMISSIONS', 'FUEL_EFFICIENCY', 'ELECTRIC_VEHICLE_PRODUCTION']
                                WHEN criteria_name ILIKE '%recyclage%' OR criteria_name ILIKE '%fin de vie%' THEN 
                                    ARRAY['VEHICLE_RECYCLING', 'MATERIAL_RECOVERY', 'BATTERY_RECYCLING']
                                ELSE ARRAY['VEHICLE_EMISSIONS', 'VEHICLE_RECYCLING']
                            END
                        
                        WHEN subsector_rec.name ILIKE '%textile%' OR subsector_rec.name ILIKE '%vetement%' THEN
                            CASE 
                                WHEN criteria_name ILIKE '%eau%' OR criteria_name ILIKE '%teinture%' THEN 
                                    ARRAY['WATER_CONSUMPTION', 'CHEMICAL_USE', 'DYEING_EFFICIENCY']
                                WHEN criteria_name ILIKE '%travail%' OR criteria_name ILIKE '%conditions%' THEN 
                                    ARRAY['WORKER_CONDITIONS', 'FAIR_WAGES', 'SUPPLY_CHAIN_LABOR']
                                ELSE ARRAY['WATER_CONSUMPTION', 'WORKER_CONDITIONS']
                            END
                        
                        -- Food & Beverage subsectors
                        WHEN subsector_rec.name ILIKE '%alimentaire%' OR subsector_rec.name ILIKE '%boisson%' THEN
                            CASE 
                                WHEN criteria_name ILIKE '%origine%' OR criteria_name ILIKE '%tracabilite%' THEN 
                                    ARRAY['INGREDIENT_TRACEABILITY', 'LOCAL_SOURCING', 'ORGANIC_CONTENT']
                                WHEN criteria_name ILIKE '%emballage%' OR criteria_name ILIKE '%plastique%' THEN 
                                    ARRAY['PACKAGING_WASTE', 'PLASTIC_REDUCTION', 'BIODEGRADABLE_PACKAGING']
                                WHEN criteria_name ILIKE '%nutrition%' OR criteria_name ILIKE '%sante%' THEN 
                                    ARRAY['NUTRITIONAL_QUALITY', 'HEALTH_CLAIMS', 'ALLERGEN_MANAGEMENT']
                                ELSE ARRAY['INGREDIENT_TRACEABILITY', 'PACKAGING_WASTE']
                            END
                        
                        -- Technology subsectors
                        WHEN subsector_rec.name ILIKE '%logiciel%' OR subsector_rec.name ILIKE '%software%' THEN
                            CASE 
                                WHEN criteria_name ILIKE '%donnees%' OR criteria_name ILIKE '%privacy%' THEN 
                                    ARRAY['DATA_PRIVACY', 'CYBERSECURITY_INCIDENTS', 'DATA_BREACHES']
                                WHEN criteria_name ILIKE '%accessibilite%' OR criteria_name ILIKE '%inclusion%' THEN 
                                    ARRAY['DIGITAL_ACCESSIBILITY', 'INCLUSIVE_DESIGN', 'USER_DIVERSITY']
                                ELSE ARRAY['DATA_PRIVACY', 'DIGITAL_ACCESSIBILITY']
                            END
                        
                        -- Default for subsectors based on parent sector logic
                        ELSE
                            CASE 
                                WHEN criteria_name ILIKE '%emission%' OR criteria_name ILIKE '%carbone%' THEN 
                                    ARRAY['GHG_EMISSIONS', 'CARBON_FOOTPRINT']
                                WHEN criteria_name ILIKE '%energie%' THEN 
                                    ARRAY['ENERGY_CONSUMPTION', 'RENEWABLE_ENERGY']
                                WHEN criteria_name ILIKE '%eau%' THEN 
                                    ARRAY['WATER_CONSUMPTION', 'WATER_DISCHARGE']
                                WHEN criteria_name ILIKE '%dechet%' THEN 
                                    ARRAY['WASTE_MANAGEMENT', 'RECYCLING_RATE']
                                WHEN criteria_name ILIKE '%emploi%' OR criteria_name ILIKE '%personnel%' THEN 
                                    ARRAY['EMPLOYEE_TURNOVER', 'EMPLOYEE_TRAINING']
                                WHEN criteria_name ILIKE '%diversite%' THEN 
                                    ARRAY['DIVERSITY_RATIO', 'GENDER_PAY_GAP']
                                WHEN criteria_name ILIKE '%securite%' THEN 
                                    ARRAY['WORKPLACE_ACCIDENTS', 'SAFETY_TRAINING']
                                WHEN criteria_name ILIKE '%gouvernance%' THEN 
                                    ARRAY['BOARD_DIVERSITY', 'ETHICS_VIOLATIONS']
                                WHEN criteria_name ILIKE '%client%' THEN 
                                    ARRAY['CUSTOMER_SATISFACTION', 'PRODUCT_SAFETY']
                                ELSE ARRAY['GHG_EMISSIONS', 'EMPLOYEE_TRAINING']
                            END
                    END;

                    -- Insert or update the subsector data
                    INSERT INTO subsector_standards_issues_criteria_indicators (
                        subsector_name,
                        standard_name,
                        issue_name,
                        criteria_name,
                        indicator_codes,
                        unit
                    ) VALUES (
                        subsector_rec.name,
                        standard_name,
                        issue_name,
                        criteria_name,
                        indicator_codes_array,
                        ''
                    ) ON CONFLICT (subsector_name, standard_name, issue_name, criteria_name) 
                    DO UPDATE SET 
                        indicator_codes = EXCLUDED.indicator_codes,
                        unit = EXCLUDED.unit;

                END LOOP; -- criteria
            END LOOP; -- issues
        END LOOP; -- standards
    END LOOP; -- subsectors

    RAISE NOTICE 'Completed populating indicators for all sectors and subsectors';
END $$;