SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

















-- exec [rpt].[p_rptMonthlyMasterCOMPARE] 

--exec [rpt].[p_rptMonthlyMasterCHECKDATA] 904


--drop table #Output
--drop table #LoanPivotPaidTotals
--drop table #Loan1
--drop table #Loan2
--drop table #Loan1PivotPaid
--drop table #Loan1PivotCurrent
--drop table #Loan2PivotPaid
--drop table #Loan2PivotCurrent
CREATE PROCEDURE [rpt].[p_rptMonthlyMasterCHECKDATA] 
--(@acct int)
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
-- =============================================

	SET NOCOUNT ON;


	create table #Loan1
				([Account Number] int	
				,LoanID1   int
				,Loan1	int	
				,Date1 datetime		
				,Principal1 decimal(9,2)
				,Interest1 decimal(9,2)	
				,payflag char(1)				
				)	

	create table #Loan2
				([Account Number] int	
				,LoanID2   int
				,Loan2	int	
				,Date2 datetime		
				,Principal2 decimal(9,2)
				,Interest2 decimal(9,2)		
				,payflag char(1)											
				)						
	

Create table #Loan12PivotPaidTotals
(UserID int,Name  varchar(150),PaymentDate date,PaymentCode varchar(15),[Principal Due] decimal(9,2), [Principal Overdue] decimal(9,2),[Interest Due] decimal(9,2),[Interest Overdue] decimal(9,2))

Create table #Loan1PivotPaid
(UserID int,Name  varchar(150),PaymentDate date,PaymentCode varchar(15),[Principal Due] decimal(9,2), [Principal Overdue] decimal(9,2),[Interest Due] decimal(9,2),[Interest Overdue] decimal(9,2))
Create table #Loan1PivotCurrent
(UserID int,Name  varchar(150),[Principal Balance] decimal(9,2), [Interest Balance] decimal(9,2),[Current Principal Due] decimal(9,2),[Current Interest Due] decimal(9,2),[Current Amount Due] decimal(9,2),[Late Charges Owed] decimal(9,2))

Create table #Loan2PivotPaid
(UserID int,Name  varchar(150),PaymentDate date,PaymentCode varchar(15),[Principal Due] decimal(9,2), [Principal Overdue] decimal(9,2),[Interest Due] decimal(9,2),[Interest Overdue] decimal(9,2))
Create table #Loan2PivotCurrent
(UserID int,Name  varchar(150),[Principal Balance] decimal(9,2), [Interest Balance] decimal(9,2),[Current Principal Due] decimal(9,2),[Current Interest Due] decimal(9,2),[Current Amount Due] decimal(9,2),[Late Charges Owed] decimal(9,2))

Create table #LoanPivotCurrentTotals
(UserID int,Name  varchar(150),[Principal Balance] decimal(9,2), [Interest Balance] decimal(9,2),[Current Principal Due] decimal(9,2),[Current Interest Due] decimal(9,2),[Current Amount Due] decimal(9,2),[Late Charges Owed] decimal(9,2))


Create table #LoanPivotPaidTotals
(UserID int,[Principal] decimal(9,2),[Interest] decimal(9,2))

create table #Output (Acct int ,Name varchar(150)
					,[Date Of Loan1] datetime,[Date Of Loan2] datetime,payflag1 char(1),payflag2 char(1)
					,[Original Principal] decimal(9,2),[Principal Paid to Date] decimal(9,2),[Principal Balance] decimal(9,2)
					,[Original Interest] decimal(9,2),[Interest Paid to Date] decimal(9,2),[Interest Balance] decimal(9,2))

			
					
	begin try
	
BEGIN

