SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [fn].[p_GenerateNewInvoiceOneUser]
	@UserID int
as
/***
	Author: Mike Sherman
	Date:   
	Desc:  generates new invoice for one user. Need logic to prevent repeating same invoices

	2014-05-21	msh added four fields to the final update to deal with special arrangements
	2015-10-19 msh Per Bill's request, set TotalOverDue = isnull([Principal Overdue],0)	+isnull([Interest Overdue],0). remove late fees from overdue

***/

set nocount on

begin try

BEGIN TRAN
-- generate invoices
	delete from fn.Invoices_Stage

	insert fn.Invoices_Stage
	(
		UserID, 
		LoanApprovedDate,
		Loan2ApprovedDate, 
		LoanLastPaymentDate, 
		StopLateFee, 
		LoanID, 
		LoanAmt, 
		PayFlag, 
		Comments, 
		ProjectedInterest, 
		LoanSeqNum, 
		LegacySchedCode, 
		PrincipalDue, 
		PrincipalOverdue, 
		InterestDue, 
		InterestOverdue, 
		Latefee, 
		LateFeeInterest, 
		ReturnedCheckFee, 
		PrepaidPenalty, 
		Balance, 
		PrincipalPaidTotal, 
		InterestPaidTotal, 
		YearOfLoan, 
		FinancialChargesPaidTotal, 
		TotalDue, 
		TotalOverDue,
		TotalPrincipalDue,
		TotalFees
	)
	 select 
 UserID 
 ,LoanApprovedDate
 ,Loan2ApprovedDate = case when [LoanSeqNum] = 2 then LoanApprovedDate else null end
 ,LoanLastPaymentDate
 ,isnull([Stop Late Fee],0) [Stop Late Fee]
 ,[LoanID]
 ,[LoanAmt]
 ,PayFlag
 ,isnull([Comments],'') [Comments]
 ,[InterestAmtDue] [Projected Interest]
 ,[LoanSeqNum]
 ,[LegacySchedCode]
 ,isnull([Principal Due],0) [Principal Due]
 ,isnull([Principal Overdue],0) [Principal Overdue]
 ,isnull([Interest Due],0) [Interest Due]
 ,isnull([Interest Overdue],0) [Interest Overdue]
 ,isnull([Late fee],0) [Late fee]
 ,isnull([Late fee Interest],0) [Late fee Interest]
 ,isnull([Returned Check fee],0) [Returned Check fee]
 ,isnull([Prepaid Penalty],0) [Prepaid Penalty]
 ,isnull(([LoanAmt] - isnull([Principal Paid to date],0)),0) [Balance]
 ,isnull([Principal Paid to date],0) [Principal Paid to date]
 ,isnull([Interest paid to date],0) [Interest paid to date]
 ,convert(int,isnull([Year of loan],0)) [Year of loan]
 ,isnull([Total Financial Charges Paid],0) [Total Financial Charges Paid]
 ,TotalDue =  isnull([Principal Due],0)
				+isnull([Principal Overdue],0)
				+isnull([Interest Due],0)
				+isnull([Interest Overdue],0)
				+isnull([Late fee],0)
				+isnull([Late fee Interest],0)
				+isnull([Returned Check fee],0)
				+isnull([Prepaid Penalty],0)
	 ,TotalOverDue = isnull([Principal Overdue],0)
					+isnull([Interest Overdue],0)
					/* 20151019 removed per Bill's request
					+isnull([Late fee],0)
					+isnull([Late fee Interest],0)
					+isnull([Returned Check fee],0)
					+isnull([Prepaid Penalty],0)
					*/
	 ,TotalPrincipalDue = isnull([Principal due],0)
					+isnull([Principal Overdue],0)
	 ,TotalFees	   = isnull([Late fee],0)
					+isnull([Late fee Interest],0)
					+isnull([Returned Check fee],0)
					+isnull([Prepaid Penalty],0)
 FROM  (
		SELECT 
			c.UserId,
			c.LoanID,
			l.LoanSeqNum,
			i.LoanItemDescr,
			c.LoanItemAmt,
			l.LoanApprovedDate,
			l.LoanLastPaymentDate,
			l.LoanAmt,
			l.PayFlag,
			l.Comments,
			s.InterestAmtDue,
			mms.LegacySchedCode
			--select *
		FROM 
		 [fn].[LoanCurrState] c
		inner join fn.Loans l					on c.LoanID = l.LoanID
		inner join [fn].[LoanItems] i			on c.LoanItemID = i.LoanItemID
		inner join dbo.LoanPaymentSchedule s on l.MMSLoanID = s.MMSLoanID
		inner join opr.MMSLoans mms		on mms.MMSLoanID = l.MMSLoanID
		where	s.LoanYear = 255 and c.UserId = @UserID
		) p
	PIVOT
	 (
	 Sum (LoanItemAmt)
	 FOR LoanItemDescr
	 IN (   

		 [Principal Due]
		 ,[Principal Overdue]
		 ,[Interest Due]
		 ,[Interest Overdue]
		 ,[Late fee]
		 ,[Late fee Interest]
		 ,[Stop Late Fee]
		 ,[Returned Check fee]
		 ,[Prepaid Penalty]
		 ,[Principal Balance]
		 ,[Principal Paid to date]
		 ,[Interest paid to date]
		 ,[Year of loan]
		 ,[Total Financial Charges Paid]
		 )
	 ) AS pvt;
 
	

