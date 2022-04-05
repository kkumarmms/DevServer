CREATE TABLE [dbo].[LoanSummary_OneTime_Temp]
(
[UserId] [int] NULL,
[LoanApprovedDate] [datetime] NOT NULL,
[LoanLastPaymentDate] [datetime] NULL,
[Stop Late Fee] [decimal] (38, 2) NOT NULL,
[LoanID] [int] NOT NULL,
[LoanAmt] [decimal] (9, 2) NULL,
[PayStatus] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Comments] [varchar] (7000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Projected Interest] [numeric] (9, 2) NULL,
[LoanSeqNum] [tinyint] NOT NULL,
[LegacySchedCode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Principal Due] [decimal] (38, 2) NOT NULL,
[Principal Overdue] [decimal] (38, 2) NOT NULL,
[Interest Due] [decimal] (38, 2) NOT NULL,
[Interest Overdue] [decimal] (38, 2) NOT NULL,
[Late fee] [decimal] (38, 2) NOT NULL,
[Late fee Interest] [decimal] (38, 2) NOT NULL,
[Returned Check fee] [decimal] (38, 2) NOT NULL,
[Prepaid Penalty] [decimal] (38, 2) NOT NULL,
[Balance] [decimal] (38, 2) NOT NULL,
[Principal Paid to date] [decimal] (38, 2) NOT NULL,
[Interest paid to date] [decimal] (38, 2) NOT NULL,
[Year of loan] [decimal] (38, 2) NOT NULL,
[Total Financial Charges Paid] [decimal] (38, 2) NOT NULL,
[Total Due] [decimal] (38, 2) NULL
) ON [PRIMARY]
GO
