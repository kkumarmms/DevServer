SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[p_GetImpersonationRequest]
	-- Add the parameters for the stored procedure here
	@UniqueId varchar(100)
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 02/23/2015
-- Description:	get an impersonation request
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			SELECT     Id, 
					UserIdToImpersonate, 
					ImpersonateBy, 
					ValidUntil, 
					UniqueId, 
					Used, 
					OverrideRORestriction, 
					DateInserted, 
					InsertedBy, 
					DateUpdated, 
					UpdatedBy
			FROM       dbo.UserImpersonationRequests
			WHERE     (UniqueId = @UniqueId)
			
		
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
GRANT EXECUTE ON  [dbo].[p_GetImpersonationRequest] TO [ExecSP]
GO
