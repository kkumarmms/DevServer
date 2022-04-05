CREATE TABLE [rpt].[TenYearForecast]
(
[Id] [int] NULL,
[PrincipalBalance] [decimal] (9, 2) NULL,
[PrincipalAmtDue] [decimal] (9, 2) NULL,
[Interest] [decimal] (9, 2) NULL,
[InterestDue] [decimal] (9, 2) NULL,
[TotalDue] [decimal] (9, 2) NULL,
[LoanYear] [int] NULL,
[PaymentDate] [date] NULL,
[CurrentFlag] [int] NULL CONSTRAINT [DF_TenYearForecast_CurrentFlag] DEFAULT ((0)),
[DateCreated] [datetime] NULL CONSTRAINT [DF_TenYearForecast_DateCreated] DEFAULT (getdate())
) ON [PRIMARY]
GO
