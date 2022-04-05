SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [rpt].[p_Generate10YearForecastReport]
as
/***
	Author: Mike Sherman
	Date:   2014-04-15
	Desc:  Generate total amounts projected to get from all loan payments over next 10 years.
	execute GetPaymentSchedule for each user and save results in a table

	select * from rpt.TenYearForecast
	opr.p_GetPaymentSchedule 2238
***/

set nocount on

begin try

	Declare @CurrUser int

	delete from [rpt].[TenYearForecast_Log]
	insert [rpt].[TenYearForecast_Log]

	(
	UserID ,
	Processed 
	)
   select distinct 
	UserID ,
	Processed =0
   from fn.LoanCurrState c
   where c.LoanItemID = 10 and c.LoanItemAmt >0

   update rpt.TenYearForecast 
   set CurrentFlag = CurrentFlag + 1 
--************** start loop
   select @CurrUser = min (UserId) 
					FROM [rpt].[TenYearForecast_Log]
					Where Processed =0

	WHILE @CurrUser is not null
	BEGIN
			
			--insert rpt.TenYearForecast
			--	(
			--		Id, PrincipalBalance, PrincipalAmtDue, Interest, 
			--		InterestDue, TotalDue, LoanYear, PaymentDate
			--	)
			
			--exec [opr].[p_GetPaymentSchedule] 2238 @CurrUser
			exec [rpt].[p_Create10YearForecast] @CurrUser
					
			Update [rpt].[TenYearForecast_Log]
			set Processed = 1
				,ProcessedDate = getdate()
			where UserId = @CurrUser

			select @CurrUser = min (UserId) 
			FROM  [rpt].[TenYearForecast_Log] 
			Where Processed =0 and UserId > @CurrUser
	END


end try
begin catch
	--if a transaction was started, rollback
	-- select @@trancount
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
