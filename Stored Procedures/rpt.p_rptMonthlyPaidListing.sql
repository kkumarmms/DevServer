SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO











--exec [p_rptMonthlyPaidListing] '2/1/2014','2/28/2014'
--check 002696 Baumer, Fionna

CREATE PROCEDURE [rpt].[p_rptMonthlyPaidListing] 
(@FromDate date
,@ToDate date)
AS
BEGIN
-- =============================================
-- Author:		Andre Barber
-- Create date: '3/24/2014'
-- Description:	Monthly Paid Listing Report for Student Loan System
-- TODO StartDate to EndDate criteria for month of fn.[LoanPayment] table current snapshot for SLAP_Source was for March TODO and @FromDate @ToDate
-- verified act.UserInfo.UserID in(2696) 
-- MSherman 3/24 for a payment applied use LoanPaymentApply Principal Paid is LoanItemID 1&2,Interest Paid is LoanItemID 3&4,Late Charge Paid is LoanItemID 5,7,8,12
-- BWheeler 4/8/2014 combine Pricipal overdue with principal and Interest overdue with Interest
-- ASB 5/12/2014 date inclusive changes and include 10 & 11 principle and interest balance
-- ASB 12/4/2014 filter PaymentType<>'ADJHID'
-- =============================================

	SET NOCOUNT ON;

	if ((ISNULL(@FromDate,'')='') or (ISNULL(@ToDate,'')=''))
		BEGIN
			SET @FromDate = DATEADD(d,-1,GetDate())	
			SET @ToDate = DATEADD(d,1,GetDate())	
		END
	else
		BEGIN			
			SET @ToDate = DATEADD(d,1,@ToDate)	
		END
	
	begin try	
	
	
			WITH data (UserID,LastName,FirstName,LoanItemDescr,PaymentDate,PaymentCode,BatchNo,ItemAmtPaid ) as
				(
				SELECT     act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName, fn.LoanItems.LoanItemDescr, fn.LoanPayment.PaymentDate, fn.LoanPayment.PaymentCode, fn.LoanPayment.BatchNo , ItemAmtPaid =sum(fn.LoanPaymentApply.AppliedAmt) 
				FROM         act.UserInfo INNER JOIN
                      fn.LoanPaymentApply ON act.UserInfo.UserID = fn.LoanPaymentApply.UserID LEFT OUTER JOIN
                      fn.LoanItems ON fn.LoanPaymentApply.LoanItemID = fn.LoanItems.LoanItemID LEFT OUTER JOIN
                      fn.Loans ON fn.LoanPaymentApply.LoanID = fn.Loans.LoanID LEFT OUTER JOIN
                      fn.LoanPayment ON fn.LoanPaymentApply.LoanPaymentID = fn.LoanPayment.LoanPaymentID
				WHERE     (fn.LoanItems.LoanItemID IN (1,2,3,4,5,7,8,12,10,11))
				 and fn.LoanPayment.PaymentType<>'ADJHID'
				--and [fn].[LoanPayment].PaymentDate between @FromDate and @ToDate
				 and (@FromDate<=fn.LoanPayment.PaymentDate and fn.LoanPayment.PaymentDate <= @ToDate)				
				--Principal Paid = 1,2 Interest Paid = 3,4 Late Charge Paid = 5,7,8,12
				--and act.UserInfo.UserID in(2696)
				GROUP BY act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName,  fn.LoanItems.LoanItemDescr, fn.LoanPayment.PaymentDate, fn.LoanPayment.PaymentCode,fn.LoanPayment.BatchNo
				)
				
			SELECT UserID,'Name' = LastName + ', ' + FirstName,PaymentDate, PaymentCode,[Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue],[Late Fee],[Late fee Interest],[Returned Check fee],[Prepaid Penalty] ,'Principal Paid'=isnull([Principal Due],0)+isnull([Principal Overdue],0) + ISNULL([Principal Balance],0) ,'Interest Paid'=isnull([Interest Due],0)+isnull([Interest Overdue],0),'Late Charge Paid'=isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0),'Total Paid'=isnull([Principal Due],0)+isnull([Principal Overdue],0)+isnull([Interest Due],0)+isnull([Interest Overdue],0)+isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0) + ISNULL([Principal Balance],0) + isnull([Interest Balance],0),BatchNo   
			FROM data
			PIVOT ( 
			  SUM(ItemAmtPaid) 
			  for LoanItemDescr in ([Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue],[Late Fee],[Late fee Interest],[Returned Check fee],[Prepaid Penalty],[Principal Balance],[Interest Balance])
			) as T
			--WHERE isnull([Principal Due],0) + isnull([Principal Overdue],0) + isnull([Interest Due],0) + isnull([Interest Overdue],0) + isnull([Late Fee],0) + isnull([Late fee Interest],0) + isnull([Returned Check fee],0) + isnull([Prepaid Penalty],0) > 0
			ORDER BY Name
	

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
