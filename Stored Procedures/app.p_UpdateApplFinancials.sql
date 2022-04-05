SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [app].[p_UpdateApplFinancials]
	-- Add the parameters for the stored procedure here
	@ApplFinancialsID int,
	@ApplicationId int,
	@FinType varchar(1),
	@Description varchar(50)= null,
	@Value decimal(9,2) = null,
	@IsDeleted char(1)='N',
	@UpdatedBy varchar(50)
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	update application financials

/* test data 

EXEC	 [app].[p_UpdateApplFinancials]
		@ApplFinancialsID = 1,
		@ApplicationId = 1,
		@FinType = N'E',
		@Description = N'test',
		@Value = 1.0,
		@IsDeleted = N'N',
		@UpdatedBy = N'debug'

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
					Description = @Description, 
					Value = @Value, 
					IsDeleted = @IsDeleted, 
					DateUpdated = getdate(), 
					UpdatedBy = @UpdatedBy
			WHERE   (ApplicationId = @ApplicationId) 
					AND (FinType = @FinType) 
					AND (ApplFinancialsID = @ApplFinancialsID)
			
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
			WHERE   (ApplicationId = @ApplicationId) 
					AND (FinType = @FinType) 
					AND (ApplFinancialsID = @ApplFinancialsID)
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
GRANT EXECUTE ON  [app].[p_UpdateApplFinancials] TO [ExecSP]
GO
