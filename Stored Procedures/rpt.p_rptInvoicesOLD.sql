SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





--exec [p_rptInvoices] 'MayJune' 


--drop table #Output
--drop table #LoanPivotPaidTotals
--drop table #Loan1
--drop table #Loan2
--drop table #Loan1PivotPaid
--drop table #Loan1PivotCurrent
--drop table #Loan2PivotPaid
--drop table #Loan2PivotCurrent

CREATE PROCEDURE [rpt].[p_rptInvoicesOLD] 
 --(@InvoiceType varchar(20))

AS

--set @InvoiceType = 'MayJune' 
--set @InvoiceType = 'JulyAugust' 
--set @InvoiceType = 'SeptThruApril'

BEGIN
-- =============================================
-- Author:		Andre Barber
-- Create date: '3/24/2014'
-- Description:	Invoices Report for Student Loan System
-- 3 invoices 
-- TODO get rules for when invoices are sent out and the due date 1)MayJune 2)JulyAugust 3)SeptThruApril each have common and different fields
--
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
	

Create table #Loan1PivotPaid
(UserID int,Name  varchar(150),PaymentDate date,PaymentCode varchar(15),[Principal Due] decimal(9,2), [Principal Overdue] decimal(9,2),[Interest Due] decimal(9,2),[Interest Overdue] decimal(9,2))
Create table #Loan1PivotCurrent
(UserID int,Name  varchar(150),[Principal Balance] decimal(9,2), [Interest Balance] decimal(9,2),[Current Principal Due] decimal(9,2),[Current Interest Due] decimal(9,2),[Current Amount Due] decimal(9,2),[Late Charges Owed] decimal(9,2))

Create table #Loan2PivotPaid
(UserID int,Name  varchar(150),PaymentDate date,PaymentCode varchar(15),[Principal Due] decimal(9,2), [Principal Overdue] decimal(9,2),[Interest Due] decimal(9,2),[Interest Overdue] decimal(9,2))
Create table #Loan2PivotCurrent
(UserID int,Name  varchar(150),[Principal Balance] decimal(9,2), [Interest Balance] decimal(9,2),[Current Principal Due] decimal(9,2),[Current Interest Due] decimal(9,2),[Current Amount Due] decimal(9,2),[Late Charges Owed] decimal(9,2))


Create table #LoanPivotPaidTotals
(UserID int,[Principal] decimal(9,2),[Interest] decimal(9,2))

create table #Output (Acct int ,Name varchar(150)
					,Addr1 varchar(150)
					,Addr2 varchar(150)
					,Salutation varchar(150)
					,School varchar(150)
					,[Date Of Loan1] datetime,[Date Of Loan2] datetime
					,[Original Principal] decimal(9,2),[Principal Paid to Date] decimal(9,2),[Principal Balance] decimal(9,2)
					,[Original Interest] decimal(9,2),[Interest Paid to Date] decimal(9,2),[Interest Balance] decimal(9,2))



--set @InvoiceType = CASE @InvoiceType WHEN 'MayJune' THEN ''
--								 WHEN 'JulyAugust' THEN ''
--								 WHEN 'SeptThruApril' THEN ''
--								 END
		
					
	begin try
	
