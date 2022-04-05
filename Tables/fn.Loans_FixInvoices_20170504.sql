CREATE TABLE [fn].[Loans_FixInvoices_20170504]
(
[LoanID] [int] NOT NULL,
[UserID] [int] NOT NULL,
[ApplicationID] [int] NOT NULL,
[MMSLoanID] [smallint] NOT NULL,
[LoanSeqNum] [tinyint] NOT NULL,
[LoanAmt] [decimal] (9, 2) NULL,
[ProjectedInterest] [decimal] (9, 2) NULL,
[LoanApprovedDate] [datetime] NOT NULL,
[LoanFirstPaymentDate] [datetime] NOT NULL,
[LoanLastPaymentDate] [datetime] NULL,
[LoanStatus] [smallint] NULL,
[PayFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comments] [varchar] (7000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[YearOfLoan] [tinyint] NULL,
[DateInserted] [datetime] NOT NULL,
[DateUpdated] [datetime] NOT NULL,
[IsDeleted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[InsertedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
