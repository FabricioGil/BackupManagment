USE [DbAdmin]
GO

INSERT INTO [dbo].[BkDatabaseVersion]
           ([VersionNumber]
           ,[UpdateDate])
     VALUES
           ('2.5',getdate())
GO


