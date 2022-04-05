SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [act].[p_GetUserWithEligibilityException]
	-- Add the parameters for the stored procedure here
	@Id int

AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 11/25/2015
-- Description:	get user with eligibility exceptions by id (not the user id)
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			SELECT     ex.Id, 
					ex.UserId, 
					ex.InstitutionId, 
					ex.StartDate, 
					ex.EndDate, 
					ex.Active, 
					ex.DateInserted, 
					ex.InsertedBy, 
					ex.DateUpdated, 
					ex.UpdatedBy, 
					u.FirstName, 
					u.LastName, 
					i.InstitutionName
			FROM         act.UserEligibilityException AS ex INNER JOIN
								  act.UserInfo AS u ON ex.UserId = u.UserID INNER JOIN
								  opr.Institution AS i ON ex.InstitutionId = i.InstitutionID
		
			WHERE    (ex.Id = @Id) 

		
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
