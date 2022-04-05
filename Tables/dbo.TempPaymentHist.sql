CREATE TABLE [dbo].[TempPaymentHist]
(
[LoanPaymentID] [int] NOT NULL,
[LoanSeqNum] [tinyint] NOT NULL,
[PaymentDate] [datetime] NOT NULL,
[TotalPaidAmt] [decimal] (9, 2) NOT NULL,
[TotalLoanPaidAmt] [decimal] (9, 2) NOT NULL,
[PaymentCode] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BatchNo] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PrincipalPaid] [decimal] (38, 2) NOT NULL,
[Principal_OD_Paid] [decimal] (38, 2) NOT NULL,
[InterestPaid] [decimal] (38, 2) NOT NULL,
[Interest_OD_Paid] [decimal] (38, 2) NOT NULL,
[LateFeePaid] [decimal] (38, 2) NOT NULL,
[LateFee_Interest_Paid] [decimal] (38, 2) NOT NULL,
[ReturnedCheckFeePaid] [decimal] (38, 2) NOT NULL,
[PrepaymentPenaltyPaid] [decimal] (38, 2) NOT NULL,
[AdjustmentFlag] [int] NOT NULL,
[PaymentType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
