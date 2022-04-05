CREATE TABLE [rpt].[TenYearForecast_20170504]
(
[Id] [int] NULL,
[PrincipalBalance] [decimal] (9, 2) NULL,
[PrincipalAmtDue] [decimal] (9, 2) NULL,
[Interest] [decimal] (9, 2) NULL,
[InterestDue] [decimal] (9, 2) NULL,
[TotalDue] [decimal] (9, 2) NULL,
[LoanYear] [int] NULL,
[PaymentDate] [date] NULL,
[CurrentFlag] [int] NULL,
[DateCreated] [datetime] NULL
) ON [PRIMARY]
GO