---old loan1 below
	--Insert into #Loan1			
	--			([Account Number],LoanID1,Loan1,Date1,Principal1,Interest1)
	--SELECT 	distinct fn.Loans.UserID,fn.Loans.LoanID,fn.Loans.LoanSeqNum,fn.Loans.LoanApprovedDate
	--, lps.[PrincipalAmtDue] as 'Principal1' ,lps.[InterestAmtDue] as 'Interest1'
	-- FROM  fn.LoanPaymentApply   left OUTER JOIN
 --                     fn.LoanItems ON fn.LoanPaymentApply.LoanItemID = fn.LoanItems.LoanItemID LEFT OUTER JOIN
 --                     fn.Loans ON fn.LoanPaymentApply.LoanID = fn.Loans.LoanID INNER JOIN
 --                     dbo.LoanPaymentSchedule lps ON lps.MMSLoanID = fn.Loans.MMSLoanID LEFT OUTER JOIN
 --                     fn.LoanPayment ON fn.LoanPaymentApply.LoanPaymentID = fn.LoanPayment.LoanPaymentID
	--			WHERE     (fn.LoanItems.LoanItemID IN (1,2,3,4,5,7,8,10,11,12))
	--		--	and fn.Loans.UserID in (3233,3334,3238  )	
	--		and fn.[Loans].LoanSeqNum=1 and lps.LoanYear=255
---new loan1 below
Insert into #Loan1			
				([Account Number],LoanID1,Loan1,Date1,Principal1,Interest1,payflag)
	SELECT 	distinct fn.Loans.UserID,fn.Loans.LoanID,fn.Loans.LoanSeqNum,fn.Loans.LoanApprovedDate
	--, lps.[PrincipalAmtDue] as 'Principal1' ,lps.[InterestAmtDue] as 'Interest1'
	, fn.Loans.[LoanAmt] as 'Principal1' ,fn.Loans.ProjectedInterest as 'Interest1'
	,fn.Loans.payflag
	 FROM  
                      fn.Loans  INNER JOIN
                      dbo.LoanPaymentSchedule lps ON lps.MMSLoanID = fn.Loans.MMSLoanID 
				WHERE     
				--fn.Loans.UserID = @acct and
			--	((fn.Loans.UserID >= 2340) and (fn.Loans.UserID < 2350)) and
			 fn.[Loans].LoanSeqNum=1 and lps.LoanYear=255 and fn.Loans.PayFlag<>'X'
			 	
--old loan2 below			
	--Insert into #Loan2			
	--			([Account Number],LoanID2,Loan2,Date2,Principal2,Interest2)
	--SELECT 	distinct fn.Loans.UserID,fn.Loans.LoanID,fn.Loans.LoanSeqNum,fn.Loans.LoanApprovedDate
	--, lps.[PrincipalAmtDue] as 'Principal2' ,lps.[InterestAmtDue] as 'Interest2'
	-- FROM  fn.LoanPaymentApply  left OUTER JOIN
 --                     fn.LoanItems ON fn.LoanPaymentApply.LoanItemID = fn.LoanItems.LoanItemID LEFT OUTER JOIN
 --                     fn.Loans ON fn.LoanPaymentApply.LoanID = fn.Loans.LoanID inner JOIN
 --                     dbo.LoanPaymentSchedule lps ON lps.MMSLoanID = fn.Loans.MMSLoanID LEFT OUTER JOIN
 --                     fn.LoanPayment ON fn.LoanPaymentApply.LoanPaymentID = fn.LoanPayment.LoanPaymentID
	--			WHERE     (fn.LoanItems.LoanItemID IN (1,2,3,4,5,7,8,10,11,12))
	--	--		and fn.Loans.UserID in (3233,3334,3238  )	
	--		and fn.[Loans].LoanSeqNum=2 and lps.LoanYear=255
--new loan2 below
Insert into #Loan2			
		([Account Number],LoanID2,Loan2,Date2,Principal2,Interest2,payflag)
	SELECT 	distinct fn.Loans.UserID,fn.Loans.LoanID,fn.Loans.LoanSeqNum,fn.Loans.LoanApprovedDate
	--, lps.[PrincipalAmtDue] as 'Principal2' ,lps.[InterestAmtDue] as 'Interest2'
	, fn.Loans.[LoanAmt] as 'Principal2' ,fn.Loans.ProjectedInterest as 'Interest2'
	,fn.Loans.payflag
	 FROM  
                      fn.Loans  INNER JOIN
                      dbo.LoanPaymentSchedule lps ON lps.MMSLoanID = fn.Loans.MMSLoanID 
				WHERE     
		--		 fn.Loans.UserID in (3233,3334,3238  )
		--fn.Loans.UserID = @acct and	
		--((fn.Loans.UserID >= 2340) and (fn.Loans.UserID < 2350)) and
			 fn.[Loans].LoanSeqNum=2 and lps.LoanYear=255 and fn.Loans.PayFlag<>'X'
			
