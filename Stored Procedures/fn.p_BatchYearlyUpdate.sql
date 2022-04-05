SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [fn].[p_BatchYearlyUpdate]

as
/***
	Author: Mike Sherman
	Date:   3/20/2014
	Desc:   Every year on May first SLAP switch to a new billing cycle. main updates are:
			a. change a loan year
			b. move Principal and Interest Due to Principal/Interest OverDue
			c. set new amounts for Principal/interest Due
			d. reset all special agreements
			e. reset PayFlag to 'N'
			f. Update payflag for customers with Sum(principal Due)= 0 to 'X'

	msh 2014-05-07 to use invoicing proc
	msh 2014-05-07 Update payflag for customers with Sum(principal Due)= 0 to 'X'
	msh 2015-04-30 three bugs . 
		1. Principal due show for paid off accounts
		2. Interest due comes from schedule table rather than from 1% of principal balance
		3. Principal due cannot be more than principal balance
	msh 2015-05-04 loans that are out of normal schedule had IntDue and Princ.Due calculated incorrectly
					need left join and isnull to schedule table
	msh 2021-02-17  added code to archine Monthly Billing report at the end of the mothly update. Jira DBA-4206
	msh 2021-02-23  Separated updates from emailing invoices. Jira BUS-291
	msh 2021-04-03  added [School] Column for archiving Monthly Billing report. Jira DBA-4281
***/

set nocount on

begin try


BEGIN TRAN
-- update payFlag to X for students with BOTH loans paid off
-- msh 20150430 
	;wITH PaidOfUsers (UserId)
	as (
			SELECT  c.userid
			FROM			[fn].[LoanCurrState] c
				inner join	 [fn].[LoanItems]	 i on c.LoanItemID = i.loanitemid
				inner join  fn.loans l on l.LoanID = c.LoanID
				where
					( i.LoanItemGroup = 1 or i.LoanItemID = 10) and l.PayFlag <>'X'
					group by c.UserId
					having sum(c.loanItemAmt) =0 -- both loans have no outstanding balances
	)
		--select * from PaidOfUsers where userid =2875
	update l
	set			payFlag ='X'
	from 			PaidOfUsers	u 
		inner join	fn.Loans l on l.UserID = u.UserId


-- Update a loan year
update fn.Loans 
set YearOfLoan = YearOfLoan + 1
	,PayFlag = 'N'
Where PayFlag <>'X'

update fn.LoanCurrState 
set LoanItemAmt = LoanItemAmt + 1
where LoanItemID = 16 
--=and PayFlag <>'X' --msh 20150430

-- update  Principal Overdue. add existing remaining Principal due
	UPDATE o 
	SET o.LoanItemAmt = o.LoanItemAmt + n.LoanItemAmt
	--select * 
	FROM			fn.LoanCurrState o
		INNER JOIN	fn.LoanCurrState n
		ON	o.LoanID = n.LoanID and
			o.LoanItemID = 2 and	--2 - overdue
			n.LoanItemID = 1		--1 - Due

			--where o.userid =2222

--  get new Principal due from Schedule table for the new YearOfLoan
-- some loans run out of main schedule so need left join and isnull conversion
--a.	principal overdue + new table value is less than Principal balance  -> Pr.Due = Table value
--b.	principal overdue + new table value is greater oe equal than Principal balance  -> Pr.Due = Pr.Balance – Pr.OverDue

