SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--
--exec opr.p_GetPaymentSchedule @UserId=2522 , @CurrDate='2014-08-20',@PrincipalBalance=4000

--[fn].[p_GetLoanSummary] 2522
CREATE PROCEDURE [opr].[p_GetPaymentSchedule_WithGap] --@UserId=2522, @CurrDate='2007-10-31',@PrincipalBalance=4000
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
	Desc:  Calculates payment schedule for the student based on the current Amount owed
		2014-04-22 - mod to get schedule for loan year > 11
		2014-05-06 - mod to split first line for overdue payment amounts
		2014-05-13 -msh added two fields to temp table to match changes in p_getLoanSummary. Also chanched [Total Due} --> [Total]
		2015-05-21 -msh new logic needed to seperate full due payment and overpayments in May and June
		2015-06-05 - msh  changed code for "All other Months" to reference payment schedule table
		2021-02-21 - msh fixed bug in calculating future scheduled payments when "Overpayment" exists
		2021-02-25 - msh added (@minId -1) to get current billing year on the schedule when "Overpayment" exists and id >= case when MONTH(@CurrDate) = 6 then @minID +1 else @minid end
[opr].[p_GetPaymentSchedule] @UserId=2593, @CurrDate='2015-07-21',@PrincipalBalance=9700
select * from [fn].[LoanCurrState] where   UserId=2593
***/

set nocount on

begin try

--select 'a'
--First get summary info
--begin tran

--declare @userid int = 2522,@PrincipalBalance decimal(9,2) = null, @CurrDate date
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
	 ,[TotalFees]  [decimal](9, 2) NULL
	 ,[Total]  [decimal](9, 2) NULL
 )
 
 insert @TmpUsrCurrState
 exec [fn].[p_GetLoanSummary] @UserId
 
  

-- calc payment schedule
exec [fn].[p_GetBasePaymentSchedule_WithGap] @UserId

select @CurrDate = isnull (@CurrDate,getdate())

declare @EndOfCurrMonth Date
    SET @EndOfCurrMonth =	CONVERT( VARCHAR(4),YEAR(@CurrDate)) + '/' + 
							CONVERT( VARCHAR(4),MONTH(@CurrDate)) + '/01'
    SET @EndOfCurrMonth = DATEADD(DD, -1, DATEADD(M, 1, @EndOfCurrMonth))

declare @CurrBalance decimal(9,2)
declare @TotalDue decimal(9,2)
declare @TotalPrincipalDue decimal(9,2)
declare @TotalInterestDue decimal(9,2)
declare @TotalOverDue decimal(9,2)
declare @TotalPrincipalOverDue decimal(9,2)
declare @TotalInterestOverDue decimal(9,2)
declare @TotalFinCharges decimal(9,2)
  select 
	  @TotalDue = sum([Total]), --msh changed 2012-05-13
	  @TotalOverDue = sum(TotalOverDue),
	  @TotalPrincipalDue = sum([Principal due]),
	  @TotalPrincipalOverDue = sum([Principal Overdue]),
  	  @TotalInterestDue = sum([Interest due]),
  	  @TotalInterestOverDue = sum([Interest Overdue]),
	  @PrincipalBalance = Sum(Balance),
	  @TotalFinCharges = Sum([Late fee]) + Sum([Late fee Interest]) + Sum([Returned Check fee]) + Sum([Prepaid Penalty]) 
  from @TmpUsrCurrState






select @CurrBalance = @PrincipalBalance
--declare @CurrDate datetime

--*************************************************************
-- re-calculate payment schedule
-- First generate new schedule if balance is greater than scheduled

declare @NextSchedBalance decimal(9,2)
declare @minID int


select @minId = min(ID)  -- -1  -- added "-1" on 2014-04-21 need to show current year where paymentdate was 06/30/2013
--select *
from dbo.schedule_stage s
where PaymentDate >= @CurrDate

--select @minId

select @NextSchedBalance = s.PrincipalBalance
from dbo.schedule_stage s
where id = @minID
------select @NextSchedBalance NextSchedBalance

if @CurrBalance >= @NextSchedBalance and @minID is not null

