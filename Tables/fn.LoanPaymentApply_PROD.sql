CREATE TABLE [fn].[LoanPaymentApply_PROD]
(
[LoanPaymentApplyID] [int] NOT NULL,
[UserID] [int] NULL,
[LoanPaymentID] [int] NULL,
[TotalLoanPaidAmt] [decimal] (9, 2) NULL,
[PaymentDate] [datetime] NOT NULL,
[LoanID] [int] NULL,
[LoanSeqNum] [tinyint] NULL,
[LoanItemGroup] [tinyint] NULL,
[LoanItemID] [int] NULL,
[AppliedAmt] [decimal] (9, 2) NULL,
[Adjustments] [decimal] (9, 2) NULL,
[Comments] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateInserted] [datetime] NOT NULL,
[DateUpdated] [datetime] NOT NULL,
[IsDeleted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[InsertedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
