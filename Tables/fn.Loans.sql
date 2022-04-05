CREATE TABLE [fn].[Loans]
(
[LoanID] [int] NOT NULL IDENTITY(1, 1),
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
[DateInserted] [datetime] NOT NULL CONSTRAINT [DF_Loans_DateInserted] DEFAULT (getdate()),
[DateUpdated] [datetime] NOT NULL CONSTRAINT [DF_Loans_DateUpdated] DEFAULT (getdate()),
[IsDeleted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Loans_IsDeleted] DEFAULT ('N'),
[InsertedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Loans_InsertedBy] DEFAULT (suser_sname()),
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Loans_UpdatedBy] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [fn].[Loans] ADD CONSTRAINT [pk_loans_pid] PRIMARY KEY CLUSTERED ([LoanID]) ON [PRIMARY]
GO
ALTER TABLE [fn].[Loans] ADD CONSTRAINT [FK_Loans_UserInfo] FOREIGN KEY ([UserID]) REFERENCES [act].[UserInfo] ([UserID])
GO
