SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [fn].[p_ShowSuggestedPaymentApply]
	@UserId int, 
	@Payment decimal(9,2),
	@DepositDate datetime = null
as
/***
	Author: Mike Sherman
	Date:   2014-03-04
	Desc:   Show payments applied to Loan items according to the Business rules

	mod 2014-03-24 - delete from output rows woth paid_amount = 0
	mod 2014-05-12 - 2% fee were not applied - need to check only Sum(Principal_due) = 0 as a criteria
	mod 2014-05-12 - added e-mail to bill for overpayments of paid off loans
	mod 2014-06-02 - 2% fee were  applied incorrectly - need to check  Sum(Principal_due + Interest_Due) = 0 as a criteria	
	2015-01-23 - msh - remove 2% prepayment penalty
	 fn.p_ShowSuggestedPaymentApply 2329, 477
***/

set nocount on

begin try



/* --Testing
--select * from #LoanCurrState
--select * from #Payinvoice
--select * from #Output
--drop table #LoanCurrState	
--drop table #Payinvoice
--drop table #Output
declare
	@UserId int, 
	@Payment decimal(9,2)

set @UserId =3241
set @Payment =11000
*/

declare 	@TotalDue decimal(9,2)
declare 	@MinLoanId int
declare		@TotalPrincipalBalance decimal(9,2)
declare 	@AmtRemaining decimal(9,2)
declare		@LastPaymentDate datetime
declare		@PaymentDate datetime

SET @PaymentDate =ISNULL(@DepositDate,GETDATE())
-- create temp table LoanCurrentState to avoid updates to live table
	select * 
	into #LoanCurrState
	from fn.LoanCurrState l
	where	l.UserId = @UserId
			and (l.LoanItemAmt <>0 or l.LoanItemID = 14)
--select * from #LoanCurrState
-- get current total principal balance
	select @TotalPrincipalBalance = sum(cs.LoanItemAmt)
	from #LoanCurrState cs 
	where	cs.UserId = @UserId 
			and cs.LoanItemID = 10

-- need to apply 2% prepayment penalty first. (Balance due = 0 ). We apply it to the "Oldest" Loan - Sequence Number = 1

-- get loanid for the oldest loan
		SELECT 	@MinLoanId = c.LoanID
		FROM 	fn.Loans c
		where	c.UserID = @UserId 
		and c.LoanSeqNum = 1

-- get Total due from CurrentState table
		SELECT 
				@TotalDue = isnull(sum(c.LoanItemAmt),0)
		FROM 
					#LoanCurrState c
		inner join	fn.LoanItems i          on c.LoanItemID = i.LoanItemID
		where  c.UserId = @UserID 
				and i.LoanItemID in ( 1,2,3,4) -- msh added 2014-05-12 + 2014-06-02

-- get Last Payment date
		SELECT 	@LastPaymentDate = max(c.LoanLastPaymentDate)
		FROM 	fn.Loans c
		where   c.UserID = @UserID		

------ Following block applies 2% prepayment penalty
------***********************************************
----		if @TotalDue <=0 and @Payment >0 and DATEDIFF(DD,@LastPaymentDate,@PaymentDate) >30
----		begin
----			if exists	(	select  LoanItemAmt
----							from #LoanCurrState cs
----							where		cs.UserId = @UserId 
----									and cs.LoanItemID = 12
									
----						) --prepay penalty
----				update #LoanCurrState  
----				set LoanItemAmt = convert(decimal (9,2),0.02 * @TotalPrincipalBalance) + LoanItemAmt
----				where UserId = @UserId and LoanID = @MinLoanId and LoanItemID = 12
----			else
----				insert #LoanCurrState 
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
------*********************************************
--create base invoicing table
--declare @Payinvoice Table 
create table #Payinvoice
	(
	Rowid int identity(1,1),
	LoanItemPayOrderID int,
	Loanid int,
	LoanSeqNum int,
	LoanItemId int, 
	LoanItemDescr Varchar(50),
	LoanItemAmt money
	)   
insert #Payinvoice
	(
	li.LoanItemPayOrderID,
	Loanid ,
	LoanSeqNum ,
	LoanItemId , 
	LoanItemDescr ,
	LoanItemAmt 
	)
SELECT 

	li.LoanItemPayOrderID,
	l.loanID,
	l.LoanSeqNum,
	li.LoanItemID,
--, li.LoanItemPayOrderID
	li.LoanItemDescr ,
	cs.LoanItemAmt


