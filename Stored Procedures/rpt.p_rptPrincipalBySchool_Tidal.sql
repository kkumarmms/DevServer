SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--ALTER SCHEMA rpt TRANSFER dbo.[rpt.PrincipalBySchool];

--exec rpt.p_rptPrincipalBySchool


CREATE PROCEDURE [rpt].[p_rptPrincipalBySchool_Tidal] 
AS
BEGIN
-- =============================================
-- Author:		Andre Barber
-- Create date: '3/24/2014'
-- Description:	Principal Balance by school for active loans Report for Student Loan System
-- TODO 
-- MSherman 3/25 for a paid off loan use LoanCurrState Principal Due is LoanItemID 1 and amount has $0
-- ASB for an active loan use LoanCurrState Principal Due is LoanItemID 1 and amount not $0
-- BWheeler 4/8/2014 for balances not zero, schools need to know what amount they can underwrite for each year
--Audit report run fiscal year end May 31,for loans with active balances
-- msh 05-2014 Cloned original proc to output to a table for use in a historical reports.
-- =============================================

	SET NOCOUNT ON;

	
	
	begin try	
	
	
		WITH data (UserID,Principal) as
				(
		    		select distinct fn.Loans.UserID					
					  ,sum(fn.LoanCurrState.LoanItemAmt)
					
				FROM  fn.LoanCurrState INNER JOIN
					  fn.Loans ON fn.LoanCurrState.LoanID = fn.Loans.LoanID INNER JOIN					
					  fn.LoanItems ON fn.LoanCurrState.LoanItemID = fn.LoanItems.LoanItemID 
				WHERE fn.Loans.PayFlag<>'X'  and (fn.LoanItems.LoanItemID = 10) AND (fn.LoanCurrState.LoanItemAmt <> 0)	
				group by fn.Loans.UserID		  
				--WHERE (fn.LoanItems.LoanItemID = 10) AND (fn.LoanCurrState.LoanItemAmt <> 0)									  
			) 
			INSERT INTO [rpt].[PrincipalBySchool]
           ([Count of Accounts]
           ,[Sum of Principal Balance]
           ,[School]
           )
			SELECT 'Count of Accounts' = Count( act.UserInfo.UserID)
					,'Sum of Principal Balance' = Sum(Principal)
					
					,'School'=(select case act.UserInfo.InstitutionID when 36 then 'T'
		    																 when 37 then 'H'
		    																 when 38 then 'B'
		    																 when 39 then 'M'
		    																 end)
			FROM data inner join act.UserInfo ON data.UserId = act.UserInfo.UserID 
			INNER JOIN opr.Institution ON opr.Institution.InstitutionID = act.UserInfo.InstitutionID 
			group by act.UserInfo.InstitutionID;
			
	

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
