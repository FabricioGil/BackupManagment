USE [DbAdmin]
GO



/****** Object:  Table [DBBackup].[ExecutionLog]    Script Date: 2023-07-05 11:12:42 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DBBackup].[ExecutionLog]') AND type in (N'U'))
DROP TABLE [DBBackup].[ExecutionLog]
GO

/****** Object:  Table [DBBackup].[ExecutionLog]    Script Date: 2023-07-05 11:12:42 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [DBBackup].[ExecutionLog](
	[ExecutionLogID] [int] IDENTITY(1,1) NOT NULL,
	[ConfigID] [int] NOT NULL,
	[Status] [nvarchar](32) NOT NULL,
	[BackupFile] [nvarchar](260) NULL,
	[Message] [nvarchar](2000) NULL,
	[TimeStart] [datetime] NOT NULL,
	[TimeEnd] [datetime] NOT NULL,
	[TimeExecution]  AS (datediff(second,[TimeStart],[TimeEnd])) PERSISTED,
 CONSTRAINT [PK_ExecutionLog] PRIMARY KEY CLUSTERED 
(
	[ExecutionLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [DBBackup].[ExecutionLog]  WITH CHECK ADD  CONSTRAINT [FK_ExecutionLog_Config] FOREIGN KEY([ConfigID])
REFERENCES [DBBackup].[Config] ([ConfigID])
GO

ALTER TABLE [DBBackup].[ExecutionLog] CHECK CONSTRAINT [FK_ExecutionLog_Config]
GO


