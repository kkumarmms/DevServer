SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--[rpt].[p_Create10YearForecast] @UserId=2775, @CurrDate='2007-10-31',@PrincipalBalance=4000
--[fn].[p_GetLoanSummary] 2238
CREATE PROCEDURE [rpt].[p_Create10YearForecast]-- @UserId=2238, @CurrDate='2007-10-31',@PrincipalBalance=4000
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
	Desc: Proc populates base  table rpt.TenYearForecast 
			to calculate 10 Year forcast. 
			It is a clone of	getpaymentSchedule 
			Calculates payment schedule for the student based on the current Amount owed
			this proc is called from  [rpt].[Generate10YearForecast] which loops through all active loans
***/

set nocount on

begin try

--First get summary info
--begin tran

--declare @userid int = 2775
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
	 ,[Year of loan] int
	 ,[Total Financial Charges Paid]  [decimal](9, 2) NULL
	 ,[Total Due]  [decimal](9, 2) NULL
	 ,[TotalOverDue]  [decimal](9, 2) NULL
	 ,[Total Fees]  [decimal](9, 2) NULL
	 ,[Total]  [decimal](9, 2) NULL
 )
 
 insert @TmpUsrCurrState
 select * from [fn].[fn_GetLoanSummary] ( @UserId )
 
  --select * from @TmpUsrCurrState

  

-- calc payment schedule
exec [fn].[p_GetBasePaymentSchedule] @UserId
--select * from Schedule_stage


declare @CurrBalance decimal(9,2)
declare @TotalDue decimal(9,2)
declare @TotalFinCharges decimal(9,2)
  select 
	  @TotalDue = sum([Total Due]),
	  @PrincipalBalance = Sum(Balance),
	  @TotalFinCharges = Sum([Late fee]) + Sum([Late fee Interest]) + Sum([Returned Check fee]) 
  from @TmpUsrCurrState

select @CurrBalance = @PrincipalBalance
--declare @CurrDate datetime
select @CurrDate = isnull (@CurrDate,getdate())
--*************************************************************
-- re-calculate payment schedule
-- First generate new schedule if balance is greater than scheduled

declare @NextSchedBalance decimal(9,2)
declare @minID int


select @minId = min(ID)
from dbo.schedule_stage s
where PaymentDate > @CurrDate

-----select @minId

select @NextSchedBalance = s.PrincipalBalance
from dbo.schedule_stage s
where id = @minID
------select @NextSchedBalance NextSchedBalance

if @CurrBalance > @NextSchedBalance
begin
	-- first for in pay schedule should reflect all past due amounts
			insert rpt.TenYearForecast
				(
					Id, PrincipalBalance, PrincipalAmtDue, Interest, 
					InterestDue, TotalDue, LoanYear, PaymentDate
				)
			
	select  UserID,
			PrincipalBalance= @CurrBalance, 
			PrincipalAmtDue= s.PrincipalAmtDue + @CurrBalance - @NextSchedBalance, 
			s.Interest, 
			InterestDue = @CurrBalance * s.Interest / 100,
			TotalDue = (s.PrincipalAmtDue + @CurrBalance - @NextSchedBalance)	--pricipalAmount Due
						 + @CurrBalance * s.Interest / 100,						--InterestDue
			s.LoanYear, 
			s.PaymentDate

	from dbo.schedule_stage s
	where id = @minID

	UNION ALL
	-- all other rows except first in pay schedule do not depend on current state of the loan and past due amounts
	-- it is a projected amounts
	select  UserID,
			PrincipalBalance= s.PrincipalBalance,
			PrincipalAmtDue=s.PrincipalAmtDue, 
			s.Interest, 
			InterestDue = s.InterestAmtDue,
			TotalDue = s.TotalAmtDue, 
			s.LoanYear, 
			s.PaymentDate

	from dbo.schedule_stage s
	where id > @minID
end

else
begin
--*************************************************************
-- re-calculate payment schedule - step 2
-- Now generate new schedule if balance is less than scheduled
declare @OverPayment decimal (9,2) 
select @OverPayment =  @NextSchedBalance - @CurrBalance 
--select @OverPayment OverPayment
			insert rpt.TenYearForecast
				(
					Id, PrincipalBalance, PrincipalAmtDue, Interest, 
					InterestDue, TotalDue, LoanYear, PaymentDate
				)
			
	select  UserID,
			PrincipalBalance= s.PrincipalBalance - @OverPayment , 
			PrincipalAmtDue= case when (s.PrincipalBalance - @OverPayment) > s.PrincipalAmtDue then s.PrincipalAmtDue else s.PrincipalBalance - @OverPayment end,
			s.Interest, 
			InterestDue = (s.PrincipalBalance - @OverPayment) * s.Interest / 100,
			TotalDue =	 case when (s.PrincipalBalance - @OverPayment) > s.PrincipalAmtDue then s.PrincipalAmtDue else s.PrincipalBalance - @OverPayment end + 
						(s.PrincipalBalance - @OverPayment) * s.Interest / 100,
			s.LoanYear, 
			s.PaymentDate
--select *
	from dbo.schedule_stage s
	where id >= @minID 
	and (s.PrincipalBalance - @OverPayment) >=0


end

--commit tran
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
	Return (-1)
end catch





GO
