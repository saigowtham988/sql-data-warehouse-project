/*
-------------------------------------------------------------------------------------
 Script Name     : quality_checks_silver.sql
-------------------------------------------------------------------------------------
 Script Purpose  :
 This script performs data quality checks on the 'silver' layer staging tables to ensure:
 - NULL or duplicate primary keys.
 - unwanted spaces in string fields
 - Data standardization and consistency
 - Logical consistency for date and numeric fields

 Tables validated:
 - silver.crm_cust_info
 - silver.crm_prd_info
 - silver.crm_sales_details
 - silver.erp_cust_az12
 - silver.erp_loc_a101
 - silver.erp_px_cat_g1v2
-------------------------------------------------------------------------------------
*/


--==============================================================================
-- Validation: silver.crm_cust_info
--==============================================================================

-- Check for NULLs or duplicates in primary key
SELECT cst_id, COUNT(*) AS cnt
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for unwanted spaces in string values
SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Check for consistent marital status values
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;


--==============================================================================
-- Validation: silver.crm_prd_info
--==============================================================================

-- Check for NULLs or duplicates in primary key
SELECT prd_id, COUNT(*) AS cnt
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for unwanted spaces in product name
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULL or negative product cost
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0;

-- Check for consistent product line values
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

-- Check for invalid date ranges
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


--==============================================================================
-- Validation: silver.crm_sales_details
--==============================================================================

-- Check for invalid or out-of-range order dates
SELECT sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt IS NULL
  OR TRY_CAST(sls_order_dt AS DATE) IS NULL
  OR sls_order_dt < '1900-01-01'
  OR sls_order_dt > '2050-01-01';

-- Check for logical date order: order date before ship and due date
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;

-- Check data consistency between sales, quantity, and price
SELECT sls_sales, sls_quantity, sls_price
FROM silver.crm_sales_details
WHERE sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
   OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
   OR sls_sales != sls_quantity * sls_price
ORDER BY sls_sales, sls_quantity, sls_price;


--==============================================================================
-- Validation: silver.erp_cust_az12
--==============================================================================

-- Identify out-of-range birthdates
SELECT DISTINCT bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE();

-- Check for consistent gender values
SELECT DISTINCT gen
FROM silver.erp_cust_az12;


--==============================================================================
-- Validation: silver.erp_loc_a101
--==============================================================================

-- Check for consistent country values
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry;


--==============================================================================
-- Validation: silver.erp_px_cat_g1v2
--==============================================================================

-- Check for unwanted spaces in string columns
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance);

-- Check for consistent maintenance categories
SELECT DISTINCT maintenance
FROM silver.erp_px_cat_g1v2;
