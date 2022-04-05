SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [opr].[p_UpdatePaymentLogTransaction]
	-- Add the parameters for the stored procedure here
	@Id int   ,
	@PaymentDate varchar(50) ,
	@ResponseCode varchar(10) ,
	@ResponseReasonCode varchar(10) ,
	@ResponseReasonText varchar(100) ,
	@AuthCode varchar(50) ,
	@TransId varchar(50) ,
	@TransactionTag varchar(50) ,
	@AuthorizationNum varchar(100) ,
	@ClientIp varchar(50) ,
	@SequenceNo varchar(50) ,
	@RetrievalRefNo varchar(50) ,
	@Token varchar(50),
	@CardNumber varchar(20),
	@ExpiryDate varchar(10),
	@CardHolderName varchar(100),
	@TransactionCardType varchar(10),
	@PaymentReceipt varchar(5000),
	@BankResponseCode varchar(3),
	@BankMessage varchar(80),
	@BankResponseCode2 varchar(2)
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- 06/10/2014 sv add @PaymentReceipt
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
						ResponseCode = @ResponseCode, 
						ResponseReasonCode = @ResponseReasonCode, 
						ResponseReasonText = @ResponseReasonText, 
						AuthCode = @AuthCode, 
						TransId = @TransId, 
						TransactionTag = @TransactionTag, 
						AuthorizationNum = @AuthorizationNum, 
						ClientIp = @ClientIp, 
						SequenceNo = @SequenceNo, 
						RetrievalRefNo = @RetrievalRefNo, 
						Token = @Token, 
						DateUpdated = GETDATE(),
						CardNumber = @CardNumber,
						ExpiryDate = @ExpiryDate,
						CardHolderName = @CardHolderName,
						TransactionCardType =@TransactionCardType,
						PayReceipt = @PaymentReceipt,
						BankResponseCode =	@BankResponseCode,
						BankMessage = @BankMessage ,
						BankResponseCode2 = @BankResponseCode2 
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
GRANT EXECUTE ON  [opr].[p_UpdatePaymentLogTransaction] TO [ExecSP]
GO