--select * from fn.LoanPaymentApply where UserID in (3233,3334,3238  )	
--select * from fn.LoanPayment where UserID in (3233,3334,3238  )
--select * from fn.LoanCurrState where UserID in (3233,3334,3238  )
--select * from fn.Loans where UserID in (3233,3334,3238  )
select '#loan1'
select * from #Loan1 --where [Account Number] = @acct order by Date1 desc
select '#loan2'
select * from #Loan2 --where [Account Number] = @acct order by Date2 desc


;
	WITH data (UserID,LastName,FirstName,LoanItemDescr,PaymentDate,PaymentCode,ItemAmtPaid ) as
				(
				SELECT     act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName, fn.LoanItems.LoanItemDescr, fn.LoanPayment.PaymentDate, fn.LoanPayment.PaymentCode, ItemAmtPaid =sum(fn.LoanPaymentApply.AppliedAmt) 
				FROM         act.UserInfo INNER JOIN
                      fn.LoanPaymentApply ON act.UserInfo.UserID = fn.LoanPaymentApply.UserID LEFT OUTER JOIN
                      fn.LoanItems ON fn.LoanPaymentApply.LoanItemID = fn.LoanItems.LoanItemID LEFT OUTER JOIN
                      fn.Loans ON fn.LoanPaymentApply.LoanID = fn.Loans.LoanID LEFT OUTER JOIN
                      fn.LoanPayment ON fn.LoanPaymentApply.LoanPaymentID = fn.LoanPayment.LoanPaymentID
				WHERE     (fn.LoanItems.LoanItemID IN (1,2,3,4))
			--and fn.Loans.UserID = @acct 	
			--and ((fn.Loans.UserID >= 2340) and (fn.Loans.UserID < 2350)) 
				 and fn.Loans.PayFlag<>'X'
				GROUP BY act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName,  fn.LoanItems.LoanItemDescr, fn.LoanPayment.PaymentDate, fn.LoanPayment.PaymentCode
				)
		insert into	#Loan12PivotPaidtotals	
			SELECT UserID,'Name' = LastName + ', ' + FirstName,PaymentDate, PaymentCode,[Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue] 
			FROM data
			PIVOT ( 
			  SUM(ItemAmtPaid) 
			  for LoanItemDescr in ([Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue])
			) as T
			
select '#Loan12PivotPaidtotals'			
select * from #Loan12PivotPaidtotals order by 		UserID				
			;
	
	
	
	
	WITH data (UserID,LastName,FirstName,LoanItemDescr,PaymentDate,PaymentCode,ItemAmtPaid ) as
				(
				SELECT     act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName, fn.LoanItems.LoanItemDescr, fn.LoanPayment.PaymentDate, fn.LoanPayment.PaymentCode, ItemAmtPaid =sum(fn.LoanPaymentApply.AppliedAmt) 
				FROM         act.UserInfo INNER JOIN
                      fn.LoanPaymentApply ON act.UserInfo.UserID = fn.LoanPaymentApply.UserID LEFT OUTER JOIN
                      fn.LoanItems ON fn.LoanPaymentApply.LoanItemID = fn.LoanItems.LoanItemID LEFT OUTER JOIN
                      fn.Loans ON fn.LoanPaymentApply.LoanID = fn.Loans.LoanID LEFT OUTER JOIN
                      fn.LoanPayment ON fn.LoanPaymentApply.LoanPaymentID = fn.LoanPayment.LoanPaymentID
				WHERE     (fn.LoanItems.LoanItemID IN (1,2,3,4))
			--and fn.Loans.UserID = @acct 	
			--and ((fn.Loans.UserID >= 2340) and (fn.Loans.UserID < 2350)) 
				and fn.[Loans].LoanSeqNum=1 and fn.Loans.PayFlag<>'X'
				GROUP BY act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName,  fn.LoanItems.LoanItemDescr, fn.LoanPayment.PaymentDate, fn.LoanPayment.PaymentCode
				)
		insert into	#Loan1PivotPaid	
			SELECT UserID,'Name' = LastName + ', ' + FirstName,PaymentDate, PaymentCode,[Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue] 
			FROM data
			PIVOT ( 
			  SUM(ItemAmtPaid) 
			  for LoanItemDescr in ([Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue])
			) as T
			
