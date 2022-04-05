CREATE TABLE [fn].[Invoices_Stage]
(
[UserID] [int] NOT NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiddleInitial] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Title] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InstitutionName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoanApprovedDate] [datetime] NOT NULL,
[Loan2ApprovedDate] [datetime] NULL,
[LoanLastPaymentDate] [datetime] NULL,
[StopLateFee] [decimal] (9, 2) NOT NULL,
[LoanID] [int] NOT NULL,
[LoanAmt] [decimal] (9, 2) NULL,
[PayFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Comments] [varchar] (7000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProjectedInterest] [numeric] (9, 2) NULL,
[LoanSeqNum] [tinyint] NOT NULL,
[LegacySchedCode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrincipalDue] [decimal] (9, 2) NOT NULL,
[PrincipalOverdue] [decimal] (9, 2) NOT NULL,
[InterestDue] [decimal] (9, 2) NOT NULL,
[InterestOverdue] [decimal] (9, 2) NOT NULL,
[Latefee] [decimal] (9, 2) NOT NULL,
[LateFeeInterest] [decimal] (9, 2) NOT NULL,
[ReturnedCheckFee] [decimal] (9, 2) NOT NULL,
[PrepaidPenalty] [decimal] (9, 2) NOT NULL,
[Balance] [decimal] (9, 2) NOT NULL,
[PrincipalPaidTotal] [decimal] (9, 2) NOT NULL,
[InterestPaidTotal] [decimal] (9, 2) NOT NULL,
[YearOfLoan] [int] NULL,
[FinancialChargesPaidTotal] [decimal] (9, 2) NOT NULL,
[TotalDue] [decimal] (9, 2) NULL,
[TotalOverDue] [decimal] (9, 2) NULL,
[DoNotSendInvoiceFlag] [bit] NOT NULL CONSTRAINT [DF_Invoices_Stage_DoNotSendInvoiceFlag] DEFAULT ((0)),
[DateInserted] [datetime] NULL CONSTRAINT [DF_Invoices_Stage_DateInserted] DEFAULT (getdate()),
[TotalPrincipalDue] [decimal] (9, 2) NULL,
[TotalFees] [decimal] (9, 2) NULL,
[PayArrangementFlag] [bit] NULL,
[PayArrangementAmt] [decimal] (9, 2) NULL,
[DelayedPayStartDate] [date] NULL,
[PayArrangementComment] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [fn].[Invoices_Stage] ADD CONSTRAINT [PK_Invoices_Stage] PRIMARY KEY CLUSTERED ([UserID], [LoanID]) ON [PRIMARY]
GO