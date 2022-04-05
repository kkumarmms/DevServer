CREATE TABLE [fn].[LoanPayment]
(
[LoanPaymentID] [int] NOT NULL IDENTITY(1, 1),
[UserID] [int] NULL,
[PaymentDate] [datetime] NOT NULL CONSTRAINT [DF_LoanPayment_PaymentDate] DEFAULT (getdate()),
[PrincipalBalance] [decimal] (9, 2) NULL,
[TotalPaidAmt] [decimal] (9, 2) NULL,
[PaymentType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentCode] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdjustmentsFlag] [bit] NULL,
[Comments] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BatchNo] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentStatus] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateInserted] [datetime] NOT NULL CONSTRAINT [DF_LoanPayment_DateInserted] DEFAULT (getdate()),
[DateUpdated] [datetime] NOT NULL CONSTRAINT [DF_LoanPayment_DateUpdated] DEFAULT (getdate()),
[IsDeleted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoanPayment_IsDeleted] DEFAULT ('N'),
[InsertedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoanPayment_InsertedBy] DEFAULT (suser_sname()),
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoanPayment_UpdatedBy] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [fn].[LoanPayment] ADD CONSTRAINT [PK_LoanPayment] PRIMARY KEY CLUSTERED ([LoanPaymentID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_LoanPayment_UserID] ON [fn].[LoanPayment] ([UserID]) ON [PRIMARY]
GO
