SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [fn].[p_BatchMonthlyUpdate]

as
/***
	Author: Mike Sherman
	Date:   3/20/2014
	Desc:   Every month need to recalculate financial chargesto generate invoices
			main rules 
			a. 1% fee on items 1,2,3,4,5,7 after Sept 1 till April of next year
			need to check for special arrangements - first pay date and pay amount

			b. If loan is overdue then we need to apply 1% fee even after May 1 till september
				for existing loans on May first all "DUE" become "Overdue" 
				so we should calculate 1 % only on items 2,4,5,7 - exclude 1,3 - new principal/interest due

				drop table #DoNotCharge

	2014-06-02 msh we should not assess 1% on any fees only items 1,2,3,4 should be considered
	2014-06-05 msh we do not need to check for delayed start in June-August. Access late fee on overdue amt only
	2014-06-05 msh default "delayed start" should be always greater than getdate() - changed to 1/1/2100
	2021-02-17 msh added code to archive Monthly Billing report at the end of the mothly update. Jira DBA-4206
	2021-04-03 msh added [School] Column for archiving Monthly Billing report. Jira DBA-4281

***/

set nocount on

truncate table dbo.schedule_stage  -- just to reset identity

begin try
	select distinct loanid
	into #DoNotCharge
	from fn.LoanCurrState c
	where c.LoanItemID = 19 and LoanItemAmt =1
-- make sure we are within valid dates
IF month(getdate()) >= 9 or month(getdate()) <= 4
	begin
	-- get loans with stopped flag for new fees


		;with TempFee (LoanId, USERID,FeeAmt)
		 as 
		 (
		  SELECT 
			c.LoanID, 
			C.USERID ,
			FeeAmt = sum(c.LoanItemAmt) * 0.01
		  FROM fn.LoanCurrState c
		  WHERE c.LoanItemID in(1,2,3,4) 
		  GROUP BY c.LoanID,C.USERID
		  HAVING sum(c.LoanItemAmt) <> 0
		 )

		 Update cs 
		 set LoanItemAmt = LoanItemAmt + f.FeeAmt
		 --SELECT * 
		 FROM fn.LoanCurrState cs
		 inner join TempFee f on cs.LoanID = f.LoanId
		 inner join act.UserInfo u on cs.UserId = u.UserID
		 left join #DoNotCharge ex on cs.LoanID = ex.LoanID
		 where	cs.LoanItemID = 5 
				and isnull(u.DelayedPayStartDate,'1/1/2100') > getdate()
				and ex.LoanID is null
	end

--Only for OVERDUE amounts from existing loans between May and August
ELSE
	begin
	-- get loans with stopped flag for new fees

		;with TempFee (LoanId, USERID,FeeAmt)
		 as 
		 (
		  SELECT 
			c.LoanID, 
			C.USERID ,
			FeeAmt = sum(c.LoanItemAmt) * 0.01
		  FROM fn.LoanCurrState c
		  WHERE c.LoanItemID in(2,4) --and userid = 2238
		  GROUP BY c.LoanID,C.USERID
		  HAVING sum(c.LoanItemAmt) <> 0
		 )

		 Update cs 
		 set LoanItemAmt = LoanItemAmt + f.FeeAmt
		 --SELECT * 
		 FROM fn.LoanCurrState cs
		 inner join TempFee f on cs.LoanID = f.LoanId
		 inner join act.UserInfo u on cs.UserId = u.UserID
		 left join #DoNotCharge ex on cs.LoanID = ex.LoanID
		 where	cs.LoanItemID = 5 
				--and isnull(u.DelayedPayStartDate,'1/1/1900') > getdate()
				and ex.LoanID is null
	end

-- generate invoices
	truncate table fn.Invoices_Stage
	exec [fn].[p_GenerateNewInvoices]

	--archive MonthlyBilling report
	Insert into [rpt].[MonthlyBilling]
		([UserID], [Name], [School], [Principal Balance], [Interest Balance], [Principal Due], [Interest Due], [Late Charges], [Total Due])
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