BEGIN




	Insert into #Loan1			
				([Account Number],LoanID1,Loan1,Date1,Principal1,Interest1)
	SELECT 	distinct fn.Loans.UserID,fn.Loans.LoanID,fn.Loans.LoanSeqNum,fn.Loans.LoanApprovedDate
	, lps.[PrincipalAmtDue] as 'Principal1' ,lps.[InterestAmtDue] as 'Interest1'
	 FROM  fn.LoanPaymentApply  LEFT OUTER JOIN
                      fn.LoanItems ON fn.LoanPaymentApply.LoanItemID = fn.LoanItems.LoanItemID LEFT OUTER JOIN
                      fn.Loans ON fn.LoanPaymentApply.LoanID = fn.Loans.LoanID INNER JOIN
                      dbo.LoanPaymentSchedule lps ON lps.MMSLoanID = fn.Loans.MMSLoanID LEFT OUTER JOIN
                      fn.LoanPayment ON fn.LoanPaymentApply.LoanPaymentID = fn.LoanPayment.LoanPaymentID
				WHERE     (fn.LoanItems.LoanItemID IN (1,2,3,4,5,7,8,10,11,12))
		--		and fn.Loans.UserID in (2284,2285,2286,2305)
			and fn.[Loans].LoanSeqNum=1 and lps.LoanYear=255

	Insert into #Loan2			
				([Account Number],LoanID2,Loan2,Date2,Principal2,Interest2)
	SELECT 	distinct fn.Loans.UserID,fn.Loans.LoanID,fn.Loans.LoanSeqNum,fn.Loans.LoanApprovedDate
	, lps.[PrincipalAmtDue] as 'Principal2' ,lps.[InterestAmtDue] as 'Interest2'
	 FROM  fn.LoanPaymentApply  LEFT OUTER JOIN
                      fn.LoanItems ON fn.LoanPaymentApply.LoanItemID = fn.LoanItems.LoanItemID LEFT OUTER JOIN
                      fn.Loans ON fn.LoanPaymentApply.LoanID = fn.Loans.LoanID INNER JOIN
                      dbo.LoanPaymentSchedule lps ON lps.MMSLoanID = fn.Loans.MMSLoanID LEFT OUTER JOIN
                      fn.LoanPayment ON fn.LoanPaymentApply.LoanPaymentID = fn.LoanPayment.LoanPaymentID
				WHERE     (fn.LoanItems.LoanItemID IN (1,2,3,4,5,7,8,10,11,12))
		--		and fn.Loans.UserID in (2284,2285,2286,2305)
			and fn.[Loans].LoanSeqNum=2 and lps.LoanYear=255



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
			--	and act.UserInfo.UserID in (2284,2285,2286,2305)
				and fn.[Loans].LoanSeqNum=1
				GROUP BY act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName,  fn.LoanItems.LoanItemDescr, fn.LoanPayment.PaymentDate, fn.LoanPayment.PaymentCode
				)
		insert into	#Loan1PivotPaid	
			SELECT UserID,'Name' = LastName + ', ' + FirstName,PaymentDate, PaymentCode,[Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue] 
			FROM data
			PIVOT ( 
			  SUM(ItemAmtPaid) 
			  for LoanItemDescr in ([Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue])
			) as T
			
			;

		WITH data (UserID,LastName,FirstName,LoanItemDescr,ItemAmt) as
				(
				SELECT     act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName, fn.LoanItems.LoanItemDescr, ItemAmt =sum(fn.LoanCurrState.LoanItemAmt) 
				FROM         act.UserInfo INNER JOIN
									  fn.LoanCurrState ON act.UserInfo.UserID = fn.LoanCurrState.UserId INNER JOIN
									  fn.LoanItems ON fn.LoanCurrState.LoanItemID = fn.LoanItems.LoanItemID  INNER JOIN
									  fn.Loans ON fn.LoanCurrState.LoanID = fn.Loans.LoanID 
				WHERE     (fn.LoanItems.LoanItemID IN (1,2,3,4,5,7,8,10,11,12))
			--	and act.UserInfo.UserID in (2284,2285,2286,2305)
				and fn.[Loans].LoanSeqNum=1
				GROUP BY act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName,  fn.LoanItems.LoanItemDescr
				) 
			Insert #Loan1PivotCurrent	
			SELECT UserID,'Name' = LastName + ', ' + FirstName,isnull([Principal Balance],0),isnull([Interest Balance],0),'Current Principal Due1'=isnull([Principal Due],0)+isnull([Principal Overdue],0) ,'Current Interest Due1'=isnull([Interest Due],0)+isnull([Interest Overdue],0),'Current Amount Due1'=isnull([Principal Due],0)+isnull([Principal Overdue],0)+isnull([Interest Due],0)+isnull([Interest Overdue],0)+isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0),'Late Charges Owed1'=isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0)
			FROM data
			PIVOT ( 
			  SUM(ItemAmt) 
			  for LoanItemDescr in ([Principal Balance],[Interest Balance],[Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue],[Late Fee],[Late fee Interest],[Returned Check fee],[Prepaid Penalty])
			) as T
			ORDER BY UserID
			
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
		--		and act.UserInfo.UserID in (2284,2285,2286,2305)
				and fn.[Loans].LoanSeqNum=2
				GROUP BY act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName,  fn.LoanItems.LoanItemDescr, fn.LoanPayment.PaymentDate, fn.LoanPayment.PaymentCode
				)
		insert into	#Loan2PivotPaid	
			SELECT UserID,'Name' = LastName + ', ' + FirstName,PaymentDate, PaymentCode,[Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue] 
			FROM data
			PIVOT ( 
			  SUM(ItemAmtPaid) 
			  for LoanItemDescr in ([Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue])
			) as T
			
			;

		WITH data (UserID,LastName,FirstName,LoanItemDescr,ItemAmt) as
				(
				SELECT     act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName, fn.LoanItems.LoanItemDescr, ItemAmt =sum(fn.LoanCurrState.LoanItemAmt) 
				FROM         act.UserInfo INNER JOIN
									  fn.LoanCurrState ON act.UserInfo.UserID = fn.LoanCurrState.UserId INNER JOIN
									  fn.LoanItems ON fn.LoanCurrState.LoanItemID = fn.LoanItems.LoanItemID  INNER JOIN
									  fn.Loans ON fn.LoanCurrState.LoanID = fn.Loans.LoanID 
				WHERE     (fn.LoanItems.LoanItemID IN (1,2,3,4,5,7,8,10,11,12))
		--		and act.UserInfo.UserID in (2284,2285,2286,2305)
				and fn.[Loans].LoanSeqNum=2
				GROUP BY act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName,  fn.LoanItems.LoanItemDescr
				) 
			Insert #Loan2PivotCurrent	
			SELECT UserID,'Name' = LastName + ', ' + FirstName,isnull([Principal Balance],0),isnull([Interest Balance],0),'Current Principal Due2'=isnull([Principal Due],0)+isnull([Principal Overdue],0) ,'Current Interest Due2'=isnull([Interest Due],0)+isnull([Interest Overdue],0),'Current Amount Due2'=isnull([Principal Due],0)+isnull([Principal Overdue],0)+isnull([Interest Due],0)+isnull([Interest Overdue],0)+isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0),'Late Charges Owed2'=isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0)
			FROM data
			PIVOT ( 
			  SUM(ItemAmt) 
			  for LoanItemDescr in ([Principal Balance],[Interest Balance],[Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue],[Late Fee],[Late fee Interest],[Returned Check fee],[Prepaid Penalty])
			) as T
			ORDER BY UserID
			
			
			insert #LoanPivotPaidTotals					
