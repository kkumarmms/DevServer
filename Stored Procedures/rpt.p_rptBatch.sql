SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






--exec [p_rptBatch] '20140304'


CREATE PROCEDURE [rpt].[p_rptBatch] 
(@BatchNum varchar(16))
AS
BEGIN
-- =============================================
-- Author:		Andre Barber
-- Create date: '3/24/2014'
-- Description:	Batch Report for Student Loan System
-- TODO -- =============================================

	SET NOCOUNT ON;
	
	begin try	
	
	
			WITH data (UserID,LastName,FirstName,LoanID,LoanItemDescr,PaymentDate,PaymentCode,BatchNo,ItemAmtPaid ) as
				(
				SELECT     act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName, fn.Loans.LoanSeqNum, fn.LoanItems.LoanItemDescr, fn.LoanPayment.PaymentDate, fn.LoanPayment.PaymentCode, fn.LoanPayment.BatchNo , ItemAmtPaid =sum(fn.LoanPaymentApply.AppliedAmt) 
				FROM         act.UserInfo INNER JOIN
                      fn.LoanPaymentApply ON act.UserInfo.UserID = fn.LoanPaymentApply.UserID LEFT OUTER JOIN
                      fn.LoanItems ON fn.LoanPaymentApply.LoanItemID = fn.LoanItems.LoanItemID LEFT OUTER JOIN
                      fn.Loans ON fn.LoanPaymentApply.LoanID = fn.Loans.LoanID LEFT OUTER JOIN
                      fn.LoanPayment ON fn.LoanPaymentApply.LoanPaymentID = fn.LoanPayment.LoanPaymentID
				WHERE     (fn.LoanItems.LoanItemID IN (1,2,3,4,5,7,8,10,12))
				and fn.LoanPayment.BatchNo = @BatchNum
				--TODO and @FromDate<=fn.LoanPayment.PaymentDate and fn.LoanPayment.PaymentDate <= @ToDate
				--Principal Paid = 1,2 Interest Paid = 3,4 Late Charge Paid = 5,7,8,12
				--and act.UserInfo.UserID in(2696)
				GROUP BY act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName, fn.Loans.LoanSeqNum, fn.LoanItems.LoanItemDescr, fn.LoanPayment.PaymentDate, fn.LoanPayment.PaymentCode,fn.LoanPayment.BatchNo
				)
				
			SELECT UserID,'Name' = LastName + ', ' + FirstName, LoanID, PaymentDate, PaymentCode,[Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue],[Late Fee],[Late fee Interest],[Returned Check fee],[Prepaid Penalty],[Principal Balance] ,'Principal Paid'=isnull([Principal Due],0)+isnull([Principal Balance],0) ,'Interest Paid'=isnull([Interest Due],0)+isnull([Interest Overdue],0),'Late Charge Paid'=isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0),'Principal Overdue Paid'=isnull([Principal Overdue],0),'Interest Overdue Paid'=isnull([Interest Overdue],0),'Total Paid'=isnull([Principal Due],0)+isnull([Principal Overdue],0)+isnull([Principal Balance],0)+isnull([Interest Due],0)+isnull([Interest Overdue],0)+isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0),BatchNo   
			FROM data
			PIVOT ( 
			  SUM(ItemAmtPaid) 
			  for LoanItemDescr in ([Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue],[Late Fee],[Late fee Interest],[Returned Check fee],[Prepaid Penalty],[Principal Balance])
			) as T
			WHERE isnull([Principal Due],0) + isnull([Principal Overdue],0) + isnull([Interest Due],0) + isnull([Interest Overdue],0) + isnull([Late Fee],0) + isnull([Late fee Interest],0) + isnull([Returned Check fee],0) + isnull([Prepaid Penalty],0) + isnull([Principal Balance],0) > 0
			ORDER BY Name desc
	 --[Principal Due]
		-- ,[Principal Overdue]
		-- ,[Interest Due]
		-- ,[Interest Overdue]
		-- ,[Late fee]
		-- ,[Late fee Interest]
		-- ,[Returned Check fee]
		-- ,[Prepaid Penalty]
		-- ,[Principal Balance]

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