FROM			fn.Loans l
	cross join   fn.LoanItems li
	inner join   #LoanCurrState cs on l.LoanID = cs.LoanID and li.LoanItemID = cs.LoanItemID
WHERE --l.UserID = @UserId and
	  li.LoanItemGroup = 1 
	and li.IsDeleted = 'N'
	and cs.PayFlag = 1
	and cs.LoanItemAmt <>0
UNION

SELECT

		li.LoanItemPayOrderID,
		cs.LoanID,
		l.LoanSeqNum,
		LoanItemID = 10,
		LoanItemDescr ='Principal Balance',
		PrincipalBalance=l.LoanAmt - cs.LoanItemAmt
		--select *
  FROM			#LoanCurrState cs
  inner join	fn.LoanItems li on cs.LoanItemID = li.LoanItemID
  inner join	fn.Loans l on l.LoanID = cs.LoanID
  where		--cs.UserId = @UserId and
		 cs.LoanItemID = 14  -- item 14 - total principal paid to date
order by	li.LoanItemPayOrderID,
			l.LoanSeqNum
--select * from #LoanCurrState

-- need to adjust principal balance to reflect proposed payments towards principal due and principal overdue

;with NewPrincipalBal (LoanID,NewLoanPrincipalBal)
as 
(
	select 
		p1.Loanid,
		NewLoanPrincipalBal = max(p1.LoanItemAmt) - sum(p2.LoanItemAmt )
	from		#Payinvoice p1 
	inner join	#Payinvoice p2 on		p1.Loanid = p2.Loanid 
									and p1.LoanItemId = 10 
									and p2.LoanItemId in( 1,2)
	group by p1.Loanid
)
UPDATE p1 
SET LoanItemAmt = p2.NewLoanPrincipalBal
FROM		#Payinvoice p1 
INNER JOIN	NewPrincipalBal p2 on p1.Loanid = p2.Loanid and p1.LoanItemId = 10 




select		
			Rowid,    
			Loanid, 
			LoanSeqNum,
			LoanItemId, 
			LoanItemDescr,  
			LoanItemAmt ,
			case 
				when prior_payment_remaining is null and @Payment <= LoanItemAmt then  @Payment  -- FIRST LINE of payments is not calculated through 'unbound preceeding' correctly    
				when payment_remaining > 0									then LoanItemAmt        
				when payment_remaining <= 0 and prior_payment_remaining > 0 then prior_payment_remaining    -- partial payment for the last pay item    
				else 0    
			end as paid_amount,   
			case 
				when payment_remaining > 0 
				then payment_remaining 
				else 0 
			end amount_remaining
into #Output
from 
	(
	select		Rowid,    
				Loanid,    
				LoanSeqNum, 
				LoanItemId,
				LoanItemDescr, 
				LoanItemAmt,  
				sum(LoanItemAmt) over (order by Rowid rows unbounded preceding) as total_applied,   
				@payment - sum(LoanItemAmt) over (order by Rowid rows unbounded preceding) as payment_remaining,    
				@payment - sum(LoanItemAmt) over (order by Rowid rows between unbounded preceding and 1 preceding) as prior_payment_remaining --shift one left to get the amount previous for the first negative.  the previous amount is the remainder that would subtract from the next invoiced total

	from #Payinvoice
	) tmp

--if there is a remaining amout not applied to the loans it should be applies to the last principal and send e-mail to Bill
-- that there is an overpayment for a closed loan and reimbursment needed for the user  
if (select top 1  o.amount_remaining from #Output o order by Rowid desc) > 0 
	begin
	declare @MaxRowId int
	declare @subject varchar (100)
	set @AmtRemaining = (select top 1  o.amount_remaining from #Output o order by Rowid desc)
	set @subject = 'Unapplied amount of $' + Convert(varchar(10),@AmtRemaining) +' remains on paid off account '+ Convert(varchar(10),@UserId) +'.'
	
	EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'CEFUND',
    @recipients = 'oteixeira@mms.org',
	@copy_recipients = 'msherman@mms.org',
    @body = 'Not all amount received was applied to account',
    @subject = @subject ;




	select @MaxRowId = max(rowid) from #Output
	update #Output 
	set paid_amount = paid_amount + amount_remaining ,
		amount_remaining = 0
	where RowId = @MaxRowId
	 
	end

delete from #Output where paid_amount = 0
select * from #Output

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
