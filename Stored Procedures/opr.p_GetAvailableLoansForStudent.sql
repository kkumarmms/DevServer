SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [opr].[p_GetAvailableLoansForStudent]
	-- Add the parameters for the stored procedure here
	@IncludeDeleted varchar(1) = 'N',
	@UserID int
AS
BEGIN
/* =============================================
-- Author:		Sorin Vatasoiu
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- 2015-12-01 msh/sorin changed to use function


select l.LoanAmt,* from act.UserInfo u inner join fn.Loans l on l.userid = u.Userid
inner join [app].[Application] a on a userid
where u.GraduationYear = 2016 
order by l.userid
=============================================*/
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try


	 select 
		l.MMSLoanID, 
		Code, 
		LoanAmount, 
		Description, 
		LoanTerm, 
		LegacySchedCode, 
		DateInserted, 
		DateUpdated, 
		IsDeleted, 
		InsertedBy, 
		UpdatedBy
	 from dbo.split((select * from fn.f_GetAvailLoans (@UserID)),',') s
	 inner join [opr].[MMSLoans] l on s.Items = l.[MMSLoanID]

	end try
	begin catch
		--if a transaction was started, rollback
		if @@trancount > 0
		begin
			rollback tran
		end
			
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
GRANT EXECUTE ON  [opr].[p_GetAvailableLoansForStudent] TO [ExecSP]
GO