select UserID,sum(isnull([Principal Due],0.00) + isnull([Principal Overdue],0.00)),SUM(isnull([Interest Due],0.00) + isnull([Interest Overdue],0.00))
 from #Loan1PivotPaid
group by UserID

insert #LoanPivotPaidTotals					
select UserID,sum(isnull([Principal Due],0.00) + isnull([Principal Overdue],0.00)),SUM(isnull([Interest Due],0.00) + isnull([Interest Overdue],0.00))
 from #Loan2PivotPaid
group by UserID

	Insert #Output
				select u.UserID, rtrim(u.FirstName) + ' '  + rtrim(u.LastName) + ' ' + rtrim(isnull(u.title,'')) as 'Name'
				,a.Address1 + ' ' + isnull(a.Address2,'') as 'Address1'
				,rtrim(a.City) + ', ' + rtrim(a.State) + ' ' + rtrim(a.zip)  as 'Address2'
				,u.Title as 'Salutation'
				,i.InstitutionName as 'School'
				,l1.Date1,l2.Date2
				,isnull(l1.Principal1,0)+isnull(l2.Principal2,0),0.00,0.00
				,isnull(l1.Interest1,0)+isnull(l2.Interest2,0),0.00,00.0				
				from #Loan1 l1 full outer join #Loan2 l2 on l1.[Account Number]=l2.[Account Number]
				inner join act.UserInfo u on u.UserID=l1.[Account Number] 
				or u.UserID=l2.[Account Number] 
				inner join act.address a on u.UserID=a.UserID 
				inner join opr.Institution i on  u.institutionID=i.institutionID  
				
	---output the results
	
					
