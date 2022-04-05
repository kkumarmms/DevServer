SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




--exec [rpt].[p_rptMonthlyMaster] 


--drop table #Output
--drop table #LoanPivotPaidTotals
--drop table #LoanPivotCurrentTotals
--drop table #Loan1
--drop table #Loan2

CREATE PROCEDURE [rpt].[p_rptMonthlyMaster] 
AS
BEGIN
-- =============================================
-- Author:		Andre Barber
-- Create date: '3/24/2014'
-- Description:	Account Payment History Report for Student Loan System
-- Modified:	06052014 ASB added Prinicpal Balance 10 for Paid Pivot 
-- Modified:	11172014 ASB modified Prinicpal Due to include 10 for Paid Pivot 
-- =============================================

	SET NOCOUNT ON;


	CREATE table #Loan1
				([Account Number] int	
				,LoanID1   int
				,Loan1	int	
				,Date1 datetime		
				,Principal1 decimal(9,2)
				,Interest1 decimal(9,2)					
				)	

	CREATE table #Loan2
				([Account Number] int	
				,LoanID2   int
				,Loan2	int	
				,Date2 datetime		
				,Principal2 decimal(9,2)
				,Interest2 decimal(9,2)													
				)						
	
	CREATE table #LoanPivotPaidTotals
				(UserID int,Name  varchar(150),[Principal Due] decimal(9,2), [Principal Balance] decimal(9,2),[Principal Overdue] decimal(9,2),[Interest Due] decimal(9,2),[Interest Overdue] decimal(9,2))

	CREATE table #LoanPivotCurrentTotals
				(UserID int,Name  varchar(150),[Principal Balance] decimal(9,2), [Interest Balance] decimal(9,2),[Current Principal Due] decimal(9,2),[Current Interest Due] decimal(9,2),[Current Amount Due] decimal(9,2),[Late Charges Owed] decimal(9,2))

	CREATE table #Output 
				(Acct int ,Name varchar(150),[Date Of Loan1] datetime,[Date Of Loan2] datetime,[Original Principal] decimal(9,2),[Principal Paid to Date] decimal(9,2),[Principal Balance] decimal(9,2)	,[Original Interest] decimal(9,2),[Interest Paid to Date] decimal(9,2),[Interest Balance] decimal(9,2))
			
					
BEGIN TRY

BEGIN


	INSERT into #Loan1			
				([Account Number],LoanID1,Loan1,Date1,Principal1,Interest1)
	SELECT 	distinct fn.Loans.UserID,fn.Loans.LoanID,fn.Loans.LoanSeqNum,fn.Loans.LoanApprovedDate
			,fn.Loans.[LoanAmt] as 'Principal1' ,fn.Loans.ProjectedInterest as 'Interest1'
	FROM  fn.Loans  INNER JOIN
          dbo.LoanPaymentSchedule lps ON lps.MMSLoanID = fn.Loans.MMSLoanID 
	WHERE     
		 fn.[Loans].LoanSeqNum=1 and lps.LoanYear=255 and fn.Loans.PayFlag<>'X'
			 	

	INSERT into #Loan2			
				([Account Number],LoanID2,Loan2,Date2,Principal2,Interest2)
	SELECT 	distinct fn.Loans.UserID,fn.Loans.LoanID,fn.Loans.LoanSeqNum,fn.Loans.LoanApprovedDate	
			,fn.Loans.[LoanAmt] as 'Principal2' ,fn.Loans.ProjectedInterest as 'Interest2'
	FROM fn.Loans  INNER JOIN
         dbo.LoanPaymentSchedule lps ON lps.MMSLoanID = fn.Loans.MMSLoanID 
	WHERE     
		 fn.[Loans].LoanSeqNum=2 and lps.LoanYear=255 and fn.Loans.PayFlag<>'X'
			
