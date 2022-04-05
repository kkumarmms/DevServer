CREATE TABLE [rpt].[MonthlyMaster]
(
[Acct] [int] NULL,
[Name] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Date Of Loan1] [datetime] NULL,
[Date Of Loan2] [datetime] NULL,
[Original Principal] [decimal] (9, 2) NULL,
[Principal Paid to Date] [decimal] (9, 2) NULL,
[Principal Balance] [decimal] (9, 2) NULL,
[Original Interest] [decimal] (9, 2) NULL,
[Interest Paid to Date] [decimal] (9, 2) NULL,
[Current Principal Due] [decimal] (9, 2) NULL,
[Current Interest Due] [decimal] (9, 2) NULL,
[Late Charges Owed] [decimal] (9, 2) NULL,
[DateCreated] [datetime] NOT NULL CONSTRAINT [DF_MonthlyMaster_DateCreated] DEFAULT (getdate())
) ON [PRIMARY]
GO
