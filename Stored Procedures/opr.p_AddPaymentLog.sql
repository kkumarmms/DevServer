SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [opr].[p_AddPaymentLog]
	-- Add the parameters for the stored procedure here
	@UserId int, 
	@Amount decimal(9,2), 
	@PayType varchar(50),
	@InvoiceNum varchar(50)
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
			
			--Begin code
			INSERT      
			INTO       dbo.PaymentLog(
						UserId, 
						Amount, 
						PayType,
						InvoiceNum)
			VALUES     (@UserId, 
						@Amount, 
						@PayType,
						@InvoiceNum)
			
			select SCOPE_IDENTITY() as 'Id'
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
GRANT EXECUTE ON  [opr].[p_AddPaymentLog] TO [ExecSP]
GO
