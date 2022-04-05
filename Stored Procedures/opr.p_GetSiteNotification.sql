SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [opr].[p_GetSiteNotification]
	-- Add the parameters for the stored procedure here
	@MessageId int
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	get the site notification for this user
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
					SELECT     MessageId, 
							DisplayOrder, 
							Message, 
							MessageStartDate, 
							MessageEndDate, 
							ShowOnlyIf, 
							ShowOnlyIfCode,
							Comment,
							Active, 
							DateInserted, 
							DateUpdated, 
							InsertedBy, 
							UpdatedBy
					FROM         opr.SiteNotification
					WHERE MessageId = @MessageId
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