select '#Loan1PivotPaid'			
select * from #Loan1PivotPaid order by 		UserID				
			;

		WITH data (UserID,LastName,FirstName,LoanItemDescr,ItemAmt) as
				(
				SELECT     act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName, fn.LoanItems.LoanItemDescr, ItemAmt =sum(fn.LoanCurrState.LoanItemAmt) 
				FROM         act.UserInfo INNER JOIN
									  fn.LoanCurrState ON act.UserInfo.UserID = fn.LoanCurrState.UserId INNER JOIN
									  fn.LoanItems ON fn.LoanCurrState.LoanItemID = fn.LoanItems.LoanItemID  INNER JOIN
									  fn.Loans ON fn.LoanCurrState.LoanID = fn.Loans.LoanID 
				WHERE     (fn.LoanItems.LoanItemID IN (1,2,3,4,5,7,8,10,11,12))
		--WHERE     (fn.LoanItems.LoanItemID IN (1,2,3,4,5,7,8,10,14,15))
		--and fn.Loans.UserID = 904
		--	and fn.Loans.UserID = @acct 		
	--	and ((fn.Loans.UserID >= 2340) and (fn.Loans.UserID < 2350)) 
				and fn.[Loans].LoanSeqNum=1 and fn.Loans.PayFlag<>'X'
				GROUP BY act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName,  fn.LoanItems.LoanItemDescr
				) 
			Insert #Loan1PivotCurrent	
			SELECT UserID,'Name' = LastName + ', ' + FirstName,isnull([Principal Balance],0),isnull([Interest Balance],0),'Current Principal Due1'=isnull([Principal Due],0)+isnull([Principal Overdue],0) ,'Current Interest Due1'=isnull([Interest Due],0)+isnull([Interest Overdue],0),'Current Amount Due1'=isnull([Principal Due],0)+isnull([Principal Overdue],0)+isnull([Interest Due],0)+isnull([Interest Overdue],0)+isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0),'Late Charges Owed1'=isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0)
			--SELECT UserID,'Name' = LastName + ', ' + FirstName
			--,isnull([Principal Paid to date],0) as 'Principal Balance'
			--,isnull([Interest paid to date],0) as 'Interest Balance'			
			--,'Current Principal Due1'=isnull([Principal Due],0)+isnull([Principal Overdue],0) 
			--,'Current Interest Due1'=isnull([Interest Due],0)+isnull([Interest Overdue],0),
			--'Current Amount Due1'=isnull([Principal Due],0)+isnull([Principal Overdue],0)+isnull([Interest Due],0)+isnull([Interest Overdue],0)+isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0),
			--'Late Charges Owed1'=isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0)
			FROM data
			PIVOT ( 
			  SUM(ItemAmt) 
			  --for LoanItemDescr in ([Principal Balance],[Interest Balance],[Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue],[Late Fee],[Late fee Interest],[Returned Check fee],[Prepaid Penalty])
			  for LoanItemDescr in ([Principal Paid to date],[Principal Balance],[Interest paid to date],[Interest Balance], [Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue],[Late Fee],[Late fee Interest],[Returned Check fee],[Prepaid Penalty])
			) as T
			ORDER BY UserID
