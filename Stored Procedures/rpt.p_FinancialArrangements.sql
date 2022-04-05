SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [rpt].[p_FinancialArrangements] 
(@NumMonthInactive int)
AS
BEGIN
/* =============================================
-- Author:		Mike Sherman
-- Create date: '9/1/2021'
-- Description:	Get list of students with Financial Arrangements within last 18 month


exec RPT.[p_FinancialArrangements] 18
-- =============================================
*/
	SET NOCOUNT ON;
BEGIN TRY
-- Get list of student with open loans who did not make payments in the last 18 month
;with LastPayment as 
(
			select 
				c.UserID ,
				LastPaymentDate=convert(date,max(l.LoanLastPaymentDate))
			from fn.LoanCurrState c
			inner join  fn.Loans l  on c.LoanID = l.LoanID
			where LoanItemID in (10)
			group by c.UserID
			having sum(c.LoanItemAmt) > 0 
			--and isnull ( max(l.LoanLastPaymentDate) ,'1/1/1900')  < dateadd(month,-@NumMonthInactive,getdate())
			--and isnull ( max(l.LoanApprovedDate) ,'1/1/1900')  < dateadd(month,-@NumMonthInactive,getdate())
)
,
	-- get loans and student summary
UserDetails as
(
	select
		u.UserID,
		u.FirstName,
		u.LastName,
		i.InstitutionName,
		i.LegacyCode,
		Loan1 = Replace(lt1.Description,'MMS Loan ',''),
		[Loan1 date] = convert(date,l1.LoanApprovedDate),
		L1NoLateChargeFlag = isnull(cs1.loanitemamt,0),
		Loan1Comments = l1.Comments  ,
		
		Loan2 =  Replace(lt2.Description,'MMS Loan ',''),
		[Loan2 date] = convert(date,l2.LoanApprovedDate),
		L2NoLateChargeFlag = isnull(cs2.loanitemamt,0),
		Loan2Comments = l2.Comments  ,
		PrincipalBalance= (select Sum(LoanItemAmt) from  fn.LoanCurrState where UserID = u.UserID and LoanItemID = 10 Group by UserID),
		TotalDue = (select sum(loanitemamt) from fn.LoanCurrState  lcs  where UserID = u.UserID and (LoanItemID < 10 or LoanItemID = 12))  ,
		u.PayArrangementFlag,
		u.PayArrangementComment

		--select *
	from [act].[UserInfo] u
	inner join [opr].[Institution] i on u.InstitutionID = i.InstitutionID
	inner join fn.loans l1 on u.UserID = l1.UserID
	left join fn.loans l2 on l1.UserID = l2.UserID and l1.LoanSeqNum = 1 and l2.LoanSeqNum = 2
	left join [opr].[MMSLoans] lt1 on l1.MMSLoanID = lt1.MMSLoanID
	left join [opr].[MMSLoans] lt2 on l2.MMSLoanID = lt2.MMSLoanID
	left join  fn.LoanCurrState cs1 on cs1.LoanID = l1.LoanID and cs1.LoanItemID = 19 
	left join  fn.LoanCurrState cs2 on cs2.LoanID = l2.LoanID and cs2.LoanItemID = 19 
	where l1.LoanSeqNum = 1 
	and (		u.PayArrangementFlag <>0
			or	len(u.PayArrangementComment) > 0
			or	 isnull(cs1.loanitemamt,0) <> 0
			or	len(l1.Comments) > 0
			or	 isnull(cs2.loanitemamt,0) <> 0
			or	len(l2.Comments) > 0
		)
)

select 
		ud.UserID,
		ud.FirstName,
		ud.LastName,
		ud.InstitutionName,
		ud.LegacyCode,
		ud.Loan1,
		ud.[Loan1 Date],
		ud.L1NoLateChargeFlag,
		ud.Loan1Comments,
		ud.Loan2,
		ud.[Loan2 Date],
		ud.L2NoLateChargeFlag,
		ud.Loan2Comments,
		lp.LastPaymentDate,
		ud.PrincipalBalance,
		ud.PayArrangementFlag,
		ud.PayArrangementComment,
		LastPaymentAmt = (select sum(TotalPaidAmt) from [fn].[LoanPayment] pmt where ud.UserID = pmt.UserID and convert(Date,pmt.PaymentDate) = convert(Date,lp.LastPaymentDate)),
		ud.TotalDue

from		UserDetails ud
inner join	LastPayment lp on ud.UserID = lp.UserID
--left Join fn.LoanPayment pay on ud.UserID = pay.UserID and isnull(lp.LastPaymentDate,'1901-01-01') = pay.PaymentDate  

order by 		ud.UserId
			
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
