SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [fn].[p_UpdateLoanNoLateFeeFlag]
	-- Add the parameters for the stored procedure here
	@UserId int,
	@LoanId int,
	@NoLateFeeFlag bit
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- 2014-06-09 msh changed "update" block. IF @NoLateFeeFlag ='1' then Item 19 should be set to 1
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try
	declare @loanItemID int

		begin tran

			select @loanItemID = li.[LoanItemID] 
								from [fn].[LoanItems] li
								where  [LoanItemDescr] = 'Stop Late Fee'

			if not exists(select LoanItemID 
				from  [fn].[LoanCurrState] 
				where UserId = @UserId 
									and LoanID = @LoanId
									and LoanItemID = @loanItemID )
			begin
			-- make sure the record exsits
					insert [fn].[LoanCurrState] 
					(
						[UserId],
						[LoanID],
						[LoanItemID],
						[LoanItemAmt]
					)
						select 
						@UserId,
						@LoanId,
						@loanItemID,
						0
			end

				IF @NoLateFeeFlag ='1'
				begin

					UPDATE  [fn].[LoanCurrState] 
					SET [LoanItemAmt] = 1
					WHERE	UserId = @UserId 
						and LoanID = @LoanId
						and LoanItemID = @loanItemID
				end

				ELSE
				begin
					UPDATE  [fn].[LoanCurrState] 
					SET [LoanItemAmt] = 0
					WHERE	UserId = @UserId 
						and LoanID = @LoanId
						and LoanItemID = @loanItemID
				end

		
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
GRANT EXECUTE ON  [fn].[p_UpdateLoanNoLateFeeFlag] TO [ExecSP]
GO
