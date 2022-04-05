SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [opr].[p_AddEmailLogSP]
	-- Add the parameters for the stored procedure here
			@EmailTo varchar(255),
			@EmailCC varchar(255) = null,
			@EmailBCC varchar(50) = null,
			@EmailProfile varchar(50) = null,
			@Subject varchar(255) = null,
			@Body varchar(6000) = null,
			@BodyFormat varchar(10) = 'HTML',
			@AttachementLink varchar(255) = null,
			@SentOn datetime = null,
			@InsertedBy varchar(50) = null,
			@EmailId int output	   
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: <Create Date,,>
-- Description:	<Description,,>
/*
DECLARE	@return_value int,
		@EmailID int

EXEC	@return_value = [opr].[p_AddEmailLog]
		@EmailTo = N'svatasoiu@mms.org',
		@EmailProfile = N'cefund',
		@Subject = N'test',
		@Body = N'test',
		@BodyFormat = N'html',
		@InsertedBy = N'test',
		@EmailID = @EmailID OUTPUT

SELECT	@EmailID as N'@EmailID'
*/
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			INSERT  INTO mms_Email
				(Profile_Name, 
				recipients, 
				Copy_Recipients, 
				BCC_Recipients, 
				Subject, 
				Body, 
				Body_Format, 
				Attachments, 
				UserName)
			VALUES     
				(@EmailProfile
				,@EmailTo
				,@EmailCC
				,@EmailBCC
				,@Subject
				,@Body
				,@BodyFormat
				,@AttachementLink
				,@InsertedBy
				)		

			set @EmailId = SCOPE_IDENTITY()
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
GRANT EXECUTE ON  [opr].[p_AddEmailLogSP] TO [ExecSP]
GO
