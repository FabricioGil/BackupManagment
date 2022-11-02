USE [DbAdmin]
GO

INSERT INTO [dbo].[BkDatabaseVersion]
           ([VersionNumber]
           ,[UpdateDate])
     VALUES
           ('1.5',getdate())
GO


