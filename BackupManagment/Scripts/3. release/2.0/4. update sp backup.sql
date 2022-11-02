USE [DbAdmin]
GO

/****** Object:  StoredProcedure [DBBackup].[usp_ExecuteBackup]    Script Date: 8/8/2019 12:41:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




 
ALTER proc [DBBackup].[usp_ExecuteBackup]

       @ConfigID AS INT

       ,@DefaultDestinationFolder AS NVARCHAR(260)

AS

BEGIN

 

       SET NOCOUNT ON;

 

       DECLARE @DBName AS NVARCHAR(128)

       DECLARE @Period AS NVARCHAR(50)

       DECLARE @Type AS NVARCHAR(50)

       DECLARE @DBDestinationPath AS NVARCHAR(260)

 

       DECLARE @BackupFolder AS NVARCHAR(260)

       DECLARE @BackupFileName AS NVARCHAR(260)

       DECLARE @CmdRenameBak AS NVARCHAR(4000)

       DECLARE @CmdDeleteOld AS NVARCHAR(4000)

       DECLARE @SQLBackup AS NVARCHAR(400)

       DECLARE @TimeStart AS DATETIME

       DECLARE @TimeEnd AS DATETIME

       DECLARE @SqlChgDb AS NVARCHAR(100)

      

       DECLARE @DBSize decimal(10,2)

       DECLARE @FilesNumber tinyint

       DECLARE @CleanUpTime smallint

	   DECLARE @AgEnable bit

	   DEClARE @Encrypt char(1)

	   DECLARE @EncAlgorithm char(7)

	   DECLARE @ServerCertificate char(50)


 

    DECLARE @sqlstatement nvarchar(max) 

       DECLARE @DBSizeOut nvarchar(25)

       DECLARE @ParmDefinition nvarchar(500)

 

       -- Get backup configuration

       SELECT @DBName = DBName

                     ,@Period = Period

                     ,@Type = [Type]

                     ,@DBDestinationPath = DestinationPath

                     ,@CleanUpTime = CleanupPeriod

					 ,@AgEnable = AgEnabled

					 ,@FilesNumber = FilesNumber

					 ,@Encrypt = Encrypt

					 ,@EncAlgorithm = EncAlgorithm

					 ,@ServerCertificate = ServerCertificate

              FROM [DBBackup].Config

              WHERE ConfigID = @ConfigID

 
 

 

       -- If backup config not found

       IF @@ROWCOUNT = 0

       BEGIN

              RAISERROR (N'Backup config not found, ConfigID=%d'

                                     ,16 --Severity,

                                     ,1 --State

                                     ,@ConfigID --First argument

                                  );           

              RETURN

       END

       --EX: msdn_WEEKLY_FULL

       SET @BackupFileName = @DBName + '_' + UPPER(@Period) + '_' + UPPER(@Type)

 

       -- IF no backup folder destination is set for this database, use default backup folder destination.

       IF @DBDestinationPath IS NULL OR RTRIM(@DBDestinationPath) = ''

              SET @BackupFolder = Utility.udf_Format_Folder(@DefaultDestinationFolder)--+@Period)

       ELSE

              SET @BackupFolder = Utility.udf_Format_Folder(@DBDestinationPath)--+@Period)

             

              print @BackupFolder

 

       BEGIN TRY

 

              SET @TimeStart = GETDATE()

 

              -- Rename previous database backup file to .old.

              SET @CmdRenameBak ='REN "' + @BackupFolder + @BackupFileName + '.BAK" "' + @BackupFileName +'.OLD"'

              EXEC master.dbo.xp_cmdshell @CmdRenameBak, no_output

 

              -- Build Backup sql statement.

              IF UPPER(@Type) = 'DIFF'

                               EXECUTE DBBackup.DatabaseBackup

                                  @Databases = @DBName,

                                  @Directory = @BackupFolder,

                                  @BackupType = 'DIFF',

                                  @Compress = 'Y',

                                  @CheckSum = 'Y',

                                  @Verify = 'N',

                                 -- @BufferCount = 250,

                                  --@MaxTransferSize = 4194304,

                                  @NumberOfFiles = @FilesNumber,

                                  @CleanupTime =@CleanUpTime,

                                  @Period = @Period,

								  @Description = @Period,

								  @Encrypt = @Encrypt,

								  @EncryptionAlgorithm =  @EncAlgorithm,

								  @ServerCertificate = @ServerCertificate,

								   @DirectoryStructure = '{ServerName}${InstanceName}{DirectorySeparator}{DatabaseName}{DirectorySeparator}{BackupType}_{Description}'

 

              -- full copy

              -- ADDED: 2011/10/04

              ELSE IF UPPER(@Type) = 'FULLCOPY'

                     SET @SQLBackup = 'BACKUP DATABASE ' + @DBName

                                         + ' TO  DISK = N''' + @BackupFolder + @BackupFileName + '.BAK'' '

                                         + ' WITH NOFORMAT, INIT, SKIP, COMPRESSION, COPY_ONLY'

                                         + '    ,NAME = N''' + @BackupFileName + ''' '

                                        

              ELSE IF UPPER(@Type) = 'LOG'

              BEGIN

                     SET @SQLBackup = 'BACKUP LOG ' + @DBName

                                         + ' TO  DISK = N''' + @BackupFolder + @BackupFileName + '.TRN'' '

                                         + ' WITH NOFORMAT, INIT, SKIP, COMPRESSION'

                                         + '    ,NAME = N''' + @BackupFileName + ''' '

             

               EXECUTE DBBackup.DatabaseBackup

                                  @Databases = @DBName,

                                  @Directory = @BackupFolder,

                                  @BackupType = 'LOG',

                                  @Compress = 'Y',

                                  @CheckSum = 'Y',

                                  @Verify = 'N',

                                  
                                  @NumberOfFiles = @FilesNumber,

                                  @CleanupTime = @CleanUpTime,

                                  @Description = @Period,

								  @Period = @Period,

								  @Encrypt = @Encrypt,

								  @EncryptionAlgorithm =  @EncAlgorithm,

								  @ServerCertificate = @ServerCertificate,


								  @DirectoryStructure = '{ServerName}${InstanceName}{DirectorySeparator}{DatabaseName}{DirectorySeparator}{BackupType}_{Description}'

                    

                     --PRINT @SQLBackup                                    

              END

              -- Default is full backup

              ELSE

                   IF @AgEnable = 1
				   
				   Begin 

						  EXECUTE DBBackup.DatabaseBackup

										  @Databases = @DBName,

										  @Directory = @BackupFolder,

										  @BackupType = 'FULL',

										  @Compress = 'Y',

										  @CheckSum = 'Y',

										  @Verify = 'N',

										  @NumberOfFiles = @FilesNumber,

										  @CopyOnly = 'Y',

										  --@NumberOfFiles = 3,

										  @CleanupTime = @CleanUpTime,

										  @Description = @Period,

										  @LogToTable ='Y',

											@DirectoryStructure = '{ServerName}${InstanceName}{DirectorySeparator}{DatabaseName}{DirectorySeparator}{BackupType}_{Description}_{CopyOnly}',

										  @Period = @Period,

										  @Encrypt = @Encrypt,

								          @EncryptionAlgorithm =  @EncAlgorithm,

								          @ServerCertificate = @ServerCertificate


										  --@Execute = 'N'
								END
                 
				          Else
						        Begin

											EXECUTE DBBackup.DatabaseBackup

										  @Databases = @DBName,

										  @Directory = @BackupFolder,

										  @BackupType = 'FULL',

										  @Compress = 'Y',

										  @CheckSum = 'Y',

										  @Verify = 'N',

										  @NumberOfFiles = @FilesNumber,

										  --@CopyOnly = 'Y',

										  --@NumberOfFiles = 3,

										  @CleanupTime = @CleanUpTime,

										  @Description = @Period,

										  @LogToTable ='Y',

										  @Encrypt = @Encrypt,

								          @EncryptionAlgorithm =  @EncAlgorithm,

								          @ServerCertificate = @ServerCertificate,


										  @DirectoryStructure = '{ServerName}${InstanceName}{DirectorySeparator}{DatabaseName}{DirectorySeparator}{BackupType}_{Description}',

										  @Period = @Period

							     End
 

              -- Delete previous database backup file.

              SET @CmdDeleteOld ='DEL "'+ @BackupFolder + @BackupFileName +'.OLD"'

              EXEC master.dbo.xp_cmdshell @CmdDeleteOld, no_output

 

              SET @TimeEnd = GETDATE()

 

              -- Update LastBackup datetime.

              UPDATE [DBBackup].Config

                     SET LastBackup = @TimeEnd

                     WHERE ConfigID = @ConfigID

 

              -- Inser execution log.

              INSERT INTO DBBackup.ExecutionLog

                              (ConfigID

                              ,Status

                              ,BackupFile

                              ,TimeStart

                              ,TimeEnd)

                     VALUES

                              (@ConfigID

                              ,'Success'

                              ,@BackupFolder + @BackupFileName + '.BAK'

                              ,@TimeStart

                              ,@TimeEnd)

       END TRY

       BEGIN CATCH

 

              DECLARE @ErrorMessage NVARCHAR(4000)

              DECLARE @ErrorSeverity INT

              DECLARE @ErrorState INT

 

              SELECT

                     @ErrorMessage = ERROR_MESSAGE(),

                     @ErrorSeverity = ERROR_SEVERITY(),

                     @ErrorState = ERROR_STATE()

 

              -- Rename back previous database backup file to .bak.

              SET @CmdRenameBak ='REN "' + @BackupFolder + @BackupFileName + '.OLD" "' + @BackupFileName +'.BAK"'

              EXEC master.dbo.xp_cmdshell @CmdRenameBak, no_output

 

              -- Insert execution log with failure.

              SET @TimeEnd = GETDATE()

              INSERT INTO DBBackup.ExecutionLog

                              (ConfigID

                              ,[Status]

                              ,BackupFile

                              ,[Message]

                              ,TimeStart

                              ,TimeEnd)

                     VALUES

                              (@ConfigID

                              ,'Failure'

                              ,@BackupFolder + @BackupFileName + '.BAK'

                              ,@ErrorMessage

                              ,@TimeStart

                              ,@TimeEnd)

 

 

              -- Transfer error to store procedure caller.          

              RAISERROR (@ErrorMessage,

                              @ErrorSeverity,

                              @ErrorState

                              )

       END CATCH

 

END

 

 

 

 

 

 

 

 

 

 

 

 

 

GO


