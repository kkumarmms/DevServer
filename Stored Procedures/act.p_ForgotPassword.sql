SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [act].[p_ForgotPassword]

	@Requestor VARCHAR(25),
	@EmailID VARCHAR(100)
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	setup expiration link and send email to reset password
/*test data

EXEC	[act].[p_ForgotPassword]
		@Requestor = N'sorin',
		@EmailID = N'svatasoiu@mms.org'
*/
-- 07/30/2018 sv - change error message for email not found
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			DECLARE @ErrorNum int
			DECLARE @MemUniqID varchar(255)
			DECLARE @body varchar(4000)
			DECLARE @LastName varchar(50)
			DECLARE @FirstName varchar(50)
			DECLARE @FullName varchar(255)
			DECLARE @ExpireDateTime datetime
			DECLARE @UserIdentity int		
			
			  IF NOT EXISTS 
			  ( 
				SELECT ui.Email 
				FROM act.UserInfo ui 
				WHERE  
					LTRIM(RTRIM(UPPER(ui.Email))) = LTRIM(RTRIM(UPPER(@EmailID))) 
					AND IsDeleted = 'N' 
			  )
			  BEGIN
				SELECT -100 ERRORCODE, 'An email with instructions on how to reset your password will be sent to the email address from our files.' ERRORMESSAGE
			  END
			  ELSE
			  BEGIN
				  SET @MemUniqID = newid() 
				  SET @ExpireDateTime   =  DATEADD(hour, 24, GETDATE())

				  SELECT @LastName = ui.LastName, 
						@FirstName = ui.FirstName,
						@UserIdentity = UserID  
				   FROM act.UserInfo ui 
				   WHERE  
						LTRIM(RTRIM(UPPER(ui.Email))) = LTRIM(RTRIM(UPPER(@EmailID)))  

				  UPDATE act.UserInfo 
				  SET	UniqueIdentifier = @MemUniqID, 
						ForgottenLinkExpiry = @ExpireDateTime 
				  WHERE  LTRIM(RTRIM(UPPER(Email))) = LTRIM(RTRIM(UPPER(@EmailID)))  

				  --IF (@UserIdentity > 0) 
				  --BEGIN
				  --EXEC p_MMS_SLAP_GetUserInfo @Requestor, 'N', @UserIdentity 
				  --END
	  
				  --SELECT @MemUniqID LinkUniqueIdentifier
      
				  SET @FullName = @FirstName + ' ' + @LastName
				  EXEC act.p_EmailForgotPassword @EmailID, @FullName,@MemUniqID, @ExpireDateTime

				  SELECT 0 ERRORCODE, 'Successful' ERRORMESSAGE

     
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
