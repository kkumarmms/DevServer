SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



--exec [rpt].[p_rptAccountPaymentHistory] 2238
--exec [rpt].[p_rptAccountPaymentHistory] 2285
--exec [rpt].[p_rptAccountPaymentHistory] 2267


--drop table #account
--drop table #Loan1
--drop table #Loan2
--drop table #Loan1pivot
--drop table #Loan2pivot

CREATE PROCEDURE [rpt].[p_rptAccountPaymentHistory] --2284
(@AccountNumber int)
AS
BEGIN
-- =============================================
-- Author:		Andre Barber
-- Create date: '3/24/2014'
-- Description:	Account Payment History Report for Student Loan System
-- MODIFIED
-- ASB 05292014 include 10 Principal Balance for principal paid in loans
-- =============================================

SET NOCOUNT ON;

create table #Account
			([Account Number] int			
			,Name varchar(150)
			,[Address] varchar(150)
			,CityStateZIP varchar(100)
			,School  varchar(100)
			,GraduationYear int
			)
			


create table #Loan1
			([Account Number] int	
			,LoanID1   int
			,Loan1	int	
			,Date1 datetime		
			,Principal1 decimal(9,2)
			,Interest1 decimal(9,2)
			,AmountPaid1 decimal(9,2)
			,LoanItemDescr varchar(50)
			,PaymentDate1 datetime
			,PaymentCode1 varchar(16)
			,BatchNo1 varchar(16)
			,ItemAmtPaid decimal(9,2)
			,PrincipalDue1 decimal(9,2)
			,InterestDue1 decimal(9,2)
			  ,[Contract Schedule ID] char(1)
			  ,[Contract Loan ID] int
			  ,[Contract Principal] decimal(9,2)
			  ,[Contract Interest] decimal(9,2) 				
			)	

create table #Loan2
			([Account Number] int	
			,LoanID2   int
			,Loan2	int	
			,Date2 datetime		
			,Principal2 decimal(9,2)
			,Interest2 decimal(9,2)
			,AmountPaid2 decimal(9,2)
			,LoanItemDescr varchar(50)
			,PaymentDate2 datetime
			,PaymentCode2 varchar(16)
			,BatchNo2 varchar(16)
			,ItemAmtPaid decimal(9,2)
			,PrincipalDue2 decimal(9,2)
			,InterestDue2 decimal(9,2)	
		      ,[Contract Schedule ID] char(1)
			  ,[Contract Loan ID] int
			  ,[Contract Principal] decimal(9,2)
			  ,[Contract Interest] decimal(9,2) 											
			)						
				
Create table #Loan1Pivot
([Account Number] int,[Contract Schedule ID] char(1), [Contract Loan ID] int , [Contract Principal] decimal(9,2),  [Contract Interest] decimal(9,2), LoanID1 int,Loan1 int,Date1 datetime,Principal1 decimal(9,2),Interest1 decimal(9,2),AmountPaid1 decimal(9,2),PaymentDate1 datetime,PaymentCode1 varchar(16),BatchNo1 varchar(16),[Principal Due]  decimal(9,2),[Principal Balance]  decimal(9,2),[Principal Overdue]  decimal(9,2),[Interest Due]  decimal(9,2),[Interest Overdue]  decimal(9,2),[Late fee]  decimal(9,2),[Late fee Interest]  decimal(9,2),[Returned Check fee]  decimal(9,2),[Prepaid Penalty]  decimal(9,2))

			
Create table #Loan2Pivot
([Account Number] int,[Contract Schedule ID] char(1), [Contract Loan ID] int , [Contract Principal] decimal(9,2),  [Contract Interest] decimal(9,2),LoanID2 int,Loan2 int,Date2 datetime,Principal2 decimal(9,2),Interest2 decimal(9,2),AmountPaid2 decimal(9,2),PaymentDate2 datetime,PaymentCode2 varchar(16),BatchNo2 varchar(16),[Principal Due]  decimal(9,2),[Principal Balance]  decimal(9,2),[Principal Overdue]  decimal(9,2),[Interest Due]  decimal(9,2),[Interest Overdue]  decimal(9,2),[Late fee]  decimal(9,2),[Late fee Interest]  decimal(9,2),[Returned Check fee]  decimal(9,2),[Prepaid Penalty]  decimal(9,2))
					
