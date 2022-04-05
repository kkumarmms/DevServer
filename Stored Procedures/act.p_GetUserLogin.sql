SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [act].[p_GetUserLogin] 
	@Requestor VARCHAR(25),
	@IncludeDeleted CHAR(1),
	@Email VARCHAR(50),
	@Password VARCHAR(100)
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	return user based on login info

/*test data

EXEC	[act].[p_GetUserLogin]
		@Requestor = N'1',
		@IncludeDeleted = N'1',
		@Email = N'svatasoiu@mms.org',
		@Password = N'test'

*/
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			OPEN SYMMETRIC KEY SLAPSymKey
				DECRYPTION BY CERTIFICATE SLAPCert	

			DECLARE @UserIdentity int
			SET @UserIdentity = 0
			SET @UserIdentity =  (
										SELECT  UserID 
										FROM act.UserInfo 
										WHERE 
											LTRIM(RTRIM(UPPER(Email))) = LTRIM(RTRIM(UPPER(@Email)))
											AND LTRIM(RTRIM(Password)) = LTRIM(RTRIM(dbo.HashData(@Password)))
								  )

			IF (@UserIdentity > 0)
			BEGIN	  
				EXEC act.p_GetUserInfo  @Requestor,@IncludeDeleted, @UserIdentity,'', 0, ''
			END		
			else
			Begin
				--return a non existing user
				EXEC act.p_GetUserInfo  @Requestor,@IncludeDeleted, -1,'', -1, 'X'
			end
			
		
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
