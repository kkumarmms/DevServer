SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [act].[p_ReconciliateEmail]
	-- Add the parameters for the stored procedure here
	@Email varchar(100)
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/11/2014
-- Description:	reconcialte old accounts
/*
EXEC	[act].[p_ReconciliateEmail]
		@Email = N'svatasoiu@mms.org'
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
			DECLARE @body varchar(4000)
			DECLARE @LastName varchar(50)
			DECLARE @FirstName varchar(50)
			DECLARE @FullName varchar(255)
			DECLARE @ExpireDateTime datetime
			DECLARE @UserIdentity int	
			-- check the email if it does exists in our user table
			IF EXISTS 
			  ( 
				SELECT ui.Email 
				FROM act.UserInfo ui 
				WHERE  
					LTRIM(RTRIM(UPPER(ui.Email))) = LTRIM(RTRIM(UPPER(@Email))) 
					AND IsDeleted = 'N' 
			  )
			  BEGIN
			  	  SET @MemUniqID = newid() 
				  SET @ExpireDateTime   =  DATEADD(hour, 24, GETDATE())

				  UPDATE act.UserInfo 
				  SET	UniqueIdentifier = @MemUniqID, 
						ForgottenLinkExpiry = @ExpireDateTime ,
						DateUpdated = getdate(),
						UpdatedBy = @Email
				  WHERE  LTRIM(RTRIM(UPPER(Email))) = LTRIM(RTRIM(UPPER(@Email))) 
				   

				  SELECT @LastName = ui.LastName, 
						@FirstName = ui.FirstName,
						@UserIdentity = UserID  
				   FROM act.UserInfo ui 
				   WHERE  
						LTRIM(RTRIM(UPPER(ui.Email))) = LTRIM(RTRIM(UPPER(@Email)))  
      
				  SET @FullName = @FirstName + ' ' + @LastName
				  EXEC act.p_EmailForgotPassword @Email, @FullName,@MemUniqID, @ExpireDateTime

				  SELECT 0 ERRORCODE, 'We found your account.<br/>An email with instructions on how to reset your password for this portal was sent to your email address.' ERRORMESSAGE
			  END
			  else
			  Begin

				  SELECT -100 ERRORCODE, 'We need more information to locate your account.<br/>Please complete the information on the next page.' ERRORMESSAGE
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
GRANT EXECUTE ON  [act].[p_ReconciliateEmail] TO [ExecSP]
GO
