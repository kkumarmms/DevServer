SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





--exec [p_rptNewLoans] '','2/1/2014','2/28/2014'

--exec [p_rptNewLoans] 'B','2/1/2014','2/28/2014'


CREATE PROCEDURE [rpt].[p_rptNewLoans] 
(@School char(1)
,@FromDate date
,@ToDate date)
AS
BEGIN
-- =============================================
-- Author:		Andre Barber
-- Create date: '3/24/2014'
-- Description:	New Loans Report for Student Loan System
-- TODO StartDate to EndDate criteria for month of [fn].[Loans] table current snapshot for SLAP_Source was for old data and data missing TODO and @FromDate @ToDate
-- Column fn.Loans.[ProjectedInterest] missing data for report 'Interest" column
-- =============================================

	SET NOCOUNT ON;

	if ((ISNULL(@FromDate,'')='') or (ISNULL(@ToDate,'')=''))
		BEGIN
			SET @FromDate = DATEADD(m,-1,GetDate())	
			SET @ToDate = GetDate()
		END
	
	begin try	
	
		--All schools	
		if (LEN(RTRIM(@School))>0)
			SELECT 
				  'Account Number'=act.UserInfo.UserID  
				  ,'Name'=rtrim(act.UserInfo.LastName) + ', ' + rtrim(act.UserInfo.FirstName)  
				  ,'School'=upper(opr.Institution.LegacyCode)      
				  ,'Loan Date'=fn.Loans.[LoanApprovedDate]
				  ,'Loan Number'=fn.Loans.LoanSeqNum
				  ,'Principal'=fn.Loans.[LoanAmt]
				  ,'Interest'=fn.Loans.[ProjectedInterest]
				  ,'Balance Outstanding'=isnull(fn.Loans.[LoanAmt],0) + isnull(fn.Loans.[ProjectedInterest],0)			  
			FROM         opr.Institution INNER JOIN
								  act.UserInfo ON opr.Institution.InstitutionID = act.UserInfo.InstitutionID RIGHT OUTER JOIN
								  fn.Loans ON act.UserInfo.UserID = fn.Loans.UserID
			WHERE @School=upper(opr.Institution.LegacyCode)   					  
			AND ((@FromDate <= fn.Loans.[LoanApprovedDate]) AND (fn.Loans.[LoanApprovedDate] <= @ToDate))
			ORDER BY 'Name'
		--Specific schools	
		else if (LEN(RTRIM(@School))=0)
			
			SELECT 
				  'Account Number'=act.UserInfo.UserID  
				  ,'Name'=rtrim(act.UserInfo.LastName) + ', ' + rtrim(act.UserInfo.FirstName)  
				  ,'School'=upper(opr.Institution.LegacyCode)      
				  ,'Loan Date'=fn.Loans.[LoanApprovedDate]
				  ,'Loan Number'=fn.Loans.LoanSeqNum
				  ,'Principal'=fn.Loans.[LoanAmt]
				  ,'Interest'=fn.Loans.[ProjectedInterest]
				  ,'Balance Outstanding'=isnull(fn.Loans.[LoanAmt],0) + isnull(fn.Loans.[ProjectedInterest],0)			  
			FROM         opr.Institution INNER JOIN
								  act.UserInfo ON opr.Institution.InstitutionID = act.UserInfo.InstitutionID RIGHT OUTER JOIN
								  fn.Loans ON act.UserInfo.UserID = fn.Loans.UserID	
			WHERE --(LEN(RTRIM(opr.Institution.LegacyCode))=0)				  		
			 ((@FromDate <= fn.Loans.[LoanApprovedDate]) AND (fn.Loans.[LoanApprovedDate] <= @ToDate))
			ORDER BY opr.Institution.LegacyCode,'Name'
			
			
			
			
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