select '#Loan1PivotCurrent'			
select * from #Loan1PivotCurrent order by 		UserID	
			;

	WITH data (UserID,LastName,FirstName,LoanItemDescr,PaymentDate,PaymentCode,ItemAmtPaid ) as
				(
				SELECT     act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName, fn.LoanItems.LoanItemDescr, fn.LoanPayment.PaymentDate, fn.LoanPayment.PaymentCode, ItemAmtPaid =sum(fn.LoanPaymentApply.AppliedAmt) 
				FROM         act.UserInfo INNER JOIN
                      fn.LoanPaymentApply ON act.UserInfo.UserID = fn.LoanPaymentApply.UserID LEFT OUTER JOIN
                      fn.LoanItems ON fn.LoanPaymentApply.LoanItemID = fn.LoanItems.LoanItemID LEFT OUTER JOIN
                      fn.Loans ON fn.LoanPaymentApply.LoanID = fn.Loans.LoanID LEFT OUTER JOIN
                      fn.LoanPayment ON fn.LoanPaymentApply.LoanPaymentID = fn.LoanPayment.LoanPaymentID
				WHERE     (fn.LoanItems.LoanItemID IN (1,2,3,4))
			--	and act.UserInfo.UserID in (3233,3334,3238  )	
		--		and fn.Loans.UserID = @acct 	
		--and ((fn.Loans.UserID >= 2340) and (fn.Loans.UserID < 2350)) 
				and fn.[Loans].LoanSeqNum=2 and fn.Loans.PayFlag<>'X'
				GROUP BY act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName,  fn.LoanItems.LoanItemDescr, fn.LoanPayment.PaymentDate, fn.LoanPayment.PaymentCode
				)
		insert into	#Loan2PivotPaid	
			SELECT UserID,'Name' = LastName + ', ' + FirstName,PaymentDate, PaymentCode,[Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue] 
			FROM data
			PIVOT ( 
			  SUM(ItemAmtPaid) 
			  for LoanItemDescr in ([Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue])
			) as T
			
select '#Loan2PivotPaid'			
select * from #Loan2PivotPaid order by 		UserID				
			;

		WITH data (UserID,LastName,FirstName,LoanItemDescr,ItemAmt) as
				(
				SELECT     act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName, fn.LoanItems.LoanItemDescr, ItemAmt =sum(fn.LoanCurrState.LoanItemAmt) 
				FROM         act.UserInfo INNER JOIN
									  fn.LoanCurrState ON act.UserInfo.UserID = fn.LoanCurrState.UserId INNER JOIN
									  fn.LoanItems ON fn.LoanCurrState.LoanItemID = fn.LoanItems.LoanItemID  INNER JOIN
									  fn.Loans ON fn.LoanCurrState.LoanID = fn.Loans.LoanID 
				WHERE     (fn.LoanItems.LoanItemID IN (1,2,3,4,5,7,8,10,11,12))
			--	WHERE     (fn.LoanItems.LoanItemID IN (1,2,3,4,5,7,8,10,14,15))
			--	and act.UserInfo.UserID in (3233,3334,3238  )	
				--and fn.Loans.UserID = @acct 	
		--		and ((fn.Loans.UserID >= 2340) and (fn.Loans.UserID < 2350)) 
				and fn.[Loans].LoanSeqNum=2 and fn.Loans.PayFlag<>'X'
				GROUP BY act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName,  fn.LoanItems.LoanItemDescr
				) 
			Insert #Loan2PivotCurrent	
			SELECT UserID,'Name' = LastName + ', ' + FirstName,isnull([Principal Balance],0),isnull([Interest Balance],0),'Current Principal Due2'=isnull([Principal Due],0)+isnull([Principal Overdue],0) ,'Current Interest Due2'=isnull([Interest Due],0)+isnull([Interest Overdue],0),'Current Amount Due2'=isnull([Principal Due],0)+isnull([Principal Overdue],0)+isnull([Interest Due],0)+isnull([Interest Overdue],0)+isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0),'Late Charges Owed2'=isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0)
			--SELECT UserID,'Name' = LastName + ', ' + FirstName
			--,isnull([Principal Paid to date],0) as 'Principal Balance'
			--,isnull([Interest paid to date],0) as 'Interest Balance'
			--,'Current Principal Due2'=isnull([Principal Due],0)+isnull([Principal Overdue],0) 
			--,'Current Interest Due2'=isnull([Interest Due],0)+isnull([Interest Overdue],0)
			--,'Current Amount Due2'=isnull([Principal Due],0)+isnull([Principal Overdue],0)+isnull([Interest Due],0)+isnull([Interest Overdue],0)+isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0)
			--,'Late Charges Owed2'=isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0)
			FROM data
			PIVOT ( 
			  SUM(ItemAmt) 
			--  for LoanItemDescr in ([Principal Balance],[Interest Balance],[Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue],[Late Fee],[Late fee Interest],[Returned Check fee],[Prepaid Penalty])
			  for LoanItemDescr in ([Principal Paid to date],[Principal Balance],[Interest paid to date],[Interest Balance], [Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue],[Late Fee],[Late fee Interest],[Returned Check fee],[Prepaid Penalty])
			) as T
			ORDER BY UserID

