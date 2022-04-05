SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--exec [p_rptMonthlyMaster] 




--705	638	7522.91	59
--705	1689	6692.41	70
--734	639	6065.74	33
--734	1690	6124.01	48
--785	1712	6169.76	28
--807	1737	6066.10	19
--828	1762	6094.79	23
--855	691	6092.00	19
--855	1911	6141.40	23
--857	1912	6141.43	21
--867	1913	6022.27	25
--871	1914	5905.63	20
--904	717	2312.00	15
--904	1937	3944.34	95
--904	3120	2312.00	15
--904	3817	3944.34	95


--select userid,loanid,SUM(appliedamt),COUNT(userid)
--from fn.loanpaymentapply
--group by userid,loanid
--order by userid

--exec [p_rptMonthlyMaster] 

--drop table #account
--drop table #Loan1
--drop table #Loan2
--drop table #Loan1pivot
--drop table #Loan2pivot
--drop table #Loan1pivotTotals
--drop table #Loan2pivotTotals
CREATE PROCEDURE [dbo].[p_rptMonthlyMasterOLD] 
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
-- =============================================

	SET NOCOUNT ON;


create table #Account
			([Account Number] int			
			,Name varchar(150)
			,[Address] varchar(150)
			,CityStateZIP varchar(100)
			,School  varchar(100)
			,GraduationYear int
			,LoanID1 int
			,DateOfLoan1 datetime
			,OriginalPrincipal1 decimal(9,2)
			,OriginalInterest1 decimal(9,2)
			,PrincipalPaid1 decimal(9,2)
			,InterestPaid1 decimal(9,2)
			,LoanID2 int
			,DateOfLoan2 datetime
			,OriginalPrincipal2 decimal(9,2)
			,OriginalInterest2 decimal(9,2)
			,PrincipalPaid2 decimal(9,2)
			,InterestPaid2 decimal(9,2)
			
			)
			
--SELECT [LoanPaymentScheduleID]
--      ,[MMSLoanID]  
--      ,[PrincipalAmtDue]
--      ,[InterestAmtDue]
--  FROM [SLAP].[dbo].[LoanPaymentSchedule]
--  where LoanYear=255

	create table #Loan1
				([Account Number] int	
				,LoanID1   int
				,Loan1	int	
				,Date1 datetime		
				,Principal1 decimal(9,2)
				,Interest1 decimal(9,2)
				,LoanItemDescr varchar(50)
				,PaymentDate1 datetime
				,PaymentCode1 varchar(16)
				,BatchNo1 varchar(16)
				,ItemAmtPaid decimal(9,2)
				,PrincipalDue1 decimal(9,2)
				,InterestDue1 decimal(9,2)
				  ,[Contract Schedule ID] int
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
				,LoanItemDescr varchar(50)
				,PaymentDate2 datetime
				,PaymentCode2 varchar(16)
				,BatchNo2 varchar(16)
				,ItemAmtPaid decimal(9,2)
				,PrincipalDue2 decimal(9,2)
				,InterestDue2 decimal(9,2)	
			      ,[Contract Schedule ID] int
				  ,[Contract Loan ID] int
				  ,[Contract Principal] decimal(9,2)
				  ,[Contract Interest] decimal(9,2) 											
				)						
				
Create table #Loan1Pivot
([Account Number] int,LoanID int
,Date1 datetime,Principal1 decimal(9,2),Interest1 decimal(9,2)
,[PrincipalPaidToDate]  decimal(9,2),[Principal Overdue]  decimal(9,2),[InterestPaidToDate]  decimal(9,2),[Interest Overdue]  decimal(9,2),[Late fee]  decimal(9,2),[Late fee Interest]  decimal(9,2),[Returned Check fee]  decimal(9,2),[Prepaid Penalty]  decimal(9,2))
--,[Contract Schedule ID] int, [Contract Loan ID] int , [Contract Principal] decimal(9,2),  [Contract Interest] decimal(9,2), LoanID1 int,Loan1 int
--,PaymentDate1 datetime,PaymentCode1 varchar(16),BatchNo1 varchar(16)
				
Create table #Loan1PivotTotals
([Account Number] int,LoanID int,LoanDate datetime,			OriginalPrincipal1 decimal(9,2)
			,OriginalInterest1 decimal(9,2)
,[PrincipalPaidToDate]  decimal(9,2),[InterestPaidToDate]  decimal(9,2))

