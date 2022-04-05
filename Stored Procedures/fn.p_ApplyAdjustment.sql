SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [fn].[p_ApplyAdjustment]
	@UserID int,
	@LoanID int,
	@LoanSeqNum int =1,
	@LoanItemGroup int =1,
	@LoanItemId int,
	@AdjAmount decimal(9,2),
	@PaymentDate datetime = null,
	@PaymentType varchar(6) ='ADJ',
    @PaymentCode varchar(16) = null,
    @AdjustmentsFlag bit = 1,
	@Comments varchar(5000),
    @BatchNo  varchar(16) = null,
    @PaymentStatus char(1) =null,
	@IsDeleted char(1) = 'N',
	@InsertedBy varchar(50)

AS
/***
	Author: Mike Sherman
	Date:   2014-03-14
	Desc:  Apply adjustment to the loan. We need to create entry in Payment table, get New paymentId and then add row to PaymentApply table.
	After that we need to update LoanCurrentState table to reflect this change. All should be in one transaction
	[fn].[p_AdjustmentApply] @UserId=2238, @LoanID= ,@LoanItemId,@AdjAmount=
***/

SET NOCOUNT ON

BEGIN

BEGIN TRY
BEGIN TRANSACTION

DECLARE @LoanPaymentID INT
SET @InsertedBy = ISNULL(@InsertedBy,SUSER_SNAME())
SET @PaymentDate =ISNULL(@PaymentDate,GETDATE())

-- add entry to fn.Payment Table
INSERT INTO [fn].[LoanPayment]
           (
		    [UserID]
           ,[PaymentDate]
           ,[TotalPaidAmt]
           ,[PaymentType]
           ,[PaymentCode]
           ,[AdjustmentsFlag]
           ,[Comments]
           ,[BatchNo]
           ,[PaymentStatus]
           ,[DateInserted]
           ,[DateUpdated]
           ,[IsDeleted]
           ,[InsertedBy]
           ,[UpdatedBy]
		   )
 SELECT
		   @UserID
		  ,@PaymentDate
		  ,@AdjAmount
		  ,@PaymentType
		  ,@PaymentCode
		  ,@AdjustmentsFlag
		  ,@Comments
		  ,@BatchNo
		  ,@PaymentStatus
		  ,GETDATE()
		  ,GETDATE()
		  ,@IsDeleted
		  ,@InsertedBy
		  ,SUSER_SNAME()
--GET NEW PAYMENTID
	SET @LoanPaymentID = SCOPE_IDENTITY()

-- Add a line to PaymentApply table
INSERT INTO [fn].[LoanPaymentApply]
           (
		    [UserID]
           ,[LoanPaymentID]
           ,[TotalLoanPaidAmt]
           ,[PaymentDate]
           ,[LoanID]
           ,[LoanSeqNum]
           ,[LoanItemGroup]
           ,[LoanItemID]
           ,[AppliedAmt]
           ,[Adjustments]
           ,[Comments]
           ,[DateInserted]
           ,[DateUpdated]
           ,[IsDeleted]
           ,[InsertedBy]
           ,[UpdatedBy]
		   )
SELECT
		    @UserID
           ,@LoanPaymentID
           ,@AdjAmount
           ,@PaymentDate
           ,@LoanID
           ,@LoanSeqNum
           ,@LoanItemGroup
           ,@LoanItemID
           ,@AdjAmount
           ,@AdjustmentsFlag
           ,@Comments
		   ,GETDATE()
		   ,GETDATE()
		   ,@IsDeleted
		   ,@InsertedBy
		   ,SUSER_SNAME()

-- Update Loan Current Status to reflecl adjustment
UPDATE [fn].[LoanCurrState]
SET
	   [LoanItemAmt]	= [LoanItemAmt] - @AdjAmount
      ,[DateUpdated]	= GETDATE()
      ,[IsDeleted]		= @IsDeleted
      ,[UpdatedBy]		= SUSER_SNAME()
WHERE
			[UserId]	= @UserID
       and	[LoanID]	= @LoanID
       and	[LoanItemID]= @LoanItemId

--********************************************************
--********************************************************
-- --   NOW WE NEED TO UPDATE CURRENT TOTALS  to reflect adjustment
UPDATE [fn].[LoanCurrState]
SET
	   [LoanItemAmt]	= [LoanItemAmt] - @AdjAmount
      ,[DateUpdated]	= GETDATE()
      ,[IsDeleted]		= @IsDeleted
      ,[UpdatedBy]		= SUSER_SNAME()
WHERE
			[UserId]	= @UserID
       and	[LoanID]	= @LoanID
       and	[LoanItemID]=	case 
								when @LoanItemId in (5,7,8,12) then 18 --fin charges paid total
								when @LoanItemId in (3,4) then 15 --interest paid total
								when @LoanItemId in (1,2,10) then 14 -- principal paid total									
							end


-- --   NOW WE NEED TO UPDATE Balances  to reflect adjustment
UPDATE [fn].[LoanCurrState]
SET
	   [LoanItemAmt]	= [LoanItemAmt] + @AdjAmount
      ,[DateUpdated]	= GETDATE()
      ,[IsDeleted]		= @IsDeleted
      ,[UpdatedBy]		= SUSER_SNAME()
WHERE
			[UserId]	= @UserID
       and	[LoanID]	= @LoanID
       and	[LoanItemID]=	case 
									when @LoanItemId in (1,2,10) then 10 -- principal	balance									
							end

-- update PayFlag in fn.Loans table
	exec fn.p_UpdateLoanPayFlag @UserID=@UserId , @LoanID = @LoanID ,@PayAmt=@AdjAmount 	 
COMMIT TRANSACTION  
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	--log error in table
	
	exec dbo.p_DBA_LogError

	declare @errProc nvarchar(126),
			@errLine int,
			@errMsg  nvarchar(max)
	select  @errProc = error_procedure(),
			@errLine = error_line(),
			@errMsg  = error_message()
	

	--raise error to front end
	raiserror('Proc: %s - Line: %d - Error: %s', 12 ,1 ,@errProc, @errLine, @errMsg)
	return(-1)
	--select  @errProc, @errLine, @errMsg ,'Job completed with errors - Notify developer'

END CATCH
END






GO
GRANT EXECUTE ON  [fn].[p_ApplyAdjustment] TO [ExecSP]
GO
