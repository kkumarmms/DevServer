SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--opr.p_GetPaymentSchedule @UserId=2238, @CurrDate='2007-10-31',@PrincipalBalance=4000
-- opr.p_GetPaymentScheduleHeader @UserId= 3000
--[fn].[p_GetLoanSummary] 2238
CREATE PROCEDURE [opr].[p_GetPaymentScheduleHeader] --@UserId=2238, @CurrDate='2007-10-31',@PrincipalBalance=4000
	@UserId int,
	@CurrDate date = null,
	@PrincipalBalance decimal(9,2) = null,
	@pastDueInterest decimal(9,2) = null,
	@LoanYear int = null,
	@FinCharge decimal(9,2) = null

as
/***
	Author: Mike Sherman
	Date:   2014-02-14
	Desc:  Get Payment Schedule header info. Need to check amount due and special arrangement flags
			2014-05-13 -msh added two fields to temp table to match changes in p_getLoanSummary. Also changed [Total Due} --> [Total]
			2015-12-03 msh  added 10 days payoff calculation and current interest percentage
			2016-05-24 added 		isnull(@CurrentInterestPercentage,0) in the last select

	[opr].[p_GetPaymentScheduleHeader] @UserId=3263
	[fn].[p_GetLoanSummary] 3263
***/

set nocount on

begin try
 --declare @userID int
 --set @userID = 3361

declare @TotalRepaymentPending decimal(9,2)
declare @CurrBalance decimal(9,2)
declare @TotalInterestDue decimal(9,2)
declare @TotalDue decimal(9,2)
declare @TotalOverDue decimal(9,2)
declare @NextAmountDue decimal(9,2)
declare @TotalPrincipalBal decimal(9,2)
declare @TotalFinCharges decimal(9,2)
declare @PayArrangementFlag bit
declare @PayArrangementAmt decimal (9,2)
declare @DelayedPayStartDate datetime
declare @NextAmountDueDate datetime
declare @NextOverDueDate datetime
declare @InvoiceNum int
declare @YearOfLoan int
declare @CurrentInterestPercentage int
--First get summary info

declare @TmpUsrCurrState table 

(
	  userID int
	 ,LoanApprovedDate [datetime]  NULL
	 ,Loan2ApprovedDate [datetime]  NULL
	 ,LoanLastPaymentDate  [datetime]  NULL
	 ,[Stop Late Fee] [decimal](9, 2) NULL
	 ,[LoanID] Int
	 ,[LoanAmt] [decimal](9, 2) NULL
	 ,[PayStatus] Char(1)
	 ,[Comments] varchar(7000)
	 ,[Projected Interest]  [decimal](9, 2) NULL
	 ,[LoanSeqNum] int
	 ,[LegacySchedCode] char(1)
	 ,[Principal Due]  [decimal](9, 2) NULL
	 ,[Principal Overdue]  [decimal](9, 2) NULL
	 ,[Interest Due]  [decimal](9, 2) NULL
	 ,[Interest Overdue]  [decimal](9, 2) NULL
	 ,[Late fee]  [decimal](9, 2) NULL
	 ,[Late fee Interest]  [decimal](9, 2) NULL
	 ,[Returned Check fee]  [decimal](9, 2) NULL
	 ,[Prepaid Penalty]  [decimal](9, 2) NULL
	 ,[Balance]  [decimal](9, 2) NULL
	 ,[Principal Paid to date]  [decimal](9, 2) NULL
	 ,[Interest paid to date]  [decimal](9, 2) NULL
	 ,[YearOfLoan] int
	 ,[Total Financial Charges Paid]  [decimal](9, 2) NULL
	 ,[Total Due]  [decimal](9, 2) NULL
	 ,[TotalOverDue]  [decimal](9, 2) NULL
	 ,[TotalFees]  [decimal](9, 2) NULL
	 ,[Total]  [decimal](9, 2) NULL	 
 )
 
 insert @TmpUsrCurrState
 exec [fn].[p_GetLoanSummary] @UserId

  --select * from @TmpUsrCurrState

  
  -- Determine next due date. If Total_Due >0 and not paid by 6/30 then it is end of current month. need to check special arrangements in user table
select 
	@PayArrangementFlag =	u.PayArrangementFlag ,
	@PayArrangementAmt =	u.PayArrangementAmt,
	@DelayedPayStartDate =	u.DelayedPayStartDate
