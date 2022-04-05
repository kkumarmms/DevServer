SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [fn].[p_ApplyPayment]
	@UserID int,
	@PaymentType varchar(6),
	@AmountPaid decimal(9,2),
	@BatchId  varchar(16) = null,
	@DepositDate datetime = null,
    @CheckNumber varchar(16) = null, --CHECK # OR CC REF
    @AdjustmentsFlag bit = 0,
	@Comment varchar(5000) = '',
    @PaymentStatus char(1) =null,
	@IsDeleted char(1) = 'N',
	@InsertedBy varchar(50) = null

AS
/***
	Author: Mike Sherman
	Date:   2014-03-14
	Desc:  Apply payment  to all loans/loanItems. We need to create entry in Payment table, 
	get New paymentId and then add rows to PaymentApply table.
	After that we need to update LoanCurrentState table to reflect this change. All should be in one transaction
	
	2014-05-12 msh fix issue with last payment date . 
								a. missing where clause
								b. We should update only loan that was actually paid. update statement should use @loanid not @user id as a filter
	
	2014-05-12 - 2% fee were not applied - need to check only Sum(Principal_due) = 0 as a criteria
	2014-05-12 - 2% fee -  need a grace period of 30 days from last payment
	2014-06-02 - 2% fee were  applied incorrectly - need to check  Sum(Principal_due + Interest_Due) = 0 as a criteria	
	2014-11-19 - Set default adjustment flag to 0. it was 1 before
	
	2014-11-24 - Shane. Update varchar to userif for string	
	2015-02-11 - msh - remove 2% prepayment penalty

	[fn].[p_ApplyPayment] @UserId=2238, @LoanID= ,@LoanItemId,@AdjAmount=

	EXEC [fn].[p_ApplyPayment]
		@UserID = 2466,
		@PaymentType = N'CC',
		@AmountPaid = 2000,
		@BatchId = N'n/a',
		@DepositDate = N'11/23/2014 16:57:00 PM',
		@CheckNumber = N'n/a',
		@AdjustmentsFlag = 0,
		@Comment = N'CC Payment',
		@PaymentStatus = NULL,
		@IsDeleted = 'N',
		@InsertedBy = N'msherman@mms.org'



***/

SET NOCOUNT ON

BEGIN

BEGIN TRY
BEGIN TRANSACTION

DECLARE	 @LoanItemGroup INT =1,
		 @LoanPaymentID INT,
		 @LoanId int,
		 @LoanItemId int,
		 @LoanSeqNum int,
		 @ItemAmount int,
		 @TotalPaidPerLoan decimal(9,2),
		 @PaymentDate datetime,
		 @LastPaymentDate datetime,
		 @PaymentCode varchar(16),
		 @TotalDue decimal(9,2),
		 @MinLoanId int,
		 @TotalPrincipalBalance decimal(9,2)

SET @InsertedBy = ISNULL(@InsertedBy,SUSER_SNAME())
SET @PaymentDate =ISNULL(@DepositDate,GETDATE())
SET @PaymentCode = isnull(@CheckNumber,'')


--Populate paymentApply staging table with prospect payments per item
delete from [fn].[PaymentApply_Stage]
INSERT [fn].[PaymentApply_Stage] --select * from [fn].PaymentApply_Stage
exec [fn].[p_ShowSuggestedPaymentApply] @UserId , @AmountPaid ,@DepositDate
--exec [fn].[p_ShowSuggestedPaymentApply] 2466,2000,'2014-11-23 16:57'

--****************************************************************
--  IF PREPAYMENT PENALTY IS APPLICABLE SEND EMAIL TO Ofelia Teixeira
 if exists (select LoanID from  [fn].[PaymentApply_Stage] where LoanItemId = 12)
	BEGIN
		declare @body varchar (1000)
		set @body ='Payment towards Prepayment Penalty was made for User ' + convert(varchar(10), @UserID)
				exec  msdb.dbo.sp_send_dbmail
				@Profile_Name	= 'CEFUND',
				@recipients		= 'msherman@mms.org;oteixeira@mms.org;svatasoiu@mms.org' , -- only for testing
				@Subject		= 'Payments to Prepayment Penalty' ,
				@Body			= @body ,
				@Body_Format			= 'HTML'
	END

--****************************************************************
-- FIRST NEED TO CHECK IF PREPAYMENT PENALTY IS APPLICABLE AND UPDATE LoanCurrentState IF NEEDED

