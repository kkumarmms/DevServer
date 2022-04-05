CREATE TABLE [fn].[PaymentApply_Stage]
(
[Rowid] [int] NULL,
[Loanid] [int] NULL,
[LoanSeqNum] [int] NULL,
[LoanItemId] [int] NULL,
[LoanItemDescr] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoanItemDue] [decimal] (9, 2) NULL,
[LoanItemPaid] [decimal] (9, 2) NULL,
[LoanPaymentRemains] [decimal] (9, 2) NULL
) ON [PRIMARY]
GO