BEGIN TRY
	
BEGIN

			
	INSERT  #Account	
	SELECT act.UserInfo.UserID
			,'Name' = rtrim(act.UserInfo.FirstName) + ' ' + rtrim(act.UserInfo.LastName) + ' ' + RTRIM(ISNULL(act.UserInfo.Title,''))
			,'Address' = ltrim(rtrim((rtrim(ISNULL(act.[Address].[Address1],'')) + ' ' + rtrim(ISNULL(act.[Address].Address2,'')))))
			,'CityStateZIP' = rtrim(act.[Address].City) + ', ' + rtrim(act.[Address].[State]) + ' ' + rtrim(act.[Address].ZIP)
			,'School' = opr.Institution.InstitutionName	
			,'GraduationYear' = act.UserInfo.GraduationYear					
	FROM  act.UserInfo INNER JOIN act.[Address] ON act.UserInfo.UserID = act.[Address].UserID					   	
			   INNER JOIN opr.Institution ON act.UserInfo.InstitutionID = opr.Institution.InstitutionID
        WHERE act.UserInfo.UserID = @AccountNumber    
    
	
	INSERT into #Loan1			
		([Account Number],LoanID1,Loan1,Date1,Principal1,Interest1,AmountPaid1,LoanItemDescr,PaymentDate1,PaymentCode1,BatchNo1,ItemAmtPaid,PrincipalDue1,InterestDue1
		,[Contract Schedule ID]
		,[Contract Loan ID]
		,[Contract Principal]
		,[Contract Interest]
		)
	SELECT 	fn.Loans.UserID,fn.Loans.LoanID,fn.Loans.LoanSeqNum,fn.Loans.LoanApprovedDate,fn.Loans.LoanAmt,fn.Loans.ProjectedInterest,fn.LoanPayment.TotalPaidAmt,
	fn.LoanItems.LoanItemDescr, fn.LoanPayment.PaymentDate, fn.LoanPayment.PaymentCode, fn.LoanPayment.BatchNo , ItemAmtPaid =sum(fn.LoanPaymentApply.AppliedAmt)
	,0,0
	,'Contract Schedule ID' = opr.MMSLoans.LegacySchedCode
	,'Contract Loan ID' = lps.[MMSLoanID]  
	,'Contract Principal' = lps.[PrincipalAmtDue] 
	,'Contract Interest' = lps.[InterestAmtDue] 		
	FROM  fn.LoanPaymentApply  LEFT OUTER JOIN
	      fn.LoanItems ON fn.LoanPaymentApply.LoanItemID = fn.LoanItems.LoanItemID LEFT OUTER JOIN
	      fn.Loans ON fn.LoanPaymentApply.LoanID = fn.Loans.LoanID INNER JOIN
	      opr.MMSLoans ON opr.MMSLoans.MMSLoanID = fn.Loans.MMSLoanID INNER JOIN
	      dbo.LoanPaymentSchedule lps ON lps.MMSLoanID = fn.Loans.MMSLoanID LEFT OUTER JOIN
	      fn.LoanPayment ON fn.LoanPaymentApply.LoanPaymentID = fn.LoanPayment.LoanPaymentID
	WHERE     (fn.LoanItems.LoanItemID IN (1,2,3,4,5,7,8,10,12))
		AND fn.[Loans].UserID = @AccountNumber 
		and fn.[Loans].LoanSeqNum=1 and lps.LoanYear=255
	GROUP BY fn.Loans.UserID, fn.Loans.LoanID, fn.Loans.LoanSeqNum,
		 fn.Loans.LoanApprovedDate,fn.Loans.LoanAmt,fn.Loans.ProjectedInterest,fn.LoanPayment.TotalPaidAmt,fn.LoanItems.LoanItemDescr, fn.LoanPayment.PaymentDate, fn.LoanPayment.PaymentCode, fn.LoanPayment.BatchNo,
		 opr.MMSLoans.LegacySchedCode,lps.[MMSLoanID],lps.[PrincipalAmtDue],lps.[InterestAmtDue] 




	INSERT into #Loan2			
		([Account Number],LoanID2,Loan2,Date2,Principal2,Interest2,AmountPaid2,LoanItemDescr,PaymentDate2,PaymentCode2,BatchNo2,ItemAmtPaid,PrincipalDue2,InterestDue2
		,[Contract Schedule ID]
		,[Contract Loan ID]
		,[Contract Principal]
		,[Contract Interest]
		)
	SELECT 	fn.Loans.UserID,fn.Loans.LoanID,fn.Loans.LoanSeqNum,fn.Loans.LoanApprovedDate,fn.Loans.LoanAmt,fn.Loans.ProjectedInterest,fn.LoanPayment.TotalPaidAmt,
	fn.LoanItems.LoanItemDescr, fn.LoanPayment.PaymentDate, fn.LoanPayment.PaymentCode, fn.LoanPayment.BatchNo , ItemAmtPaid =sum(fn.LoanPaymentApply.AppliedAmt)
	,0,0
	,'Contract Schedule ID' = opr.MMSLoans.LegacySchedCode
	,'Contract Loan ID' = lps.[MMSLoanID]  
	,'Contract Principal' = lps.[PrincipalAmtDue] 
	,'Contract Interest' = lps.[InterestAmtDue] 		
	FROM  fn.LoanPaymentApply  LEFT OUTER JOIN
	      fn.LoanItems ON fn.LoanPaymentApply.LoanItemID = fn.LoanItems.LoanItemID LEFT OUTER JOIN
	      fn.Loans ON fn.LoanPaymentApply.LoanID = fn.Loans.LoanID INNER JOIN
	      opr.MMSLoans ON opr.MMSLoans.MMSLoanID = fn.Loans.MMSLoanID INNER JOIN
	      dbo.LoanPaymentSchedule lps ON lps.MMSLoanID = fn.Loans.MMSLoanID LEFT OUTER JOIN
	      fn.LoanPayment ON fn.LoanPaymentApply.LoanPaymentID = fn.LoanPayment.LoanPaymentID
	WHERE     (fn.LoanItems.LoanItemID IN (1,2,3,4,5,7,8,10,12))
		AND fn.[Loans].UserID =@AccountNumber
		AND fn.[Loans].LoanSeqNum=2  AND lps.LoanYear=255 
	GROUP BY fn.Loans.UserID, fn.Loans.LoanID, fn.Loans.LoanSeqNum,
		fn.Loans.LoanApprovedDate,fn.Loans.LoanAmt,fn.Loans.ProjectedInterest,fn.LoanPayment.TotalPaidAmt,fn.LoanItems.LoanItemDescr, fn.LoanPayment.PaymentDate, fn.LoanPayment.PaymentCode, fn.LoanPayment.BatchNo ,
		opr.MMSLoans.LegacySchedCode,lps.[MMSLoanID],lps.[PrincipalAmtDue],lps.[InterestAmtDue] 


