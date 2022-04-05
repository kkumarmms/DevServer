SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [app].[p_UpdateApplicationLoanType]
	-- Add the parameters for the stored procedure here
	@ApplicationID int,
	@NewMMSLoanId int,
	@UpdatedBy varchar(50)
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
			/*
			get info for log
			*/
			declare @UserId int
			declare @CurrentMMSLoanId int
			declare @CurrentLoanAmt decimal(9,2)			
			declare @NewLoanAmt decimal(9,2)
			declare @Comment varchar(1000)

			SELECT  @NewLoanAmt = LoanAmount
			FROM   opr.MMSLoans
			WHERE  (MMSLoanID = @NewMMSLoanId)

			select @UserId = a.userId,
				@CurrentMMSLoanId = a.MMSLoanID,
				@CurrentLoanAmt = a.LoanAmt
			from app.Application a
			where a.ApplicationID=@ApplicationID

			--Begin code
			UPDATE  app.Application
			SET     MMSLoanID = @NewMMSLoanId, 
					LoanAmt = @NewLoanAmt, 
					DateUpdated = GETDATE(), 
					UpdatedBy = @UpdatedBy
			WHERE   (ApplicationID = @ApplicationID)
			


			set @Comment = 'Modified the Loan type from type ' + CONVERT(varchar, @CurrentMMSLoanId)  + ' (value=' + CONVERT(varchar, @CurrentLoanAmt) + ')' + ' to ' + CONVERT(varchar, @NewMMSLoanId) + ' (value=' + CONVERT(varchar, @NewLoanAmt) + ')'

			--insert log information
			INSERT INTO [dbo].[OperationsLog]
				   ([UserId]
				   ,[ApplicationId]
				   ,[Comment]
				   ,[InsertedBy])
			 VALUES
				   (@UserId
				   ,@ApplicationID
				   ,@Comment
				   ,@UpdatedBy)
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
