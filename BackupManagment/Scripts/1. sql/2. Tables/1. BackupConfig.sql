USE [DbAdmin]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [DBBackup].[Config](
	[ConfigID] [int] IDENTITY(1,1) NOT NULL,
	[DBName] [nvarchar](128) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Period] [nvarchar](50) NOT NULL,
	[Type] [nvarchar](50) NOT NULL,
	[DestinationPath] [nvarchar](260) NULL,
	[LastBackup] [datetime] NULL,
	[CleanupPeriod] [smallint] NULL,
	[Created] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[Modified] [datetime] NULL,
	[ModifiedBy] [nvarchar](50) NULL,
 CONSTRAINT [PK_Config] PRIMARY KEY CLUSTERED 
(
	[ConfigID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Folder where backup will be store. This field is optional, if = NULL, backup store proc will use the default folder. Must end with “\”.' , @level0type=N'SCHEMA',@level0name=N'DBBackup', @level1type=N'TABLE',@level1name=N'Config', @level2type=N'COLUMN',@level2name=N'DestinationPath'
GO

ALTER TABLE [DBBackup].[Config] ADD  CONSTRAINT [DF_Config_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO

ALTER TABLE [DBBackup].[Config] ADD  CONSTRAINT [DF_DBBackup_Created]  DEFAULT (getdate()) FOR [Created]
GO

ALTER TABLE [DBBackup].[Config] ADD  CONSTRAINT [DF_Config_CreatedBy]  DEFAULT (suser_sname()) FOR [CreatedBy]
GO