-- get current total principal balance
	select @TotalPrincipalBalance = sum(cs.LoanItemAmt)
	from fn.LoanCurrState cs 
	where	cs.UserId = @UserId 
			and cs.LoanItemID = 10

-- need to apply 2% prepayment penalty first. (Balance due = 0 ). We apply it to the "Oldest" Loan - Sequence Number = 1

-- get loanid for the oldest loan
		SELECT 	@MinLoanId = c.LoanID
		FROM 	fn.Loans c
		where	c.UserID = @UserId 
		and c.LoanSeqNum = 1

-- get Total Principal due + Interest Due from CurrentState table 
		SELECT 
				@TotalDue = isnull(sum(c.LoanItemAmt),0)
				
		FROM 
					fn.LoanCurrState c
		inner join	fn.LoanItems i          on c.LoanItemID = i.LoanItemID
		where  c.UserId = @UserID 
				and i.LoanItemID in ( 1,2,3,4) -- msh added 2014-05-12 + 2014-06-02

-- get Last Payment date
		SELECT 	@LastPaymentDate = max(c.LoanLastPaymentDate)
		FROM 	fn.Loans c
		where   c.UserID = @UserID		

------ Following block applies 2% prepayment penalty
------***********************************************
----		if @TotalDue <=0 and @AmountPaid >0 and DATEDIFF(DD,@LastPaymentDate,@PaymentDate) >30
----		begin
----			if exists	(	select  LoanItemAmt
----							from fn.LoanCurrState cs
----							where		cs.UserId = @UserId 
----									and cs.LoanItemID = 12
----						) --prepay penalty already exists for the loan

----				update fn.LoanCurrState  
----				set LoanItemAmt = convert(decimal (9,2),0.02 * @TotalPrincipalBalance) + LoanItemAmt
----				where	UserId = @UserId 
----						and LoanID = @MinLoanId 
----						and LoanItemID = 12
----			else										-- first time financial charge
----				insert fn.LoanCurrState 
----					(
----					UserId, 
----					LoanID, 
----					LoanItemID, 
----					LoanItemAmt, 
----					PayFlag, 
----					Comments, 
----					DateInserted, 
----					DateUpdated, 
----					IsDeleted, 
----					InsertedBy, 
----					UpdatedBy
----					)
----				SELECT
----					UserId =		@UserId,
----					LoanID =		@MinLoanId,
----					LoanItemID =	12,
----					LoanItemAmt =	convert(decimal (9,2),0.02 * @TotalPrincipalBalance),
----					PayFlag =		1,
----					Comments =		'',
----					DateInserted =	getdate(),
----					DateUpdated =	getdate(),
----					IsDeleted =		'N',
----					InsertedBy =	suser_sname(),
----					UpdatedBy =		suser_sname()


----		end
------  end applying 2% prepayment penalty
--*********************************************


--****************************************************************

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
		  ,@AmountPaid
		  ,@PaymentType
		  ,@PaymentCode
		  ,@AdjustmentsFlag
		  ,@Comment
		  ,@BatchId
		  ,@PaymentStatus
		  ,GETDATE()
		  ,GETDATE()
		  ,@IsDeleted
		  ,@InsertedBy
		  ,SUSER_SNAME()
--GET NEW PAYMENTID
	SET @LoanPaymentID = SCOPE_IDENTITY()

-- Add a line to PaymentApply table
;With TotalPaidByLoan (LoanID, TotalPaid)
as (
	select	LoanID, 
			LoanItemPaid=Sum(LoanItemPaid)
	FROM	[fn].[PaymentApply_Stage]
	Group by LoanID
	)
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
           ,cte.TotalPaid
           ,@PaymentDate
           ,st.Loanid
           ,st.LoanSeqNum
           ,@LoanItemGroup
           ,st.LoanItemID
           ,st.LoanItemPaid
           ,@AdjustmentsFlag
           ,@Comment
		   ,GETDATE()
		   ,GETDATE()
		   ,@IsDeleted
		   ,@InsertedBy
		   ,SUSER_SNAME()
		   --select *
FROM      [fn].[PaymentApply_Stage] st
inner join TotalPaidByLoan cte on st.Loanid = cte.LoanID

--************************************************************************************
--   NOW WE NEED TO UPDATE CURRENT TOTALS AND RUNNING VALUES 
-- Update Loan Current Status to reflect payments except principal balance and totals
UPDATE [fn].[LoanCurrState]
SET
	   [LoanItemAmt]	= [LoanItemAmt] - p.LoanItemPaid
      ,[DateUpdated]	= GETDATE()
      ,[IsDeleted]		= @IsDeleted
      ,[UpdatedBy]		= SUSER_SNAME()
