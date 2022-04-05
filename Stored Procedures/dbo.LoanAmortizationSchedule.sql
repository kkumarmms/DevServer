SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[LoanAmortizationSchedule] --'107990.00','18.5','36','2011-07-01'
@Loan decimal(12,2), 
@InterestRate FLOAT, 
@PeriodInMonths FLOAT, 
@PaymentStartDate SMALLDATETIME
AS
BEGIN
SET NOCOUNT ON

DECLARE 

@Payment decimal(12,2), 
@Period FLOAT, 

/*** CALCULATED PROCEDURAL VARIABLES ***/ 

@Payment2 decimal(12,2), 
@TotalPayment decimal(12,2), 
@FinanceCharges FLOAT, 
@CompoundingPeriod FLOAT, 
@CompoundingInterest FLOAT, 

/*** CALCULATED LOAN VARIABLES ***/ 

@CurrentBalance decimal(12,2), 
@Principal FLOAT, 
@Interest FLOAT, 

/*** Loan TIME VARIABLES ***/ 


@LoanPaymentEndDate SMALLDATETIME, 
@LoanPayDate SMALLDATETIME, 
@LoanDueDate SMALLDATETIME 



/*** USER VARIABLES ***/ 

SET @InterestRate = @InterestRate/100 
SET @CompoundingPeriod = 12 
--SET @Loan = 107990.00 
--SET @PeriodInMonths = 36 
--SET @PaymentStartDate = '2011-07-01' 
/*** END USER VARIABLES ***/ 

SET @CompoundingInterest = @InterestRate/@CompoundingPeriod 
SET @Payment = ROUND(( ((@InterestRate/12) * @Loan)/
						(1-(POWER((1 + (@InterestRate/12)),(-1 * @PeriodInMonths))))),2) 
SET @TotalPayment = @Payment * @PeriodInMonths 
SET @FinanceCharges = @TotalPayment - @Loan 

IF EXISTS(SELECT object_id FROM tempdb.sys.objects WHERE name LIKE '#Schedule%') 
BEGIN 
	DROP TABLE #SCHEDULE 
END 

CREATE TABLE #SCHEDULE 
	( 
	PERIOD INT 
	,PAYDATE SMALLDATETIME 
	,PAYMENT decimal(12,2) 
	,CURRENT_BALANCE decimal(12,2) 
	,INTEREST decimal(12,2) 
	,PRINCIPAL decimal(12,2) 
	) 

SET @Period = 1 
SET @LoanPaymentEndDate = DATEADD(month,@PeriodInMonths,@PaymentStartDate) 
SET @LoanPayDate = @PaymentStartDate 
BEGIN 
	WHILE (@Period < = @PeriodInMonths) 
	BEGIN 
	SET @CurrentBalance = ROUND ( 
			@Loan * POWER((1+ @CompoundingInterest) , @Period ) - 
			((ROUND(@Payment,2)/@CompoundingInterest) * 
			(POWER((1 + @CompoundingInterest),@Period ) - 1)),0) 

	SET @Principal = 
		CASE 
		WHEN @Period = 1 
		THEN ROUND((ROUND(@Loan,0) - ROUND(@CurrentBalance,0)),0) 

		ELSE ROUND 
				((	SELECT ABS(ROUND(CURRENT_BALANCE,0) - ROUND(@CurrentBalance,0)) 
					FROM #SCHEDULE 
					WHERE PERIOD = @Period -1),2) 

		END 

	SET @Interest = ROUND(ABS(ROUND(@Payment,2) - ROUND(@Principal,2)),2) 
	SET @LoanDueDate = @LoanPayDate 

	INSERT #SCHEDULE
		(
		PERIOD, 
		PAYDATE, 
		PAYMENT, 
		CURRENT_BALANCE, 
		INTEREST, 
		PRINCIPAL
		) 

	SELECT 
		@Period, 
		@LoanDueDate, 
		@Payment, 
		@CurrentBalance, 
		@Interest, 
		@Principal 

	SET @Period = @Period + 1 
	SET @LoanPayDate = DATEADD(MM,1,@LoanPayDate) 

	END 

END 

SELECT * FROM #SCHEDULE 
END
GO
