SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--create logging proc
CREATE PROCEDURE [dbo].[p_DBA_LogError] (
	@query nvarchar(max) = null)
AS

/***
	Author: Joe Alves
	Date:   11/10/2008
	Desc:   proc to log errors
***/

SET NOCOUNT ON

--Log error to error database
INSERT INTO dbo.DBA_ErrorLog (
	ErrNumber,
	ErrSeverity,
	ErrState,
	ErrProc,
	ErrLine,
	ErrMessage,
	QueryString)
SELECT
	ERROR_NUMBER(),
	ERROR_SEVERITY(),
	ERROR_STATE(),
	ERROR_PROCEDURE(),
	ERROR_LINE(),
	ERROR_MESSAGE(),
	@query
	




GO