Create table #Loan2PivotTotals
([Account Number] int,LoanID int,LoanDate datetime,			OriginalPrincipal2 decimal(9,2)
			,OriginalInterest2 decimal(9,2)
,[PrincipalPaidToDate]  decimal(9,2),[InterestPaidToDate]  decimal(9,2))
			
Create table #Loan2Pivot
([Account Number] int,LoanID int
,Date2 datetime,Principal2 decimal(9,2),Interest2 decimal(9,2)
,[PrincipalPaidToDate]  decimal(9,2),[Principal Overdue]  decimal(9,2),[InterestPaidToDate]  decimal(9,2),[Interest Overdue]  decimal(9,2),[Late fee]  decimal(9,2),[Late fee Interest]  decimal(9,2),[Returned Check fee]  decimal(9,2),[Prepaid Penalty]  decimal(9,2))
--,[Contract Schedule ID] int, [Contract Loan ID] int , [Contract Principal] decimal(9,2),  [Contract Interest] decimal(9,2),LoanID2 int,Loan2 int
--,Date2 datetime,Principal2 decimal(9,2),Interest2 decimal(9,2)
--,PaymentDate2 datetime,PaymentCode2 varchar(16),BatchNo2 varchar(16)
					
	begin try
	
BEGIN



			
	Insert  #Account	
	SELECT distinct act.UserInfo.UserID
--	,l1.LoanSeqNum
--	,l2.LoanSeqNum
			,'Name' = rtrim(act.UserInfo.LastName) + ', ' + left(rtrim(act.UserInfo.FirstName) ,1)
			,''--,'Address' = ltrim(rtrim((rtrim(ISNULL(act.[Address].[Address1],'')) + ' ' + rtrim(ISNULL(act.[Address].Address2,'')))))
			,''--,'CityStateZIP' = rtrim(act.[Address].City) + ', ' + rtrim(act.[Address].[State]) + ' ' + rtrim(act.[Address].ZIP)
			,''--,'School' = opr.Institution.InstitutionName	
			,0--,'GraduationYear' = 0
			,l1.LoanID
			,NULL --DateOfLoan1		
			,0.00 -- OriginalPrincipal1 decimal(9,2)
			,0.00 -- OriginalInterest1 decimal(9,2)
			,0.00 -- PrincipalPaid1 decimal(9,2)
			,0.00 -- InterestPaid1 decimal(9,2)			
			,l2.LoanID
			,NULL --DateOfLoan2		
			,0.00 -- OriginalPrincipal2 decimal(9,2)
			,0.00 -- OriginalInterest2 decimal(9,2)
			,0.00 -- PrincipalPaid2 decimal(9,2)
			,0.00 -- InterestPaid2 decimal(9,2)			
			
	FROM  act.UserInfo INNER JOIN act.[Address] ON act.UserInfo.UserID = act.[Address].UserID					   	
					   INNER JOIN opr.Institution ON act.UserInfo.InstitutionID = opr.Institution.InstitutionID
					   full outer Join 	fn.Loans l1 on act.UserInfo.UserID = l1.UserID and l1.LoanSeqNum=1
					  full outer join 	fn.Loans l2 on act.UserInfo.UserID = l2.UserID and l2.LoanSeqNum=2					   
   --where act.UserInfo.UserID  in  (1355,2993) --and l1.LoanSeqNum<>l2.LoanSeqNum and l1.LoanID<>l2.LoanID
    
   -- select * from #account
	
	Insert into #Loan1			
				([Account Number],LoanID1,Loan1,Date1,Principal1,Interest1,LoanItemDescr,PaymentDate1,PaymentCode1,BatchNo1,ItemAmtPaid,PrincipalDue1,InterestDue1
				,[Contract Schedule ID]
				,[Contract Loan ID]
				,[Contract Principal]
				,[Contract Interest]
				)
	SELECT 	fn.Loans.UserID,fn.Loans.LoanID,fn.Loans.LoanSeqNum,fn.Loans.LoanApprovedDate
	--,fn.Loans.LoanAmt,fn.Loans.ProjectedInterest,
	, lps.[PrincipalAmtDue] as 'Contract Principal' ,lps.[InterestAmtDue] as 'Contract Interest'
	,fn.LoanItems.LoanItemDescr, fn.LoanPayment.PaymentDate, fn.LoanPayment.PaymentCode, fn.LoanPayment.BatchNo , ItemAmtPaid =sum(fn.LoanPaymentApply.AppliedAmt)
	,0,0
		,'Contract Schedule ID' = lps.[LoanPaymentScheduleID] 
			,'Contract Loan ID' = lps.[MMSLoanID]  
			,'Contract Principal' = lps.[PrincipalAmtDue] 
			,'Contract Interest' = lps.[InterestAmtDue] 		
	 FROM  fn.LoanPaymentApply  LEFT OUTER JOIN
                      fn.LoanItems ON fn.LoanPaymentApply.LoanItemID = fn.LoanItems.LoanItemID LEFT OUTER JOIN
                      fn.Loans ON fn.LoanPaymentApply.LoanID = fn.Loans.LoanID INNER JOIN
                      dbo.LoanPaymentSchedule lps ON lps.MMSLoanID = fn.Loans.MMSLoanID LEFT OUTER JOIN
                      fn.LoanPayment ON fn.LoanPaymentApply.LoanPaymentID = fn.LoanPayment.LoanPaymentID
				WHERE     (fn.LoanItems.LoanItemID IN (1,2,3,4,5,7,8,12))
			--	and fn.Loans.UserID  in  (1355,2993)
	and fn.[Loans].LoanSeqNum=1 and lps.LoanYear=255
	GROUP BY fn.Loans.UserID, fn.Loans.LoanID, fn.Loans.LoanSeqNum,
