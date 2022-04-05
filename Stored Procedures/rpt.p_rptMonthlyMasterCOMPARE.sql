SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO










--(No column name)	(No column name)	(No column name)
--16454527.46	7379243.37908732	9075284.05740801




 
--exec [rpt].[p_rptMonthlyMasterCOMPARE] 


--drop table #Output
--drop table #LoanPivotPaidTotals
--drop table #Loan1
--drop table #Loan2
--drop table #LoanPivotPaidTotals
--drop table #LoanPivotCurrentTotals

CREATE PROCEDURE [rpt].[p_rptMonthlyMasterCOMPARE] 
AS
BEGIN
-- =============================================
-- Author:		Andre Barber
-- Create date: '3/24/2014'
-- Description:	Account Payment History Report for Student Loan System
-- TODO 
-- MSherman 3/24 for a payment applied use LoanPaymentApply Principal Paid is LoanItemID 1&2,Interest Paid is LoanItemID 3&4,Late Charge Paid is LoanItemID 5,7,8,12
--Meeting 3/31/2014 for projected interest & graduation year Mike to populate
--BWheeler 4/8/2014 date range paramters only used for report display and not report logic, include all loans that have a principal balance>0
--BWheeler 4/11/2014 delete interest balance column
--BWheeler 4/18/2014 #Output.Acct<>904 --debug
--ASB 4/25/2014 change loan original amounts to , fn.Loans.[LoanAmt] as 'Principal1' ,fn.Loans.ProjectedInterest as 'Interest1'
-- =============================================

	SET NOCOUNT ON;


	create table #Loan1
				([Account Number] int	
				,LoanID1   int
				,Loan1	int	
				,Date1 datetime		
				,Principal1 decimal(9,2)
				,Interest1 decimal(9,2)					
				)	

	create table #Loan2
				([Account Number] int	
				,LoanID2   int
				,Loan2	int	
				,Date2 datetime		
				,Principal2 decimal(9,2)
				,Interest2 decimal(9,2)													
				)						
	
Create table #LoanPivotPaidTotals
(UserID int,Name  varchar(150),[Principal Due] decimal(9,2), [Principal Overdue] decimal(9,2),[Interest Due] decimal(9,2),[Interest Overdue] decimal(9,2))


create table #Output (Acct int ,Name varchar(150)
					,[Date Of Loan1] datetime,[Date Of Loan2] datetime,[Original Principal] decimal(9,2),[Principal Paid to Date] decimal(9,2),[Principal Balance] decimal(9,2)
					,[Original Interest] decimal(9,2),[Interest Paid to Date] decimal(9,2),[Interest Balance] decimal(9,2))

			
					
	begin try
	
BEGIN

Insert into #Loan1			
				([Account Number],LoanID1,Loan1,Date1,Principal1,Interest1)
	SELECT 	distinct fn.Loans.UserID,fn.Loans.LoanID,fn.Loans.LoanSeqNum,fn.Loans.LoanApprovedDate
	, fn.Loans.[LoanAmt] as 'Principal1' ,fn.Loans.ProjectedInterest as 'Interest1'
	 FROM  
                      fn.Loans  INNER JOIN
                      dbo.LoanPaymentSchedule lps ON lps.MMSLoanID = fn.Loans.MMSLoanID 
				WHERE     		
			 fn.[Loans].LoanSeqNum=1 and lps.LoanYear=255 and fn.Loans.PayFlag<>'X'
			 	
--new loan2 below
Insert into #Loan2			
		([Account Number],LoanID2,Loan2,Date2,Principal2,Interest2)
	SELECT 	distinct fn.Loans.UserID,fn.Loans.LoanID,fn.Loans.LoanSeqNum,fn.Loans.LoanApprovedDate
	, fn.Loans.[LoanAmt] as 'Principal2' ,fn.Loans.ProjectedInterest as 'Interest2'
	 FROM  
                      fn.Loans  INNER JOIN
                      dbo.LoanPaymentSchedule lps ON lps.MMSLoanID = fn.Loans.MMSLoanID 
				WHERE    
			 fn.[Loans].LoanSeqNum=2 and lps.LoanYear=255 and fn.Loans.PayFlag<>'X'
			
;
	WITH data (UserID,LastName,FirstName,LoanItemDescr,ItemAmtPaid ) as  --PaymentDate,PaymentCode,
				(
				SELECT     act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName, fn.LoanItems.LoanItemDescr,ItemAmtPaid =sum(fn.LoanPaymentApply.AppliedAmt) -- fn.LoanPayment.PaymentDate, fn.LoanPayment.PaymentCode, 
				FROM         act.UserInfo INNER JOIN
                      fn.LoanPaymentApply ON act.UserInfo.UserID = fn.LoanPaymentApply.UserID LEFT OUTER JOIN
                      fn.LoanItems ON fn.LoanPaymentApply.LoanItemID = fn.LoanItems.LoanItemID LEFT OUTER JOIN
                      fn.Loans ON fn.LoanPaymentApply.LoanID = fn.Loans.LoanID LEFT OUTER JOIN
                      fn.LoanPayment ON fn.LoanPaymentApply.LoanPaymentID = fn.LoanPayment.LoanPaymentID
				WHERE     (fn.LoanItems.LoanItemID IN (1,2,3,4))			
				 and fn.Loans.PayFlag<>'X'
				GROUP BY act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName,  fn.LoanItems.LoanItemDescr --, fn.LoanPayment.PaymentDate, fn.LoanPayment.PaymentCode
					)
		insert into	#LoanPivotPaidTotals	
			SELECT UserID,'Name' = LastName + ', ' + FirstName,[Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue] 
			FROM data --PaymentDate, PaymentCode,
			PIVOT ( 
			  SUM(ItemAmtPaid) 
			  for LoanItemDescr in ([Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue])
			) as T
			
			

	Insert #Output
				select act.UserInfo.UserID, act.UserInfo.LastName + ', ' + act.UserInfo.FirstName
				,l1.Date1,l2.Date2,isnull(l1.Principal1,0)+isnull(l2.Principal2,0),0.00,00.0
				,isnull(l1.Interest1,0)+isnull(l2.Interest2,0),0.00,00.0			
				from #Loan1 l1 full outer join #Loan2 l2 on l1.[Account Number]=l2.[Account Number]
				inner join act.UserInfo  on act.UserInfo.UserID=l1.[Account Number] 
				or act.UserInfo.UserID=l2.[Account Number] 
				order by act.UserInfo.UserID desc
	---
	
