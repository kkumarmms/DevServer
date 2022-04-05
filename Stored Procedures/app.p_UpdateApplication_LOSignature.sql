SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [app].[p_UpdateApplication_LOSignature]
	-- Add the parameters for the stored procedure here
	@ApplicationID  int  ,
	@OfficerId  int  ,
	@OfficerSignature  varchar(50)  ,
	@OfficerSignedDate  date  ,
	@UpdatedBy  varchar(50)  ,
	@OfficerRejectComment varchar(1000) =''

AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	update (partial) of an application
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			UPDATE [app].[Application]
			   SET [OfficerId] = @OfficerId, 
				  [OfficerSignature] = @OfficerSignature, 
				  [OfficerSignedDate] = @OfficerSignedDate, 
				  [DateUpdated] =getdate(), 
				  [UpdatedBy] = @UpdatedBy ,
				  OfficerRejectComment = @OfficerRejectComment
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
GRANT EXECUTE ON  [app].[p_UpdateApplication_LOSignature] TO [ExecSP]
GO
