SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[p_AddUserImpersonationRequest]
	-- Add the parameters for the stored procedure here
	@UserIdToImpersonate int, 
	@ImpersonateBy varchar(50), 
	@InsertedBy varchar(50),
	@OverrideRORestriction bit = 0
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 02/19/2015
-- Description:	add a request to impersonate a user
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			declare 	@ValidUntil datetime
			set @ValidUntil = DATEADD(minute,5,getdate())

			INSERT      
			INTO       dbo.UserImpersonationRequests (UserIdToImpersonate, ImpersonateBy, ValidUntil, InsertedBy, OverrideRORestriction)
			VALUES     (@UserIdToImpersonate, @ImpersonateBy, @ValidUntil, @InsertedBy, @OverrideRORestriction)

			select [UniqueId]
			from dbo.UserImpersonationRequests
			where UserIdToImpersonate = @UserIdToImpersonate
				and ValidUntil = @ValidUntil
				and Id = @@identity
		
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
GRANT EXECUTE ON  [dbo].[p_AddUserImpersonationRequest] TO [ExecSP]
GO
