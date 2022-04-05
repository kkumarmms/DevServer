SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[mms_EmailControl_TestInternal]
as
/*
Generic procedure to send emails to a group of recipients
all emails already stored in mms_email table with all required information
msh 2021-01-29 replaced Bill Wheeler's name and email
*/
set nocount on

begin try

-- only for testing period
--update mms_email set recipients = 'msherman@mms.org;jmcelhiney@mms.org;mtanner@mms.org;ebayes@mms.org' where MailSent is null

-- only for initial go-live period
--update mms_email set BCC_Recipients = 'cefund@mms.org;msherman@mms.org;svatasoiu@mms.org;oteixeira@mms.org' where MailSent is null

declare	
	@sql 	varchar(1000) ,
	@id 	int ,
	@maxid	int,
	@return_value int,
	@Profile_Name		varchar(50),
	@recipients			varchar(256) ,
	@Copy_Recipients	varchar(256) ,
	@BCC_Recipients		varchar(256) ,
	@Subject			varchar(256) ,
	@body			varchar(max) ,
	@Body_Format		char(4),
	@Attachments		varchar(5000)
	

	
	select	@id = 0 , @maxid = max(id) 
	from mms_Email
	where [MailSent] is null
	
	while @id < @maxid
	begin
		select	@id = min(id) from mms_Email where [MailSent] is null and id > @id
		
		select 	

			@Profile_Name		=Profile_Name,
			@recipients			=recipients ,
			@Copy_Recipients	=Copy_Recipients ,
			@BCC_Recipients		=BCC_Recipients,
			@Subject			='TEST Internal Recipients ONLY ' + Subject ,
			@body				=body ,
			@Body_Format		=Body_Format,
			@Attachments		=Attachments		
		from	mms_Email
		where	id = @id	
		select @recipients

		exec @return_value = msdb.dbo.sp_send_dbmail
				@Profile_Name	= @Profile_Name,
--				@recipients		= @recipients ,
				@recipients		= 'msherman@mms.org;svatasoiu@mms.org;oteixeira@mms.org', -- only for testing
				@Subject		= @Subject ,
				@Body			= @body ,
				@Copy_Recipients		= @Copy_Recipients,
				@blind_copy_recipients	=@BCC_Recipients,
				@Body_Format			=@Body_Format,
				@file_Attachments		= @Attachments

		----if @return_value =0
		----begin
		----	update mms_Email 
		----	set [MailSent] = getdate() 
		----	where	id = @id
		----end
	

	end


	--select @return_value  = count(*) from dbo.mms_Email where MailSent is null
	--if @return_value >0
	--begin
	--	set @Subject = convert(varchar(10),@return_value) + '  SLAP EMAILS were not sent'	
	--	EXEC msdb.dbo.sp_send_dbmail
	--	@profile_name = @Profile_Name,
	--	@recipients = 'msherman@mms.org;svatasoiu@mms.org;oteixeira@mms.org',
	--	@body = 'Please run select * from SLAP.dbo.mms_Email where [MailSent] is null',
	--	@subject = @Subject
	--end


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
	Return (-1)
end catch







GO
