SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[p_SendEmail]
	@sendEmailTo varchar(100),
	@body varchar(7000),
	@subj varchar(100),
	@attachm varchar(100)
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	log activity for audit
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			declare @profile varchar(100)
			SET @profile = ''

			exec msdb.dbo.sp_send_dbmail 
					 @recipients = @sendEmailTo
					--,@profile_name = @profile
					,@file_attachments = @attachm
					,@subject = @subj
					,@body = @body
	
			insert dbo.Audit (Type, 
							TableName, 
							PrimaryKeyField, 
							PrimaryKeyValue, 
							FieldName, 
							OldValue, 
							NewValue, 
							UpdateDate, 
							UserName)
			 values
							  ('E', 
							  'Email', 
							  'RECEIPIENTS', 
							  @sendEmailTo, 
							  '', 
							  @body, 
							  @subj, 
							  GETDATE(), 
							  'Stored Proc')
		
			
		
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