select '#Loan2PivotCurrent'
select * from #Loan2PivotCurrent order by 		UserID	



	;

		WITH data (UserID,LastName,FirstName,LoanItemDescr,ItemAmt) as
				(
				SELECT     act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName, fn.LoanItems.LoanItemDescr, ItemAmt =sum(fn.LoanCurrState.LoanItemAmt) 
				FROM         act.UserInfo INNER JOIN
									  fn.LoanCurrState ON act.UserInfo.UserID = fn.LoanCurrState.UserId INNER JOIN
									  fn.LoanItems ON fn.LoanCurrState.LoanItemID = fn.LoanItems.LoanItemID  INNER JOIN
									  fn.Loans ON fn.LoanCurrState.LoanID = fn.Loans.LoanID 
				WHERE     (fn.LoanItems.LoanItemID IN (1,2,3,4,5,7,8,10,11,12))
			--	WHERE     (fn.LoanItems.LoanItemID IN (1,2,3,4,5,7,8,10,14,15))
			--	and act.UserInfo.UserID in (3233,3334,3238  )	
				--and fn.Loans.UserID = @acct 	
			--	and ((fn.Loans.UserID >= 2340) and (fn.Loans.UserID < 2350)) 
			 and fn.Loans.PayFlag<>'X'
				GROUP BY act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName,  fn.LoanItems.LoanItemDescr
				) 
			Insert #LoanPivotCurrentTotals	
			SELECT UserID,'Name' = LastName + ', ' + FirstName,isnull([Principal Balance],0),isnull([Interest Balance],0),'Current Principal Due2'=isnull([Principal Due],0)+isnull([Principal Overdue],0) ,'Current Interest Due2'=isnull([Interest Due],0)+isnull([Interest Overdue],0),'Current Amount Due2'=isnull([Principal Due],0)+isnull([Principal Overdue],0)+isnull([Interest Due],0)+isnull([Interest Overdue],0)+isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0),'Late Charges Owed2'=isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0)
			--SELECT UserID,'Name' = LastName + ', ' + FirstName
			--,isnull([Principal Paid to date],0) as 'Principal Balance'
			--,isnull([Interest paid to date],0) as 'Interest Balance'
			--,'Current Principal Due2'=isnull([Principal Due],0)+isnull([Principal Overdue],0) 
			--,'Current Interest Due2'=isnull([Interest Due],0)+isnull([Interest Overdue],0)
			--,'Current Amount Due2'=isnull([Principal Due],0)+isnull([Principal Overdue],0)+isnull([Interest Due],0)+isnull([Interest Overdue],0)+isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0)
			--,'Late Charges Owed2'=isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0)
			FROM data
			PIVOT ( 
			  SUM(ItemAmt) 
			--  for LoanItemDescr in ([Principal Balance],[Interest Balance],[Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue],[Late Fee],[Late fee Interest],[Returned Check fee],[Prepaid Penalty])
			  for LoanItemDescr in ([Principal Paid to date],[Principal Balance],[Interest paid to date],[Interest Balance], [Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue],[Late Fee],[Late fee Interest],[Returned Check fee],[Prepaid Penalty])
			) as T
			ORDER BY UserID

select '#LoanPivotCurrentTotals'
select * from #LoanPivotCurrentTotals order by 		UserID	

			
insert #LoanPivotPaidTotals	
select UserID,sum(isnull([Principal Due],0.00) + isnull([Principal Overdue],0.00)),SUM(isnull([Interest Due],0.00) + isnull([Interest Overdue],0.00))
from #Loan12PivotPaidtotals	
group by UserID			
--select UserID,sum(isnull([Principal Due],0.00) + isnull([Principal Overdue],0.00)),SUM(isnull([Interest Due],0.00) + isnull([Interest Overdue],0.00))
--from #Loan1PivotPaid
--group by UserID
--insert #LoanPivotPaidTotals					
--select UserID,sum(isnull([Principal Due],0.00) + isnull([Principal Overdue],0.00)),SUM(isnull([Interest Due],0.00) + isnull([Interest Overdue],0.00))
--from #Loan2PivotPaid
--group by UserID

