SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [act].[p_ResendEmailForInitialAccount] 
	@Requestor varchar(25),
	@EmailAddress varchar(50)
AS

BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	resend email for account setup

/* test data

EXEC	[act].[p_ResendEmailForInitialAccount]
		@Requestor = N'test',
		@EmailAddress = N'svatasoiu@mms.org'

*/
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			DECLARE @MemUniqID varchar(255)
			DECLARE @LastName varchar(50)
			DECLARE @FirstName varchar(50)
			DECLARE @FullName varchar(255)
			DECLARE @UserIdentity int
		
			SELECT	@UserIdentity = ui.UserID,    				
   					@LastName = ui.LastName, 
   					@FirstName = ui.FirstName,
   					@MemUniqID = ui.UniqueIdentifier
   			FROM act.UserInfo ui 
			WHERE  
					LTRIM(RTRIM(UPPER(ui.Email))) = LTRIM(RTRIM(UPPER(@EmailAddress)))  
					AND ui.IsDeleted = 'N'

			IF (@UserIdentity > 0) 
			BEGIN
				SELECT 0 ERRORCODE, 'Successful.' ERRORMESSAGE

				SET @FullName = @FirstName + ' ' + @LastName

				EXEC act.p_EmailIntialAccountSetUp @EmailAddress, @FullName, @MemUniqID
			END
			ELSE
			BEGIN
				SELECT -100 ERRORCODE , 'Email address provided is not a valid or active one.' ERRORMESSAGE
			END			
		
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
