SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create PROCEDURE [fn].[p_GetBasePaymentSchedule_WithGap] --@UserId=3263
	@UserId int,
	@CurrDate date = null,
	@PrincipalBalance decimal(9,2) = null,
	@pastDueInterest decimal(9,2) = null,
	@LoanYear int = null,
	@FinCharge decimal(9,2) = null

	as
/***
	Author: Mike Sherman
	Date:  2014-01-17 
	Desc:  Get Payment Schedule for a user. Summary of all his/her loans
[fn].[p_GetBasePaymentSchedule] @UserId=3266  3439
[opr].[p_GetPaymentSchedule] @UserId=3263
select * from dbo.schedule_stage
***/

set nocount on
delete from dbo.schedule_stage
--truncate table dbo.schedule_stage

begin try

	--declare @CurrDate date
	--default to loanApproved date
	select @CurrDate =  
					 (
					 select min(l.LoanApprovedDate) 
					 from fn.Loans l
					 where UserID = @UserId
					 )


;With PaymentSchedule 
	(
	UserId,
	PrincipalBalance,
	PrincipalAmtDue,
	Interest,
	InterestAmtDue,
	InterestAmtDueCalc,
	TotalAmtDue,
	TotalAmtDueCalc,
	LoanYear,
	PaymentDate
	)
	as (
		SELECT 
			max(l.UserId) userId,
			--isnull(convert(varchar(20),sum(s.PrincipalBalance)),'Total') PrincipalBalance,
			sum(s.PrincipalBalance) PrincipalBalance,
			sum(s.PrincipalAmtDue)	PrincipalAmtDue,
			max(s.Interest)			Interest,
			--isnull(convert(varchar(20),sum(s.Interest)),'Total') Interest,
			sum(s.InterestAmtDue)	InterestAmtDue,
			sum(s.PrincipalBalance * s.Interest /100 )	InterestAmtDueCalc,
			sum(s.TotalAmtDue)		TotalAmtDue,
			sum(s.PrincipalAmtDue + s.PrincipalBalance * s.Interest /100)		TotalAmtDueCalc,
			max(s.LoanYear) LoanYear,
			--min(l.LoanFirstPaymentDate) LoanPaymentDate,
			--convert(date,dateadd(yy,max(s.LoanGroupingCode),min(l.LoanFirstPaymentDate))) PaymentDate --changed 3/28/14
			convert(date,dateadd(yy,max(s.LoanYear)-1,min(l.LoanFirstPaymentDate))) PaymentDate

		--select s.*
		FROM		fn.Loans l 
		INNER JOIN dbo.LoanPaymentSchedule s	on l.MMSLoanID = s.MMSLoanID
		WHERE		s.LoanGroupingCode <>255 and UserID =@UserId --and l.YearOfLoan <> 0
		GROUP BY	s.LoanGroupingCode
		)
	insert 	into dbo.schedule_stage
	select 
		UserId,
		PrincipalBalance,
		PrincipalAmtDue,
		Interest,
		InterestAmtDue,
		InterestAmtDueCalc = convert(decimal (9,2),InterestAmtDueCalc),
		TotalAmtDue,
		TotalAmtDueCalc,
		LoanYear ,
		PaymentDate 

	FROM PaymentSchedule
	WHERE PaymentDate > @CurrDate --getdate()
	order by PaymentDate

	--select  * from dbo.schedule_stage

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