begin
--select 'b'
--**************Changed to split DUE and OVERDUE amounts for the first year**************

	IF MONTH(@CurrDate) =5
	 -- need to split line in May only. All other time it should be a combined amt
	BEGIN
	--select 'c'
		if @TotalOverDue >0
		BEGIN
		--select 'd'
			select  
					ID,
					PrincipalBalance= @CurrBalance, 
					PrincipalAmtDue= @TotalPrincipalOverDue, 
					Interest=0,--s.Interest, 
					InterestDue = @TotalInterestOverDue,
					TotalOtherFees = @TotalFinCharges,
					TotalDue = @TotalFinCharges + @TotalPrincipalOverDue				--pricipalAmount OverDue
								 + @TotalInterestOverDue,						--Interest OverDue
					LoanYear=s.LoanYear -1, 
					PaymentDate = @EndOfCurrMonth
					--SELECT *
			from dbo.schedule_stage s
			where id = @minID	

			UNION
			select  
					ID,
					PrincipalBalance= s.PrincipalBalance, 
					PrincipalAmtDue=s.PrincipalAmtDue, 
					Interest=s.Interest, 
					InterestDue =  @CurrBalance * s.Interest / 100,
					TotalOtherFees = 0,
					TotalDue = s.PrincipalAmtDue + @CurrBalance * s.Interest / 100, 
					s.LoanYear, 
					s.PaymentDate

			from dbo.schedule_stage s
			where id = @minID				
			UNION
			select  
					ID,
					PrincipalBalance= s.PrincipalBalance, 
					PrincipalAmtDue=s.PrincipalAmtDue, 
					Interest=s.Interest, 
					InterestDue = s.InterestAmtDue,
					TotalOtherFees = 0,
					TotalDue = s.TotalAmtDue, 
					s.LoanYear, 
					s.PaymentDate

			from dbo.schedule_stage s
			where id > @minID	
			order by PaymentDate		
		END

		ELSE -- no total overdue
		BEGIN
		--select 'e'
				select  ID,
			PrincipalBalance= @CurrBalance, 
			PrincipalAmtDue= @TotalPrincipalDue + @TotalPrincipalOverDue, 
			s.Interest, 
			InterestDue = @TotalInterestDue + @TotalInterestOverDue,
			TotalOtherFees = @TotalFinCharges,
			TotalDue = @TotalFinCharges +@TotalPrincipalDue + @TotalPrincipalOverDue	--pricipalAmount Due
						 + @TotalInterestDue + @TotalInterestOverDue,						--InterestDue
			s.LoanYear, 
			PaymentDate = case when @TotalDue > 0 then @EndOfCurrMonth else s.PaymentDate end

			from dbo.schedule_stage s
			where id = @minID

			Union

			select  
			ID,
			PrincipalBalance= s.PrincipalBalance, 
			PrincipalAmtDue=s.PrincipalAmtDue, 
			s.Interest, 
			InterestDue = s.InterestAmtDue,
			TotalOtherFees = 0,
			TotalDue = s.TotalAmtDue, 
			s.LoanYear, 
			PaymentDate = s.PaymentDate

			from dbo.schedule_stage s
			where id > @minid 
			order by PaymentDate

		END
	
	END
	
	ELSE -- all other month except May
	BEGIN
	--select 'f'


				select  ID,
			PrincipalBalance= @CurrBalance, 
			PrincipalAmtDue= @TotalPrincipalDue + @TotalPrincipalOverDue, 
			s.Interest, 
			InterestDue = @TotalInterestDue + @TotalInterestOverDue,
			TotalOtherFees = @TotalFinCharges,
			TotalDue = @TotalFinCharges +@TotalPrincipalDue + @TotalPrincipalOverDue	--pricipalAmount Due
						 + @TotalInterestDue + @TotalInterestOverDue,						--InterestDue
			s.LoanYear, 
			PaymentDate = case when @TotalDue > 0 then @EndOfCurrMonth else s.PaymentDate end

			from dbo.schedule_stage s
			where id = @minID-1
		Union
		select  
			ID,
			PrincipalBalance= s.PrincipalBalance, 
			PrincipalAmtDue=s.PrincipalAmtDue, 
			s.Interest, 
			InterestDue = s.InterestAmtDue,
			TotalOtherFees = 0,
			TotalDue = s.TotalAmtDue, 
			s.LoanYear, 
			PaymentDate = s.PaymentDate
--select *
			from dbo.schedule_stage s
			where id >= case when MONTH(@CurrDate) = 6 then @minID +1 else @minid end
			order by PaymentDate 
		--END
	END
	
--************* END split DUE and OVERDUE amounts for the first year*****************


	--UNION ALL
	---- all other rows except first in pay schedule do not depend on current state of the loan and past due amounts
	---- it is a projected amounts
	--select  ID,

	--		PrincipalBalance= s.PrincipalBalance, 
	--		PrincipalAmtDue=s.PrincipalAmtDue, 
	--		s.Interest, 
	--		InterestDue = s.InterestAmtDue,
	--		TotalOtherFees = 0,
	--		TotalDue = s.TotalAmtDue, 
	--		s.LoanYear, 
	--		s.PaymentDate

	--from dbo.schedule_stage s
	--where id > @minID
end

