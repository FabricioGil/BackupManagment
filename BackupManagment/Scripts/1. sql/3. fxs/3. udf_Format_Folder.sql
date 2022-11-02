
USE DbAdmin
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [Utility].[udf_Format_Folder] 
(
	@Folder AS VARCHAR(260)
)
RETURNS NVARCHAR(260)
AS
BEGIN
	DECLARE @FormatedFolder AS VARCHAR(260)

	IF @Folder IS NULL
		RETURN NULL

	SET @FormatedFolder = RTRIM(LTRIM(@Folder))

	-- Folder must ends with '\'
	IF RIGHT(@FormatedFolder,1) <> N'\'
		SET @FormatedFolder = @FormatedFolder + N'\'

	RETURN @FormatedFolder

END





GO
