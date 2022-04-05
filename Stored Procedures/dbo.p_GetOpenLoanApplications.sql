SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[p_GetOpenLoanApplications]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 03/09/2015
-- Description:	get still open loan applications
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			SELECT     app.Application.ApplicationID, app.Application.UserID, 
						app.Application.FirstName, app.Application.LastName, app.Application.Comments, 
						app.Application.ApplicantSignature, app.Application.ApplicantSignedDate, 
						app.Application.MMSLoanID, app.Application.LoanAmt, app.Application.OfficerSignature, 
						app.Application.OfficerSignedDate, app.Application.MMSAmt, 
						app.Application.MMSSignature, app.Application.MMSSignedDate, app.Application.ApplStatus, 
						app.Application.LoanApprovedFlag, app.Application.LoanApprovedDate, 
						app.Application.Uniqueidentifier, app.Application.DateInserted, 
						app.Application.DateUpdated, 
						app.Application.LockedForStudent, app.Application.LockedForOfficer, 
						app.Application.LockedForAdmin, app.Application.OfficerRejectComment, 
						app.Application.MMSPrivateComment, app.Application.MMSLoanSignedDate, 
						opr.CodeLookup.CodeDescription,
						opr.Institution.LegacyCode
			FROM         app.Application 
					LEFT  JOIN	 opr.CodeLookup ON CONVERT(varchar(50), app.Application.ApplStatus) = opr.CodeLookup.Code
					LEFT  JOIN	 act.UserInfo	on act.UserInfo.UserID = app.Application.UserID
					LEFT  JOIN	 opr.Institution on act.UserInfo.InstitutionID =  opr.Institution.InstitutionID
			WHERE     (app.Application.IsDeleted = 'N') 
						AND (NOT (app.Application.ApplStatus IN (250, 260))) 
						AND (opr.CodeLookup.CodeType = 'Application')
			
		
			--End code

		commit tran

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
		return(-1)
	end catch

END
GO
GRANT EXECUTE ON  [dbo].[p_GetOpenLoanApplications] TO [ExecSP]
GO
