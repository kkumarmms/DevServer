SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [fn].[p_GetLoanSummary] 
	@UserID int

as
/***
	Author: Mike Sherman
	Date:  2014/02/28 
	Desc:  get summary information of the current state of each loan for the user

	exec fn.p_GetLoanSummary 5841 --2238--3240

	2014-05-12 msh past due and late fees should be seperated

	2014-10-16 msh - need to eliminate interest due for year-of-loan 0 
case when convert(int,isnull([Year of loan],0)) = 0 then 0 else isnull([Interest Due],0) end
***/

set nocount on

begin try
--begin tran
 select 
 UserID = @UserID
 ,LoanApprovedDate
 ,Loan2ApprovedDate = case when [LoanSeqNum] = 2 then LoanApprovedDate else null end
 ,LoanLastPaymentDate
 ,isnull([Stop Late Fee],0) [Stop Late Fee]
 ,[LoanID]
 ,[LoanAmt]
 ,[PayStatus]
 ,isnull([Comments],'') [Comments]
 ,[InterestAmtDue] [Projected Interest]
 ,[LoanSeqNum]
 ,[LegacySchedCode]
 ,isnull([Principal Due],0) [Principal Due]
 ,isnull([Principal Overdue],0) [Principal Overdue]
 ,case when convert(int,isnull([Year of loan],0)) = 0 then 0 else isnull([Interest Due],0) end [Interest Due]
 ,isnull([Interest Overdue],0) [Interest Overdue]
 ,isnull([Late fee],0) [Late fee]
 ,isnull([Late fee Interest],0) [Late fee Interest]
 ,isnull([Returned Check fee],0) [Returned Check fee]
 ,isnull([Prepaid Penalty],0) [Prepaid Penalty]
 ,isnull(([LoanAmt] - isnull([Principal Paid to date],0)),0) [Balance]
 ,isnull([Principal Paid to date],0) [Principal Paid to date]
 ,isnull([Interest paid to date],0) [Interest paid to date]
 ,convert(int,isnull([Year of loan],0)) [Year of loan]
 ,isnull([Total Financial Charges Paid],0) [Total Financial Charges Paid]
 ,[Total Due] =  isnull([Principal Due],0)
				+case when convert(int,isnull([Year of loan],0)) = 0 then 0 else isnull([Interest Due],0) end
 ,TotalOverDue = isnull([Principal Overdue],0)
				+isnull([Interest Overdue],0)

 ,TotalFees	   = isnull([Late fee],0)
				+isnull([Late fee Interest],0)
				+isnull([Returned Check fee],0)
				+isnull([Prepaid Penalty],0)

 ,[Total] =  isnull([Principal Due],0)
				+isnull([Principal Overdue],0)
				+case when convert(int,isnull([Year of loan],0)) = 0 then 0 else isnull([Interest Due],0) end
				+isnull([Interest Overdue],0)
				+isnull([Late fee],0)
				+isnull([Late fee Interest],0)
				+isnull([Returned Check fee],0)
				+isnull([Prepaid Penalty],0)
 FROM  (
		SELECT 
			c.LoanID,
			l.LoanSeqNum,
			i.LoanItemDescr,
			c.LoanItemAmt,
			l.LoanApprovedDate,
			l.LoanLastPaymentDate,
			l.LoanAmt,
			PayStatus=l.PayFlag,
			l.Comments,
			s.InterestAmtDue,
			mms.LegacySchedCode
			--select *
		FROM 
		 [fn].[LoanCurrState] c
		inner join fn.Loans l					on c.LoanID = l.LoanID
		inner join [fn].[LoanItems] i			on c.LoanItemID = i.LoanItemID
		inner join dbo.LoanPaymentSchedule s on l.MMSLoanID = s.MMSLoanID
		inner join opr.MMSLoans mms		on mms.MMSLoanID = l.MMSLoanID
		where	c.UserId = @UserID 
				and s.LoanYear = 255
				--and c.IsDeleted <> 'Y' --msh 2020-10-30
		) p
	PIVOT
	 (
	 Sum (LoanItemAmt)
	 FOR LoanItemDescr
	 IN (   

		 [Principal Due]
		 ,[Principal Overdue]
		 ,[Interest Due]
		 ,[Interest Overdue]
		 ,[Late fee]
		 ,[Late fee Interest]
		 ,[Stop Late Fee]
		 ,[Returned Check fee]
		 ,[Prepaid Penalty]
		 ,[Principal Balance]
		 ,[Principal Paid to date]
		 ,[Interest paid to date]
		 ,[Year of loan]
		 ,[Total Financial Charges Paid]
		 )
	 ) AS pvt
order by  LoanSeqNum

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
