SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [app].[p_CreateLoanFromApplication]
	-- Add the parameters for the stored procedure here
	@ApplicationID int
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	create a loan from an application
-- 10/17/2014 sv loan start date is the MMSLoanSignedDate
-- 11/17/2014 msh initial @PrincipalDue and @InterestDue should be 0 until May 1
/* test data

EXEC	[app].[p_CreateLoanFromApplication]
		@ApplicationID = 1

*/
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			declare @loanId int
			declare @userId int
			declare @LoanSeqNum int
			declare @MMSLoanid int
			declare @LoanAmt int
			declare @GradYear int
			declare @PrincipalDue decimal (9,2)
			declare @PrincipalBalance decimal (9,2)
			declare @InterestlDue decimal (9,2)
			declare @InterestBalance decimal (9,2)



			select	@userId =		UserId,
					@LoanAmt =		LoanAmt,
					@MMSLoanid =	MMSLoanid,
					@GradYear =		MDDegreeDate
			from app.Application 
			where ApplicationID=@ApplicationID

		--need to  lock Loans table so we can get correct Max(LoanId). 
			update fn.Loans  set LoanSeqNum = LoanSeqNum 
			where UserID = @userId



			select @LoanSeqNum =	isnull(max(LoanSeqNum),0) 
									from fn.Loans l
									where l.UserID = @userId

			select 
					@PrincipalDue = s.PrincipalAmtDue,
					@InterestlDue = s.InterestAmtDue 
			from [dbo].[LoanPaymentSchedule] s
			where	s.MMSLoanID = @MMSLoanid and
					s.LoanYear = 1

			select 
					@PrincipalBalance = s.PrincipalAmtDue,
					@InterestBalance = s.InterestAmtDue 
			from [dbo].[LoanPaymentSchedule] s
			where	s.MMSLoanID = @MMSLoanid and
					s.LoanYear = 255

			--Begin code
			INSERT      
			INTO    fn.Loans(UserID, 
							ApplicationID, 
							MMSLoanID, 
							LoanAmt,
							ProjectedInterest, 
							LoanApprovedDate, 
							LoanStatus,
							LoanSeqNum, 
							LoanFirstPaymentDate,
							Comments, 
							YearOfLoan,
							PayFlag,
							InsertedBy)
				SELECT     UserID, 
							ApplicationID, 
							MMSLoanID, 
							LoanAmt,
							@InterestBalance,
							MMSLoanSignedDate,	--LoanApprovedDate, 
							310					AS 'LoanStatus', 
							@LoanSeqNum +1		AS 'LoanSeqNum',
							dbo.get_First_PaymentDate() as 'LoanFirstPaymentDate',
							''					AS Comments, 
							0					AS YearOfLoan,
							'A'					AS PayFlag,
							MMSSignature as 'InsertedBy'
				FROM        app.Application
				WHERE       ApplicationID = @ApplicationID
			
			set @loanId = scope_identity()
		
			INSERT      
			INTO      fn.LoanCurrState(UserId, 
										LoanID, 
										LoanItemID, 
										LoanItemAmt, 
										PayFlag)
			select 
					@userId,
					@loanId,
					loanItemID,
					LoanItemAmt=	Case loanItemID
								when 10 then @LoanAmt
								when 1  then 0--@PrincipalDue msh 2014/11/17
								when 3  then 0--@InterestlDue msh
								when 11 then @InterestBalance
								when 16 then 0
								else 0	
							end,
					PayFlag=1

from fn.LoanItems
			----VALUES		(@userId, @loanId, 10, @LoanAmt, 1),
			----			(@userId, @loanId, 1, @PrincipalDue, 1),
			----			(@userId, @loanId, 3, @InterestlDue, 1),
			----			(@userId, @loanId, 11, @InterestBalance, 1),
			----			(@userId, @loanId, 2, 0, 1),
			----			(@userId, @loanId, 4, 0, 1),
			----			(@userId, @loanId, 5, 0, 1),
			----			(@userId, @loanId, 15, 0, 1),
			----			(@userId, @loanId, 18, 0, 1),
			----			(@userId, @loanId, 14, 0, 1)
			--End code

	UPDATE act.UserInfo 
	SET GraduationYear = @GradYear
	where UserID = @userId

		commit tran

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
GRANT EXECUTE ON  [app].[p_CreateLoanFromApplication] TO [ExecSP]
GO
