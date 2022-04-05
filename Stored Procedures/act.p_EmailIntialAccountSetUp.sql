SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [act].[p_EmailIntialAccountSetUp] 
	@sendEmailTo varchar(100),
	@displayName varchar(100),
	@MemUniqID varchar(255)
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	send email to student to complete acount
/* test data

EXEC	[act].[p_EmailIntialAccountSetUp]
		@sendEmailTo = N'svatasoiu@mms.org',
		@displayName = N'sorin',
		@MemUniqID = N'1111111111111'
*/
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			declare @url varchar(100)
			set @url = dbo.fnGetWebLinkForEnvironment(0) +'/CompleteAccount.aspx?uid='

			declare @profile varchar(100)
			declare @body varchar(7000)
			declare @subj varchar(100)
			declare @emailId int

			set nocount on

			set @profile ='CEFUND'
			set @subj= 'Student loan from Massachusetts Medical Society - Initial Account Setup'

				set @body = 'Dear ' + @displayName + ',' + Char(10) +Char(13) + '<br/>'
							+ 'The financial aid office at your medical school recommends you apply for a student loan from the Massachusetts Medical Society Charitable and Educational Fund.' + '<br/>'
							+ Char(10) +Char(13) + '<br/>'
							+ '<a href="' + @url + @MemUniqID + '">Please click here to begin the account setup and application process.</a>'
							+ Char(10) +Char(13) + '<br/>'
							+ Char(10) +Char(13) + '<br/>'
 							+ 'Please contact your financial aid office should you have any questions regarding this email or loans from the MMS Charitable and Educational Fund.'
							+ Char(10) +Char(13) + '<br/>'
							+ 'Thank You.'
							+ Char(10) +Char(13) + '<br/>'

			exec opr.p_AddEmailLogSP 
								@EmailTo = @sendEmailTo
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
