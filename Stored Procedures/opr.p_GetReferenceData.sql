SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [opr].[p_GetReferenceData]
	@Requestor VARCHAR(25),
	@IncludeDeleted CHAR(1)
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			

					--raise error to front end
		declare @errProc1 nvarchar(126),
				@errLine1 int,
				@errMsg1  nvarchar(max)
		select  @errProc1 = error_procedure(),
				@errLine1 = error_line(),
				@errMsg1  = error_message()
		raiserror('Proc: %s - Line: %d - Error: %s', 12 ,1 ,@errProc1, @errLine1, 'not used')


			--Begin code
			--SELECT    CodeDescID AS CodeID, Code, CodeDescription AS Description
			--FROM      opr.CodeLookup
			--WHERE     (TableName = 'UserInfo') AND (FieldName = 'UserType')		
			
		
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
