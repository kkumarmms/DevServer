SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [app].[p_GetApplFinancials]
	-- Add the parameters for the stored procedure here
	@ApplicationId int, 
	@FinType char(1),
	@IsDeleted char(1) = 'N'
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	get application financials
/* test data

EXEC	[app].[p_GetApplFinancials]
		@ApplicationId = 1,
		@FinType = N'E',
		@IsDeleted = N'N'

*/
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			SELECT     ApplFinancialsID, 
						ApplicationId, 
						FinType, 
						Description, 
						Value, 
						DisplayOrder,
						IsDeleted, 
						DateInserted, 
						DateUpdated, 
						InsertedBy, 
						UpdatedBy
			FROM         app.ApplFinancials AS af
			WHERE     (ApplicationId = @ApplicationId) 
					AND (FinType = @FinType)
					AND (IsDeleted = @IsDeleted)
			ORDER BY 	DisplayOrder 
			
		
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
GRANT EXECUTE ON  [app].[p_GetApplFinancials] TO [ExecSP]
GO
