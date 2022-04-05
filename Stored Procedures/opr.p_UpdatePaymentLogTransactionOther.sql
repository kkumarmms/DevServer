SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [opr].[p_UpdatePaymentLogTransactionOther]
	-- Add the parameters for the stored procedure here
	@Id int,
	@PaymentDate varchar(50),
	@LoanId int = null,
	@LoanItemId int = null,
	@BatchId varchar(50) = null,
	@CheckNumber varchar(50) = null,
	@DepositDate varchar(50) = null,
	@Comments varchar(500) = null,
	@UpdatedBy varchar(50) = null
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 06/11/2014
-- Description:	update payments for Checks and adjustments
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			UPDATE     dbo.PaymentLog
			SET        PaymentDate = @PaymentDate, 
						LoanId = @LoanId, 
						LoanItemId = @LoanItemId, 
						BatchId = @BatchId, 
						CheckNumber = @CheckNumber, 
						DepositDate = @DepositDate, 
						Comments = @Comments, 
						UpdatedBy = @UpdatedBy, 
						DateUpdated = GETDATE()

			WHERE     (Id = @Id)			
		
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
GRANT EXECUTE ON  [opr].[p_UpdatePaymentLogTransactionOther] TO [ExecSP]
GO
