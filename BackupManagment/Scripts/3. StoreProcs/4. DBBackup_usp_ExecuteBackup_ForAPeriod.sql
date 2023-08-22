USE [DbAdmin]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






-- =============================================

-- Create date: 2010/11/25
-- Description:	BAckup all the database for
--				the specified @period
--
-- Modification:
--

-- =============================================
CREATE  PROCEDURE [DBBackup].[usp_ExecuteBackup_ForAPeriod]
	@Period AS nvarchar(50)
	,@BackupPath AS NVARCHAR(260)
AS
BEGIN
	SET NOCOUNT ON;

	-- Validate parameter.
	/* Removed: 2011/10/04
	IF @Period NOT IN ('daily', 'weekly', 'monthly')
	BEGIN
		RAISERROR('ERROR: Invalid @Period parameter!!',11,0)
		RETURN
	END
	*/
	
	IF LTRIM(@BackupPath) = ''
	BEGIN
		RAISERROR('ERROR: Invalid @@BackupPath parameter!!',11,0)
		RETURN
	END


	DECLARE @ConfigID AS INT
	DECLARE @ErrorCnt AS INT

	-- Get list of active backup config for the specified period
	DECLARE @ConfigIDTable AS TABLE ( ConfigID INT )
	INSERT @ConfigIDTable 
		SELECT ConfigID 
		FROM DBBackup.Config
		WHERE Period = @Period 
			AND IsActive = 1

	-- Open cursor on config list.
	DECLARE ConfigCursor CURSOR FAST_FORWARD FOR
		SELECT ConfigID FROM @ConfigIDTable
		
	OPEN ConfigCursor
	FETCH NEXT FROM ConfigCursor INTO @ConfigID

	-- for each db in config list.
	SET @ErrorCnt = 0
	WHILE @@FETCH_STATUS = 0
	BEGIN
		BEGIN TRY
				EXEC [DBBackup].[usp_ExecuteBackup] 
						@ConfigID = @ConfigID		
						,@DefaultDestinationFolder = @BackupPath
		END TRY
		BEGIN CATCH
			PRINT ERROR_MESSAGE()
			SET @ErrorCnt = @ErrorCnt + 1
		END CATCH

		FETCH NEXT FROM ConfigCursor INTO @ConfigID


	END
	CLOSE ConfigCursor
	DEALLOCATE ConfigCursor
	
	IF @ErrorCnt > 0 
	BEGIN
		RAISERROR('ERROR: At least on error was raised during backup execution!',11,0)
	END

END

GO