--select * from #Account
--select * from #Loan1
--select * from #Loan2



	INSERT #Loan1Pivot
	SELECT [Account Number],[Contract Schedule ID],[Contract Loan ID],[Contract Principal],[Contract Interest] ,LoanID1 ,Loan1 ,Date1 ,Principal1 ,Interest1,AmountPaid1 ,PaymentDate1 ,PaymentCode1 ,BatchNo1 ,[Principal Due],[Principal Balance],[Principal Overdue],[Interest Due],[Interest Overdue],[Late fee],[Late fee Interest],[Returned Check fee],[Prepaid Penalty]
	FROM #Loan1
				PIVOT ( 
				  SUM(ItemAmtPaid) 
				  for LoanItemDescr in ([Principal Due],[Principal Balance],[Principal Overdue],[Interest Due],[Interest Overdue],[Late fee],[Late fee Interest],[Returned Check fee],[Prepaid Penalty])
				) as T			


	INSERT #Loan2Pivot
	SELECT [Account Number],[Contract Schedule ID],[Contract Loan ID],[Contract Principal],[Contract Interest] ,LoanID2 ,Loan2 ,Date2 ,Principal2 ,Interest2,AmountPaid2 ,PaymentDate2 ,PaymentCode2 ,BatchNo2 ,[Principal Due],[Principal Balance],[Principal Overdue],[Interest Due],[Interest Overdue],[Late fee],[Late fee Interest],[Returned Check fee],[Prepaid Penalty]
	FROM #Loan2
				PIVOT ( 
				  SUM(ItemAmtPaid) 
				  for LoanItemDescr in ([Principal Due],[Principal Balance],[Principal Overdue],[Interest Due],[Interest Overdue],[Late fee],[Late fee Interest],[Returned Check fee],[Prepaid Penalty])
				) as T			

