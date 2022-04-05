SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [rpt].[p_rptMonthlyBilling_ByMonth]
(@Month int,@Year int)
AS
BEGIN
-- =============================================
-- Author:		Mike Sherman
-- Create date: '2/16/2021'
-- Description:	Monthly Billing Report for Month of @Month Student Laon System
-- selects data from cumulative archive table rpt.MonthlyBilling
-- exec [rpt].[p_rptMonthlyBilling_ByMonth] 6,2020
-- =============================================

	SET NOCOUNT ON;

	begin try
		declare @RunDate as Date
		set @RunDate = Convert(date,convert(char(4),@Year) + '-'+ right('0' + convert(varchar(2),@Month),2) + '-'+ '01')
		SELECT 
			[UserID], 
			[Name], 
			[Principal Balance], 
			[Interest Balance], 
			[Principal Due], 
			[Interest Due], 
			[Late Charges], 
			[Total Due], 
			[DateInserted]
		FROM rpt.MonthlyBilling
		where EOMONTH(DateInserted) = EOMONTH(@RunDate)
		order by [Name]

		

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
		return(-1)
	end catch

END









GO
