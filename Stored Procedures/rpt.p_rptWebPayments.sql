SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








--exec [rpt].[p_rptWebPayments] '2/1/2000','2/28/2015'


CREATE PROCEDURE [rpt].[p_rptWebPayments] 
(@FromDate date
,@ToDate date)
AS
BEGIN
-- =============================================
-- Author:		Andre Barber
-- Create date: '3/24/2014'
-- Description:	Web payment report Margaret Misilo for Student Loan System
-- Modified 06112014 only allow payment type of CC for credit cards
-- =============================================

	SET NOCOUNT ON;

	if ((ISNULL(@FromDate,'')='') or (ISNULL(@ToDate,'')=''))
		BEGIN
			SET @FromDate = DATEADD(m,-1,GetDate())	
			SET @ToDate = GetDate()
		END
	
	begin try	
				
						
					SELECT 
				  [UserId]
				  ,[Amount]
				  ,[PayType]
				  ,[InvoiceNum]
				  ,[PaymentDate]
				  ,[ResponseCode]
				  ,[ResponseReasonCode]
				  ,[ResponseReasonText]
				  ,[AuthCode]
				  ,[TransId]
				  ,[TransactionTag]
				  ,[AuthorizationNum]
				  ,[SequenceNo]
				  ,[RetrievalRefNo]
				  ,[CardNumber]
				  ,[TransactionCardType]= case [TransactionCardType] when 'VISA' then 'VISA/MASTERCARD'
																	 when 'MASTERCARD' then 'VISA/MASTERCARD'
																	 when 'AMERICAN E' then 'AMEX'
																	 else [TransactionCardType] end
				  ,[CardHolderName]
				  ,[AppliedToLoan]
				  ,[AppliedToLoanDate]
				  ,[AppliedToLoanMessage]
				  ,[DateInserted]
				  ,[DateUpdated]
			  FROM [SLAP].[dbo].[PaymentLog]
			  WHERE PaymentDate between @FromDate and @ToDate
			  and ISNULL([CardHolderName],'')<>''
			  and ISNULL([TransactionCardType],'')<>''
			  and ISNULL([CardNumber],'')<>''
			  and ResponseCode = 1
			  and PayType = 'CC'
			  ORDER BY [UserId],[TransactionCardType],[DateInserted] 	
						
						
			
			
	end try
	begin catch
		--if a transaction was started, rollback
		--if @@trancount > 0
		--begin
		--	rollback tran
		--end
			
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
