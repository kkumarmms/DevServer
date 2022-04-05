SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [app].[p_UpdateIsDeletedApplFinancials]
	-- Add the parameters for the stored procedure here
	@ApplFinancialsID int,
	@IsDeleted char(1),
	@UpdatedBy varchar(50) = null
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 10/7/2014
-- Description:	update application financials

/* test data 

EXEC	 [app].[p_UpdateIsDeletedApplFinancials]
		@ApplFinancialsID = 1,
		@IsDeleted = N'N',
		@UpdatedBy = null

*/
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			UPDATE    app.ApplFinancials
			SET     
					IsDeleted = @IsDeleted, 
					DateUpdated = getdate(), 
					UpdatedBy = isnull(@UpdatedBy,suser_sname())
			WHERE  ApplFinancialsID = @ApplFinancialsID
			
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
			WHERE  ApplFinancialsID = @ApplFinancialsID
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
GRANT EXECUTE ON  [app].[p_UpdateIsDeletedApplFinancials] TO [ExecSP]
GO
