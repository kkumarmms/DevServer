CREATE TABLE [dbo].[PaidLoansDetailedReport1]
(
[UserID] [int] NOT NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[InstitutionName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LegacyCode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Loan1] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Loan1 Date] [date] NULL,
[L1NoLateChargeFlag] [decimal] (9, 2) NOT NULL,
[Loan1Comments] [varchar] (7000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Loan2] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Loan2 Date] [date] NULL,
[L2NoLateChargeFlag] [decimal] (9, 2) NOT NULL,
[Loan2Comments] [varchar] (7000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastPaymentDate] [date] NULL,
[PrincipalBalance] [decimal] (38, 2) NULL,
[PayArrangementFlag] [bit] NULL,
[PayArrangementComment] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastPaymentAmt] [decimal] (38, 2) NULL,
[TotalDue] [decimal] (38, 2) NULL
) ON [PRIMARY]
GO
