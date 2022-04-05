SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [act].[p_EmailResetPassword] 
	@sendEmailTo varchar(100),
	@displayName varchar(100)
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	send a link to reset the password
/* test data

EXEC	 [act].[p_EmailResetPassword]
		@sendEmailTo = N'svatasoiu@mms.org',
		@displayName = N'sorin'

*/
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
				declare @profile varchar(100)
				declare @body varchar(7000)
				declare @subj varchar(100)
				declare @emailId int

				set nocount on

				set @profile ='CEFUND'
				set @subj= 'Reset Password Process Complete'

				set @body = 'Dear ' + @displayName + ',' + Char(10) +Char(13)+ '<br/>'
						+ 'At your request, your SLAP password has been reset. Your password reset date and time is: ' + CAST(GETDATE() AS varchar) + '.'
						+ Char(10) +Char(13)+ '<br/>'
 						+ 'Please contact CE Fund at <a mailto:"cefund@mms.org">cefund@mms.org</a> if you encounter any logon difficulties or did not request this change.'
						+ Char(10) +Char(13) + '<br/>'

						+ 'Thank You.'

				exec opr.p_AddEmailLogSP @EmailTo = @sendEmailTo
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
		commit tran
		begin tran
				exec msdb.dbo.sp_send_dbmail 
				@recipients = @sendEmailTo
				,@profile_name = @profile
				,@subject = @subj
				,@body = @body	
				,@body_format = 'HTML' 
		
				update [dbo].[mms_Email]
				set MailSent = getdate()
				where Id = @emailId
			
		
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
GRANT EXECUTE ON  [act].[p_EmailResetPassword] TO [ExecSP]
GO
