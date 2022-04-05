SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [opr].[p_GetSiteNotifications]
	-- Add the parameters for the stored procedure here
	@GetAll bit = 0
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/4/2014
-- Description:	get site notifications
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			if (@GetAll = 1)
			begin
				--get all
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
					ORDER BY DisplayOrder
			end
			else
			begin
				--get only active ones
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
					WHERE Active = 1
						and MessageStartDate <= getdate()
						and dateadd(day,1,isnull(MessageEndDate, getdate())) >= getdate()
					ORDER BY DisplayOrder
			end
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
GRANT EXECUTE ON  [opr].[p_GetSiteNotifications] TO [ExecSP]
GO
