USE [DbAdmin]
GO

If exists ( select name from sys.schemas
           where name = 'Utility' )
 DROP SCHEMA [Utility]
GO


If exists ( select name from sys.schemas
           where name = 'Process' )
DROP SCHEMA [Process]
GO

If exists ( select name from sys.schemas
           where name = 'DBBackup' )
DROP SCHEMA [DBBackup]
GO

CREATE SCHEMA [DBBackup]
GO


CREATE SCHEMA [Process]
GO

CREATE SCHEMA [Utility]
GO

SELECT 'Schemas completed!'