else  ---critera -  @CurrBalance < @NextSchedBalance and @minID is not null
	if @minID is not null
	begin
	--select 'g'
		--*************************************************************
		-- re-calculate payment schedule - step 2
		-- Now generate new schedule if balance is less than scheduled
		-- msh 20150520  we need to differentiate full payment due and overpayment. In May and June full payment was considered as overpayment

		-- patch for May and June. Need to take @NextSchedBalance from "Next"year in case of full payment
		IF (MONTH(@CurrDate) =5 or  MONTH(@CurrDate) =6) and @TotalDue =0
		BEGIN
		--select 'h'
			select @NextSchedBalance = s.PrincipalBalance
			from dbo.schedule_stage s
			where id = @minID +1
			--select @NextSchedBalance

			declare @OverPayment decimal (9,2) 
			select @OverPayment =  @NextSchedBalance - @CurrBalance 
			--select @OverPayment OverPayment
			select  ID,
					PrincipalBalance= @CurrBalance,--@NextSchedBalance , msh 2015-06-07
					PrincipalAmtDue= @TotalPrincipalDue,
					s.Interest, 
					InterestDue = @TotalInterestDue,
					TotalOtherFees = @TotalFinCharges,
					TotalDue =	 @TotalDue,
					s.LoanYear, 
					s.PaymentDate

			from dbo.schedule_stage s
			where id = @minID 
			and (s.PrincipalBalance - @OverPayment) >=0
		
			UNION

			select  ID,
					--s.PrincipalBalance,
					PrincipalBalance= s.PrincipalBalance - @OverPayment , 
					--s.PrincipalAmtDue, 
					PrincipalAmtDue= case when (s.PrincipalBalance - @OverPayment) > s.PrincipalAmtDue then s.PrincipalAmtDue else s.PrincipalBalance - @OverPayment end,
					s.Interest, 
					--s.InterestAmtDue,
					InterestDue = (s.PrincipalBalance - @OverPayment) * s.Interest / 100,
					--s.TotalAmtDue, 
					TotalOtherFees = @TotalFinCharges,
					TotalDue =	 case when (s.PrincipalBalance - @OverPayment) > s.PrincipalAmtDue then s.PrincipalAmtDue else s.PrincipalBalance - @OverPayment end + 
								(s.PrincipalBalance - @OverPayment) * s.Interest / 100,
					s.LoanYear, 
					s.PaymentDate

			from dbo.schedule_stage s
			where id > @minID 
			and (s.PrincipalBalance - @OverPayment) >=0
			order by s.PaymentDate
		END
		ELSE
		BEGIN  --all other months
		--select 'I'
			--declare @OverPayment decimal (9,2) 
			select @OverPayment =  @NextSchedBalance - @CurrBalance 
			--select @OverPayment OverPayment,@NextSchedBalance, @CurrBalance
			select  ID,
					PrincipalBalance= @CurrBalance,--@NextSchedBalance , msh 2015-06-07
					PrincipalAmtDue= @TotalPrincipalDue,
					s.Interest, 
					InterestDue = @TotalInterestDue,
					TotalOtherFees = @TotalFinCharges,
					TotalDue =	 @TotalDue,
					s.LoanYear, 
					s.PaymentDate

			from dbo.schedule_stage s
			where id = @minID -1 --msh 2021-02-25 added  -1 to get current billing year on the schedule
			and (s.PrincipalBalance - @OverPayment) >=0
			UNION
			select  ID,
					PrincipalBalance= s.PrincipalBalance - @OverPayment ,
					PrincipalAmtDue= case when (s.PrincipalBalance - @OverPayment) > s.PrincipalAmtDue then s.PrincipalAmtDue else s.PrincipalBalance - @OverPayment end,
					s.Interest,
					InterestDue = (s.PrincipalBalance - @OverPayment) * s.Interest / 100,
					TotalOtherFees = @TotalFinCharges,
					TotalDue =	 case when (s.PrincipalBalance - @OverPayment) > s.PrincipalAmtDue then s.PrincipalAmtDue else s.PrincipalBalance - @OverPayment end + 
								(s.PrincipalBalance - @OverPayment) * s.Interest / 100,
					s.LoanYear, 
					s.PaymentDate		

			from dbo.schedule_stage s
			where id >= case when MONTH(@CurrDate) = 6 then @minID +1 else @minid end   --msh 2021-02-25 added  -1 to get current billing year on the schedule
			and (s.PrincipalBalance - @OverPayment) >=0

		END

	end

	ELSE
	BEGIN
	--select 'J'
		--*************************************************************
		--*************************************************************
		--          Now We Need to add a row for loans that passed 11 year cycle.
		--			In this case all amounts due should be shown on the first record
		SELECT 
			 PrincipalBalance	=	@PrincipalBalance  
			,PrincipalAmtDue	=	@PrincipalBalance 
			,Interest			=	6
			,InterestDue		=	sum([Interest Due] +[Interest Overdue])
			,TotalOtherFees		=	@TotalFinCharges
			,TotalDue			=	@TotalDue
			,LoanYear			=	max([Year of loan])
			,PaymentDate		=	@EndOfCurrMonth    --convert(date, '6/30/'+convert(char(4),year(getdate())))
		FROM @TmpUsrCurrState
	END

--IF @minID is null and @TotalDue > 0
--BEGIN
--	SELECT 
--		 PrincipalBalance	=	@PrincipalBalance  
--		,PrincipalAmtDue	=	@PrincipalBalance 
--		,Interest			=	sum([Interest Due] +[Interest Overdue])
--		,InterestDue		=	sum([Interest Due] +[Interest Overdue])
--		,TotalOtherFees		=	@TotalFinCharges
--		,TotalDue			=	@TotalDue
--		,LoanYear			=	max([Year of loan])
--		,PaymentDate		=	convert(date, '6/30/'+convert(char(4),year(getdate())))
--	FROM @TmpUsrCurrState
--END


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
