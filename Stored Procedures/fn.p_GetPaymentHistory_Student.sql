SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [fn].[p_GetPaymentHistory_Student] 
	@UserID int
as
/***
	Author: Mike Sherman
	Date:   2014-03-03
	Desc:  Get full payment history for a student. Need to pivot results to present on front end
			Reuse fn.p_GetPaymentHistory_Admin code and add grouping to get summary by user if user has two loans

	select * from [fn].[LoanPayment] where userid = 2238
	select * from [fn].[LoanPaymentApply] where userid = 2238
	fn.[p_GetPaymentHistory_Student] 2238
***/

set nocount on

begin try

--declare @UserID int =2238
declare @AllUserPayments table 

(
	[LoanPaymentID] [int] NOT NULL,
	[LoanSeqNum] [tinyint] NOT NULL,
	[PaymentDate] [datetime] NOT NULL,
	[TotalPaidAmt] [decimal](9, 2) NOT NULL,
	[TotalLoanPaidAmt] [decimal](9, 2) NOT NULL,
	[PaymentCode] [varchar](16) NOT NULL,
	[BatchNo] [varchar](16) NOT NULL,
	[PrincipalPaid] [decimal](38, 2) NOT NULL,
	[Principal_OD_Paid] [decimal](38, 2) NOT NULL,
	[InterestPaid] [decimal](38, 2) NOT NULL,
	[Interest_OD_Paid] [decimal](38, 2) NOT NULL,
	[LateFeePaid] [decimal](38, 2) NOT NULL,
	[LateFee_Interest_Paid] [decimal](38, 2) NOT NULL,
	[ReturnedCheckFeePaid] [decimal](38, 2) NOT NULL,
	[PrepaymentPenaltyPaid] [decimal](38, 2) NOT NULL,
	[AdjustmentFlag] [int] NOT NULL,
	[PaymentType] [varchar](6) NOT NULL
)
insert @AllUserPayments
exec fn.[p_GetPaymentHistory_Admin] @UserID
--select * from @AllUserPayments

select 

            [PaymentDate]
           ,[TotalPaidAmt] -- =			sum([TotalPaidAmt])
           ,[PrincipalPaid]=			sum([PrincipalPaid])
           ,[Principal_OD_Paid]=		sum([Principal_OD_Paid])
           ,[InterestPaid]=				sum([InterestPaid])
           ,[Interest_OD_Paid]=			sum([Interest_OD_Paid])
           ,[LateFeePaid]=				sum([LateFeePaid])
           ,[LateFee_Interest_Paid]=	sum([LateFee_Interest_Paid])
		   ,[LateFeePaid_Total] =		sum([LateFeePaid] + [LateFee_Interest_Paid])
           ,[ReturnedCheckFeePaid]=		sum([ReturnedCheckFeePaid])
           ,[PrepaymentPenaltyPaid]=	sum([PrepaymentPenaltyPaid])
           ,[PaymentType] 
from @AllUserPayments
group by
           [PaymentDate]
           ,[TotalPaidAmt]
           ,[PaymentType]
		   ,LoanPaymentID

order by PaymentDate
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
