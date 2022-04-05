SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [act].[p_ResetPassword] 
	@Requestor VARCHAR(25),
	@Email VARCHAR(100),
	@Password VARCHAR(100),
	@LinkUniqueIdentifier varchar(255)

AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	reset user password

/* test data

EXEC	[act].[p_ResetPassword]
		@Requestor = N'sorin',
		@Email = N'svatasoiu@mms.org',
		@Password = N'test',
		@LinkUniqueIdentifier = N'DBD6B313-A35F-4432-A35C-0868EF0AFDE0'

*/
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			DECLARE @ErrorNum int
			DECLARE @ExpireDateTime datetime
			DECLARE @UserIdentity int
			DECLARE @LastName varchar(50)
			DECLARE @FirstName varchar(50)
			DECLARE @FullName varchar(255)		
			
			OPEN SYMMETRIC KEY SLAPSymKey
				DECRYPTION BY CERTIFICATE SLAPCert	

			  IF NOT EXISTS 
			  ( 
				SELECT ui.Email FROM UserInfo ui 
				WHERE  LTRIM(RTRIM(UPPER(ui.Email))) = LTRIM(RTRIM(UPPER(@Email))) 
					AND IsDeleted = 'N' 
					AND UniqueIdentifier = @LinkUniqueIdentifier
			  )
			  BEGIN
				SELECT -100 ERRORCODE , 'Unrecognized authentication information or invalid Email address.' ERRORMESSAGE
			  END  
			  ELSE
			  BEGIN
  
					SELECT  
						@UserIdentity = ui.UserID,
						@LastName = ui.LastName,
						@FirstName = ui.FirstName
					FROM UserInfo ui 
					WHERE 	
						LTRIM(RTRIM(UPPER(ui.Email))) = LTRIM(RTRIM(UPPER(@Email))) 
						AND ui.IsDeleted = 'N' 
						AND ui.UniqueIdentifier = @LinkUniqueIdentifier
						AND ui.ForgottenLinkExpiry >= GETDATE()
  
				IF @UserIdentity > 0
				BEGIN
					UPDATE UserInfo 
					SET Password = dbo.HashData(@Password) 		
						,UserStatus = 180 -- account active		
						,DateUpdated = getdate()
						,UpdatedBy = @Email
						WHERE UserID = @UserIdentity
		
					SET @FullName = @FirstName + ' ' + @LastName
					EXEC act.p_EmailResetPassword @Email, @FullName

					SELECT 0 ERRORCODE , 'Successful update.' ERRORMESSAGE
		

				END
				ELSE
				BEGIN
				   SELECT -200 ERRORCODE , 'The time limit to perform this operation has expired. Please go back to forgotten password and request again. The expiry date and time will be in the email.' ERRORMESSAGE
				END
  
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