select #Output.Acct,#Output.Name

					,#Output.Addr1 
					,#Output.Addr2 
					,#Output.Salutation 
					,#Output.School 
,'Date Of Loan1'=CASE isdate(#Output.[Date Of Loan1]) when 1 then CONVERT(varchar(10),#Output.[Date Of Loan1],101) else '' end
,'Date Of Loan2'=CASE isdate(#Output.[Date Of Loan2]) when 1 then CONVERT(varchar(10),#Output.[Date Of Loan2],101) else '' end
,#Output.[Original Principal],sum(#LoanPivotPaidTotals.Principal) as 'Principal Paid to Date'
,isnull(#Loan1PivotCurrent.[Principal Balance],0) + isnull(#Loan2PivotCurrent.[Principal Balance],0) as 'Principal Balance'
,#Output.[Original Interest],sum(#LoanPivotPaidTotals.Interest) as 'Interest Paid to Date' 
,isnull(#Loan1PivotCurrent.[Interest Balance],0) + isnull(#Loan2PivotCurrent.[Interest Balance],0) as 'Interest Balance'
,isnull(#Loan1PivotCurrent.[Current Principal Due],0) + isnull(#Loan2PivotCurrent.[Current Principal Due],0) as 'Current Principal Due'
,isnull(#Loan1PivotCurrent.[Current Interest Due],0) + isnull(#Loan2PivotCurrent.[Current Interest Due],0) as 'Current Interest Due'
,isnull(#Loan1PivotCurrent.[Late Charges Owed],0) + isnull(#Loan2PivotCurrent.[Late Charges Owed],0) as 'Late Charges Owed'

from #LoanPivotPaidTotals	
	inner join #Output on #LoanPivotPaidTotals.userid=#Output.Acct
	full outer join #Loan1PivotCurrent on #Loan1PivotCurrent.userid=#Output.Acct
	full outer join #Loan2PivotCurrent on #Loan2PivotCurrent.userid=#Output.Acct
	where isnull(#Output.Acct,0)<>0
	-- and #Output.Acct>=2476
group by #Output.Acct,#Output.Name,#Output.Addr1 ,#Output.Addr2,#Output.Salutation ,#Output.School  ,#Output.[Date Of Loan1],#Output.[Date Of Loan2],#Output.[Original Principal],#Output.[Original Interest]
,isnull(#Loan1PivotCurrent.[Principal Balance],0) + isnull(#Loan2PivotCurrent.[Principal Balance],0)
,isnull(#Loan1PivotCurrent.[Interest Balance],0) + isnull(#Loan2PivotCurrent.[Interest Balance],0)
,isnull(#Loan1PivotCurrent.[Current Principal Due],0) + isnull(#Loan2PivotCurrent.[Current Principal Due],0)
,isnull(#Loan1PivotCurrent.[Current Interest Due],0) + isnull(#Loan2PivotCurrent.[Current Interest Due],0)
,isnull(#Loan1PivotCurrent.[Late Charges Owed],0) + isnull(#Loan2PivotCurrent.[Late Charges Owed],0)			
				
having (isnull(#Loan1PivotCurrent.[Current Principal Due],0) + isnull(#Loan2PivotCurrent.[Current Principal Due],0)) > 0 or  (isnull(#Loan1PivotCurrent.[Current Interest Due],0) + isnull(#Loan2PivotCurrent.[Current Interest Due],0))>0

Order by #Output.Name


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
