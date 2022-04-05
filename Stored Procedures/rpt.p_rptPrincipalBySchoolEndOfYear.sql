SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO












--ALTER SCHEMA rpt TRANSFER dbo.p_rptPrincipalBySchool;





--exec rpt.p_rptPrincipalBySchool


CREATE PROCEDURE [rpt].[p_rptPrincipalBySchoolEndOfYear] 
	@Year int 
AS
BEGIN
-- =============================================
-- Author:		MIKE MHERMAN
-- Create date: '6/1/2017'
-- Description:	Principal Balance by school for active loans Report for Student Loan System FOR ANY YEAR

-- =============================================

	SET NOCOUNT ON;

	
	
	begin try	
	
	--IF @YEAR IS NULL SELECT @YEAR =YEAR(GETDATE())
	
	SELECT [Count of Accounts], [Sum of Principal Balance], School--, DateCreated
	FROM [rpt].[PrincipalBySchool]
	WHERE YEAR([DateCreated]) = @YEAR
			
	

	end try
	begin catch
		--if a transaction was started, rollback
		--if @@trancount > 0
		--begin
		--	rollback tran
		--end
			
		--log error in table
		exec dbo.p_DBA_LogError

		--raise error to front end
		declare @errProc nvarchar(126),
				@errLine int,
				@errMsg  nvarchar(max)
		select  @errProc = error_procedure(),
				@errLine = error_line(),
				@errMsg  = error_message()
		raiserror('Proc: %s - Line: %d - Error: %s', 12 ,1 ,@errProc, @errLine, @errMsg)
		return(-1)
	end catch

END























GO
