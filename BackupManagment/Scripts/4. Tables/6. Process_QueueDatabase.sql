USE [DbAdmin]
GO



IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Process].[QueueDatabase]') AND type in (N'U'))
DROP TABLE [Process].[QueueDatabase]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Process].[QueueDatabase](
	[QueueID] [int] NOT NULL,
	[DatabaseName] [sysname] NOT NULL,
	[DatabaseOrder] [int] NULL,
	[DatabaseStartTime] [datetime2](7) NULL,
	[DatabaseEndTime] [datetime2](7) NULL,
	[SessionID] [smallint] NULL,
	[RequestID] [int] NULL,
	[RequestStartTime] [datetime] NULL,
 CONSTRAINT [PK_QueueDatabase] PRIMARY KEY CLUSTERED 
(
	[QueueID] ASC,
	[DatabaseName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [Process].[QueueDatabase]  WITH CHECK ADD  CONSTRAINT [FK_QueueDatabase_Queue] FOREIGN KEY([QueueID])
REFERENCES [Process].[Queue] ([QueueID])
GO

ALTER TABLE [Process].[QueueDatabase] CHECK CONSTRAINT [FK_QueueDatabase_Queue]
GO


