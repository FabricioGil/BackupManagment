USE [DbAdmin]
GO


EXECUTE  [DBBackup].[usp_Config_Populate] 
GO


Update DbAdmin.DBBackup.Config
set IsActive = 0
go


update  DbAdmin.DBBackup.Config
set DestinationPath = 'D:\'
go