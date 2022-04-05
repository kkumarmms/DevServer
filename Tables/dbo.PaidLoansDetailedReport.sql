CREATE TABLE [dbo].[PaidLoansDetailedReport]
(
[Account] [int] NOT NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Institution] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoanNumber] [tinyint] NOT NULL,
[Loan1Date] [datetime] NULL,
[Loan1Type] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Loan2Date] [datetime] NULL,
[Loan2Type] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DatePaid] [datetime] NULL,
[LastPaymentAmount] [decimal] (9, 2) NULL,
[AmountAppliedToPrincipalBalance] [decimal] (9, 2) NULL,
[AmountAppliedToInterest] [decimal] (9, 2) NULL,
[TotalPrincipalBorrowed] [decimal] (9, 2) NULL,
[TotalInterest] [decimal] (9, 2) NULL,
[TotalInterestPaid] [decimal] (9, 2) NULL,
[PercentageofTotalInterestPaid] [decimal] (9, 2) NULL,
[TotalLateChargesPaid] [decimal] (9, 2) NULL,
[PaidOffInNoOfMonths] [int] NULL,
[LastInterestRate] [numeric] (9, 2) NULL
) ON [PRIMARY]
GO
