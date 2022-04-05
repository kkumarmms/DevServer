SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [fn].[p_GetPaymentHistory_Admin] 
	@UserID int
as
/***
	Author: Mike Sherman
	Date:   2014-03-03
	Desc:  Get full payment history for a student. Need to pivot results to present on front end

	2014-05-07 msh added payment toward principal to calculation of PrincipalPaid

	select * from [fn].[LoanPayment] where userid = 2238
	select * from [fn].[LoanPaymentApply] where userid = 2238
	fn.p_GetPaymentHistory_Admin 2238
***/
--declare @UserID int = 2238
set nocount on

begin try

SELECT 
	 isnull(LoanPaymentID,0)		LoanPaymentID,
	 isnull(LoanSeqNum,0)			LoanSeqNum,
	 isnull(PaymentDate,0)			PaymentDate,
	 isnull(TotalPaidAmt,0)			TotalPaidAmt,
	 isnull(TotalLoanPaidAmt,0)		TotalLoanPaidAmt,
	 isnull(PaymentCode,0)			PaymentCode,
	 isnull(BatchNo,0)				BatchNo,
	 isnull([Principal Due],0)	+ 	 isnull([Principal Balance],0)		PrincipalPaid,
	 isnull ([Principal Overdue],0)	Principal_OD_Paid,
	 isnull([Interest Due],0)		InterestPaid,
	 isnull([Interest Overdue],0)	Interest_OD_Paid,
	 isnull([Late fee],0)			LateFeePaid,
	 isnull([Late fee Interest],0)	LateFee_Interest_Paid,
	 isnull([Returned Check fee],0)	ReturnedCheckFeePaid,
	 isnull([Prepaid Penalty],0)	PrepaymentPenaltyPaid,
	 isnull(AdjustmentFlag,0)		AdjustmentFlag,
	 isnull(PaymentType,'')			PaymentType

		 --select*
	--into #Temp--
FROM
	(
	SELECT 

		i.LoanItemDescr,
		p.LoanPaymentID,
		l.LoanSeqNum,
		p.PaymentDate,					-- Deposit date
		p.TotalPaidAmt,					-- Check/Web Payment Amt
		pa.TotalLoanPaidAmt,			-- Amt applied to a loan
		p.PaymentCode,					-- Check# or WebRef#
		p.BatchNo,
		isnull(pa.AppliedAmt,0)				AppliedAmt,
		case PaymentType when 'ADJ' then 1 else 0 end AdjustmentFlag,
		p.PaymentType

	FROM 

					[fn].[LoanPayment] p		
		inner join	[fn].LoanPaymentApply pa	on p.LoanPaymentID = pa.LoanPaymentID 
		inner join	[fn].[Loans] l				on l.LoanID = pa.LoanID
		inner join  [fn].[LoanItems] i			on i.LoanItemID = pa.LoanItemID
	WHERE p.UserID = @UserId 
	--and l.IsDeleted <> 'Y' --msh 2020-10-30

	) as tmp

		PIVOT
	 (
	 Sum (AppliedAmt)
	 FOR LoanItemDescr
	 IN (   

		 [Principal Due]
		 ,[Principal Overdue]
		 ,[Interest Due]
		 ,[Interest Overdue]
		 ,[Late fee]
		 ,[Late fee Interest]
		 ,[Returned Check fee]
		 ,[Prepaid Penalty]
		 ,[Principal Balance]
		 )
	 ) AS pvt
order by PaymentDate desc,  LoanSeqNum

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
	--Return (-1)
end catch

GO
