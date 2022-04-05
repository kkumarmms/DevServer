CREATE TABLE [dbo].[LoanPaymentSchedule]
(
[LoanPaymentScheduleID] [tinyint] NOT NULL IDENTITY(1, 1),
[MMSLoanID] [tinyint] NULL,
[LoanYear] [tinyint] NULL,
[PrincipalBalance] [numeric] (9, 2) NULL,
[PrincipalAmtDue] [numeric] (9, 2) NULL,
[Interest] [numeric] (9, 1) NULL,
[InterestAmtDue] [numeric] (9, 2) NULL,
[TotalAmtDue] [numeric] (9, 2) NULL,
[LoanGroupingCode] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LoanPaymentSchedule] ADD CONSTRAINT [PK_LoanPaymentSchedule] PRIMARY KEY CLUSTERED ([LoanPaymentScheduleID]) ON [PRIMARY]
GO
