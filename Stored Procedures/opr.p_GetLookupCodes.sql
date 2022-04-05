SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [opr].[p_GetLookupCodes]
	-- Add the parameters for the stored procedure here
	@CodeType varchar(50) = '',
	@FieldName varchar(50) = ''
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	get codes based on filter

/*

EXEC	[opr].[p_GetLookupCodes]
		@CodeType = N'Loans',
		@FieldName = ''
*/
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			SELECT  CodeDescID, 
					CodeType, 
					FieldName, 
					Code, 
					CodeDescription, 
					CodeDescriptionInternal
			FROM         opr.CodeLookup
			WHERE     ((isnull(@CodeType,'')='') or (CodeType = @CodeType))
					and ((isnull(@FieldName,'')='') or (FieldName = @FieldName))

			
		
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
GRANT EXECUTE ON  [opr].[p_GetLookupCodes] TO [ExecSP]
GO
