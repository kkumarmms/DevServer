SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




--exec [p_rptMonthlyBilling] 3 ,2014

CREATE PROCEDURE [rpt].[p_rptMonthlyBilling] 
(@Month int,@Year int)
AS
BEGIN
-- =============================================
-- Author:		Andre Barber
-- Create date: '3/24/2014'
-- Description:	Monthly Billing Report for Month of @Month Student Laon System
-- TODO @Month criteria for month of fn.LoanCurrState table current snapshot for SLAP_Source was for March
--verified 2782 Brevil SLAP_Source
-- msh 2021-03-31 added column "School" Jira DBA-4269
-- =============================================

	SET NOCOUNT ON;

	begin try

		
			WITH data (UserID,LastName,FirstName,LoanItemDescr,School,ItemAmt) as
				(
				SELECT     act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName, fn.LoanItems.LoanItemDescr, opr.Institution.LegacyCode,ItemAmt =sum(fn.LoanCurrState.LoanItemAmt) 
				FROM         act.UserInfo INNER JOIN
									  fn.LoanCurrState ON act.UserInfo.UserID = fn.LoanCurrState.UserId INNER JOIN
									  fn.LoanItems ON fn.LoanCurrState.LoanItemID = fn.LoanItems.LoanItemID LEFT  JOIN	 
									  opr.Institution on act.UserInfo.InstitutionID =  opr.Institution.InstitutionID
				WHERE     (fn.LoanItems.LoanItemID IN (1,2,3,4,5,7,8,10,11,12))
				GROUP BY act.UserInfo.UserID, act.UserInfo.LastName,act.UserInfo.FirstName,  fn.LoanItems.LoanItemDescr, opr.Institution.LegacyCode
				) 
			SELECT UserID,'Name' = LastName + ', ' + FirstName, School ,[Principal Balance],[Interest Balance],'Principal Due'=isnull([Principal Due],0)+isnull([Principal Overdue],0) ,'Interest Due'=isnull([Interest Due],0)+isnull([Interest Overdue],0),'Late Charges'=isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0),'Total Due'=isnull([Principal Due],0)+isnull([Principal Overdue],0)+isnull([Interest Due],0)+isnull([Interest Overdue],0)+isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0)
			--[Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue],[Late Fee]
			FROM data
			PIVOT ( 
			  SUM(ItemAmt) 
			  for LoanItemDescr in ([Principal Balance],[Interest Balance],[Principal Due],[Principal Overdue],[Interest Due],[Interest Overdue],[Late Fee],[Late fee Interest],[Returned Check fee],[Prepaid Penalty])
			) as T
			WHERE isnull([Principal Due],0)+isnull([Principal Overdue],0)+isnull([Interest Due],0)+isnull([Interest Overdue],0)+isnull([Late Fee],0)+isnull([Late fee Interest],0)+isnull([Returned Check fee],0)+isnull([Prepaid Penalty],0) > 0
			ORDER BY Name
			
		

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