--  c.LoanItemAmt - "Principal Due"
--  c1.LoanItemAmt - "Principal Balance"
--  c2.LoanItemAmt - "Principal Overdue"
	UPDATE c
	SET c.LoanItemAmt = case 
							when c2.LoanItemAmt+ isnull(s.PrincipalAmtDue,0) < c1.LoanItemAmt
							then isnull(s.PrincipalAmtDue,0)
							else c1.LoanItemAmt - c2.LoanItemAmt
						end								--msh 20150430 - mod 3
	--select 	*
	FROM		fn.LoanCurrState c
		inner join fn.LoanCurrState c1 on c.LoanID = c1.loanid and c1.LoanItemID = 10
		inner join fn.LoanCurrState c2 on c.LoanID = c2.loanid and c2.LoanItemID = 2
		INNER JOIN 	fn.Loans l					on c.LoanID = l.LoanID
		left JOIN dbo.LoanPaymentSchedule s	on  l.MMSLoanID = s.MMSLoanID and l.YearOfLoan = s.LoanYear
	WHERE		
			isnull(s.LoanGroupingCode,0) <>255   and
			c.LoanItemID = 1
		and l.PayFlag <>'X' --msh 20150430


-- update  Interest Due/Overdue
	UPDATE o 
	SET o.LoanItemAmt = o.LoanItemAmt + n.LoanItemAmt
	--select * 
	FROM			fn.LoanCurrState o
		INNER JOIN	fn.LoanCurrState n
	on	o.LoanID = n.LoanID and
		o.LoanItemID = 4 and	-- Interest overdue
		n.LoanItemID = 3		-- Interest due

--  get new Interest due from Schedule table
--select * from dbo.LoanPaymentSchedule
-- some loans run out of main schedule so need left join and isnull conversion. default to 6%
	UPDATE c
	SET c.LoanItemAmt = 0.01 * isnull(s.Interest,6) * c1.LoanItemAmt   --msh 20150430 - mod 2
	--select 	0.01 * isnull(s.Interest,6)* c1.LoanItemAmt,c.*,c1.*
	FROM		fn.LoanCurrState c
		inner join fn.LoanCurrState c1 on c.LoanID = c1.loanid and c1.LoanItemID = 10
		INNER JOIN 	fn.Loans l					on c.LoanID = l.LoanID
		left JOIN dbo.LoanPaymentSchedule s	on  l.MMSLoanID = s.MMSLoanID and l.YearOfLoan = s.LoanYear
	WHERE		
			isnull(s.LoanGroupingCode,0) <>255 and
			c.LoanItemID = 3
			--and c.userid = 2102
			and l.PayFlag <>'X' --msh 20150430


-- reset special agreements
	UPDATE act.UserInfo
	SET PayArrangementFlag =0,
		PayArrangementAmt = 0,
		DelayedPayStartDate = null
			--select * from [act].[UserInfo]
	WHERE PayArrangementFlag <>0









-- generate invoices 
exec [fn].[p_GenerateNewInvoices] --msh 2014-05-07 to use invoicing proc

-- update payFlag to X for students with BOTH loans paid off

	;wITH PaidOfUsers (UserId)
	as (
			SELECT  c.userid
			FROM			[fn].[LoanCurrState] c
				inner join	 [fn].[LoanItems]	 i on c.LoanItemID = i.loanitemid
				inner join  fn.loans l on l.LoanID = c.LoanID
				
			where
					( i.LoanItemGroup = 1 or i.LoanItemID = 10) and l.PayFlag <>'X'
					group by c.UserId
					having sum(c.loanItemAmt) =0 -- both loans have no outstanding balances
	)
--select * from PaidOfUsers where userid =2222
	update l
	set			payFlag ='X'
	from 			PaidOfUsers	u 
		inner join	fn.Loans l on l.UserID = u.UserId

COMMIT TRAN

	exec [rpt].[p_Generate10YearForecastReport]
	-- moved invoicing to separate tidal jobs
	--exec dbo.p_EmailsInvoicesToSend
	--exec  dbo.mms_EmailControl

	--archive MonthlyBilling report
	Insert into [rpt].[MonthlyBilling]
		([UserID], [Name], [School],  [Principal Balance], [Interest Balance], [Principal Due], [Interest Due], [Late Charges], [Total Due])
	exec [rpt].[p_rptMonthlyBilling] 1,1

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