from act.UserInfo u
WHERE u.UserID = @UserId

  select 

	@NextAmountDue = sum(cs.[Total Due]), 		--2014-05-13 -msh  changed [Total Due} --> [Total]
	@TotalRepaymentPending = -1,			--10 days payoff amount is equal to principal balance + any interest or overdue interest due + any late fees currently due
	@NextAmountDueDate = '1/1/1900',		--need confirmation
	@TotalDue = sum(cs.[Total]),
	@TotalPrincipalBal = Sum(cs.Balance),
	@TotalFinCharges = Sum(cs.[Late fee]) + Sum(cs.[Late fee Interest]) + Sum(cs.[Returned Check fee]) + sum (cs.[Prepaid Penalty]) ,
 	@TotalOverDue = sum(cs.[TotalOverDue]),
	@YearOfLoan = max(cs.YearOfLoan),
	@TotalInterestDue = sum(cs.[Interest Due]) + sum(cs.[Interest Overdue])
  from @TmpUsrCurrState cs 

  --Get 10 days payoff amount 
   select 	@TotalRepaymentPending = @TotalPrincipalBal + @TotalInterestDue + @TotalFinCharges 			--10 days payoff amount is equal to principal balance + any interest or overdue interest due + any late fees currently due

  --Get Current Interest percentage from Oldest loan
	SELECT @CurrentInterestPercentage = sch.Interest 
	FROM			@TmpUsrCurrState cs
		inner join	fn.Loans l					on cs.LoanID = l.LoanID
		inner join	dbo.LoanPaymentSchedule sch on l.MMSLoanID = sch.MMSLoanID and cs.YearOfLoan = sch.LoanYear
	WHERE 
		--cs.LoanSeqNum = 1 
		sch.LoanYear = @YearOfLoan


  --select @PayArrangementFlag, @PayArrangementAmt, @DelayedPayStartDate, @NextAmountDue, @TotalRepaymentPending, @NextAmountDueDate, @TotalDue, @TotalDue, @TotalPrincipalBal, @TotalFinCharges

-- check next payment date and next amount due if special agreement exist

-- new billing cicle. First payment due 6/30
	if @TotalDue >0 and (Month(getdate()) =5 or Month(getdate()) =6)  
		set	@NextAmountDueDate = convert(date, '06/30/'+ convert(char(4),year(getdate())))

-- payment past due
	if @TotalDue > 0 and (month (getdate()) <5 or month (getdate()) >6)  
		set	@NextAmountDueDate = DATEADD(d,-1,DATEADD(month, DATEDIFF(month,0,GETDATE())+1,0))  --last day of current month

 -- if special arrangements
	if @PayArrangementFlag = 1
		select		@NextAmountDue		= isnull(@PayArrangementAmt,@NextAmountDue), 
					@NextAmountDueDate	= isnull(@DelayedPayStartDate,@NextAmountDueDate)

-- if paid in full
	if  @TotalDue =0 
		select		@NextAmountDue		= 0, 
					@TotalDue =0,
					@NextAmountDueDate	=	case 
												when  Month(getdate()) <5 
												then convert(date, '06/30/'+ convert(char(4),year(getdate())))
												else convert(date, '06/30/'+ convert(char(4),year(getdate())+1))
											end
-- if New Loan
	if  @YearOfLoan = 0 
		select		@NextAmountDueDate	=	case 
												when  Month(getdate()) <5 
												then convert(date, '06/30/'+ convert(char(4),year(getdate())))
												else convert(date, '06/30/'+ convert(char(4),year(getdate())+1))
											end
  -- get latest invoice number from invoice table

  SELECT @InvoiceNum = InvoiceID
  FROM fn.invoices
  WHERE UserID = @UserId and
		InvoiceCurrentFlag = 0

  SELECT @InvoiceNum = isnull(@InvoiceNum ,-1)
  --Final Output 
  set @NextOverDueDate = @NextAmountDueDate

  if  month(getdate())=5
  set @NextOverDueDate = '5/31/' + convert (char(4),year(getdate()))

  if  exists (select userid from fn.loans where userid = @UserId)
	BEGIN
	  select 
		NextAmountDue =			@NextAmountDue,					
		TotalRepaymentPending = @TotalRepaymentPending,			--need confirmation
		NextAmountDueDate =		@NextAmountDueDate,		
		NextOverDueDate =		@NextOverDueDate,			
		TotalDue =				@TotalDue,
		TotalOverDue =			@TotalOverDue,
		PrincipalBalance =		@TotalPrincipalBal,
		TotalFinCharges =		@TotalFinCharges,
		InvoiceNumber =			@InvoiceNum, 
		YearOfLoan =			@YearOfLoan,
		InterestPercentage =	isnull(@CurrentInterestPercentage,0),
		TotalInterestDue =		@TotalInterestDue
	END


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
