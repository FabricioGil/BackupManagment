/*   
nov.8.17
Fabricio Gil
consider new db's as removed ones and restoring, put job to update dbs config by invoking populate sp 
*/

USE [DbAdmin]
GO

/****** Object:  StoredProcedure [DBBackup].[usp_Config_Populate]    Script Date: 11/7/2017 4:05:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [DBBackup].[usp_Config_Populate]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @MaxSizeForDailyFull AS INT -- GB
	-- database size bigger than @GBSizeForDailyFull will use differential for daily backup.
	SET @MaxSizeForDailyFull = 25

	--************************************************************
	-- Insert Missing daily database backup configuration
	--************************************************************
	INSERT INTO DBBackup.Config
			   (DBName
			   ,IsActive
			   ,Period
			   ,[Type]
			   ,DestinationPath
			   ,Created
			   ,CreatedBy)
		
		SELECT DISTINCT DB.name AS DBName
				,1 AS IsActive
				,'daily' AS Period
				-- If db size >= 5 then backup type = differential else full
				,CASE WHEN (size * 8/1024/1024) >= @MaxSizeForDailyFull THEN 'diff'
					ELSE 'full'
				 END AS [Type]
				,NULL AS DestinationPath -- Use default path
				,GETDATE() AS Modified
				,SYSTEM_USER AS ModifiedBy
			FROM sys.databases AS DB
				LEFT JOIN sys.master_files AS FL
					ON DB.database_id = FL.database_id and FL.file_id = 1 
				WHERE FL.type = 0
				    AND DB.is_read_only = 0  -- exclude stand by server
					AND DB.state = 0 -- online dbs only
					-- AND not in DBBackup.Config
					AND DB.name NOT IN 
						(SELECT DBName FROM DBBackup.Config WHERE Period = 'daily')
					AND DB.name NOT IN ('tempdb','ReportServerTempDB','model') 
					--and	DB.name not in ( select primary_database from dbo.log_shipping_primary_databases)

	--************************************************************
	-- Insert Missing weekly database backup configuration
	--************************************************************
	INSERT INTO DBBackup.Config
			   (DBName
			   ,IsActive
			   ,Period
			   ,[Type]
			   ,DestinationPath
			   ,Created
			   ,CreatedBy)
		
		SELECT DISTINCT DB.name AS DBName
				,1 AS IsActive
				,'weekly' AS Period
				,'full' AS [Type]
				,NULL AS DestinationPath -- Use default path
				,GETDATE() AS Modified
				,SYSTEM_USER AS ModifiedBy
			FROM sys.databases AS DB
				--  not in DBBackup.Config				
				WHERE DB.name NOT IN 
						(SELECT DBName FROM DBBackup.Config WHERE Period = 'weekly')
						AND DB.name NOT IN ('tempdb','ReportServerTempDB','model')
						--AND DB.name not in ( select primary_database from dbo.log_shipping_primary_databases)
						 AND DB.is_read_only = 0  -- exclude stand by server
						 AND DB.state = 0 -- online dbs only

	--************************************************************
	-- Insert Missing weekly database backup configuration
	--************************************************************
	INSERT INTO DBBackup.Config
			   (DBName
			   ,IsActive
			   ,Period
			   ,[Type]
			   ,DestinationPath
			   ,Created
			   ,CreatedBy)
		
		SELECT DISTINCT DB.name AS DBName
				,1 AS IsActive
				,'monthly' AS Period
				,'full' AS [Type]
				,NULL AS DestinationPath -- Use default path
				,GETDATE() AS Modified
				,SYSTEM_USER AS ModifiedBy
			FROM sys.databases AS DB
				--  not in DBBackup.Config
				WHERE DB.name NOT IN 
						(SELECT DBName FROM DBBackup.Config WHERE Period = 'monthly')
					AND DB.name NOT IN ('tempdb','ReportServerTempDB','model')	
					--AND DB.name not in ( select primary_database from dbo.log_shipping_primary_databases)
					AND DB.is_read_only = 0  -- exclude stand by server
					AND DB.state = 0 -- online dbs only

	--************************************************************
	-- Insert Missing log database backup configuration
	--************************************************************
	INSERT INTO DBBackup.Config
			   (DBName
			   ,IsActive
			   ,Period
			   ,[Type]
			   ,DestinationPath
			   ,Created
			   ,CreatedBy)
		
		SELECT DISTINCT DB.name AS DBName
				,1 AS IsActive
				,'dailylog' AS Period
				,'log' AS [Type]
				,NULL AS DestinationPath -- Use default path
				,GETDATE() AS Modified
				,SYSTEM_USER AS ModifiedBy
			FROM sys.databases AS DB
				--  not in DBBackup.Config
				WHERE DB.name NOT IN 
						(SELECT DBName FROM DBBackup.Config WHERE Period = 'dailylog')
					AND DB.name NOT IN ('tempdb','ReportServerTempDB','model')
					AND DB.is_read_only = 0  -- exclude stand by server
					AND DB.state = 0 -- online dbs only
					AND DB.name not in ( select primary_database from msdb.dbo.log_shipping_primary_databases)
					AND DB.recovery_model_desc = 'FULL'
					

  Update DbAdmin.DBBackup.Config
			 set IsActive = 0
			 where DBName not in
			 ( select name from sys.databases where state = 0) 

END







GO


