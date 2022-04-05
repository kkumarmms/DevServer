CREATE TABLE [fn].[Loans_Hist]
(
[LoanID] [int] NOT NULL IDENTITY(1, 1),
[UserID] [int] NOT NULL,
[ApplicationID] [int] NOT NULL,
[MMSLoanID] [smallint] NOT NULL,
[LoanSeqNum] [tinyint] NOT NULL,
[LoanAmt] [decimal] (9, 2) NULL,
[LoanApprovedDate] [datetime] NOT NULL,
[LoanFirstPaymentDate] [datetime] NULL,
[LoanLastPaymentDate] [datetime] NULL,
[LoanStatus] [tinyint] NULL,
[Comments] [varchar] (7000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[YearOfLoan] [tinyint] NULL,
[DateInserted] [datetime] NOT NULL CONSTRAINT [DF_Loans_Hist_DateInserted] DEFAULT (getdate()),
[DateUpdated] [datetime] NOT NULL CONSTRAINT [DF_Loans_Hist_DateUpdated] DEFAULT (getdate()),
[IsDeleted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Loans_Hist_IsDeleted] DEFAULT ('N'),
[InsertedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Loans_Hist_InsertedBy] DEFAULT (suser_sname()),
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Loans_Hist_UpdatedBy] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [fn].[Loans_Hist] ADD CONSTRAINT [PK_Loans_Hist] PRIMARY KEY CLUSTERED ([LoanID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Loans_Hist] ON [fn].[Loans_Hist] ([UserID], [LoanSeqNum], [LoanAmt]) ON [PRIMARY]
GO
