USE [DbAdmin]
GO

INSERT INTO [dbo].[BkDatabaseVersion]
           ([VersionNumber]
           ,[UpdateDate])
     VALUES
           ('2.0',getdate())
GO


