SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [opr].[p_GetMMSLoans]
	-- Add the parameters for the stored procedure here
	@Requestor varchar(50),
	@IncludeDeleted char(1) = 'N',
	@MMSLoanID smallint = 0
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
			--raiserror('Proc: %s - Line: %d - Error: %s', 12 ,1 ,'developer', 'generated', 'error')
			--Begin code
			SELECT  MMSLoanID, 
					Code, 
					LoanAmount, 
					Description, 
					LoanTerm, 
					DateInserted, 
					DateUpdated, 
					IsDeleted, 
					InsertedBy, 
					UpdatedBy
			FROM         opr.MMSLoans
			WHERE 1=1
			    AND ((@IncludeDeleted = 'Y') or (IsDeleted = 'N') )
				AND ((@MMSLoanID <= 0) or (MMSLoanID = @MMSLoanID))
			
		
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
