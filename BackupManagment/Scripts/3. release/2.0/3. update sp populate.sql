USE [DbAdmin]
GO

/****** Object:  StoredProcedure [DBBackup].[usp_Config_Populate]    Script Date: 8/8/2019 12:10:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO









ALTER PROCEDURE [DBBackup].[usp_Config_Populate]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @sqlstatement nvarchar(max) 

       DECLARE @DBSizeOut nvarchar(25)

       DECLARE @ParmDefinition nvarchar(500)

	   DECLARE @DBName AS NVARCHAR(128)
	   
       DECLARE @DBSize decimal(10,2)

	   DECLARE @FilesNumber tinyint

       select  @ParmDefinition = N'@DBSizeOutP nvarchar(25) OUTPUT';

	   DECLARE @ConfigIDTable AS TABLE ( DbName sysname )

	   DECLARE @ErrorCnt AS INT


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
			 set IsActive = 0,ModifiedBy= SYSTEM_USER, Modified=getdate()
			 where DBName not in
			 ( select name from sys.databases where state = 0) 

-- update ag feature on config


  Update DbAdmin.DBBackup.Config
			 set AgEnabled = 1
			 where DBName  in
			 ( select name from sys.databases where replica_id is not null)


-- recaculate number of files by database size

-- Get list of active backup 

		INSERT @ConfigIDTable 
		SELECT Distinct DbName  
		FROM DBBackup.Config
		WHERE IsActive = 1

	   	-- Open cursor on config list.
	    DECLARE ConfigCursor CURSOR FAST_FORWARD FOR
		SELECT DbName FROM @ConfigIDTable
		
	    OPEN ConfigCursor
	    FETCH NEXT FROM ConfigCursor INTO @DbName

			-- for each db in config list.
			SET @ErrorCnt = 0
			WHILE @@FETCH_STATUS = 0
			BEGIN
				BEGIN TRY
				             
                   select @sqlstatement =     N'USE [' + @DBName + ']'+char(13)+N' SELECT @DBSizeOutP = CONVERT(DECIMAL(18,2), SUM(total_pages)*8/1024.0/1024.0) FROM sys.partitions AS p INNER JOIN sys.allocation_units AS a  ON p.[partition_id] = a.container_id'

                   exec sp_executesql @sqlstatement,@ParmDefinition,@DBSizeOutP = @DBSizeOut OUTPUT;

                   select @DBSize = CONVERT(decimal(8,2),@DBSizeOut)


				
              IF @DBSize < 40

                     set @FilesNumber = 1

              ELSE IF @DBSize >= 40 and @DBSize <= 80

                     set @FilesNumber = 4

              ELSE IF @DBSize > 80  and @DBSize <= 125

                    set @FilesNumber = 7

              ELSE IF @DBSize > 125  and @DBSize <= 250
                   set @FilesNumber = 12


        ELSE IF @DBSize >250     

                     set @FilesNumber = 15

 
                   Update DbBackup.Config
				   set FilesNumber = @FilesNumber
				   where DBName = @DBName and type = 'full'

			       select @DBSize

		           select @FilesNumber

				   select @DBName
				         
				END TRY
				BEGIN CATCH
					PRINT ERROR_MESSAGE()
					SET @ErrorCnt = @ErrorCnt + 1
				END CATCH

				FETCH NEXT FROM ConfigCursor INTO @DbName

			END
			CLOSE ConfigCursor
			DEALLOCATE ConfigCursor

            
 
 -- Encryption settings

 update DbBackup.Config
set Encrypt = 1
where Encrypt is null




update DbBackup.Config
set EncAlgorithm = 'AES'
where EncAlgorithm is null

 



END







GO


