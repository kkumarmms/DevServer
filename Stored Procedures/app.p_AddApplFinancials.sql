SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [app].[p_AddApplFinancials]
	-- Add the parameters for the stored procedure here
	@ApplicationId int,
	@FinType varchar(1),
	@Description varchar(50),
	@Value decimal(9,2)=null,
	@DisplayOrder int,
	@IsDeleted char(1),
	@InsertedBy varchar(50)
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	add applications financials for an application

/* test data

EXEC	 [app].[p_AddApplFinancials]
		@ApplicationId = 1,
		@FinType = N'R',
		@Description = N'test',
		@Value = 1.1,
		@DisplayOrder = 1,
		@IsDeleted = N'N',
		@InsertedBy = N'debug'

*/
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			INSERT INTO app.ApplFinancials
                      (ApplicationId, 
					  FinType, 
					  Description, 
					  Value, 
					  DisplayOrder,
					  IsDeleted, 
					  InsertedBy,
					  DateInserted)
			VALUES     (@ApplicationId, 
					@FinType, 
					@Description, 
					@Value, 
					@DisplayOrder,
					@IsDeleted,
					 @InsertedBy, 
					 getdate())
			
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
			WHERE     (ApplFinancialsID = scope_identity()) 
		
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
GRANT EXECUTE ON  [app].[p_AddApplFinancials] TO [ExecSP]
GO
