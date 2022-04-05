SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [app].[p_GetApplicationsForStudent]
	-- Add the parameters for the stored procedure here
		@UserId int,
		@IncludeDeleted char(1) = 'N'
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	get applications for one user

/* test data

EXEC	 [app].[p_GetApplicationsForStudent]
		@UserId = 1,
		@IncludeDeleted = N'N'

*/
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code

			SELECT     app.ApplicationID, 
						app.UserID, 
						app.ApplStatus, 
						app.LoanApprovedFlag, 
						app.LoanApprovedDate, 
						app.Uniqueidentifier, 
						app.DateInserted, 
						ISNULL(cd.CodeDescription, '') AS 'ApplStatusDescription', 
						ISNULL(cd.CodeDescriptionInternal, '') AS 'ApplStatusDescriptionInternal', 
						ISNULL(ln.LoanAmount, 0) AS 'LoanAmount', 
						ISNULL(ln.Description, '')              AS LoanDescription
			FROM         app.Application AS app LEFT OUTER JOIN
								  opr.MMSLoans AS ln ON app.MMSLoanID = ln.MMSLoanID LEFT OUTER JOIN
								  opr.CodeLookup AS cd ON app.ApplStatus = cd.Code

			WHERE     (app.UserID = @UserId) 
				AND (cd.CodeType = 'Application') 
				AND (cd.FieldName = 'ApplStatus')
			order by app.DateInserted desc
			
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
GRANT EXECUTE ON  [app].[p_GetApplicationsForStudent] TO [ExecSP]
GO