fn.Loans.LoanApprovedDate,
fn.Loans.LoanAmt,
fn.Loans.ProjectedInterest,fn.LoanItems.LoanItemDescr, fn.LoanPayment.PaymentDate, fn.LoanPayment.PaymentCode, fn.LoanPayment.BatchNo
	, lps.[LoanPaymentScheduleID] 
				,lps.[MMSLoanID]
				,lps.[PrincipalAmtDue]
				,lps.[InterestAmtDue] 




	Insert into #Loan2			
				([Account Number],LoanID2,Loan2,Date2,Principal2,Interest2,LoanItemDescr,PaymentDate2,PaymentCode2,BatchNo2,ItemAmtPaid,PrincipalDue2,InterestDue2
				,[Contract Schedule ID]
				,[Contract Loan ID]
				,[Contract Principal]
				,[Contract Interest]
				)
	SELECT 	fn.Loans.UserID,fn.Loans.LoanID,fn.Loans.LoanSeqNum,fn.Loans.LoanApprovedDate
	--,fn.Loans.LoanAmt,fn.Loans.ProjectedInterest
	, lps.[PrincipalAmtDue] as 'Contract Principal' ,lps.[InterestAmtDue] as 'Contract Interest'
	,fn.LoanItems.LoanItemDescr, fn.LoanPayment.PaymentDate, fn.LoanPayment.PaymentCode, fn.LoanPayment.BatchNo , ItemAmtPaid =sum(fn.LoanPaymentApply.AppliedAmt)
	,0,0
		,'Contract Schedule ID' = lps.[LoanPaymentScheduleID] 
			,'Contract Loan ID' = lps.[MMSLoanID]  
			,'Contract Principal' = lps.[PrincipalAmtDue] 
			,'Contract Interest' = lps.[InterestAmtDue] 		
	 FROM  fn.LoanPaymentApply  LEFT OUTER JOIN
                      fn.LoanItems ON fn.LoanPaymentApply.LoanItemID = fn.LoanItems.LoanItemID LEFT OUTER JOIN
                      fn.Loans ON fn.LoanPaymentApply.LoanID = fn.Loans.LoanID INNER JOIN
                      dbo.LoanPaymentSchedule lps ON lps.MMSLoanID = fn.Loans.MMSLoanID LEFT OUTER JOIN
                      fn.LoanPayment ON fn.LoanPaymentApply.LoanPaymentID = fn.LoanPayment.LoanPaymentID
				WHERE     (fn.LoanItems.LoanItemID IN (1,2,3,4,5,7,8,12))
			--	and fn.Loans.UserID  in  (1355,2993)
	AND fn.[Loans].LoanSeqNum=2  AND lps.LoanYear=255 
	GROUP BY fn.Loans.UserID, fn.Loans.LoanID, fn.Loans.LoanSeqNum,
fn.Loans.LoanApprovedDate,
fn.Loans.LoanAmt,
fn.Loans.ProjectedInterest,fn.LoanItems.LoanItemDescr, fn.LoanPayment.PaymentDate, fn.LoanPayment.PaymentCode, fn.LoanPayment.BatchNo 
	, lps.[LoanPaymentScheduleID] 
				,lps.[MMSLoanID]
				,lps.[PrincipalAmtDue]
				,lps.[InterestAmtDue] 


