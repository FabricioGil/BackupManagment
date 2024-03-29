USE [DbAdmin]
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Process].[Queue]') AND type in (N'U'))
DROP TABLE [Process].[Queue]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Process].[Queue](
	[QueueID] [int] IDENTITY(1,1) NOT NULL,
	[SchemaName] [sysname] NOT NULL,
	[ObjectName] [sysname] NOT NULL,
	[Parameters] [nvarchar](max) NOT NULL,
	[QueueStartTime] [datetime2](7) NULL,
	[SessionID] [smallint] NULL,
	[RequestID] [int] NULL,
	[RequestStartTime] [datetime] NULL,
 CONSTRAINT [PK_Queue] PRIMARY KEY CLUSTERED 
(
	[QueueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