Create table #LoanPivotCurrentTotals
(UserID int,Name  varchar(150),[Principal Balance] decimal(9,2), [Interest Balance] decimal(9,2),[Current Principal Due] decimal(9,2),[Current Interest Due] decimal(9,2),[Current Amount Due] decimal(9,2),[Late Charges Owed] decimal(9,2))

	;

		WITH data (UserID,LastName,FirstName,LoanItemDescr,ItemAmt) as
				(
				SELECT     act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName, fn.LoanItems.LoanItemDescr, ItemAmt =sum(fn.LoanCurrState.LoanItemAmt) 
				FROM         act.UserInfo INNER JOIN
									  fn.LoanCurrState ON act.UserInfo.UserID = fn.LoanCurrState.UserId INNER JOIN
									  fn.LoanItems ON fn.LoanCurrState.LoanItemID = fn.LoanItems.LoanItemID  INNER JOIN
									  fn.Loans ON fn.LoanCurrState.LoanID = fn.Loans.LoanID 
				WHERE     (fn.LoanItems.LoanItemID IN (1,2,3,4,5,7,8,10,11,12))
				 and fn.Loans.PayFlag<>'X'
				GROUP BY act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName,  fn.LoanItems.LoanItemDescr		
				) 
			Insert #LoanPivotCurrentTotals	
			SELECT UserID,'Name' = LastName + ', ' + FirstName,isnull([Principal Balance],0),isnull([Interest Balance],0),'Current Principal Due2'=isnull([Principal Due],0)+isnull([Principal Overdue],0) ,'Current Interest Due2'=isnull([Interest Due],0)+isnull([Interest Overdue],0),'Current Amount Due2'=isnull([Principal Due],0)+isnull([Principal Overdue],0)+isnull([Interest Due],0)+isnull([Interest Overdue],0)+isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0),'Late Charges Owed2'=isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0)
			FROM data
			PIVOT ( 
			  SUM(ItemAmt) 
			  for LoanItemDescr in ([Principal Paid to date],[Principal Balance],[Interest paid to date],[Interest Balance], [Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue],[Late Fee],[Late fee Interest],[Returned Check fee],[Prepaid Penalty])
			) as T
		
			
----
	create table #outputcompare
				([Acct] int
				,Name varchar(100)
				,Date1 datetime	
				,Date2 datetime		
				,OrigPrincipal decimal(9,2)
				,PaidPrincipal decimal(9,2)	
				,BalPrincipal decimal(9,2)					
				)	

select '#Output before joins'
select * from #Output
select '#LoanPivotPaidTotals'
select * from #LoanPivotPaidTotals
select '#LoanPivotCurrentTotals'
select * from #LoanPivotCurrentTotals

					
--insert #outputcompare					
select ABS(qmr.paidprincipal-#LoanPivotPaidTotals.[Principal Due]) as 'ppERROR'
,qmr.Acct
,qmr.Dateloan1
,qmr.dateloan2
,qmr.origprincipal
,qmr.paidprincipal
,qmr.balprincipal
,#Output.Acct
,#Output.Name
,'Date Of Loan1'=CASE isdate(#Output.[Date Of Loan1]) when 1 then CONVERT(varchar(10),#Output.[Date Of Loan1],101) else '' end
,'Date Of Loan2'=CASE isdate(#Output.[Date Of Loan2]) when 1 then CONVERT(varchar(10),#Output.[Date Of Loan2],101) else '' end
,#Output.[Original Principal] 
,(#LoanPivotPaidTotals.[Principal Due]+#LoanPivotPaidTotals.[Principal Overdue]) as 'Principal Paid to Date'
,#LoanPivotCurrentTotals.[Principal Balance]  as 'Principal Balance'
,isnull(#Output.[Original Interest],0) as 'Original Interest'
,isnull(#LoanPivotPaidTotals.[Interest Due],0)+ isnull(#LoanPivotPaidTotals.[Interest Overdue],0) as 'Interest Paid to Date' 
,isnull(#LoanPivotCurrentTotals.[Current Principal Due],0) as 'Current Principal Due'
,isnull(#LoanPivotCurrentTotals.[Current Interest Due],0) as 'Current Interest Due'
,isnull(#LoanPivotCurrentTotals.[Late Charges Owed],0)  as 'Late Charges Owed'

from #Output	
full outer join Quartely_Master_Report qmr on qmr.ACCt=#Output.acct
	full outer join  #LoanPivotPaidTotals on #LoanPivotPaidTotals.userid=#Output.Acct
	 full outer join #LoanPivotCurrentTotals on #LoanPivotCurrentTotals.userid=#Output.Acct

 where ABS(qmr.paidprincipal-#LoanPivotPaidTotals.[Principal Due])>0.01

order by ABS(qmr.paidprincipal-#LoanPivotPaidTotals.[Principal Due]) desc
--select * from #outputcompare
END

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
	--	return(-1)
	end catch

END
























GO
