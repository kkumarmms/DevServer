SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [act].[p_UpdateUserToEligibilityExceptions]
	-- Add the parameters for the stored procedure here
	@Id int,
	@UserId int,
	@InstitutionId int ,
	@StartDate datetime ,
	@EndDate datetime,
	@Active bit,
	@UpdatedBy varchar(50) 
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 11/25/2015
-- Description:	update user for eligibility exceptions
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			UPDATE    act.UserEligibilityException
			SET       StartDate = @StartDate,
					 EndDate = @EndDate,
					 Active = @Active, 
					 UpdatedBy = @UpdatedBy,
					 DateUpdated = getdate()
			WHERE     (Id = @Id) 
					AND (UserId = @UserId) 
					AND (InstitutionId = @InstitutionId)
			
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
