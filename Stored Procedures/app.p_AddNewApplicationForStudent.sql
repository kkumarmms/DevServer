SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [app].[p_AddNewApplicationForStudent]
	-- Add the parameters for the stored procedure here
	@UserId int, 
	@OfficerId int,
	@MMSLoanID int,
	@InsertedBy varchar(50) = null
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	will add a new loan application for an existing student
-- 06/23/2014 sv - add null for LoanApprovedFlag
/* test data

EXEC	[app].[p_AddNewApplicationForStudent]
		@UserId = 1,
		@OfficerId = 1,
		@MMSLoanID = 1,
		@InsertedBy = N'debug'

*/
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			declare @appId as int
			declare @schoolName varchar(100)

			SELECT  @schoolName =  isnull(opr.Institution.InstitutionName,'')
			FROM    opr.Institution INNER JOIN
								  act.UserInfo ON opr.Institution.InstitutionID = act.UserInfo.InstitutionID
			WHERE   (act.UserInfo.UserID = @UserId) 


			--Begin code
			INSERT INTO app.Application
						  (UserID, 
						  OfficerId, 
						  FirstName, 
						  MiddleInitial, 
						  LastName, 
						  MMSLoanID, 
						  LoanAmt,
						  MDDegreeFromSchool,
						  ApplStatus, 
						  InsertedBy,
						  DateInserted,
						  LoanApprovedFlag)
				SELECT  act.UserInfo.UserID, 
						@OfficerId 'OfficerId',
						act.UserInfo.FirstName, 
						act.UserInfo.MiddleInitial, 
						act.UserInfo.LastName, 
						opr.MMSLoans.MMSLoanID,
						opr.MMSLoans.LoanAmount 'LoanAmt' ,
						@schoolName,
						199 'ApplStatus',
						@InsertedBy 'InsertedBy',
						getdate(),
						null

				FROM         act.UserInfo CROSS JOIN
									  opr.MMSLoans
				WHERE     (act.UserInfo.UserID = @UserId) 
						AND (opr.MMSLoans.MMSLoanID = @MMSLoanID)
			
			set @appId = scope_identity();

			--update data from prev application
			

			--update the status of the application
			exec app.p_UpdateApplicationStatus @ApplicationID = @appId, @CurrentStatus = 199,	@NewStatus =200;
		
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
GRANT EXECUTE ON  [app].[p_AddNewApplicationForStudent] TO [ExecSP]
GO