--select *
FROM		[fn].[LoanCurrState] c 
inner join	[fn].[PaymentApply_Stage] p
		on  c.LoanID		=	p.Loanid
		and c.LoanItemID	=	p.LoanItemId
where  c.LoanItemID <> 10 --to avoid double counting of amount paid directly towards principal
--***********
--  TOTAL INTEREST PAID - Update Loan Current Status to reflect cumulative values:  total interest paid etc
-- 
;with TotalPayment ( LoanID, LoanItemPaid)
	as
	(
	-- get total payment towards INTEREST
	select p.Loanid, LoanItemPaid = sum(LoanItemPaid)
		FROM		[fn].[PaymentApply_Stage] p
		WHERE p.LoanItemId in (3,4)
		group by p.Loanid
	)

	UPDATE [fn].[LoanCurrState]
	SET
		   [LoanItemAmt]	=	[LoanItemAmt] + p.LoanItemPaid	 -- increase total interest paid
		  ,[DateUpdated]	= GETDATE()
		  ,[IsDeleted]		= @IsDeleted
		  ,[UpdatedBy]		= SUSER_SNAME()
	--select *
	FROM			[fn].[LoanCurrState] c 
		inner join	TotalPayment p		on  c.LoanID		=	p.Loanid
	WHERE c.LoanItemID = 15 -- total interest paid

--***********
--  TOTAL FINANCIAL CHARGES - Update Loan Current Status to reflect cumulative values: TOTAL FINANCIAL CHARGESd etc
-- 
;with TotalPayment ( LoanID, LoanItemPaid)
	as
	(
	-- get total payment towards FINANCIAL CHARGES
	select p.Loanid, LoanItemPaid = sum(p.LoanItemPaid)
		FROM		[fn].[PaymentApply_Stage] p
		WHERE p.LoanItemId in (5,7,8,12)
		group by p.Loanid
	)

	UPDATE [fn].[LoanCurrState]
	SET
		   [LoanItemAmt]	=	[LoanItemAmt] + isnull(p.LoanItemPaid,0)	
		  ,[DateUpdated]	= GETDATE()
		  ,[IsDeleted]		= @IsDeleted
		  ,[UpdatedBy]		= SUSER_SNAME()
	--select *
	FROM			[fn].[LoanCurrState] c 
		inner join	TotalPayment p		on  c.LoanID		=	p.Loanid
	WHERE c.LoanItemID = 18 and p.LoanItemPaid is not null


--***********
-- Need additional update to substract Principal due, principal overdue and direct payment toward principal from current principal amount
;with TotalPrincipalPayment ( LoanID, LoanItemPaid)
	as
	(
	-- get total payment towards principal
	select p.Loanid, LoanItemPaid = sum(LoanItemPaid)
		FROM		[fn].[PaymentApply_Stage] p
		WHERE p.LoanItemId in (1,2,10)
		group by p.Loanid
	)

	UPDATE [fn].[LoanCurrState]
	SET
		   [LoanItemAmt]	=	case c.LoanItemID 
									when 10 then [LoanItemAmt] - p.LoanItemPaid  -- reduce remaining principal
									when 14 then [LoanItemAmt] + p.LoanItemPaid	 -- increase total principle paid
								end
		  ,[DateUpdated]	= GETDATE()
		  ,[IsDeleted]		= @IsDeleted
		  ,[UpdatedBy]		= SUSER_SNAME()
	--select *
	FROM			[fn].[LoanCurrState] c 
		inner join	TotalPrincipalPayment p		on  c.LoanID		=	p.Loanid
	WHERE c.LoanItemID in (10,14)

--select * FROM [fn].[PaymentApply_Stage]
--***********
-- Final update to change lastpaymentdate
-- mod msh 2014-05-12
	; with LastPay (LoanID, LastPayDate)
		as
		(
		select 
			LoanID, 
			LastPayDate = max(PaymentDate) 
		FROM [fn].[LoanPaymentApply]
		where UserID = @userId
		group by LoanID
		)

		--select p.*,l.* 
		update l set LoanLastPaymentDate = p.LastPayDate
		from LastPay p 
		inner join fn.loans l on p.LoanID = l.loanid
		where isnull(l.LoanLastPaymentDate,'1/1/1900') <> p.LastPayDate

-- Update PayFlag in fn.Loans table

	exec fn.p_UpdateLoanPayFlag @UserID=@UserId , @LoanID = null ,@PayAmt=@AmountPaid 
 
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
