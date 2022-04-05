SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [app].[p_GetApplicationByAppId]
	-- Add the parameters for the stored procedure here
	@ApplicationID int
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	get an loan application based on filter
-- 10/17/2014 sv - add MMSLoanSignedDate
/* test data

EXEC	[app].[p_GetApplicationByAppId]
		@ApplicationID = 1

*/
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			SELECT a.ApplicationID
			  ,a.UserID
			  ,a.OfficerId
			  ,a.FirstName
			  ,a.MiddleInitial
			  ,a.LastName
			  ,a.AddressID
			  ,a.ParentAddressID
			  ,a.IsUSCitizen
			  ,a.IsMAResident
			  ,a.IsMMSStudent
			  ,a.MMSStudentID
			  ,a.HaveLoanCEF
			  ,a.MDDegreeFromSchool
			  ,a.MDDegreeDate
			  ,a.LocationAfterGrad
			  ,a.IsMarried
			  ,a.SpouseOccupation
			  ,isnull(a.Children,0) 'Children'
			  ,a.ChildsAge
			  ,a.IsSpouseApplForLoan
			  ,a.Comments
			  ,a.ApplicantSignature
			  ,a.ApplicantSignedDate
			  ,a.MMSLoanID
			  ,a.LoanAmt
			  ,a.OfficerSignature
			  ,a.OfficerSignedDate
			  ,a.MMSAmt
			  ,a.MMSSignature
			  ,a.MMSSignedDate
			  ,a.ApplStatus
			  ,a.LoanApprovedFlag
			  ,a.LoanApprovedDate
			  ,a.Uniqueidentifier
			  ,a.IsDeleted
			  ,a.DateInserted
			  ,a.DateUpdated
			  ,a.InsertedBy
			  ,a.UpdatedBy
			  ,a.LockedForStudent
			  ,a.LockedForOfficer
			  ,a.LockedForAdmin
			  ,a.OfficerRejectComment
			  ,a.MMSPrivateComment
			  ,a.MMSLoanSignedDate
		  FROM [app].[Application] as a
		  WHERE ApplicationID = @ApplicationID
			
		
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
GRANT EXECUTE ON  [app].[p_GetApplicationByAppId] TO [ExecSP]
GO
