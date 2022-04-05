SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






--exec [rpt].[p_rptMonthlyMaster] 


--drop table #Output
--drop table #LoanPivotPaidTotals
--drop table #LoanPivotCurrentTotals
--drop table #Loan1
--drop table #Loan2

CREATE PROCEDURE [rpt].[p_rptMonthlyMaster_ByMonth] 
	@RunDate datetime
AS
BEGIN
-- =============================================
-- Author:		Mike Sherman
-- Create date: '2/9/2021'
-- Description:	Account Payment History Report for Student Loan System. Historical data by month
 -- EXEC [rpt].[p_rptMonthlyMaster_ByMonth] '2020-06-01'
-- =============================================

	SET NOCOUNT ON;
BEGIN TRY

set @RunDate = dateadd(Month,1,@RunDate)

SELECT 
	[Acct], 
	[Name], 
	[Date Of Loan1] = convert(date,[Date Of Loan1]), 
	[Date Of Loan2] = convert(date,[Date Of Loan2]), 
	[Original Principal], 
	[Principal Paid to Date], 
	[Principal Balance], 
	[Original Interest], 
	[Interest Paid to Date], 
	[Current Principal Due], 
	[Current Interest Due], 
	[Late Charges Owed], 
	[DateCreated]

FROM [rpt].[MonthlyMaster]
WHERE CONVERT (DATE, [DateCreated]) = @RunDate


END TRY
BEGIN CATCH
		
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

END CATCH

END







GO
