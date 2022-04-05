SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [act].[p_EmailForgotPassword]
	@sendEmailTo varchar(100),
	@displayName varchar(100),
	@MemUniqID varchar(255),
	@ExpireDateTime datetime,
	@EmailSubject varchar(100) = 'MMS Student Loan Application Portal - Account Setup Required'
AS
BEGIN
/*
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	send out email to reset password
	2021-01-29 - msh - replaced Bill Wheeler's name and email
*/
/* test data

EXEC	[act].[p_EmailForgotPassword]
		@sendEmailTo = N'svatasoiu@mms.org',
		@displayName = N'sorin',
		@MemUniqID = N'1111111',
		@ExpireDateTime = N'1/1/2014',
		@EmailSubject = N'reset email test'
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
			set @subj= @EmailSubject

			set @body = 'Dear ' + @displayName + ',' + Char(10) +Char(13) + '<br/>'
					+ '<a href="'+ dbo.fnGetWebLinkForEnvironment(0) +'/ResetPassword.aspx?uid=' + @MemUniqID + '">Please click here to reset your MMS Student Loan Application Portal (SLAP) password</a> and complete your account setup.' 
					+' This link will expire as stated below:' 
					+ Char(10) +Char(13) + '<br/>'
					+ Char(10) +Char(13) + '<br/>'
					+ 'Expire date and time: ' + CAST(@ExpireDateTime AS varchar)
					+ Char(10) +Char(13) + '<br/>'
					+ Char(10) +Char(13) + '<br/>'
 					+ 'Please contact Ofelia Teixeira at <a mailto:"cefund@mms.org">cefund@mms.org</a> should you have any questions.'
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


			exec msdb.dbo.sp_send_dbmail 
				@recipients = @sendEmailTo
				,@profile_name = @profile
				,@subject = @subj
				,@body = @body	
				,@body_format = 'HTML' 	
		commit tran

		begin tran
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
