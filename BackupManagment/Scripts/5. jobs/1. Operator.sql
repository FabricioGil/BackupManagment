USE [msdb]
GO
if exists ( select name from msdb.dbo.sysoperators)
     EXEC msdb.dbo.sp_delete_operator @name=N'DBA'
GO

EXEC msdb.dbo.sp_add_operator @name=N'DBA', 
		@enabled=1, 
		@pager_days=0
GO
