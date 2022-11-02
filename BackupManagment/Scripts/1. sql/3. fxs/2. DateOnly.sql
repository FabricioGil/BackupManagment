USE DbAdmin
GO

/****** Object:  UserDefinedFunction [dbo].[DateOnly]    Script Date: 11/10/2011 15:08:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create  function [Utility].[DateOnly](@DateTime DateTime)
-- Returns @DateTime at midnight; i.e., it removes the time portion of a DateTime value.
returns datetime
as
    begin
    return dateadd(dd,0, datediff(dd,0,@DateTime))
    end


GO