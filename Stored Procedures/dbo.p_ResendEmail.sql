SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[p_ResendEmail]
	-- Add the parameters for the stored procedure here
	@EmailId int,
	@SentBy varchar(50)
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 02/27/2015
-- Description:	re-send an email
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			declare	@Profile_Name sysname,
					@recipientsCopy varchar(max) ,
					@Copy_Recipients varchar(max) ,
					@BCC_Recipients varchar(max) ,
					@SubjectCopy varchar(255) ,
					@BodyCopy varchar(max) ,
					@Body_Format varchar(20) ,
					@Attachments varchar(max) 


			SELECT @Profile_Name = [Profile_Name]
				  ,@recipientsCopy = [recipients]
				  ,@Copy_Recipients = [Copy_Recipients]
				  ,@BCC_Recipients = [BCC_Recipients]
				  ,@SubjectCopy = [Subject]
				  ,@BodyCopy = [Body]
				  ,@Body_Format = [Body_Format]
				  ,@Attachments = [Attachments]
			from [dbo].[mms_Email]
			where id = @EmailId

		commit tran

				begin tran
			

				declare @profile varchar(100)
				declare @body varchar(7000)
				declare @subj varchar(100)
				declare @emailIdNew int

				set nocount on

				set @profile ='CEFUND'
				set @subj= @SubjectCopy

				set @body = @BodyCopy

				exec opr.p_AddEmailLogSP @EmailTo = @recipientsCopy
									,@EmailCC = null
									,@EmailBCC = null
									,@EmailProfile = @profile
									,@Subject = @subj
									,@Body = @body
									,@BodyFormat = 'HTML'
									,@AttachementLink = null
									,@SentOn = null
									,@InsertedBy = @SentBy
									,@emailId = @emailIdNew  output
		commit tran
		begin tran
				exec msdb.dbo.sp_send_dbmail 
				@recipients = @recipientsCopy
				,@profile_name = @profile
				,@subject = @subj
				,@body = @body	
				,@body_format = 'HTML' 
		
				update [dbo].[mms_Email]
				set MailSent = getdate()
				where Id = @emailIdNew
			
		


		commit tran
					--End code
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
