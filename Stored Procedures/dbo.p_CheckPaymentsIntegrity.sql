SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[p_CheckPaymentsIntegrity]

as
/***
	Author: msherman
	Date:   5/29/2014
	Desc:  checks that no payments were applied to a wrong user/loan
***/

set nocount on
declare @RetCode int
begin try

		select  distinct userid,loanid 
		from fn.LoanPaymentApply
EXCEPT
		select userid,loanid
		from fn.Loans
		group by userid,loanid
if @@rowcount > 0 
begin
			exec @RetCode= msdb.dbo.sp_send_dbmail 
					 @recipients = 'svatasoiu@mms.org;msherman@mms.org;oteixeira@mms.org'
					--,@profile_name = @profile
				
					,@subject = 'SLAP - Some payments were applied to a wrong Loan'
					,@Query = '		
										select  distinct userid,loanid 
										from SLAP.fn.LoanPaymentApply
									EXCEPT
										select userid,loanid
										from SLAP.fn.Loans
										group by userid,loanid'


end

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
	Return (-1)
end catch
GO
