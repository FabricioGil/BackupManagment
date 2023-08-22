USE [DbAdmin]
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BkDatabaseVersion]') AND type in (N'U'))
DROP TABLE [dbo].[BkDatabaseVersion]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BkDatabaseVersion](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[VersionNumber] [nchar](10) NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_BKDatabaseVersion] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


