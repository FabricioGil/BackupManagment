USE [DbAdmin]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




alter Table DBBackup.Config add  AgEnabled bit default 0
go