SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [fn].[p_UpdateLoanPayFlag]
	@UserID int,
	@LoanID int = null,
	@PayAmt decimal(9,2)

as
/***
	Author: Mike Sherman
	Date:   2014-04-03
	Desc:  Update Loan Pay flag after each Payment or adjustment transaction
			On may first all loans become 'N', after first payment - 'P', If no Due - 'Y'
			if no due and principal balance 0 - paid in full --'X'
			New loans before May 1 - 'A'

	2014-05-07 msh commented out changes to set flag to 'X' we do that only on May 1
***/

set nocount on

begin try
declare 
	@TotalOutstanding decimal(9,2),
	@TotalDue decimal(9,2),
	@Balance decimal(9,2),
	@PayFlag Char (1)

--NEED TO UPDATE PayFlag FOR BOTH LOANS SEPERATELY. NEED A LOOP 
--start a loop if LoanID not supplied
	if @LoanID is null
	BEGIN
		 
		Select @LoanID = min(LoanID) 
						FROM  [fn].[Loans]
						where UserID = @UserID

		WHILE @LoanID is not null
		BEGIN
		--
			SELECT @TotalOutstanding = sum(c.loanItemAmt)
			FROM			[fn].[LoanCurrState] c
				inner join	 [fn].[LoanItems]	 i on c.LoanItemID = i.loanitemid
			where c.LoanID = @LoanID 
					and ( i.LoanItemGroup = 1 or i.LoanItemID = 10) -- All Items Due + Principal balance

			SELECT @TotalDue = sum(c.loanItemAmt)
			FROM			[fn].[LoanCurrState] c
				inner join	 [fn].[LoanItems]	 i on c.LoanItemID = i.loanitemid
			where c.LoanID = @LoanID 
					and ( i.LoanItemGroup = 1 ) -- All Items Due
			
			UPDATE [fn].[Loans] 
			SET PayFlag =		CASE
									--WHEN	@TotalOutstanding = 0	THEN 'X' -- PAID IN FULL

									WHEN	@TotalOutstanding >= 0 
										AND @TotalDue = 0			THEN 'Y' -- ALL DUES FOR CURRENT YEAR PAID			
									
									WHEN	@TotalOutstanding >= 0 
										AND @TotalDue > 0 
										AND @PayAmt > 0				THEN 'P' -- PARTIAL PAYMENT		
											
									WHEN	@TotalOutstanding >= 0 
										AND @TotalDue > 0 
										AND PayFlag = 'Y'			THEN 'P' -- adjustment that increased total due 

-- need logic to revert payFlag from 'P' to 'N'
									ELSE PayFlag
								End	
			FROM  [fn].[Loans]
			WHERE		LoanID = @LoanID	
					AND PayFlag <> 'X'
					AND IsDeleted = 'N'
				
		-- loop to next Loanid
				Select @LoanID = min(LoanID) 
						FROM  [fn].[Loans]
						where	UserID = @UserID 
							and LoanID > @LoanID
		END
	END

-- all other cases when @LoanID provided to the proc
-- same code as above but no loop needed
	if @LoanID <> 0 
	BEGIN
		--
			SELECT @TotalOutstanding = sum(c.loanItemAmt)
			FROM			[fn].[LoanCurrState] c
				inner join	 [fn].[LoanItems]	 i on c.LoanItemID = i.loanitemid
			where c.LoanID = @LoanID 
					and ( i.LoanItemGroup = 1 or i.LoanItemID = 10) -- All Items Due + Principal balance

			SELECT @TotalDue = sum(c.loanItemAmt)
			FROM			[fn].[LoanCurrState] c
				inner join	 [fn].[LoanItems]	 i on c.LoanItemID = i.loanitemid
			where c.LoanID = @LoanID 
					and ( i.LoanItemGroup = 1 ) -- All Items Due
			
			UPDATE [fn].[Loans] 
			SET PayFlag =		CASE
									--WHEN	@TotalOutstanding = 0	THEN 'X' -- PAID IN FULL

									WHEN	@TotalOutstanding >= 0 
										AND @TotalDue = 0			THEN 'Y' -- ALL DUES FOR CURRENT YEAR PAID			
									
									WHEN	@TotalOutstanding >= 0 
										AND @TotalDue > 0 
										AND @PayAmt > 0				THEN 'P' -- PARTIAL PAYMENT		
											
									WHEN	@TotalOutstanding >= 0 
										AND @TotalDue > 0
										AND @PayAmt <> 0											 
										AND PayFlag = 'Y'			THEN 'P' -- adjustment that increased total due 

-- need additional logic to revert payFlag from 'P' to 'N'
									ELSE PayFlag
								END	
			FROM  [fn].[Loans]
			WHERE		LoanID = @LoanID	
					AND PayFlag <> 'X'
					AND IsDeleted = 'N'
		
	END
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
	Return (-1)
end catch

GO