select '#LoanPivotPaidTotals'	
select * from #LoanPivotPaidTotals order by UserID

	Insert #Output
				select act.UserInfo.UserID
				, act.UserInfo.LastName + ', ' + act.UserInfo.FirstName
				,l1.Date1,l2.Date2,l1.payflag as 'payflag1',l2.payflag as 'payflag2'
				,isnull(l1.Principal1,0)+isnull(l2.Principal2,0),0.00,00.0
				,isnull(l1.Interest1,0)+isnull(l2.Interest2,0),0.00,00.0
				--l1.LoanID1,l2.LoanID2,
				from #Loan1 l1 full outer join #Loan2 l2 on l1.[Account Number]=l2.[Account Number]
				inner join act.UserInfo  on (act.UserInfo.UserID=l1.[Account Number] 
				or act.UserInfo.UserID=l2.[Account Number] ) --and (l1.[Account Number]=l2.[Account Number])
				where isnull(act.UserInfo.UserID,0)<>0
				order by act.UserInfo.UserID desc
	---output the results
select '#Output raw'
select * from #Output



--select Acct,sum([Original Principal]),sum([Principal Paid to Date]),sum([Principal Balance]) from #output
--where ISNULL((#Output.[Original Principal]),0.00)<>0.00	
----	and (#Output.payflag1='A' or #Output.payflag2='A')
--group by acct with rollup

	order by acct

select 'report raw no sums'					
select distinct #Output.Acct --,#Output.Name,#Output.payflag1,#Output.payflag2
--,'error' =abs(((#Output.[Original Principal]-	sum(#LoanPivotPaidTotals.Principal) - (isnull(#Loan1PivotCurrent.[Principal Balance],0) + isnull(#Loan2PivotCurrent.[Principal Balance],0))) ) )
,'Date Of Loan1'=CASE isdate(#Output.[Date Of Loan1]) when 1 then CONVERT(varchar(10),#Output.[Date Of Loan1],101) else '' end
,'Date Of Loan2'=CASE isdate(#Output.[Date Of Loan2]) when 1 then CONVERT(varchar(10),#Output.[Date Of Loan2],101) else '' end
,#Output.[Original Principal]
,#LoanPivotPaidTotals.Principal as 'Principal Paid to Date'
,#LoanPivotCurrentTotals.[Principal Balance]  as 'Principal Balance'
--,#Output.[Original Interest],sum(#LoanPivotPaidTotals.Interest) as 'Interest Paid to Date' 
--,isnull(#Loan1PivotCurrent.[Current Principal Due],0) + isnull(#Loan2PivotCurrent.[Current Principal Due],0) as 'Current Principal Due'
--,isnull(#Loan1PivotCurrent.[Current Interest Due],0) + isnull(#Loan2PivotCurrent.[Current Interest Due],0) as 'Current Interest Due'
--,isnull(#Loan1PivotCurrent.[Late Charges Owed],0) + isnull(#Loan2PivotCurrent.[Late Charges Owed],0) as 'Late Charges Owed'

from #LoanPivotPaidTotals	
	inner join #Output on #LoanPivotPaidTotals.userid=#Output.Acct
	inner join #LoanPivotCurrentTotals on #LoanPivotCurrentTotals.userid=#Output.Acct

	--where isnull(#Output.Acct,0)<>0 and #Output.Acct>=2282
	--Where not(#Output.Acct in (904,1819,705)) --debug
--	where (#Output.payflag1='A' or #Output.payflag2='A')
--group by #Output.Acct --,#Output.Name,#Output.payflag1,#Output.payflag2
--,#Output.[Date Of Loan1]
--,#Output.[Date Of Loan2]
--,#Output.[Original Principal]

--,isnull(#Loan1PivotCurrent.[Principal Balance],0) + isnull(#Loan2PivotCurrent.[Principal Balance],0)
--,#Output.[Original Interest]
--,isnull(#Loan1PivotCurrent.[Current Principal Due],0) + isnull(#Loan2PivotCurrent.[Current Principal Due],0)
--,isnull(#Loan1PivotCurrent.[Interest Balance],0) + isnull(#Loan2PivotCurrent.[Interest Balance],0)
--,isnull(#Loan1PivotCurrent.[Current Principal Due],0) + isnull(#Loan2PivotCurrent.[Current Principal Due],0)
--,isnull(#Loan1PivotCurrent.[Current Interest Due],0) + isnull(#Loan2PivotCurrent.[Current Interest Due],0)
--,isnull(#Loan1PivotCurrent.[Late Charges Owed],0) + isnull(#Loan2PivotCurrent.[Late Charges Owed],0)	
--		with rollup
--having  ISNULL((#Output.[Original Principal]),0.00)<>0.00		
order by #Output.acct --#Output.payflag1,#Output.payflag2 --#Output.acct -- #Output.acct --#Output.Name		 --'error'

select 'report'					
select #Output.Acct --,#Output.Name,#Output.payflag1,#Output.payflag2
,'error' =abs(#Output.[Original Principal]-#LoanPivotPaidTotals.Principal-#LoanPivotCurrentTotals.[Principal Balance])
,'Date Of Loan1'=CASE isdate(#Output.[Date Of Loan1]) when 1 then CONVERT(varchar(10),#Output.[Date Of Loan1],101) else '' end
,'Date Of Loan2'=CASE isdate(#Output.[Date Of Loan2]) when 1 then CONVERT(varchar(10),#Output.[Date Of Loan2],101) else '' end
,#Output.[Original Principal]
,#LoanPivotPaidTotals.Principal as 'Principal Paid to Date'
,#LoanPivotCurrentTotals.[Principal Balance]  as 'Principal Balance'
--,#Output.[Original Interest],sum(#LoanPivotPaidTotals.Interest) as 'Interest Paid to Date' 
--,isnull(#Loan1PivotCurrent.[Current Principal Due],0) + isnull(#Loan2PivotCurrent.[Current Principal Due],0) as 'Current Principal Due'
--,isnull(#Loan1PivotCurrent.[Current Interest Due],0) + isnull(#Loan2PivotCurrent.[Current Interest Due],0) as 'Current Interest Due'
--,isnull(#Loan1PivotCurrent.[Late Charges Owed],0) + isnull(#Loan2PivotCurrent.[Late Charges Owed],0) as 'Late Charges Owed'

from 	#Output
	--full outer join #Output on #LoanPivotPaidTotals.userid=#Output.Acct
	full outer join #LoanPivotPaidTotals on #LoanPivotPaidTotals.userid=#Output.Acct
	full outer join #LoanPivotCurrentTotals on #LoanPivotCurrentTotals.userid=#Output.Acct
	--inner join #Loan2PivotCurrent on #Loan2PivotCurrent.userid=#Output.Acct
	--where isnull(#Output.Acct,0)<>0 and #Output.Acct>=2282
	--Where not(#Output.Acct in (904,1819,705)) --debug
--	where (#Output.payflag1='A' or #Output.payflag2='A')
--group by #Output.Acct --,#Output.Name,#Output.payflag1,#Output.payflag2
--,#Output.[Date Of Loan1]
--,#Output.[Date Of Loan2]
--,#Output.[Original Principal]
--,isnull(#LoanPivotCurrentTotals.[Principal Balance],0)
--,#Output.[Original Interest]
--,isnull(#Loan1PivotCurrent.[Current Principal Due],0) + isnull(#Loan2PivotCurrent.[Current Principal Due],0)
--,isnull(#Loan1PivotCurrent.[Interest Balance],0) + isnull(#Loan2PivotCurrent.[Interest Balance],0)
--,isnull(#Loan1PivotCurrent.[Current Principal Due],0) + isnull(#Loan2PivotCurrent.[Current Principal Due],0)
--,isnull(#Loan1PivotCurrent.[Current Interest Due],0) + isnull(#Loan2PivotCurrent.[Current Interest Due],0)
--,isnull(#Loan1PivotCurrent.[Late Charges Owed],0) + isnull(#Loan2PivotCurrent.[Late Charges Owed],0)	
--		with rollup
--having  ISNULL((#Output.[Original Principal]),0.00)<>0.00		
order by 'error' desc --#Output.acct --#Output.payflag1,#Output.payflag2 --#Output.acct -- #Output.acct --#Output.Name		 --'error'



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