--select * from #Loan1 order by Date1 desc
--select * from #Loan2 order by Date2 desc


	;
	WITH data (UserID,LastName,FirstName,LoanItemDescr,ItemAmtPaid ) as  
				(
				SELECT     act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName, fn.LoanItems.LoanItemDescr,ItemAmtPaid =sum(fn.LoanPaymentApply.AppliedAmt) -- fn.LoanPayment.PaymentDate, fn.LoanPayment.PaymentCode, 
				FROM  act.UserInfo INNER JOIN
                      fn.LoanPaymentApply ON act.UserInfo.UserID = fn.LoanPaymentApply.UserID LEFT OUTER JOIN
                      fn.LoanItems ON fn.LoanPaymentApply.LoanItemID = fn.LoanItems.LoanItemID LEFT OUTER JOIN
                      fn.Loans ON fn.LoanPaymentApply.LoanID = fn.Loans.LoanID LEFT OUTER JOIN
                      fn.LoanPayment ON fn.LoanPaymentApply.LoanPaymentID = fn.LoanPayment.LoanPaymentID
				WHERE    
					(fn.LoanItems.LoanItemID IN (1,2,3,4,10)) 
					 and fn.Loans.PayFlag<>'X'
				GROUP BY act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName,  fn.LoanItems.LoanItemDescr --, fn.LoanPayment.PaymentDate, fn.LoanPayment.PaymentCode
				)
		    INSERT into	#LoanPivotPaidTotals	
			SELECT UserID,'Name' = LastName + ', ' + FirstName,[Principal Due],[Principal Balance],[Principal Overdue],[Interest Due],[Interest Overdue]
			FROM data 
			PIVOT ( 
			  SUM(ItemAmtPaid) 
			  for LoanItemDescr in ([Principal Due],[Principal Balance],[Principal Overdue],[Interest Due],[Interest Overdue],[Late fee],[Late fee Interest],[Returned Check fee],[Prepaid Penalty])
			) as T
			
			
	;
	WITH data (UserID,LastName,FirstName,LoanItemDescr,ItemAmt) as
				(
				SELECT     act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName, fn.LoanItems.LoanItemDescr, ItemAmt =sum(fn.LoanCurrState.LoanItemAmt) 
				FROM  act.UserInfo INNER JOIN
					  fn.LoanCurrState ON act.UserInfo.UserID = fn.LoanCurrState.UserId INNER JOIN
					  fn.LoanItems ON fn.LoanCurrState.LoanItemID = fn.LoanItems.LoanItemID  INNER JOIN
					  fn.Loans ON fn.LoanCurrState.LoanID = fn.Loans.LoanID 
				WHERE
				     (fn.LoanItems.LoanItemID IN (1,2,3,4,5,7,8,10,11,12)) 
					 and fn.Loans.PayFlag<>'X'
				GROUP BY act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName,  fn.LoanItems.LoanItemDescr
				) 
			INSERT #LoanPivotCurrentTotals	
			SELECT UserID,'Name' = LastName + ', ' + FirstName,isnull([Principal Balance],0),isnull([Interest Balance],0)
				,'Current Principal Due'=isnull([Principal Due],0)+isnull([Principal Overdue],0) 
				,'Current Interest Due'=isnull([Interest Due],0)+isnull([Interest Overdue],0)
				,'Current Amount Due'=isnull([Principal Due],0)+isnull([Principal Overdue],0)+isnull([Interest Due],0)+isnull([Interest Overdue],0)+isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0)
				,'Late Charges Owed'=isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0)
			FROM data
			PIVOT ( 
			  SUM(ItemAmt) 
			  for LoanItemDescr in ([Principal Paid to date],[Principal Balance],[Interest paid to date],[Interest Balance], [Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue],[Late Fee],[Late fee Interest],[Returned Check fee],[Prepaid Penalty])
			) as T
		


	INSERT #Output
				SELECT act.UserInfo.UserID, act.UserInfo.LastName + ', ' + act.UserInfo.FirstName
					,l1.Date1,l2.Date2,isnull(l1.Principal1,0)+isnull(l2.Principal2,0),0.00,00.0
					,isnull(l1.Interest1,0)+isnull(l2.Interest2,0),0.00,00.0
				FROM #Loan1 l1 full outer join #Loan2 l2 on l1.[Account Number]=l2.[Account Number]
					inner join act.UserInfo  on act.UserInfo.UserID=l1.[Account Number] 
					or act.UserInfo.UserID=l2.[Account Number] 
				ORDER BY act.UserInfo.UserID desc
	
						
	SELECT #Output.Acct,#Output.Name
		,'Date Of Loan1'=CASE isdate(#Output.[Date Of Loan1]) when 1 then CONVERT(varchar(10),#Output.[Date Of Loan1],101) else '' end
		,'Date Of Loan2'=CASE isdate(#Output.[Date Of Loan2]) when 1 then CONVERT(varchar(10),#Output.[Date Of Loan2],101) else '' end
		,#Output.[Original Principal] 
		,(isnull(#LoanPivotPaidTotals.[Principal Due],0)+isnull(#LoanPivotPaidTotals.[Principal Overdue],0)+isnull(#LoanPivotPaidTotals.[Principal Balance],0)) as 'Principal Paid to Date'
		,#LoanPivotCurrentTotals.[Principal Balance]  as 'Principal Balance'
		,isnull(#Output.[Original Interest],0) as 'Original Interest'
		,isnull(#LoanPivotPaidTotals.[Interest Due],0)+ isnull(#LoanPivotPaidTotals.[Interest Overdue],0) as 'Interest Paid to Date' 
		,isnull(#LoanPivotCurrentTotals.[Current Principal Due],0) as 'Current Principal Due'
		,isnull(#LoanPivotCurrentTotals.[Current Interest Due],0) as 'Current Interest Due'
		,isnull(#LoanPivotCurrentTotals.[Late Charges Owed],0)  as 'Late Charges Owed'
		--,'error' =abs(((#Output.[Original Principal]-	sum(#LoanPivotPaidTotals.Principal) - (isnull(#Loan1PivotCurrent.[Principal Balance],0) + isnull(#Loan2PivotCurrent.[Principal Balance],0))) ) )
	FROM #Output	
		 full outer join  #LoanPivotPaidTotals on #LoanPivotPaidTotals.userid=#Output.Acct
		 full outer join #LoanPivotCurrentTotals on #LoanPivotCurrentTotals.userid=#Output.Acct

	WHERE ISNULL(#Output.Acct,0)<>0	 

	ORDER by #Output.Name 



END

END TRY
BEGIN CATCH
		
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

END CATCH

END







GO
