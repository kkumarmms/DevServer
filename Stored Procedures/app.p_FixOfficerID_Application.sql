SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE [app].[p_FixOfficerID_Application] 
	@UserID int,
	@OfficerId int ,
	@IsDeleted nchar(10) ='N' ,
	@DateInserted datetime2(7) = null ,
	@DateUpdated datetime2(7) = null ,
	@InsertedBy varchar(50) = null ,
	@UpdatedBy varchar(50) = null

AS
BEGIN
-- =============================================
-- Author:		Mike Sherman
-- Create date: 4/1/2014
-- Description:	update missing officerID. Id was set to 0 when application created
/* test data

EXEC	[app].[p_FixOfficerID_Application]
		@UserID = 1,
		@OfficerId = 1,
		@IsDeleted = N'N',
		@DateInserted = NULL,
		@DateUpdated = NULL,
		@InsertedBy = NULL,
		@UpdatedBy = NULL

*/
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-- Set default values for optional parameters
	SET	@DateInserted = isnull(@DateInserted,getdate() ) 
	SET	@DateUpdated  = isnull(@DateUpdated,getdate() )
	SET	@InsertedBy =  isnull(@InsertedBy,suser_sname() )
	SET	@UpdatedBy = isnull(@UpdatedBy,suser_sname())
    -- Insert statements for procedure here
	begin try

		begin tran
			
				-- update missing officerID. Id was set to 0 when application created
			UPDATE app.Application
			SET
					OfficerId = @OfficerId
			WHERE 
					UserID = @UserID AND
					OfficerId = 0 

			SELECT 0 ERRORCODE, 'Successful...' ERRORMESSAGE

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
