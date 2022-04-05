SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[p_GetEmailsSent]
	-- Add the parameters for the stored procedure here
	@SentTo varchar(100) = null,
	@Subject varchar(200) = null,
	@FirstName varchar(100) = null,
	@LastName varchar(100) = null,
	@SentBefore datetime = null,
	@SentAfter datetime = null,
	@MaxRecords int = 100
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 02/27/2015
-- Description:	get the sent emails
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			SELECT  top(@MaxRecords)   
					id as Id, 
					isnull(Profile_Name,'') as ProfileName, 
					isnull(recipients,'') as Recipients, 
					isnull(Copy_Recipients,'') as CopyRecipients, 
					isnull(BCC_Recipients,'') as BccRecipients, 
					isnull(Subject,'') as Subject, 
					isnull(Body,'') as Body, 
					isnull(Body_Format,'') as BodyFormat, 
					isnull(Attachments,'') as Attachments, 
					Created, 
					isnull(UserName,'') as UserName, 
					MailSent
			FROM    dbo.mms_Email
			WHERE (@SentTo is null or recipients like '%' + @SentTo + '%')
				and (@Subject is null or Subject like '%' + @Subject + '%')
				and (@FirstName is null or Body like '%' + @FirstName + '%')
				and (@LastName is null or Body like '%' + @LastName + '%')
				and (@SentBefore is null or Created <= @SentBefore )
				and (@SentAfter is null or Created >= @SentAfter)
			ORDER BY Created DESC
			
		
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
GRANT EXECUTE ON  [dbo].[p_GetEmailsSent] TO [ExecSP]
GO
