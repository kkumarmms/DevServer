SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [opr].[p_AddSiteNotification]
	-- Add the parameters for the stored procedure here
	@DisplayOrder int =0,
	@Message varchar(2000),
	@MessageStartDate datetime,
	@MessageEndDate datetime = null,
	@ShowOnlyIf varchar(50) ,
	@ShowOnlyIfCode varchar(50) ,
	@Comment varchar(200) ='',
	@Active bit = 1,
	@InsertedBy varchar(100) = ''
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/2/2014
-- Description:	add a site notification
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
				INSERT INTO opr.SiteNotification
									(DisplayOrder, 
									Message, 
									MessageStartDate, 
									MessageEndDate, 
									ShowOnlyIf, 
									ShowOnlyIfCode,
									Comment,
									Active, 
									DateInserted,
									InsertedBy)
				VALUES     (@DisplayOrder
							,@Message
							,@MessageStartDate
							,@MessageEndDate
							,@ShowOnlyIf
							,@ShowOnlyIfCode
							,@Comment
							,@Active
							, GETDATE()
							,@InsertedBy)	
			
		
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
GRANT EXECUTE ON  [opr].[p_AddSiteNotification] TO [ExecSP]
GO