----select * from #Account
--select * from #Loan1
--select * from #Loan2

--select *  from #Loan1
INSERT #Loan1Pivot
select [Account Number] ,LoanID1 
,Date1,[Contract Principal] ,[Contract Interest] 
,[Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue],[Late fee],[Late fee Interest],[Returned Check fee],[Prepaid Penalty]
from #Loan1
			PIVOT ( 
			  SUM(ItemAmtPaid) 
			  for LoanItemDescr in ([Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue],[Late fee],[Late fee Interest],[Returned Check fee],[Prepaid Penalty])
			) as T			



--select *  from #Loan2		
INSERT #Loan2Pivot
select [Account Number],LoanID2 
 ,Date2 ,[Contract Principal] ,[Contract Interest] 
 ,[Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue],[Late fee],[Late fee Interest],[Returned Check fee],[Prepaid Penalty]
from #Loan2
			PIVOT ( 
			  SUM(ItemAmtPaid) 
			  for LoanItemDescr in ([Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue],[Late fee],[Late fee Interest],[Returned Check fee],[Prepaid Penalty])
			) as T			
			
--select * from #account
--select * from #Loan1Pivot
--select * from #Loan2Pivot
--select * from #Loan1PivotTotals 
--select * from #Loan2PivotTotals 
	
--truncate table #Loan1PivotTotals
--truncate table #Loan2PivotTotals

--select * from #Loan1PivotTotals
--select * from #Loan2PivotTotals

insert  #Loan1PivotTotals
select [Account Number],LoanID,max(Date1),max(Principal1),MAX(Interest1),SUM(isnull([PrincipalPaidToDate],0)),SUM(isnull([InterestPaidToDate],0)) 
from #Loan1Pivot 
group by [Account Number],LoanID
		
insert  #Loan2PivotTotals
select [Account Number],LoanID,max(Date2),max(Principal2),MAX(Interest2),SUM(isnull([PrincipalPaidToDate],0)),SUM(isnull([InterestPaidToDate],0)) 
from #Loan2Pivot 
group by [Account Number],LoanID

			



update #account
set DateofLoan1=l1pt.LoanDate
, OriginalPrincipal1=l1pt.OriginalPrincipal1
,OriginalInterest1=l1pt.OriginalInterest1
,PrincipalPaid1=l1pt.PrincipalPaidToDate
,InterestPaid1=l1pt.InterestPaidToDate
from #Loan1PivotTotals l1pt,#account a
where a.[Account Number]=l1pt.[Account Number]
and a.[loanid1]=l1pt.[loanid]

update #account
set DateofLoan2=l2pt.LoanDate
, OriginalPrincipal2=l2pt.OriginalPrincipal2
,OriginalInterest2=l2pt.OriginalInterest2
,PrincipalPaid2=l2pt.PrincipalPaidToDate
,InterestPaid2=l2pt.InterestPaidToDate
from #Loan2PivotTotals l2pt,#account a
where a.[Account Number]=l2pt.[Account Number]
and a.[loanid2]=l2pt.[loanid]

select [Account Number]
, Name
,LoanID1
,case isdate(DateOfLoan1) WHEN 1 Then convert(varchar(10),DateOfLoan1,101) else '' END as DateOfLoan1
,case isnull(LoanID2,1) WHEN 1 then '' else CONVERT(varchar(10),LoanID2)  END as LoanID2
,case isdate(DateOfLoan2) WHEN 1 Then convert(varchar(10),DateOfLoan2,101) else '' END as DateOfLoan2

,[Original Principal] = isnull(OriginalPrincipal1,0) + isnull(OriginalPrincipal2,0)
,[Principal Paid to Date] = isnull(PrincipalPaid1,0) + isnull(PrincipalPaid2,0)
,[Principal Balance] = 0
,[Original Interest] = isnull(OriginalInterest1,0) + isnull(OriginalInterest2,0)
,[Interest Paid to Date] = isnull(InterestPaid1,0) + isnull(InterestPaid2,0)
,[Interest Balance] = 0
,[Current Principal Due] = 0
,[Current Interest Due] = 0
,[Current Amount Due] = 0
,[Late Charges Owed] = 0
,[Outstanding Balance] = 0
from #account
where ISNULL([Account Number],'')<>'' and Name>'z'
order by Name


--select [Account Number],
--*
--from #account
--where ISNULL([Account Number],'')<>'' and Name>'z'
--order by Name


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
