CREATE TABLE [fn].[LoanPaymentApply]
(
[LoanPaymentApplyID] [int] NOT NULL IDENTITY(1, 1),
[UserID] [int] NULL,
[LoanPaymentID] [int] NULL,
[TotalLoanPaidAmt] [decimal] (9, 2) NULL,
[PaymentDate] [datetime] NOT NULL CONSTRAINT [DF_LoanPaymentApply_PaymentDate] DEFAULT (getdate()),
[LoanID] [int] NULL,
[LoanSeqNum] [tinyint] NULL,
[LoanItemGroup] [tinyint] NULL,
[LoanItemID] [int] NULL,
[AppliedAmt] [decimal] (9, 2) NULL,
[Adjustments] [decimal] (9, 2) NULL,
[Comments] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateInserted] [datetime] NOT NULL CONSTRAINT [DF_LoanPaymentApply_DateInserted] DEFAULT (getdate()),
[DateUpdated] [datetime] NOT NULL CONSTRAINT [DF_LoanPaymentApply_DateUpdated] DEFAULT (getdate()),
[IsDeleted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoanPaymentApply_IsDeleted] DEFAULT ('N'),
[InsertedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoanPaymentApply_InsertedBy] DEFAULT (suser_sname()),
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoanPaymentApply_UpdatedBy] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [fn].[LoanPaymentApply] ADD CONSTRAINT [PK_LoanPaymentApply] PRIMARY KEY CLUSTERED ([LoanPaymentApplyID]) ON [PRIMARY]
GO
ALTER TABLE [fn].[LoanPaymentApply] ADD CONSTRAINT [FK_LoanPaymentApply_LoanItems] FOREIGN KEY ([LoanItemID]) REFERENCES [fn].[LoanItems] ([LoanItemID])
GO
ALTER TABLE [fn].[LoanPaymentApply] ADD CONSTRAINT [FK_LoanPaymentApply_LoanPayment] FOREIGN KEY ([LoanPaymentID]) REFERENCES [fn].[LoanPayment] ([LoanPaymentID])
GO
ALTER TABLE [fn].[LoanPaymentApply] ADD CONSTRAINT [FK_LoanPaymentApply_Loans] FOREIGN KEY ([LoanID]) REFERENCES [fn].[Loans] ([LoanID])
GO