---- 	delete entries with no amount due
	delete from fn.Invoices_Stage
	where TotalDue =0

	update i 
	set InvoiceCurrentFlag = InvoiceCurrentFlag +1 
	--select *
	from fn.Invoices i
	Where i.UserID = @UserID


	
	INSERT INTO fn.Invoices
           (InvoiceCurrentFlag
           ,UserID
           ,LoanApprovedDate
           ,Loan2ApprovedDate
           ,LoanLastPaymentDate
           ,StopLateFee
           ,LoanAmt
           ,PayFlag
           ,Comments
           ,ProjectedInterest
           ,PrincipalDue
           ,PrincipalOverdue
           ,InterestDue
           ,InterestOverdue
           ,Latefee
           ,LateFeeInterest
           ,ReturnedCheckFee
           ,PrepaidPenalty
           ,Balance
           ,PrincipalPaidTotal
           ,InterestPaidTotal
           ,YearOfLoan
           ,FinancialChargesPaidTotal
           ,TotalDue
		   ,TotalOverDue
			,TotalPrincipalDue
			,TotalFees
		   )
	select 
			InvoiceCurrentFlag = 0
           ,i.UserID
           ,LoanApprovedDate =		min(LoanApprovedDate)
           ,Loan2ApprovedDate =		min(Loan2ApprovedDate)
           ,LoanLastPaymentDate =	max (LoanApprovedDate)
           ,StopLateFee =			max (StopLateFee)
           ,LoanAmt =				sum (LoanAmt)
           ,PayFlag=				min (PayFlag)
           ,Comments= ''
           ,ProjectedInterest =		sum (ProjectedInterest)
           ,PrincipalDue=			sum (PrincipalDue)
           ,PrincipalOverdue=		sum (PrincipalOverdue)
           ,InterestDue=			sum (InterestDue)
           ,InterestOverdue=		sum (InterestOverdue)
           ,Latefee=				sum (Latefee)
           ,LateFeeInterest=		sum (LateFeeInterest)
           ,ReturnedCheckFee=		sum (ReturnedCheckFee)
           ,PrepaidPenalty=			sum (PrepaidPenalty)
           ,Balance=				sum (Balance)
           ,PrincipalPaidTotal=		sum (PrincipalPaidTotal)
           ,InterestPaidTotal=		sum (InterestPaidTotal)
           ,YearOfLoan=				min (YearOfLoan)
           ,FinancialChargesPaidTotal=sum (FinancialChargesPaidTotal)
           ,TotalDue=				sum (TotalDue)
		   ,TotalOverDue =			sum(TotalOverDue)
		   ,TotalPrincipalDue =		sum(TotalPrincipalDue)
		   ,TotalFees =				sum(TotalFees)
	from fn.Invoices_Stage i
	where i.userid = @UserID
	group by UserID


	-- UPDATE lOAN2 APPROVED DATE FOR USERS WITH TWO LOANS

	--UPDATE i 
	--SET Loan2ApprovedDate = s.Loan2ApprovedDate
	--FROM			fn.Invoices i 
	--	inner join	fn.Invoices_Stage s on i.UserID = s.UserID and s.LoanSeqNum = 2

	-- POPULATE ADDRESS AND SCHOOL INFO and Special arrangements

	update inv 
	set Email					= u.Email
		,FirstName				= u.FirstName
		,LastName				= u.LastName
		,MiddleInitial			= u.MiddleInitial
		,Title					= u.title
		,InstitutionName		= s.InstitutionName
		,DoNotSendInvoiceFlag	= u.DoNotSendInvoiceFlag
		,Address1				= a.Address1
		,Address2				= a.Address2
		,City					= a.City
		,State					= a.State
		,Zip					= a.Zip
		,Country				= a.Country	
		,PayArrangementFlag		= u.PayArrangementFlag
		,PayArrangementAmt		= u.PayArrangementAmt
		,DelayedPayStartDate	= u.DelayedPayStartDate
		,PayArrangementComment	= u.PayArrangementComment
	--select inv.*
	from			fn.Invoices inv
		inner join	fn.Invoices_stage i on i.UserID = inv.UserID
		inner join	act.UserInfo u on u.UserID = i.UserID
		inner join	act.Address a on a.UserID = u.UserId and a.AdrCode = 'S' and a.AdrFlag = 0
		inner join	opr.Institution s on s.InstitutionID = u.InstitutionID
	where inv.InvoiceCurrentFlag = 0 
			and  i.userid = @UserID

COMMIT TRAN	
end try
begin catch
	--if a transaction was started, rollback
	if @@trancount > 0
	begin
		rollback tran
	end
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
	Return (-1)
end catch

GO
