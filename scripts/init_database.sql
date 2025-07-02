/*
-------------------------------------------------------------------------------------
 Script Name : initialize_data_warehouse_environment.sql
-------------------------------------------------------------------------------------
 Script Purpose :
 This script creates a new SQL Server database named 'DataWarehouse' and sets up
 three standard schemas: bronze, silver, and gold — typically used for a layered 
 data architecture in ETL/ELT pipelines.

 WARNING:
 If the database 'DataWarehouse' already exists, it will be dropped and recreated.
 All existing data in the 'DataWarehouse' database will be permanently lost.
-------------------------------------------------------------------------------------
*/

-- Switch to the master database to perform database-level operations
USE master;
GO

-- Drop the 'DataWarehouse' database if it already exists
IF DB_ID('DataWarehouse') IS NOT NULL
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END
GO

-- Create a new 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO

-- Switch context to the newly created database
USE DataWarehouse;
GO

-- Create the 'bronze' schema for raw ingested data
CREATE SCHEMA bronze;
GO

-- Create the 'silver' schema for cleansed and transformed data
CREATE SCHEMA silver;
GO

-- Create the 'gold' schema for aggregated and analytical data
CREATE SCHEMA gold;
GO
