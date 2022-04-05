SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




--select * from rpt.TenYearForecast  where CurrentFlag = 0


--exec rpt.p_rpt10YearForecast 


CREATE PROCEDURE [rpt].[p_rpt10YearForecast] 

AS
BEGIN
-- =============================================
-- Author:		Andre Barber
-- Create date: '3/24/2014'
-- Description:	10 Year Forecast run annually report for Student Loan System
--
-- TODO -- Mike to create forecast table and populate, proc will simply select to display

	SET NOCOUNT ON;
	
--	begin try	

select  
              year(Paymentdate) as LoanYear,
              COUNT(distinct id) LoansOutstanding,
              sum(f.PrincipalAmtDue) Principal, 
              sum (f.interestDue) Interest,
             -- Sum (f.TotalDue) Total
				Total=sum(f.PrincipalAmtDue) + sum (f.interestDue) --msh 2014-04-27 fees should not not include  in report
from rpt.TenYearForecast f
where CurrentFlag = 0
group by Paymentdate
order by Paymentdate
 

	
	
			--WITH data (UserID,LastName,FirstName,LoanID,LoanItemDescr,PaymentDate,PaymentCode,BatchNo,ItemAmtPaid ) as
			--	(
			--	SELECT     act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName, fn.Loans.MMSLoanID, fn.LoanItems.LoanItemDescr, fn.LoanPayment.PaymentDate, fn.LoanPayment.PaymentCode, fn.LoanPayment.BatchNo , ItemAmtPaid =sum(fn.LoanPaymentApply.AppliedAmt) 
			--	FROM         act.UserInfo INNER JOIN
   --                   fn.LoanPaymentApply ON act.UserInfo.UserID = fn.LoanPaymentApply.UserID LEFT OUTER JOIN
   --                   fn.LoanItems ON fn.LoanPaymentApply.LoanItemID = fn.LoanItems.LoanItemID LEFT OUTER JOIN
   --                   fn.Loans ON fn.LoanPaymentApply.LoanID = fn.Loans.LoanID LEFT OUTER JOIN
   --                   fn.LoanPayment ON fn.LoanPaymentApply.LoanPaymentID = fn.LoanPayment.LoanPaymentID
			--	WHERE     (fn.LoanItems.LoanItemID IN (1,2,3,4,5,7,8,12))
			--	and fn.LoanPayment.BatchNo = @BatchNum
			--	--TODO and @FromDate<=fn.LoanPayment.PaymentDate and fn.LoanPayment.PaymentDate <= @ToDate
			--	--Principal Paid = 1,2 Interest Paid = 3,4 Late Charge Paid = 5,7,8,12
			--	--and act.UserInfo.UserID in(2696)
			--	GROUP BY act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName, fn.Loans.MMSLoanID, fn.LoanItems.LoanItemDescr, fn.LoanPayment.PaymentDate, fn.LoanPayment.PaymentCode,fn.LoanPayment.BatchNo
			--	)
				
			--SELECT UserID,'Name' = LastName + ', ' + FirstName, LoanID, PaymentDate, PaymentCode,[Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue],[Late Fee],[Late fee Interest],[Returned Check fee],[Prepaid Penalty] ,'Principal Paid'=isnull([Principal Due],0)+isnull([Principal Overdue],0) ,'Interest Paid'=isnull([Interest Due],0)+isnull([Interest Overdue],0),'Late Charge Paid'=isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0),'Principal Overdue Paid'=isnull([Principal Overdue],0),'Interest Overdue Paid'=isnull([Interest Overdue],0),'Total Paid'=isnull([Principal Due],0)+isnull([Principal Overdue],0)+isnull([Interest Due],0)+isnull([Interest Overdue],0)+isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0),BatchNo   
			--FROM data
			--PIVOT ( 
			--  SUM(ItemAmtPaid) 
			--  for LoanItemDescr in ([Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue],[Late Fee],[Late fee Interest],[Returned Check fee],[Prepaid Penalty])
			--) as T
			--WHERE isnull([Principal Due],0) + isnull([Principal Overdue],0) + isnull([Interest Due],0) + isnull([Interest Overdue],0) + isnull([Late Fee],0) + isnull([Late fee Interest],0) + isnull([Returned Check fee],0) + isnull([Prepaid Penalty],0) > 0
			--ORDER BY Name
	

	--end try
	--begin catch
	--	--if a transaction was started, rollback
	--	--if @@trancount > 0
	--	--begin
	--	--	rollback tran
	--	--end
			
	--	--log error in table
	--	exec dbo.p_DBA_LogError

	--	--raise error to front end
	--	declare @errProc nvarchar(126),
	--			@errLine int,
	--			@errMsg  nvarchar(max)
	--	select  @errProc = error_procedure(),
	--			@errLine = error_line(),
	--			@errMsg  = error_message()
	--	raiserror('Proc: %s - Line: %d - Error: %s', 12 ,1 ,@errProc, @errLine, @errMsg)
	--	return(-1)
	--end catch

END











GO
