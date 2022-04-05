SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [opr].[p_AddUserForReconciliation]
	-- Add the parameters for the stored procedure here
	@FirstName  varchar(50) ,
	@MiddleInitial  varchar(10)  = NULL,
	@LastName  varchar(50) ,
	@Title  varchar(10)  = NULL,
	@Email  varchar(100),
	@SSNumber varchar(100) = null,
	@Address1  varchar(50)  = NULL,
	@Address2  varchar(50)  = NULL,
	@City  varchar(50)  = NULL,
	@State  varchar(3)  = NULL,
	@Zip  varchar(10)  = NULL,
	@Country varchar(50) = NULL,
	@Phone  varchar(20)  = NULL,
	@CellPhone  varchar(20)  = NULL,
	@Comment varchar(500) = NULL,
	@ReferenceNo  varchar(50)  = NULL,
	@IpAddress  varchar(50)  = NULL
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: <Create Date,,>
-- Description:	<Description,,>

--[opr].[p_AddUserForReconciliation] 
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
			DECLARE @FullName varchar(255)
			DECLARE @ExpireDateTime datetime
			DECLARE @UserIdentity int	
			declare @MMSAdminEmail varchar(100)
			set @MMSAdminEmail = 'Cefund@mms.org'
			declare @profile varchar(100)
			set @profile ='CEFUND'
				
			declare @subj varchar(100)
			declare @emailId int
			declare @counter int

			OPEN SYMMETRIC KEY SLAPSymKey
				DECRYPTION BY CERTIFICATE SLAPCert	

			--check if the email exists in users table
			set @counter = (SELECT     COUNT(Email) AS TotalCount
							FROM         act.UserInfo
							WHERE     (Email = @Email))

			if (@counter >0)
				BEGIN --1
					--raiserror('This email (%s) was already registered in our system.',12,1, @Email)
						SELECT -100 ERRORCODE, 'This email (' + @Email + ') was already registered in our system.' ERRORMESSAGE
					
				END --1

			ELSE
				BEGIN -- 1
				--check if the email exists in user reconciliation table
					set @counter = (SELECT     COUNT(Email) AS TotalCount
					--select *
									FROM       [dbo].[UserReconciliation]  
									WHERE     (Email = @Email))

					if (@counter >0)
					begin --2
						--raiserror('You already registered this email (%s) for this website.',12,1, @Email)
						SELECT -200 ERRORCODE, 'You already registered this email (' + @Email + ') for this website, please contact <a href="mailto:cefund@mms.org">cefund@mms.org</a> for assistance.' ERRORMESSAGE
				
					end --2
					ELSE
					BEGIN --2
							INSERT INTO dbo.UserReconciliation
								   (FirstName
								   ,MiddleInitial
								   ,LastName
								   ,Title
								   ,Email
								   ,Address1
								   ,Address2
								   ,City
								   ,State
								   ,Zip
								   ,Country
								   ,Phone
								   ,CellPhone
								   ,Comment
								   ,ReferenceNo
								   ,IpAddress
									,SSNumber
									,SSNHashed)
							 VALUES
							--select	  
									(@FirstName
								   ,@MiddleInitial
								   ,@LastName
								   ,@Title
								   ,@Email
								   ,@Address1
								   ,@Address2
								   ,@City
								   ,@State
								   ,@Zip
								   ,@Country
								   ,@Phone
								   ,@CellPhone
								   ,@Comment
								   ,@ReferenceNo
								   ,@IpAddress
									,dbo.EncryptData(@SSNumber) 
									,dbo.HashData(@SSNumber))
									
			


						--check to see if there is a matching SSN with a missing email
							set @counter = (SELECT     COUNT(u.UserID) AS TotalCount
											FROM         act.UserInfo u
											WHERE     u.SSNHashed = dbo.HashData(@SSNumber))

							if (@counter >0)
							begin --3
								--found a SSN match, update the email and OK
								UPDATE    act.UserInfo
								SET       Email = @Email
								WHERE     SSNHashed = dbo.HashData(@SSNumber)

								-- valid 
								SET @MemUniqID = newid() 
								SET @ExpireDateTime   =  DATEADD(hour, 24, GETDATE())

								UPDATE act.UserInfo 
								SET	UniqueIdentifier = @MemUniqID, 
										ForgottenLinkExpiry = @ExpireDateTime 
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
								--return(0)
							end --3
							else
							begin --3
								--not found
								--contact admin
									set @subj= 'SLAP - student needs manual account lookup'

									set @body = 'Dear ' + 'CELoan Admin' + ',' + Char(10) +Char(13) + '<br/>'
												+ 'A student tried unsuccessfully to reconcile her/his account with an existing one. ' + '<br/>'
												+ 'The following information was submitted:<br/>'
												+ '<br/>First Name    = ' + isnull(@FirstName,'')
												+ '<br/>Middle Initial= ' + isnull(@MiddleInitial,'')
												+ '<br/>Last Name     = ' + isnull(@LastName,'')
												+ '<br/>Title         = ' + isnull(@Title,'')
												+ '<br/>Email         = ' + isnull(@Email,'')
												+ '<br/>Address1      = ' + isnull(@Address1,'')
												+ '<br/>Address2      = ' + isnull(@Address2,'')
												+ '<br/>City          = ' + isnull(@City,'')
												+ '<br/>State         = ' + isnull(@State,'')
												+ '<br/>Zip           = ' + isnull(@Zip,'')
												+ '<br/>Country       = ' + isnull(@Country,'')
												+ '<br/>Phone         = ' + isnull(@Phone,'')
												+ '<br/>Comment       = ' + isnull(@Comment,'')
												+ Char(10) +Char(13) + '<br/>'
												+ Char(10) +Char(13) + '<br/>'
												+ 'Thank You.'
												+ Char(10) +Char(13) + '<br/>'
							--select EmailTo=@MMSAdminEmail
							--profile = @profile,
							--Subject = @subj,
							--Body = @body
							--/*
												exec opr.p_AddEmailLogSP @EmailTo = @MMSAdminEmail
																   ,@EmailCC = null
																   ,@EmailBCC = null
																   ,@EmailProfile = @profile
																   ,@Subject = @subj
																   ,@Body = @body
																   ,@BodyFormat = 'HTML'
																   ,@AttachementLink = null
																   ,@SentOn = null
																   ,@InsertedBy = 'auto'
																	,@EmailId = @EmailId  output


												exec msdb.dbo.sp_send_dbmail 
													@recipients = @MMSAdminEmail
													,@profile_name = @profile
													,@subject = @subj
													,@body = @body		
													,@body_format = 'HTML' 

												update [dbo].[mms_Email]
												set MailSent = getdate()
												where Id = @emailId


												SELECT -300 ERRORCODE, 'We could not find a matching account.<br/>Your data was recorded and the administrator of the C &amp; E Fund was notified.<br/>You will receive a notification from the administrator soon with instructions on how to proceed.' ERRORMESSAGE
										
							--*/
							end --3
					END --2
				END --1
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
GRANT EXECUTE ON  [opr].[p_AddUserForReconciliation] TO [ExecSP]
GO