--select * from #Loan1Pivot
--select * from #Loan2Pivot

--OUTPUT
	SELECT distinct 'SortDate' = isnull(l1p.PaymentDate1,l2p.PaymentDate2),			
		a.[Account Number]
		,l1p.[Contract Schedule ID] as 'Schedule1'
		,l1p.[Contract Loan ID] as 'LoanID1'
		,l1p.[Contract Principal] as 'Principal1'
		,l1p.[Contract Interest] as 'Interest1'
		,l1p.[AmountPaid1] as 'AmountPaid1'
		,l2p.[Contract Schedule ID] as 'Schedule2'
		,l2p.[Contract Loan ID] as 'LoanID2'
		,l2p.[Contract Principal] as 'Principal2'
		,l2p.[Contract Interest] as 'Interest2'		
		,l2p.[AmountPaid2] as 'AmountPaid2'
		,Name =''--a.Name
		,[Address]=''--,a.[Address] 
		,CityStateZIP=''--,a.CityStateZIP
		,School=''--,a.School  
		,GraduationYear=0--,a.GraduationYear 
		 ,convert(varchar(10),isnull(l1p.Date1,''),101) as 'Date1' ,l1p.PaymentDate1 ,l1p.PaymentCode1 ,l1p.BatchNo1 ,isnull(l1p.[Principal Due],0) + isnull(l1p.[Principal Balance],0)  + isnull(l1p.[Principal Overdue],0) as 'Loan1Principal',isnull(l1p.[Interest Due],0) + isnull(l1p.[Interest Overdue],0) as 'Loan1Interest', isnull(l1p.[Late fee],0)  + isnull(l1p.[Late fee Interest],0)  + isnull(l1p.[Returned Check fee],0)  + isnull(l1p.[Prepaid Penalty],0) as 'Loan1LateCharges'
		 ,convert(varchar(10),isnull(l2p.Date2,''),101) as 'Date2' ,l2p.PaymentDate2 ,l2p.PaymentCode2 ,l2p.BatchNo2 ,isnull(l2p.[Principal Due],0) + isnull(l2p.[Principal Balance],0)  + isnull(l2p.[Principal Overdue],0) as 'Loan2Principal',isnull(l2p.[Interest Due],0) + isnull(l2p.[Interest Overdue],0) as 'Loan2Interest', isnull(l2p.[Late fee],0)  + isnull(l2p.[Late fee Interest],0)  + isnull(l2p.[Returned Check fee],0)  + isnull(l2p.[Prepaid Penalty],0) as 'Loan2LateCharges'
	FROM #Loan1Pivot l1p full outer join #Loan2Pivot l2p on l1p.[Account Number]=l2p.[Account Number] and l1p.PaymentDate1=l2p.PaymentDate2
		cross join #account a 
		order by sortdate asc



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
