SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









--exec [p_rptPaidLoans] '2/1/2014','2/28/2014'


CREATE PROCEDURE [rpt].[p_rptPaidLoans] 
(@FromDate date
,@ToDate date)
AS
BEGIN
-- =============================================
-- Author:		Andre Barber
-- Create date: '3/24/2014'
-- Description:	Paid Loans Report for Student Loan System
-- TODO StartDate to EndDate criteria for fn.LoanPaymentApply.PaymentDate table current snapshot for SLAP has missing data for @FromDate @ToDate
-- MSherman 3/25 for a paid off off loan use LoanCurrState Principal Due is LoanItemID 1 and amount has $0
-- =============================================

	SET NOCOUNT ON;

	if ((ISNULL(@FromDate,'')='') or (ISNULL(@ToDate,'')=''))
		BEGIN
			SET @FromDate = DATEADD(m,-1,GetDate())	
			SET @ToDate = GetDate()
		END
	
	begin try	
	
	
			--SELECT      
			--	'Account Number' = act.UserInfo.UserID
			--	,'Name' = rtrim(act.UserInfo.LastName) + ', ' + rtrim(act.UserInfo.FirstName)
			--	,'Date Paid' = fn.LoanPaymentApply.PaymentDate
			--	,'Loan Number'=fn.Loans.MMSLoanID
			--FROM         fn.LoanCurrState INNER JOIN
			--					  fn.LoanPaymentApply ON fn.LoanCurrState.LoanID = fn.LoanPaymentApply.LoanID INNER JOIN
			--					  fn.Loans ON fn.LoanPaymentApply.LoanID = fn.Loans.LoanID LEFT OUTER JOIN
			--					  act.UserInfo ON fn.LoanPaymentApply.UserID = act.UserInfo.UserID
			--WHERE     (fn.LoanCurrState.LoanItemID = 1) AND (fn.LoanCurrState.LoanItemAmt = 0)
			----TODO and @FromDate<=fn.LoanPaymentApply.PaymentDate and fn.LoanPaymentApply.PaymentDate <= @ToDate
			--ORDER BY 'Name' --rtrim(act.UserInfo.LastName), rtrim(act.UserInfo.FirstName)
	

				SELECT Distinct
		    		'Account Number' = act.UserInfo.UserID
					,rtrim(act.UserInfo.LastName) + ', ' + rtrim(act.UserInfo.FirstName) as 'Name'					
					,'Loan Number'=fn.Loans.LoanSeqNum
					,'Date Paid' = max(fn.LoanPaymentApply.PaymentDate)
							 --fn.LoanItems.LoanItemID, fn.LoanItems.LoanItemDescr, fn.LoanCurrState.LoanItemAmt, fn.LoanCurrState.LoanItemID AS Expr1, act.UserInfo.UserID, 
					--                  act.UserInfo.FirstName, act.UserInfo.LastName, fn.Loans.MMSLoanID, fn.LoanCurrState.DateInserted
				FROM         fn.LoanCurrState INNER JOIN
									  fn.Loans ON fn.LoanCurrState.LoanID = fn.Loans.LoanID INNER JOIN
									  act.UserInfo ON fn.LoanCurrState.UserId = act.UserInfo.UserID INNER JOIN
									  fn.LoanItems ON fn.LoanCurrState.LoanItemID = fn.LoanItems.LoanItemID INNER JOIN
									  fn.LoanPaymentApply ON fn.LoanPaymentApply.LoanID = fn.Loans.LoanID
				WHERE     ((fn.LoanCurrState.LoanItemID = 10) AND (fn.LoanCurrState.LoanItemAmt = 0))
					 and ((@FromDate<=fn.LoanPaymentApply.PaymentDate) and (fn.LoanPaymentApply.PaymentDate <= @ToDate))
				GROUP BY act.UserInfo.UserID,rtrim(act.UserInfo.LastName) + ', ' + rtrim(act.UserInfo.FirstName),fn.Loans.LoanSeqNum	 
	            ORDER BY 'Name' 

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
